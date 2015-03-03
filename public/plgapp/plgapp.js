/**
 * PlgApp base
 */

var PlgApp = function () {
    var baseLocation = document.baseURI;
    var rimrockJs = 'plgapp/rimrock.js';
    var plgdataJs = 'plgapp/plgdata.js';
    var datanetJs = 'plgapp/datanet.js';
    var signOut = 'sign_out';
    var openIdLogoutFrame = '<iframe src="https://openid.plgrid.pl/logout" style="display:none"></iframe>';
    var csrfToken = null;
    var userLogin = null;

    function appendToBase(path) {
        return baseLocation + path;
    }

    this.rimrockJsUrl = function () {
        return appendToBase(rimrockJs);
    };

    this.plgdataJsUrl = function () {
        return appendToBase(plgdataJs);
    };

    this.datanetJsUrl = function () {
        return appendToBase(datanetJs);
    };

    this.logoutUrl = function () {
        return appendToBase(signOut);
    };

    this.openIdLogoutFrame = function () {
        return openIdLogoutFrame;
    };

    this.getInfo = function (cb) {
        if (csrfToken == null || userLogin == null) {
            var success = function (data, status) {
                userLogin = data.userLogin;
                csrfToken = data.csrfToken;
                cb(null, data.userLogin, data.csrfToken);
            };
            var error = function (xhr, status, error) {
                cb(this.parseError(xhr, status, error));
            };
            $.ajax({
                url: document.baseURI + '/info',
                success: success,
                error: error
            });
        } else {
            cb(null, userLogin, csrfToken);
        }
    };


    //utilities -> to be moved to prototype
    this.parseError = function (xhr, status, error) {
        var data = xhr.responseText;
        try {
            data = JSON.parse(data);
        } catch (err) {
        }
        return new AppError(status + ' ' + xhr.status + ' ' + error, data);
    };
};

//AppError extends Error with optional 'data' field

var AppError = function (message, data) {
    this.name = 'AppError';
    this.message = message || 'Unknown Error';
    this.data = data;
};

var appError_toString = function () {
    var err_txt = Error.prototype.toString.call(this);
    try {
        err_txt += '\n' + JSON.stringify(this.data);
    } catch (err) {
    }
    return err_txt;
};

AppError.prototype = Object.create(Error.prototype);
AppError.prototype.constructor = AppError;
AppError.prototype.toString = appError_toString;

var plgapp = new PlgApp();