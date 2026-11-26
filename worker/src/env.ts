export interface Env {
  /** Klucz do Gemini. `wrangler secret put GEMINI_API_KEY`. */
  GEMINI_API_KEY: string;

  /** Workers AI: zapasowy dostawca, gdy Gemini zawiedzie. */
  AI?: Ai;

  /** Dzienny licznik pytań na instalację oraz zgłoszenia odpowiedzi. */
  QUOTA: KVNamespace;

  /** Darmowe pytania dziennie na instalację. */
  DAILY_LIMIT: string;
}
