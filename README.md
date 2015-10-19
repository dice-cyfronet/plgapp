# PlgApp [![Build Status](https://travis-ci.org/dice-cyfronet/plgapp.svg)](https://travis-ci.org/dice-cyfronet/plgapp) [![Code Climate](https://codeclimate.com/github/dice-cyfronet/plgapp/badges/gpa.svg)](https://codeclimate.com/github/dice-cyfronet/plgapp) [![Test Coverage](https://codeclimate.com/github/dice-cyfronet/plgapp/badges/coverage.svg)](https://codeclimate.com/github/dice-cyfronet/plgapp) [![Dependency Status](https://gemnasium.com/dice-cyfronet/plgapp.svg)](https://gemnasium.com/dice-cyfronet/plgapp)

> Scientific application development made easier

PlgApp is a platform for hosting lightweight web applications using [PL-Grid high performance computing infrastructures](http://www.plgrid.pl/en).

## Dependencies

  * MRI 2.2.x
  * postgresql, libpq-dev
  * ImageMagic or GraphicsMagic

## Installation

Install required gems:

```
bundle
```

Create databases:

```
bin/rake db:create db:migrate db:seed db:test:prepare
```

Make sure that  puma configuration is in place and configured

```
cp config/puma.rb.example config/puma.rb
edit config/puma.rb
```

### Proxy endpoints validation

User app is able to connect into [Rimrock](https://submit.plgrid.pl), [Datanet](https://datanet.plgrid.pl) and [PlgData](https://data.plgrid.pl). To avoid MitM attack we verify these services certificates (signed by [Terena](https://www.terena.org)). To install Terena certificates execute following commands:

```
cd /etc/ssl/certs
sudo wget https://www.terena.org/activities/tcs/repository/AddTrust_External_CA_Root.pem
sudo wget https://www.terena.org/activities/tcs/repository/UTN-USERFirst-Hardware.pem
sudo wget https://www.terena.org/activities/tcs/repository/TERENA_SSL_CA.pem
sudo c_rehash .
```

## Running

Foreman is responsible for starting 2 processes: web serwer and delay jobs serwer (sidekiq).

```
foreman start
```

## Testing

To execute all tests run:

```
bin/rspec
```

Use guard to execute tests connected with modified file:

```
guard
```

To execute karma tests run:

```
bundle exec rake karma:test
```

To run interactive karma test engine (which will retest every time a test or code is changed) run:

```
bundle exec rake karma:run
```

## Contributing

  1. Fork the project
  1. Create your feature branch (git checkout -b my-new-feature)
  1. Commit your changes (git commit -am 'Add some feature')
  1. Push to the branch (git push origin my-new-feature)
  1. Create new pull request
