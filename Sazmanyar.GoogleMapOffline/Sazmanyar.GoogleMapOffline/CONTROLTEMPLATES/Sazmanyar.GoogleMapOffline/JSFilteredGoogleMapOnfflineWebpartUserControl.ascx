<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=3.5.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %> 
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="JSFilteredGoogleMapOnfflineWebpartUserControl.ascx.cs" Inherits="Sazmanyar.GoogleMapOffline.CONTROLTEMPLATES.Sazmanyar.GoogleMapOffline.JSFilteredGoogleMapOnfflineWebpartUserControl" %>

<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GoogleMapOffline/Script/css/gmo-ui.css" />
<script type="text/javascript" lang="javascript" src="/_layouts/15/Sazmanyar.GoogleMapOffline/Script/js/jquery-1.3.2.min.js"></script>
<script type="text/javascript" lang="javascript" src="/_layouts/15/Sazmanyar.GoogleMapOffline/Script/js/json2.js"></script>
<script type="text/javascript">

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


    function FilterMarker() {

        var mapPointResult = {
            bindings: []
        };

        $('.chlMarekerCheckList').each(function (i, obj) {

            var TempmapPointResult = GetSelectedPoint_From_checkboxSelection(obj);
            if (TempmapPointResult != null) {
                for (var i = 0; i < TempmapPointResult.bindings.length; i++) {

                    var bShouldAdd = true;
                    for (var j = 0; j < mapPointResult.bindings.length; j++) {
                        if (mapPointResult.bindings[j].ID == TempmapPointResult.bindings[i].ID) {
                            bShouldAdd = false;
                        }
                    }
                    if (bShouldAdd == true) {
                        mapPointResult.bindings.push(TempmapPointResult.bindings[i]);
                    }
                }
            }
        });


        $('.cmbMarekerFilter').each(function (i, obj) {

            var TempmapPointResult = GetSelectedPoint_From_CmbBoxSelection(obj);
            if (TempmapPointResult != null) {
                for (var i = 0; i < TempmapPointResult.bindings.length; i++) {

                    var bShouldAdd = true;
                    for (var j = 0; j < mapPointResult.bindings.length; j++) {
                        if (mapPointResult.bindings[j].ID == TempmapPointResult.bindings[i].ID) {
                            bShouldAdd = false;
                        }
                    }
                    if (bShouldAdd == true) {
                        mapPointResult.bindings.push(TempmapPointResult.bindings[i]);
                    }
                }
            }
        });

        RefereshMarkerInfo(mapPointResult);
    }

    /*************************************************/
    function GetSelectedPoint_From_checkboxSelection(chkbox) {
        var mapPointResult = {
            bindings: []
        };

        try {

            if (mapPoints == null) { return null; }
            if (mapPoints.bindings == null) { return null; }

            var ColName = chkbox.getAttribute('InternalColName');

            var SelectedValues = getchlSelectedValues(chkbox).split("#@#");


            for (var i = 0; i < mapPoints.bindings.length; i++) {
                try {
                    for (var j = 0; j < SelectedValues.length; j++) {
                        if ((SelectedValues[j].toString().trim().length > 0) && (mapPoints.bindings[i][ColName].toString() == SelectedValues[j].toString())) {
                            mapPointResult.bindings.push(mapPoints.bindings[i]);
                            break;
                        }
                    }
                }
                catch (e) { }
            }


        } catch (e) {

        }
        return mapPointResult;
    }

    function GetSelectedPoint_From_CmbBoxSelection(CmbBox) {

        var mapPointResult = {
            bindings: []
        };

        try {
            if (mapPoints == null) { return null; }
            if (mapPoints.bindings == null) { return null; }
            if (CmbBox.selectedIndex < 1) { return null; }

            var ColName = CmbBox.getAttribute('InternalColName');

            for (var i = 0; i < mapPoints.bindings.length; i++) {
                try {
                    if (mapPoints.bindings[i][ColName].toString() == CmbBox.options[CmbBox.selectedIndex].value.toString()) {
                        mapPointResult.bindings.push(mapPoints.bindings[i]);
                    }
                }
                catch (e) { }
            }


        } catch (e) {

        }
        return mapPointResult;
    }
    /*************************************************/
    function checkboxSelection(chkbox) {
        try {

            if (mapPoints == null) { return null; }
            if (mapPoints.bindings == null) { return null; }

            var ColName = chkbox.getAttribute('InternalColName');

            var SelectedValues = getchlSelectedValues(chkbox).split("#@#");

            var mapPointResult = {
                bindings: []
            };

            for (var i = 0; i < mapPoints.bindings.length; i++) {
                try {
                    for (var j = 0; j < SelectedValues.length; j++) {
                        if ((SelectedValues[j].toString().trim().length > 0) && (mapPoints.bindings[i][ColName].toString() == SelectedValues[j].toString())) {
                            mapPointResult.bindings.push(mapPoints.bindings[i]);
                            break;
                        }
                    }
                }
                catch (e) { }
            }

            RefereshMarkerInfo(mapPointResult);

        } catch (e) {

        }
    }

    function CmbBoxSelection(CmbBox) {
        try {
            if (mapPoints == null) { return null; }
            if (mapPoints.bindings == null) { return null; }
            if (CmbBox.selectedIndex < 1) { return null; }

            var ColName = CmbBox.getAttribute('InternalColName');

            var mapPointResult = {
                bindings: []
            };

            for (var i = 0; i < mapPoints.bindings.length; i++) {
                try {
                    if (mapPoints.bindings[i][ColName].toString() == CmbBox.options[CmbBox.selectedIndex].value.toString()) {
                        mapPointResult.bindings.push(mapPoints.bindings[i]);
                    }
                }
                catch (e) { }
            }

            RefereshMarkerInfo(mapPointResult);

        } catch (e) {

        }
    }

