import {
  BadRequest,
  describeJournal,
  describeLawn,
  describeWeather,
  readToday,
} from './context';
import type { Env } from './env';
import { geminiProvider } from './gemini';
import { firstAnswer, type ModelRequest } from './model';
import { privacyPage } from './privacy';
import { ASK_SYSTEM, DIAGNOSIS_SYSTEM, inLanguage } from './prompts';
import { handleReport } from './report';
import { ASK_SCHEMA, DIAGNOSIS_SCHEMA } from './schemas';
import { json, sha256 } from './util';
import { workersAiProvider } from './workers-ai';

const ASSISTANT_ROUTES = ['/v1/diagnose', '/v1/ask'];

/** Stan limitu bez zużywania pytania - do licznika na ekranie asystenta. */
const QUOTA_ROUTE = '/v1/quota';

/** Zgłoszenie odpowiedzi. Nie kosztuje pytania, bo wtedy nikt by nie zgłaszał. */
const REPORT_ROUTE = '/v1/report';

const PAGES: Record<string, () => Response> = { '/privacy': privacyPage };

/** Zdjęcie po kompresji w aplikacji. Ponad to odrzucamy. */
const MAX_IMAGE_BYTES = 4 * 1024 * 1024;
const MAX_IMAGES = 2;
const ALLOWED_MEDIA_TYPES = ['image/jpeg', 'image/png', 'image/webp'];

/** Wcześniejsze wymiany w rozmowie, żeby dopytanie miało kontekst. */
const MAX_HISTORY = 6;

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const path = new URL(request.url).pathname;

    const page = PAGES[path];
    if (page) {
      return request.method === 'GET' || request.method === 'HEAD'
        ? page()
        : json({ error: 'method_not_allowed' }, 405);
    }

    if (request.method !== 'POST') {
      return json({ error: 'method_not_allowed' }, 405);
    }
    if (!ASSISTANT_ROUTES.includes(path) && path !== QUOTA_ROUTE && path !== REPORT_ROUTE) {
      return json({ error: 'not_found' }, 404);
    }

    let body: Record<string, unknown>;
    try {
      body = (await request.json()) as Record<string, unknown>;
    } catch {
      return json({ error: 'invalid_json' }, 400);
    }

    const identity = await resolveIdentity(body);
    if (!identity) {
      return json({ error: 'unauthorized' }, 401);
    }

    if (path === QUOTA_ROUTE) {
      const quota = await readQuota(env, identity);
      return json({ remaining: quota.remaining, limit: quota.limit, resetsAt: quota.resetsAt }, 200);
    }

    if (path === REPORT_ROUTE) {
      const result = await handleReport(env, identity, body);
      return json(result.body, result.status);
    }

    let payload: ModelRequest;
    try {
      payload = path === '/v1/diagnose' ? buildDiagnosisRequest(body) : buildAskRequest(body);
    } catch (error) {
      if (error instanceof BadRequest) {
        return json({ error: error.code }, 400);
      }
      throw error;
    }

    const quota = await consumeQuota(env, identity);
    if (!quota.allowed) {
      return json({ error: 'quota_exceeded', resetsAt: quota.resetsAt, limit: quota.limit }, 429);
    }

    const response = await answer(env, payload, quota);

    // Bez odpowiedzi użytkownik nie powinien płacić pytaniem.
    if (response.status >= 500) {
      await refundQuota(env, identity);
    }

    return response;
  },
};

// --- wejście -----------------------------------------------------------------

function requireString(body: Record<string, unknown>, key: string, maxLength: number): string {
  const value = body[key];

  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new BadRequest(`missing_${key}`);
  }
  if (value.length > maxLength) {
    throw new BadRequest(`${key}_too_long`);
  }

  return value.trim();
}

function readImages(body: Record<string, unknown>): { data: string; mediaType: string }[] {
  const raw = body.images;
  if (raw === undefined || raw === null) return [];
  if (!Array.isArray(raw) || raw.length > MAX_IMAGES) {
    throw new BadRequest('too_many_images');
  }

  return raw.map((item) => {
    const image = item as Record<string, unknown>;
    const data = image.base64;
    const mediaType = image.mediaType;

    if (typeof data !== 'string' || data.length === 0) {
      throw new BadRequest('missing_image');
    }
    if (typeof mediaType !== 'string' || !ALLOWED_MEDIA_TYPES.includes(mediaType)) {
      throw new BadRequest('unsupported_media_type');
    }
    // Base64 rozdmuchuje bajty o ok. jedną trzecią; liczymy rozmiar oryginału.
    if ((data.length * 3) / 4 > MAX_IMAGE_BYTES) {
      throw new BadRequest('image_too_large');
    }

    return { data, mediaType };
  });
}

