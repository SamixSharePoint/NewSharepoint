var strCurrentWebUrl = window.location.protocol + "//" + window.location.host + _spPageContextInfo.webServerRelativeUrl;
var Marker_dorbun = [];
var Marker_TradodShomar = [];
var nRoutesIDs = [];

function FillCmbFromStationInfo() {
    var CmbFromStation = document.getElementById('cmbFromStation');
    for (i = 0; i < CmbFromStation.options.length; i++) {
        CmbFromStation.options[i] = null;
    }

    CmbFromStation.innerHTML = "";

    $.ajax({
        type: 'POST',
        url: strCurrentWebUrl + '/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchAllRouts_FromStations',
        data: "{}",
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (strHtmlOutput) {
            if (strHtmlOutput.d.trim != '') {
                var objResult = strHtmlOutput.d;
                for (var i = 0; i < objResult.length; i++) {
                    var opt = document.createElement('option');
                    opt.innerHTML = objResult[i]["Value"];
                    opt.value = objResult[i]["ID"];
                    CmbFromStation.appendChild(opt);
                }
                FillCmbToStationInfo(CmbFromStation);
            }
        },
        error: function (MSG) {
            alert('error' + MSG);
        }
    });

}


function FillCmbToStationInfo(cmbFromStationId) {
    var cmbFromStation = document.getElementById(cmbFromStationId.id);
    var strSelectedFromStation = cmbFromStation.value;
    var cmbToStation = document.getElementById('cmbToStation');

    for (i = 0; i < cmbToStation.options.length; i++) {
        cmbToStation.options[i] = null;
    }

    cmbToStation.innerHTML = "";

    if (strSelectedFromStation.toString().trim().length != 0) {
        $.ajax({
            type: 'POST',
            url: strCurrentWebUrl + '/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchAllCoridor_ToCitesByFromStationInfo',
            data: "{'strFromCitesID':'" + strSelectedFromStation + "' }",
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            success: function (strHtmlOutput) {
                if (strHtmlOutput.d.trim != '') {
                    var objResult = strHtmlOutput.d;
                    for (var i = 0; i < objResult.length; i++) {
                        var opt = document.createElement('option');
                        opt.innerHTML = objResult[i]["Value"];
                        opt.value = objResult[i]["ID"];
                        cmbToStation.appendChild(opt);
                    }
                }
            },
            error: function (MSG) {
                alert('error' + MSG);
            }
        });
    }
}


