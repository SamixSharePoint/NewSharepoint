// نسخهء معادل BaseScriptForCoridorForAdmin.js که به‌جای Google Maps JavaScript API
// و Google Directions API (که نیاز به کلید و Billing فعال دارند) از کتابخانهء رایگان
// Leaflet + نقشهء OpenStreetMap برای نمایش نقشه، و از Leaflet Routing Machine با موتور
// مسیریابی رایگان و بدون کلید OSRM (router.project-osrm.org) برای کشیدن مسیر استفاده می‌کند.
//
// فرمت داده‌ای که در پایان تولید و در دیتابیس ذخیره می‌شود (نقاط مسیر، فاصله، مدت،
// محدودهء جغرافیایی) کاملاً هم‌شکل با نسخهء گوگل‌مپ است، پس صفحاتی که مسیرهای ذخیره‌شده
// را بعداً روی نقشه (حتی نقشهء گوگل) نمایش می‌دهند نیازی به تغییر ندارند.

var strCurrentWebUrl = window.location.protocol + "//" + window.location.host + _spPageContextInfo.webServerRelativeUrl;

var Marker_dorbun = [];
var Marker_TradodShomar = [];

var strDistance = '';
var strDuration = '';
var str_ren_directions_routes = '';

var LatNortheast = '';
var LongNortheast = '';
var LatSouthwest = '';
var LongSouthwest = '';

var txtSourceStation;
var txtDesinationStation;
var SourseID = 0;
var SourseLat = 0;
var SourseLng = 0;
var DestinationID = 0;
var DestinationLat = 0;
var DestinationLng = 0;

var objmarker_Sourse = null;
var objmarker_Desination = null;

var map = null;
var routingControl = null;

if (typeof ($) != 'undefined') {
    $(document).ready(function () {
        try {
            map = L.map('map_canvas').setView([35.696111, 51.423056], 11);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
                maxZoom: 19
            }).addTo(map);
        } catch (e) {
            alert("عدم اتصال به شبکه اینترنت ");
            return;
        }

        routingControl = L.Routing.control({
            waypoints: [],
            router: L.Routing.osrmv1({ serviceUrl: 'https://router.project-osrm.org/route/v1' }),
            routeWhileDragging: true,
            addWaypoints: false,
            fitSelectedRoutes: true,
            show: false,
            createMarker: function () {
                // مبدا/مقصد را خودمان با آیکن سبز/قرمز جدا مدیریت می‌کنیم
                return null;
            }
        }).addTo(map);

        routingControl.on('routesfound', function (e) {
            var route = e.routes[0];
            var overview_path = [];
            for (var i = 0; i < route.coordinates.length; i++) {
                overview_path.push({ lat: route.coordinates[i].lat, lng: route.coordinates[i].lng });
            }

            str_ren_directions_routes = JSON.stringify(overview_path);
            strDistance = formatDistance(route.summary.totalDistance);
            strDuration = formatDuration(route.summary.totalTime);

            var bounds = L.latLngBounds(route.coordinates);
            LatNortheast = bounds.getNorthEast().lat;
            LongNortheast = bounds.getNorthEast().lng;
            LatSouthwest = bounds.getSouthWest().lat;
            LongSouthwest = bounds.getSouthWest().lng;
        });

        routingControl.on('routingerror', function () {
            if (typeof (window.__onRoutingError) == 'function') {
                var handler = window.__onRoutingError;
                window.__onRoutingError = null;
                handler();
            }
        });
    });
}

function showAjaxError(MSG) {
    var strMessage = 'ارتباط با سرور برقرار نشد';
    if (MSG && MSG.statusText) {
        strMessage = MSG.statusText;
    }
    alert('خطا: ' + strMessage);
}

function formatDistance(meters) {
    if (meters >= 1000) {
        return (meters / 1000).toFixed(1) + ' km';
    }
    return Math.round(meters) + ' m';
}

function formatDuration(seconds) {
    var mins = Math.round(seconds / 60);
    if (mins >= 60) {
        var hours = Math.floor(mins / 60);
        var remMins = mins % 60;
        return hours + ' h' + (remMins > 0 ? ' ' + remMins + ' min' : '');
    }
    return mins + ' min';
}

function isNumber(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
}

