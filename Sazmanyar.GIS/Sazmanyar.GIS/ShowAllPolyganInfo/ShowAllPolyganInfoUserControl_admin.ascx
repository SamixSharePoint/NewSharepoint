<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ShowAllPolyganInfoUserControl_admin.ascx.cs" Inherits="Sazmanyar.GIS.ShowAllPolyganInfo.ShowAllPolyganInfoUserControl_admin" %>
<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GIS/Script/css/gis-ui.css" />
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-1.7.1.min.js" type="text/javascript"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/gis-ui.js" charset="utf-8"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/GoogleMap/GISBase.js"></script>

<script type="text/javascript">
    /* Developed by: Abhinay Rathore [web3o.blogspot.com] */
    //Global variables
    var global = this;
    var map;

    var PolygonMarkers = []; //Array for Map Markers
    var PolygonPoints = []; //Array for Polygon Node Markers
    var bounds = new GLatLngBounds; //Polygon Bounds
    var Polygon; //Polygon overlay object
    var polygon_resizing = false; //To track Polygon Resizing

    //Polygon Marker/Node icons
    var redpin = new GIcon(); //Red Pushpin Icon
    redpin.image = "/_layouts/15/images/Sazmanyar.GIS/General/red-pushpin.png";
    redpin.iconSize = new GSize(32, 32);
    redpin.iconAnchor = new GPoint(10, 32);
    var bluepin = new GIcon(); //Blue Pushpin Icon
    bluepin.image = "/_layouts/15/images/Sazmanyar.GIS/General/blue-pushpin.png";
    bluepin.iconSize = new GSize(32, 32);
    bluepin.iconAnchor = new GPoint(10, 32);

    function initialize() { //Initialize Google Map
        if (GBrowserIsCompatible()) {
            // create the map
            // var map = new GMap2(document.getElementById("map"));
            //var map = new GMap(document.getElementById("map"));

            var mapCenter, mapZoom;
            var copyright = new GCopyright(1, new GLatLngBounds(new GLatLng(-90, -180), new GLatLng(90, 180)), 0, 'Sazmanyar');
            var copyrightCollection = new GCopyrightCollection('Map Data:');
            copyrightCollection.addCopyright(copyright);
            CustomGetTileUrl = function (a, b) {
                return '/_layouts/15/images/Sazmanyar.GoogleMapOffline/Google Maps Image/' + b + '/' + a.x + '/' + a.y + '.png';
            };
            var tilelayers = [new GTileLayer(copyrightCollection, 1, 13)];
            tilelayers[0].getTileUrl = CustomGetTileUrl;
            var custommap = new GMapType(tilelayers, new GMercatorProjection(13), "Sazmanyar");
            map = new GMap(document.getElementById('map_canvas'), { mapTypes: [custommap] });
            map.addControl(new GLargeMapControl());
            map.addMapType(G_PHYSICAL_MAP);
            map.setCenter(new GLatLng(35.7150676237549, 51.3955078125), 6);

            var ui = new GMapUIOptions(); //Map UI options
            ui.maptypes = { normal: true, satellite: true, hybrid: true, physical: false }
            ui.zoom = { scrollwheel: true, doubleclick: true };
            ui.controls = { largemapcontrol3d: true, maptypecontrol: true, scalecontrol: true };
            map.setUI(ui); //Set Map UI options

            //Add Shift+Click event to add Polygon markers
            GEvent.addListener(map, "click", function (overlay, point, overlaypoint) {
                var p = (overlaypoint) ? overlaypoint : point;
                //Add polygon marker if overlay is not an existing marker and shift key is pressed
                if (global.shiftKey && !checkPolygonMarkers(overlay)) { addMarker(p); }
            });
        }
    }

    // Adds a new Polygon boundary marker
    function addMarker(point) {
        var markerOptions = { icon: bluepin, draggable: true };
        var marker = new GMarker(point, markerOptions);
        PolygonMarkers.push(marker); //Add marker to PolygonMarkers array
        map.addOverlay(marker); //Add marker on the map
        GEvent.addListener(marker, 'dragstart', function () { //Add drag start event
            marker.setImage(redpin.image);
            polygon_resizing = true;
        });
        GEvent.addListener(marker, 'drag', function () { drawPolygon(); }); //Add drag event
        GEvent.addListener(marker, 'dragend', function () {   //Add drag end event
            marker.setImage(bluepin.image);
            polygon_resizing = false;
            drawPolygon();
            fitPolygon();
        });
        GEvent.addListener(marker, 'click', function (point) { //Add Ctrl+Click event to remove marker
            if (global.ctrlKey) { removeMarker(point); }
        });
        drawPolygon();

        //If more then 2 nodes then automatically fit the polygon
        if (PolygonMarkers.length > 2) fitPolygon();
    }

    // Removes a Polygon boundary marker
    function removeMarker(point) {
        if (PolygonMarkers.length == 1) { //Only one marker in the array
            map.removeOverlay(PolygonMarkers[0]);
            map.removeOverlay(PolygonMarkers[0]);
            PolygonMarkers = [];
            if (Polygon) { map.removeOverlay(Polygon) };
        }
        else //More then one marker
        {
            var RemoveIndex = -1;
            var Remove;
            //Search for clicked Marker in PolygonMarkers Array
            for (var m = 0; m < PolygonMarkers.length; m++) {
                if (PolygonMarkers[m].getPoint().equals(point)) {
                    RemoveIndex = m; Remove = PolygonMarkers[m]
                    break;
                }
            }
            //Shift Array elemeents to left
            for (var n = RemoveIndex; n < PolygonMarkers.length - 1; n++) {
                PolygonMarkers[n] = PolygonMarkers[n + 1];
            }
            PolygonMarkers.length = PolygonMarkers.length - 1 //Decrease Array length by 1
            map.removeOverlay(Remove); //Remove Marker
            drawPolygon(); //Redraw Polygon
        }
    }

    //Draw Polygon from the PolygonMarkers Array
    function drawPolygon() {

        var strFillColor = document.getElementById('txtFillColor').value;
        var strBorderColor = document.getElementById('txtBorderColor').value;
        var nOpacity = document.getElementById('txtOpacity').value

        PolygonPoints.length = 0;
        for (var m = 0; m < PolygonMarkers.length; m++) {
            PolygonPoints.push(PolygonMarkers[m].getPoint()); //Add Markers to PolygonPoints node array
        }
        //Add first marker in the end to close the Polygon
        PolygonPoints.push(PolygonMarkers[0].getPoint());
        if (Polygon) { map.removeOverlay(Polygon); } //Remove existing Polygon from Map
        strFillColor = (polygon_resizing) ? 'red' : strFillColor; //Set Polygon Fill Color
        Polygon = new GPolygon(PolygonPoints, strBorderColor, 2, 1, strFillColor, nOpacity); //New GPolygon object
        map.addOverlay(Polygon); //Add Polygon to the Map

        //TO DO: Function Call triggered after Polygon is drawn
    }

    //Fits the Map to Polygon bounds
    function fitPolygon() {
        bounds = Polygon.getBounds();
        map.setCenter(bounds.getCenter(), map.getBoundsZoomLevel(bounds));
    }
    //check is the marker is a polygon boundary marker
    function checkPolygonMarkers(marker) {
        var flag = false;
        for (var m = 0; m < PolygonMarkers.length; m++) {
            if (marker == PolygonMarkers[m])
            { flag = true; break; }
        }
        return flag;
    }

    //////////////////[ Key down event handler ]/////////////////////
    //Event handler class to attach events
    var EventUtil = {
        addHandler: function (element, type, handler) {
            if (element.addEventListener) {
                element.addEventListener(type, handler, false);
            } else if (element.attachEvent) {
                element.attachEvent("on" + type, handler);
            } else {
                element["on" + type] = handler;
            }
        }
    };

    // Attach Key down/up events to document
    EventUtil.addHandler(document, "keydown", function (event) { keyDownHandler(event) });
    EventUtil.addHandler(document, "keyup", function (event) { keyUpHandler(event) });

    //Checks for shift and Ctrl key press
    function keyDownHandler(e) {
        if (!e) var e = window.event;
        var target = (!e.target) ? e.srcElement : e.target;
        if (e.keyCode == 16 && !global.shiftKey) { //Shift Key
            global.shiftKey = true;
        }
        if (e.keyCode == 17 && !global.ctrlKey) { //Ctrl Key
            global.ctrlKey = true;
        }
    }

    //Checks for shift and Ctrl key release
    function keyUpHandler(e) {
        if (!e) var e = window.event;
        if (e.keyCode == 16 && global.shiftKey) { //Shift Key
            global.shiftKey = false;
        }
        if (e.keyCode == 17 && global.ctrlKey) { //Ctrl Key
            global.ctrlKey = false;
        }
    }

    if (typeof ($) != 'undefined') {
        $(document).ready(function () {
            initialize();
            GUnload();
        });
    }

    var strCurrentWebUrl = window.location.protocol + "//" + window.location.host + _spPageContextInfo.webServerRelativeUrl;
    function SubmitPolyganInMap() {

        var strFillColor = document.getElementById('txtFillColor').value;
        var strBorderColor = document.getElementById('txtBorderColor').value;
        var nOpacity = document.getElementById('txtOpacity').value

        var X = jQuery.noConflict();

        var txtNamePolygan = document.getElementById('txtNamePolygan').value;
        if (txtNamePolygan == '') {
            alert('اطلاعات نام سطح را وارد نمایید');
            return;
        }

        if (PolygonPoints == '' || PolygonPoints.length == 0) {
            alert('لطفا ابتدا سطح را رسم نمایید');
            return;
        }

        var strPolygonPoints = JSON.stringify(PolygonPoints);

        X.ajax({
            type: "POST",
            url: strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/InsertPolyganInDatabase",
            data: "{'strNamePolygan':'" + txtNamePolygan + "' , 'strPolygonPoints':'" + strPolygonPoints + "' ,  'strFillColor':'" + strFillColor + "' , 'strBorderColor':'" + strBorderColor + "', 'nOpacity':" + nOpacity + "}",
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

</script>



<style type="text/css">
    .gm-style-mtc {
        display: none;
    }
</style>
<div class="gis-root gis-root-map">
<div class="gis-reg-panel">
    <div class="gis-reg-tools">
        <button type="button" class="gis-reg-tool gis-fs-btn" onclick="gisToggleFullscreen(this);" title="نمایش تمام‌صفحه">
            <svg class="gis-fs-enter" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 9V4h5M20 9V4h-5M4 15v5h5M20 15v5h-5" /></svg><svg class="gis-fs-exit" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 4v5H4M15 4v5h5M9 20v-5H4M15 20v-5h5" /></svg>
            <span class="gis-fs-enter">تمام‌صفحه</span><span class="gis-fs-exit">خروج از تمام‌صفحه</span>
        </button>
    </div>
    <div class="gis-reg-section">
        <div class="gis-reg-section-title">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 8l7-4 9 5-3 10-10-1z" /></svg>
            <span>ثبت سطح</span>
        </div>
        <div class="gis-reg-body" id="pnlConfig">
            <div class="gis-reg-field">
                <label for="txtNamePolygan">نام سطح</label>
                <input id="txtNamePolygan" type="text" placeholder="نام سطح..." />
            </div>
            <div class="gis-reg-field">
                <label for="txtFillColor">رنگ داخل سطح</label>
                <input id="txtFillColor" type="text" value="Blue" />
            </div>
            <div class="gis-reg-field">
                <label for="txtBorderColor">رنگ دور سطح</label>
                <input id="txtBorderColor" type="text" value="Black" />
            </div>
            <div class="gis-reg-field">
                <label for="txtOpacity">شفافیت (بین 0 تا 1)</label>
                <input id="txtOpacity" type="text" value="0.2" />
            </div>
            <div class="gis-reg-hint">
                برای درج نقاط سطح از <b>Shift + کلیک چپ</b> و برای حذف نقاط از <b>Ctrl + کلیک چپ</b> روی نقشه استفاده کنید.
            </div>
            <button type="button" id="btnSubmit" class="gis-reg-btn gis-reg-btn-primary" onclick="SubmitPolyganInMap()">ثبت سطح</button>
        </div>
    </div>
</div>
<div id='map_canvas' style="border: medium solid #FFFFFF; width: 100%; height: 620px;">
</div>
</div>
