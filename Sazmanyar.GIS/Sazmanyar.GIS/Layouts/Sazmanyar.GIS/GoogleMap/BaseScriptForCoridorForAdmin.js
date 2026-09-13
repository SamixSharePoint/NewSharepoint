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


var txtSourceStation
var txtDesinationStation
var SourseID = 0;
var SourseLat = 0;
var SourseLng = 0;
var DestinationID = 0;
var DestinationLat = 0;
var DestinationLng = 0;

var objmarker_Sourse = null;
var objmarker_Desination = null;


if (typeof ($) != 'undefined') {
    $(document).ready(function () {
        try {
            map = new google.maps.Map(document.getElementById('map_canvas'), { 'zoom': 11, 'mapTypeId': google.maps.MapTypeId.ROADMAP, 'center': new google.maps.LatLng(35.696111, 51.423056) })
        } catch (e) {
            alert("عدم اتصال به شبکه اینترنت ");
            return
        }

        ren = new google.maps.DirectionsRenderer({ 'draggable': true });
        ren.setMap(map);

        google.maps.event.addListener(ren, 'routeindex_changed',
                    function () {

                        var overview_path = [];


                        for (var i = 0; i < ren.directions.routes[0].overview_path.length; i++) {
                            var point = { lat: ren.directions.routes[0].overview_path[i].lat(), lng: ren.directions.routes[0].overview_path[i].lng() };
                            overview_path.push(point);
                        }

                        str_ren_directions_routes = JSON.stringify(overview_path);
                        strDistance = ren.directions.routes[0].legs[0].distance.text;
                        strDuration = ren.directions.routes[0].legs[0].duration.text;
                        LatNortheast = ren.directions.routes[0].bounds.getNorthEast().lat()
                        LongNortheast = ren.directions.routes[0].bounds.getNorthEast().lng()
                        LatSouthwest = ren.directions.routes[0].bounds.getSouthWest().lat()
                        LongSouthwest = ren.directions.routes[0].bounds.getSouthWest().lng()

                        //ShowCameraForKoridorInfo();
                        //ShowTradodShomarForKoridorInfo();

                    });
    });

}

function isNumber(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
}

// پاسخ سرور به شکل «ID,Lat,Long» است. اگر سرور اعشار را با ویرگول فرستاده باشد
// (ID,34,878,51,108) هم درست جدا می‌کند و مختصات خارج از محدوده را رد می‌کند تا
// سرویس مسیریابی/ژئوکد با مقدار خراب وارد حلقهٔ بی‌پایان نشود.
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

function ShowCameraForKoridorInfo() {

    for (var i = 0; i < Marker_dorbun.length; i++) {
        Marker_dorbun[i].setMap(null);
    }

    Marker_dorbun = [];

    var checkbox = document.getElementById('chbDorbinHa');
    if (checkbox.checked == false) {
        return;
    }

    if (str_ren_directions_routes == '') {
        alert('اطلاعات مسیر در نقشه یافت نشد');
        return;
    }

    var strEnherafMeyar = document.getElementById('txtEnheraf_Mayar_Dorbin').value;
    if (isNumber(strEnherafMeyar) == false) {
        alert('اطلاعات انحراف معیار در دوربین ها عددی نمی باشد');
        return;
    }

    var CoridorRoutPoint = str_ren_directions_routes;
    var EnherafMayar_Mohiti_DarCamera = parseFloat(strEnherafMeyar);

    $.ajax({
        type: 'POST',
        url: strCurrentWebUrl + '/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchingStringData_CameraInfo_forCoridorRoutPoint',
        data: "{'CoridorRoutPoint':'" + CoridorRoutPoint + "' , 'EnherafMayar_Mohiti_DarCamera':" + EnherafMayar_Mohiti_DarCamera + "}",
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (strHtmlOutput) {
            if (strHtmlOutput.d.trim != '') {
                var mapTempPointsTemp = JSON.parse('[' + strHtmlOutput.d + ']');
                for (var i = 0; i < mapTempPointsTemp.length; i++) {
                    Marker_dorbun.push(createDorbinMarker(mapTempPointsTemp[i]));
                }
            }
        },
        error: function (MSG) {
            alert('error' + MSG);
        }
    });
}

