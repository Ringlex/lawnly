/**
 * Polityka prywatności serwowana przez tego samego Workera: Google Play
 * wymaga działającego adresu WWW, a Worker ma już HTTPS.
 *
 * Treść opisuje to, co robi kod: dane trawnika zostają w telefonie, a do
 * asystenta trafiają tylko przy zadaniu pytania.
 */

/** Uzupełnij przed publikacją w sklepie. */
const CONTACT = '[ADRES KONTAKTOWY]';
const UPDATED = '9 października 2026';

export function privacyPage(): Response {
  return new Response(HTML, {
    headers: { 'content-type': 'text/html; charset=utf-8', 'cache-control': 'public, max-age=3600' },
  });
}

const HTML = `<!doctype html>
<html lang="pl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Lawnly — Polityka prywatności</title>
<style>
  :root { color-scheme: light dark; }
  body { margin: 0 auto; padding: 2rem 1.25rem 4rem; max-width: 46rem; font: 16px/1.65 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #F4F7F2; color: #17251B; }
  @media (prefers-color-scheme: dark) { body { background: #0B1A10; color: #E4F2DA; } }
  h1 { font-size: 1.9rem; margin-bottom: .25rem; }
  h2 { font-size: 1.25rem; margin-top: 2.5rem; }
  .sub { opacity: .7; margin-top: 0; }
</style>
</head>
<body>
<h1>Lawnly — Polityka prywatności</h1>
<p class="sub">Ostatnia aktualizacja: ${UPDATED}</p>

<h2>Co zostaje w telefonie</h2>
<p>Profil trawnika, plan zabiegów, dziennik i zdjęcia są zapisane wyłącznie na Twoim telefonie. Aplikacja nie ma kont i nie wysyła tych danych na nasz serwer, poza sytuacją opisaną niżej.</p>

<h2>Prognoza pogody</h2>
<p>Do pobrania prognozy aplikacja wysyła współrzędne trawnika do serwisu MET Norway (met.no). Nie wysyłamy tam nic poza współrzędnymi. Wyszukiwanie miejscowości i dane o opadach z ostatnich dni pochodzą z Open-Meteo (open-meteo.com), gdzie trafia nazwa miejscowości lub współrzędne.</p>

<h2>Asystent</h2>
<p>Gdy zadasz pytanie asystentowi albo poprosisz o diagnozę, aplikacja wysyła na nasz serwer: treść pytania lub opis problemu, wybrane przez Ciebie zdjęcia, dane trawnika (m.in. powierzchnię, mieszankę, glebę, pH, miejscowość), pogodę z ostatnich dni i prognozę oraz tytuły ostatnich wpisów z dziennika. Serwer przekazuje je do modelu Google Gemini, który przygotowuje odpowiedź.</p>
<p>Korzystamy z bezpłatnego dostępu do Gemini. Na tych warunkach Google może wykorzystywać przesłane treści, w tym zdjęcia, do ulepszania swoich usług. Nie dołączaj zdjęć, na których widać osoby albo inne rzeczy, których nie chcesz udostępniać.</p>
<p>Nasz serwer nie zapisuje pytań ani zdjęć. Do naliczania dziennego limitu pytań przechowuje przez dobę skrót losowego identyfikatora instalacji i liczbę pytań.</p>

<h2>Zgłoszenia odpowiedzi</h2>
<p>Jeśli zgłosisz odpowiedź asystenta, zapisujemy jej treść, powód zgłoszenia, Twój komentarz i skrót identyfikatora instalacji, żeby móc ją sprawdzić.</p>

<h2>Kontakt</h2>
<p>${CONTACT}</p>
</body>
</html>`;
