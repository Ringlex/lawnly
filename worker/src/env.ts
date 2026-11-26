export interface Env {
  /** Workers AI: jedyny dostawca modeli. */
  AI: Ai;

  /** Dzienny licznik pytań na instalację oraz zgłoszenia odpowiedzi. */
  QUOTA: KVNamespace;

  /** Darmowe pytania dziennie na instalację. */
  DAILY_LIMIT: string;
}
