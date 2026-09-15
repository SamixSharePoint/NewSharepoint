<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="FilteredGoogleMapOfflineWebpartUserControl.ascx.cs" Inherits="Sazmanyar.GoogleMapOffline.FilteredGoogleMapOfflineWebpart.FilteredGoogleMapOfflineWebpartUserControl" %>
<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GoogleMapOffline/Script/css/gmo-ui.css" />
<script type="text/javascript" language="javascript" src="/_layouts/15/Sazmanyar.GoogleMapOffline/Script/js/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GoogleMapOffline/Script/js/gmo-ui.js" charset="utf-8"></script>
<script type="text/javascript" language="javascript" src="/_layouts/15/Sazmanyar.GoogleMapOffline/Script/js/json2.js"></script>
<div class="gmo-root">
<div id="pnlShowDetails" style="visibility: hidden">
    <div class="msg-modal" onclick="closeDetailInfo()">
    </div>
    <div class="msg-content">
        <div class="close" id="btnExit_Payam" onclick="closeDetailInfo()" title="بستن">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M6 6l12 12M18 6L6 18" /></svg>
        </div>
        <div id="pnl_title" class="title">
        </div>
        <div class="body">
            <div class="header">
                نمایش جزئیات
            </div>
            <div id="pnl_msgbody" class="gmo-iw">
            </div>
            <div class="footer">
            </div>
        </div>
    </div>
</div>
<%-- اسکریپت تولیدشده در کد پشت، روی ctl00_panelArrow مقدار .src و .title می‌نویسد؛ src روی button بی‌اثر است و
     حالت باز/بسته از روی title (که با «بستن» شروع می‌شود) در CSS تشخیص داده می‌شود. --%>
<div id="map_Search" runat="server" class="gmo-topbar">
    <input id="MyLocationMarkerHidden" type="hidden" runat="server" />
    <button type="button" id="ctl00_panelArrow" class="gmo-toggle" onclick="togglePanel();" title="بستن فرم جستجو">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="16" rx="2" /><path d="M15 4v16" /><path d="M6 9h5M6 13h5" /></svg>
        <span>پنل جستجو</span>
    </button>
    <button type="button" class="gmo-toggle gmo-fs-btn" onclick="gmoToggleFullscreen(this);" title="نمایش تمام‌صفحه">
        <svg class="gmo-fs-enter" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 9V4h5M20 9V4h-5M4 15v5h5M20 15v5h-5" /></svg><svg class="gmo-fs-exit" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 4v5H4M15 4v5h5M9 20v-5H4M15 20v-5h5" /></svg>
        <span class="gmo-fs-enter">تمام‌صفحه</span><span class="gmo-fs-exit">خروج از تمام‌صفحه</span>
    </button>
