# JS libraries

# PLGApp API

PLGApp API is contained in `plgapp.js` file. PLGApp API supplies
basic functions needed for PLGApp app. All callbacks follow the
*errback* principle, that is having `err` object as first
argument. If any error occurs the `err` argument is set, while
other have undefined values.

## Get logout path

Returns logout path. Handy for constructing *logout* links.

```
plgapp.logoutPath();
```

## Get OpenID logout frame

Returns code used for generating an OpenId logout frame. Used for
logging out of OpenId.

```
plgapp.openIdLogoutFrame();
```
```

## Get information about user and his token

Upon completion getInfo calls the supplied callback with `userLogin`
and `csrfToken` as parameters.

```
plgapp.getInfo(function(err, userLogin, csrfToken) {});
```

## Error class

PLGApp js libs use custom error class.

```
class AppError;
```

AppError is based on `Error` class, additionally it contains a `data`
field, which contains information returned by the service.

# Rimrock API

Rimrock API is contained in `rimrock.js` file. This API allows for
calling functions exposed by Rimrock. All objects supplied to and returned
by Rimrock API are compliant with information sent to and received
from Rimrock itself. All information about Rimrock services is contained in
[documentation](https://submit.plgrid.pl/processes)

## Run a process

`run` function allows for creating a Rimrock process. Underlying rimrock
service is described [here](https://submit.plgrid.pl/processes).

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



## Run a job

`submitJob` function allows for running a Rimrock job. Underlying rimrock
service is described [here](https://submit.plgrid.pl/jobs).

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

The `result` object in submit callback is created based on Rimrock response, just as the `job` object in `onUpdate` callback.

## Get information about jobs

```
rimrock.jobs(function(err, jobs) { /* handle job info */ }, tag); //tag is optional
```

Upon completion calls the callback with information about jobs. The `jobs` parameter is based on Rimrock response.

## Get information about specific job

```
rimrock.job(function(err, job) { /* handle job information */ }, job_id);
```

Upon completion calls the callback with information about specified job.

## Abort job

```
rimrock.abortJob(function (err) {}, job_id);
```

Aborts a specified job, calls the callback upon completion.

## Delete job

```
rimrock.deleteJob(function (err) {}, job_id);
```

Deletes a specified job, calls the callback upon completion.

# PLG-Data API

PLG-Data API is contained in `plgdata.js` file. This API contains
helper functions used for interacting with plgdata.

## Make directory

```
plgdata.mkdir(function (err) {}, path);
```

Creates a new directory at the supplied path. Callback is called upon completion.

## Generate download path

```
plgdata.generateDownloadPath(function (err, downloadPath) {}, path);
```

Generates download path for a specified path.

## Generate upload path

```
plgdata.generateUploadPath(function (err, uploadPath) {}, path);
```

Generates upload path for a specified path.