function ShowTradodShomarForKoridorInfo() {
    for (var i = 0; i < Marker_TradodShomar.length; i++) {
        Marker_TradodShomar[i].setMap(null);
    }

    Marker_TradodShomar = [];

    var checkbox = document.getElementById('chbTraddodShomarHa');
    if (checkbox.checked == false) {
        return;
    }

    if (str_ren_directions_routes == '') {
        alert('اطلاعات مسیر در نقشه یافت نشد');
        return;
    }

    var strEnherafMeyar = document.getElementById('txtEnheraf_Mayar_Dorbin').value;
    if (isNumber(strEnherafMeyar) == false) {
        alert('اطلاعات انحراف معیار در دوربین ها عددی نمی باشد');
        return;
    }

    var CoridorRoutPoint = str_ren_directions_routes;
    var EnherafMayar_Mohiti_DarTradodShomar = parseFloat(strEnherafMeyar);

    $.ajax({
        type: 'POST',
        url: strCurrentWebUrl + '/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchingStringData_TrradodShomarInfo_forCoridorRoutPoint',
        data: "{'CoridorRoutPoint':'" + CoridorRoutPoint + "' , 'EnherafMayar_Mohiti_DarTradodShomar':" + EnherafMayar_Mohiti_DarTradodShomar + "}",
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (strHtmlOutput) {
            if (strHtmlOutput.d.trim != '') {
                var mapTempPointsTemp = JSON.parse('[' + strHtmlOutput.d + ']');
                for (var i = 0; i < mapTempPointsTemp.length; i++) {
                    Marker_TradodShomar.push(createTradodShomarMarker(mapTempPointsTemp[i]));
                }
            }
        },
        error: function (MSG) {
            alert('error' + MSG);
        }
    });
}

var activeWindow = null;

function createDorbinMarker(objBindings) {
    var point = new google.maps.LatLng(objBindings.Latitude, objBindings.Longitude);
    var objmarker = new google.maps.Marker({ map: map, position: point, icon: strCurrentWebUrl + '/_layouts/15/images/Sazmanyar.GIS/General/PinNotSelected_20.png', title: objBindings.ID });
    var strSnapShotcontent = createSnapShotMarker_strcontent(objBindings);
    google.maps.event.addListener(objmarker, 'mouseover', function () {

        //Close active window if exists
        if (activeWindow != null)
            activeWindow.close();

        objmarker.info.open(map, objmarker);

        //Store new window in global variable
        activeWindow = objmarker.info;

        objmarker.setIcon(strCurrentWebUrl + '/_layouts/15/images/Sazmanyar.GIS/General/PinSelected_20.png');

    });
    objmarker.info = new google.maps.InfoWindow({
        content: strSnapShotcontent
    });
    google.maps.event.addListener(objmarker, 'mouseout', function () {
        objmarker.setIcon(strCurrentWebUrl + '/_layouts/15/images/Sazmanyar.GIS/General/PinNotSelected_20.png');
    });
    return objmarker;
}

function createTradodShomarMarker(objBindings) {
    var point = new google.maps.LatLng(objBindings.Latitude, objBindings.Longitude);
    var objmarker = new google.maps.Marker({ map: map, position: point, icon: strCurrentWebUrl + '/_layouts/15/images/Sazmanyar.GIS/General/TradodShomar.png', title: objBindings.ID });
    var strcontent = createMarker_strcontent(objBindings, false);

    objmarker.info = new google.maps.InfoWindow({
        content: strcontent
    });

    google.maps.event.addListener(objmarker, 'mouseover', function () {

        //Close active window if exists
        if (activeWindow != null)
            activeWindow.close();

        objmarker.info.open(map, objmarker);

        //Store new window in global variable
        activeWindow = objmarker.info;
    });

    return objmarker;
}

