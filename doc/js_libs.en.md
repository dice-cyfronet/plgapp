# JS libraries

JS libraries consist of four components:

 * plgapp API in file *plgapp.js*
 * rimrock API in file *rimrock.js*
 * PLG-Data API in file *plgdata.js*
 * DataNet API in file *datanet.js*

The libraries are available in separate JS files with their proper names. JS libs depend on jQuery,
so it needs to be included in the page. Inclusion of JS libs can be achieved by inserting
the following code in HTML page:

```html
<head>
  <script type="text/javascript" src="/plgapp/jquery/2.1.3/jquery.min.js"></script>
  <script type="text/javascript" src="/plgapp/plgapp.js"></script>
  <script type="text/javascript" src="/plgapp/rimrock.js"></script>
  <script type="text/javascript" src="/plgapp/plgdata.js"></script>
  <script type="text/javascript" src="/plgapp/datanet.js"></script>
</head>
```

## plgapp API

Plgapp API is contained in `plgapp.js` file. Plgapp API supplies
basic functions needed for plgapp application. All callbacks follow the
*errback* principle, that is having `err` object as first
argument. If any error occurs the `err` argument is set, while
other have undefined values.

### Get information about user and his token

Upon completion getInfo calls the supplied callback with `userLogin`
and `csrfToken` as parameters.

```javascript
plgapp.getInfo(function(err, userLogin, csrfToken) {});
```

### Import JavaScript and CSS resources independently of development/production mode

JavaScript and CSS resources edited during development mode on a local computer can be picked up by plgapp by changing URLs in the HTML code
to improve the save-refresh-check development cycle. To be able to switch to production without modifying the source code `importResources`
method can be used:

```
plgapp.importResources(localServerRootUrl, javaScriptResources, cssResources);
```

Let's look at the following example:

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

When viewed in a browser in the development mode an additional `head` section will resolve into:

```
<head>
	...
	<link rel="stylesheet" href="http://localhost/files/css/file.css"/>
    <script type="text/javascript" src="http://localhost/files/js/file.js"></script>
</head>
```

In the production mode, however, the local server address will be omitted thus generating the following:

```
<head>
	...
	<link rel="stylesheet" href="/css/file.css"/>
    <script type="text/javascript" src="/js/file.js"></script>
</head>
```

### Register callback for session expiration

```
    var before_timeout = 60;
    plgapp.registerSessionTimeoutCallback(function(time_left){
        console.log("session will exire in: " + time_left);
    }, before_timeout);
```

`RegisterSessionTimeoutCallback` allows for registration of session expiration
callbacks. User can supply a specified number of seconds, which will be
 subtracted from timeout in order to fire the callback before the actual
 expiration occurs.

### Error class

plgapp js libs use custom error class.

```javascript
class AppError;
```

AppError is based on `Error` class, additionally it contains a `data`
field, which contains information returned by the service.

## rimrock API