</div>
<div class="gmo-row">
    <div class="gmo-side">
        <div id="divRightOptions" class="gmo-panel" style="display: none;">
            <div id="PanelSearchOptions" class="gmo-panel-section">
                <div class="gmo-panel-head">
                    <span>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5h16l-6 8v6l-4-2v-4z" /></svg>
                        جستجو در نقشه
                    </span>
                </div>
                <div class="gmo-panel-body gmo-form">
                    <div id="pnlFilterPart" runat="server">
                        <table>
                            <tr>
                                <td colspan="2">
                                    <asp:Label ID="lblError" runat="server" ForeColor="Red" Text=""></asp:Label>
                                </td>
                            </tr>
                            <tr id="pnlSearch1" runat="server">
                                <td>
                                    <asp:Label ID="lblOnvanSearch1" runat="server" Text=""></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtMarekerSearch1" runat="server"></asp:TextBox>
                                </td>
                            </tr>
                            <tr id="pnlSearch2" runat="server">
                                <td>
                                    <asp:Label ID="lblOnvanSearch2" runat="server" Text=""></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtMarekerSearch2" runat="server"></asp:TextBox>
                                </td>
                            </tr>
                            <tr id="pnlSearch3" runat="server">
                                <td>
                                    <asp:Label ID="lblOnvanSearch3" runat="server" Text=""></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtMarekerSearch3" runat="server"></asp:TextBox>
                                </td>
                            </tr>
                            <tr id="pnlCheckList1" runat="server">
                                <td>
                                    <asp:Label ID="lblOnvanCheckList1" runat="server" Text=""></asp:Label>
                                </td>
                                <td>
                                    <asp:CheckBoxList ID="chlMarekerCheckList1" runat="server">
                                    </asp:CheckBoxList>
                                </td>
                            </tr>
                            <tr id="pnlCheckList2" runat="server">
                                <td>
                                    <asp:Label ID="lblOnvanCheckList2" runat="server" Text=""></asp:Label>
                                </td>
                                <td>
                                    <asp:CheckBoxList ID="chlMarekerCheckList2" runat="server">
                                    </asp:CheckBoxList>
                                </td>
                            </tr>
                            <tr id="pnlCheckList3" runat="server">
                                <td>
                                    <asp:Label ID="lblOnvanCheckList3" runat="server" Text=""></asp:Label>
                                </td>
                                <td>
                                    <asp:CheckBoxList ID="chlMarekerCheckList3" runat="server">
                                    </asp:CheckBoxList>
                                </td>
                            </tr>
                            <tr id="pnlFilter1" runat="server">
                                <td>
                                    <asp:Label ID="lblOnvanFilter1" runat="server" Text=""></asp:Label>
                                </td>
                                <td>
                                    <asp:DropDownList ID="cmbMarekerFilter1" runat="server">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr id="pnlFilter2" runat="server">
                                <td>
                                    <asp:Label ID="lblOnvanFilter2" runat="server" Text=""></asp:Label>
                                </td>
                                <td>
                                    <asp:DropDownList ID="cmbMarekerFilter2" runat="server">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr id="pnlFilter3" runat="server">
                                <td>
                                    <asp:Label ID="lblOnvanFilter3" runat="server" Text=""></asp:Label>
                                </td>
                                <td>
                                    <asp:DropDownList ID="cmbMarekerFilter3" runat="server">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="gmo-check-row">
                        <input id="ctl00_MainContent_CheckBoxOrderByLocation" type="checkbox" name="ctl00$MainContent$CheckBoxOrderByLocation"
                            onclick="CheckBoxOrderByLocationClick();" /><label for="ctl00_MainContent_CheckBoxOrderByLocation">مرتب‌سازی بر اساس نزدیکی به موقعیت آدمک</label>
                        <img alt="" src="/_layouts/15/images/Sazmanyar.GoogleMapOffline/Marker/iconMe.png"
                            title="برای قرار دادن نشانگر تعیین موقعیت در مرکز نمای فعلی کلیک کنید"
                            onclick="javascript:SetMyLocationMarkerInCenter()" />
                    </div>
                </div>
                <div class="gmo-panel-foot">
                    <button type="button" class="gmo-btn gmo-btn-primary gmo-btn-block" id="btnSearch" onclick="ButtonSearchClicked();" title="جستجو بر اساس نزدیکی به مرکز نقشه">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7" /><path d="M20 20l-3.5-3.5" /></svg>
                        <span>جستجو در نقشه</span>
                    </button>
                </div>
            </div>
            <div id="PanelSearchResult" class="gmo-panel-section" style="visibility: hidden">
                <div class="gmo-panel-head">
                    <span>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 21s7-6.2 7-11a7 7 0 1 0-14 0c0 4.8 7 11 7 11z" /><circle cx="12" cy="10" r="2.5" /></svg>
                        نتایج جستجو
                    </span>
                    <button type="button" class="gmo-btn" id="hazfePanelSearchResult" onclick="hazfPanelSearchResult();" title="حذف نتایج و بازگشت به صفحه جستجو">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 6l6 6-6 6" /></svg>
                        <span>بازگشت</span>
                    </button>
                </div>
                <div class="gmo-panel-body">
                    <div id="divSearchResult" class="gmo-list">
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div id="map_canvas" class="gmo-map">
    </div>
</div>
</div>
