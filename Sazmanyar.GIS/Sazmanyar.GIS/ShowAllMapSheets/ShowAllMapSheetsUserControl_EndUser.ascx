<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ShowAllMapSheetsUserControl_EndUser.ascx.cs" Inherits="Sazmanyar.GIS.ShowAllMapSheets.ShowAllMapSheetsUserControl_EndUser" %>
<%--
    برگه‌های نقشه - حالت کاربر نهایی
    ---------------------------------
    فقط نمایش برگه‌های ثبت‌شده در dbo.MapSheets روی نقشه (mapsheets.js):
      * جستجو با بخشی از شمارهء برگه / نام برگه یا کد پروژه (وب‌متد FetchMapSheets)
      * کمبوی انتخاب برگه برای فیت‌شدن نقشه و باز شدن InfoWindow
      * رنگ برگه = دستهء تحقق پروژهء متصل در PWAInfo؛ برگهء بدون پروژه خاکستری-آبی
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
            msSearch();
        });
    }

    function msSearch() {
        var sheet = document.getElementById('txtMsSheet').value;
        var code = document.getElementById('txtMsProjectCode').value;
        msLoad(sheet, code, '', function () { msFillCombo('cmbMsSheet'); });
    }

    function msResetSearch() {
        document.getElementById('txtMsSheet').value = '';
        document.getElementById('txtMsProjectCode').value = '';
        msSearch();
    }

    function msSearchKey(e) {
        if (e && e.keyCode == 13) { msSearch(); return false; }
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
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7" /><path d="M20 20l-4-4" /></svg>
                <span>جستجوی برگه</span>
            </div>
            <div class="gis-reg-body">
                <div class="gis-reg-field">
                    <label for="txtMsSheet">شماره یا نام برگه</label>
                    <input id="txtMsSheet" type="text" placeholder="مثلاً 7352 یا راور" onkeypress="return msSearchKey(event);" />
                </div>
                <div class="gis-reg-field">
                    <label for="txtMsProjectCode">کد پروژه (PWA)</label>
                    <input id="txtMsProjectCode" type="text" placeholder="مثلاً 140411094252" onkeypress="return msSearchKey(event);" />
                </div>
                <button type="button" class="gis-reg-btn gis-reg-btn-primary" onclick="msSearch();">جستجو</button>
                <button type="button" class="gis-reg-btn" onclick="msResetSearch();">همهء برگه‌ها</button>
                <div class="gis-reg-field" style="margin-top: 8px;">
                    <label for="cmbMsSheet">انتخاب برگه</label>
                    <select id="cmbMsSheet" onchange="msComboChanged(this);"></select>
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