function ShowCameraForKoridorInfo() {
    map.closeInfoWindow();
    for (var i = 0; i < Marker_dorbun.length; i++) {
        //Marker_dorbun[i].setMap(null);
        map.removeOverlay(Marker_dorbun[i]);
    }

    Marker_dorbun = [];

    var checkbox = document.getElementById('chbDorbinHa');
    if (checkbox.checked == false) {
        return;
    }

    if (nRoutesIDs.length == 0) {
        alert('اطلاعات مسیر در نقشه یافت نشد');
        return;
    }

    for (var i = 0; i < nRoutesIDs.length; i++) {
        var CoridorID = nRoutesIDs[i];
        $.ajax({
            type: 'POST',
            url: strCurrentWebUrl + '/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchingStringData_CameraInfo_forCoridorInDataBase',
            data: "{'nCoridorID':" + CoridorID + "}",
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

}

function ShowTradodShomarForKoridorInfo() {
    map.closeInfoWindow();
    for (var i = 0; i < Marker_TradodShomar.length; i++) {
        //Marker_TradodShomar[i].setMap(null);
        map.removeOverlay(Marker_TradodShomar[i]);
    }

    Marker_TradodShomar = [];

    var checkbox = document.getElementById('chbTraddodShomarHa');
    if (checkbox.checked == false) {
        return;
    }

    if (nRoutesIDs.length == 0) {
        alert('اطلاعات مسیر در نقشه یافت نشد');
        return;
    }

    for (var i = 0; i < nRoutesIDs.length; i++) {
        var CoridorID = nRoutesIDs[i];
        $.ajax({
            type: 'POST',
            url: strCurrentWebUrl + '/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchingStringData_TrradodShomarInfo_forCoridorInDataBase',
            data: "{'nCoridorID':" + CoridorID + "}",
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


}

function createDorbinMarker(objBindings) {
    var point = new GLatLng(objBindings.Latitude, objBindings.Longitude);
    var myIcon = new GIcon();
    myIcon.image = strCurrentWebUrl + '/_layouts/15/images/Sazmanyar.GIS/General/PinNotSelected_20.png';
    myIcon.iconAnchor = new GPoint(10, 10);
    myIcon.infoWindowAnchor = new GPoint(1, 1);
    var objmarker = new GMarker(point, { icon: myIcon, title: objBindings.ID });
    var strSnapShotcontent = createSnapShotMarker_strcontent(objBindings);
    GEvent.addListener(objmarker, 'mouseover', function () {
        objmarker.setImage(strCurrentWebUrl + '/_layouts/15/images/Sazmanyar.GIS/General/PinSelected_20.png');
        var infoWindow = map.getInfoWindow();
        objmarker.openInfoWindowHtml(strSnapShotcontent, { onOpenFn: function () {
            var infoWindow_Size = new GSize(100, 100);
            objmarker.setImage(strCurrentWebUrl + '/_layouts/15/images/Sazmanyar.GIS/General/PinSelected_20.png');
            infoWindow.reset(infoWindow.getPoint(), infoWindow.getTabs(), infoWindow_Size, null, null);
        }
        }
                );
    });
    GEvent.addListener(objmarker, 'mouseout', function () {
        objmarker.setImage(strCurrentWebUrl + '/_layouts/15/images/Sazmanyar.GIS/General/PinNotSelected_20.png');
    });
    map.addOverlay(objmarker);
    Arrayesmarkers.push(objmarker);
    return objmarker;
}


function createTradodShomarMarker(objBindings) {
    var point = new GLatLng(objBindings.Latitude, objBindings.Longitude);
    var myIcon = new GIcon();
    myIcon.image = strCurrentWebUrl + '/_layouts/15/images/Sazmanyar.GIS/General/TradodShomar.png';
    myIcon.iconAnchor = new GPoint(10, 10);
    myIcon.infoWindowAnchor = new GPoint(1, 1);
    var objmarker = new GMarker(point, { icon: myIcon, title: objBindings.ID });
    var strcontent = createMarker_strcontent(objBindings, false);

    GEvent.addListener(objmarker, 'click', function () {
        objmarker.openInfoWindowHtml(strcontent);
    });
    map.addOverlay(objmarker);
    Arrayesmarkers.push(objmarker);
    return objmarker;
}


var txtSourceStation
var txtDesinationStation
var SourseLat = 0;
var SourseLng = 0;
var DestinationLat = 0;
var DestinationLng = 0;

function ShowRoutInMap() {

    var X = jQuery.noConflict();
    txtSourceStation = document.getElementById('cmbFromStation').value;
    txtDesinationStation = document.getElementById('cmbToStation').value;
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
        nRoutesIDs = [];
        var bRidirect = false;
        bUseDataBaseRah141 = true;

        X.ajax({
            type: "POST",
            url: strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchAllCoridorInfoFromDataBase_By_FromStation_ToStation",
            data: "{'str_FromStationID':'" + txtSourceStation + "' , 'str_ToStationID':'" + txtDesinationStation + "'}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (strHtmlOutput) {
                map.clearOverlays();
                if (strHtmlOutput.d != '') {
                    var result = strHtmlOutput.d;
                    for (var i = 0; i < result.length; i++) {
                        nRoutesIDs.push(result[i].ID)
                        initializeGMapForKoridorInfo(result[i]);
                    }
                }
            },
            error: function (MSG) {
                alert('error' + MSG);
            }
        });
    }
}
