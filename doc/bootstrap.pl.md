# Bootstrap

Usługa Plgapp udostępnia wersje popularnej biblioteki Boostrap w wersji 3.3.4.
Jeśli chcesz ją użyc w swojej apliakcji dodaj następujące elementy do swojej
strony html:

```html
<head>
  <!-- Skompilowany oraz zminimalizowany CSS -->
  <link rel="stylesheet" href="/plgapp/bootstrap/3.3.4/css/bootstrap.min.css">

  <!-- Obcjonalny motyw -->
  <link rel="stylesheet" href="/plgapp/bootstrap/3.3.4/css/bootstrap-theme.min.css">

  <!-- Skompilowany oraz zminimalizowany JavaScript -->
  <script src="/plgapp/bootstrap/3.3.4/js/bootstrap.min.js"></script>
</head>
```

## Dlaczego plgapp hostuje swoją wersję biblioteki Boostrap?

Użycie jakich kolwiek bibliotek CSS lub JavaScript pochodzących z zewnętrznych
miejsc (CDN) będzie pierwszym elementem wykrytym przez audyt bezpieczeństwa jako
naruszenie standardów bezpieczeństwa. Dlatego od samego początku staramy się
promować rozwiązania, które są orkeślone jako bezpieczne przez zespół do spraw
bezpieczeństwa.
