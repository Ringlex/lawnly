/** Zapytanie niezależne od dostawcy; każdy dostawca składa z niego własny format. */
export interface ModelImage {
  data: string;
  mediaType: string;
}

export interface ModelRequest {
  system: string;
  text: string;
  images: ModelImage[];
  schema: object;
}

/** Dostawca zwraca tekst JSON zgodny ze schematem albo null, gdy się nie udało. */
export type Provider = (request: ModelRequest) => Promise<string | null>;

export async function firstAnswer(providers: Provider[], request: ModelRequest): Promise<string | null> {
  for (const provider of providers) {
    const text = await provider(request);
    if (text) return text;
  }

  return null;
}