function ShowRoutInMap() {

    if (objmarker_Sourse != null) {
        objmarker_Sourse.setMap(null);
    }

    if (objmarker_Desination != null) {
        objmarker_Desination.setMap(null);
    }

    var X = jQuery.noConflict();
    txtSourceStation = document.getElementById('txtSourceStation').value;
    txtDesinationStation = document.getElementById('txtDesinationStation').value;
    var lblResult = document.getElementById('lblResult');
    lblResult.innerHTML = '';
    var bIsFarsi = true;
    var Lang = 1;

    if (txtSourceStation.trim() == '') {
        if (Lang == 1) {
            lblResult.innerHTML = 'ایستگاه مبدا را صحیح وارد نمایید';
        }
        else {
            lblResult.innerHTML = 'Please Enter Source Info';
        }

        lblResult.style.color = "red";
    }
    else if (txtDesinationStation.trim() == '') {
        if (Lang == 1) {
            lblResult.innerHTML = 'ایستگاه مقصد را صحیح وارد نمایید';
        } else {
            lblResult.innerHTML = 'Please Enter Destination Info';
        }
        lblResult.style.color = "red";
    }
    else if (txtSourceStation.trim() == txtDesinationStation.trim()) {
        if (Lang == 1) {
            lblResult.innerHTML = 'ایستگاه مبدا و مقصد یکسان است';
        } else {
            lblResult.innerHTML = 'Source and Destination are the same';
        }
        lblResult.style.color = "red";
    }
    else {

        var bRidirect = false;
        bUseDataBaseRah141 = true;

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



                    objmarker_Sourse = new google.maps.Marker({ map: map, position: new google.maps.LatLng(SourseLat, SourseLng)
                                , icon: { url: strCurrentWebUrl + '/_layouts/15/images/Sazmanyar.GIS/General/GreenPin.png', scaledSize: new google.maps.Size(60, 60) }, title: txtSourceStation
                    });

                    var infowindow_Sourse = new google.maps.InfoWindow({
                        content: ' <div style="padding-top: 20px; padding-right: 10px; padding-left: 10px;">' + txtSourceStation + ' </div>'
                    });

                    infowindow_Sourse.open(map, objmarker_Sourse);


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

                                objmarker_Desination = new google.maps.Marker({ map: map, position: new google.maps.LatLng(DestinationLat, DestinationLng)
                                , icon: { url: strCurrentWebUrl + '/_layouts/15/images/Sazmanyar.GIS/General/RedPin.png', scaledSize: new google.maps.Size(60, 60) }, title: txtDesinationStation
                                });
                                var infowindow_Desination = new google.maps.InfoWindow({
                                    content: ' <div style="padding-top: 20px; padding-right: 10px; padding-left: 10px;">' + txtDesinationStation + ' </div>'
                                });
                                infowindow_Desination.open(map, objmarker_Desination);


                                var ser = new google.maps.DirectionsService();
                                ser.route({ 'origin': new google.maps.LatLng(SourseLat, SourseLng), 'destination': new google.maps.LatLng(DestinationLat, DestinationLng), 'travelMode': google.maps.DirectionsTravelMode.DRIVING }, function (res, sts) {
                                    if (sts == 'OK') {
                                        ren.setDirections(res);
                                        ShowNameCoridorInfo();
                                        return;
                                    }
                                    else {

                                        //دقیق کردن لت و لانگ مسیر مبدا
                                        var geocoder = new google.maps.Geocoder();
                                        geocoder.geocode({ 'address': txtSourceStation }, function (results, status) {

                                            if (status == google.maps.GeocoderStatus.OK) {
                                                var Sourse___Lat = results[0].geometry.location.lat();
                                                var Sourse___Lng = results[0].geometry.location.lng();

                                                ser.route({ 'origin': new google.maps.LatLng(Sourse___Lat, Sourse___Lng), 'destination': new google.maps.LatLng(DestinationLat, DestinationLng), 'travelMode': google.maps.DirectionsTravelMode.DRIVING }, function (res, sts) {
                                                    if (sts == 'OK') {
                                                        ren.setDirections(res);
                                                        ShowNameCoridorInfo();
                                                        return;
                                                    }
                                                    else {
                                                        //دقیق کردن لت و لانگ مسیر مقصد
                                                        geocoder.geocode({ 'address': txtDesinationStation }, function (results, status) {
                                                            if (status == google.maps.GeocoderStatus.OK) {
                                                                var Destination____Lat = results[0].geometry.location.lat();
                                                                var Destination____Lng = results[0].geometry.location.lng();

                                                                ser.route({ 'origin': new google.maps.LatLng(SourseLat, SourseLng), 'destination': new google.maps.LatLng(Destination____Lat, Destination____Lng), 'travelMode': google.maps.DirectionsTravelMode.DRIVING }, function (res, sts) {
                                                                    if (sts == 'OK') {
                                                                        ren.setDirections(res);
                                                                        ShowNameCoridorInfo();
                                                                    }
                                                                    else {
                                                                        ShowDefaltRouteInfo();
                                                                    }
                                                                    return;
                                                                });

                                                            } else {
                                                                ShowDefaltRouteInfo();
                                                            }
                                                        });
                                                    }
                                                });


                                            } else {
                                                //دقیق کردن لت و لانگ مسیر مقصد
                                                geocoder.geocode({ 'address': txtDesinationStation }, function (results, status) {
                                                    if (status == google.maps.GeocoderStatus.OK) {
                                                        var Destination____Lat = results[0].geometry.location.lat();
                                                        var Destination____Lng = results[0].geometry.location.lng();

                                                        ser.route({ 'origin': new google.maps.LatLng(SourseLat, SourseLng), 'destination': new google.maps.LatLng(Destination____Lat, Destination____Lng), 'travelMode': google.maps.DirectionsTravelMode.DRIVING }, function (res, sts) {
                                                            if (sts == 'OK') {
                                                                ren.setDirections(res);
                                                                ShowNameCoridorInfo();
                                                            }
                                                            else {
                                                                ShowDefaltRouteInfo();
                                                            }
                                                            return;
                                                        });

                                                    } else {
                                                        ShowDefaltRouteInfo();
                                                    }
                                                });
                                            }
                                        });

                                    }
                                });
                            }



                        },
                        error: function (MSG) {
                            alert('error' + MSG);
                        }
                    });

                }
            },
            error: function (MSG) {
                alert('error' + MSG);
            }
        });


    }
}

