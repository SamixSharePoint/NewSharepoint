<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ShowAllMapSheetsUserControl_admin.ascx.cs" Inherits="Sazmanyar.GIS.ShowAllMapSheets.ShowAllMapSheetsUserControl_admin" %>
<%--
    برگه‌های نقشه - حالت ادمین
    ---------------------------
    * بارگذاری ZIP شامل Shapefile کارفرما (shp + dbf + prj + cpg) با postback سرور، خواندن با ClsShapefile،
      ثبت در dbo.MapSheets با ClsHelpper.ImportMapSheets (upsert روی شمارهء برگه).
    * فهرست Importهای قبلی با امکان نمایش هر Import روی نقشه یا حذف کامل آن.
    * نقشه و فهرست برگه‌ها: mapsheets.js (مشترک با کنترل کاربر نهایی).
--%>
<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GIS/Script/css/gis-ui.css?v=20260915" />
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-1.7.1.min.js" type="text/javascript"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/gis-ui.js?v=20260915" charset="utf-8"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/GoogleMap/GISBase.js"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/mapsheets.js?v=20260920" charset="utf-8"></script>

<style type="text/css">
    .gm-style-mtc {
        display: none;
    }

    .gis-root .gis-reg-panel {
        max-height: 620px;
        overflow-y: auto;
    }

    .gis-root .ms-file {
        width: 100%;
        font-size: 12px;
    }

    .gis-root .ms-check {
        font-size: 12px;
        cursor: pointer;
    }

        .gis-root .ms-check input {
            vertical-align: middle;
            margin: 0 0 0 4px;
        }

    .gis-root .ms-result {
        margin-top: 8px;
        font-size: 12px;
        line-height: 1.8;
    }

        .gis-root .ms-result .ms-ok {
            color: #166534;
        }

        .gis-root .ms-result .ms-err {
            color: #b91c1c;
        }

        .gis-root .ms-result .ms-warn {
            color: #92400e;
        }

    .gis-root .ms-log {
        max-height: 180px;
        overflow-y: auto;
        border: 1px solid #e5e7eb;
        border-radius: 6px;
        padding: 4px 8px;
        margin-top: 4px;
        background: #f9fafb;
        font-size: 11px;
        line-height: 1.7;
    }

    .gis-root table.ms-batches {
        width: 100%;
        border-collapse: collapse;
        font-size: 11px;
    }

        .gis-root table.ms-batches th,
        .gis-root table.ms-batches td {
            border-bottom: 1px solid #e5e7eb;
            padding: 4px 3px;
            text-align: right;
            vertical-align: top;
        }

        .gis-root table.ms-batches th {
            color: #6b7280;
            font-weight: normal;
            white-space: nowrap;
        }

        .gis-root table.ms-batches .ms-num {
            text-align: center;
            white-space: nowrap;
        }

        .gis-root table.ms-batches .ms-bad {
            color: #b91c1c;
            font-weight: bold;
        }

        .gis-root table.ms-batches a,
        .gis-root table.ms-batches button {
            font-size: 11px;
            cursor: pointer;
            white-space: nowrap;
        }

    .gis-root .gis-iw-pwa {
        max-height: 360px;
        overflow-y: auto;
        min-width: 360px;
    }

        .gis-root .gis-iw-pwa h4 {
            margin: 0 0 6px 0;
            font-size: 13px;
        }

        .gis-root .gis-iw-pwa .pwa-item {
            border-top: 1px solid #e5e7eb;
            padding: 6px 2px;
        }

            .gis-root .gis-iw-pwa .pwa-item:first-of-type {
                border-top: none;
            }

        .gis-root .gis-iw-pwa .pwa-name {
            font-weight: bold;
            margin-bottom: 3px;
        }

        .gis-root .gis-iw-pwa .pwa-badge {
            display: inline-block;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-left: 5px;
            vertical-align: middle;
        }

        .gis-root .gis-iw-pwa table {
            border-collapse: collapse;
            width: 100%;
            font-size: 12px;
        }

        .gis-root .gis-iw-pwa td {
            padding: 1px 4px;
            vertical-align: top;
            white-space: nowrap;
        }

            .gis-root .gis-iw-pwa td.lbl {
                color: #6b7280;
            }

    .gis-root .gis-item.is-selected {
        background: #eff6ff;
        border-radius: 6px;
    }
</style>

<script type="text/javascript">
    if (typeof ($) != 'undefined') {
        $(document).ready(function () {
            msInitMap('map_canvas');
            GUnload();
            var focus = document.getElementById('<%= hdnFocusBatch.ClientID %>');
            msLoad('', '', focus ? focus.value : '', null);
        });
    }

    function msShowBatch(batch) {
        var focus = document.getElementById('<%= hdnFocusBatch.ClientID %>');
        if (focus) { focus.value = batch || ''; }
        msLoad('', '', batch || '', null);
    }

    function msBeforeImport() {
        var f = document.getElementById('<%= fupZip.ClientID %>');
        if (!f || !f.value) {
            alert('ابتدا فایل ZIP را انتخاب کنید.');
            return false;
        }
        if (!/\.zip$/i.test(f.value)) {
            alert('فقط فایل ZIP پذیرفته می‌شود (شامل shp، dbf، prj و cpg).');
            return false;
        }
        var btn = document.getElementById('<%= btnImport.ClientID %>');
        if (btn) { btn.value = 'در حال بارگذاری...'; }
        return true;
    }
