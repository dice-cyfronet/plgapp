# Biblioteki JS

Biblioteki JS składają się z trzech komponentów:

 * PLGApp API, w pliku: *plgapp.js*
 * Rimrock API, w pliku: *rimrock.js*
 * PLG-Data API, w pliku: *plgdata.js*

biblioteki są dostępne jako oddzielne pliki JS. Wszystkie biblioteki zależą od jQuery, które powinno
być uwzględnione w stronie. Dołączenie bibliotek JS najłatwiej osiągnąć w prezentowany poniżej sposób.

```
<head>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
    <script src="./plgapp/plgapp.js"></script>
    <script src="./plgapp/rimrock.js"></script>
    <script src="./plgapp/plgdata.js"></script>
</head>
```

## PLGApp API

PLGApp API zostało zawarte w pliku `plgapp.js`. PLGApp API dostarcza
podstawowych funkcji potrzebnych dla aplikacji PLGApp. Wszystkie
callbacki używają konwencji *errback*, czyli posiadają obiekt `err`
jako pierwszy argument. W przypadku wystąpienia błędu argument `err`
zostanie ustawiony, a pozostałe argumenty pozostaną niezdefiniowane.

### Pobież login i token użytkownika

Funkcja służąca do pobrania informacji o loginie i tokenie użytkownika.
Po wykonaniu operacji wywoływana jest funkcja `callback`
z odpowiednimi parametrami.

```
plgapp.getInfo(function(err, userLogin, csrfToken) {});
```

### Typ błędu

Biblioteki PLGApp używają własnego typu błędu, w każdej sytuacji gdzie
zwracany jest błąd.

```
class AppError;
```
AppError bazuje na typie `Error`, dodając pole `data` zawierające
informacje zwracane przez daną usługę.

## Rimrock API

Rimrock API zostało zawarte w pliku `rimrock.js`. Api zawiera funkcje
służące do korzystania z usług Rimrocka.
Wszystkie obiekty zwracane przez funkcje i podawane jako argumenty w callbackach
są zgodne z informacjami zwracanymi przez Rimrocka. Informacje zwracane
przez Rimrocka zostały opisane na stronie [z dokumentacją](https://submit.plgrid.pl/processes).

### Uruchom proces

Funkcja `run` pozwala na uruchomienie procesu, wywoływana funkcja
Rimrocka została opisana w [dokumentacji](https://submit.plgrid.pl/processes).

```
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

```
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

### Pobierz informacje o zadaniach

```
rimrock.jobs(function(err, jobs) { /* handle job info */ }, tag); //tag is optional
```

Po zakończeniu operacji wywoływany jest callback z informacjami o zadaniach. Format informacji o zadaniach
jest zgodny z wiadomością zwracaną przez Rimrocka.

### Pobierz informacje o zadaniu.

```
rimrock.job(function(err, job) { /* handle job information */ }, job_id);
```

Po zakończeniu operacji wywoływany jest callback z informacjami o zadaniu.

### Przerwij zadanie

```
rimrock.abortJob(function (err) {}, job_id);
```

Przerywa zadanie, wywołuje callback po zakończeniu operacji.

### Usuń zadanie

```
rimrock.deleteJob(function (err) {}, job_id);
```

Usuwa zadanie, wywołuje callback po zakończeniu operacji.

## PLG-Data API

PLG-Data API zostało zawarte w pliku `plgdata.js`. Api zawiera funkcje
pomocnicze, używane podczas korzystania z plgdata.

### Stwórz katalog

```
plgdata.mkdir(function (err) {}, path);
```

Tworzy nowy katalog pod wskazaną ścieżką. Po wykonaniu operacji wywoływana
jest funkcja `callback`.

### Wygeneruj ścieżkę ściągania

```
plgdata.generateDownloadPath(function (err, downloadPath) {}, path);
```

Zwraca ścieżkę umożliwiającą ściągnięcie pliku.

### Wygeneruj ścieżkę wysyłania

```
plgdata.generateUploadPath(function (err, uploadPath) {}, path);
```

Zwraca ścieżkę umożliwiającą wysłanie pliku.
