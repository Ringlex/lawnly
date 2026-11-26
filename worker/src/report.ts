/**
 * Zgłoszenia odpowiedzi asystenta (wymóg zasad Google Play dla treści z modelu).
 *
 * Bez bazy danych: zgłoszenie ląduje w KV pod kluczem `report:<data>:<id>` bez
 * terminu ważności. Przegląd: `wrangler kv key list --binding QUOTA --prefix report:`.
 */
import type { Env } from './env';
import { sha256 } from './util';

const REASONS = ['wrong', 'offensive', 'dangerous', 'other'];
const KINDS = ['diagnosis', 'ask'];
const MAX_CONTENT = 8000;
const MAX_NOTE = 1000;

/** Zapis jest darmowy dla zgłaszającego, więc limit chroni sam magazyn. */
const DAILY_LIMIT = 20;

export async function handleReport(
  env: Env,
  identity: string,
  body: Record<string, unknown>,
): Promise<{ status: number; body: Record<string, unknown> }> {
  const reason = body.reason;
  if (typeof reason !== 'string' || !REASONS.includes(reason)) {
    return { status: 400, body: { error: 'invalid_reason' } };
  }

  const content = typeof body.content === 'string' ? body.content.trim() : '';
  if (content.length === 0) {
    return { status: 400, body: { error: 'missing_content' } };
  }

  const kind = typeof body.kind === 'string' && KINDS.includes(body.kind) ? body.kind : 'ask';
  const note = typeof body.note === 'string' && body.note.trim() ? body.note.trim().slice(0, MAX_NOTE) : null;
  const reporter = await sha256(identity);
  const day = new Date().toISOString().slice(0, 10);

  const counterKey = `report-count:${reporter}:${day}`;
  const used = Number((await env.QUOTA.get(counterKey)) ?? '0');
  if (used >= DAILY_LIMIT) {
    return { status: 429, body: { error: 'too_many_reports' } };
  }
  await env.QUOTA.put(counterKey, String(used + 1), { expirationTtl: 60 * 60 * 26 });

  const id = crypto.randomUUID();
  await env.QUOTA.put(
    `report:${day}:${id}`,
    JSON.stringify({ id, createdAt: new Date().toISOString(), reporter, kind, reason, note, content: content.slice(0, MAX_CONTENT) }),
  );

  return { status: 200, body: { ok: true, id } };
}