function contextText(body: Record<string, unknown>): string {
  return [
    `Dzisiaj: ${readToday(body)}`,
    describeLawn(body.lawn),
    describeWeather(body.weather),
    describeJournal(body.journal),
  ].join('\n\n');
}

function buildDiagnosisRequest(body: Record<string, unknown>): ModelRequest {
  const problem = requireString(body, 'problem', 120);
  const description = typeof body.description === 'string' ? body.description.trim().slice(0, 3000) : '';
  const since = typeof body.since === 'string' ? body.since.trim().slice(0, 60) : '';
  const images = readImages(body);

  const text = [
    contextText(body),
    `Zgłoszony problem: ${problem}`,
    since ? `Od kiedy: ${since}` : null,
    description ? `Opis właściciela:\n${description}` : null,
    images.length > 0 ? `Dołączone zdjęcia: ${images.length}.` : 'Bez zdjęcia.',
  ]
    .filter(Boolean)
    .join('\n\n');

  return { system: inLanguage(DIAGNOSIS_SYSTEM, body.language), text, images, schema: DIAGNOSIS_SCHEMA };
}

function buildAskRequest(body: Record<string, unknown>): ModelRequest {
  const question = requireString(body, 'question', 1000);
  const images = readImages(body);
  const history = Array.isArray(body.history) ? body.history.slice(-MAX_HISTORY) : [];

  const conversation = history
    .map((item) => item as Record<string, unknown>)
    .filter((turn) => (turn.role === 'user' || turn.role === 'assistant') && typeof turn.text === 'string')
    .map((turn) => `${turn.role === 'user' ? 'Użytkownik' : 'Asystent'}: ${(turn.text as string).slice(0, 2000)}`);

  const text = [
    contextText(body),
    conversation.length > 0 ? `Wcześniejsza rozmowa:\n${conversation.join('\n')}` : null,
    `Pytanie: ${question}`,
  ]
    .filter(Boolean)
    .join('\n\n');

  return { system: inLanguage(ASK_SYSTEM, body.language), text, images, schema: ASK_SCHEMA };
}

// --- wywołanie modelu --------------------------------------------------------

async function answer(env: Env, request: ModelRequest, quota: QuotaResult): Promise<Response> {
  const gemini = geminiProvider(env);
  const workersAi = workersAiProvider(env);
  const providers = request.images.length > 0 ? [gemini, workersAi] : [workersAi, gemini];
  const text = await firstAnswer(providers, request);

  if (!text) {
    console.error('all_providers_failed');
    return json({ error: 'upstream_busy' }, 503);
  }

  return new Response(text, {
    status: 200,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'x-quota-remaining': String(quota.remaining),
      'x-quota-limit': String(quota.limit),
      'x-quota-resets-at': quota.resetsAt,
    },
  });
}

// --- tożsamość i limity ------------------------------------------------------

/**
 * Identyfikator instalacji z aplikacji. Da się go podrobić, więc limit to
 * mały darmowy próg, a nie zabezpieczenie. Przechowujemy tylko skrót.
 */
async function resolveIdentity(body: Record<string, unknown>): Promise<string | null> {
  const installId = body.installId;

  if (typeof installId !== 'string' || installId.length < 16 || installId.length > 128) {
    return null;
  }

  return `anon:${await sha256(installId)}`;
}

interface QuotaResult {
  allowed: boolean;
  remaining: number;
  limit: number;
  resetsAt: string;
}

function quotaKey(identity: string): string {
  return `${identity}:${new Date().toISOString().slice(0, 10)}`;
}

function nextReset(): string {
  const tomorrow = new Date();
  tomorrow.setUTCHours(24, 0, 0, 0);
  return tomorrow.toISOString();
}

async function readQuota(env: Env, identity: string): Promise<QuotaResult> {
  const limit = Number(env.DAILY_LIMIT);
  const used = Number((await env.QUOTA.get(quotaKey(identity))) ?? '0');
  const remaining = Math.max(0, limit - used);
  return { allowed: remaining > 0, remaining, limit, resetsAt: nextReset() };
}

async function consumeQuota(env: Env, identity: string): Promise<QuotaResult> {
  const quota = await readQuota(env, identity);
  if (!quota.allowed) return quota;

  // Licznik wygasa sam po dobie z zapasem.
  const used = quota.limit - quota.remaining;
  await env.QUOTA.put(quotaKey(identity), String(used + 1), { expirationTtl: 60 * 60 * 26 });

  return { ...quota, remaining: quota.remaining - 1 };
}

async function refundQuota(env: Env, identity: string): Promise<void> {
  const key = quotaKey(identity);
  const used = Number((await env.QUOTA.get(key)) ?? '0');

  if (used > 0) {
    await env.QUOTA.put(key, String(used - 1), { expirationTtl: 60 * 60 * 26 });
  }
}
