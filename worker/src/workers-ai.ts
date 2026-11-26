import type { Env } from './env';
import { matchesSchema } from './matches-schema';
import type { ModelImage, ModelRequest, Provider } from './model';

/**
 * Tylko Cloudflare Workers AI: darmowy dzienny limit, po jego wyczerpaniu
 * zapytania kończą się błędem, bez opłat na planie Workers Free.
 * Zdjęcia obsługuje Gemma; pytania bez zdjęć zaczynają od Llamy.
 */
const VISION_MODEL = '@cf/google/gemma-4-26b-a4b-it';
const TEXT_MODEL = '@cf/meta/llama-3.3-70b-instruct-fp8-fast';

const REQUEST_TIMEOUT_MS = 25_000;
const MAX_OUTPUT_TOKENS = 1500;

const IMAGES_DROPPED_NOTE =
  'Użytkownik dołączył zdjęcia, ale nie masz do nich dostępu. Zaznacz to w odpowiedzi i oprzyj się na opisie.';

interface Attempt {
  model: string;
  input: (request: ModelRequest) => Record<string, unknown>;
}

const gemma: Attempt = {
  model: VISION_MODEL,
  input: (request) => ({
    messages: [
      { role: 'system', content: `${request.system}\n\n${schemaRule(request.schema)}` },
      { role: 'user', content: userContent(request.text, request.images) },
    ],
    max_completion_tokens: MAX_OUTPUT_TOKENS,
    chat_template_kwargs: { enable_thinking: false },
    response_format: { type: 'json_object' },
  }),
};

const llama: Attempt = {
  model: TEXT_MODEL,
  input: (request) => ({
    messages: [
      { role: 'system', content: request.system },
      {
        role: 'user',
        content: request.images.length > 0 ? `${request.text}\n\n${IMAGES_DROPPED_NOTE}` : request.text,
      },
    ],
    max_tokens: MAX_OUTPUT_TOKENS,
    response_format: { type: 'json_schema', json_schema: request.schema },
  }),
};

/** Wymuszony `json_schema` zapętlał Gemmę do limitu tokenów, więc schemat idzie w instrukcji. */
function schemaRule(schema: object): string {
  return `Odpowiedz wyłącznie jednym obiektem JSON zgodnym z tym schematem (JSON Schema), bez żadnego innego tekstu:\n${JSON.stringify(schema)}`;
}

function userContent(text: string, images: ModelImage[]): unknown {
  if (images.length === 0) return text;

  return [
    { type: 'text', text },
    ...images.map((image) => ({
      type: 'image_url',
      image_url: { url: `data:${image.mediaType};base64,${image.data}` },
    })),
  ];
}

export function workersAiProviders(env: Env, request: ModelRequest): Provider[] {
  const attempts = request.images.length > 0 ? [gemma, llama] : [llama, gemma];
  return attempts.map((attempt) => provider(env, attempt));
}

function provider(env: Env, attempt: Attempt): Provider {
  return async (request) => {
    try {
      const result = await env.AI.run(
        attempt.model as keyof AiModels,
        attempt.input(request) as never,
        { signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS) } as never,
      );

      const text = extractJson(result as AiResult, request.schema);
      if (!text) console.warn('workers_ai_no_json', attempt.model);

      return text;
    } catch (error) {
      console.warn('workers_ai_error', attempt.model, String(error));
      return null;
    }
  };
}

interface AiResult {
  response?: unknown;
  choices?: { message?: { content?: string | null } }[];
}

/** Aplikacja parsuje odpowiedź jako JSON, więc ucięty albo luźny tekst odrzucamy. */
function extractJson(result: AiResult, schema: object): string | null {
  const raw = result.response ?? result.choices?.[0]?.message?.content;
  const text = typeof raw === 'string' ? raw.trim().replace(/^```(?:json)?\s*|\s*```$/g, '') : null;

  try {
    const parsed: unknown = text === null ? raw : JSON.parse(text);
    return matchesSchema(parsed, schema) ? (text ?? JSON.stringify(parsed)) : null;
  } catch {
    return null;
  }
}