rimrock API is contained in `rimrock.js` file. This API allows for
calling functions exposed by Rimrock. All objects supplied to and returned
by rimrock API are compliant with information sent to and received
from Rimrock itself. All information about rimrock services is contained in
[documentation](https://submit.plgrid.pl/processes)

### Run a process

`run` function allows for creating a Rimrock process. Underlying rimrock
service is described [here](https://submit.plgrid.pl/processes).

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



### Run a job

`submitJob` function allows for running a rimrock job. Underlying rimrock
service is described [here](https://submit.plgrid.pl/jobs).

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

The `result` object in submit callback is created based on Rimrock response, just as the `job` object in `onUpdate` callback.

### Register callback

`registerCallback` function allows for registering a function, which is called upon a job state change event.

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

If current job status is not supplied, job state callback will be called upon first state check with new status.
`Job` parameter of job state update callback is a plain job object, extended by `previous_state` field,
which contains, as the name suggests, the previous state.

### Get information about jobs

```javascript
rimrock.jobs(function(err, jobs) { /* handle job info */ }, tag); //tag is optional
```

Upon completion calls the callback with information about jobs. The `jobs` parameter is based on Rimrock response.

### Get information about specific job

```javascript
rimrock.job(function(err, job) { /* handle job information */ }, job_id);
```

Upon completion calls the callback with information about specified job.

### Abort job

```javascript
rimrock.abortJob(function (err) {}, job_id);
```

Aborts a specified job, calls the callback upon completion.

### Delete job

```javascript
rimrock.deleteJob(function (err) {}, job_id);
```

Deletes a specified job, calls the callback upon completion.

## PLG-Data API

PLG-Data API is contained in `plgdata.js` file. This API contains
helper functions used for interacting with plgdata.

### Make directory

```javascript
plgdata.mkdir(function (err) {}, path);
```

Creates a new directory at the supplied path. Callback is called upon completion.

### Generate download path

```javascript
plgdata.generateDownloadPath(function (err, downloadPath) {}, path);
```

Generates download path for a specified path.

### Generate upload path

```javascript
plgdata.generateUploadPath(function (err, uploadPath) {}, path);
```

Generates upload path for a specified path.

## DataNet API

DataNet API is provided with the `datanet.js` file and it allows
to easily use the functionality provided by the DataNet service which
has its documentation [here](https://datanet.plgrid.pl/documentation/manual).
The API follows the principles of fluid API. It is recommended to start a new
chain of method calls for each request. The chaining should always start with
the global object `datanet` and the `repository` method. Remember that all
the methods return a chain factory which allows for subsequent method calls.

`function repository(repositoryName:String)` - sets the name of the repository to be used in the following request,

* `repositoryName` - name of the DataNet repository (the one provided during repository publishing in the DataNet web interface)

`function entity(entityName:String)` - sets the entity name to be used in the following request,

* `entityName` - name of the entity of the DataNet model (case sensitive)

`function id(entityId:String)` - sets the entity entry id to be used in the following request,

* `entityId` - entity entry id

`function field(fieldName:String[, fieldValue:String])` - sets a field name (optionally with a value) to be used in the following request,

* `fieldName` - name of the field frome the DataNet model

`function fields(fieldNames:Array|fieldValues:Object)` - sets field names or field values to be used in the following request,

* `fieldNames` - array of field names frome the DataNet model,
* `fieldValues` - object of field names and values

`function create()` - used to create new entries in the DataNet repository,

`function get()` - used to retrieve entity entries or values from the DataNet repository,

`function update()` - used to update existing entries in the DataNet repository,

`function search(filters:Array)` - used to search entries in the DataNet repository,

* `filters` - a list of DataNet filters (e.g. `name=John` or `surname=/Smith.*/`),

`function delete()` - used to delete entries in the DataNet repository,

`function then(success:Function(data), error:Function(errorMessage))` - terminal method which actually builds and dispatches the DataNet request,

* `success(data)` - a callback method which is called when the DataNet request is successfully processed,
* `error(errorMessage)` - a callback method which is called in case an error occurs during processing a DataNet request or insufficient information
is provided to make the request.

### Examples

The general schema for chaining method calls with the DataNet API id the following:

	datanet.repository(...).entity(...).[id(...)|field(...)|fields(...)|].[create()|get()|update()|search(...)|delete()].then(...);

Let's take a look at a couple of examples of using the API assuming we have a DataNet model consisting of a single entity names `Person` with the following
fields:

	name: String(required),
	surname: String(required),
	age: Integer

##### Creating a new person entry
	datanet.repository('people').entity('Person').field('name', 'John').field('surname', 'Smith').
			create().then(function(data) {var id = data.id;}, function(error) {/*...*/});
	//or with fields() method
	datanet.repository('people').entity('Person').fields({name: 'John', surname: 'Smith'}).
			create().then(function(data) {var id = data.id;}, function(error) {/*...*/});

##### Updating person's age
	datanet.repository('people').entity('Person').id('entryId').field('age', 25).
			update().then(function(data) {/*...*/}, function(error) {/*...*/});

##### Deleting one of the entries
	datanet.repository('people').entity('Person').id('entryId').
			delete().then(function(data) {/*...*/}, function(error) {/*...*/});

##### Retrieving all person entries
	datanet.repository('people').entity('Person').
			get().then(function(data) {/*...*/}, function(error) {/*...*/});

##### Retrieving all person entries with only name fields
	datanet.repository('people').entity('Person').field('name').
			get().then(function(data) {/*...*/}, function(error) {/*...*/});

##### Retrieving a person entry with a given id
	datanet.repository('people').entity('Person').id('entryId').
			get().then(function(data) {/*...*/}, function(error) {/*...*/});

##### Searching for person entries with name matching given regular expression
	datanet.repository('people').entity('Person').
			search(['name=/John,*/']).then(function(data) {/*...*/}, function(error) {/*...*/});