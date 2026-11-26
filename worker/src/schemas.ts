/**
 * Kształty odpowiedzi wymuszane przez structured outputs.
 *
 * Aplikacja parsuje te JSON-y wprost do modeli, więc każde pole jest w
 * `required`, a to, co bywa nieznane, ma jawny wariant null.
 */

export const CARE_KINDS = [
  'fertilizing',
  'mowing',
  'watering',
  'aeration',
  'scarification',
  'overseeding',
  'liming',
  'other',
] as const;

const ACTIONS = {
  type: 'array',
  description: 'Zabiegi do wpisania w kalendarz. Najwyżej trzy. Pusta lista, gdy nic nie trzeba robić.',
  items: {
    type: 'object',
    properties: {
      kind: { type: 'string', enum: CARE_KINDS },
      title: { type: 'string', description: 'Krótka nazwa, np. "Nicienie pożyteczne".' },
      when: { type: 'string', description: 'Kiedy i pod jakim warunkiem, np. "maj, gdy gleba ma min. 12°C".' },
      earliestDate: {
        anyOf: [{ type: 'string' }, { type: 'null' }],
        description: 'Najwcześniejszy sensowny dzień RRRR-MM-DD, nie wcześniej niż dziś. null, gdy nie da się wskazać.',
      },
    },
    required: ['kind', 'title', 'when', 'earliestDate'],
    additionalProperties: false,
  },
} as const;

const FOLLOW_UPS = {
  type: 'array',
  description: 'Dwa-trzy krótkie pytania, które użytkownik może zadać dalej. Pusta lista, gdy nie ma sensu.',
  items: { type: 'string' },
} as const;

export const DIAGNOSIS_SCHEMA = {
  type: 'object',
  properties: {
    summary: {
      type: 'string',
      description: 'Dwa-trzy zdania: co najpewniej się dzieje i dlaczego, z odwołaniem do danych trawnika lub pogody.',
    },
    urgency: {
      type: 'string',
      enum: ['act_now', 'soon', 'routine'],
      description: 'act_now = szkoda szybko się rozprzestrzenia, soon = w najbliższych tygodniach, routine = przy okazji lub w kolejnym sezonie.',
    },
    causes: {
      type: 'array',
      description: 'Prawdopodobne przyczyny, od najbardziej prawdopodobnej. Najwyżej cztery.',
      items: {
        type: 'object',
        properties: {
          name: { type: 'string', description: 'Nazwa przyczyny, np. "Pędraki".' },
          likelihood: { type: 'string', enum: ['high', 'medium', 'low'] },
          explanation: { type: 'string', description: 'Dlaczego to pasuje do opisu, zdjęcia i danych.' },
          checkFirst: { type: 'string', description: 'Najprostszy sposób, by to potwierdzić lub wykluczyć.' },
        },
        required: ['name', 'likelihood', 'explanation', 'checkFirst'],
        additionalProperties: false,
      },
    },
    actions: ACTIONS,
    followUpQuestions: FOLLOW_UPS,
  },
  required: ['summary', 'urgency', 'causes', 'actions', 'followUpQuestions'],
  additionalProperties: false,
} as const;

export const ASK_SCHEMA = {
  type: 'object',
  properties: {
    answer: {
      type: 'string',
      description: 'Odpowiedź zwykłym tekstem, jeden do trzech krótkich akapitów rozdzielonych pustą linią.',
    },
    actions: ACTIONS,
    followUpQuestions: FOLLOW_UPS,
  },
  required: ['answer', 'actions', 'followUpQuestions'],
  additionalProperties: false,
} as const;
