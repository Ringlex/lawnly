import type { Env } from './env';
import type { ModelRequest, Provider } from './model';

/** Darmowy próg Cloudflare, niezależny od limitów Google. */
const MODELS = ['@cf/meta/llama-3.3-70b-instruct-fp8-fast', '@cf/meta/llama-3.1-8b-instruct-fast'];

const REQUEST_TIMEOUT_MS = 25_000;
const MAX_OUTPUT_TOKENS = 1500;

const IMAGES_DROPPED_NOTE =
  'Użytkownik dołączył zdjęcia, ale nie masz do nich dostępu. Zaznacz to w odpowiedzi i oprzyj się na opisie.';

export function workersAiProvider(env: Env): Provider {
  return async (request) => {
    const ai = env.AI;
    if (!ai) return null;

    for (const model of MODELS) {
      const text = await tryModel(ai, model, request);
      if (text) return text;
    }

    return null;
  };
}

async function tryModel(ai: Ai, model: string, request: ModelRequest): Promise<string | null> {
  const text = request.images.length > 0 ? `${request.text}\n\n${IMAGES_DROPPED_NOTE}` : request.text;

  try {
    const result = (await ai.run(
      model as keyof AiModels,
      {
        messages: [
          { role: 'system', content: request.system },
          { role: 'user', content: text },
        ],
        max_tokens: MAX_OUTPUT_TOKENS,
        response_format: { type: 'json_schema', json_schema: request.schema },
      } as never,
      { signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS) } as never,
    )) as { response?: unknown };

    return stringify(result.response);
  } catch (error) {
    console.warn('workers_ai_error', model, String(error));
    return null;
  }
}

function stringify(response: unknown): string | null {
  if (typeof response === 'string') return response.trim() || null;
  if (response && typeof response === 'object') return JSON.stringify(response);

  return null;
}
