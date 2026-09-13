<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ShowAllKoridorInfoUserControl_admin.ascx.cs" Inherits="Sazmanyar.GIS.ShowAllKoridorInfo.ShowAllKoridorInfoUserControl_admin" %>
<script src='/_layouts/15/Sazmanyar.GoogleMapOffline/Script/js/DrowMarker.js' type='text/javascript'> </script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-1.9.1.js"></script>
<link rel="stylesheet" href="/_layouts/15/Sazmanyar.GIS/Script/css/jquery-ui-1.10.3.custom.min.css" />
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-ui-1.10.3.custom.min.js"></script>
<script type="text/javascript" src="http://maps.googleapis.com/maps/api/js?key=AIzaSyBk2zY1PsSNsYBAFC7Gi-qCbTm4rvvAo_g"></script>
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

<style type="text/css">
    .MainPanle {
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

