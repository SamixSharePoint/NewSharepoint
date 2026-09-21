<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ShowAllPolyganInfoUserControl_EndUser.ascx.cs" Inherits="Sazmanyar.GIS.ShowAllPolyganInfo.ShowAllPolyganInfoUserControl_EndUser" %>
<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GIS/Script/css/gis-ui.css?v=20260921c" />
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-1.7.1.min.js" type="text/javascript"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/gis-ui.js?v=20260915" charset="utf-8"></script>
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

        }
    }


    //Draw Polygon from the PolygonMarkers Array
    function drawPolygon(PolygonMarkers, strFillColor, strBorderColor, nOpacity) {

        if (Polygon) { map.removeOverlay(Polygon); } //Remove existing Polygon from Map


        PolygonPoints.length = 0;
        for (var m = 0; m < PolygonMarkers.length; m++) {
            PolygonPoints.push(new GLatLng(PolygonMarkers[m].lat, PolygonMarkers[m].lng)); //Add Markers to PolygonPoints node array
        }

        if (PolygonPoints.length < 1) {
            return;
        }

        //Add first marker in the end to close the Polygon
        PolygonPoints.push(new GLatLng(PolygonMarkers[0].lat, PolygonMarkers[0].lng));

        strFillColor = (polygon_resizing) ? 'red' : strFillColor; //Set Polygon Fill Color
        Polygon = new GPolygon(PolygonPoints, strBorderColor, 2, 1, strFillColor, nOpacity); //New GPolygon object
        map.addOverlay(Polygon); //Add Polygon to the Map

        //TO DO: Function Call triggered after Polygon is drawn
        fitPolygon();
    }

    //Fits the Map to Polygon bounds
    function fitPolygon() {
        bounds = Polygon.getBounds();
        map.setCenter(bounds.getCenter(), map.getBoundsZoomLevel(bounds));
    }

    if (typeof ($) != 'undefined') {
        $(document).ready(function () {
            initialize();
            GUnload();
            FillCmbFromPolyganInfo();
        });
    }

    var strCurrentWebUrl = window.location.protocol + "//" + window.location.host + _spPageContextInfo.webServerRelativeUrl;
    function FillCmbFromPolyganInfo() {

        var X = jQuery.noConflict();

        var cmbFromPolygan = document.getElementById('cmbFromPolygan');
        for (i = 0; i < cmbFromPolygan.options.length; i++) {
            cmbFromPolygan.options[i] = null;
        }

        cmbFromPolygan.innerHTML = "";

        X.ajax({
            type: 'POST',
            url: strCurrentWebUrl + '/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchAllPolygans',
            data: "{}",
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            success: function (strHtmlOutput) {
                if (strHtmlOutput.d.trim != '') {
                    var objResult = strHtmlOutput.d;

                    var optFirstRow = document.createElement('option');
                    optFirstRow.innerHTML = "یکی از موارد را انتخاب کنید";
                    optFirstRow.value = "0";
                    cmbFromPolygan.appendChild(optFirstRow);

                    for (var i = 0; i < objResult.length; i++) {
                        var opt = document.createElement('option');
                        opt.innerHTML = objResult[i]["Value"];
                        opt.value = objResult[i]["ID"];
                        cmbFromPolygan.appendChild(opt);
                    }
                }
            },
            error: function (MSG) {
                alert('error' + MSG);
            }
        });

    }
    function ShowPolyganInMap(ctrl) {
        var cmbFromPolygan = document.getElementById(ctrl.id);
        var strSelectedFromPolygan = cmbFromPolygan.value;


        var ID = "";
        var strPolygonPoints = "";
        var FillColor = "";
        var BorderColor = "";
        var Opacity = "";

        try {

            ID = strSelectedFromPolygan.split("*/*")[0].toString();
            strPolygonPoints = strSelectedFromPolygan.split("*/*")[1].toString();
            FillColor = strSelectedFromPolygan.split("*/*")[2].toString();
            BorderColor = strSelectedFromPolygan.split("*/*")[3].toString();
            Opacity = strSelectedFromPolygan.split("*/*")[4].toString();

        } catch (e) {

        }




        var PolygonPoints = JSON.parse(strPolygonPoints);
        drawPolygon(PolygonPoints, FillColor, BorderColor, Opacity);

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
            <span>نمایش سطح</span>
        </div>
        <div class="gis-reg-body" id="pnlConfig">
            <div class="gis-reg-field">
                <label for="cmbFromPolygan">انتخاب سطح</label>
                <select id="cmbFromPolygan" onchange="ShowPolyganInMap(this);">
                </select>
            </div>
        </div>
    </div>
</div>
<div id='map_canvas' style="border: medium solid #FFFFFF; width: 100%; height: 620px;">
</div>
</div>
