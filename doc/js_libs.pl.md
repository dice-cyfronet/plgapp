# Biblioteki JS

Biblioteki JS składają się z trzech komponentów:

 * plgapp API w pliku *plgapp.js*
 * rimrock API w pliku *rimrock.js*
 * PLG-Data API w pliku *plgdata.js*

Biblioteki te są dostępne jako oddzielne pliki JS. Wszystkie biblioteki zależą od jQuery, które powinno
być uwzględnione w stronie. Dołączenie bibliotek JS najłatwiej osiągnąć w prezentowany poniżej sposób.

```html
<head>
  <script type="text/javascript" src="/plgapp/jquery/2.1.3/jquery.min.js"></script>
  <script type="text/javascript" src="/plgapp/plgapp.js"></script>
  <script type="text/javascript" src="/plgapp/rimrock.js"></script>
  <script type="text/javascript" src="/plgapp/plgdata.js"></script>
</head>
```

## plgapp API

plgapp API zostało zawarte w pliku `plgapp.js`. PLGApp API dostarcza
podstawowych funkcji potrzebnych dla aplikacji PLGApp. Wszystkie
callbacki używają konwencji *errback*, czyli posiadają obiekt `err`
jako pierwszy argument. W przypadku wystąpienia błędu argument `err`
zostanie ustawiony, a pozostałe argumenty pozostaną niezdefiniowane.

### Pobież login i token użytkownika

Funkcja służąca do pobrania informacji o loginie i tokenie użytkownika.
Po wykonaniu operacji wywoływana jest funkcja `callback`
z odpowiednimi parametrami.

```javascript
plgapp.getInfo(function(err, userLogin, csrfToken) {});
```

### Import JavaScript and CSS resources independently of development/production mode

Pliki JavaScript oraz CSS edytowane podczas tworzenia aplikacji mogą zostać użyte przez platformę plgapp poprzez odpowiednią zmianę adresów
w kodzie HTML w celu przyspieszenia cyklu zapisz-odśwież-sprawdź. Aby móc wygodnie przełączać się pomiędzy trybami produkcyjnym i tworzenia
aplikacji bez dodatkowych zmian w kodzie można wykorzystać metodę `importResources`:

```
plgapp.importResources(localServerRootUrl, javaScriptResources, cssResources);
```

Posłóżmy się następującym przykładem:

```
<!doctype html>
<html>
    <head>
        <script type="text/javascript" src="/plgapp/jquery/2.1.3/jquery.min.js"></script>
        <script type="text/javascript" src="/plgapp/plgapp.js"></script>
        <script type="text/javascript">
        	plgapp.importResources('http://localhost/files', ['/js/file.js'], ['/css/file.css']);
        </script>
    </head>
    <body></body>
</html>
```

Kiedy strona będzie wyświetlana w przeglądarce w trybie tworzenia aplikacji zostanie dodana dodatkowa sekcja nagłówka:

```
<head>
	...
	<link rel="stylesheet" href="http://localhost/files/css/file.css"/>
    <script type="text/javascript" src="http://localhost/files/js/file.js"></script>
</head>
```

W trybie produkcyjnym adres lokalnego serwera będzie pominięty a końcowa treść w nagłówku będzie następująca: 

```
<head>
	...
	<link rel="stylesheet" href="/css/file.css"/>
    <script type="text/javascript" src="/js/file.js"></script>
</head>
```

### Typ błędu

Biblioteki PLGApp używają własnego typu błędu, w każdej sytuacji gdzie
zwracany jest błąd.

```javascript
class AppError;
```
AppError bazuje na typie `Error`, dodając pole `data` zawierające
informacje zwracane przez daną usługę.

## rimrock API

