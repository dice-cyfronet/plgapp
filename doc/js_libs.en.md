# JS libraries

JS libraries consist of three components:

 * plgapp API in file *plgapp.js*
 * rimrock API in file *rimrock.js*
 * PLG-Data API in file *plgdata.js*

The libraries are available in separate JS files with their proper names. JS libs depend on jQuery,
so it needs to be included in the page. Inclusion of JS libs can be achieved by inserting
the following code in HTML page:

```html
<head>
  <script type="text/javascript" src="/plgapp/jquery/2.1.3/jquery.min.js"></script>
  <script type="text/javascript" src="/plgapp/plgapp.js"></script>
  <script type="text/javascript" src="/plgapp/rimrock.js"></script>
  <script type="text/javascript" src="/plgapp/plgdata.js"></script>
</head>
```

## plgapp API

PLGApp API is contained in `plgapp.js` file. PLGApp API supplies
basic functions needed for PLGApp app. All callbacks follow the
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
