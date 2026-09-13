<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> 
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> 
<%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %> 
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ShowAllKoridorInfoUserControl_Tajamoee.ascx.cs" Inherits="Sazmanyar.GIS.ShowAllKoridorInfo.ShowAllKoridorInfoUserControl_Tajamoee" %>
<style type="text/css">
    #s4-leftpanel
    {
        display: none;
    }
    
    .s4-ca
    {
        margin-right: 0px;
    }
    
    .s4-title
    {
        display: none;
    }
</style>
<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GIS/Script/css/gis-ui.css" />
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-1.9.1.js" type="text/javascript"></script>
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/gis-ui.js" type="text/javascript" charset="utf-8"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/GoogleMap/GISBase.js"></script>
<script src="/_layouts/15/Sazmanyar.GIS/GoogleMap/EWindow.js" type="text/javascript"></script>
<script src="/_layouts/15/Sazmanyar.GIS/GoogleMap/elabel.js" type="text/javascript"></script>
<script type="text/javascript" language="javascript">
    var strCurrentWebUrl = window.location.protocol + "//" + window.location.host + _spPageContextInfo.webServerRelativeUrl;

    if (typeof ($) != 'undefined') {
        $(document).ready(function () {
            hazfPanelSearchResult();
        });
    }

    function CreateIframPopup(ID) {
        var strSrc = strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ForShowIframInfo.htm";
        var strcontent = "";
        strcontent = strcontent + '<div id="opacityDIV" style="display: block; z-index: 100000;"><div class="transOn"></div>';
        strcontent = strcontent + '<div class="opDiv">';
        strcontent = strcontent + '<div class="width : 100%;height : 100px;"><br /><br /><img src="/_layouts/15/images/Sazmanyar.GIS/General/loading/Load.gif" alt="wait" /><br /><br />در حال بارگذاری ...</div>'
        strcontent = strcontent + '</div>';
        strcontent = strcontent + '</div>';
        strcontent = strcontent + '<iframe  onload="hideLoading();"  src="' + strSrc + '?Station_ID=' + ID + '&CurrentWebUrl=' + strCurrentWebUrl + '"  width="500" height="300px" id="iframeDorbin" marginheight="0" frameborder="0" ></iframe>';
        return strcontent;
    }

    function getchlSelectedValues(chlElement) {
        var chkText = '';
        var ltchktr = chlElement.getElementsByTagName('tr');
        for (var i = 0; i < ltchktr.length; i++) {
            var ltchktd = ltchktr[i].getElementsByTagName('td');
            for (var j = 0; j < ltchktd.length; j++) {
                var ltchkinput = ltchktd[j].getElementsByTagName('input');
                var chklabel = ltchktd[j].getElementsByTagName('label');
                for (k = 0; k < ltchkinput.length; k++) {
                    var chkopt = ltchkinput[k];
                    if (chkopt.checked) {
                        chkText = chkText + chklabel[k].innerHTML + '#@#';
                    }
                }
            }
        }
        return chkText;
    }

    function hideLoading() {
        try {
            document.getElementById('opacityDIV').style.display = "none";
        } catch (e) {

        }

    }

    var X = jQuery.noConflict();
    nRoutesIDs = [];
    var bRidirect = false;
    bUseDataBaseRah141 = true;


    function ShowAllRoutInMap() {

        var NameProjeh = "";
        var OnvanMaseer = "";
        var OnvanStation = "";
        var VaziyatTehaghoghMaseer = "";
        var VaziyatTehaghoghStation = "";


        OnvanMaseer = document.getElementById('txtOnvanMaseer').value;
        OnvanStation = document.getElementById('txtOnvanStation').value;
        VaziyatTehaghoghStation = getchlSelectedValues(document.getElementById(X('.VaziyatTehaghoghStation').attr('ID')));


        VaziyatTehaghoghMaseer = getchlSelectedValues(document.getElementById(X('.VaziyatTehaghoghMaseer').attr('ID')));
        VaziyatTehaghoghMaseer = VaziyatTehaghoghMaseer.replace("بیش از 90 درصد", "1");
        VaziyatTehaghoghMaseer = VaziyatTehaghoghMaseer.replace("بین 70 تا 90 درصد", "2");
        VaziyatTehaghoghMaseer = VaziyatTehaghoghMaseer.replace("بین 50 تا 70 درصد", "3");
        VaziyatTehaghoghMaseer = VaziyatTehaghoghMaseer.replace("کمتر از 50 درصد", "4");
        VaziyatTehaghoghMaseer = VaziyatTehaghoghMaseer.replace("آغاز نشده", "5");


        VaziyatTehaghoghStation = getchlSelectedValues(document.getElementById(X('.VaziyatTehaghoghStation').attr('ID')));
        VaziyatTehaghoghStation = VaziyatTehaghoghStation.replace("بیش از 90 درصد", "1");
        VaziyatTehaghoghStation = VaziyatTehaghoghStation.replace("بین 70 تا 90 درصد", "2");
        VaziyatTehaghoghStation = VaziyatTehaghoghStation.replace("بین 50 تا 70 درصد", "3");
        VaziyatTehaghoghStation = VaziyatTehaghoghStation.replace("کمتر از 50 درصد", "4");
        VaziyatTehaghoghStation = VaziyatTehaghoghStation.replace("آغاز نشده", "5");

        document.getElementById('divSearchResult').innerHTML = '';
        document.getElementById('divSearchResult').innerHTML = '<p></p>';
        document.getElementById('divSearchResult').innerHTML = '<div class="gis-msg gis-msg-wait">لطفاً کمی صبر نمایید ...<br />سیستم در حال جستجوی اطلاعات مورد نیاز شما می باشد</div>';

        X.ajax({
            type: "POST",
            url: strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchAllCoridorInfoFromDataBase",
            data: "{'NameProjeh':'" + NameProjeh + "' ,'OnvanMaseer':'" + OnvanMaseer + "' , 'OnvanStation':'" + OnvanStation + "', 'VaziyatTehaghoghMaseer':'" + VaziyatTehaghoghMaseer + "', 'VaziyatTehaghoghStation':'" + VaziyatTehaghoghStation + "'}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (strHtmlOutput) {

                divSearchResult_html = "";
                gpolys = [];
                gmarkers = [];

                map.clearOverlays();

                GEvent.addListener(map, "click", function (overlay, point) {
                    if (!overlay) {
                        map.closeInfoWindow();
                    }
                });

                if (strHtmlOutput.d != '') {
                    var result = strHtmlOutput.d;
                    for (var i = 0; i < result.length; i++) {
                        nRoutesIDs.push(result[i].ID)
                        initializeGMapForKoridorInfo(result[i]);
                    }
                    map.centerAndZoomOnBounds(bounds);
                }

                if (divSearchResult_html != '') {
                    document.getElementById("divSearchResult").innerHTML = divSearchResult_html;
                }
                else {
                    document.getElementById('divSearchResult').innerHTML = '<div class="gis-msg">هیچ موردی جهت نمایش در لیست یافت نشد</div>';
                }

            },
            error: function (MSG) {
                alert('error' + MSG);
            }
        });
    }

    function initializeGMapForKoridorInfo(ObjAllRoutInfo) {

        var result = "";

        if (ObjAllRoutInfo.Points != null && ObjAllRoutInfo.Points != "") {
            try {
                result = JSON.parse(ObjAllRoutInfo.Points);
            } catch (e) {
            }
        }
        var CurrentColor = ObjAllRoutInfo.Color;

        var ID = 0;
        var Title = "";
        var points = [];
        var BaseColor = '#00b2ff';

        var StationFrom_ID = 0;
        var StationFrom_Title = "";
        var LatFrom = 0;
        var LongFrom = 0;

        var StationTo_ID = 0;
        var StationTo_Title = "";
        var LatTo = 0;
        var LongTo = 0;


        if (typeof (ObjAllRoutInfo.ID) != 'undefined' && ObjAllRoutInfo.ID != null) {
            ID = ObjAllRoutInfo.ID;
        }

        if (typeof (ObjAllRoutInfo.Title) != 'undefined' && ObjAllRoutInfo.Title != null) {
            Title = ObjAllRoutInfo.Title;
        }

        for (var i = 0, len = result.length; i < len; i++) {
            var point = new GLatLng(result[i].lat, result[i].lng);
            points.push(point);
        }

        if (typeof (CurrentColor) != 'undefined' && CurrentColor != null) {
            BaseColor = CurrentColor;
        }


        if (typeof (ObjAllRoutInfo.StationFrom_ID) != 'undefined' && ObjAllRoutInfo.StationFrom_ID != null) {
            StationFrom_ID = ObjAllRoutInfo.StationFrom_ID;
        }

        if (typeof (ObjAllRoutInfo.StationFrom_Title) != 'undefined' && ObjAllRoutInfo.StationFrom_Title != null) {
            StationFrom_Title = ObjAllRoutInfo.StationFrom_Title;
        }

        if (typeof (ObjAllRoutInfo.LatFrom) != 'undefined' && ObjAllRoutInfo.LatFrom != null) {
            LatFrom = ObjAllRoutInfo.LatFrom;
        }

        if (typeof (ObjAllRoutInfo.LongFrom) != 'undefined' && ObjAllRoutInfo.LongFrom != null) {
            LongFrom = ObjAllRoutInfo.LongFrom;
        }


        if (typeof (ObjAllRoutInfo.StationTo_ID) != 'undefined' && ObjAllRoutInfo.StationTo_ID != null) {
            StationTo_ID = ObjAllRoutInfo.StationTo_ID;
        }

        if (typeof (ObjAllRoutInfo.StationTo_Title) != 'undefined' && ObjAllRoutInfo.StationTo_Title != null) {
            StationTo_Title = ObjAllRoutInfo.StationTo_Title;
        }

        if (typeof (ObjAllRoutInfo.LatTo) != 'undefined' && ObjAllRoutInfo.LatTo != null) {
            LatTo = ObjAllRoutInfo.LatTo;
        }

        if (typeof (ObjAllRoutInfo.LongTo) != 'undefined' && ObjAllRoutInfo.LongTo != null) {
            LongTo = ObjAllRoutInfo.LongTo;
        }

        createClickablePolyline_Custom(ID, Title, points, BaseColor, StationFrom_ID, StationFrom_Title, LatFrom, LongFrom, StationTo_ID, StationTo_Title, LatTo, LongTo, ObjAllRoutInfo);
    }

    // TLabel marker with animated gif and clickability via addDomListener
    function createTLabel1(point, html) {
        var label = new TLabel();
        label.id = 'Label ' + n;
        label.anchorLatLng = point;
        label.anchorPoint = 'bottomCenter';
        label.content = '<img src="/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Marker/anicon.gif" width=20 height=34 />';
        label.markerOffset = new GSize(-1, -5);
        map.addTLabel(label);
        GEvent.addDomListener(document.getElementById(label.id), "click", function () {
            map.openInfoWindowHtml(point, html, { pixelOffset: new GSize(0, -34) });
        });
        n++;

        return marker;
    }

    // Custom icon is identical to the default icon, except that its invisible
    var icon = new GIcon(G_DEFAULT_ICON, "http://www.google.com/intl/en_ALL/mapfiles/markerTransparent.png");

    // An invisible marker, for the shadow and clickability, and an animated TLabel 
    function createTLabel2(point, html) {
        var marker = new GMarker(point, icon);
        GEvent.addListener(marker, "click", function () {
            marker.openInfoWindowHtml(html);
        });
        map.addOverlay(marker);
        var label = new TLabel();
        label.id = 'Label ' + n;
        label.anchorLatLng = point;
        label.anchorPoint = 'bottomCenter';
        label.content = '<img src="/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Marker/anicon.gif" width=20 height=34 />';
        label.markerOffset = new GSize(-1, -5);
        map.addTLabel(label);
        n++;

        return marker;
    }

    // An invisible marker, for the shadow and clickability, and an animated ELabel 
    function createELabel(point, html) {
        var marker = new GMarker(point, icon);
        GEvent.addListener(marker, "click", function () {
            marker.openInfoWindowHtml(html);
        });
        map.addOverlay(marker);
        var label = new ELabel(point, '<img src="/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Marker/anicon.gif" width=20 height=34 />', null, new GSize(-9, 6), null, true);
        map.addOverlay(label);

        return marker;
    }

    // Using a GMarker works in API v2.59 onwards
    var anicon = new GIcon(G_DEFAULT_ICON, "/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Marker/anicon.gif");
    function createMarker(point, html) {
        var marker = new GMarker(point, anicon);
        GEvent.addListener(marker, "click", function () {
            marker.openInfoWindowHtml(html);
        });
        map.addOverlay(marker);
    }




    function createClickablePolyline_Custom(ID, label, points, BaseColor, StationFrom_ID, StationFrom_Title, LatFrom, LongFrom, StationTo_ID, StationTo_Title, LatTo, LongTo, ObjAllRoutInfo) {

        if (points.length > 0) {

            var HTMlPoly = "";
            HTMlPoly = HTMlPoly + "<div class='gis-iw'>";
            HTMlPoly = HTMlPoly + "<table cellpadding ='5' >";

            HTMlPoly = HTMlPoly + "<tr>";
            HTMlPoly = HTMlPoly + "<td>";
            try {

                HTMlPoly = HTMlPoly + " مبدا: <b>" + StationFrom_Title + "</b>";
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "<td>";
            try {

                HTMlPoly = HTMlPoly + " مقصد: <b>" + StationTo_Title + "</b>";
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "</tr>";

            HTMlPoly = HTMlPoly + "<tr>";
            HTMlPoly = HTMlPoly + "<td>";
            try {

                HTMlPoly = HTMlPoly + "عنوان: <b>" + Title + "</b>";
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "<td>";
            try {

                //                HTMlPoly = HTMlPoly + "تعداد کر: <b>" + ObjAllRoutInfo.NumberCore + "</b>";
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "</tr>";


            HTMlPoly = HTMlPoly + "<tr>";
            HTMlPoly = HTMlPoly + "<td>";
            try {

                HTMlPoly = HTMlPoly + "تاریخ شروع مسیر : <b>" + ObjAllRoutInfo.RouteStartDate + "</b>";
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "<td>";
            try {

                HTMlPoly = HTMlPoly + "تاریخ پایان مسیر: <b>" + ObjAllRoutInfo.RouteFinishDate + "</b>";
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "</tr>";

            //            HTMlPoly = HTMlPoly + "<tr>";
            //            HTMlPoly = HTMlPoly + "<td>";
            //            try {

            //                HTMlPoly = HTMlPoly + "طول مسیر هوایی: <b>" + ObjAllRoutInfo.PlaneDistanceMap + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlPoly = HTMlPoly + "</td>";
            //            HTMlPoly = HTMlPoly + "<td>";
            //            try {

            //                HTMlPoly = HTMlPoly + "طول مسیر جغرافیایی: <b>" + ObjAllRoutInfo.PlaneDistanceChart + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlPoly = HTMlPoly + "</td>";
            //            HTMlPoly = HTMlPoly + "</tr>";


            //            HTMlPoly = HTMlPoly + "<tr>";
            //            HTMlPoly = HTMlPoly + "<td>";
            //            try {

            //                HTMlPoly = HTMlPoly + "میزان افت کر اول: <b>" + ObjAllRoutInfo.ReduceCore1 + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlPoly = HTMlPoly + "</td>";
            //            HTMlPoly = HTMlPoly + "<td>";
            //            try {

            //                HTMlPoly = HTMlPoly + "میزان افت کر دوم: <b>" + ObjAllRoutInfo.ReduceCore2 + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlPoly = HTMlPoly + "</td>";
            //            HTMlPoly = HTMlPoly + "</tr>";

            HTMlPoly = HTMlPoly + "<tr>";
            HTMlPoly = HTMlPoly + "<td>";
            try {

                HTMlPoly = HTMlPoly + "درصد پیشرفت: <b>" + ObjAllRoutInfo.Complete + "</b>";
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "<td>";
            try {

                HTMlPoly = HTMlPoly + "درصد تحقق: <b>" + ObjAllRoutInfo.TahaghoghRoute + "</b>";
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "</tr>";

            HTMlPoly = HTMlPoly + "</table>";
            HTMlPoly = HTMlPoly + "</div>";

            points.splice(0, 0, new GLatLng(LatFrom, LongFrom));
            points.push(new GLatLng(LatTo, LongTo));

            var myPinIcon = new GIcon();
            myPinIcon.image = '/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Marker/Pin.png';
            myPinIcon.iconSize = new GSize(16, 20);
            myPinIcon.shadowSize = new GSize(16, 20);
            myPinIcon.iconAnchor = new GPoint(5, 5);
            myPinIcon.infoWindowAnchor = new GPoint(5, 1);


            var objmarker_StationFrom = new GMarker(new GLatLng(LatFrom, LongFrom), { icon: myPinIcon, title: StationFrom_Title });
            map.addOverlay(objmarker_StationFrom);
            var ew_objmarker_StationFrom = new EWindow(map, E_STYLE_0);
            map.addOverlay(ew_objmarker_StationFrom);

            var objmarker_StationTo = new GMarker(new GLatLng(LatTo, LongTo), { icon: myPinIcon, title: StationTo_Title });
            map.addOverlay(objmarker_StationTo);
            var ew_objmarker_StationTo = new EWindow(map, E_STYLE_0);
            map.addOverlay(ew_objmarker_StationTo);


            var poly = new GPolyline(points, BaseColor, 5, 1);
            poly.objmarker_StationFrom = objmarker_StationFrom;
            poly.objmarker_StationTo = objmarker_StationTo;

            gpolys.push(poly);


            var poly_num = gpolys.length - 1;
            if (HTMlPoly) {
                GEvent.addListener(poly, 'click', function (point) {
                    if (!point) {
                        point = poly.getVertex(Math.floor(poly.getVertexCount() / 2));
                    }
                    map.openInfoWindowHtml(point, HTMlPoly);
                    map.panTo(point);
                    map.setCenter(point);
                });


            }


            if (!label) {
                label = "polyline #" + poly_num;
            }
            divSearchResult_html += gisResultItem('route', 'poly', poly_num, 'togglePoly', BaseColor, 'gpolys', label);

            if (poly && poly.getBounds && poly.getBounds()) {
                if (debug) { GLog.write(poly.getBounds() + ":" + poly.getBounds().getNorthEast() + ":" + poly.getBounds().getSouthWest()) }
                bounds.extend(poly.getBounds().getNorthEast());
                bounds.extend(poly.getBounds().getSouthWest());
            }
            map.addOverlay(poly);

        }
        else {

            //فقط به نقطه شروع نگاه می کنیم

            var objmarker_StationFrom = createELabel(new GLatLng(LatFrom, LongFrom), CreateIframPopup(StationFrom_ID));
            gmarkers.push(objmarker_StationFrom);
            bounds.extend(objmarker_StationFrom.getPoint());
            map.addOverlay(objmarker_StationFrom);

            var marker_num = gmarkers.length - 1;
            divSearchResult_html += '<div class="gis-item gis-item-station"><input type="checkbox" id="marker' + marker_num + '" checked="checked" disabled="disabled" onclick="togglemarker(' + marker_num + ');" /><span class="gis-swatch" style="background:' + BaseColor + '"></span><a class="gis-item-text" href="javascript:GEvent.trigger(gmarkers[' + marker_num + '],\'click\');"><span class="gis-item-title">' + gisEscapeHtml(StationFrom_Title) + '</span></a></div>';
        }

    }

    function ButtonSearchClicked() {

        var OnvanMaseer = document.getElementById('txtOnvanMaseer').value;
        var OnvanStation = document.getElementById('txtOnvanStation').value;

        if (OnvanMaseer.trim().length == 0 && OnvanStation.trim().length == 0) {
            alert("اطلاعات مسیر یا ایستگاه جهت جستجو الزامی است");
            return;
        }

        document.getElementById('divRightOptions').style.display = 'block';
        document.getElementById('PanelSearchResult').style.visibility = 'visible';
        document.getElementById('PanelSearchOptions').style.visibility = 'hidden';

        ShowAllRoutInMap();

    }

    var MyLocationMarker;
    function CheckBoxOrderByLocationClick() {
        if (document.getElementById('chbMainContentOrderByLocation').checked) {
            addMyLocationMarker();
            document.getElementById('btnSearch').title = 'جستجو بر اساس نزدیکی به موقعیت آدمک';
        }
        else {
            ClearMyLocationMarker();
            document.getElementById('btnSearch').title = 'جستجو بر اساس نزدیکی به مرکز نقشه';
        }
    }
    function addMyLocationMarker() {
        if (map != null) {
            if ((typeof MyLocationMarker == 'undefined') || (MyLocationMarker == null)) {
                var myIcon = new GIcon();
                myIcon.image = '/_layouts/15/images/Sazmanyar.GoogleMapOffline/Marker/iconMe.png';
                myIcon.iconAnchor = new GPoint(1, 1);
                var point = new GLatLng(map.getCenter().lat(), map.getCenter().lng());
                MyLocationMarker = new GMarker(point, { draggable: true, title: 'موقعیت من', icon: myIcon });
                map.addOverlay(MyLocationMarker);
            }
        }
    }

    function hazfPanelSearchResult() {
        document.getElementById('PanelSearchResult').style.visibility = 'hidden';
        document.getElementById('PanelSearchOptions').style.visibility = 'visible';

    }

    function SetMyLocationMarkerInCenter() {
        if (typeof MyLocationMarker == 'undefined') { return false; }
        if (MyLocationMarker != null) { MyLocationMarker.setLatLng(map.getCenter()); }
    }

    function ClearMyLocationMarker() {
        if (MyLocationMarker == null) { return; }
        map.removeOverlay(MyLocationMarker); ;
        MyLocationMarker = null;
    }
    function rad(x) { return x * Math.PI / 180; }
    function find_closest_marker() {
        //                                    if (mapPoints == null) { return null; }  
        //                                    if (mapPoints.bindings == null) { return null;  }  
        //                                    var mapPoints_bindings = []  ;
        //                                    for (var counter = 0; counter < mapPoints.bindings.length; counter++) {
        //                                        mapPoints_bindings.push(mapPoints.bindings[counter]);
        //                                    }

        //                                    var SortedPointsmarkers = [];
        //                               
        //                                    var lat = -1;
        //                                    var lng = -1;

        //                                    if ((typeof map != 'undefined') && (map != null)) {
        //                                                        lat = map.getCenter().lat();
        //                                                        lng = map.getCenter().lng();
        //                                    }

        //                                    if (document.getElementById('chbMainContentOrderByLocation').checked) {
        //                                        if (typeof MyLocationMarker != 'undefined') {
        //                                            lat = MyLocationMarker.getLatLng().lat();
        //                                            lng = MyLocationMarker.getLatLng().lng();
        //                                        }
        //                                    }
        //            
        //                                    var R = 6371; // radius of earth in km
        //                             
        //                                    while  (mapPoints_bindings.length > 0)
        //                                    {
        //                                        var closest = -1;
        //                                        var distances = [];
        //                                        for (var i = 0; i < mapPoints_bindings.length; i++) {
        //                                            var mlat = mapPoints_bindings[i]." + LatField + @"; 
        //                                            var mlng = mapPoints_bindings[i]." + LongField + @";
        //                                            var dLat  = rad(mlat - lat);
        //                                            var dLong = rad(mlng - lng);
        //                                            var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
        //                                                Math.cos(rad(lat)) * Math.cos(rad(lat)) * Math.sin(dLong/2) * Math.sin(dLong/2);
        //                                            var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        //                                            var d = R * c;
        //                                            distances[i] = d;
        //                                            if ( closest == -1 || d < distances[closest] ) {
        //                                                closest = i;
        //                                            }
        //                                        } 
        //                                    
        //                                        SortedPointsmarkers.push(mapPoints_bindings[closest]);                            
        //                                        removeByIndex(mapPoints_bindings, closest);
        //                                  }
        //                                return  SortedPointsmarkers;                      
    }

    function removeByIndex(arr, index) {
        arr.splice(index, 1);
    }

    function FillDivSearchResult(SortedPointsmarkers) {
        //                                    document.getElementById('divSearchResult').innerHTML ='';           
        //                                    if (SortedPointsmarkers == null) 
        //                                    { 
        //                                        document.getElementById('divSearchResult').innerHTML = '<p style=\'color:blue\' >هیچ موردی جهت نمایش در لیست یافت نشد </p>';
        //                                        return; 
        //                                    }  

        //                                    if (SortedPointsmarkers.length == 0) 
        //                                    { 
        //                                        document.getElementById('divSearchResult').innerHTML = '<p style=\'color:blue\'>هیچ موردی جهت نمایش در لیست یافت نشد </p>';
        //                                        return; 
        //                                    }  

        //                                    var HTML = '' ;
        //                                    var cnt = 0 ;
        //            
        //                                    HTML += '<p style=\'color:blue\' >تعداد موارد یافت شده '  + SortedPointsmarkers.length + ' عدد می باشد';

        //                                    var MaxSearchResult  =  " + MaxSearchResult + @";
        //                                    if(MaxSearchResult== 0)
        //                                    {
        //                                        MaxSearchResult = SortedPointsmarkers.length;
        //                                    }
        //                                    else if(MaxSearchResult < SortedPointsmarkers.length)
        //                                    {
        //                                        HTML += 'که '  + MaxSearchResult + ' مورد از آنها در لیست زیر نشان داده شده است';
        //                                    }
        //                                    HTML += '</p>';
        //         
        //          
        //                                    for (var r = 0; r < MaxSearchResult ; r++) {

        //                                            if(r > SortedPointsmarkers.length-1) { break; }
        //                                            var BusinessID = SortedPointsmarkers[r].ID;
        //                                            var strInternalNameResult1 = SortedPointsmarkers[r]." + TitleField + @" ;;
        //                                            if ('" + strInternalNameResult1 + @"' != '_____Null_____') 
        //                                            {
        //                                               strInternalNameResult1 = SortedPointsmarkers[r]." + strInternalNameResult1 + @" ;
        //                                            }
        //                    
        //                                            var strInternalNameResult2 ='';
        //                                            if ('" + strInternalNameResult2 + @"' != '_____Null_____') 
        //                                            {
        //                                                strInternalNameResult2 = SortedPointsmarkers[r]." + strInternalNameResult2 + @" ;
        //                                            }
        //             
        //                                            var Latitude = SortedPointsmarkers[r]." + LatField + @";
        //                                            var Longitude = SortedPointsmarkers[r]." + LongField + @";
        //                                            var IconFileName = '" + CurrentWeb.Url + "/_layouts/15/images/Sazmanyar.GoogleMapOffline/Marker/' + SortedPointsmarkers[r]." + StateField + @"  +  '/marker.png';
        //          
        //                                        if (cnt > 0) {
        //                                            HTML += '<br/>';
        //                                        }

        //                                        HTML += '<table>';
        //                                        HTML += '<tr>';
        //                                        HTML += '<td style='vertical-align:top'>';
        //                                        if (parseFloat(Latitude) < 0 || parseFloat(Longitude) < 0) {
        //                                            HTML += ' <img src='img/Markers/disabledMarker.gif' title='موقعیت هنوز مشخص نشده است' />';
        //                                        }
        //                                        else {
        //                                            HTML += ' <img style='cursor:pointer' src='' + IconFileName + '' title='نمایش موقعیت بر روی نقشه' onclick='javascript:ShowLocation(' +  BusinessID +  ' ,' + Latitude + ',' + Longitude + ')' />';
        //                                        }
        //                                        HTML += '</td>';
        //                                        HTML += '<td>';

        //                                        HTML += '<strong style='Color:gray;margin-right:5px' >' + ( r + 1) + '-' + '</strong>' + ' <a  class='Link' href='#' onclick='javascript:ShowDetailInfo(' +  BusinessID +  ' )'> ' + '<strong>' + strInternalNameResult1 + '</strong> </a> ';

        //                                        HTML += '<br/>';
        //                                        if (strInternalNameResult2 != '') {
        //                                            if (strInternalNameResult2.length > 65) {
        //                                                strInternalNameResult2 = strInternalNameResult2.substring(0, 65);
        //                                                strInternalNameResult2 += ' ... ';
        //                                            }
        //                                            HTML += strInternalNameResult2;
        //                                        }
        //                                        HTML += '</td>';
        //                                        HTML += '</tr>';
        //                                        HTML += '</table>';
        //                                        cnt++;

        //                                        }
        //                                        document.getElementById('divSearchResult').innerHTML = HTML;
    }


</script>

<asp:Literal runat="server" Id="InitializBounds" />

<table width="100%">
    <tr>
        <td valign="top">
            <div id="divRightOptions" style="border: solid 1px black; width: 300px; direction: rtl;">
                <div id="PanelSearchOptions" style="position: absolute;">
                    <br />
                    <br />
                    <br />
                    <table cellpadding="0" cellspacing="0" style="margin-right: 5px;">
                        <tr>
                            <td colspan="2">
                                <div id="pnlFilterPart" runat="server" align="center" style="width: 100%">
                                    <table width="100%" cellpadding="2" cellspacing="2">
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblError" runat="server" ForeColor="Red" Text=""></asp:Label>
                                            </td>
                                        </tr>
                                        <tr id="pnlSearch1" runat="server">
                                            <td align="right">
                                                <fieldset style="padding: 3px">
                                                    <legend>
                                                        <asp:Label ID="lblOnvanMaseer" runat="server" ForeColor="Black" Text="عنوان مسیر:"></asp:Label>
                                                    </legend>
                                                    <input id="txtOnvanMaseer" style="width: 90%" />
                                                </fieldset>
                                            </td>
                                        </tr>
                                        <tr id="pnlSearch2" runat="server">
                                            <td align="right">
                                                <fieldset style="padding: 3px">
                                                    <legend>
                                                        <asp:Label ID="lblOnvanStation" runat="server" ForeColor="Black" Text="عنوان ایستگاه:">
                                                        </asp:Label>
                                                    </legend>
                                                    <input id="txtOnvanStation" style="width: 90%" />
                                                </fieldset>
                                            </td>
                                        </tr>
                                        <tr id="pnlCheckList1" runat="server">
                                            <td align="right">
                                                <fieldset style="padding: 3px">
                                                    <legend>
                                                        <asp:Label ID="lblVaziyatTehaghoghMaseer" runat="server" ForeColor="Black" Text="درصد تحقق مسیر:">
                                                        </asp:Label>
                                                    </legend>
                                                    <asp:CheckBoxList ID="chbVaziyatTehaghoghMaseer" class="VaziyatTehaghoghMaseer" runat="server"
                                                        RepeatColumns="2" RepeatDirection="Horizontal">
                                                        <asp:ListItem Value="1">بیش از 90 درصد</asp:ListItem>
                                                        <asp:ListItem Value="2">بین 70 تا 90 درصد</asp:ListItem>
                                                        <asp:ListItem Value="3">بین 50 تا 70 درصد</asp:ListItem>
                                                        <asp:ListItem Value="4">کمتر از 50 درصد</asp:ListItem>
                                                        <asp:ListItem Value="5">آغاز نشده</asp:ListItem>
                                                    </asp:CheckBoxList>
                                                </fieldset>
                                            </td>
                                        </tr>
                                        <tr id="pnlCheckList2" runat="server">
                                            <td align="right">
                                                <fieldset style="padding: 3px">
                                                    <legend>
                                                        <asp:Label ID="lblVaziyatTehaghoghStation" runat="server" ForeColor="Black" Text="درصد تحقق ایستگاه:">
                                                        </asp:Label>
                                                    </legend>
                                                    <asp:CheckBoxList ID="chbVaziyatTehaghoghStation" class="VaziyatTehaghoghStation"
                                                        runat="server" RepeatColumns="2" RepeatDirection="Horizontal">
                                                        <asp:ListItem Value="1">بیش از 90 درصد</asp:ListItem>
                                                        <asp:ListItem Value="2">بین 70 تا 90 درصد</asp:ListItem>
                                                        <asp:ListItem Value="3">بین 50 تا 70 درصد</asp:ListItem>
                                                        <asp:ListItem Value="4">کمتر از 50 درصد</asp:ListItem>
                                                        <asp:ListItem Value="5">آغاز نشده</asp:ListItem>
                                                    </asp:CheckBoxList>
                                                </fieldset>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </td>
                        </tr>
                    </table>
                    <input type="button" style="text-align: right; width: 140px; background-image: url('/_layouts/15/images/Sazmanyar.GIS/GoogleMap/search_network.png');
                        background-repeat: no-repeat; height: 40px;" value="جستجو در نقشه" id="btnSearch"
                        onclick="ButtonSearchClicked();" title="جستجو بر اساس نزدیکی به مرکز نقشه" />
                </div>
                <div id="PanelSearchResult">
                    <table width="100%" cellpadding="10px" cellspacing="10px">
                        <tr>
                            <td align="left">
                                <input type="button" style="text-align: right; width: 40px; background-image: url('/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Back.png');
                                    background-repeat: no-repeat; height: 40px;" id="hazfePanelSearchResult" onclick="hazfPanelSearchResult();"
                                    title="حذف نتایج و بازگشت به صفحه جستجو" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div id="divSearchResult" class="gis-list" style="height: 310px; font-size: 0.9em; overflow: auto;">
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </td>
        <td valign="top" style="width: 100%">
            <div id="map" style="width: 100%; height: 550px">
            </div>
        </td>
    </tr>
</table>
<script type="text/javascript">
    //<![CDATA[

    var mapInitLongitude, mapInitLatitude, mapInitZoom, mapInitType;

    var latitudeAttr = "lat";
    var longitudeAttr = "lng";


    var degreesPerRadian = 180.0 / Math.PI;
    var radiansPerDegree = Math.PI / 180.0;

    // Returns the bearing in degrees between two points.
    // North = 0, East = 90, South = 180, West = 270.
    function bearing(from, to) {
        // See T. Vincenty, Survey Review, 23, No 176, p 88-93,1975.
        // Convert to radians.
        var lat1 = from.latRadians();
        var lon1 = from.lngRadians();
        var lat2 = to.latRadians();
        var lon2 = to.lngRadians();

        // alert("lat1="+lat1+", lat2="+lat2+", lon1="+lon1+", lon2="+lon2);

        // Compute the angle.
        var angle = -Math.atan2(Math.sin(lon1 - lon2) * Math.cos(lat2), Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(lon1 - lon2));
        if (angle < 0.0)
            angle += Math.PI * 2.0;

        // And convert result to degrees.
        angle = angle * degreesPerRadian;
        angle = angle.toFixed(1);

        return angle;
    }

    GMap.prototype.centerAndZoomOnBounds = function (bounds) {
        if (debug) GLog.write("centerAndZoomOnBounds()");
        var center_lat = (bounds.getNorthEast().lat() + bounds.getSouthWest().lat()) / 2.0;
        var center_lng = (bounds.getNorthEast().lng() + bounds.getSouthWest().lng()) / 2.0;
        var center = new GLatLng(center_lat, center_lng)
        map.setCenter(center, map.getBoundsZoomLevel(bounds));
    }

    if (GBrowserIsCompatible()) {
        // this variable will collect the html which will eventualkly be placed in the divSearchResult
        var divSearchResult_html = "";

        // arrays to hold copies of the markers and html used by the divSearchResult
        // because the function closure trick doesnt work there
        var gmarkers = [];
        var gpolys = [];

        // global variables
        var map;
        var request;
        var bounds = new GLatLngBounds();
        var geonamesUrl;
        var earthtoolsUrl;
        var addFile = false;
        var debug = false;
        var loadtime = false;

        function zoomIN(i) {
            map.setCenter(gmarkers[i].getPoint(), 16);
        }

        //Zoom-Out Function 
        function zoomOUT(i) {
            // map.closeInfoWindow();
            // map.centerAndZoom(gmarkers[i].point, 4);
            map.centerAndZoomOnBounds(bounds);

        }


        // Create our "tiny" marker icon
        var icons = new Array();
        icons["red"] = new GIcon();
        icons["red"].image = "/_layouts/15/images/Sazmanyar.GIS/GoogleMap/mm_20_red.png";
        icons["red"].shadow = "/_layouts/15/images/Sazmanyar.GIS/GoogleMap/mm_20_shadow.png";
        icons["red"].iconSize = new GSize(12, 20);
        icons["red"].shadowSize = new GSize(22, 20);
        icons["red"].iconAnchor = new GPoint(6, 20);
        icons["red"].infoWindowAnchor = new GPoint(5, 1);
        icons["red"].imageMap = [4, 0, 0, 4, 0, 7, 3, 11, 4, 19, 7, 19, 8, 11, 11, 7, 11, 4, 7, 0];
        icons["red"].transparent = "mapIcons/mm_20_transparent.png";
        // these are for the "normal" marker
        // icons["red"].printImage="http://www.google.com/mapfiles/markerie.gif";
        // icons["red"].mozPrintImage="http://www.google.com/mapfiles/markerff.gif";
        // icons["red"].printShadow="http://www.google.com/mapfiles/dithshadow.gif";


        function get_icon(iconColor) {
            if ((typeof (iconColor) == "undefined") || (iconColor == null)) {
                iconColor = "red";
            }
            if (!icons[iconColor]) {
                icons[iconColor] = new GIcon(icons["red"]);
                icons[iconColor].image = "/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Marker/" + iconColor + "/marker.png";
            }
            return icons[iconColor];
        }


        // ==================================================
        // A function to create a tabbed marker and set up the event window
        // This version accepts a variable number of tabs, passed in the arrays htmls[] and labels[]
        function createTabbedMarker(point, label, tabs, icon, markerOpts) {
            // alert("cTM:"+point+" label:"+label+" icon:"+icon+" mO:"+markerOpts);
            var marker;
            if (markerOpts) {
                marker = new GMarker(point, markerOpts);
            } else if (icon != null) {
                marker = new GMarker(point, get_icon(icon));
            } else {
                marker = new GMarker(point);
            }
            var marker_num = gmarkers.length;
            marker.marker_num = marker_num;
            marker.tabs = tabs;
            gmarkers[marker_num] = marker;

            GEvent.addListener(gmarkers[marker_num], "click", function () {
                marker.openInfoWindowTabsHtml(gmarkers[marker_num].tabs);
            });

            if (markerOpts && markerOpts.draggable) {
                GEvent.addListener(marker, "dragstart", function () {
                    map.closeInfoWindow();
                });

                GEvent.addListener(marker, "dragend", function () {
                    marker.openInfoWindowHtml(marker.getPoint().toUrlValue());
                    earthtoolsUrl = "http://www.earthtools.org/height/" + marker.getPoint().lat() + "/" + marker.getPoint().lng();
                    request.open("GET", "xmlProxy060215.asp?" + earthtoolsUrl, true);
                    // request.open("GET", "http://ws.geonames.org/gtopo30JSON?lat="+point.lat()+"&lng="+point.lng(), true);
                    geonamesUrl = "http://ws.geonames.org/gtopo30?lat=" + point.lat() + "&lng=" + point.lng();
                    // request.open("GET", "xmlProxy060215.asp?"+geonamesUrl, true);
                    request.onreadystatechange = processEarthToolsXML;
                    // request.send(null);
                    // if (clickMarker) map.removeOverlay(clickMarker);
                    // alert("none")
                    var latLngStr = marker.getPoint().toUrlValue(); ;
                    // clickMarker = new GMarker(point,{title: latLngStr, draggable: true});
                    var tabLabel = "drag";
                    var tabHtml = "";
                    tabHtml += latLngStr + "<br>";
                    tabHtml += "<a href='javascript:map.closeInfoWindow(); map.removeOverlay(clickMarker);'>remove</a><br>";
                    tabHtml += "<a href='javascript:map.setCenter(clickMarker.getPoint(), 10);'>Zoom In</a> - ";
                    tabHtml += "<a href='javascript:map.centerAndZoomOnBounds(bounds);'>Zoom Out</a><br>";

                    tabs.push(new GInfoWindowTab(tabLabel, tabHtml));

                    // create the marker
                    // clickMarker = createTabbedMarker(point,"click",tabs, null, {title: latLngStr, draggable: true, icon:get_icon("red")});
                    marker.tabs = tabs;
                    // map.addOverlay(clickMarker);
                });
            }

            // add a line to the divSearchResult html
            divSearchResult_html += '<a href="javascript:myclick(' + marker_num + ')">' + label + '</a><br />';
            return marker;
        }
        // ==================================================
        function addTabToMarker(marker, tab) {
            marker.tabs.push(tab);
        }


        // This function picks up the click and opens the corresponding info window
        function myclick(i) {
            GEvent.trigger(gmarkers[i], "click");
        }

        function togglePoly(poly_num) {
            if (document.getElementById('poly' + poly_num)) {
                if (document.getElementById('poly' + poly_num).checked) {
                    gpolys[poly_num].show();
                    gpolys[poly_num].objmarker_StationFrom.show();
                    gpolys[poly_num].objmarker_StationTo.show();

                } else {
                    gpolys[poly_num].hide();
                    gpolys[poly_num].objmarker_StationFrom.hide();
                    gpolys[poly_num].objmarker_StationTo.hide();
                }
            }
        }

        function togglemarker(marker_num) {
            if (document.getElementById('marker' + marker_num)) {
                if (document.getElementById('marker' + marker_num).checked) {
                    gmarkers[marker_num].show();
                } else {
                    gmarkers[marker_num].hide();
                }
            }
        }

        var mapCenter, mapZoom;
        var copyright = new GCopyright(1, new GLatLngBounds(new GLatLng(-90, -180), new GLatLng(90, 180)), 0, 'Sazmanyar');
        var copyrightCollection = new GCopyrightCollection('Map Data:');
        copyrightCollection.addCopyright(copyright);
        CustomGetTileUrl = function (a, b) {
            return '/_layouts/15/images/Sazmanyar.GoogleMapOffline/Google Maps Image/' + b + '/' + a.x + '/' + a.y + '.png';
        };
        var tilelayers = [new GTileLayer(copyrightCollection, 1, 14)];
        tilelayers[0].getTileUrl = CustomGetTileUrl;
        var custommap = new GMapType(tilelayers, new GMercatorProjection(14), "Sazmanyar");
        map = new GMap(document.getElementById('map'), { mapTypes: [custommap] });
        map.addControl(new GLargeMapControl());
        map.addMapType(G_PHYSICAL_MAP);
        map.setCenter(new google.maps.LatLng(35.7150676237549, 51.3955078125), 6);
    }

    else {
        alert("Sorry, the Google Maps API is not compatible with this browser");
    }

   
    //]]>
</script>