</script>

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
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3v12M7 10l5 5 5-5" /><path d="M4 17v3h16v-3" /></svg>
                <span>بارگذاری برگه‌های نقشه (Shapefile)</span>
            </div>
            <div class="gis-reg-body">
                <div class="gis-reg-field">
                    <label for="<%= fupZip.ClientID %>">فایل ZIP کارفرما</label>
                    <asp:FileUpload ID="fupZip" runat="server" CssClass="ms-file" accept=".zip,application/zip,application/x-zip-compressed" />
                </div>
                <div class="gis-reg-field">
                    <label class="ms-check">
                        <asp:CheckBox ID="chkOverwrite" runat="server" />
                        بازنویسی برگه‌هایی که از قبل ثبت شده‌اند
                    </label>
                </div>
                <div class="gis-reg-hint">
                    ZIP باید فایل‌های <b>shp</b>، <b>dbf</b>، <b>prj</b> و <b>cpg</b> یک لایهء Polygon را داشته باشد.
                    ستون <b>P_Code</b> جدول صفت‌ها کلید اتصال به پروژه‌های PWA است و ستون <b>N50</b> شمارهء برگه.
                    مختصات UTM هنگام ثبت به عرض/طول جغرافیایی تبدیل می‌شود.
                </div>
                <asp:Button ID="btnImport" runat="server" Text="بارگذاری و ثبت در MapSheets" CssClass="gis-reg-btn gis-reg-btn-primary" OnClientClick="return msBeforeImport();" OnClick="btnImport_Click" />
                <asp:HiddenField ID="hdnFocusBatch" runat="server" />
                <div class="ms-result">
                    <asp:Literal ID="litResult" runat="server"></asp:Literal>
                </div>
            </div>
        </div>

        <div class="gis-reg-section">
            <div class="gis-reg-section-title">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="16" rx="2" /><path d="M3 10h18M9 4v16" /></svg>
                <span>بارگذاری‌های ثبت‌شده</span>
            </div>
            <div class="gis-reg-body">
                <asp:Panel ID="pnlNoBatches" runat="server" CssClass="gis-reg-hint">هنوز هیچ برگه‌ای ثبت نشده است.</asp:Panel>
                <asp:Repeater ID="rptBatches" runat="server" OnItemCommand="rptBatches_ItemCommand">
                    <HeaderTemplate>
                        <table class="ms-batches">
                            <tr>
                                <th>تاریخ</th>
                                <th>فایل / لایه</th>
                                <th class="ms-num" title="تعداد برگه">برگه</th>
                                <th class="ms-num" title="برگه‌هایی که کد پروژه ندارند یا کدشان در PWAInfo نیست">بدون پروژه</th>
                                <th></th>
                            </tr>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td title='<%# Eval("ImportedBy") %>'><%# FormatDate(Eval("ImportedAt")) %></td>
                            <td><%# Server.HtmlEncode(Convert.ToString(Eval("SourceFile"))) %><br /><span class="gis-hint"><%# Server.HtmlEncode(Convert.ToString(Eval("SourceLayer"))) %></span></td>
                            <td class="ms-num"><%# Eval("Sheets") %></td>
                            <td class='<%# BadClass(Eval("WithoutCode"), Eval("NotInPwa")) %>'><%# BadCount(Eval("WithoutCode"), Eval("NotInPwa")) %></td>
                            <td class="ms-num">
                                <button type="button" class="gis-reg-tool" onclick='msShowBatch("<%# Eval("ImportBatch") %>");' title="فقط برگه‌های این بارگذاری روی نقشه">نمایش</button>
                                <asp:LinkButton ID="lnkDelete" runat="server" CssClass="gis-reg-tool" CommandName="DeleteBatch" CommandArgument='<%# Eval("ImportBatch") %>' OnClientClick='<%# "return confirm(\"همهء " + Eval("Sheets") + " برگهء این بارگذاری حذف شود؟\");" %>' ToolTip="حذف همهء برگه‌های این بارگذاری">حذف</asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
                <div class="gis-reg-hint" style="margin-top: 6px;">
                    <button type="button" class="gis-reg-tool" onclick="msShowBatch('');">نمایش همهء برگه‌ها</button>
                </div>
            </div>
        </div>

        <div class="gis-reg-section">
            <div class="gis-reg-section-title">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 8l7-4 9 5-3 10-10-1z" /></svg>
                <span>برگه‌های روی نقشه</span>
            </div>
            <div class="gis-reg-body">
                <div class="gis-panel-head">
                    <div id="divMsCount" class="gis-counts"></div>
                    <div class="gis-toolbar">
                        <button type="button" class="gis-tool gis-tool-text" onclick="msSetAllVisible('all');" title="نمایش همه"><span>همه</span></button>
                        <button type="button" class="gis-tool gis-tool-text" onclick="msSetAllVisible('invert');" title="معکوس"><span>معکوس</span></button>
                        <button type="button" class="gis-tool gis-tool-text gis-tool-danger" onclick="msSetAllVisible('none');" title="مخفی کردن همه"><span>هیچ</span></button>
                    </div>
                </div>
                <div id="divMsList" class="gis-list"></div>
                <div class="gis-legend" style="margin-top: 6px;">
                    <span class="gis-legend-title">تحقق پروژه:</span>
                    <span class="gis-legend-item"><i style="background: #22c55e"></i>بیش از ۹۰٪</span>
                    <span class="gis-legend-item"><i style="background: #facc15"></i>۷۰ تا ۹۰٪</span>
                    <span class="gis-legend-item"><i style="background: #f472b6"></i>۵۰ تا ۷۰٪</span>
                    <span class="gis-legend-item"><i style="background: #ef4444"></i>کمتر از ۵۰٪</span>
                    <span class="gis-legend-item"><i style="background: #9ca3af"></i>آغاز نشده</span>
                    <span class="gis-legend-item"><i style="background: #64748b"></i>بدون پروژه در PWA</span>
                </div>
            </div>
        </div>
    </div>
    <div id="map_canvas" style="border: medium solid #FFFFFF; width: 100%; height: 620px;">
    </div>
</div>