</script>
<div id="pnlShouldHideCtrl" style="display: none; visibility: hidden">
    <div id="pnlShowDetails" style="visibility: hidden">
        <div class="msg-modal">
        </div>
        <div class="msg-content">
            <div class="close">
                <img alt="" id="btnExit_Payam" src="/_layouts/15/images/Sazmanyar.GoogleMapOffline/Search/msg-close.png"
                    style="text-align: left" onclick="closeDetailInfo()" />
            </div>
            <div class="body">
                <div id="pnl_title" class="title">
                </div>
                <div class="header">
                    نمایش جزئیات
                </div>
                <div id="pnl_msgbody">
                </div>
                <div class="footer">
                </div>
            </div>
        </div>
    </div>
    <div id='map_Search' runat="server" style="position: absolute; z-index: 2000000; padding-top: 30px; padding-right: 10px;">
        <input id="MyLocationMarkerHidden" type="hidden" runat="server" />
        <img alt="" src="/_layouts/15/images/Sazmanyar.GoogleMapOffline/Search/left-arrow.png"
            id="ctl00_panelArrow" style="cursor: pointer;" onclick="javascript:togglePanel();"
            title="بستن فرم جستجو" />
    </div>
    <table width="100%">
        <tr>
            <td valign="top">
                <div id="divRightOptions" style="display: none; border: solid 1px black; width: 300px; direction: rtl;">
                    <div id="PanelSearchOptions" style="position: absolute;">
                        <br />
                        <br />
                        <br />
                        <table cellpadding="0" cellspacing="0" style="margin-right: 5px;">
                            <tr>
                                <td colspan="2">
                                    <div id="pnlFilterPart" runat="server" align="center" style="width: 100%">
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <input id="ctl00_MainContent_CheckBoxOrderByLocation" type="checkbox" name="ctl00$MainContent$CheckBoxOrderByLocation"
                                        onclick="CheckBoxOrderByLocationClick();" /><label for="ctl00_MainContent_CheckBoxOrderByLocation">مرتب
                                            سازی بر اساس نزدیکی به موقعیت آدمک</label>
                                </td>
                                <td>
                                    <img alt="" src="/_layouts/15/images/Sazmanyar.GoogleMapOffline/Marker/iconMe.png"
                                        style="margin-top: 10px; cursor: pointer" align="middle" title="برای قرار دادن نشانگر تعیین موقعیت در مرکز نمای فعلی کلیک کنید"
                                        onclick="javascript:SetMyLocationMarkerInCenter()" />
                                </td>
                            </tr>
                        </table>
                        <input type="button" style="text-align: right; width: 140px; background-image: url('/_layouts/15/images/Sazmanyar.GoogleMapOffline/Search/search_network.png'); background-repeat: no-repeat; height: 40px;"
                            value="جستجو در نقشه" id="btnSearch"
                            onclick="ButtonSearchClicked();" title="جستجو بر اساس نزدیکی به مرکز نقشه" />
                    </div>
                    <div id="PanelSearchResult">
                        <br />
                        <br />
                        <table width="100%">
                            <tr>
                                <td align="left">
                                    <input type="button" style="text-align: right; width: 140px; background-image: url('/_layouts/15/images/Sazmanyar.GoogleMapOffline/Search/Back.png'); background-repeat: no-repeat; height: 40px;"
                                        value="حذف نتایج جستجو" id="hazfePanelSearchResult"
                                        onclick="hazfPanelSearchResult();" title="حذف نتایج و بازگشت به صفحه جستجو" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div id="divSearchResult" style="font-size: 0.9em; overflow: auto;">
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </td>
            <td valign="top" style="width: 100%"></td>
        </tr>
    </table>
