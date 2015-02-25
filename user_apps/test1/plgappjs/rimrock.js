/**
 * Rimrock
 */

var Rimrock = function () {
    var rimrockProxy = document.baseURI + 'rimrock';

    var getCSRFToken = function (cb) {
        var success = function (data, status) {
            cb(null, data.csrfToken);
        };
        var error = function (xhr, status, error) {
            cb(new Error(status + ' ' + error));
        };
        $.ajax({
            url: document.baseURI + '/csrf_token',
            success: success,
            error: error
        });
    };

    this.run = function (job) {
        getCSRFToken(function (err, token) {
            if (err) {
                job.onFinished(err);
                return;
            }
            doRequest(token);
        });

        var success = function (data, status) {
            if (job.onFinished != undefined) {
                job.onFinished(null, data);
            }
        };
        var error = function (xhr, status, error) {
            if (job.onFinished != undefined) {
                job.onFinished(new Error(status + ' ' + error));
            }
        };

        var doRequest = function (token) {
            $.ajax({
                url: rimrockProxy + '/process',
                type: 'POST',
                headers: {'X-CSRF-Token': token},
                contentType: 'application/json',
                data: JSON.stringify({
                    host: job.host,
                    command: job.command
                }),
                success: success,
                error: error
            });
        };
    };

    this.jobs = function (cb, tag) {
        var success = function (data, status) {
            cb(null, data)
        };
        var error = function (xhr, status, error) {
            cb(new Error(status + ' ' + error));
        };
        $.ajax({
            url: rimrockProxy + '/jobs' + (tag == undefined ? '' : '?tag=' + tag),
            success: success,
            error: error
        });
    };

    this.job = function (cb, job_id) {
        var success = function (data, status) {
            cb(null, data)
        };
        var error = function (xhr, status, error) {
            cb(new Error(status + ' ' + error));
        };
        $.ajax({
            url: rimrockProxy + '/jobs/' + job_id,
            success: success,
            error: error
        });
    };
};

var rimrock = new Rimrock();