function ShowNameCoridorInfo() {
    var X = jQuery.noConflict();
    var ProgramName = document.getElementById(X('.NameProjeh').attr('ID')).value;
    document.getElementById('txtNameCoridor').value = 'مسیر ' + txtSourceStation + '-' + txtDesinationStation + '[' + ProgramName + ']';

}

function ShowDefaltRouteInfo() {

    alert('مسیری برای این ایستگاه های وارد شده یافت نشد');
    var ser = new google.maps.DirectionsService();
    ser.route({ 'origin': new google.maps.LatLng(35.696111, 51.423056), 'destination': new google.maps.LatLng(32.661343, 51.680374), 'travelMode': google.maps.DirectionsTravelMode.DRIVING }, function (res, sts) {

        if (sts == 'OK') {
            ren.setDirections(res);
            map.setZoom(4);
            map.setCenter(new google.maps.LatLng(35.696111, 51.423056));
            ShowNameCoridorInfo();
            return;
        }

    });
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
        error: function (MSG) {
            alert('error' + MSG);
        }
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
        error: function (MSG) {
            alert('error' + MSG);
        }
    });
}

function FillSugestion_NameStationFromAllStations(objtxtCustomn) {
    if (objtxtCustomn.value.length < 1) {
        return;
    }
    var X = jQuery.noConflict();

    var bUseDataBaseRah141 = true;
    var bIsFarsi = true;

    X.ajax({
        type: "POST",
        url: strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FillSugestion_NameStationFromAllStations",
        data: "{'strStationInfo':'" + objtxtCustomn.value + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (strHtmlOutput) {
            if (strHtmlOutput.d.trim != '') {
                var availableTags = strHtmlOutput.d.split("*")
                X("#" + objtxtCustomn.getAttribute("ID")).autocomplete({ minLength: 1,
                    source: availableTags
                });
            }
        },
        error: function (MSG) {
            alert('error' + MSG);
        }
    });
}


function FillSugestion_NameCorridor(objtxtCustomn) {
    if (objtxtCustomn.value.length < 1) {
        return;
    }
    var X = jQuery.noConflict();

    var bUseDataBaseRah141 = true;
    var bIsFarsi = true;

    X.ajax({
        type: "POST",
        url: strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FillSugestion_NameCorridor",
        data: "{'str_NameCorridor':'" + objtxtCustomn.value + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (strHtmlOutput) {
            if (strHtmlOutput.d.trim != '') {
                var availableTags = strHtmlOutput.d.split("*")
                X("#" + objtxtCustomn.getAttribute("ID")).autocomplete({ minLength: 1,
                    source: availableTags
                });
            }
        },
        error: function (MSG) {
            alert('error' + MSG);
        }
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