// پاسخ سرور به شکل «ID,Lat,Long» است. اگر سرور اعشار را با ویرگول فرستاده باشد
// (ID,34,878,51,108) هم درست جدا می‌کند و مختصات خارج از محدوده را رد می‌کند تا
// موتور مسیریابی با مقدار خراب وارد حلقهٔ بی‌پایان نشود.
function gisParseStationInfo(str) {
    if (!str) { return null; }
    var p = String(str).split(',');
    var id, lat, lng;
    if (p.length == 3) { id = p[0]; lat = p[1]; lng = p[2]; }
    else if (p.length == 5) { id = p[0]; lat = p[1] + '.' + p[2]; lng = p[3] + '.' + p[4]; }
    else { return null; }
    lat = parseFloat(String(lat).replace('/', '.'));
    lng = parseFloat(String(lng).replace('/', '.'));
    if (!isFinite(lat) || !isFinite(lng) || Math.abs(lat) > 90 || Math.abs(lng) > 180) { return null; }
    return { id: id, lat: lat, lng: lng };
}

// مسیر بین دو نقطه را از OSRM می‌خواهد. اگر مسیریابی شکست بخورد onError صدا زده می‌شود.
function setRouteWaypoints(originLat, originLng, destLat, destLng, onError) {
    window.__onRoutingError = onError || null;
    routingControl.setWaypoints([
        L.latLng(originLat, originLng),
        L.latLng(destLat, destLng)
    ]);
}

// معادل رایگان ژئوکد کردن نام ایستگاه (بدون کلید) با استفاده از Nominatim (OpenStreetMap)
function geocodeStationName(strName, callback) {
    var X = jQuery.noConflict();
    X.ajax({
        type: 'GET',
        url: 'https://nominatim.openstreetmap.org/search?format=json&limit=1&q=' + encodeURIComponent(strName),
        dataType: 'json',
        success: function (results) {
            if (results && results.length > 0) {
                callback(parseFloat(results[0].lat), parseFloat(results[0].lon));
            } else {
                callback(null, null);
            }
        },
        error: function () {
            callback(null, null);
        }
    });
}

function ShowRoutInMap() {

    if (objmarker_Sourse != null) {
        map.removeLayer(objmarker_Sourse);
        objmarker_Sourse = null;
    }

    if (objmarker_Desination != null) {
        map.removeLayer(objmarker_Desination);
        objmarker_Desination = null;
    }

    var X = jQuery.noConflict();
    txtSourceStation = document.getElementById('txtSourceStation').value;
    txtDesinationStation = document.getElementById('txtDesinationStation').value;
    var lblResult = document.getElementById('lblResult');
    lblResult.innerHTML = '';

    if (txtSourceStation.trim() == '') {
        lblResult.innerHTML = 'ایستگاه مبدا را صحیح وارد نمایید';
        lblResult.style.color = "red";
    }
    else if (txtDesinationStation.trim() == '') {
        lblResult.innerHTML = 'ایستگاه مقصد را صحیح وارد نمایید';
        lblResult.style.color = "red";
    }
    else if (txtSourceStation.trim() == txtDesinationStation.trim()) {
        lblResult.innerHTML = 'ایستگاه مبدا و مقصد یکسان است';
        lblResult.style.color = "red";
    }
    else {

        X.ajax({
            type: "POST",
            url: strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchStationIDCamaLatCamaLong",
            data: "{'strStationInfo':'" + txtSourceStation + "'}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (strHtmlOutput) {
                if (strHtmlOutput.d.trim != '') {
                    var sourceInfo = gisParseStationInfo(strHtmlOutput.d);
                    if (sourceInfo == null) {
                        lblResult.innerHTML = 'نام ایستگاه اول [' + txtSourceStation + '] در لیست ایستگاه ها یافت نشد یا مختصات آن نامعتبر است';
                        lblResult.style.color = "red";
                        return;
                    }

                    SourseID = sourceInfo.id;
                    SourseLat = sourceInfo.lat;
                    SourseLng = sourceInfo.lng;

                    var greenIcon = L.icon({
                        iconUrl: strCurrentWebUrl + '/_layouts/15/images/Sazmanyar.GIS/General/GreenPin.png',
                        iconSize: [60, 60], iconAnchor: [30, 60], popupAnchor: [0, -60]
                    });
                    objmarker_Sourse = L.marker([SourseLat, SourseLng], { icon: greenIcon }).addTo(map)
                        .bindPopup(txtSourceStation).openPopup();

                    X.ajax({
                        type: "POST",
                        url: strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchStationIDCamaLatCamaLong",
                        data: "{'strStationInfo':'" + txtDesinationStation + "'}",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (strHtmlOutput) {
                            if (strHtmlOutput.d.trim != '') {
                                var destinationInfo = gisParseStationInfo(strHtmlOutput.d);
                                if (destinationInfo == null) {
                                    lblResult.innerHTML = 'نام ایستگاه دوم [' + txtDesinationStation + '] در لیست ایستگاه ها یافت نشد یا مختصات آن نامعتبر است';
                                    lblResult.style.color = "red";
                                    return;
                                }

                                DestinationID = destinationInfo.id;
                                DestinationLat = destinationInfo.lat;
                                DestinationLng = destinationInfo.lng;

                                var redIcon = L.icon({
                                    iconUrl: strCurrentWebUrl + '/_layouts/15/images/Sazmanyar.GIS/General/RedPin.png',
                                    iconSize: [60, 60], iconAnchor: [30, 60], popupAnchor: [0, -60]
                                });
                                objmarker_Desination = L.marker([DestinationLat, DestinationLng], { icon: redIcon }).addTo(map)
                                    .bindPopup(txtDesinationStation).openPopup();

                                routingControl.once('routesfound', function () {
                                    ShowNameCoridorInfo();
                                });

                                // اول با مختصات خام ایستگاه‌ها امتحان می‌کنیم؛ اگر OSRM نتوانست
                                // مسیری پیدا کند، نام ایستگاه‌ها را با Nominatim ژئوکد می‌کنیم
                                // (دقیقاً معادل همان fallback ای که نسخهء گوگل‌مپ داشت)
                                setRouteWaypoints(SourseLat, SourseLng, DestinationLat, DestinationLng, function () {
                                    GeocodeAndRetry_Source();
                                });
                            }
                        },
                        error: showAjaxError
                    });

                }
            },
            error: showAjaxError
        });

    }
}

