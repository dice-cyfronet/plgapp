/**
 * Rimrock
 */

var Rimrock = function () {
    var rimrockProxy = document.baseURI + 'rimrock';

    var extendByFields = function (target, source, fields) {
        $.each(fields, function (idx, field) {
            if (source.hasOwnProperty(field)) {
                target[field] = source[field];
            }
        });
        return target;
    };

    //TODO: user parser error from PlgApp
    var parseError = function (xhr, status, error) {
        var data = xhr.responseText;
        try {
            data = JSON.parse(data);
        } catch (err) {
        }
        return new AppError(status + ' ' + xhr.status + ' ' + error, data);
    };

    // /process

    this.run = function (cb, job) {
        plgapp.getInfo(function (err, login, token) {
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
                cb(parseError(xhr, status, error));
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
        plgapp.getInfo(function (err, login, token) {
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
                cb(parseError(xhr, status, error));
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
            cb(parseError(xhr, status, error));
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
            cb(parseError(xhr, status, error));
        };
        $.ajax({
            url: rimrockProxy + '/jobs/' + job_id,
            success: success,
            error: error
        });
    };

    this.deleteJob = function (cb, job_id) {
        plgapp.getInfo(function (err, login, token) {
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
                cb(parseError(xhr, status, error));
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

    this.abortJob = function (cb, job_id) {
        plgapp.getInfo(function (err, login, token) {
            if (err) {
                cb(err);
                return;
            }
            doRequest(token);
        });

        var success = function (data, status) {
            if (cb != undefined) {
                cb(null);
            }
        };
        var error = function (xhr, status, error) {
            if (cb != undefined) {
                cb(parseError(xhr, status, error));
            }
        };

        var doRequest = function (token) {
            var data = {action: 'abort'};
            $.ajax({
                url: rimrockProxy + '/jobs/' + job_id,
                type: 'PUT',
                headers: {'X-CSRF-Token': token},
                contentType: 'application/json',
                data: JSON.stringify(data),
                success: success,
                error: error
            });
        };
    };
};

var rimrock = new Rimrock();