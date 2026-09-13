var G_INCOMPAT = false;
function GScript(src) {
    document.write('<' + 'script src="' + src + '"' + ' type="text/javascript"><' + '/script>');
}
function GBrowserIsCompatible() {
    if (G_INCOMPAT) return false;
    return true;
}
function GVerify() {
}
function GApiInit() {
    if (GApiInit.called) return;
    GApiInit.called = true;
    window.GAddMessages && GAddMessages(
    {
        160: '\x3cH1\x3eServer Error\x3c/H1\x3eserver is temporarily errors, may not be able to process your request .\x3cp\x3ePlease retry after a few minutes .\x3c/p\x3e', 1415: '.', 1416: ',', 1547: 'Miles', 1616: 'Km', 4100: 'M', 4101: 'Ft.', 10018: 'Loading...', 10021: 'Enlarge', 10022: 'Narrowing', 10024: 'Drag the Zoom', 10029: 'Return to the previous results', 10049: 'Map', 10050: 'Satellite', 10093: 'Terms of use', 10109: 'M', 10110: 'Ft.', 10111: 'Map', 10112: 'Satellite', 10116: 'Hybrid Map', 10117: 'Hybrid Map', 10120: 'Sorry, not found in this area on this map zoom level .\x3cp\x3e Please zoom out to expand the field of view.\x3c/p\x3e', 10121: 'Sorry, at this zoom level on a satellite image of the region was not found. \x3cp\x3e please reduce the image to expand the field of view.\x3c/p\x3e', 10507: 'Pan left', 10508: 'Pan right', 10509: 'Pan up', 10510: 'Pan down', 10511: 'Show street map', 10512: 'Displays satellite images', 10513: 'Show street names marked with pictures', 10806: 'Click to see this area on Google Maps', 10807: 'Traffic', 10808: 'Show traffic', 10809: 'Hide Traffic', 12150: 'In %2$s%1$sonthere', 12151: 'In%2$sand%3$sintersectionshave%1$ s', 12152: 'There are %1$s between %2%3$s$s on and %4$ s intersection', 10985: 'Enlarge', 10986: 'Narrowing', 11047: 'In this center the map', 11089: '\x3ca href\x3d\x22javascript: void (0); \x22\x3e zoom \x3c/a\x3e can view the traffic flow in the area', 11259: 'Full Screen', 11751: 'Show topographical map', 11752: 'Style：', 11757: 'Change the map style', 11758: 'Terrain', 11759: 'Terrain', 11794: 'Show tags', 11303: 'Street View Help', 11274: 'To use street view , you need to %1$d or an updated version of Adobe Flash Player.', 11382: 'Get the latest version of Flash Player.', 11314: 'Sorry, due to high demand , Street View is temporarily unavailable. \x3cbr \x3e please try again later !', 1559: 'North', 1560: 'South', 1561: 'West', 1562: 'East', 1608: 'Northwest', 1591: 'Northeast', 1605: 'Southwest', 1606: 'Southeast', 11907: 'The picture is no longer available', 10041: 'Help', 12471: 'Current Position', 12492: 'Earth', 0: ''
    }
    );
//    if (!GValidateKey("bbf729686d6d5e089887496d924b9b10b69015dd"))//modify by tangf, and here I have ! removed GValidateKey ago, so to avoid key authentication.
//    {
//        G_INCOMPAT = true;
//        alert("Google Maps API key used on this site is registered to another site. You can generate a new key for the site on the http://code.google.com/apis/maps/.");
//        return;
//    }
}
var GLoad;
(function () {
    var jslinker =
    {
        version: "140", jsbinary: [
        {
            id: "maps2", url: myurl + "/mapfiles/140g/maps2/main.js"
        }
        ,
        {
            id: "maps2.api", url: myurl + "/mapfiles/140g/maps2.api/main.js"
        }
        ,
        {
            id: "gc", url: myurl + "/mapfiles/140g/gc.js"
        }
        ,
        {
            id: "legacy_gc", url: myurl + "/mapfiles/140g/legacy_gc.js"
        }
        ,
        {
            id: "adsense", url: myurl + "/mapfiles/140g/adsense.js"
        }
        ,
        {
            id: "suggest", url: myurl + "/mapfiles/140g/suggest/main.js"
        }
        ]
    };
    GLoad = function (callback) {
        var apiCallback = callback || GLoadApi;
        GApiInit();
        var opts =
    {
        public_api: true, export_legacy_names: true, jsmain: myurl + "/mapfiles/140g/maps2.api/main.js"
    };
        var pageArgs =
    {
    };
        var jsinit = window.GJsLoaderInit;
        jsinit && jsinit(opts.jsmain);
        apiCallback(["http://mt0.google.com/mt/v\x3dap.89\x26hl\x3dzh-CN\x26", "http://mt1.google.com/mt/v\x3dap.89\x26hl\x3dzh-CN\x26", "http://mt2.google.com/mt/v\x3dap.89\x26hl\x3dzh-CN\x26", "http://mt3.google.com/mt/v\x3dap.89\x26hl\x3dzh-CN\x26"], ["http://khm0.google.com/kh/v\x3d36\x26hl\x3dzh-CN\x26", "http://khm1.google.com/kh/v\x3d36\x26hl\x3dzh-CN\x26", "http://khm2.google.com/kh/v\x3d36\x26hl\x3dzh-CN\x26", "http://khm3.google.com/kh/v\x3d36\x26hl\x3dzh-CN\x26"], ["http://mt0.google.com/mt/v\x3dapt.88\x26hl\x3dzh-CN\x26", "http://mt1.google.com/mt/v\x3dapt.88\x26hl\x3dzh-CN\x26", "http://mt2.google.com/mt/v\x3dapt.88\x26hl\x3dzh-CN\x26", "http://mt3.google.com/mt/v\x3dapt.88\x26hl\x3dzh-CN\x26"], "ABQIAAAALnobdtcQBfcYCnVSCwRHOxS79ylobW1eCJiHSW2SS5sQtpAV3RTgS5_aqQLZwCkEn_OAeso4797XXA", "", "", true, "google.maps.", opts, ["http://mt0.google.com/mt/v\x3dapp.87\x26hl\x3dzh-CN\x26", "http://mt1.google.com/mt/v\x3dapp.87\x26hl\x3dzh-CN\x26", "http://mt2.google.com/mt/v\x3dapp.87\x26hl\x3dzh-CN\x26", "http://mt3.google.com/mt/v\x3dapp.87\x26hl\x3dzh-CN\x26"], jslinker, pageArgs);
    }
}
)();
function GUnload() {
    if (window.GUnloadApi) {
        GUnloadApi();
    }
}
var _mIsRtl = false;
var _mF = [, , false, true, true, 100, 4096, "bounds_cippppt.txt", "cities_cippppt.txt", "local/add/flagStreetView", true, true, 400, true, true, , true, , true, "myaddjs/dommanifest.js", , true, true, false, false, true, true, false, true, true, true, , true, true, , true, , true, "http://maps.google.com/maps/stk/fetch", 0, , true, true, , , true, , , , "http://maps.google.com/maps/stk/style", true, "107485602240773805043.00043dadc95ca3874f1fa", , "US,AU,NZ", false, 1000, 42, "http://cbk0.google.com", false, true, "ar,iw", false, true, , true, true, , false, "/maps/complete", "http://pagead2.googlesyndication.com/pagead/imgad?id\x3dCMKp3NaV5_mE1AEQEBgQMgieroCd6vHEKA", false, , false, false, , false, 5000, true, , true, "SS", "en,fr", false, "tbr", "Earth", "SATELLITE_3D_MAP", true, true, true, true, "getEarthInstance", false, true, true, true, true, , true, true, "", "1", true, false, false, true, false, true, 25, "0.25", "AU,BE,FR,NZ,US", true, false, false, true, 500, "http://chart.apis.google.com/chart?cht\x3dqr\x26chs\x3d80x80\x26chld\x3d|0\x26chl\x3d", false, , , true, false, false, , true, false, , false, true, false, false, true, false, false, , , , false, false, true, false, 10, true, true, true, true, true, false, 30, "infowindow_v1", "", false, true, 30, "http://khm.%1$s/maptilecompress?t\x3d1\x26c\x3d10\x26", "http://khm.%1$s/maptilecompress?t\x3d2\x26q\x3d20\x26", "http://khm.%1$s/maptilecompress?t\x3d3\x26q\x3d25\x26", "http://khm.%1$s/maptilecompress?t\x3d6\x26q\x3d30\x26", , true, false, "US,AU,NZ,FR,DK,MX,BE,CA,DE,GB,IE,PR,PT,RU,SG,JM,HK,TW", true, true, "windows-ie,windows-firefox,macos-safari,macos-firefox", true, false, 40000, 900, 30, , false, true, true, , false, false, true, true, "maps.google.com", false, true, true, true, "", true, true, true, true, true, "4:http://gt%1$d.google.com/mt?v\x3dgwm.fresh\x26", "4:http://gt%1$d.google.com/mt?v\x3dgwh.fresh\x26", false, false, false, true, 0.25, true, "107485602240773805043.0004561b22ebdc3750300", true, false, false, "/ig/ifr", false, false, false, true, true, 8, "http://maps.gmodules.com/gadgets/js/rpc.js", false, true, true, false, "https://cbks0.google.com", false, true, false, false, false, false];
var _mHost = "http://maps.google.com";
var _mUri = "/maps";
var _mDomain = "google.com";
var _mStaticPath = myurl + "/mapfiles/";
var _mJavascriptVersion = G_API_VERSION = "140g";
var _mTermsUrl = "http://www.google.com/intl/zh-CN_ALL/help/terms_maps.html";
var _mHL = "zh-CN";
var _mGL = "";
var _mLocalSearchUrl = "http://www.google.com/uds/solutions/localsearch/gmlocalsearch.js";
var _mTrafficEnableApi = true;
var _mTrafficTileServerUrls = ['http://mt0.google.com/mapstt', 'http://mt1.google.com/mapstt', 'http://mt2.google.com/mapstt', 'http://mt3.google.com/mapstt'];
var _mCityblockLatestFlashUrl = "http://maps.google.com/local_url?q=http://www.adobe.com/shockwave/download/download.cgi%3FP1_Prod_Version%3DShockwaveFlash&amp;dq=&amp;file=api&amp;v=2&amp;key=ABQIAAAALnobdtcQBfcYCnVSCwRHOxS79ylobW1eCJiHSW2SS5sQtpAV3RTgS5_aqQLZwCkEn_OAeso4797XXA&amp;s=ANYYN7manSNIV_th6k0SFvGB4jz36is1Gg";
var _mCityblockLogUsage = true;
var _mCityblockFrogLogUsage = false;
var _mCityblockInfowindowLogUsage = false;
var _mCityblockDrivingDirectionsLogUsage = false;
var _mCityblockPrintwindowLogUsage = false;
var _mCityblockPrintwindowImpressionLogUsage = false;
var _mCityblockUseSsl = false;
var _mSavedLocationsLogUsage = true;
var _mAddressBookUrl = "/maps?file\x3dapi\x26v\x3d2\x26key\x3dABQIAAAALnobdtcQBfcYCnVSCwRHOxS79ylobW1eCJiHSW2SS5sQtpAV3RTgS5_aqQLZwCkEn_OAeso4797XXA\x26ie\x3dUTF8\x26hl\x3dzh-CN\x26sidr\x3d1\x26oi\x3dsl_menu_edit";
var _mWizActions =
{
    hyphenSep: 1, breakSep: 2, dir: 3, searchNear: 6, savePlace: 9
};
var _mIGoogleUseXSS = false;
var _mIGoogleEt = "jhfBZQah";
var _mIGoogleServerTrustedUrl = "";
var _mMMEnablePanelTab = true;
var _mIdcRouterPath = "/maps/mpl/router";
var _mIdcRelayPath = "/maps/mpl/relay";
var _mIGoogleServerUntrustedUrl = "http://maps.gmodules.com";
var _mMplGGeoXml = 100;
var _mMplGPoly = 1000;
var _mMplMapViews = 100;
var _mMplGeocoding = 100;
var _mMplDirections = 100;
var _mMplEnableGoogleLinks = true;
var _mMMEnableAddContent = true;
var _mMSEnablePublicView = true;
var _mMSSurveyUrl = "";
var _mSatelliteToken = "fzwq2mlT4xxjhP5aYo2hjbcbxpx76gUe_aa7nA";
var _mMapCopy = "Map data \x26#169;2009";
var _mSatelliteCopy = "Imagery \x26#169;2009";
var _mGoogleCopy = "\x26#169;2009 Google";
var _mPreferMetric = false;
var _mPanelWidth = 23.75;
var _mMapPrintUrl = 'http://www.google.com/mapprint';
var _mSvgEnabled = true;
var _mSvgForced = false;
var _mLogInfoWinExp = true;
var _mLogPanZoomClks = false;
var _mLogWizard = true;
var _mLogLimitExceeded = true;
var _mLogPrefs = true;
var _mMMLogMyMapViewpoints = true;
var _mSXBmwAssistUrl = '';
var _mSXCarEnabled = true;
var _mSXServices =
{
};
var _mSXPhoneEnabled = true;
var _mSXQRCodeEnabled = false;
var _mLyrcItems = [];
var _mAttrInpNumMap =
{
    'One hundred': 100, 'One thousand': 1000, 'One thousand': 1000, 'One million': 1000000, 'One million': 1000000, 'One billion': 1000000000, 'One billion': 1000000000
};
var _mMSMarker = 'Positioning mark';
var _mMSLine = 'Lines';
var _mMSPolygon = 'Graphics';
var _mMSImage = 'Pictures';
var _mDirectionsDragging = true;
var _mDirectionsEnableCityblock = true;
var _mDirectionsEnableApi = true;
var _mAdSenseForMapsEnable = "true";
var _mAdSenseForMapsFeedUrl = "http://pagead2.googlesyndication.com/afmaps/ads";
var _mReviewsWidgetUrl = "/reviews/scripts/annotations_bootstrap.js?hl\x3dzh-CN\x26amp;gl\x3d";
var _mIsLeafEnabled = true;
var _mLearnMoreLogUsage = true;
var _mTumblerLoaderV1Url = _mStaticPath + "ge/v/1/4/loader.js";
var _mUserPreferences = false;
function GLoadMapsScript() {
    if (GBrowserIsCompatible()) {
        GScript(myurl + "/mapfiles/140g/maps2.api/main.js");
    }
}
(function () {
    if (!window.google) window.google =
    {
    };
    if (!window.google.maps) window.google.maps =
    {
    };
    var ns = window.google.maps;
    ns.BrowserIsCompatible = GBrowserIsCompatible;
    ns.Unload = GUnload;
}
)();
GLoadMapsScript();
