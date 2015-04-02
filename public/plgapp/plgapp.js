/**
 * PlgApp base
 */

var PlgApp = function () {
    var baseLocation = '/';
    var rimrockJs = 'plgapp/rimrock.js';
    var plgdataJs = 'plgapp/plgdata.js';
    var datanetJs = 'plgapp/datanet.js';
    var signOut = 'sign_out';
    var openIdLogoutFrame = '<iframe src="https://openid.plgrid.pl/logout"' +
        ' style="display:none"></iframe>';
    var csrfToken = null;
    var userLogin = null;

    function appendToBase(path) {
        return baseLocation + path;
    }

    this.rimrockJsPath = function () {
        return appendToBase(rimrockJs);
    };

    this.plgdataJsPath = function () {
        return appendToBase(plgdataJs);
    };

    this.datanetJsPath = function () {
        return appendToBase(datanetJs);
    };

    this.logoutPath = function () {
        return appendToBase(signOut);
    };

    this.openIdLogoutFrame = function () {
        return openIdLogoutFrame;
    };

    this.getInfo = function (cb) {
        if (csrfToken === null || userLogin === null) {
            var success = function (data, status) {
                userLogin = data.userLogin;
                csrfToken = data.csrfToken;
                cb(null, data.userLogin, data.csrfToken);
            };
            var error = function (xhr, status, error) {
                cb(this.parseError(xhr, status, error));
            };
            $.ajax({
                url: baseLocation + 'info',
                success: success,
                error: error
            });
        } else {
            cb(null, userLogin, csrfToken);
        }
    };

    this.importResources = function(developmentRootUrl, javascripts, csses) {
    	$.ajax({
            url: baseLocation + 'info',
            success: function(data) {
            	var url;
            	
            	if(csses !== null) {
	            	for(var i = 0; i < csses.length; i++) {
	            		url = (data.development ? developmentRootUrl : '') +
	            				csses[i];
	            		$('head').append('<link rel="stylesheet" href="' + url +
	            				'"/>');
	            	}
            	}
            	
            	if(javascripts !== null) {
	            	for(var j = 0; j < javascripts.length; j++) {
	            		url = (data.development ? developmentRootUrl : '') +
	            				javascripts[j];
	            		$('head').append('<script type="text/javascript" src="' +
	            				url + '"></script>');
	            	}
            	}
            }
        });
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

var appErrorToString = function () {
    var errTxt = Error.prototype.toString.call(this);
    try {
        errTxt += '\n' + JSON.stringify(this.data);
    } catch (err) {
    }
    return errTxt;
};

AppError.prototype = Object.create(Error.prototype);
AppError.prototype.constructor = AppError;
AppError.prototype.toString = appErrorToString;

var plgapp = new PlgApp();