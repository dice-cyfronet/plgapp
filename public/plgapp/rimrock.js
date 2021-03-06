/**
 * Rimrock
 */

var Rimrock = function () {
    var rimrockProxy = '/rimrock';

    var monitoredJobs = {};

    var extendByFields = function (target, source, fields) {
        $.each(fields, function (idx, field) {
            if (source.hasOwnProperty(field)) {
                target[field] = source[field];
            }
        });
        return target;
    };

    //TODO: use parser error from PlgApp
    var parseError = function (xhr, status, error) {
        var data = xhr.responseText;
        try {
            data = JSON.parse(data);
        } catch (err) {
        }
        return new AppError(status + ' ' + xhr.status + ' ' + error, data);
    };

    var addMonitoredJob = function (jobId, status, cbUpdate) {
        if (cbUpdate === undefined) {
            return
        }
        monitoredJobs[jobId] = {
            job_id: jobId,
            status: status,
            cbUpdate: cbUpdate
        };
        if (Object.keys(monitoredJobs).length == 1) {
            //this is the first item in active JobsArray so we need to start
            // job monitor
            setTimeout(monitorJobs, 5000);
        }
    };

    var removeMonitoredJob = function (jobId) {
        delete monitoredJobs[jobId];
    };

    var monitorJobs = function () {
        var delayCheck = function () {
            if (Object.keys(monitoredJobs).length > 0) {
                setTimeout(monitorJobs, 5000);
            }
        };

        //TODO: change rimrock to proper this working with setTimeout
        //get states of all jobs
        rimrock.jobs(function (err, jobArray) {
            if (err) {
                console.log('error while monitoring jobs!');
                console.log(err);
                //still try again later
                delayCheck();
                return;
            }

            //convert job list to object with fields
            var jobs = {};
            for (var i = 0; i < jobArray.length; i++) {
                var j = jobArray[i];
                jobs[j.job_id] = j;
            }

            //loop over monitored jobs, and check for changes
            for (var mJobId in monitoredJobs) {
                if (monitoredJobs.hasOwnProperty(mJobId)) {
                    var mJob = monitoredJobs[mJobId];
                    if (mJobId in jobs) {
                        var job = jobs[mJobId];
                        if (job.status != mJob.status) {
                            if (job.status == 'FINISHED' ||
                                job.status == 'ERROR') {
                                removeMonitoredJob(mJobId);
                            }
                            job.previous_status = mJob.status;
                            mJob.status = job.status;
                            mJob.cbUpdate(null, job);
                        }
                    } else {
                        //monitored job not found in job list
                        mJob.cbUpdate(new AppError(mJobId +
                        ' not found in jobs list'));
                    }

                }
            }

            delayCheck();
        });

    };

    // /process

    this.run = function (cb, job) {
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

        plgapp.getInfo(function (err, login, token) {
            if (err) {
                cb(err);
                return;
            }
            doRequest(token);
        });
    };

    // /jobs

    this.submitJob = function (cb, job) {
        var success = function (data, status) {
            addMonitoredJob(data.job_id, data.status, job.onUpdate);
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
            var data = extendByFields({}, job, ['host', 'script',
                'working_directory', 'tag']);
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

        plgapp.getInfo(function (err, login, token) {
            if (err) {
                cb(err);
                return;
            }
            doRequest(token);
        });
    };

    this.registerCallback = function (cb, jobId, onUpdate, status) {
        addMonitoredJob(jobId, status == undefined ? 'none' : status,
            onUpdate);
        cb(null);
    };

    this.jobs = function (cb, tag) {
        var success = function (data, status) {
            cb(null, data)
        };
        var error = function (xhr, status, error) {
            cb(parseError(xhr, status, error));
        };
        $.ajax({
            url: rimrockProxy + '/jobs' + (tag == undefined ? '' : '?tag=' +
            tag),
            success: success,
            error: error
        });
    };

    this.job = function (cb, jobId) {
        var success = function (data, status) {
            cb(null, data)
        };
        var error = function (xhr, status, error) {
            cb(parseError(xhr, status, error));
        };
        $.ajax({
            url: rimrockProxy + '/jobs/' + jobId,
            success: success,
            error: error
        });
    };

    this.deleteJob = function (cb, jobId) {
        var success = function (data, status) {
            if (cb !== undefined) {
                cb(null, data);
            }
        };
        var error = function (xhr, status, error) {
            if (cb !== undefined) {
                cb(parseError(xhr, status, error));
            }
        };

        var doRequest = function (token) {
            $.ajax({
                url: rimrockProxy + '/jobs/' + jobId,
                type: 'DELETE',
                headers: {'X-CSRF-Token': token},
                success: success,
                error: error
            });
        };

        plgapp.getInfo(function (err, login, token) {
            if (err) {
                cb(err);
                return;
            }
            doRequest(token);
        });
    };

    this.abortJob = function (cb, jobId) {
        var success = function (data, status) {
            if (cb !== undefined) {
                cb(null);
            }
        };
        var error = function (xhr, status, error) {
            if (cb !== undefined) {
                cb(parseError(xhr, status, error));
            }
        };

        var doRequest = function (token) {
            var data = {action: 'abort'};
            $.ajax({
                url: rimrockProxy + '/jobs/' + jobId,
                type: 'PUT',
                headers: {'X-CSRF-Token': token},
                contentType: 'application/json',
                data: JSON.stringify(data),
                success: success,
                error: error
            });
        };

        plgapp.getInfo(function (err, login, token) {
            if (err) {
                cb(err);
                return;
            }
            doRequest(token);
        });
    };
};

var rimrock = new Rimrock();