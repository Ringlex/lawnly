/**
 * Polityka prywatności serwowana przez tego samego Workera: Google Play
 * wymaga działającego adresu WWW, a Worker ma już HTTPS.
 *
 * Treść opisuje to, co robi kod. Po zmianie przepływu danych w aplikacji
 * albo w Workerze trzeba ją zaktualizować w obu językach.
 */

const ADMINISTRATOR = 'Robert Bajor';
const CONTACT = 'robert.bajor110@gmail.com';

export function privacyPage(): Response {
  return html(PL);
}

export function privacyPageEn(): Response {
  return html(EN);
}

function html(body: string): Response {
  return new Response(body, {
    headers: { 'content-type': 'text/html; charset=utf-8', 'cache-control': 'public, max-age=3600' },
  });
}

function page(lang: string, title: string, content: string): string {
  return `<!doctype html>
<html lang="${lang}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${title}</title>
<style>
  :root { color-scheme: light dark; }
  body { margin: 0 auto; padding: 2rem 1.25rem 4rem; max-width: 46rem; font: 16px/1.65 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #F4F7F2; color: #17251B; overflow-wrap: anywhere; }
  a { color: inherit; }
  @media (prefers-color-scheme: dark) { body { background: #0B1A10; color: #E4F2DA; } }
  h1 { font-size: 1.9rem; margin-bottom: .25rem; }
  h2 { font-size: 1.25rem; margin-top: 2.5rem; }
  .sub { opacity: .7; margin-top: 0; }
</style>
</head>
<body>
<h1>${title}</h1>
${content}
</body>
</html>`;
}

const PL = page(
  'pl',
  'Lawnly — Polityka prywatności',
  `<p class="sub">Ostatnia aktualizacja: 26 listopada 2026 · <a href="/privacy/en">English</a></p>

<h2>Kto odpowiada za dane</h2>
<p>Administratorem danych w aplikacji Lawnly jest ${ADMINISTRATOR}. Kontakt: ${CONTACT}.</p>
<p>Lawnly nie ma kont użytkowników, reklam ani narzędzi analitycznych. Nie sprzedajemy danych.</p>

<h2>Co jest zapisane w telefonie</h2>
<p>Profile trawników, plany zabiegów, dziennik, zdjęcia i ustawienia są zapisane na Twoim telefonie. Poza nim trafiają tylko w sytuacjach opisanych niżej.</p>

<h2>Kopia zapasowa i eksport</h2>
<p>Jeśli masz włączoną kopię zapasową w telefonie, system może zapisać dane aplikacji na Twoim koncie Google (Android) albo w iCloud (iOS). Na Androidzie zdjęcia z dziennika nie trafiają do kopii w chmurze. Nie mamy dostępu do tych kopii.</p>
<p>Możesz też wyeksportować dane do pliku i zapisać go w wybranym miejscu. Plik nie jest zaszyfrowany i zawiera m.in. położenie trawnika oraz zdjęcia.</p>

<h2>Lokalizacja i pogoda</h2>
<p>Możesz wpisać miejscowość albo pozwolić aplikacji pobrać przybliżoną lokalizację. Do pobrania prognozy aplikacja wysyła współrzędne trawnika do MET Norway (met.no). Wyszukiwanie miejscowości i dane o opadach z ostatnich dni pochodzą z Open-Meteo (open-meteo.com), gdzie trafia nazwa miejscowości lub współrzędne. Aplikacja nie śledzi lokalizacji w tle.</p>

<h2>Asystent AI</h2>
<p>Asystent jest opcjonalny. Gdy zadasz pytanie albo poprosisz o diagnozę, aplikacja wysyła na nasz serwer: treść pytania lub opis problemu, wcześniejsze wiadomości z rozmowy, wybrane zdjęcia, dane trawnika (m.in. powierzchnię, mieszankę, glebę, pH, nazwę miejscowości i daty zabiegów), pogodę i prognozę, ostatnie wpisy z dziennika (rodzaj, objawy, produkt i notatki, bez zdjęć z dziennika), język aplikacji oraz losowy identyfikator instalacji. Współrzędnych nie wysyłamy do asystenta.</p>
<p>Serwer działa w usłudze Cloudflare, a odpowiedzi przygotowują modele AI uruchamiane w Cloudflare Workers AI. Twoich danych nie przekazujemy innym dostawcom AI. Cloudflare deklaruje, że nie wykorzystuje treści przetwarzanych w Workers AI do trenowania modeli. Zapisuje natomiast dane techniczne o zapytaniach, np. czas i rozmiar.</p>
<p>Odpowiedzi AI mogą być błędne. Nie wpisuj danych osobowych i nie wysyłaj zdjęć, na których widać osoby albo inne rzeczy, których nie chcesz udostępniać.</p>
<p>Nasz serwer nie zapisuje pytań, odpowiedzi ani zdjęć, z wyjątkiem zgłoszeń opisanych niżej. Do naliczania dziennego limitu przechowuje do 26 godzin skrót identyfikatora instalacji i liczbę pytań.</p>

<h2>Zgłoszenia odpowiedzi</h2>
<p>Jeśli zgłosisz odpowiedź asystenta, zapisujemy jej treść, powód zgłoszenia, Twój komentarz, datę i skrót identyfikatora instalacji, żeby ją sprawdzić. Zgłoszenia usuwamy automatycznie po 12 miesiącach.</p>

<h2>Fonty i połączenia sieciowe</h2>
<p>Aplikacja pobiera fonty z serwerów Google (Google Fonts). Przy każdym połączeniu z usługami wymienionymi w tej polityce ich dostawcy otrzymują dane techniczne, w tym adres IP.</p>

<h2>Cel i podstawa przetwarzania</h2>
<p>Dane przetwarzamy, żeby świadczyć funkcje, z których korzystasz (art. 6 ust. 1 lit. b RODO), oraz w uzasadnionym interesie: ochrony asystenta przed nadużyciami i sprawdzania zgłoszeń (art. 6 ust. 1 lit. f RODO). Dostawcy mogą przetwarzać dane także poza Europejskim Obszarem Gospodarczym.</p>

<h2>Twoje prawa i usuwanie danych</h2>
<p>Dane w telefonie usuniesz, czyszcząc dane aplikacji lub ją odinstalowując. Kopie zapasowe i wyeksportowane pliki usuwasz osobno. Masz prawo do dostępu do danych, ich sprostowania, usunięcia, ograniczenia przetwarzania, przenoszenia i sprzeciwu. O usunięcie zgłoszenia poprosisz, pisząc na adres kontaktowy i podając datę oraz treść zgłoszenia. Możesz też złożyć skargę do Prezesa Urzędu Ochrony Danych Osobowych.</p>

<h2>Dzieci</h2>
<p>Lawnly jest przeznaczona dla osób dorosłych (18+).</p>

<h2>Zmiany</h2>
<p>Aktualizacje tej polityki publikujemy na tej stronie wraz z nową datą.</p>`,
);

