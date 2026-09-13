<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ShowAllKoridorInfoUserControl_adminLeaflet.ascx.cs" Inherits="Sazmanyar.GIS.ShowAllKoridorInfo.ShowAllKoridorInfoUserControl_adminLeaflet" %>
<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GIS/Script/css/gis-ui.css" />
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-1.9.1.js"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/gis-ui.js" charset="utf-8"></script>
<link rel="stylesheet" href="/_layouts/15/Sazmanyar.GIS/Script/css/jquery-ui-1.10.3.custom.min.css" />
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-ui-1.10.3.custom.min.js"></script>
<!-- این نسخه از کنترل به‌جای Google Maps (که نیاز به کارت اعتباری/Billing دارد) از
     Leaflet + OpenStreetMap برای نمایش نقشه و از Leaflet Routing Machine (با موتور
     رایگان و بدون کلید OSRM) برای کشیدن مسیر بین دو نقطه استفاده می‌کند. -->
<link rel="stylesheet" href="/_layouts/15/Sazmanyar.GIS/Leaflet/leaflet.css" />
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Leaflet/leaflet.js"></script>
<link rel="stylesheet" href="/_layouts/15/Sazmanyar.GIS/Leaflet/leaflet-routing-machine.css" />
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Leaflet/leaflet-routing-machine.js"></script>
<script src="/_layouts/15/Sazmanyar.GIS/Leaflet/BaseScriptForCoridorForAdminLeaflet.js"
    type="text/javascript"></script>
<script type="text/javascript" language="javascript">
    if ($("#DeltaPlaceHolderMain").find("div.DivBackground").length == 0) {

        $("#DeltaPlaceHolderMain").css({ "border-radius": "5px;", "box-shadow": "2px 2px 2px gray;" });

    } else {
        $("#DeltaPlaceHolderMain").css({ "background-color": "#e3e3f0 !important;" });

    }
</script>

<style type="text/css">
    /* لایه‌های داخلی Leaflet (کاشی‌ها، مارکرها، کنترل‌ها) از z-index بین 200 تا 1000
       استفاده می‌کنند و #map_canvas خودش z-index ندارد، پس آن لایه‌ها مستقیماً با
       .gis-reg-panel (که z-index: 10000 دارد، تعریف‌شده در gis-ui.css) رقابت می‌کنند؛
       عدد فعلی خیلی بزرگ‌تر از بیشترین z-index داخلی Leaflet است و کافی است.

       لیست پیشنهادی autocomplete جی‌کوئری UI به‌صورت پیش‌فرض مستقیم به body اضافه
       می‌شود (نه داخل .gis-reg-panel)، پس z-index بالای پنل رویش اثر ندارد و باید
       جدا و حتی بالاتر از پنل تنظیم شود تا زیر لایه‌های نقشه پنهان نماند. */
    .ui-autocomplete {
        z-index: 20000 !important;
    }
</style>

<asp:Literal runat="server" Id="InitializBounds" />

<div class="gis-reg-panel">
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
