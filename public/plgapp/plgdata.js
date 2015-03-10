/**
 * PLGData
 */

var PLGData = function () {
    var plgdataProxy = '/plgdata';
    var downloadPrefix = plgdataProxy + '/download';

    //TODO: use parser error from PlgApp
    var parseError = function (xhr, status, error) {
        var data = xhr.responseText;
        try {
            data = JSON.parse(data);
        } catch (err) {
        }
        return new AppError(status + ' ' + xhr.status + ' ' + error, data);
    };

    var getHome = function (userLogin) {
        return '/people/' + userLogin + '/';
    };

    var expandPath = function (path, login) {
        if (path.length > 0 && path.charAt(0) == '/') {
            return path;
        } else {
            if (path.length > 1 && path.slice(0, 2) == '~/') {
                path = path.slice(2);
            }
            return getHome(login) + path;
        }
    };

    this.generateDownloadPath = function (cb, path) {
        plgapp.getInfo(function (err, login, token) {
            if (err) {
                cb(err);
                return;
            }
            cb(null, downloadPrefix + expandPath(path, login));
        });
    };

    this.mkdir = function (cb, path) {

        var success = function (data, status) {
            if (cb !== undefined) {
                cb(null);
            }
        };
        var error = function (xhr, status, error) {
            if (cb !== undefined) {
                if (xhr.status == 200) {
                    //ignore json parse errors of empty response
                    cb(null);
                } else {
                    cb(parseError(xhr, status, error));
                }
            }
        };

        var doRequest = function (userLogin, token) {
            $.ajax({
                url: plgdataProxy + '/mkdir' + expandPath(path, userLogin),
                type: 'POST',
                headers: {'X-CSRF-Token': token},
                contentType: 'application/json',
                data: JSON.stringify({recursive: 'true'}),
                success: success,
                error: error
            });
        };

        plgapp.getInfo(function (err, login, token) {
            if (err) {
                cb(err);
                return;
            }
            doRequest(login, token);
        });
    };
};

var plgdata = new PLGData();