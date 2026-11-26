import type { Env } from './env';
import type { ModelRequest, Provider } from './model';

/**
 * Interactions API, jak w Pitstopie: odpowiedź ma kształt
 * `steps[].content[].text`, a nie starą płaską tablicę `outputs`.
 */
const GEMINI_URL = 'https://generativelanguage.googleapis.com/v1beta/interactions';

/**
 * Kolejka modeli na darmowym progu: najlepszy pierwszy, kolejne przy limicie
 * albo przeciążeniu. Lite na końcu: słabszy, ale najrzadziej przeciążony.
 * 3.6 Flash ma w tym projekcie znikomy limit dzienny, 2.5 nie jest już dostępny dla nowych kont.
 */
const MODELS = [
  'gemini-3.8-flash',
  'gemini-3.6-flash',
  'gemini-2.5-flash',
  'gemini-3.8-flash-lite',
];

/** Jedno wywołanie nie może wisieć: aplikacja czeka na odpowiedź. */
const REQUEST_TIMEOUT_MS = 18_000;

/** Po tym czasie nie próbujemy kolejnych modeli, tylko oddajemy dostawcę zapasowego. */
const TOTAL_BUDGET_MS = 20_000;

export function geminiProvider(env: Env): Provider {
  return async (request) => {
    const startedAt = Date.now();

    for (const model of MODELS) {
      if (Date.now() - startedAt >= TOTAL_BUDGET_MS) break;

      if (await isExhausted(env, model)) continue;

      const text = await tryModel(env, model, request);
      if (text) return text;
    }

    return null;
  };
}

/**
 * Dzienny limit darmowego progu liczy się na cały projekt i nie minie przed
 * resetem, więc po 429 pomijamy model, zamiast pytać go przy każdym pytaniu.
 */
const EXHAUSTED_TTL_SECONDS = 60 * 60;

function exhaustedKey(model: string): string {
  return `gemini-exhausted:${model}`;
}

async function isExhausted(env: Env, model: string): Promise<boolean> {
  return (await env.QUOTA.get(exhaustedKey(model))) !== null;
}

async function markExhausted(env: Env, model: string): Promise<void> {
  await env.QUOTA.put(exhaustedKey(model), '1', { expirationTtl: EXHAUSTED_TTL_SECONDS });
}

async function tryModel(env: Env, model: string, request: ModelRequest): Promise<string | null> {
  try {
    const response = await fetch(GEMINI_URL, {
      method: 'POST',
      headers: { 'content-type': 'application/json', 'x-goog-api-key': env.GEMINI_API_KEY },
      body: JSON.stringify(buildBody(model, request)),
      signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
    });

    if (!response.ok) {
      const detail = (await response.text()).slice(0, 300);
      console.warn('gemini_failed', JSON.stringify({ model, status: response.status, detail }));
      if (response.status === 429) await markExhausted(env, model);
      return null;
    }

    const text = extractText((await response.json()) as GeminiInteraction);
    if (!text) console.warn('gemini_no_text', model);

    return text || null;
  } catch (error) {
    console.warn('gemini_error', model, String(error));
    return null;
  }
}

function buildBody(model: string, request: ModelRequest): Record<string, unknown> {
  const input: Record<string, unknown>[] = request.images.map((image) => ({
    type: 'image',
    data: image.data,
    mime_type: image.mediaType,
  }));
  input.push({ type: 'text', text: request.text });

  return {
    model,
    system_instruction: request.system,
    input,
    response_format: { type: 'text', mime_type: 'application/json', schema: request.schema },
    ...(supportsThinkingLevel(model) && { generation_config: { thinking_level: 'low' } }),
  };
}

/** Domyślne myślenie wydłuża odpowiedź o kilka sekund; porada o trawniku go nie potrzebuje. */
function supportsThinkingLevel(model: string): boolean {
  return /^gemini-3\.\d+-flash$/.test(model);
}

interface GeminiInteraction {
  steps?: { type?: string; content?: { type?: string; text?: string }[] }[];
}

/** Sklejamy wszystkie bloki tekstu: dłuższa odpowiedź potrafi przyjść w kilku. */
function extractText(interaction: GeminiInteraction): string {
  const parts: string[] = [];

  for (const step of interaction.steps ?? []) {
    if (step.type !== 'model_output') continue;
    for (const block of step.content ?? []) {
      if (block.type === 'text' && block.text) parts.push(block.text);
    }
  }

  return parts.join('');
}
