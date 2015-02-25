/**
 * PlgApp base
 */

var PlgApp = function () {
    var baseLocation = document.baseURI;
    var rimrockJs = 'plgappjs/rimrock.js';
    var plgdataJs = 'plgappjs/plgdata.js';
    var datanetJs = 'plgappjs/datanet.js';
    var signOut = 'sign_out';
    var openIdLogoutFrame = '<iframe src="https://openid.plgrid.pl/logout" style="display:none"></iframe>';

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
};

var plgapp = new PlgApp();