<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> 
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> 
<%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %> 
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ShowAllKoridorInfoUserControl_ViewRouts.ascx.cs" Inherits="Sazmanyar.GIS.ShowAllKoridorInfo.ShowAllKoridorInfoUserControl_ViewRouts" %>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-1.9.1.js"></script>
<link rel="stylesheet" href="/_layouts/15/Sazmanyar.GIS/Script/css/jquery-ui-1.10.3.custom.min.css" />
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-ui-1.10.3.custom.min.js"></script>
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/BaseScriptForCoridorForEndUser.js"
    type="text/javascript"></script>
<script src='/_layouts/15/Sazmanyar.GoogleMapOffline/Script/js/DrowMarker.js' type='text/javascript'> </script>
<script type="text/javascript" language="javascript">
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
            var point = new GLatLng(result[i].lat, result[i].lng);
            var Color = '#00b2ff';
            if (typeof (result[i].Color) != 'undefined' && result[i].Color != null) {
                Color = result[i].Color;
            }
            if (Color != BaseColor) {
                points.push(point);
                if (points.length == 1) {
                    var Lastpoint = new GLatLng(result[i - 1].lat, result[i - 1].lng);
                    points.push(Lastpoint);
                }
                var polyline = new GPolyline(points, BaseColor, 5, 1);
                map.addOverlay(polyline);
                points = [];
                points.push(point);
                BaseColor = Color;
            }
            else {
                points.push(point);
            }
        }

        if (points.length > 0) {
            var polyline = new GPolyline(points, BaseColor, 5, 1);
            map.addOverlay(polyline);
        }

    } 
</script>
<style type="text/css">
    .MainPanle
    {
        direction: rtl;
        text-align: right;
        width: 250px;
        position: absolute;
        top: 100px;
        right: 10px;
        background-color: #CCFFCC;
        z-index: 1;
    }
</style>

<asp:Literal runat="server" Id="InitializBounds" />

<div class="MainPanle">
    <fieldset>
        <legend>نمایش مسیر</legend>
        <table cellpadding="5" cellspacing="5" id="pnlShow" runat="server" width="100%">
            <tr>
                <td align="left">
                    ایستگاه ابتدا:
                </td>
                <td>
                    <select id="cmbFromStation" style="width: 100px" onchange="FillCmbToStationInfo(this);">
                    </select>
                </td>
            </tr>
            <tr>
                <td align="left">
                    ایستگاه انتها:
                </td>
                <td>
                    <select id="cmbToStation" style="width: 100px">
                    </select>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <label id="lblResult">
                    </label>
                </td>
            </tr>
            <tr>
                <td align="left">
                </td>
                <td>
                    <input id="btnShowRout" style="width: 100px" type="button" onclick="ShowRoutInMap()"
                        value="نمایش مسیر" />
                </td>
            </tr>
        </table>
    </fieldset>
</div>
<script type="text/javascript" language="javascript">
    if (typeof ($) != 'undefined') {
        $(document).ready(function () {
            FillCmbFromStationInfo();
        });

    }
</script>