rimrock API zostało zawarte w pliku `rimrock.js`. API zawiera funkcje
służące do korzystania z usług Rimrocka.
Wszystkie obiekty zwracane przez funkcje i podawane jako argumenty w callbackach
są zgodne z informacjami zwracanymi przez rimrocka. Informacje zwracane
przez rimrocka zostały opisane na stronie [z dokumentacją](https://submit.plgrid.pl/processes).

### Uruchom proces

Funkcja `run` pozwala na uruchomienie procesu, wywoływana funkcja
Rimrocka została opisana w [dokumentacji](https://submit.plgrid.pl/processes).

```javascript
rimrock.run(function (err, result) {
  //submit callback
  if(err) {
      //handle errors
      return;
  }
  //handle result
}, {
  //options object
  host: 'zeus.cyfronet.pl', //example hostname
  command: 'uname -a' //example command
});
```

### Uruchom zadanie

Funkcja `submitJob` pozwala na uruchomienie zadania, wywoływana funkcja
Rimrocka została opisana w [dokumentacji](https://submit.plgrid.pl/jobs).

```javascript
rimrock.submitJob(function (err, result) {
  //submit callback
  if (err) {
      //handle errors
      return;
  }
}, {
  //options object
  host: 'zeus.cyfronet.pl', //example host
  working_directory: '/mnt/auto/people/plglogin/test', //optional, work dir
  script: '#!/bin/bash\necho hello\nexit 0', //example script to run as a pbs job
  tag: 'mytag', //optional tag parameter
  onUpdate: function (err, job) {
    if (err) {
        console.log(err);
    }
    //handle job status updates
    //job contains all fields returned by rimrock, with additional "previous_status" field containing previous status
  }
}); //submit job to queue system, result is similar to one described here: https://submit.plgrid.pl/jobs, onUpdate function is called every time when job status is updated by batch system
```

Obiekt `result` w callbacku jest tworzony na podstawie odpowiedzi z Rimrocka, tak samo jak obiekt `job` w `onUpdate`
callback.

### Zarejestruj callback reagujący na zmianę stanu zadania

Funkcja `registerCallback` pozwala na zarejestrowanie callbacku, który jest wywoływany w przypadku zmiany stanu zadania.

```
rimrock.registerCallback(function (err) {
            //registration callback
            console.log('registered a callback!');
        },
        job_id,
        function (err, job) {
            //job state update callback
            console.log("job state was updated!");
        },
        current_job_status //optional
        );
```

Jeżeli aktualny stan zadania (czwarty argument) nie zostanie podany, to stan zadania zostanie zaktualizowany przy
pierwszym sprawdzeniu i zostanie wywoływany callback aktualizacji stanu zadania. Parametr `job` callbacku aktualizacji
stanu zadania jest zwykłym obiektem reprezentującym zadanie rozszerzonym o pole `previous_state`, które zawiera
poprzedni stan zadania.

### Pobierz informacje o zadaniach

```javascript
rimrock.jobs(function(err, jobs) { /* handle job info */ }, tag); //tag is optional
```

Po zakończeniu operacji wywoływany jest callback z informacjami o zadaniach. Format informacji o zadaniach
jest zgodny z wiadomością zwracaną przez Rimrocka.

### Pobierz informacje o zadaniu.

```javascript
rimrock.job(function(err, job) { /* handle job information */ }, job_id);
```

Po zakończeniu operacji wywoływany jest callback z informacjami o zadaniu.

### Przerwij zadanie

```javascript
rimrock.abortJob(function (err) {}, job_id);
```

Przerywa zadanie, wywołuje callback po zakończeniu operacji.

### Usuń zadanie

```javascript
rimrock.deleteJob(function (err) {}, job_id);
```

Usuwa zadanie, wywołuje callback po zakończeniu operacji.

## PLG-Data API

PLG-Data API zostało zawarte w pliku `plgdata.js`. Api zawiera funkcje
pomocnicze, używane podczas korzystania z plgdata.

### Stwórz katalog

```javascript
plgdata.mkdir(function (err) {}, path);
```

Tworzy nowy katalog pod wskazaną ścieżką. Po wykonaniu operacji wywoływana
jest funkcja `callback`.

### Wygeneruj ścieżkę ściągania

```javascript
plgdata.generateDownloadPath(function (err, downloadPath) {}, path);
```

Zwraca ścieżkę umożliwiającą ściągnięcie pliku.

### Wygeneruj ścieżkę wysyłania

```javascript
plgdata.generateUploadPath(function (err, uploadPath) {}, path);
```

Zwraca ścieżkę umożliwiającą wysłanie pliku.
