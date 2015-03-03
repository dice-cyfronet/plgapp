/**
 * PLGData
 */

var PLGData = function () {
    var plgdataProxy = document.baseURI + 'plgdata';
    var downloadURL = plgdataProxy + '/download';

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

    this.generateUrl = function (cb, path) {
        plgapp.getInfo(function (err, login, token) {
            if (err) {
                cb(err);
                return;
            }
            if (path.length > 1 && path.charAt(0) == '/') {
                cb(null, downloadURL + path);
            } else {
                if (path.length > 1 && path.slice(0, 2) == '~/') {
                    path = path.slice(2);
                }
                cb(null, downloadURL + getHome(login) + path);
            }
        });
    };

    this.mkdir = function (cb, relativePath) {
        plgapp.getInfo(function (err, login, token) {
            if (err) {
                cb(err);
                return;
            }
            doRequest(login, token);
        });

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

        var doRequest = function (userLogin, token) {
            $.ajax({
                url: plgdataProxy + '/mkdir' + getHome(userLogin)
                + relativePath,
                type: 'POST',
                headers: {'X-CSRF-Token': token},
                contentType: 'application/json',
                data: JSON.stringify({recursive: 'true'}),
                success: success,
                error: error
            });
        };
    };
};

var plgdata = new PLGData();