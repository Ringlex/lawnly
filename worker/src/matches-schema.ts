interface Schema {
  type?: string;
  enum?: readonly unknown[];
  anyOf?: readonly Schema[];
  items?: Schema;
  properties?: Record<string, Schema>;
  required?: readonly string[];
}

/** Sprawdza tylko to, czego używają schematy z `schemas.ts`. */
export function matchesSchema(value: unknown, schema: Schema): boolean {
  if (schema.anyOf) return schema.anyOf.some((option) => matchesSchema(value, option));
  if (schema.enum) return schema.enum.includes(value);

  switch (schema.type) {
    case 'null':
      return value === null;
    case 'string':
      return typeof value === 'string';
    case 'array':
      return Array.isArray(value) && value.every((item) => matchesSchema(item, schema.items ?? {}));
    case 'object': {
      if (value === null || typeof value !== 'object' || Array.isArray(value)) return false;
      const record = value as Record<string, unknown>;
      return (
        (schema.required ?? []).every((key) => key in record) &&
        Object.entries(schema.properties ?? {}).every(
          ([key, property]) => !(key in record) || matchesSchema(record[key], property),
        )
      );
    }
    default:
      return true;
  }
}
