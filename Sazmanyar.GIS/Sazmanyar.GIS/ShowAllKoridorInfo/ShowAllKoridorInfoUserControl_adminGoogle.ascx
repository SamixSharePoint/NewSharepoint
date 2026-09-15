<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ShowAllKoridorInfoUserControl_adminGoogle.ascx.cs" Inherits="Sazmanyar.GIS.ShowAllKoridorInfo.ShowAllKoridorInfoUserControl_adminGoogle" %>
<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GIS/Script/css/gis-ui.css?v=20260915" />
<script src='/_layouts/15/Sazmanyar.GoogleMapOffline/Script/js/DrowMarker.js' type='text/javascript'> </script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-1.9.1.js"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/gis-ui.js?v=20260915" charset="utf-8"></script>
<link rel="stylesheet" href="/_layouts/15/Sazmanyar.GIS/Script/css/jquery-ui-1.10.3.custom.min.css" />
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-ui-1.10.3.custom.min.js"></script>
<%-- کلید Google Maps API از پراپرتی وب‌پارت (بخش «تنظیمات ویژه» → «کلید Google Maps API») خوانده می‌شود
     تا مدیر سایت بتواند بدون تغییر کد، کلید خودش را جایگزین کند. این نقشه به کلید معتبر با Billing
     فعال نیاز دارد؛ اگر کلید ندارید از کنترل «admin (نقشهء رایگان Leaflet)» استفاده کنید. --%>
<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?key=<%= GoogleMapsApiKey %>"></script>
<script src='/_layouts/15/Sazmanyar.GIS/Script/js/DrowSnapShotMarker.js' type='text/javascript'> </script>
<script src="/_layouts/15/Sazmanyar.GIS/GoogleMap/BaseScriptForCoridorForAdmin.js"
    type="text/javascript"></script>
<script type="text/javascript" language="javascript">
    if ($("#DeltaPlaceHolderMain").find("div.DivBackground").length == 0) {

        $("#DeltaPlaceHolderMain").css({ "border-radius": "5px;", "box-shadow": "2px 2px 2px gray;" });

    } else {
        $("#DeltaPlaceHolderMain").css({ "background-color": "#e3e3f0 !important;" });

    }



    if (typeof ($) != 'undefined') {
        $(document).ready(function () {

        });
    }

    function initializeGMapForKoridorInfo(result, CurrentColor) {
        var points = [];
        var BaseColor = '#00b2ff';
        if (typeof (CurrentColor) != 'undefined' && CurrentColor != null) {
            BaseColor = CurrentColor;
        }
        if (typeof (result[0].Color) != 'undefined' && result[0].Color != null) {
            BaseColor = result[0].Color;
        }
        for (var i = 0, len = result.length; i < len; i++) {
            var point = new google.maps.LatLng(result[i].lat, result[i].lng);
            var Color = '#00b2ff';
            if (typeof (result[i].Color) != 'undefined' && result[i].Color != null) {
                Color = result[i].Color;
            }
            if (Color != BaseColor) {
                points.push(point);
                if (points.length == 1) {
                    var Lastpoint = new google.maps.LatLng(result[i - 1].lat, result[i - 1].lng);
                    points.push(Lastpoint);
                }
                var polyline = new google.maps.Polyline(points, BaseColor, 5, 1);
                polyline.setMap(map);
                points = [];
                points.push(point);
                BaseColor = Color;
            }
            else {
                points.push(point);
            }
        }

        if (points.length > 0) {
            var polyline = new google.maps.Polyline(points, BaseColor, 5, 1);
            map.addOverlay(polyline);
        }

    }

</script>

<%-- گوگل‌مپ نسخهء زنده (v3) با کلید فوق لود می‌شود؛ لایه‌های داخلی آن معمولاً z-index پایین‌تری
     نسبت به Leaflet دارند، ولی همان عدد بزرگ .gis-reg-panel (در gis-ui.css) کافی است. --%>

<asp:Literal runat="server" Id="InitializBounds" />

<div class="gis-root gis-root-map">
<div class="gis-reg-panel">
    <div class="gis-reg-tools">
        <button type="button" class="gis-reg-tool gis-fs-btn" onclick="gisToggleFullscreen(this);" title="نمایش تمام‌صفحه">
            <svg class="gis-fs-enter" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 9V4h5M20 9V4h-5M4 15v5h5M20 15v5h-5" /></svg><svg class="gis-fs-exit" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 4v5H4M15 4v5h5M9 20v-5H4M15 20v-5h5" /></svg>
            <span class="gis-fs-enter">تمام‌صفحه</span><span class="gis-fs-exit">خروج از تمام‌صفحه</span>
        </button>
    </div>
    <div class="gis-reg-header">
        <div class="gis-reg-field">
            <label for="<%= cmbNameProjeh.ClientID %>">نام پروژه</label>
            <asp:DropDownList ID="cmbNameProjeh" CssClass="NameProjeh" runat="server">
            </asp:DropDownList>
        </div>
    </div>

    <div class="gis-reg-section">
        <div class="gis-reg-section-title">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="5" cy="18" r="2" /><circle cx="19" cy="6" r="2" /><path d="M7 17.5c4 0 4-11 8-11h2" /></svg>
            <span>نمایش مسیر</span>
        </div>
        <div class="gis-reg-body" id="pnlShow">
            <div class="gis-reg-field">
                <label for="txtSourceStation">ایستگاه ابتدا</label>
                <input id="txtSourceStation" type="text" onkeyup="FillSugestion_NameStationFromAllStations(this)" placeholder="نام ایستگاه..." />
            </div>
            <div class="gis-reg-field">
                <label for="txtDesinationStation">ایستگاه انتها</label>
                <input id="txtDesinationStation" type="text" onkeyup="FillSugestion_NameStationFromAllStations(this)" placeholder="نام ایستگاه..." />
            </div>
            <div id="lblResult" class="gis-reg-hint"></div>
            <button type="button" id="btnShowRout" class="gis-reg-btn" onclick="ShowRoutInMap()">نمایش مسیر</button>
        </div>
    </div>

    <div class="gis-reg-section">
        <div class="gis-reg-section-title">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M5 12h14" /></svg>
            <span>ثبت مسیر</span>
        </div>
        <div class="gis-reg-body" id="pnlConfig">
            <div class="gis-reg-field">
                <label for="txtNameCoridor">نام مسیر</label>
                <input id="txtNameCoridor" type="text" placeholder="نام مسیر..." />
            </div>
            <button type="button" id="btnSubmit" class="gis-reg-btn gis-reg-btn-primary" onclick="SubmitRoutInMap()">ثبت مسیر</button>
        </div>
    </div>
</div>
<div id='map_canvas' style="border: medium solid #FFFFFF; width: 100%; height: 620px;">
</div>
</div>