function GeocodeAndRetry_Source() {
    geocodeStationName(txtSourceStation, function (lat, lng) {
        if (lat != null) {
            routingControl.once('routesfound', function () { ShowNameCoridorInfo(); });
            setRouteWaypoints(lat, lng, DestinationLat, DestinationLng, function () {
                GeocodeAndRetry_Destination(SourseLat, SourseLng);
            });
        } else {
            GeocodeAndRetry_Destination(SourseLat, SourseLng);
        }
    });
}

function GeocodeAndRetry_Destination(originLat, originLng) {
    geocodeStationName(txtDesinationStation, function (lat, lng) {
        if (lat != null) {
            routingControl.once('routesfound', function () { ShowNameCoridorInfo(); });
            setRouteWaypoints(originLat, originLng, lat, lng, function () {
                ShowDefaltRouteInfo();
            });
        } else {
            ShowDefaltRouteInfo();
        }
    });
}

function ShowNameCoridorInfo() {
    var X = jQuery.noConflict();
    var ProgramName = document.getElementById(X('.NameProjeh').attr('ID')).value;
    document.getElementById('txtNameCoridor').value = 'مسیر ' + txtSourceStation + '-' + txtDesinationStation + '[' + ProgramName + ']';

}

function ShowDefaltRouteInfo() {

    alert('مسیری برای این ایستگاه های وارد شده یافت نشد');

    routingControl.once('routesfound', function () {
        map.setZoom(4);
        map.setView([35.696111, 51.423056]);
        ShowNameCoridorInfo();
    });

    setRouteWaypoints(35.696111, 51.423056, 32.661343, 51.680374, null);
}

function LoadCoridorDataFromDataBase() {

    var X = jQuery.noConflict();

    var txtNameCoridor = document.getElementById('txtNameCoridor').value;
    if (txtNameCoridor == '') {
        alert('اطلاعات نام مسیر را وارد نمایید');
        return;
    }

    X.ajax({
        type: "POST",
        url: strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchAllCoridorInfoFromDataBase",
        data: "{'str_NameCorridor':'" + txtNameCoridor + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (strHtmlOutput) {
            if (strHtmlOutput.d.toString() != '') {
                var AResult = strHtmlOutput.d;

                document.getElementById('txtSourceStation').value = AResult.StationFrom;
                document.getElementById('txtDesinationStation').value = AResult.StationTo;

            }
        },
        error: showAjaxError
    });

}

