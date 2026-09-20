<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ShowAllMapSheetInfoUserControl.ascx.cs" Inherits="Sazmanyar.GIS.ShowAllMapSheetInfo.ShowAllMapSheetInfoUserControl" %>

<%--
    برگه‌های نقشه (جدول MapSheets + پروژهء متصل از PWAInfo)
    ----------------------------------------------------------
    الگو: ShowAllProjectInfoUserControl (ریبون بالای نقشه + پنل کناری + جستجوی پیشرفته با query-builder)
      * ریبون: تمام‌صفحه، فهرست برگه‌ها، ثبت برگه (فقط ادمین)، جستجوی پیشرفته، حذف شرایط،
               کمبوی «منطقه پروژه» و فیلد «برگه» با پیشنهاد خودکار، شفافیت سطح‌ها و راهنمای رنگ
      * پنل ثبت: بارگذاری ZIP شامل Shapefile (postback سرور)، نتیجهء سطر‌به‌سطر، فهرست بارگذاری‌ها (نمایش / حذف)
      * پنل جستجو: فهرست برگه‌ها با چک‌باکس نمایش/مخفی، همه / معکوس / هیچ
      * جستجوی پیشرفته: FilterMapSheet.html داخل fancybox؛ شرط SQL به وب‌متد FetchMapSheets می‌رود
    رفتار نقشه:
      * هر برگه یک چندضلعی واقعی (از Boundary ذخیره‌شده) + یک پین روی مرکز برگه
      * رنگ = دستهء تحقق میانگین همهء سطرهای PWAInfo با کد آن برگه (ستون PwaRows؛ پروژهء چندنوعی = چند سطر، همان فرمول
        pwaCategory در ShowAllProjectInfo)؛ دستهء ششم «بدون پروژه»: خاکستری‌آبی
      * پنجرهء اطلاعات: یک سطر = بدون تب؛ چند سطر = یک تب برای هر سطر (برچسب تب: نوع پروژه) مثل پین‌های ShowAllProjectInfo
      * پین هر برگه آیکون «برگهء نقشه» (SVG درون‌خطی) با همان رنگ دسته است تا از پین پروژه‌های PWA متمایز باشد؛
        برگهء چندپروژه‌ای (چند سطر PWA) آیکون «دستهء برگه» (چند برگهء روی هم) با نشان تعداد می‌گیرد
      * کلیک روی سطح یا پین: انتخاب (هایلایت) + پنجرهء اطلاعات برگه و پروژه
      * خوشه‌بندی سه‌سطحی وابسته به زوم (چک‌باکس «خوشه‌بندی» و اسلایدر «زوم تک‌برگه» در ریبون):
          - زوم نزدیک (>= زوم تک‌برگه): هر برگه با سطح و پین خودش
          - زوم میانی (دو پله پایین‌تر): برگه‌های یک «برگهء مادر 1:100000» (SheetSeries) یک نشانگر شمارنده می‌گیرند؛ سطح‌ها می‌مانند
          - زوم دور: برگه‌های نزدیک هم (آستانهء پیکسلی) یک نشانگر شمارنده می‌شوند و سطح‌ها پنهان می‌شوند
        کلیک روی نشانگر خوشه: زوم به محدودهء اعضا؛ در بیشترین زوم فهرست اعضا
--%>