</div>
<div class="gmo-topbar gmo-form gmo-form-inline">
    <table>
        <tr>
            <td colspan="2">
                <asp:Label ID="lblError" runat="server" ForeColor="Red" Text=""></asp:Label>
            </td>
        </tr>
        <tr id="pnlSearch1" runat="server">
            <td class="gmo-form-label">
                <asp:Label ID="lblOnvanSearch1" runat="server" Text=""></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtMarekerSearch1" runat="server"></asp:TextBox>
            </td>
        </tr>
        <tr id="pnlSearch2" runat="server">
            <td class="gmo-form-label">
                <asp:Label ID="lblOnvanSearch2" runat="server" Text=""></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtMarekerSearch2" runat="server"></asp:TextBox>
            </td>
        </tr>
        <tr id="pnlSearch3" runat="server">
            <td class="gmo-form-label">
                <asp:Label ID="lblOnvanSearch3" runat="server" Text=""></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtMarekerSearch3" runat="server"></asp:TextBox>
            </td>
        </tr>
        <tr id="pnlCheckList1" runat="server">
            <td class="gmo-form-label">
                <asp:Label ID="lblOnvanCheckList1" runat="server" Text=""></asp:Label>
            </td>
            <td>
                <asp:CheckBoxList ID="chlMarekerCheckList1" runat="server" RepeatDirection="Horizontal"
                    onclick="FilterMarker()" class="chlMarekerCheckList">
                </asp:CheckBoxList>
            </td>
        </tr>
        <tr id="pnlCheckList2" runat="server">
            <td class="gmo-form-label">
                <asp:Label ID="lblOnvanCheckList2" runat="server" Text=""></asp:Label>
            </td>
            <td>
                <asp:CheckBoxList ID="chlMarekerCheckList2" RepeatDirection="Horizontal" runat="server"
                    onclick="FilterMarker()" class="chlMarekerCheckList">
                </asp:CheckBoxList>
            </td>
        </tr>
        <tr id="pnlCheckList3" runat="server">
            <td class="gmo-form-label">
                <asp:Label ID="lblOnvanCheckList3" runat="server" Text=""></asp:Label>
            </td>
            <td>
                <asp:CheckBoxList ID="chlMarekerCheckList3" RepeatDirection="Horizontal" runat="server"
                    onclick="FilterMarker()" class="chlMarekerCheckList">
                </asp:CheckBoxList>
            </td>
        </tr>
        <tr id="pnlFilter1" runat="server">
            <td class="gmo-form-label">
                <asp:Label ID="lblOnvanFilter1" runat="server" Text=""></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="cmbMarekerFilter1" runat="server" onchange="FilterMarker();"
                    class="cmbMarekerFilter">
                </asp:DropDownList>
            </td>
        </tr>
        <tr id="pnlFilter2" runat="server">
            <td class="gmo-form-label">
                <asp:Label ID="lblOnvanFilter2" runat="server" Text=""></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="cmbMarekerFilter2" runat="server" onchange="FilterMarker();"
                    class="cmbMarekerFilter">
                </asp:DropDownList>
            </td>
        </tr>
        <tr id="pnlFilter3" runat="server">
            <td class="gmo-form-label">
                <asp:Label ID="lblOnvanFilter3" runat="server" Text=""></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="cmbMarekerFilter3" runat="server" onchange="FilterMarker();"
                    class="cmbMarekerFilter">
                </asp:DropDownList>
            </td>
        </tr>
    </table>
</div>
<div id="map_canvas" class="gmo-map">
</div>