const EN = page(
  'en',
  'Lawnly — Privacy Policy',
  `<p class="sub">Last updated: 26 November 2026 · <a href="/privacy">Polski</a></p>

<h2>Who is responsible</h2>
<p>The data controller for the Lawnly app is ${ADMINISTRATOR}. Contact: ${CONTACT}.</p>
<p>Lawnly has no user accounts, ads or analytics tools. We do not sell data.</p>

<h2>What is stored on your phone</h2>
<p>Lawn profiles, care plans, the journal, photos and settings are stored on your phone. They leave it only in the cases described below.</p>

<h2>Backup and export</h2>
<p>If backup is enabled on your phone, the system may save app data to your Google account (Android) or iCloud (iOS). On Android, journal photos are not included in the cloud backup. We have no access to these backups.</p>
<p>You can also export your data to a file and save it wherever you choose. The file is not encrypted and includes your lawn location and photos.</p>

<h2>Location and weather</h2>
<p>You can type a town or let the app read your approximate location. To get the forecast, the app sends the lawn coordinates to MET Norway (met.no). Town search and recent rainfall come from Open-Meteo (open-meteo.com), which receives the town name or coordinates. The app does not track location in the background.</p>

<h2>AI assistant</h2>
<p>The assistant is optional. When you ask a question or request a diagnosis, the app sends our server: your question or problem description, earlier messages in the conversation, the photos you select, lawn details (including area, grass mix, soil, pH, town name and care dates), weather and forecast, recent journal entries (type, symptoms, product and notes, without journal photos), the app language and a random installation identifier. Coordinates are not sent to the assistant.</p>
<p>The server runs on Cloudflare, and answers are produced by AI models running on Cloudflare Workers AI. We do not pass your data to any other AI provider. Cloudflare states that it does not use content processed by Workers AI to train models. It does record technical data about requests, such as time and size.</p>
<p>AI answers can be wrong. Do not enter personal information or send photos showing people or anything else you do not want to share.</p>
<p>Our server does not store questions, answers or photos, except for the reports described below. To enforce the daily limit it keeps a hash of the installation identifier and the number of questions for up to 26 hours.</p>

<h2>Reported answers</h2>
<p>If you report an assistant answer, we store its text, the reason, your comment, the date and a hash of the installation identifier so that we can review it. Reports are deleted automatically after 12 months.</p>

<h2>Fonts and network connections</h2>
<p>The app downloads fonts from Google servers (Google Fonts). Whenever the app connects to a service named in this policy, its provider receives technical data, including your IP address.</p>

<h2>Purpose and legal basis</h2>
<p>We process data to provide the features you use (Article 6(1)(b) GDPR) and for our legitimate interest in protecting the assistant from abuse and reviewing reports (Article 6(1)(f) GDPR). Providers may also process data outside the European Economic Area.</p>

<h2>Your rights and deleting data</h2>
<p>To delete data on your phone, clear the app data or uninstall the app. Delete backups and exported files separately. You have the right to access, correct, delete, restrict, port and object to the processing of your data. To ask for a report to be deleted, write to the contact address with the date and content of the report. You can also complain to your data protection authority (in Poland: the President of the Personal Data Protection Office).</p>

<h2>Children</h2>
<p>Lawnly is intended for adults (18+).</p>

<h2>Changes</h2>
<p>We publish updates to this policy on this page with a new date.</p>`,
);
