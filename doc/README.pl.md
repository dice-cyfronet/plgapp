### Tworzenie aplikacji

*plgapp* udostępnia tryb tworzenia aplikacji aby zapewnić, że testowania zmian w kodzie nie koliduje z produkcyjną wersją modyfikowane aplikacji. Wersja deweloperska dowolnej aplikacji jest zawsze dostępna pod adresem `{subdomena-aplikacji}-dev.app.plgrid.pl` i jest dostępna tylko dla zalogowanych użytkowników platformy *plgapp*. Poniżej przedstawiono listę kroków potrzebnych do stworzenia nowej aplikacji z platformą *plgapp*:

1. Zaloguj się do *plgapp* za pomocą serwera OpenID portalu PL-Grid (należy użyć linku *ZALOGUJ SIĘ PRZEZ PL-GRID*, króry znajduje się w nagłówku strony). Potrzebna jest wcześniejsza aktywacja usługi *plgapp* w portalu PL-Grid.

1. Przełącz się na zakładkę *MOJE APLIKACJE* i użyj przycisku *DODAJ NOWĄ*, aby zarejestrować nową aplikację. Należy podać następujące dane:

	**Nazwa** - przyjazna nazwa aplikacji używana na liście aplikacji,
	
	**Subdomena** - subdomena jest używana do konstrukcji adresu aplikacji, który będzie miał następującą postać: `https://{subdomena-aplikacji}.app.plgrid.pl`,
	
	**Tekst na stronie logowania** - podany tekst będzie wyświetlany na stronie logowania Twojej aplikacji; do formatowania tekstu można użyć  [notacji markdown](http://daringfireball.net/projects/markdown/).
	
	Po kliknięciu na przycisk *STWÓRZ* Twoja aplikacja staje się gotowa do rozbudowy i jest od razu zintegrowana (tylko w trybie tworzenia aplikacji) z serwerem OpenID portalu PL-Grid. Podane wartości mogą być zmieniane w dowolnym momencie za pomocą przycisku *EDYTUJ* w panelu aplikacji. W następnej sekcji pokazano w jaki sposób można synchronizować pliki w trybie tworzenia aplikacji.

#### Synchronizacja plików w trybie tworzenia aplikacji poprzez Dropbox

Aby wykorzystać tryb tworzenia aplikacji należy dostarczyć pliki, które zostaną uruchomione w przeglądarce używkownika (dla większości przypadków będą to pliki HTML, CSS lub JavaScript). Należy pamiętać, że aplikacje *plgapp* są aplikacjami przeglądarkowymi, a wszelka interakcja z infrastrukturą obliczeniową jest realizowana za pomocą bibliotek JavaScript (dla większości zastosowań zestaw bibliotek dostarczony z platformą powinien być wystarczający). W celu automatyzacji procesu przesyłania plików aplikacji do platformy można użyć rozwiązania Dropbox. Zmiany dokonywane w plikach na lokalnym komputerze są wykrywane i przesyłane do platformy i używane w przeglądarce w czasie uruchamiania danej aplikacji. Poniżej przedstawiono listę kroków potrzebnych do wykonania pełnego cyklu tworzenia aplikacji:

1. Załóżmy, że właśnie utworzono nową aplikację *plgapp* i że chcemy udostępnić pierwszą stronę widoczną przez użytkownika po zalogowaniu. Przejdź do panelu aplikacji i wybierz zakłądkę *NOWA WERSJA*, a następnie opcję udostępniania *DROPBOX*. Poniżej znajduje się przycisk *POŁĄCZ Z DROPBOX*, po kliknięciu którego należy postępować zgodnie z przedstawionymi instrukcjami w celu połączenia jednego z katalogów Dropbox z tworzoną aplikacją. Nazwa katalogu powinna mieć następującą postać: `Aplikacje/plgapp/{subdomena-aplikacji}`

1. W katalogu aplikacji w Dropbox należy utworzyć plik `index.html`, który zostanie automatycznie zwrócony do przeglądarki po odwiedzeniu adresu aplikacji `https://{subdomena-aplikacji}-dev.app.plgrid.pl`. Proszę użyć poniższego kodu:

<!-- -->
	<!doctype html>
	<html>
		<head>
			<title>Moja pierwsza aplikacji plgapp</title>
			<script type="text/javascript" src="/plgapp/jquery/2.1.3/jquery.min.js"></script>
			<script type="text/javascript" src="/plgapp/plgapp.js"></script>
		</head>
		<body>
			<div>To jest moja pierwsza aplikacja <em>plgapp</em>.</div>
		</body>
	</html>
	
Tworzenie plików pomocniczych, takich jak JavaScript lub CSS, jest przeprowadzane w standardowy sposób. Należy umieścić pliki w katalogu aplikacji i załączyć jes w kodzie HTML za pomocą odpowiednich tagów (`<script>` lub `<link>`). Biblioteki dostarczane razem z platformą *plgapp* oraz ich API jest dostępne na [osobnej stronie](/help/js_libs).

#### Synchronizacja plików w trybie tworzenia aplikacji poprzez formularz HTML

Jeśli z jakichś przyczy nie da się wykorzystać Dropbox do syhchronizacji plików można w tym celu wykorzystać formularz HTML dostępny w panelu aplikacji w zakładce *NOWA WERSJA*. Używając tej opcji należy przesłać archiwum zip, pamiętając, że główny katalog archiwum będzie mapowany na główną lokalizację adresu URL aplikacji.

### Udostępnianie produkcyjne

Z chwilą gotowości aplikacji do umieszczenia produkcyjnego (w tym trybie inni użytkownicy są w stanie uzyskać dostęp do aplikacji o ile aplikacja została zarejestrowana w portalu PL-Grid) należy użyć przycisku *WGRAJ NA PRODUKCJĘ* na zakładce *NOWA WERSJA* panelu aplikacji.