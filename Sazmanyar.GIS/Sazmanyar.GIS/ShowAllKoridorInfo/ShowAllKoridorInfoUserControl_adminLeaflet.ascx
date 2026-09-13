<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ShowAllKoridorInfoUserControl_adminLeaflet.ascx.cs" Inherits="Sazmanyar.GIS.ShowAllKoridorInfo.ShowAllKoridorInfoUserControl_adminLeaflet" %>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-1.9.1.js"></script>
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
    .MainPanle {
        direction: rtl;
        text-align: right;
        width: 250px;
        position: absolute;
        top: 100px;
        right: 10px;
        background-color: #CCFFCC;
        /* لایه‌های داخلی Leaflet (کاشی‌ها، مارکرها، کنترل‌ها) از z-index بین 200 تا 1000
           استفاده می‌کنند؛ چون #map_canvas خودش z-index ندارد، آن لایه‌ها مستقیماً با این
           پنل رقابت می‌کنند. برای اینکه پنل همیشه روی نقشه بماند باید عددی خیلی بزرگ‌تر
           از بیشترین z-index داخلی Leaflet (1000) داشته باشد. */
        z-index: 10000;
    }

    /* لیست پیشنهادی autocomplete جی‌کوئری UI به‌صورت پیش‌فرض مستقیم به body اضافه می‌شود
       (نه داخل .MainPanle)، پس z-index بالای پنل رویش اثر ندارد و باید جدا و حتی بالاتر
       تنظیم شود تا زیر لایه‌های نقشهء Leaflet پنهان نماند. */
    .ui-autocomplete {
        z-index: 20000 !important;
    }
</style>

<asp:Literal runat="server" Id="InitializBounds" />

<div class="MainPanle">
    <fieldset>
        <legend>نمایش مسیر</legend>
        <table cellpadding="5" cellspacing="5" id="pnlShow" runat="server" width="100%">
            <tr>
                <td align="left">ایستگاه ابتدا:
                </td>
                <td>
                    <input id="txtSourceStation" type="text" style="width: 100px;" onkeyup="FillSugestion_NameStationFromAllStations(this)" />
                </td>
            </tr>
            <tr>
                <td align="left">ایستگاه انتها:
                </td>
                <td>
                    <input id="txtDesinationStation" type="text" style="width: 100px;" onkeyup="FillSugestion_NameStationFromAllStations(this)" />
                </td>
            </tr>
            <tr>
                <td align="left">نام پروژه:
                </td>
                <td>
                    <asp:DropDownList ID="cmbNameProjeh" class="NameProjeh" style="width: 150px;" runat="server">
                    </asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <label id="lblResult">
                    </label>
                </td>
            </tr>
            <tr>
                <td align="left" width="100px"></td>
                <td>
                    <input id="btnShowRout" style="width: 100px" type="button" onclick="ShowRoutInMap()"
                        value="نمایش مسیر" />
                </td>
            </tr>
        </table>
    </fieldset>
    <br />
    <fieldset>
        <legend>ثبت مسیر</legend>
        <table cellpadding="5" cellspacing="5" id="pnlConfig" runat="server" width="100%">
            <tr>
                <td>
                    <input id="txtNameCoridor" type="text" style="width: 90%" />
                </td>
            </tr>
            <tr>
                <td>
                    <input id="btnSubmit" style="width: 100px" type="button" onclick="SubmitRoutInMap()"
                        value="ثبت مسیر" />
                </td>
            </tr>
        </table>
    </fieldset>
</div>
<div id='map_canvas' style="border: medium solid #FFFFFF; width: 100%; height: 620px;">
</div>
