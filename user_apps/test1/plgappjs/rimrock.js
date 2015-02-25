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

    var extendByFields = function (target, source, fields) {
        $.each(fields, function (idx, field) {
            if (source.hasOwnProperty(field)) {
                target[field] = source[field];
            }
        });
        return target;
    };

    // /process

    this.run = function (cb, job) {
        getCSRFToken(function (err, token) {
            if (err) {
                cb(err);
                return;
            }
            doRequest(token);
        });

        var success = function (data, status) {
            if (cb != undefined) {
                cb(null, data);
            }
        };
        var error = function (xhr, status, error) {
            if (cb != undefined) {
                cb(new Error(status + ' ' + error));
            }
        };

        var doRequest = function (token) {
            var data = extendByFields({}, job, ['host', 'command']);
            $.ajax({
                url: rimrockProxy + '/process',
                type: 'POST',
                headers: {'X-CSRF-Token': token},
                contentType: 'application/json',
                data: JSON.stringify(data),
                success: success,
                error: error
            });
        };
    };

    // /jobs

    this.submitJob = function (cb, job) {
        getCSRFToken(function (err, token) {
            if (err) {
                cb(err);
                return;
            }
            doRequest(token);
        });

        var success = function (data, status) {
            if (cb != undefined) {
                cb(null, data);
            }
        };
        var error = function (xhr, status, error) {
            if (cb != undefined) {
                cb(new Error(status + ' ' + error));
            }
        };

        var doRequest = function (token) {
            var data = extendByFields({}, job, ['host', 'script', 'working_directory', 'tag']);
            $.ajax({
                url: rimrockProxy + '/jobs',
                type: 'POST',
                headers: {'X-CSRF-Token': token},
                contentType: 'application/json',
                data: JSON.stringify(data),
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

    this.deleteJob = function (cb, job_id) {
        getCSRFToken(function (err, token) {
            if (err) {
                cb(err);
                return;
            }
            doRequest(token);
        });

        var success = function (data, status) {
            if (cb != undefined) {
                cb(null, data);
            }
        };
        var error = function (xhr, status, error) {
            if (cb != undefined) {
                cb(new Error(status + ' ' + error));
            }
        };

        var doRequest = function (token) {
            $.ajax({
                url: rimrockProxy + '/jobs/' + job_id,
                type: 'DELETE',
                headers: {'X-CSRF-Token': token},
                success: success,
                error: error
            });
        };
    };
};

var rimrock = new Rimrock();