<style type="text/css">
    #s4-leftpanel {
        display: none;
    }

    .s4-ca {
        margin-right: 0px;
    }

    .s4-title {
        display: none;
    }

    .gis-iw-pwa {
        max-height: 380px;
        overflow-y: auto;
        min-width: 360px;
        direction: rtl;
        text-align: right;
    }

    .gis-iw-pwa h4 {
        margin: 0 0 6px 0;
        font-size: 13px;
    }

    .gis-iw-pwa .pwa-item {
        border-top: 1px solid #e5e7eb;
        padding: 6px 2px;
    }

    .gis-iw-pwa .pwa-item:first-of-type {
        border-top: none;
    }

    .gis-iw-pwa .pwa-name {
        font-weight: bold;
        margin-bottom: 3px;
    }

    .gis-iw-pwa .pwa-badge {
        display: inline-block;
        width: 10px;
        height: 10px;
        border-radius: 50%;
        margin-left: 4px;
        vertical-align: middle;
    }

    .gis-iw-pwa table {
        border-collapse: collapse;
        width: 100%;
        font-size: 12px;
    }

    .gis-iw-pwa td {
        padding: 1px 4px;
        vertical-align: top;
        white-space: nowrap;
    }

    .gis-iw-pwa td.lbl {
        color: #6b7280;
    }

    .gis-iw-pwa td.wrap {
        white-space: normal;
    }

    .gis-iw-pwa .pwa-bar {
        position: relative;
        height: 8px;
        background: #e5e7eb;
        border-radius: 4px;
        overflow: hidden;
        min-width: 120px;
    }

    .gis-iw-pwa .pwa-bar i {
        position: absolute;
        right: 0;
        top: 0;
        bottom: 0;
        display: block;
    }

    .gis-iw-pwa .pwa-bar i.plan {
        background: #93c5fd;
    }

    .gis-iw-pwa .pwa-bar i.act {
        background: #1d4ed8;
        height: 50%;
        top: 25%;
    }

    /* تب‌های برگهء چندپروژه‌ای (همان ShowAllProjectInfo) */
    .gis-iw-pwa .pwa-tab-strip {
        display: flex;
        flex-wrap: wrap;
        gap: 4px;
        border-bottom: 1px solid #d1d5db;
        margin-bottom: 6px;
        padding-bottom: 4px;
    }

    .gis-iw-pwa .pwa-tab {
        display: inline-block;
        padding: 3px 8px;
        border: 1px solid #d1d5db;
        border-radius: 6px 6px 0 0;
        background: #f3f4f6;
        color: #374151;
        font-size: 12px;
        text-decoration: none;
        white-space: nowrap;
        cursor: pointer;
    }

    .gis-iw-pwa .pwa-tab:hover {
        background: #e5e7eb;
        text-decoration: none;
    }

    .gis-iw-pwa .pwa-tab.is-active {
        background: #ffffff;
        border-bottom-color: #ffffff;
        color: #111827;
        font-weight: bold;
        margin-bottom: -5px;
        padding-bottom: 7px;
    }

    .gis-iw-pwa .pwa-tab-panel {
        display: none;
        padding: 2px;
    }

    .gis-iw-pwa .pwa-tab-panel.is-active {
        display: block;
    }

    /* ---- انتخاب و انیمیشن مارکر / سطح / ردیف فهرست (همان ShowAllProjectInfo) ---- */
    @keyframes pwaMarkerBounce {
        0%   { transform: translateY(0) scale(1.45); }
        25%  { transform: translateY(-16px) scale(1.45); }
        50%  { transform: translateY(0) scale(1.45); }
        70%  { transform: translateY(-7px) scale(1.45); }
        100% { transform: translateY(0) scale(1.45); }
    }

    @keyframes pwaMarkerPulse {
        0%   { filter: drop-shadow(0 0 2px rgba(29, 78, 216, 0.95)); }
        50%  { filter: drop-shadow(0 0 9px rgba(29, 78, 216, 0.95)); }
        100% { filter: drop-shadow(0 0 2px rgba(29, 78, 216, 0.95)); }
    }

    .gis-root .pwa-marker-selected {
        transform: scale(1.45);
        transform-origin: 50% 100%;
        overflow: visible !important;
        z-index: 100000 !important;
        animation: pwaMarkerBounce 0.9s ease-out 1, pwaMarkerPulse 1.6s ease-in-out 0.9s infinite;
    }

    .gis-root .gis-item.is-selected {
        background: #dbeafe;
        box-shadow: inset 3px 0 0 #2563eb;
        border-radius: 6px;
    }

    .gis-root .gis-item.is-selected .gis-item-title {
        font-weight: bold;
        color: #1e3a8a;
    }

    .gis-root .gis-topbar {
        flex-wrap: nowrap;
        align-items: flex-start;
    }

    .gis-root .gis-topbar .gis-fields {
        flex: 1 1 auto;
        min-width: 0;
    }

    .gis-root .gis-topbar-aside {
        flex: 0 0 auto;
        margin-right: auto;
        align-items: flex-end;
    }

    .gis-root .gis-legend {
        flex-wrap: wrap;
        max-width: 520px;
        row-gap: 4px;
    }

    .gis-root .gis-toggle.is-active {
        background: #eff4ff;
        border-color: #2f6fdd;
        color: #2f6fdd;
        box-shadow: 0 0 0 2px rgba(47, 111, 221, 0.18);
    }

    .gis-root .gis-toggle.pwa-toggle-danger:hover {
        background: #fff1f1;
        color: #d33;
        border-color: #f3c2c2;
    }

    .gis-root .pwa-selbar {
        gap: 4px;
        margin-top: 6px;
    }

    .gis-root .pwa-selbar .gis-tool {
        height: 26px;
        padding: 0 6px;
        gap: 4px;
        font-size: 11px;
        line-height: 1;
        white-space: nowrap;
        border-radius: 6px;
    }

    .gis-root .pwa-selbar .gis-tool svg {
        width: 13px;
        height: 13px;
        flex: none;
    }

    /* ---- پنل ثبت برگه (داخل ستون کناری، هم‌اندازهء پنل فهرست) ---- */
    .gis-root .ms-reg-body {
        flex: 1;
        min-height: 0;
        overflow: auto;
        padding: 10px 12px;
        font-size: 12px;
    }

    .gis-root .ms-reg-title {
        display: flex;
        align-items: center;
        gap: 6px;
        font-weight: bold;
        font-size: 13px;
        color: #1f2937;
        margin: 0 0 8px 0;
    }

    .gis-root .ms-reg-title svg {
        width: 16px;
        height: 16px;
    }

    .gis-root .ms-reg-sub {
        font-weight: bold;
        color: #374151;
        margin: 12px 0 6px 0;
        padding-top: 8px;
        border-top: 1px solid #eef0f3;
    }

    .gis-root .ms-field {
        margin-bottom: 8px;
    }

    .gis-root .ms-field label {
        display: block;
        color: #6b7280;
        margin-bottom: 3px;
    }

    .gis-root .ms-file {
        width: 100%;
        font-size: 12px;
    }

    .gis-root .ms-check {
        cursor: pointer;
    }

    .gis-root .ms-check input {
        vertical-align: middle;
        margin: 0 0 0 4px;
    }

    .gis-root .ms-btn {
        display: inline-block;
        border: 1px solid #2f6fdd;
        background: #2f6fdd;
        color: #fff;
        border-radius: 6px;
        padding: 6px 14px;
        font-size: 12px;
        cursor: pointer;
    }

    .gis-root .ms-btn:hover {
        background: #2559b8;
    }

    .gis-root .ms-btn-light {
        border-color: #d1d5db;
        background: #fff;
        color: #374151;
        padding: 3px 8px;
        font-size: 11px;
        border-radius: 5px;
        cursor: pointer;
    }

    .gis-root .ms-btn-light:hover {
        background: #f3f4f6;
    }

    .gis-root .ms-btn-danger {
        border-color: #f3c2c2;
        color: #d33;
    }

    .gis-root .ms-btn-danger:hover {
        background: #fff1f1;
    }

    .gis-root .ms-result {
        margin-top: 8px;
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
        max-height: 170px;
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

    .gis-root table.ms-batches a {
        text-decoration: none;
    }

    .gis-root .ms-hint {
        color: #6b7280;
        font-size: 11px;
        line-height: 1.7;
        margin-bottom: 8px;
    }
</style>
<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GIS/Script/css/gis-ui.css?v=20260917" />
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-1.7.1.min.js" type="text/javascript"></script>
<link href="/_layouts/15/Sazmanyar.GIS/Script/css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" />
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-ui-1.10.3.custom.min.js" type="text/javascript"></script>
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/gis-ui.js?v=20260917" type="text/javascript" charset="utf-8"></script>
<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GIS/Fansy/css/jquery.fancybox-1.3.4.css" />
<script src="/_layouts/15/Sazmanyar.GIS/Fansy/JS/jquery.fancybox-1.3.4.js" type="text/javascript"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/GoogleMap/GISBase.js"></script>
<script type="text/javascript" language="javascript">

    function stopRKey(evt) {
        var evt = (evt) ? evt : ((event) ? event : null);
        var node = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);
        if ((evt.keyCode == 13) && (node.type == "text")) { return false; }
    }
    document.onkeypress = stopRKey;

    var X = jQuery;
    var availableTags = [];            // برچسب برگه‌ها برای پیشنهاد خودکار («7352-1 - راور»)
    var bVaziyatSelect = false;        // آیا برگهء معتبری انتخاب شده؟
    var currentSheet = "";
    var strCurrentWebUrl = window.location.protocol + "//" + window.location.host + _spPageContextInfo.webServerRelativeUrl;
    var strFetchUrl = strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/";

    // ---- جستجوی پیشرفته (همان سازوکار ShowAllProjectInfo: صفحهء FilterMapSheet.html داخل fancybox، خروجی query-builder به‌صورت SQL) ----
    var SearchOption_MapSheet = null;   // { sql: "SELECT * FROM table WHERE ..." }

    function ShowSearchOptionMapSheet() {
        X.fancybox({
            'width': 960,
            'height': 600,
            'padding': 0,
            'autoScale': false,
            'transitionIn': 'none',
            'transitionOut': 'none',
            'type': 'iframe',
            'href': '/_layouts/15/Sazmanyar.GIS/FilterMapSheet.html?v=20260920'
        });
    }

    function GetRulesWidgets_MapSheet() {
        if (SearchOption_MapSheet != null) {
            var Sql = SearchOption_MapSheet.sql.replace("SELECT * FROM table WHERE ", "").replace(/NNNNNNNNNNN/g, "").replace(/DDDDDDDDDDD/g, "");
            if (Sql.trim().length == 0) {
                return null;
            }
            SearchOption_MapSheet.sql = Sql;
        }
        return SearchOption_MapSheet;
    }

    function setInformation_MapSheet(data) {
        SearchOption_MapSheet = data;
        return SearchOption_MapSheet;
    }

    // صفحهء فیلتر بعد از «جستجوی اطلاعات» این را صدا می‌زند
    function ShowAllRoutInMap() {
        RefereshAllInMap();
    }

    function DeLSearchOption() {
        SearchOption_MapSheet = null;
        RefereshAllInMap();
    }

    // فهرست‌های انتخابی صفحهء جستجوی پیشرفته (از برگه‌های بارگذاری‌شده ساخته می‌شوند)
    var msLists = { types: [], regions: [], contractors: [], supervisors: [], geologists: [] };
    function msFilterLists() {
        return msLists;
    }

    function msGetSearchCondition() {
        if (SearchOption_MapSheet == null || SearchOption_MapSheet.sql == null) { return ""; }
        var Condition = SearchOption_MapSheet.sql.replace("SELECT * FROM table WHERE ", "").replace(/'/g, "#@#").replace(/NNNNNNNNNNN/g, "N");
        return Condition.trim();
    }

    function msUpdateSearchState() {
        var active = msGetSearchCondition().length > 0;
        var btnDel = document.getElementById('btnDelSearchOption');
        var btnSearch = document.getElementById('btnShowSearchOption');
        if (btnDel) { btnDel.style.display = active ? '' : 'none'; }
        if (btnSearch) {
            btnSearch.className = 'gis-toggle' + (active ? ' is-active' : '');
            btnSearch.title = active ? 'جستجوی پیشرفته (شرط فعال است) - برای ویرایش کلیک کنید' : 'جستجوی پیشرفته روی مشخصات برگه و پروژه';
        }
    }

    // ---- دسته‌های رنگ: 0 = بدون پروژه در PWA، 1..5 = دستهء تحقق پروژه (همان کدهای GISInfo.TahaghoghRoute) ----
    var MS_CAT = {
        0: { title: 'بدون پروژه', hex: '#64748b', marker: 'Black' },
        1: { title: 'بیش از ۹۰٪', hex: '#22c55e', marker: 'Green' },
        2: { title: '۷۰ تا ۹۰٪', hex: '#facc15', marker: 'Yellow' },
        3: { title: '۵۰ تا ۷۰٪', hex: '#f472b6', marker: 'Pink' },
        4: { title: 'کمتر از ۵۰٪', hex: '#ef4444', marker: 'Red' },
        5: { title: 'آغاز نشده', hex: '#9ca3af', marker: 'Gray' }
    };

    function msNum(v) {
        var n = parseFloat(String(v == null ? '' : v).replace(/[۰-۹]/g, function (d) { return String.fromCharCode(d.charCodeAt(0) - 1776 + 48); }));
        return isNaN(n) ? 0 : n;
    }

    function msVal(v) {
        if (v == null || v === '' || v == 'NULL') { return '-'; }
        return gisEscapeHtml(v);
    }

    function msPct(v) {
        if (v == null || v === '' || v == 'NULL') { return '-'; }
        return gisEscapeHtml(String(Math.round(msNum(v) * 100) / 100)) + '٪';
    }

    function msScale(v) {
        var n = msNum(v);
        if (n <= 0) { return '-'; }
        return '1:' + String(n).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    }

    // سطرهای PWAInfo یک برگه (ستون PwaRows: JSON)؛ یک بار پارس و روی خود شیء کش می‌شود
    function msPwaRows(s) {
        if (!s) { return []; }
        if (s._pwaRows) { return s._pwaRows; }
        var rows = [];
        try { rows = JSON.parse(s.PwaRows || '[]'); } catch (e) { rows = []; }
        if (!rows || !rows.length) {
            // سازگاری: اگر ستون PwaRows نبود، همان سطر اول نما
            if (s.PwaID != null && s.PwaID !== '') { rows = [s]; } else { rows = []; }
        }
        s._pwaRows = rows;
        return rows;
    }

    // دستهء تحقق یک مجموعه سطر PWA: میانگین درصد تحقق و پیشرفت واقعی (همان pwaCategory در ShowAllProjectInfo)؛ بدون سطر = 0
    function msCategoryOfRows(rows) {
        var sumAch = 0, sumAct = 0, n = 0;
        for (var i = 0; i < rows.length; i++) {
            sumAch += msNum(rows[i].AchievementPct);
            sumAct += msNum(rows[i].ActualProgress);
            n++;
        }
        if (n == 0) { return 0; }
        if (sumAct == 0) { return 5; }
        var ach = sumAch / n;
        if (ach > 90) { return 1; }
        if (ach > 70) { return 2; }
        if (ach > 50) { return 3; }
        return 4;
    }

    function msCategory(s) {
        return msCategoryOfRows(msPwaRows(s));
    }

    // میانگین یک ستون عددی روی سطرهای PWA یک برگه
    function msAvg(rows, col) {
        if (!rows.length) { return 0; }
        var sum = 0;
        for (var i = 0; i < rows.length; i++) { sum += msNum(rows[i][col]); }
        return sum / rows.length;
    }

    function msSheetTitle(s) {
        var t = String(s.SheetNo || '');
        if (s.SheetNameFa) { t += ' - ' + s.SheetNameFa; }
        else if (s.SheetNameEn) { t += ' - ' + s.SheetNameEn; }
        return t;
    }

    // ---- بارگذاری اولیه ----
    if (typeof ($) != 'undefined') {
        $(document).ready(function () {
            X('.NameProjeh').on('change', function () {
                FillSugestion_Pishnahadi();
            });
            X('.NameProjeh').keyup(function (event) {
                FillSugestion_Pishnahadi();
            });
            // پنل ثبت بعد از بارگذاری/حذف باز می‌ماند
            var regOpen = document.getElementById('<%= hdnRegOpen.ClientID %>');
            if (regOpen && regOpen.value == '1') { toggleRegPanel(true); }
            msLoadLists();
        });
    }

    function GetSelectedRegion() {
        var control = document.getElementById('cmbRegion');
        if (!control || control.selectedIndex < 0) { return ''; }
        var selectedvalue = control.options[control.selectedIndex].value;
        if (selectedvalue == 'همه موارد') { return ''; }
        return selectedvalue;
    }

    // یک بار همهء برگه‌ها را می‌گیرد تا کمبوی منطقه، پیشنهاد خودکار برگه و فهرست‌های جستجوی پیشرفته ساخته شوند؛ سپس نقشه را تازه می‌کند
    function msLoadLists() {
        X.ajax({
            type: "POST",
            url: strFetchUrl + "FetchMapSheets",
            data: JSON.stringify({ 'Region': '', 'Sheet': '', 'ImportBatch': '', 'Condition': '' }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (strHtmlOutput) {
                var rows = (strHtmlOutput.d != null) ? strHtmlOutput.d : [];
                msBuildLists(rows);
                msSetupAutocomplete();
                FillSugestion_Pishnahadi();
            },
            error: function (MSG) {
                alert('error' + MSG.responseText);
            }
        });
    }

    function msAddDistinct(list, v) {
        if (v == null || v === '') { return; }
        if (X.inArray(v, list) < 0) { list.push(v); }
    }

    function msBuildLists(rows) {
        msLists = { types: [], regions: [], contractors: [], supervisors: [], geologists: [] };
        availableTags = [];
        var unlinked = 0;
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            msAddDistinct(msLists.types, r.ProjectType);
            msAddDistinct(msLists.regions, r.Region);
            msAddDistinct(msLists.contractors, r.Contractor);
            msAddDistinct(msLists.supervisors, r.Supervisor);
            msAddDistinct(msLists.geologists, r.Geologist);
            msAddDistinct(availableTags, msSheetTitle(r));
            if (r.PwaID == null || r.PwaID === '') { unlinked++; }
        }
        msLists.regions.sort();
        availableTags.sort();

        // کمبوی منطقه: همه موارد + منطقه‌های پروژه‌های متصل + «بدون پروژه»
        var cmb = document.getElementById('cmbRegion');
        var cur = GetSelectedRegion();
        cmb.innerHTML = '';
        var o = document.createElement('option'); o.value = 'همه موارد'; o.innerHTML = 'همه موارد'; cmb.appendChild(o);
        for (var k = 0; k < msLists.regions.length; k++) {
            var op = document.createElement('option'); op.value = msLists.regions[k]; op.innerHTML = gisEscapeHtml(msLists.regions[k]); cmb.appendChild(op);
        }
        if (unlinked > 0) {
            var ou = document.createElement('option'); ou.value = '*NOPWA*'; ou.innerHTML = 'بدون پروژه (' + unlinked + ')'; cmb.appendChild(ou);
        }
        for (var m = 0; m < cmb.options.length; m++) {
            if (cmb.options[m].value == cur) { cmb.selectedIndex = m; break; }
        }
    }

    function msSetupAutocomplete() {
        var search_option = false;
        X(".NameProjeh").autocomplete({
            source: function (request, response) {
                var results = X.ui.autocomplete.filter(availableTags, request.term);
                response(results.slice(0, 15));
            },
            minLength: 0,
            focus: function (event, ui) {
                search_option = ui.item;
            },
            change: function (event, ui) {
                FillSugestion_Pishnahadi();
            },
            select: function (event, ui) {
                search_option = ui.item;
                X(".NameProjeh").autocomplete('widget').trigger('mousedown.choose_option');
            }
        }).bind('click', function () {
            X(this).autocomplete('search', X(this).val());
        });

        X(".NameProjeh").autocomplete('widget').bind('mousedown.choose_option', function () {
            X(".NameProjeh").autocomplete('close');
            X(".NameProjeh").val(search_option.value);
            FillSugestion_Pishnahadi();
        });
    }

    // وضعیت فیلد «برگه» و تازه‌سازی نقشه (نام تابع برای سازگاری با gis-ui.js حفظ شده)
    function FillSugestion_Pishnahadi() {
        var strSheet = X(".NameProjeh").val();
        if (strSheet == null || strSheet.toString().length == 0) {
            gisSetProjectStatus('none');
            bVaziyatSelect = false;
            currentSheet = "";
            RefereshAllInMap();
            return;
        }

        // معتبر = دست‌کم یک برگه با این متن (بخشی از شماره یا نام) وجود دارد؛ سرور با LIKE جستجو می‌کند
        gisSetProjectStatus('invalid');
        bVaziyatSelect = false;
        currentSheet = "";
        var needle = String(strSheet).toLowerCase();
        for (var i = 0; i < availableTags.length; i++) {
            if (availableTags[i].toLowerCase().indexOf(needle) >= 0) {
                gisSetProjectStatus('valid');
                bVaziyatSelect = true;
                break;
            }
        }
        // فقط شمارهء برگه یا نام (بخش قبل/بعد از « - ») به سرور می‌رود
        currentSheet = String(strSheet).split(' - ')[0].trim();
        RefereshAllInMap();
    }

    // ---- بارگذاری برگه‌ها و رسم ----
    var gmarkers = [];     // پین مرکز هر برگه (هم‌اندیس با gsheets)
    var gpolys = [];       // سطح هر برگه (هم‌اندیس با gsheets)
    var ggans = [];        // همان آرایهء gpolys (gis-ui.js اسلایدر شفافیت را روی ggans اعمال می‌کند)
    var gsheets = [];
    var divSearchResult_html = "";
    var map;
    var msFirstLoad = true;

    function RefereshAllInMap() {
        if (typeof map == 'undefined' || map == null) { return; }

        var strRegion = GetSelectedRegion();
        var strSheet = currentSheet;
        var strCondition = msGetSearchCondition();
        msUpdateSearchState();
        try { X.fancybox.close(); } catch (e) { }

        // فقط در اولین بارگذاری بعد از ثبت: برگه‌های همان بارگذاری
        var strBatch = '';
        if (msFirstLoad) {
            var focus = document.getElementById('<%= hdnFocusBatch.ClientID %>');
            strBatch = focus ? focus.value : '';
            msFirstLoad = false;
        }

        document.getElementById("divSearchCount").innerHTML = '';
        document.getElementById('divSearchResult').innerHTML = '<div class="gis-msg gis-msg-wait">لطفاً کمی صبر نمایید ...<br />سیستم در حال جستجوی اطلاعات مورد نیاز شما می باشد</div>';

        msClearSelection();
        gmarkers = [];
        gpolys = [];
        ggans = gpolys;
        gsheets = [];
        msClusterMarkers = [];
        map.clearOverlays();
        divSearchResult_html = "";
        bounds = new GLatLngBounds();

        X.ajax({
            type: "POST",
            url: strFetchUrl + "FetchMapSheets",
            data: JSON.stringify({ 'Region': strRegion, 'Sheet': strSheet, 'ImportBatch': strBatch, 'Condition': strCondition }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (strHtmlOutput) {
                var result = strHtmlOutput.d;
                if (result == null || result.length == 0) {
                    document.getElementById('divSearchResult').innerHTML = '<div class="gis-msg">هیچ برگه‌ای جهت نمایش در لیست یافت نشد</div>';
                    map.centerAndZoomOnBounds(new GLatLngBounds(new GLatLng(39.027719, 44.736328), new GLatLng(26.745610, 62.050781)));
                    return;
                }
                DrawMapSheets(result);
            },
            error: function (MSG) {
                alert('error' + MSG.responseText);
            }
        });
    }

    function msParseBoundary(str) {
        var pts = [];
        try {
            var arr = JSON.parse(str);
            for (var i = 0; i < arr.length; i++) {
                var la = msNum(arr[i].lat), ln = msNum(arr[i].lng);
                if (la == 0 && ln == 0) { continue; }
                pts.push(new GLatLng(la, ln));
            }
        } catch (e) { }
        return pts;
    }

    function DrawMapSheets(rows) {
        var listHtml = "";
        var nLinked = 0, nUnlinked = 0, nProjects = 0;
        var codes = {};

        for (var i = 0; i < rows.length; i++) {
            var s = rows[i];
            var pts = msParseBoundary(s.Boundary);
            if (pts.length < 3) { continue; }
            pts.push(pts[0]);

            var cat = msCategory(s);
            var color = MS_CAT[cat].hex;
            if (cat == 0) { nUnlinked++; } else { nLinked++; if (!codes[s.ProjectCode]) { codes[s.ProjectCode] = true; nProjects++; } }

            gsheets.push(s);
            var idx = gsheets.length - 1;

            // سطح برگه
            var poly = new GPolygon(pts, color, 2, 0.9, color, gisAreaOpacity(null), { clickable: true });
            poly.pwaColor = color;
            gpolys.push(poly);
            map.addOverlay(poly);

            // پین مرکز برگه: آیکون «برگهء نقشه» با رنگ دسته؛ چند سطر PWA = دستهء برگه با نشان تعداد
            var prows = msPwaRows(s);
            var center = new GLatLng(msNum(s.CentroidLat), msNum(s.CentroidLong));
            var pIcon = msSheetIcon(color, null, prows.length);
            var marker = new GMarker(center, { icon: pIcon, title: msSheetTitle(s) + (prows.length > 1 ? ' (' + prows.length + ' پروژه)' : '') });
            marker.pwaImage = pIcon.image;
            marker.pwaColor = color;
            marker.pwaCount = prows.length;
            marker.pwaUserHidden = false;   // با چک‌باکس فهرست مخفی شده؟
            marker.pwaClustered = false;    // داخل یک خوشه پنهان شده؟
            gmarkers.push(marker);
            map.addOverlay(marker);

            (function (num, c) {
                GEvent.addListener(gpolys[num], "click", function (point) {
                    msSelectSheet(num);
                    map.openInfoWindowHtml(point || c, BuildSheetInfoHtml(gsheets[num]));
                });
                GEvent.addListener(gmarkers[num], "click", function () {
                    msSelectSheet(num);
                    map.openInfoWindowHtml(c, BuildSheetInfoHtml(gsheets[num]));
                });
            })(idx, center);

            var sub = (cat == 0)
                ? (s.ProjectCode ? 'کد ' + s.ProjectCode + ' در PWA نیست' : 'بدون کد پروژه')
                : String(prows[0].ProjectName || '') + (prows.length > 1 ? ' - ' + prows.length + ' نوع' : '');
            listHtml += gisResultItem('area', 'Sheet', idx, 'toggleSheet', color, 'gpolys', msSheetTitle(s) + ' [' + sub + ']');

            var b = poly.getBounds();
            bounds.extend(b.getNorthEast());
            bounds.extend(b.getSouthWest());
        }

        divSearchResult_html = listHtml;
        document.getElementById("divSearchCount").innerHTML = msCountChips(gsheets.length, nProjects, nUnlinked);
        document.getElementById("divSearchResult").innerHTML = listHtml.length > 0 ? listHtml : '<div class="gis-msg">هیچ برگه‌ای جهت نمایش در لیست یافت نشد</div>';

        if (gsheets.length > 0) {
            map.centerAndZoomOnBounds(bounds);
        }
        // خوشه‌بندی برای زوم فعلی (با تغییر زوم، رویداد zoomend دوباره محاسبه می‌کند)
        msRebuildClusters();
    }

    function msCountChips(sheets, projects, unlinked) {
        var html = '<span class="gis-chip" title="برگه">' + GIS_ICON_AREA + ' برگه <b>' + sheets + '</b></span>' +
            '<span class="gis-chip" title="پروژهء متصل در PWA">' + GIS_ICON_ROUTE + ' پروژه <b>' + projects + '</b></span>';
        if (unlinked > 0) {
            html += '<span class="gis-chip" title="برگه‌هایی که پروژه‌شان در PWA پیدا نشد">' + GIS_ICON_STATION + ' بدون پروژه <b>' + unlinked + '</b></span>';
        }
        return html;
    }

    // ---- آیکون پین برگه: SVG درون‌خطی به شکل یک برگهء نقشه (چهارگوش با گوشهء تاشده و خطوط شبکه) + نوک پایین ----
    // count > 1 (برگهء چندپروژه‌ای): چند برگهء روی هم (تا 3 لایه) + نشان گرد تعداد در گوشهء بالا-چپ.
    // هر (رنگ، تعداد، شناسهء انتخاب) یک بار ساخته و کش می‌شود. selIdx فقط برای پین انتخاب‌شده: یک id داخل SVG می‌گذارد تا
    // بتوان عنصر <img> آن را در DOM پیدا و انیمیت کرد (روش ShowAllProjectInfo با ?pwasel= روی data: URI کار نمی‌کند).
    var msIconCache = {};
    function msSheetIcon(hex, selIdx, count) {
        count = count || 1;
        var key = hex + '|' + count + '|' + (selIdx == null ? '' : selIdx);
        if (msIconCache[key]) { return msIconCache[key]; }
        var w = 30, h = 38;
        var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="' + w + '" height="' + h + '" viewBox="0 0 30 38">' +
            (selIdx == null ? '<g>' : '<g id="pwasel-' + selIdx + '">') +
            '<path d="M13 37 L8 29 H18 Z" fill="#1f2937"/>';
        // برگه‌های پشتی (دستهء برگه): هر لایه 3 پیکسل بالا-چپ‌تر (در RTL یعنی پشت سر)
        var layers = Math.min(3, count);
        for (var L = layers - 1; L >= 1; L--) {
            var dx = 3 * L, dy = -3 * L;
            svg += '<g transform="translate(' + dx + ',' + dy + ')">' +
                '<path d="M3.5 6.5 H17 L22.5 12 V29.5 H3.5 Z" fill="' + hex + '" stroke="#1f2937" stroke-width="1.2" stroke-linejoin="round"/>' +
                '<path d="M3.5 6.5 H17 L22.5 12 V29.5 H3.5 Z" fill="#ffffff" fill-opacity="' + (0.25 * L) + '"/>' +
                '</g>';
        }
        // برگهء جلو
        svg += '<path d="M3.5 6.5 H17 L22.5 12 V29.5 H3.5 Z" fill="' + hex + '" stroke="#1f2937" stroke-width="1.4" stroke-linejoin="round"/>' +
            '<path d="M17 6.5 V12 H22.5" fill="#ffffff" fill-opacity="0.85" stroke="#1f2937" stroke-width="1.2" stroke-linejoin="round"/>' +
            '<path d="M9.5 12.5 V29.5 M16 15 V29.5 M3.5 18 H22.5 M3.5 23.5 H22.5" stroke="#ffffff" stroke-opacity="0.85" stroke-width="1.1"/>';
        // نشان تعداد
        if (count > 1) {
            var txt = count > 9 ? '9+' : String(count);
            svg += '<circle cx="23.5" cy="7" r="6.2" fill="#1f2937" stroke="#ffffff" stroke-width="1.3"/>' +
                '<text x="23.5" y="7" dy="0.36em" text-anchor="middle" font-family="Arial, Tahoma" font-size="' + (count > 9 ? 7.5 : 8.5) + '" font-weight="bold" fill="#ffffff">' + txt + '</text>';
        }
        svg += '</g></svg>';
        var icon = new GIcon();
        icon.image = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg);
        icon.iconSize = new GSize(w, h);
        icon.iconAnchor = new GPoint(13, 37);
        icon.infoWindowAnchor = new GPoint(13, 4);
        msIconCache[key] = icon;
        return icon;
    }

    // ---- انتخاب (Highlight) سطح + پین + ردیف فهرست ----
    var msSel = { idx: -1, polyTimer: null, listEl: null };
    var MS_SEL_STROKE = '#1d4ed8';

    function msClearSelection() {
        if (msSel.polyTimer) { clearInterval(msSel.polyTimer); msSel.polyTimer = null; }
        if (msSel.idx >= 0) {
            var poly = gpolys[msSel.idx];
            if (poly) {
                try {
                    poly.setStrokeStyle({ color: poly.pwaColor, weight: 2, opacity: 0.9 });
                    poly.setFillStyle({ color: poly.pwaColor, opacity: gisAreaOpacity(null) });
                } catch (e) { }
            }
            var mk = gmarkers[msSel.idx];
            if (mk) { try { mk.setImage(mk.pwaImage); } catch (e) { } }
        }
        var els = document.querySelectorAll('.gis-root .pwa-marker-selected');
        for (var i = 0; i < els.length; i++) { els[i].className = els[i].className.replace(/\s*pwa-marker-selected/g, ''); }
        if (msSel.listEl) {
            msSel.listEl.className = msSel.listEl.className.replace(/\s*is-selected/g, '');
            msSel.listEl = null;
        }
        msSel.idx = -1;
    }

    function msSelectSheet(idx) {
        msClearSelection();
        msSel.idx = idx;

        // سطح: خط دور ضخیم آبی + چند ضربان شفافیت، سپس ثابت روی حالت پررنگ‌تر
        var poly = gpolys[idx];
        var base = gisAreaOpacity(null);
        var hi = Math.min(0.85, base + 0.3);
        try { poly.setStrokeStyle({ color: MS_SEL_STROKE, weight: 4, opacity: 1 }); } catch (e) { }
        var step = 0;
        msSel.polyTimer = setInterval(function () {
            step++;
            var on = (step % 2 == 1);
            try { poly.setFillStyle({ color: poly.pwaColor, opacity: on ? hi : base }); } catch (e) { }
            if (step >= 6) {
                clearInterval(msSel.polyTimer); msSel.polyTimer = null;
                try { poly.setFillStyle({ color: poly.pwaColor, opacity: Math.min(0.85, base + 0.15) }); } catch (e) { }
            }
        }, 180);

        // پین: همان آیکون با یک id یکتا داخل SVG، تا بتوان عنصر <img> آن را در DOM پیدا و انیمیت کرد
        var mk = gmarkers[idx];
        if (mk) {
            try { mk.setImage(msSheetIcon(mk.pwaColor, idx, mk.pwaCount).image); } catch (e) { }
            setTimeout(function () {
                var imgs = document.querySelectorAll('.gis-root img[src*="pwasel-' + idx + '%22"]');
                for (var i = 0; i < imgs.length; i++) {
                    var el = (imgs[i].parentNode && imgs[i].parentNode.tagName == 'DIV') ? imgs[i].parentNode : imgs[i];
                    if (el.className.indexOf('pwa-marker-selected') < 0) { el.className += ' pwa-marker-selected'; }
                }
            }, 30);
        }

        // ردیف فهرست
        var cb = document.getElementById('Sheet' + idx);
        if (cb && cb.parentNode) {
            var el = cb.parentNode;
            el.className += ' is-selected';
            msSel.listEl = el;
            try {
                var panel = document.getElementById('divSearchOptions');
                if (panel && panel.style.display != 'none' && el.scrollIntoView) {
                    el.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
                }
            } catch (e) { }
        }
    }

    // ---- HTML پنجرهء اطلاعات ----
    function msBarHtml(plan, act) {
        var p = Math.max(0, Math.min(100, msNum(plan)));
        var a = Math.max(0, Math.min(100, msNum(act)));
        return "<div class='pwa-bar' title='برنامه‌ای: " + msPct(p) + " / واقعی: " + msPct(a) + "'>" +
            "<i class='plan' style='width:" + p + "%'></i><i class='act' style='width:" + a + "%'></i></div>";
    }

    var msInfoSeq = 0; // شمارندهء یکتا برای شناسهء تب‌های هر پنجره

    // جزئیات یک سطر PWA (بدنهء هر تب) - همان BuildProjectDetailHtml در ShowAllProjectInfo
    function BuildProjectDetailHtml(r, bShowName) {
        var rcat = msCategoryOfRows([r]);
        var html = "";
        if (bShowName) {
            html += "<div class='pwa-name'><span class='pwa-badge' style='background:" + MS_CAT[rcat].hex + "' title='" + MS_CAT[rcat].title + "'></span>" + msVal(r.ProjectName) + "</div>";
        }
        html += "<table>";
        html += "<tr><td class='lbl'>نوع پروژه:</td><td><b>" + msVal(r.ProjectType) + "</b></td><td class='lbl'>کد:</td><td>" + msVal(r.ProjectCode) + "</td></tr>";
        html += "<tr><td class='lbl'>وضعیت:</td><td>" + msVal(r.Status) + "</td><td class='lbl'>منطقه:</td><td>" + msVal(r.Region) + "</td></tr>";
        html += "<tr><td class='lbl'>پیشرفت برنامه‌ای:</td><td>" + msPct(r.PlannedProgress) + "</td><td class='lbl'>پیشرفت واقعی:</td><td>" + msPct(r.ActualProgress) + "</td></tr>";
        html += "<tr><td class='lbl'>درصد تحقق:</td><td><b>" + msPct(r.AchievementPct) + "</b></td><td colspan='2'>" + msBarHtml(r.PlannedProgress, r.ActualProgress) + "</td></tr>";
        html += "<tr><td class='lbl'>شروع:</td><td>" + msVal(r.StartDateJ) + "</td><td class='lbl'>پایان:</td><td>" + msVal(r.FinishDateJ) + "</td></tr>";
        html += "<tr><td class='lbl'>شروع برنامه‌ای:</td><td>" + msVal(r.PlannedStartJ) + "</td><td class='lbl'>پایان برنامه‌ای:</td><td>" + msVal(r.PlannedFinishJ) + "</td></tr>";
        html += "<tr><td class='lbl'>نحوه اجرا:</td><td>" + msVal(r.ExecutionMethod) + "</td><td class='lbl'>مدیر پروژه:</td><td>" + msVal(r.ProjectManager) + "</td></tr>";
        html += "<tr><td class='lbl'>ناظر پروژه:</td><td colspan='3'>" + msVal(r.ProjectSupervisor) + "</td></tr>";
        html += "</table>";
        return html;
    }

    // تغییر تب فعال داخل پنجرهء اطلاعات
    function msShowTab(tabId, idx) {
        var root = document.getElementById(tabId);
        if (!root) { return; }
        var tabs = root.getElementsByTagName('a');
        for (var i = 0; i < tabs.length; i++) {
            if (tabs[i].className.indexOf('pwa-tab') < 0) { continue; }
            tabs[i].className = 'pwa-tab' + (tabs[i].getAttribute('data-idx') == String(idx) ? ' is-active' : '');
        }
        var panels = root.getElementsByTagName('div');
        for (var j = 0; j < panels.length; j++) {
            if (panels[j].className.indexOf('pwa-tab-panel') < 0) { continue; }
            panels[j].className = 'pwa-tab-panel' + (panels[j].getAttribute('data-idx') == String(idx) ? ' is-active' : '');
        }
    }

    function BuildSheetInfoHtml(s) {
        var cat = msCategory(s);
        var html = "<div class='gis-iw gis-iw-pwa'>";
        html += "<h4><span class='pwa-badge' style='background:" + MS_CAT[cat].hex + "'></span>برگه " + gisEscapeHtml(msSheetTitle(s)) +
            " <small>(" + msScale(s.SheetScale) + ")</small></h4>";

        html += "<div class='pwa-item'><div class='pwa-name'>مشخصات برگه</div><table>";
        html += "<tr><td class='lbl'>شماره برگه:</td><td><b>" + msVal(s.SheetNo) + "</b></td><td class='lbl'>برگه مادر / ربع:</td><td>" + msVal(s.SheetSeries) + " / " + msVal(s.SheetQuarter) + "</td></tr>";
        html += "<tr><td class='lbl'>نام فارسی:</td><td>" + msVal(s.SheetNameFa) + "</td><td class='lbl'>نام انگلیسی:</td><td>" + msVal(s.SheetNameEn) + "</td></tr>";
        html += "<tr><td class='lbl'>مساحت:</td><td>" + (s.AreaKm2 ? gisEscapeHtml(String(Math.round(msNum(s.AreaKm2)))) + " km²" : "-") + "</td><td class='lbl'>مرکز:</td><td>" + msVal(s.CentroidLat) + " , " + msVal(s.CentroidLong) + "</td></tr>";
        html += "<tr><td class='lbl'>مجری:</td><td>" + msVal(s.Contractor) + "</td><td class='lbl'>ناظر:</td><td>" + msVal(s.Supervisor) + "</td></tr>";
        html += "<tr><td class='lbl'>زمین‌شناس:</td><td colspan='3'>" + msVal(s.Geologist) + "</td></tr>";
        if (s.SheetProjectName) {
            html += "<tr><td class='lbl'>عنوان در فایل کارفرما:</td><td colspan='3' class='wrap'>" + msVal(s.SheetProjectName) + "</td></tr>";
        }
        html += "</table></div>";

        var rows = msPwaRows(s);
        html += "<div class='pwa-item'><div class='pwa-name'><span class='pwa-badge' style='background:" + MS_CAT[cat].hex + "' title='" + MS_CAT[cat].title + "'></span>پروژه در PWA" +
            (rows.length > 1 ? " <small>(" + rows.length + " سطر / نوع - کد " + gisEscapeHtml(s.ProjectCode) + ")</small>" : "") + "</div>";
        if (rows.length == 1) {
            html += BuildProjectDetailHtml(rows[0], true);
        }
        else if (rows.length > 1) {
            // چند سطر (پروژهء چندنوعی): یک تب برای هر سطر؛ برچسب تب = نوع پروژه، با شماره برای نوع‌های تکراری
            msInfoSeq++;
            var tabId = 'msTabs' + msInfoSeq;
            var typeCount = {}, typeSeen = {};
            for (var c = 0; c < rows.length; c++) {
                var tc = (rows[c].ProjectType == null || rows[c].ProjectType == '') ? 'بدون نوع' : rows[c].ProjectType;
                typeCount[tc] = (typeCount[tc] || 0) + 1;
            }
            html += "<div class='pwa-tabs' id='" + tabId + "'>";
            html += "<div class='pwa-tab-strip'>";
            for (var i = 0; i < rows.length; i++) {
                var r = rows[i];
                var rcat = msCategoryOfRows([r]);
                var label = (r.ProjectType == null || r.ProjectType == '') ? 'بدون نوع' : r.ProjectType;
                if (typeCount[label] > 1) {
                    typeSeen[label] = (typeSeen[label] || 0) + 1;
                    label = label + ' (' + typeSeen[label] + ')';
                }
                html += "<a href='javascript:void(0);' class='pwa-tab" + (i == 0 ? " is-active" : "") + "' data-idx='" + i + "'" +
                    " onclick=\"msShowTab('" + tabId + "', " + i + ");\" title='" + gisEscapeHtml(r.ProjectName) + "'>" +
                    "<span class='pwa-badge' style='background:" + MS_CAT[rcat].hex + "'></span>" + gisEscapeHtml(label) + "</a>";
            }
            html += "</div>";
            for (var j = 0; j < rows.length; j++) {
                html += "<div class='pwa-tab-panel" + (j == 0 ? " is-active" : "") + "' data-idx='" + j + "'>" + BuildProjectDetailHtml(rows[j], true) + "</div>";
            }
            html += "</div>";
        }
        else if (s.ProjectCode) {
            html += "<div class='gis-hint'>کد پروژه «" + gisEscapeHtml(s.ProjectCode) + "» در PWAInfo پیدا نشد؛ باید با کارفرما بررسی شود.</div>";
        }
        else {
            html += "<div class='gis-hint'>در فایل کارفرما کد پروژه (P_Code) برای این برگه خالی است.</div>";
        }
        html += "</div>";

        html += "<div class='gis-hint'>منبع: " + msVal(s.SourceFile) + (s.SourceLayer ? " / " + gisEscapeHtml(s.SourceLayer) : "") + (s.SourceCrs ? " - " + gisEscapeHtml(s.SourceCrs) : "") + "</div>";
        html += "</div>";
        return html;
    }

    // ==== خوشه‌بندی وابسته به زوم ====
    var msClusterEnabled = true;
    var msZoomFull = 10;                 // از این زوم به بعد هر برگه جدا نمایش داده می‌شود
    var msClusterMarkers = [];           // نشانگرهای خوشه که الان روی نقشه‌اند
    var MS_CLUSTER_PX = 44;              // فاصلهء پیکسلی ادغام در سطح دور
    var msClusterIconCache = {};

    function msApplyZoomFull(value) {
        var v = parseInt(value, 10);
        if (isNaN(v)) { return; }
        msZoomFull = v;
        var lbl = document.getElementById('msZoomFullValue');
        if (lbl) { lbl.innerHTML = v; }
    }

    // فاصلهء کیلومتری معادل MS_CLUSTER_PX پیکسل در زوم فعلی (مقیاس وب‌مرکاتور در عرض ~33 درجه)
    function msClusterThresholdKm() {
        var z = 6;
        try { z = map.getZoom(); } catch (e) { }
        return MS_CLUSTER_PX * 156.543 * 0.84 / Math.pow(2, z);
    }

    function msDistKm(lat1, lng1, lat2, lng2) {
        var R = 6371, dLat = (lat2 - lat1) * Math.PI / 180, dLng = (lng2 - lng1) * Math.PI / 180;
        var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return 2 * R * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    // دستهء رنگ یک مجموعه برگه: میانگین روی همهء سطرهای PWA همهء اعضا؛ اگر هیچ‌کدام پروژه ندارند 0
    function msCategoryOfSheets(idxs) {
        var all = [];
        for (var i = 0; i < idxs.length; i++) { all = all.concat(msPwaRows(gsheets[idxs[i]])); }
        return msCategoryOfRows(all);
    }

    // آیکون خوشه: چهارگوش گردگوشه به شکل برگه (متمایز از خوشهء دایره‌ای پروژه‌ها) + عدد؛ هر (تعداد، رنگ) یک بار ساخته می‌شود
    function msClusterIcon(count, hex) {
        var key = count + '|' + hex;
        if (msClusterIconCache[key]) { return msClusterIconCache[key]; }
        var size = count < 10 ? 34 : (count < 50 ? 40 : 46);
        var half = size / 2;
        var fontSize = count < 100 ? 13 : 11;
        var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="' + size + '" height="' + size + '" viewBox="0 0 ' + size + ' ' + size + '">' +
            '<rect x="1" y="1" width="' + (size - 2) + '" height="' + (size - 2) + '" rx="6" fill="' + hex + '" fill-opacity="0.35"/>' +
            '<rect x="5" y="5" width="' + (size - 10) + '" height="' + (size - 10) + '" rx="4" fill="' + hex + '"/>' +
            '<rect x="9" y="9" width="' + (size - 18) + '" height="' + (size - 18) + '" rx="3" fill="#ffffff"/>' +
            '<text x="' + half + '" y="' + half + '" dy="0.36em" text-anchor="middle" font-family="Arial, Tahoma" font-size="' + fontSize + '" font-weight="bold" fill="#111827">' + count + '</text>' +
            '</svg>';
        var icon = new GIcon();
        icon.image = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg);
        icon.iconSize = new GSize(size, size);
        icon.iconAnchor = new GPoint(half, half);
        icon.infoWindowAnchor = new GPoint(half, 2);
        msClusterIconCache[key] = icon;
        return icon;
    }

    // نمایش/مخفی یک برگه با توجه به چک‌باکس کاربر و عضویت در خوشه (hidePoly: در سطح دور سطح هم پنهان می‌شود)
    function msApplyVisibility(idx, hidePoly) {
        var m = gmarkers[idx], p = gpolys[idx];
        if (!m || !p) { return; }
        if (m.pwaUserHidden) { m.hide(); p.hide(); return; }
        if (m.pwaClustered) { m.hide(); } else { m.show(); }
        if (m.pwaClustered && hidePoly) { p.hide(); } else { p.show(); }
    }

    // خوشه‌بندی سادهء فاصله‌ای (greedy): هر نقطه به اولین خوشه‌ای می‌رود که هستهء آن در آستانه است
    function msClusterByDistance(items, thresholdKm) {
        var clusters = [];
        for (var i = 0; i < items.length; i++) {
            var it = items[i], placed = false;
            for (var c = 0; c < clusters.length; c++) {
                var seed = clusters[c][0];
                if (msDistKm(it.lat, it.lng, seed.lat, seed.lng) <= thresholdKm) { clusters[c].push(it); placed = true; break; }
            }
            if (!placed) { clusters.push([it]); }
        }
        return clusters;
    }

    function msRebuildClusters() {
        if (typeof map == 'undefined' || map == null) { return; }
        for (var c = 0; c < msClusterMarkers.length; c++) {
            try { map.removeOverlay(msClusterMarkers[c]); } catch (e) { }
        }
        msClusterMarkers = [];

        var z = 6;
        try { z = map.getZoom(); } catch (e) { }

        // سطح 1: زوم نزدیک یا خوشه‌بندی خاموش -> همه جدا
        if (!msClusterEnabled || z >= msZoomFull) {
            for (var i = 0; i < gmarkers.length; i++) { gmarkers[i].pwaClustered = false; msApplyVisibility(i, false); }
            return;
        }

        // نقاط قابل خوشه‌بندی (کاربر مخفی نکرده)
        var items = [];
        for (var k = 0; k < gmarkers.length; k++) {
            var m = gmarkers[k];
            if (m.pwaUserHidden) { m.pwaClustered = false; msApplyVisibility(k, false); continue; }
            var ll = m.getLatLng();
            items.push({ lat: ll.lat(), lng: ll.lng(), idx: k, series: gsheets[k].SheetSeries || ('#' + gsheets[k].SheetNo) });
        }

        var clusters = [];
        var hidePoly = false;
        if (z >= msZoomFull - 2) {
            // سطح 2: زوم میانی -> گروه‌بندی بر اساس برگهء مادر (SheetSeries)؛ سطح‌ها می‌مانند
            var bySeries = {}, order = [];
            for (var a = 0; a < items.length; a++) {
                var key = items[a].series;
                if (!bySeries[key]) { bySeries[key] = []; order.push(key); }
                bySeries[key].push(items[a]);
            }
            for (var o = 0; o < order.length; o++) { clusters.push(bySeries[order[o]]); }
        }
        else {
            // سطح 3: زوم دور -> خوشه‌بندی فاصله‌ای؛ سطح‌ها هم پنهان می‌شوند
            clusters = msClusterByDistance(items, msClusterThresholdKm());
            hidePoly = true;
        }

        for (var q = 0; q < clusters.length; q++) {
            var cl = clusters[q];
            if (cl.length == 1) {
                gmarkers[cl[0].idx].pwaClustered = false;
                msApplyVisibility(cl[0].idx, false);
                continue;
            }
            var members = [], sumLat = 0, sumLng = 0;
            var cb = new GLatLngBounds();
            for (var j = 0; j < cl.length; j++) {
                var gm = gmarkers[cl[j].idx];
                gm.pwaClustered = true;
                msApplyVisibility(cl[j].idx, hidePoly);
                members.push(cl[j].idx);
                sumLat += cl[j].lat; sumLng += cl[j].lng;
                var pb = gpolys[cl[j].idx].getBounds();
                cb.extend(pb.getNorthEast()); cb.extend(pb.getSouthWest());
            }
            var center = new GLatLng(sumLat / cl.length, sumLng / cl.length);
            var cat = msCategoryOfSheets(members);
            var title = (hidePoly ? '' : 'برگه مادر ' + cl[0].series + ': ') + cl.length + ' برگه';
            var cm = new GMarker(center, { icon: msClusterIcon(cl.length, MS_CAT[cat].hex), title: title });
            cm.pwaMembers = members;
            cm.pwaBounds = cb;
            (function (clusterMarker, pos) {
                GEvent.addListener(clusterMarker, 'click', function () {
                    var zz = map.getZoom();
                    if (zz < msZoomFull) {
                        // زوم به محدودهء اعضا؛ دست‌کم یک پله نزدیک‌تر
                        var target = Math.max(zz + 1, Math.min(msZoomFull, map.getBoundsZoomLevel(clusterMarker.pwaBounds)));
                        map.setCenter(clusterMarker.pwaBounds.getCenter(), target);
                    }
                    else {
                        map.openInfoWindowHtml(pos, BuildClusterInfoHtml(clusterMarker));
                    }
                });
            })(cm, center);
            msClusterMarkers.push(cm);
            map.addOverlay(cm);
        }

        // اگر برگهء انتخاب‌شده داخل خوشه رفت، انتخاب و پنجره بسته شود
        if (msSel.idx >= 0 && gmarkers[msSel.idx] && gmarkers[msSel.idx].pwaClustered) {
            try { map.closeInfoWindow(); } catch (e) { }
            msClearSelection();
        }
    }

    // فهرست برگه‌های یک خوشه: هر ردیف یک برگه؛ کلیک = پنجرهء همان برگه
    function BuildClusterInfoHtml(clusterMarker) {
        var html = "<div class='gis-iw gis-iw-pwa'>";
        html += "<h4>" + clusterMarker.pwaMembers.length + " برگهء نزدیک به هم</h4>";
        html += "<table>";
        for (var i = 0; i < clusterMarker.pwaMembers.length; i++) {
            var idx = clusterMarker.pwaMembers[i];
            var sh = gsheets[idx];
            var cat = msCategory(sh);
            html += "<tr><td><span class='pwa-badge' style='background:" + MS_CAT[cat].hex + "'></span>" +
                "<a href='javascript:void(0);' onclick='msOpenSheetFromCluster(" + idx + ");'>" + gisEscapeHtml(msSheetTitle(sh)) + "</a></td>" +
                "<td class='lbl'>" + (cat == 0 ? 'بدون پروژه' : msPct(msAvg(msPwaRows(sh), 'AchievementPct')) + ' تحقق' + (msPwaRows(sh).length > 1 ? ' (' + msPwaRows(sh).length + ' نوع)' : '')) + "</td></tr>";
        }
        html += "</table></div>";
        return html;
    }

    function msOpenSheetFromCluster(idx) {
        var sh = gsheets[idx];
        if (!sh) { return; }
        map.openInfoWindowHtml(new GLatLng(msNum(sh.CentroidLat), msNum(sh.CentroidLong)), BuildSheetInfoHtml(sh));
    }

    // ---- پنل کناری ----
    function msSetAllVisible(mode) {
        var list = document.getElementById('divSearchResult');
        if (!list) { return; }
        var boxes = list.getElementsByTagName('input');
        for (var i = 0; i < boxes.length; i++) {
            var cb = boxes[i];
            if (cb.type != 'checkbox') { continue; }
            cb.checked = (mode == 'all') ? true : (mode == 'none') ? false : !cb.checked;
            var id = cb.id || '';
            if (id.indexOf('Sheet') == 0) { toggleSheet(parseInt(id.substring(5), 10), true); }
        }
        msRebuildClusters();
    }

    function togglePanelSearch() {
        var panel = document.getElementById('divSearchOptions');
        if (panel == null) { return; }
        var open = panel.style.display == 'none';
        panel.style.display = open ? 'block' : 'none';
        document.getElementById('map_SearchArrow').title = open ? 'بستن فهرست' : 'نمایش فهرست';
        if (open) { toggleRegPanel(false); }
        msAfterPanelChange();
    }

    function toggleRegPanel(forceOpen) {
        var panel = document.getElementById('divRegPanel');
        if (panel == null) { return; }
        var open = (typeof forceOpen == 'boolean') ? forceOpen : (panel.style.display == 'none');
        panel.style.display = open ? 'block' : 'none';
        var btn = document.getElementById('btnRegPanel');
        if (btn) { btn.className = 'gis-toggle' + (open ? ' is-active' : ''); }
        if (open) {
            var search = document.getElementById('divSearchOptions');
            if (search) { search.style.display = 'none'; }
        }
        msAfterPanelChange();
    }

    function msAfterPanelChange() {
        gisResizeMap();
        if ((typeof map != 'undefined') && (map != null)) {
            map.checkResize();
            if (gsheets.length > 0) { map.centerAndZoomOnBounds(bounds); }
        }
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
<div class="gis-root">
<table style="width: 100%">
    <tr>
        <td>
            <table style="width: 100%" cellpadding="5" cellspacing="5">
                <tr>
                    <td>
                        <div class="gis-topbar">
                            <div class="gis-fields">
                                <div class="gis-toggles">
                                    <button type="button" class="gis-toggle gis-fs-btn" onclick="gisToggleFullscreen(this);" title="نمایش تمام‌صفحه">
                                        <svg class="gis-fs-enter" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 9V4h5M20 9V4h-5M4 15v5h5M20 15v5h-5" /></svg><svg class="gis-fs-exit" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 4v5H4M15 4v5h5M9 20v-5H4M15 20v-5h5" /></svg>
                                        <span class="gis-fs-enter">تمام‌صفحه</span><span class="gis-fs-exit">خروج از تمام‌صفحه</span>
                                    </button>
                                    <button type="button" id="map_SearchArrow" class="gis-toggle" onclick="togglePanelSearch();" title="نمایش فهرست">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="16" rx="2" /><path d="M15 4v16" /><path d="M6 9h5M6 13h5" /></svg>
                                        <span>فهرست برگه‌ها</span>
                                    </button>
                                    <asp:PlaceHolder ID="phRegToggle" runat="server">
                                        <button type="button" id="btnRegPanel" class="gis-toggle" onclick="toggleRegPanel();" title="بارگذاری Shapefile برگه‌ها (ZIP) و مدیریت بارگذاری‌ها">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3v12M7 10l5 5 5-5" /><path d="M4 17v3h16v-3" /></svg>
                                            <span>ثبت برگه</span>
                                        </button>
                                    </asp:PlaceHolder>
                                    <button type="button" id="btnShowSearchOption" class="gis-toggle" onclick="ShowSearchOptionMapSheet();" title="جستجوی پیشرفته روی مشخصات برگه و پروژه">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 5h18l-7 8v6l-4-2v-4z" /></svg>
                                        <span>جستجو</span>
                                    </button>
                                    <button type="button" id="btnDelSearchOption" class="gis-toggle pwa-toggle-danger" style="display: none;" onclick="DeLSearchOption();" title="حذف شرط‌های جستجوی پیشرفته">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18M8 6V4h8v2M6 6l1 14h10l1-14" /><path d="M10 10v7M14 10v7" /></svg>
                                        <span>حذف شرایط</span>
                                    </button>
                                </div>
                                <div class="gis-field">
                                    <span class="gis-field-label">منطقه پروژه:</span>
                                    <select id="cmbRegion" class="cmbDepartment gis-select" onchange="RefereshAllInMap();">
                                        <option value="همه موارد">همه موارد</option>
                                    </select>
                                </div>
                                <div class="gis-field">
                                    <span class="gis-field-label">برگه:</span>
                                    <span id="gisProjectWrap" class="gis-input-wrap">
                                        <input id="txtSheet" class="NameProjeh gis-input" type="text" placeholder="شماره یا نام برگه (برای انتخاب کلیک کنید)" />
                                        <button type="button" class="gis-clear" onclick="gisClearProject();" title="پاک کردن">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M6 6l12 12M18 6L6 18" /></svg>
                                        </button>
                                        <span id="imgVaziyat" class="VaziyatSelect gis-status">
                                            <svg class="gis-status-ok" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12.5l4.5 4.5L19 7.5" /></svg>
                                            <svg class="gis-status-no" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round"><path d="M6 6l12 12M18 6L6 18" /></svg>
                                        </span>
                                    </span>
                                    <span id="gisProjectHint" class="gis-hint"></span>
                                </div>
                            </div>
                            <div class="gis-topbar-aside">
                                <div class="gis-opacity" title="شفافیت داخل سطح برگه‌ها روی نقشه">
                                    <span class="gis-field-label">شفافیت سطح‌ها:</span>
                                    <input type="range" id="gisAreaOpacity" min="5" max="100" step="5" value="35" oninput="gisApplyAreaOpacity(this.value);" onchange="gisApplyAreaOpacity(this.value);" />
                                    <span id="gisAreaOpacityValue" class="gis-opacity-value">خودکار</span>
                                </div>
                                <div class="gis-opacity" title="از این زوم به بعد هر برگه جدا نمایش داده می‌شود؛ دو پله پایین‌تر برگه‌های هر برگهء مادر یک نشانگر می‌شوند و دورتر از آن برگه‌های نزدیک هم">
                                    <span class="gis-field-label">زوم تک‌برگه:</span>
                                    <input type="range" id="msZoomFull" min="6" max="14" step="1" value="10" oninput="msApplyZoomFull(this.value);" onchange="msApplyZoomFull(this.value); msRebuildClusters();" />
                                    <span id="msZoomFullValue" class="gis-opacity-value">10</span>
                                    <label class="gis-field-label" style="cursor: pointer;" title="برگه‌های نزدیک به هم در زوم‌های دور یک نشانگر شمارنده می‌شوند؛ کلیک روی آن زوم می‌کند">
                                        <input type="checkbox" id="chkCluster" checked="checked" onchange="msClusterEnabled = this.checked; msRebuildClusters();" style="vertical-align: middle; margin: 0 0 0 4px;" />خوشه‌بندی
                                    </label>
                                </div>
                                <div class="gis-legend" title="رنگ برگه = درصد تحقق پروژهء متصل در PWA">
                                    <span class="gis-legend-title">تحقق:</span>
                                    <span class="gis-legend-item"><i style="background: #22c55e"></i>بیش از ۹۰٪</span>
                                    <span class="gis-legend-item"><i style="background: #facc15"></i>۷۰ تا ۹۰٪</span>
                                    <span class="gis-legend-item"><i style="background: #f472b6"></i>۵۰ تا ۷۰٪</span>
                                    <span class="gis-legend-item"><i style="background: #ef4444"></i>کمتر از ۵۰٪</span>
                                    <span class="gis-legend-item"><i style="background: #9ca3af"></i>آغاز نشده</span>
                                    <span class="gis-legend-item"><i style="background: #64748b"></i>بدون پروژه</span>
                                </div>
                            </div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <div class="gis-map-row">
                        <div class="gis-side">
                            <asp:Panel ID="pnlRegPanel" runat="server">
                            <div id="divRegPanel" class="gis-panel" style="display: none;">
                                <div class="gis-panel-inner">
                                    <div class="ms-reg-body">
                                        <div class="ms-reg-title">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3v12M7 10l5 5 5-5" /><path d="M4 17v3h16v-3" /></svg>
                                            <span>ثبت برگه‌های نقشه (Shapefile)</span>
                                        </div>
                                        <div class="ms-hint">
                                            ZIP باید فایل‌های <b>shp</b>، <b>dbf</b>، <b>prj</b> و <b>cpg</b> یک لایهء Polygon را داشته باشد.
                                            ستون <b>P_Code</b> جدول صفت‌ها کلید اتصال به پروژه‌های PWA و ستون <b>N50</b> شمارهء برگه است.
                                            مختصات UTM هنگام ثبت به عرض/طول جغرافیایی تبدیل می‌شود.
                                        </div>
                                        <div class="ms-field">
                                            <label for="<%= fupZip.ClientID %>">فایل ZIP کارفرما</label>
                                            <asp:FileUpload ID="fupZip" runat="server" CssClass="ms-file" accept=".zip,application/zip,application/x-zip-compressed" />
                                        </div>
                                        <div class="ms-field">
                                            <label class="ms-check">
                                                <asp:CheckBox ID="chkOverwrite" runat="server" />
                                                بازنویسی برگه‌هایی که از قبل ثبت شده‌اند
                                            </label>
                                        </div>
                                        <asp:Button ID="btnImport" runat="server" Text="بارگذاری و ثبت در MapSheets" CssClass="ms-btn" OnClientClick="return msBeforeImport();" OnClick="btnImport_Click" />
                                        <asp:HiddenField ID="hdnFocusBatch" runat="server" />
                                        <asp:HiddenField ID="hdnRegOpen" runat="server" />
                                        <div class="ms-result">
                                            <asp:Literal ID="litResult" runat="server"></asp:Literal>
                                        </div>

                                        <div class="ms-reg-sub">بارگذاری‌های ثبت‌شده</div>
                                        <asp:Panel ID="pnlNoBatches" runat="server" CssClass="ms-hint">هنوز هیچ برگه‌ای ثبت نشده است.</asp:Panel>
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
                                                        <asp:LinkButton ID="lnkDelete" runat="server" CssClass="ms-btn-light ms-btn-danger" CommandName="DeleteBatch" CommandArgument='<%# Eval("ImportBatch") %>' OnClientClick='<%# "return confirm(\"همهء " + Eval("Sheets") + " برگهء این بارگذاری حذف شود؟\");" %>' ToolTip="حذف همهء برگه‌های این بارگذاری">حذف</asp:LinkButton>
                                                    </td>
                                                </tr>
                                            </ItemTemplate>
                                            <FooterTemplate>
                                                </table>
                                            </FooterTemplate>
                                        </asp:Repeater>
                                    </div>
                                </div>
                            </div>
                            </asp:Panel>
                            <div id="divSearchOptions" class="gis-panel" style="display: none;">
                                <div id="PanelSearchResult" class="gis-panel-inner">
                                    <div class="gis-panel-head">
                                        <div id="divSearchCount" class="gis-counts"></div>
                                        <div class="gis-toolbar pwa-selbar">
                                            <button type="button" class="gis-tool gis-tool-text" onclick="msSetAllVisible('all');" title="انتخاب همه: نمایش همهء برگه‌ها">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="3" /><path d="M7 12.5l3.5 3.5L17 9" /></svg>
                                                <span>همه</span>
                                            </button>
                                            <button type="button" class="gis-tool gis-tool-text" onclick="msSetAllVisible('invert');" title="انتخاب معکوس: برعکس کردن وضعیت نمایش هر برگه">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 7h11l-3-3M20 17H9l3 3" /></svg>
                                                <span>معکوس</span>
                                            </button>
                                            <button type="button" class="gis-tool gis-tool-text gis-tool-danger" onclick="msSetAllVisible('none');" title="پاک کردن همه: مخفی کردن همهء برگه‌ها">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="3" /><path d="M8 8l8 8M16 8l-8 8" /></svg>
                                                <span>هیچ</span>
                                            </button>
                                        </div>
                                    </div>
                                    <div id="divSearchResult" class="gis-list"></div>
                                </div>
                            </div>
                        </div>
                        <div id="map" class="gis-map"></div>
                        </div>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<asp:Literal runat="server" ID="InitializBounds" />

<script type="text/javascript">
    //<![CDATA[

    GMap.prototype.centerAndZoomOnBounds = function (bounds) {
        var center_lat = (bounds.getNorthEast().lat() + bounds.getSouthWest().lat()) / 2.0;
        var center_lng = (bounds.getNorthEast().lng() + bounds.getSouthWest().lng()) / 2.0;
        var center = new GLatLng(center_lat, center_lng)
        map.setCenter(center, map.getBoundsZoomLevel(bounds));
    }

    if (GBrowserIsCompatible()) {

        // چک‌باکس فهرست: نمایش/مخفی سطح و پین یک برگه (عضویت خوشه‌ها با مخفی/نمایش شدن یک برگه عوض می‌شود)
        function toggleSheet(idx, skipRebuild) {
            var cb = document.getElementById('Sheet' + idx);
            if (!cb || !gpolys[idx] || !gmarkers[idx]) { return; }
            gmarkers[idx].pwaUserHidden = !cb.checked;
            if (!cb.checked && msSel.idx == idx) {
                map.closeInfoWindow();
                msClearSelection();
            }
            if (!skipRebuild) { msRebuildClusters(); }
        }

        // آیکون پین‌ها: msSheetIcon (SVG درون‌خطی به شکل برگهء نقشه)؛ پین‌های گرد Marker/<Color>/marker.png این‌جا استفاده نمی‌شوند

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
        map.centerAndZoomOnBounds(bounds);
        GEvent.addListener(map, "click", function (overlay, point) {
            if (!overlay) {
                map.closeInfoWindow();
            }
        });
        // با بسته شدن پنجرهء اطلاعات، حالت انتخاب سطح/پین/ردیف فهرست هم پاک می‌شود
        GEvent.addListener(map, "infowindowclose", function () {
            msClearSelection();
        });
        // با هر تغییر زوم، خوشه‌بندی دوباره محاسبه می‌شود
        GEvent.addListener(map, "zoomend", function () {
            msRebuildClusters();
        });
    }
    else {
        alert("Sorry, the Google Maps API is not compatible with this browser");
    }

    //]]>
</script>
</div>