function SubmitRoutInMap() {

    var X = jQuery.noConflict();

    var txtNameCoridor = document.getElementById('txtNameCoridor').value;
    if (txtNameCoridor == '') {
        alert('اطلاعات نام مسیر را وارد نمایید');
        return;
    }

    var ProgramName = document.getElementById(X('.NameProjeh').attr('ID')).value;
    if (ProgramName == '') {
        alert('نام پروژه را وارد نمایید');
        return;
    }

    if (str_ren_directions_routes == '') {
        alert('اطلاعات مسیر در نقشه یافت نشد');
        return;
    }

    var strCamaSeperatedDorbinhaIDS = '';
    for (var i = 0; i < Marker_dorbun.length; i++) {

        if (strCamaSeperatedDorbinhaIDS != '') {
            strCamaSeperatedDorbinhaIDS = strCamaSeperatedDorbinhaIDS + ','
        }
        strCamaSeperatedDorbinhaIDS = strCamaSeperatedDorbinhaIDS + Marker_dorbun[i].title;
    }

    var strCamaSeperatedTradodShomarhaIDS = '';
    for (var i = 0; i < Marker_TradodShomar.length; i++) {

        if (strCamaSeperatedTradodShomarhaIDS != '') {
            strCamaSeperatedTradodShomarhaIDS = strCamaSeperatedTradodShomarhaIDS + ','
        }
        strCamaSeperatedTradodShomarhaIDS = strCamaSeperatedTradodShomarhaIDS + Marker_TradodShomar[i].title;
    }

    X.ajax({
        type: "POST",
        url: strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/InsertCoridorInDatabase",
        data: "{'strNameCoridor':'" + txtNameCoridor + "' , 'strDistance':'" + strDistance + "' ,  'strDuration':'" + strDuration + "' , 'nSourse_ID':" + SourseID + " ,'nDestination_ID':" + DestinationID + " ,'ProgramName':'" + ProgramName + "' , 'strRoutesInfo':'" + str_ren_directions_routes + "' , 'LatNortheast':'" + LatNortheast + "', 'LongNortheast':'" + LongNortheast + "', 'LatSouthwest':'" + LatSouthwest + "', 'LongSouthwest':'" + LongSouthwest + "', 'strCamaSeperatedDorbinhaIDS':'" + strCamaSeperatedDorbinhaIDS + "', 'strCamaSeperatedTradodShomarhaIDS':'" + strCamaSeperatedTradodShomarhaIDS + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (strHtmlOutput) {
            if (strHtmlOutput.d.toString() != '') {
                alert(strHtmlOutput.d.toString());
            } else {
                alert('عملیات با مشکل مواجه شده است');
            }
        },
        error: showAjaxError
    });
}

function FillSugestion_NameStationFromAllStations(objtxtCustomn) {
    if (objtxtCustomn.value.length < 1) {
        return;
    }
    var X = jQuery.noConflict();

    X.ajax({
        type: "POST",
        url: strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FillSugestion_NameStationFromAllStations",
        data: "{'strStationInfo':'" + objtxtCustomn.value + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (strHtmlOutput) {
            if (strHtmlOutput.d.trim != '') {
                var availableTags = strHtmlOutput.d.split("*")
                X("#" + objtxtCustomn.getAttribute("ID")).autocomplete({
                    minLength: 1,
                    source: availableTags
                });
            }
        },
        error: showAjaxError
    });
}


function FillSugestion_NameCorridor(objtxtCustomn) {
    if (objtxtCustomn.value.length < 1) {
        return;
    }
    var X = jQuery.noConflict();

    X.ajax({
        type: "POST",
        url: strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FillSugestion_NameCorridor",
        data: "{'str_NameCorridor':'" + objtxtCustomn.value + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (strHtmlOutput) {
            if (strHtmlOutput.d.trim != '') {
                var availableTags = strHtmlOutput.d.split("*")
                X("#" + objtxtCustomn.getAttribute("ID")).autocomplete({
                    minLength: 1,
                    source: availableTags
                });
            }
        },
        error: showAjaxError
    });
}


function checkNetConnection() {
    try {
        var xhr = new XMLHttpRequest();
        var file = "http://www.Sazmanyar.org/SazmanyarTheme/Images/LogoIcon-inner.png";
        var r = Math.round(Math.random() * 10000);
        xhr.open('HEAD', file + "?subins=" + r, false);
        try {
            xhr.send();
            if (xhr.status >= 200 && xhr.status < 304) {
                return true;
            } else {
                return false;
            }
        } catch (e) {
            return false;
        }
    } catch (e) {
        return false;
    }


}
