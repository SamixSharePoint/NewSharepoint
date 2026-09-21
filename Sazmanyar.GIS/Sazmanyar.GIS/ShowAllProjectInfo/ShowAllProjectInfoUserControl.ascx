<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ShowAllProjectInfoUserControl.ascx.cs" Inherits="Sazmanyar.GIS.ShowAllProjectInfo.ShowAllProjectInfoUserControl" %>

<%--
    نقشهء پروژه‌های Project Web App (جدول PWAInfo)
    ------------------------------------------------
    الگو: ShowAllKoridorInfoUserControl_ViewTemplate1
      * کمبوی «دپارتمان»  -> کمبوی «نوع پروژه» (پیش‌فرض: همه موارد؛ در بارگذاری اولیه همهء انواع نمایش داده می‌شود)
      * فیلد «نام پروژه»   -> فیلد «منطقه پروژه» با پیشنهاد خودکار
    رفتار:
      * هر منطقه یک ناحیه (چندضلعی) دارد که در لحظه از پوستهء محدب پین‌های همان منطقه ساخته می‌شود
        (اگر کمتر از 3 نقطهء متمایز داشته باشد، یک دایرهء تقریبی دور نقاط کشیده می‌شود).
      * پروژه‌هایی که مختصات یکسان دارند یک پین می‌شوند و در InfoWindow جدا از هم فهرست می‌شوند
        (پروژهء چندنوعی در PWAInfo چند سطر است؛ هر سطر با نوع خودش نمایش داده می‌شود).
      * رنگ پین و ناحیه با همان دسته‌های تحقق GISInfo: 1 سبز (>90٪) 2 زرد (70-90) 3 صورتی (50-70) 4 قرمز (<50) 5 خاکستری (آغاز نشده)
      * برگه‌های واقعی (dbo.MapSheets، ستون JSON «Sheets» در خروجی FetchPWAProjects): پروژه‌ای که برگه دارد
        - پین آن روی مرکز برگه (میانگین مرکز برگه‌ها) می‌نشیند، نه Lat/Long تقریبی PWAInfo
        - مرز واقعی برگه‌هایش پیش‌فرض فقط وقتی پین انتخاب شود کشیده می‌شود؛ با چک‌باکس «سطح برگه‌ها» (خاصیت ShowSheetAreas)
          مرز همهء برگه‌ها به‌صورت یک گروه سطح برای هر پروژه (یک ردیف در فهرست) با رنگ تحقق کشیده می‌شود
        - در ساخت ناحیهء تقریبی منطقه شرکت نمی‌کند (اگر همهء پروژه‌های منطقه برگه داشته باشند، ناحیهء تقریبی کشیده نمی‌شود)
        - پین آن آیکون «برگهء نقشه» (SVG درون‌خطی، همان ShowAllMapSheetInfo) است؛ چند پروژه در یک پین = دستهء برگه + نشان تعداد
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
        max-height: 360px;
        overflow-y: auto;
        overflow-x: hidden;
        padding-left: 6px;
        min-width: 340px;
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

    /* تب‌های پین چندپروژه‌ای */
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

    /* ---- انتخاب و انیمیشن مارکر / ناحیه / ردیف فهرست ---- */
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

    /* کلاس روی عنصر نگهدارندهء تصویر مارکر (div با overflow:hidden) می‌نشیند تا بزرگ‌نمایی و سایه بریده نشود */
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

    /* شرح گفتاری فیلترهای فعال بالای شمارنده‌های پنل جستجو */
    .gis-root .gis-filter-summary {
        font-size: 12px;
        line-height: 1.8;
        color: #6b7280;
        margin-bottom: 6px;
        white-space: normal;
    }

    .gis-root .gis-filter-summary.is-active {
        color: #1e3a8a;
        background: #eff6ff;
        border-right: 3px solid #2563eb;
        border-radius: 6px;
        padding: 4px 8px;
    }

    /* نوار بالا: بخش «شفافیت ناحیه‌ها + راهنمای تحقق» همیشه در گوشهء چپ می‌ماند و به ردیف پایین نمی‌افتد؛
       اگر جا کم باشد فیلدهای سمت راست (دکمه‌ها، نوع، منطقه) داخل خودشان می‌شکنند، نه بخش چپ */
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
        margin-right: auto;   /* در RTL یعنی چسبیده به چپ */
        align-items: flex-end; /* داخل ستون هم اسلایدر و راهنما به لبهء چپ بچسبند */
    }

    .gis-root .gis-legend {
        flex-wrap: wrap;
        max-width: 460px;
        row-gap: 4px;
    }

    /* دکمهء جستجوی پیشرفته وقتی شرط فعال دارد، و دکمهء حذف شرایط */
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

    /* نوار «همه / معکوس / هیچ» بالای فهرست: فشرده، تک‌خطی، هم‌عرض */
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
</style>
<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GIS/Script/css/gis-ui.css?v=20260921c" />
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-1.7.1.min.js" type="text/javascript"></script>
<link href="/_layouts/15/Sazmanyar.GIS/Script/css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" />
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-ui-1.10.3.custom.min.js" type="text/javascript"></script>
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/gis-ui.js?v=20260921" type="text/javascript" charset="utf-8"></script>
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
    var pwaShowSheetAreas = <%= ShowSheetAreas ? "true" : "false" %>;   // مرز همهء برگه‌های واقعی کشیده شود؟ (وگرنه فقط برای پین انتخاب‌شده)
    var availableTags = [];            // فهرست منطقه‌ها برای پیشنهاد خودکار
    var bVaziyatSelect = false;        // آیا منطقهء معتبری انتخاب شده؟
    var currentRegion = "";
    var strCurrentWebUrl = window.location.protocol + "//" + window.location.host + _spPageContextInfo.webServerRelativeUrl;
    var strFetchUrl = strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/";

    // ---- جستجوی پیشرفته (همان سازوکار قالب 1: صفحهء FilterProject.html داخل fancybox، خروجی query-builder به‌صورت SQL) ----
    var SearchOption_Project = null;   // { sql: "SELECT * FROM table WHERE ..." } که صفحهء فیلتر برمی‌گرداند
    var SearchDescription_Project = '';  // شرح گفتاری شرط‌ها (از صفحهء فیلتر می‌آید) برای نمایش در پنل جستجو

    function ShowSearchOptionProject() {
        X.fancybox({
            'width': 960,
            'height': 600,
            'padding': 0,
            'autoScale': false,
            'transitionIn': 'none',
            'transitionOut': 'none',
            'type': 'iframe',
            'href': '/_layouts/15/Sazmanyar.GIS/FilterProject.html?nc=' + new Date().getTime()
        });
    }

    // صفحهء فیلتر با این تابع شرط‌های قبلی را برای «پیش فرض شرایط» می‌گیرد
    function GetRulesWidgets_Project() {
        if (SearchOption_Project != null) {
            var Sql = SearchOption_Project.sql.replace("SELECT * FROM table WHERE ", "").replace(/NNNNNNNNNNN/g, "").replace(/DDDDDDDDDDD/g, ""); // For Unicode Support
            if (Sql.trim().length == 0) {
                return null;
            }
            SearchOption_Project.sql = Sql;
        }
        return SearchOption_Project;
    }

    function setInformation_Project(data, description) {
        SearchOption_Project = data;
        SearchDescription_Project = description || '';
        return SearchOption_Project;
    }

    // صفحهء فیلتر بعد از «جستجوی اطلاعات» این را صدا می‌زند
    function ShowAllRoutInMap() {
        RefereshAllInMap();
    }

    function DeLSearchOption() {
        SearchOption_Project = null;
        SearchDescription_Project = '';
        RefereshAllInMap();
    }

    // جملهء گفتاری فیلترهای فعال (نوع پروژه، منطقه، شرط‌های جستجوی پیشرفته) بالای شمارنده‌های پنل جستجو
    function pwaFilterSummary() {
        var type = GetSelectedProjectType();
        var region = bVaziyatSelect ? currentRegion : '';
        var adv = (pwaGetSearchCondition().length > 0) ? SearchDescription_Project : '';
        var s = 'همهء پروژه‌ها';
        if (type && region) { s = 'پروژه‌های «' + type + '» در منطقهء «' + region + '»'; }
        else if (type) { s = 'پروژه‌های نوع «' + type + '»'; }
        else if (region) { s = 'پروژه‌های منطقهء «' + region + '»'; }
        if (adv) { s = (s == 'همهء پروژه‌ها' ? 'پروژه‌هایی' : s) + ' با شرط: ' + adv; }
        var cls = (type || region || adv) ? 'gis-filter-summary is-active' : 'gis-filter-summary';
        return '<div class="' + cls + '" title="فیلترهای اعمال‌شده روی فهرست و نقشه">' + gisEscapeHtml(s) + '</div>';
    }

    // فهرست نوع‌ها و منطقه‌ها برای فیلترهای انتخابی صفحهء جستجو
    function pwaFilterLists() {
        var types = [];
        try {
            var control = document.getElementById('<%= cmbProjectType.ClientID %>');
            for (var i = 0; i < control.options.length; i++) {
                if (control.options[i].value != 'همه موارد') { types.push(control.options[i].value); }
            }
        } catch (e) { }
        return { types: types, regions: availableTags.slice() };
    }

    // شرطی که به سرور می‌رود (کوتیشن -> #@# تا در JSON/URL مشکلی نسازد؛ سرور برمی‌گرداند)
    function pwaGetSearchCondition() {
        if (SearchOption_Project == null || SearchOption_Project.sql == null) { return ""; }
        var Condition = SearchOption_Project.sql.replace("SELECT * FROM table WHERE ", "").replace(/'/g, "#@#").replace(/NNNNNNNNNNN/g, "N");
        return Condition.trim();
    }

    // نمایش/مخفی‌کردن دکمهء «حذف شرایط» و نشانهء فیلتر فعال
    function pwaUpdateSearchState() {
        var active = pwaGetSearchCondition().length > 0;
        var btnDel = document.getElementById('btnDelSearchOption');
        var btnSearch = document.getElementById('btnShowSearchOption');
        if (btnDel) { btnDel.style.display = active ? '' : 'none'; }
        if (btnSearch) {
            btnSearch.className = 'gis-toggle' + (active ? ' is-active' : '');
            btnSearch.title = active ? 'جستجوی پیشرفته (شرط فعال است) - برای ویرایش کلیک کنید' : 'جستجوی پیشرفته روی فیلدهای پروژه';
        }
    }

    // ---- دسته‌های تحقق (همان کدهای GISInfo.TahaghoghRoute) ----
    var PWA_CAT = {
        1: { title: 'بیش از ۹۰٪', hex: '#22c55e', marker: 'Green' },
        2: { title: '۷۰ تا ۹۰٪', hex: '#facc15', marker: 'Yellow' },
        3: { title: '۵۰ تا ۷۰٪', hex: '#f472b6', marker: 'Pink' },
        4: { title: 'کمتر از ۵۰٪', hex: '#ef4444', marker: 'Red' },
        5: { title: 'آغاز نشده', hex: '#9ca3af', marker: 'Gray' }
    };

    function pwaNum(v) {
        var n = parseFloat(String(v == null ? '' : v).replace(/[۰-۹]/g, function (d) { return String.fromCharCode(d.charCodeAt(0) - 1776 + 48); }));
        return isNaN(n) ? 0 : n;
    }

    // دستهء تحقق از روی میانگین درصد تحقق و پیشرفت واقعی یک مجموعه پروژه
    function pwaCategory(rows) {
        var sumAch = 0, sumAct = 0, n = 0;
        for (var i = 0; i < rows.length; i++) {
            sumAch += pwaNum(rows[i].AchievementPct);
            sumAct += pwaNum(rows[i].ActualProgress);
            n++;
        }
        if (n == 0 || sumAct == 0) { return 5; }
        var ach = sumAch / n;
        if (ach > 90) { return 1; }
        if (ach > 70) { return 2; }
        if (ach > 50) { return 3; }
        return 4;
    }

    function pwaVal(v) {
        if (v == null || v == '' || v == 'NULL') { return '-'; }
        return gisEscapeHtml(v);
    }

    // برگه‌های واقعی یک سطر (ستون Sheets: JSON آرایهء برگه‌های MapSheets)؛ یک بار پارس و روی خود شیء کش می‌شود
    function pwaSheets(r) {
        if (!r) { return []; }
        if (r._sheets) { return r._sheets; }
        var arr = [];
        try { arr = JSON.parse(r.Sheets || '[]'); } catch (e) { arr = []; }
        if (!arr || !arr.length) { arr = []; }
        r._sheets = arr;
        return arr;
    }

    // موقعیت مؤثر پین یک سطر: اگر برگه دارد میانگین مرکز برگه‌ها، وگرنه Lat/Long تقریبی PWAInfo
    function pwaEffectivePos(r) {
        if (r._pos) { return r._pos; }
        var sheets = pwaSheets(r);
        var pos = { lat: pwaNum(r.Lat), lng: pwaNum(r.Long), fromSheet: false };
        if (sheets.length > 0) {
            var sLat = 0, sLng = 0, n = 0;
            for (var i = 0; i < sheets.length; i++) {
                var la = pwaNum(sheets[i].CentroidLat), ln = pwaNum(sheets[i].CentroidLong);
                if (la == 0 && ln == 0) { continue; }
                sLat += la; sLng += ln; n++;
            }
            if (n > 0) { pos = { lat: sLat / n, lng: sLng / n, fromSheet: true }; }
        }
        r._pos = pos;
        return pos;
    }

    function pwaSheetLabel(sheets) {
        var parts = [];
        for (var i = 0; i < sheets.length; i++) {
            parts.push(String(sheets[i].SheetNo || '') + (sheets[i].SheetNameFa ? ' ' + sheets[i].SheetNameFa : ''));
        }
        return parts.join('، ');
    }

    // ---- آیکون پین پروژه‌های برگه‌دار: SVG درون‌خطی به شکل برگهء نقشه (همان msSheetIcon در ShowAllMapSheetInfo) ----
    // count > 1 (چند پروژه در یک پین): چند برگهء روی هم (تا 3 لایه) + نشان گرد تعداد. هر (رنگ، تعداد، شناسهء انتخاب) یک بار
    // ساخته و کش می‌شود. selIdx فقط برای پین انتخاب‌شده: id داخل SVG تا عنصر <img> آن در DOM پیدا و انیمیت شود
    // (افزودن ?pwasel= به data: URI، که برای پین‌های تصویری استفاده می‌شود، SVG را خراب می‌کند).
    var pwaSheetIconCache = {};
    function pwaSheetIcon(hex, selIdx, count) {
        count = count || 1;
        var key = hex + '|' + count + '|' + (selIdx == null ? '' : selIdx);
        if (pwaSheetIconCache[key]) { return pwaSheetIconCache[key]; }
        var w = 30, h = 38;
        var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="' + w + '" height="' + h + '" viewBox="0 0 30 38">' +
            (selIdx == null ? '<g>' : '<g id="pwasel-' + selIdx + '">') +
            '<path d="M13 37 L8 29 H18 Z" fill="#1f2937"/>';
        var layers = Math.min(3, count);
        for (var L = layers - 1; L >= 1; L--) {
            svg += '<g transform="translate(' + (3 * L) + ',' + (-3 * L) + ')">' +
                '<path d="M3.5 6.5 H17 L22.5 12 V29.5 H3.5 Z" fill="' + hex + '" stroke="#1f2937" stroke-width="1.2" stroke-linejoin="round"/>' +
                '<path d="M3.5 6.5 H17 L22.5 12 V29.5 H3.5 Z" fill="#ffffff" fill-opacity="' + (0.25 * L) + '"/>' +
                '</g>';
        }
        svg += '<path d="M3.5 6.5 H17 L22.5 12 V29.5 H3.5 Z" fill="' + hex + '" stroke="#1f2937" stroke-width="1.4" stroke-linejoin="round"/>' +
            '<path d="M17 6.5 V12 H22.5" fill="#ffffff" fill-opacity="0.85" stroke="#1f2937" stroke-width="1.2" stroke-linejoin="round"/>' +
            '<path d="M9.5 12.5 V29.5 M16 15 V29.5 M3.5 18 H22.5 M3.5 23.5 H22.5" stroke="#ffffff" stroke-opacity="0.85" stroke-width="1.1"/>';
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
        pwaSheetIconCache[key] = icon;
        return icon;
    }

    // آیا دست‌کم یکی از سطرهای یک پین برگهء واقعی دارد؟
    function pwaRowsHaveSheets(rows) {
        for (var i = 0; i < rows.length; i++) { if (pwaSheets(rows[i]).length > 0) { return true; } }
        return false;
    }

    function pwaPct(v) {
        if (v == null || v == '' || v == 'NULL') { return '-'; }
        return gisEscapeHtml(String(Math.round(pwaNum(v) * 100) / 100)) + '٪';
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
            RefershPishnahadInfo();
        });
    }

    function GetSelectedProjectType() {
        var control = document.getElementById('<%= cmbProjectType.ClientID %>');
        var selectedvalue = control.options[control.selectedIndex].value;
        if (selectedvalue == 'همه موارد') { return ''; }
        return selectedvalue;
    }

    // با تغییر نوع پروژه: فهرست منطقه‌های آن نوع را می‌گیرد، پیشنهاد خودکار را می‌سازد و نقشه را تازه می‌کند
    function RefershPishnahadInfo() {

        var strProjectType = GetSelectedProjectType();

        X.ajax({
            type: "POST",
            url: strFetchUrl + "FetchPWARegions",
            data: JSON.stringify({ 'ProjectType': strProjectType }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (strHtmlOutput) {
                availableTags = (strHtmlOutput.d != null) ? strHtmlOutput.d : [];

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

                // اگر منطقهء قبلی در نوع جدید وجود ندارد، فیلد پاک شود
                var cur = X(".NameProjeh").val();
                if (cur != null && cur != '' && X.inArray(cur, availableTags) < 0) {
                    X(".NameProjeh").val('');
                }
                FillSugestion_Pishnahadi();
            },
            error: function (MSG) {
                alert('error' + MSG.responseText);
            }
        });
    }

    // وضعیت فیلد «منطقه پروژه» و تازه‌سازی نقشه (نام تابع برای سازگاری با gis-ui.js حفظ شده)
    function FillSugestion_Pishnahadi() {
        var strRegion = X(".NameProjeh").val();
        if (strRegion == null || strRegion.toString().length == 0) {
            gisSetProjectStatus('none');
            bVaziyatSelect = false;
            currentRegion = "";
            RefereshAllInMap();
            return;
        }

        gisSetProjectStatus('invalid');
        bVaziyatSelect = false;
        currentRegion = "";
        for (var i = 0; i < availableTags.length; i++) {
            if (strRegion == availableTags[i]) {
                gisSetProjectStatus('valid');
                bVaziyatSelect = true;
                currentRegion = strRegion;
                break;
            }
        }
        RefereshAllInMap();
    }

    // ---- بارگذاری پروژه‌ها و رسم ----
    var gmarkers = [];     // پین‌ها (هر پین = یک نقطه با یک یا چند پروژه)
    var gpolys = [];       // استفاده نمی‌شود؛ برای سازگاری با gis-ui.js
    var ggans = [];        // ناحیه‌های مناطق
    var divSearchResult_html = "";
    var map;

    function RefereshAllInMap() {
        if (typeof map == 'undefined' || map == null) { return; }

        var strProjectType = GetSelectedProjectType();
        var strRegion = bVaziyatSelect ? currentRegion : "";
        var strCondition = pwaGetSearchCondition();
        pwaUpdateSearchState();
        try { X.fancybox.close(); } catch (e) { }

        document.getElementById("divSearchCount").innerHTML = '';
        document.getElementById('divSearchResult').innerHTML = '<div class="gis-msg gis-msg-wait">لطفاً کمی صبر نمایید ...<br />سیستم در حال جستجوی اطلاعات مورد نیاز شما می باشد</div>';

        pwaClearSelection();
        gmarkers = [];
        ggans = [];
        map.clearOverlays();
        divSearchResult_html = "";
        bounds = new GLatLngBounds();

        X.ajax({
            type: "POST",
            url: strFetchUrl + "FetchPWAProjects",
            data: JSON.stringify({ 'ProjectType': strProjectType, 'Region': strRegion, 'Condition': strCondition }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (strHtmlOutput) {
                var result = strHtmlOutput.d;
                if (result == null || result.length == 0) {
                    pwaLastRows = null;
                    document.getElementById("divSearchCount").innerHTML = pwaFilterSummary();
                    document.getElementById('divSearchResult').innerHTML = '<div class="gis-msg">هیچ موردی جهت نمایش در لیست یافت نشد</div>';
                    map.centerAndZoomOnBounds(new GLatLngBounds(new GLatLng(39.027719, 44.736328), new GLatLng(26.745610, 62.050781)));
                    return;
                }
                pwaLastRows = result;
                DrawPWAProjects(result, false);
            },
            error: function (MSG) {
                alert('error' + MSG.responseText);
            }
        });
    }

    function DrawPWAProjects(rows, bKeepView) {
        // 1) گروه‌بندی بر اساس منطقه و بر اساس نقطه
        var byRegion = {}, regionOrder = [];
        var byPoint = {}, pointOrder = [];
        var nProjects = 0;

        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            var pos = pwaEffectivePos(r);
            var lat = pos.lat, lng = pos.lng;
            if (lat == 0 || lng == 0) { continue; }
            nProjects++;

            var regionKey = (r.Region == null || r.Region == '') ? '(بدون منطقه)' : r.Region;
            if (!byRegion[regionKey]) { byRegion[regionKey] = []; regionOrder.push(regionKey); }
            byRegion[regionKey].push(r);

            var pointKey = lat.toFixed(5) + ',' + lng.toFixed(5);
            if (!byPoint[pointKey]) { byPoint[pointKey] = { lat: lat, lng: lng, rows: [], regionCounts: {} }; pointOrder.push(pointKey); }
            byPoint[pointKey].rows.push(r);
            // معمولاً همهء ردیف‌های یک نقطه از یک منطقه‌اند؛ اگر (به‌ندرت) نبودند، منطقهء غالب انتخاب می‌شود
            byPoint[pointKey].regionCounts[regionKey] = (byPoint[pointKey].regionCounts[regionKey] || 0) + 1;
        }

        // منطقهء غالب هر نقطه (برای خوشه‌بندی پین‌ها در همان منطقه، نه سراسر نقشه)
        for (var pk = 0; pk < pointOrder.length; pk++) {
            var ptRec = byPoint[pointOrder[pk]];
            var bestRegion = null, bestCount = -1;
            for (var rk in ptRec.regionCounts) {
                if (ptRec.regionCounts[rk] > bestCount) { bestCount = ptRec.regionCounts[rk]; bestRegion = rk; }
            }
            ptRec.region = bestRegion;
        }

        // 2) ناحیه‌های هر منطقه: نقاط منطقه خوشه‌بندی می‌شوند (فاصلهء آستانه از اسلایدر) و هر خوشه یک لکهء نرم می‌شود؛
        //    نقاط تک یا دوتایی دایره می‌گیرند. همهء لکه‌های یک منطقه در یک گروه (PwaRegionGroup) با یک ردیف در فهرست.
        var areaHtml = "";
        var clusterKm = pwaGetClusterKm();
        for (var a = 0; a < regionOrder.length; a++) {
            var regionName = regionOrder[a];
            var regionRows = byRegion[regionName];
            var pts = [];
            var seen = {};
            for (var j = 0; j < regionRows.length; j++) {
                // پروژه‌ای که برگهء واقعی دارد در ناحیهء تقریبی منطقه شرکت نمی‌کند (مرز واقعی‌اش جدا کشیده می‌شود)
                if (pwaSheets(regionRows[j]).length > 0) { continue; }
                var k = pwaNum(regionRows[j].Lat).toFixed(5) + ',' + pwaNum(regionRows[j].Long).toFixed(5);
                if (seen[k]) { continue; }
                seen[k] = true;
                pts.push({ lat: pwaNum(regionRows[j].Lat), lng: pwaNum(regionRows[j].Long) });
            }
            var shapes = pwaClusterShapes(pts, clusterKm);
            if (shapes.length == 0) { continue; }

            var cat = pwaCategory(regionRows);
            var color = PWA_CAT[cat].hex;
            var polys = [];
            for (var s = 0; s < shapes.length; s++) {
                var shape = shapes[s];
                var PolygonPoints = [];
                for (var h = 0; h < shape.length; h++) {
                    PolygonPoints.push(new GLatLng(shape[h].lat, shape[h].lng));
                }
                PolygonPoints.push(new GLatLng(shape[0].lat, shape[0].lng));
                var Polygon = new GPolygon(PolygonPoints, color, 1.5, 0.8, color, gisAreaOpacity(null), { clickable: true });
                polys.push(Polygon);
            }

            var group = new PwaRegionGroup(polys, regionName, color);
            ggans.push(group);
            var gan_num = ggans.length - 1;

            (function (grp, html, num) {
                GEvent.addListener(grp, 'click', function (point) {
                    if (!point) {
                        // کلیک از فهرست کناری: مرکز ناحیه
                        var b = grp.getBounds();
                        point = b ? b.getCenter() : grp.getVertex(0);
                        map.panTo(point);
                    }
                    pwaSelectPolygon(grp, num);
                    map.openInfoWindowHtml(point, html);
                });
                for (var q = 0; q < grp.polys.length; q++) {
                    GEvent.addListener(grp.polys[q], 'click', function (point) {
                        GEvent.trigger(grp, 'click', point);
                    });
                }
            })(group, BuildRegionInfoHtml(regionName, regionRows, cat), gan_num);

            var lbl = regionName + ' [' + regionRows.length + ' پروژه' + (shapes.length > 1 ? ' - ' + shapes.length + ' ناحیه' : '') + ']';
            areaHtml += gisResultItem('area', 'Gan', gan_num, 'toggleGan', color, 'ggans', lbl);

            var gb = group.getBounds();
            if (gb) {
                bounds.extend(gb.getNorthEast());
                bounds.extend(gb.getSouthWest());
            }
            for (var o = 0; o < polys.length; o++) { map.addOverlay(polys[o]); }
        }

        // 2b) مرز واقعی برگه‌ها: هر پروژهء برگه‌دار (کد پروژه) یک گروه سطح با همان رابط PwaRegionGroup و یک ردیف در فهرست؛
        //     رنگ = دستهء تحقق همهء سطرهای آن کد؛ کلیک = همان پنجرهء پین (با تب برای پروژهء چندنوعی)
        var byCode = {}, codeOrder = [];
        for (var sc = 0; sc < rows.length; sc++) {
            var sr = rows[sc];
            if (!pwaShowSheetAreas) { break; }   // سطح‌ها خاموش: مرز برگه فقط هنگام انتخاب پین کشیده می‌شود (pwaShowSelectedSheets)
            if (pwaSheets(sr).length == 0) { continue; }
            var ck = (sr.ProjectCode == null || sr.ProjectCode == '') ? ('#' + sc) : sr.ProjectCode;
            if (!byCode[ck]) { byCode[ck] = []; codeOrder.push(ck); }
            byCode[ck].push(sr);
        }
        for (var cc = 0; cc < codeOrder.length; cc++) {
            var codeRows = byCode[codeOrder[cc]];
            var sheets = pwaSheets(codeRows[0]);
            var scat = pwaCategory(codeRows);
            var scolor = PWA_CAT[scat].hex;
            var spolys = [];
            for (var sh = 0; sh < sheets.length; sh++) {
                var ring = [];
                try {
                    var arr = JSON.parse(sheets[sh].Boundary || '[]');
                    for (var v = 0; v < arr.length; v++) {
                        var la = pwaNum(arr[v].lat), ln = pwaNum(arr[v].lng);
                        if (la == 0 && ln == 0) { continue; }
                        ring.push(new GLatLng(la, ln));
                    }
                } catch (e) { ring = []; }
                if (ring.length < 3) { continue; }
                ring.push(ring[0]);
                var spoly = new GPolygon(ring, scolor, 2, 0.9, scolor, gisAreaOpacity(null), { clickable: true });
                spoly.pwaColor = scolor;
                spolys.push(spoly);
            }
            if (spolys.length == 0) { continue; }

            var sgroup = new PwaRegionGroup(spolys, codeRows[0].Region || '', scolor);
            ggans.push(sgroup);
            var sgan_num = ggans.length - 1;

            (function (grp, html, num) {
                GEvent.addListener(grp, 'click', function (point) {
                    if (!point) {
                        var b = grp.getBounds();
                        point = b ? b.getCenter() : grp.getVertex(0);
                        map.panTo(point);
                    }
                    pwaSelectPolygon(grp, num);
                    map.openInfoWindowHtml(point, html);
                });
                for (var q = 0; q < grp.polys.length; q++) {
                    GEvent.addListener(grp.polys[q], 'click', function (point) {
                        GEvent.trigger(grp, 'click', point);
                    });
                }
            })(sgroup, BuildPinInfoHtml(codeRows), sgan_num);

            var slbl = 'برگه ' + pwaSheetLabel(sheets) + ' [' + pwaPinTitle(codeRows) + (sheets.length > 1 ? ' - ' + sheets.length + ' برگه' : '') + ']';
            areaHtml += gisResultItem('area', 'Gan', sgan_num, 'toggleGan', scolor, 'ggans', slbl);

            var sgb = sgroup.getBounds();
            if (sgb) {
                bounds.extend(sgb.getNorthEast());
                bounds.extend(sgb.getSouthWest());
            }
            for (var so = 0; so < spolys.length; so++) { map.addOverlay(spolys[so]); }
        }

        // 3) پین‌ها (یک پین برای هر نقطه؛ InfoWindow همهء پروژه‌های آن نقطه را فهرست می‌کند)
        var pinHtml = "";
        for (var p = 0; p < pointOrder.length; p++) {
            var pt = byPoint[pointOrder[p]];
            var pcat = pwaCategory(pt.rows);
            var pcolor = PWA_CAT[pcat].hex;
            var point = new GLatLng(pt.lat, pt.lng);
            var title = pwaPinTitle(pt.rows);

            // پین برگه‌دار: آیکون برگهء نقشه (چند پروژه = دستهء برگه + نشان تعداد)؛ بقیه: پین گرد رنگی
            var bSheetPin = pwaRowsHaveSheets(pt.rows);
            var pIcon = bSheetPin ? pwaSheetIcon(pcolor, null, pt.rows.length) : get_icon(PWA_CAT[pcat].marker);
            var marker = new GMarker(point, { icon: pIcon, title: title + (pt.rows.length > 1 ? ' (' + pt.rows.length + ' پروژه)' : '') });
            marker.pwaRows = pt.rows;
            marker.pwaImage = pIcon.image;
            marker.pwaIsSheet = bSheetPin;
            marker.pwaColor = pcolor;
            marker.pwaCount = pt.rows.length;
            marker.pwaHtml = BuildPinInfoHtml(pt.rows);
            marker.pwaRegion = pt.region;   // برای خوشه‌بندی پین‌ها در محدودهء همان منطقه (بخش «خوشه‌بندی پین‌ها»)
            marker.pwaUserHidden = false;   // با چک‌باکس فهرست مخفی شده؟
            marker.pwaClustered = false;    // داخل یک خوشه پنهان شده؟
            gmarkers.push(marker);
            var marker_num = gmarkers.length - 1;

            (function (mk, num) {
                GEvent.addListener(mk, "click", function () {
                    pwaSelectMarker(mk, num);
                    mk.openInfoWindowHtml(mk.pwaHtml);
                });
            })(marker, marker_num);

            pinHtml += gisResultItem('station', 'marker', marker_num, 'togglemarker', pcolor, 'gmarkers', title + ' [' + pt.rows.length + ' پروژه]');

            bounds.extend(point);
            map.addOverlay(marker);
        }

        divSearchResult_html = areaHtml + pinHtml;
        document.getElementById("divSearchCount").innerHTML = pwaFilterSummary() + pwaCountChips(regionOrder.length, pointOrder.length, nProjects);
        document.getElementById("divSearchResult").innerHTML = divSearchResult_html;

        if (!bKeepView && (regionOrder.length > 0 || pointOrder.length > 0)) {
            map.centerAndZoomOnBounds(bounds);
        }
        // خوشه‌بندی پین‌ها برای زوم فعلی (با تغییر زوم، رویداد zoomend دوباره محاسبه می‌کند)
        pwaRebuildMarkerClusters();
    }

    function pwaCountChips(regions, points, projects) {
        return '<span class="gis-chip" title="منطقه">' + GIS_ICON_AREA + ' منطقه <b>' + regions + '</b></span>' +
            '<span class="gis-chip" title="نقطه">' + GIS_ICON_STATION + ' نقطه <b>' + points + '</b></span>' +
            '<span class="gis-chip" title="پروژه">' + GIS_ICON_ROUTE + ' پروژه <b>' + projects + '</b></span>';
    }

    // عنوان پین: نام محل (بخش بعد از خط تیره در نام پروژه) یا نام کوتاه‌شدهء اولین پروژه
    function pwaPinTitle(rows) {
        var name = String(rows[0].ProjectName || '');
        name = name.replace(/\d{9,}/g, '').replace(/\s+/g, ' ').trim();
        var parts = name.split(/\s*[-–—]+\s*/);
        var t = parts.length > 1 ? parts[parts.length - 1] : name;
        t = t.replace(/[-–—\s]+$/, '');
        if (t.length > 40) { t = t.substring(0, 40) + '…'; }
        return t;
    }

    // ---- انتخاب (Highlight) مارکر یا ناحیه + انیمیشن ----
    // فقط یک مورد در هر لحظه انتخاب است؛ با بسته شدن InfoWindow یا انتخاب مورد دیگر، حالت قبلی برمی‌گردد.
    var pwaSel = { marker: null, markerImg: '', poly: null, polyTimer: null, listEl: null, sheetOverlays: [] };
    var PWA_SEL_STROKE = '#1d4ed8';

    // مرز برگه‌های واقعی پروژه‌های یک پین انتخاب‌شده (فقط وقتی «سطح برگه‌ها» خاموش است): موقت، با بستن پنجره پاک می‌شود
    function pwaShowSelectedSheets(rows) {
        pwaHideSelectedSheets();
        if (pwaShowSheetAreas) { return; }
        var seen = {};
        var cat = pwaCategory(rows);
        var color = PWA_CAT[cat].hex;
        for (var i = 0; i < rows.length; i++) {
            var sheets = pwaSheets(rows[i]);
            for (var sh = 0; sh < sheets.length; sh++) {
                var key = String(sheets[sh].SheetNo || sh);
                if (seen[key]) { continue; }
                seen[key] = true;
                var ring = [];
                try {
                    var arr = JSON.parse(sheets[sh].Boundary || '[]');
                    for (var v = 0; v < arr.length; v++) {
                        var la = pwaNum(arr[v].lat), ln = pwaNum(arr[v].lng);
                        if (la == 0 && ln == 0) { continue; }
                        ring.push(new GLatLng(la, ln));
                    }
                } catch (e) { ring = []; }
                if (ring.length < 3) { continue; }
                ring.push(ring[0]);
                var poly = new GPolygon(ring, PWA_SEL_STROKE, 3, 1, color, Math.min(0.85, gisAreaOpacity(null) + 0.15), { clickable: false });
                map.addOverlay(poly);
                pwaSel.sheetOverlays.push(poly);
            }
        }
    }

    function pwaHideSelectedSheets() {
        for (var i = 0; i < pwaSel.sheetOverlays.length; i++) {
            try { map.removeOverlay(pwaSel.sheetOverlays[i]); } catch (e) { }
        }
        pwaSel.sheetOverlays = [];
    }

    // چک‌باکس «سطح برگه‌ها» در ریبون
    function pwaToggleSheetAreas(checked) {
        pwaShowSheetAreas = !!checked;
        pwaRedraw();
    }

    function pwaHighlightListItem(checkboxId) {
        if (pwaSel.listEl) {
            pwaSel.listEl.className = pwaSel.listEl.className.replace(/\s*is-selected/g, '');
            pwaSel.listEl = null;
        }
        var cb = document.getElementById(checkboxId);
        if (!cb || !cb.parentNode) { return; }
        var el = cb.parentNode;
        el.className += ' is-selected';
        pwaSel.listEl = el;
        try {
            var panel = document.getElementById('divSearchOptions');
            if (panel && panel.style.display != 'none' && el.scrollIntoView) {
                el.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
            }
        } catch (e) { }
    }

    function pwaClearSelection() {
        pwaHideSelectedSheets();
        // مارکر: تصویر اصلی برمی‌گردد
        if (pwaSel.marker) {
            try { pwaSel.marker.setImage(pwaSel.markerImg); } catch (e) { }
            pwaSel.marker = null; pwaSel.markerImg = '';
        }
        var els = document.querySelectorAll('.gis-root .pwa-marker-selected');
        for (var i = 0; i < els.length; i++) { els[i].className = els[i].className.replace(/\s*pwa-marker-selected/g, ''); }

        // ناحیه: استایل اصلی برمی‌گردد
        if (pwaSel.polyTimer) { clearInterval(pwaSel.polyTimer); pwaSel.polyTimer = null; }
        if (pwaSel.poly) {
            try {
                pwaSel.poly.setStrokeStyle({ color: pwaSel.poly.pwaColor, weight: 2, opacity: 0.9 });
                pwaSel.poly.setFillStyle({ color: pwaSel.poly.pwaColor, opacity: gisAreaOpacity(null) });
            } catch (e) { }
            pwaSel.poly = null;
        }

        if (pwaSel.listEl) {
            pwaSel.listEl.className = pwaSel.listEl.className.replace(/\s*is-selected/g, '');
            pwaSel.listEl = null;
        }
    }

    // مارکر انتخاب‌شده: تصویر همان رنگ با یک نشانهء یکتا در آدرس، تا بتوان عنصر <img> آن را در DOM پیدا و انیمیت کرد
    function pwaSelectMarker(mk, marker_num) {
        pwaClearSelection();
        pwaSel.marker = mk;
        pwaSel.markerImg = mk.pwaImage;
        // پین تصویری: نشانهء یکتا در query string؛ پین SVG برگه: id داخل خود SVG
        var selector;
        if (mk.pwaIsSheet) {
            try { mk.setImage(pwaSheetIcon(mk.pwaColor, marker_num, mk.pwaCount).image); } catch (e) { }
            selector = '.gis-root img[src*="pwasel-' + marker_num + '%22"]';
        }
        else {
            try { mk.setImage(mk.pwaImage + '?pwasel=' + marker_num); } catch (e) { }
            selector = '.gis-root img[src*="pwasel=' + marker_num + '"]';
        }
        setTimeout(function () {
            var imgs = document.querySelectorAll(selector);
            for (var i = 0; i < imgs.length; i++) {
                // موتور نقشه تصویر مارکر را داخل یک div با overflow:hidden می‌گذارد؛ کلاس روی همان div می‌نشیند
                var el = (imgs[i].parentNode && imgs[i].parentNode.tagName == 'DIV') ? imgs[i].parentNode : imgs[i];
                if (el.className.indexOf('pwa-marker-selected') < 0) { el.className += ' pwa-marker-selected'; }
            }
        }, 30);
        pwaHighlightListItem('marker' + marker_num);
        // پین برگه‌دار: مرز برگه‌هایش (فقط وقتی سطح‌ها خاموش‌اند)
        if (mk.pwaIsSheet) { pwaShowSelectedSheets(mk.pwaRows); }
    }

    // ناحیهء انتخاب‌شده: خط دور ضخیم آبی + چند ضربان شفافیت داخل، سپس ثابت روی حالت پررنگ‌تر
    function pwaSelectPolygon(poly, gan_num) {
        pwaClearSelection();
        pwaSel.poly = poly;
        var base = gisAreaOpacity(null);
        var hi = Math.min(0.85, base + 0.3);
        try { poly.setStrokeStyle({ color: PWA_SEL_STROKE, weight: 4, opacity: 1 }); } catch (e) { }
        var step = 0;
        pwaSel.polyTimer = setInterval(function () {
            step++;
            var on = (step % 2 == 1);
            try { poly.setFillStyle({ color: poly.pwaColor, opacity: on ? hi : base }); } catch (e) { }
            if (step >= 6) {
                clearInterval(pwaSel.polyTimer); pwaSel.polyTimer = null;
                try { poly.setFillStyle({ color: poly.pwaColor, opacity: Math.min(0.85, base + 0.15) }); } catch (e) { }
            }
        }, 180);
        pwaHighlightListItem('Gan' + gan_num);
    }

    // ---- HTML پنجرهء اطلاعات ----
    var pwaInfoSeq = 0; // شمارندهء یکتا برای شناسهء تب‌های هر پنجره

    // نوار مقایسهء پیشرفت: آبی روشن = برنامه‌ای، آبی تیره = واقعی (هر دو 0 تا 100)
    function pwaBarHtml(plan, act) {
        var p = Math.max(0, Math.min(100, pwaNum(plan)));
        var a = Math.max(0, Math.min(100, pwaNum(act)));
        return "<div class='pwa-bar' title='برنامه‌ای: " + pwaPct(p) + " / واقعی: " + pwaPct(a) + "'>" +
            "<i class='plan' style='width:" + p + "%'></i><i class='act' style='width:" + a + "%'></i></div>";
    }

    // جزئیات یک پروژه (بدنهء هر تب)
    function BuildProjectDetailHtml(r, bShowName) {
        var rcat = pwaCategory([r]);
        var html = "";
        if (bShowName) {
            html += "<div class='pwa-name'><span class='pwa-badge' style='background:" + PWA_CAT[rcat].hex + "' title='" + PWA_CAT[rcat].title + "'></span>" + pwaVal(r.ProjectName) + "</div>";
        }
        html += "<table>";
        html += "<tr><td class='lbl'>نوع پروژه:</td><td><b>" + pwaVal(r.ProjectType) + "</b></td><td class='lbl'>کد:</td><td>" + pwaVal(r.ProjectCode) + "</td></tr>";
        html += "<tr><td class='lbl'>وضعیت:</td><td>" + pwaVal(r.Status) + "</td><td class='lbl'>نحوه اجرا:</td><td>" + pwaVal(r.ExecutionMethod) + "</td></tr>";
        html += "<tr><td class='lbl'>پیشرفت برنامه‌ای:</td><td>" + pwaPct(r.PlannedProgress) + "</td><td class='lbl'>پیشرفت واقعی:</td><td>" + pwaPct(r.ActualProgress) + "</td></tr>";
        html += "<tr><td class='lbl'>درصد تحقق:</td><td><b>" + pwaPct(r.AchievementPct) + "</b></td><td colspan='2'>" + pwaBarHtml(r.PlannedProgress, r.ActualProgress) + "</td></tr>";
        html += "<tr><td class='lbl'>شروع:</td><td>" + pwaVal(r.StartDateJ) + "</td><td class='lbl'>پایان:</td><td>" + pwaVal(r.FinishDateJ) + "</td></tr>";
        html += "<tr><td class='lbl'>شروع برنامه‌ای:</td><td>" + pwaVal(r.PlannedStartJ) + "</td><td class='lbl'>پایان برنامه‌ای:</td><td>" + pwaVal(r.PlannedFinishJ) + "</td></tr>";
        html += "<tr><td class='lbl'>مدیر پروژه:</td><td>" + pwaVal(r.ProjectManager) + "</td><td class='lbl'>ناظر پروژه:</td><td>" + pwaVal(r.ProjectSupervisor) + "</td></tr>";
        html += "</table>";
        // مشخصات کامل برگه(های) واقعی این پروژه - همان بخش «مشخصات برگه» در ShowAllMapSheetInfo
        var sheets = pwaSheets(r);
        for (var si = 0; si < sheets.length; si++) {
            html += BuildSheetBlockHtml(sheets[si]);
        }
        return html;
    }

    function pwaScale(v) {
        var n = pwaNum(v);
        if (n <= 0) { return '-'; }
        return '1:' + String(n).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    }

    // بلوک یک برگهء واقعی داخل پنجرهء پین: شماره، مادر/ربع، نام‌ها، مساحت، مرکز، مجری/ناظر/زمین‌شناس به روایت فایل کارفرما، منبع
    function BuildSheetBlockHtml(sh) {
        var title = 'برگه ' + String(sh.SheetNo || '') + (sh.SheetNameFa ? ' - ' + sh.SheetNameFa : (sh.SheetNameEn ? ' - ' + sh.SheetNameEn : ''));
        var html = "<div class='pwa-item'><div class='pwa-name'>" + gisEscapeHtml(title) + " <small>(" + pwaScale(sh.SheetScale) + ")</small></div><table>";
        html += "<tr><td class='lbl'>شماره برگه:</td><td><b>" + pwaVal(sh.SheetNo) + "</b></td><td class='lbl'>برگه مادر / ربع:</td><td>" + pwaVal(sh.SheetSeries) + " / " + pwaVal(sh.SheetQuarter) + "</td></tr>";
        html += "<tr><td class='lbl'>نام فارسی:</td><td>" + pwaVal(sh.SheetNameFa) + "</td><td class='lbl'>نام انگلیسی:</td><td>" + pwaVal(sh.SheetNameEn) + "</td></tr>";
        html += "<tr><td class='lbl'>مساحت:</td><td>" + (sh.AreaKm2 ? gisEscapeHtml(String(Math.round(pwaNum(sh.AreaKm2)))) + " km²" : "-") + "</td><td class='lbl'>مرکز:</td><td>" + pwaVal(sh.CentroidLat) + " , " + pwaVal(sh.CentroidLong) + "</td></tr>";
        if (sh.Contractor || sh.Supervisor || sh.Geologist) {
            html += "<tr><td class='lbl'>مجری (فایل):</td><td>" + pwaVal(sh.Contractor) + "</td><td class='lbl'>ناظر (فایل):</td><td>" + pwaVal(sh.Supervisor) + "</td></tr>";
            if (sh.Geologist) { html += "<tr><td class='lbl'>زمین‌شناس:</td><td colspan='3'>" + pwaVal(sh.Geologist) + "</td></tr>"; }
        }
        if (sh.LinkProjectName) {
            html += "<tr><td class='lbl'>عنوان در فایل کارفرما:</td><td colspan='3' style='white-space:normal'>" + pwaVal(sh.LinkProjectName) + "</td></tr>";
        }
        html += "<tr><td class='lbl'>منبع:</td><td colspan='3' style='white-space:normal'>" + pwaVal(sh.SourceFile) + (sh.SourceLayer ? " / " + gisEscapeHtml(sh.SourceLayer) : "") + (sh.SourceCrs ? " - " + gisEscapeHtml(sh.SourceCrs) : "") + "</td></tr>";
        html += "</table></div>";
        return html;
    }

    // پنجرهء پین: یک پروژه = بدون تب؛ چند پروژه = یک تب برای هر پروژه (برچسب تب: نوع پروژه)
    function BuildPinInfoHtml(rows) {
        var cat = pwaCategory(rows);
        var html = "<div class='gis-iw gis-iw-pwa'>";
        html += "<h4><span class='pwa-badge' style='background:" + PWA_CAT[cat].hex + "'></span>" +
            gisEscapeHtml(pwaPinTitle(rows)) + " <small>(" + rows.length + " پروژه" + (rows[0].Region ? " - " + gisEscapeHtml(rows[0].Region) : "") + ")</small></h4>";

        if (rows.length == 1) {
            html += "<div class='pwa-item'>" + BuildProjectDetailHtml(rows[0], true) + "</div>";
            html += "</div>";
            return html;
        }

        pwaInfoSeq++;
        var tabId = 'pwaTabs' + pwaInfoSeq;

        // اگر چند پروژه نوع یکسان داشته باشند، شماره به برچسب تب اضافه می‌شود
        var typeCount = {}, typeSeen = {};
        for (var c = 0; c < rows.length; c++) {
            var tc = (rows[c].ProjectType == null || rows[c].ProjectType == '') ? 'بدون نوع' : rows[c].ProjectType;
            typeCount[tc] = (typeCount[tc] || 0) + 1;
        }

        html += "<div class='pwa-tabs' id='" + tabId + "'>";
        html += "<div class='pwa-tab-strip'>";
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            var rcat = pwaCategory([r]);
            var label = (r.ProjectType == null || r.ProjectType == '') ? 'بدون نوع' : r.ProjectType;
            if (typeCount[label] > 1) {
                typeSeen[label] = (typeSeen[label] || 0) + 1;
                label = label + ' (' + typeSeen[label] + ')';
            }
            html += "<a href='javascript:void(0);' class='pwa-tab" + (i == 0 ? " is-active" : "") + "' data-idx='" + i + "'" +
                " onclick=\"pwaShowTab('" + tabId + "', " + i + ");\" title='" + gisEscapeHtml(r.ProjectName) + "'>" +
                "<span class='pwa-badge' style='background:" + PWA_CAT[rcat].hex + "'></span>" + gisEscapeHtml(label) + "</a>";
        }
        html += "</div>";
        for (var j = 0; j < rows.length; j++) {
            html += "<div class='pwa-tab-panel" + (j == 0 ? " is-active" : "") + "' data-idx='" + j + "'>" +
                BuildProjectDetailHtml(rows[j], true) + "</div>";
        }
        html += "</div>";
        html += "</div>";
        return html;
    }

    // تغییر تب فعال داخل پنجرهء اطلاعات پین
    function pwaShowTab(tabId, idx) {
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

    function BuildRegionInfoHtml(regionName, rows, cat) {
        var n = rows.length, sumPlan = 0, sumAct = 0, sumAch = 0, done = 0, notStarted = 0;
        var types = {}, typeOrder = [];
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            var rp = pwaNum(r.PlannedProgress), ra = pwaNum(r.ActualProgress);
            sumPlan += rp;
            sumAct += ra;
            sumAch += pwaNum(r.AchievementPct);
            if (ra >= 100) { done++; }
            if (ra == 0) { notStarted++; }
            var t = (r.ProjectType == null || r.ProjectType == '') ? '(بدون نوع)' : r.ProjectType;
            if (!types[t]) { types[t] = { n: 0, plan: 0, act: 0, rows: [] }; typeOrder.push(t); }
            types[t].n++; types[t].plan += rp; types[t].act += ra; types[t].rows.push(r);
        }
        var avgPlan = sumPlan / n, avgAct = sumAct / n;
        var html = "<div class='gis-iw gis-iw-pwa'>";
        html += "<h4><span class='pwa-badge' style='background:" + PWA_CAT[cat].hex + "'></span>منطقه: " + gisEscapeHtml(regionName) + "</h4>";
        html += "<table>";
        html += "<tr><td class='lbl'>تعداد پروژه:</td><td><b>" + n + "</b></td><td class='lbl'>تکمیل‌شده:</td><td>" + done + "</td></tr>";
        html += "<tr><td class='lbl'>آغاز نشده:</td><td>" + notStarted + "</td><td class='lbl'>دستهء تحقق:</td><td>" + PWA_CAT[cat].title + "</td></tr>";
        html += "<tr><td class='lbl'>میانگین پیشرفت برنامه‌ای:</td><td>" + pwaPct(avgPlan) + "</td><td class='lbl'>میانگین پیشرفت واقعی:</td><td>" + pwaPct(avgAct) + "</td></tr>";
        html += "<tr><td class='lbl'>میانگین درصد تحقق:</td><td><b>" + pwaPct(sumAch / n) + "</b></td><td colspan='2'>" + pwaBarHtml(avgPlan, avgAct) + "</td></tr>";
        html += "</table>";
        html += "<div class='pwa-item'><div class='pwa-name'>به تفکیک نوع پروژه</div><table>";
        for (var k = 0; k < typeOrder.length; k++) {
            var ty = types[typeOrder[k]];
            var tcat = pwaCategory(ty.rows);
            html += "<tr><td class='lbl'><span class='pwa-badge' style='background:" + PWA_CAT[tcat].hex + "'></span>" + gisEscapeHtml(typeOrder[k]) + "</td>" +
                "<td><b>" + ty.n + "</b></td>" +
                "<td class='lbl'>" + pwaPct(ty.act / ty.n) + " از " + pwaPct(ty.plan / ty.n) + "</td>" +
                "<td>" + pwaBarHtml(ty.plan / ty.n, ty.act / ty.n) + "</td></tr>";
        }
        html += "</table></div>";
        html += "<div class='gis-hint'>مرز ناحیه به‌صورت تقریبی از موقعیت پین‌های همین منطقه ساخته شده است؛ پروژه‌های دارای برگهء واقعی جداگانه با مرز خودشان نمایش داده می‌شوند.</div>";
        html += "</div>";
        return html;
    }

    // ---- هندسه: پوستهء محدب (Andrew monotone chain) + دایرهء تقریبی برای نقاط کم ----
    function pwaConvexHull(points) {
        var pts = points.slice().sort(function (a, b) { return a.lng == b.lng ? a.lat - b.lat : a.lng - b.lng; });
        if (pts.length < 3) { return pts; }
        function cross(o, a, b) { return (a.lng - o.lng) * (b.lat - o.lat) - (a.lat - o.lat) * (b.lng - o.lng); }
        var lower = [];
        for (var i = 0; i < pts.length; i++) {
            while (lower.length >= 2 && cross(lower[lower.length - 2], lower[lower.length - 1], pts[i]) <= 0) { lower.pop(); }
            lower.push(pts[i]);
        }
        var upper = [];
        for (var j = pts.length - 1; j >= 0; j--) {
            while (upper.length >= 2 && cross(upper[upper.length - 2], upper[upper.length - 1], pts[j]) <= 0) { upper.pop(); }
            upper.push(pts[j]);
        }
        lower.pop(); upper.pop();
        return lower.concat(upper);
    }

    // شکل یک خوشه: پوستهء محدبِ «دایره‌های دور هر نقطه» (شعاع حاشیه). نتیجه همیشه گوشه‌های گرد دارد، هر نقطه با
    // حاشیهء کامل داخل شکل است، و برای نقاط هم‌خط یا تکی هم درست کار می‌کند (کپسول / دایره).
    var PWA_SHAPE_MARGIN_KM = 9;     // حاشیهء دور هر پین
    var PWA_SINGLE_RADIUS_KM = 12;   // شعاع دایرهء پین تنها

    function pwaRegionShape(points) {
        if (points.length == 0) { return []; }
        var r = (points.length == 1) ? PWA_SINGLE_RADIUS_KM : PWA_SHAPE_MARGIN_KM;
        var cloud = [];
        for (var i = 0; i < points.length; i++) {
            var circ = pwaCircle(points[i].lat, points[i].lng, r, 24);
            for (var c = 0; c < circ.length; c++) { cloud.push(circ[c]); }
        }
        var hull = pwaConvexHull(cloud);
        if (hull.length < 3) { return pwaCircle(points[0].lat, points[0].lng, PWA_SINGLE_RADIUS_KM, 32); }
        // یک بار گردکردن اضافه تا اتصال کمان‌ها به خط‌های راست نرم‌تر شود
        return pwaChaikin(hull, 1);
    }

    // خوشه‌بندی تک‌پیوندی: دو نقطه که فاصله‌شان کمتر از آستانه است در یک خوشه‌اند (اتحاد مجموعه‌ها)
    function pwaClusterPoints(points, thresholdKm) {
        var n = points.length;
        var parent = [];
        for (var i = 0; i < n; i++) { parent[i] = i; }
        function find(x) { while (parent[x] != x) { parent[x] = parent[parent[x]]; x = parent[x]; } return x; }
        for (var a = 0; a < n; a++) {
            for (var b = a + 1; b < n; b++) {
                if (pwaDistKm(points[a].lat, points[a].lng, points[b].lat, points[b].lng) <= thresholdKm) {
                    var ra = find(a), rb = find(b);
                    if (ra != rb) { parent[ra] = rb; }
                }
            }
        }
        var groups = {}, order = [];
        for (var c = 0; c < n; c++) {
            var r = find(c);
            if (!groups[r]) { groups[r] = []; order.push(r); }
            groups[r].push(points[c]);
        }
        var out = [];
        for (var g = 0; g < order.length; g++) { out.push(groups[order[g]]); }
        return out;
    }

    // شکل‌های یک منطقه: هر خوشه یک شکل (آرایه‌ای از {lat,lng})
    function pwaClusterShapes(points, thresholdKm) {
        var shapes = [];
        var clusters = pwaClusterPoints(points, thresholdKm);
        for (var i = 0; i < clusters.length; i++) {
            var shape = pwaRegionShape(clusters[i]);
            if (shape.length >= 3) { shapes.push(shape); }
        }
        return shapes;
    }

    // آیا نقطه داخل چندضلعی است؟ (ray casting)
    function pwaPointInPoly(pt, poly) {
        var inside = false;
        for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
            var a = poly[i], b = poly[j];
            if (((a.lat > pt.lat) != (b.lat > pt.lat)) &&
                (pt.lng < (b.lng - a.lng) * (pt.lat - a.lat) / (b.lat - a.lat) + a.lng)) {
                inside = !inside;
            }
        }
        return inside;
    }

    // گردکردن گوشه‌ها (الگوریتم Chaikin) روی چندضلعی بسته؛ هر تکرار تعداد رئوس را دو برابر می‌کند
    function pwaChaikin(poly, iterations) {
        var pts = poly;
        for (var it = 0; it < iterations; it++) {
            var out = [];
            var n = pts.length;
            for (var i = 0; i < n; i++) {
                var p = pts[i], q = pts[(i + 1) % n];
                out.push({ lat: 0.75 * p.lat + 0.25 * q.lat, lng: 0.75 * p.lng + 0.25 * q.lng });
                out.push({ lat: 0.25 * p.lat + 0.75 * q.lat, lng: 0.25 * p.lng + 0.75 * q.lng });
            }
            pts = out;
        }
        return pts;
    }

    // گروه لکه‌های یک منطقه: همان رابط GPolygon که بقیهء کد (فهرست، شفافیت، انتخاب) انتظار دارد، روی همهء لکه‌ها اعمال می‌شود
    function PwaRegionGroup(polys, regionName, color) {
        this.polys = polys;
        this.pwaRegion = regionName;
        this.pwaColor = color;
        this.gisOpacity = gisAreaOpacity(null);
        this.hidden = false;
    }
    PwaRegionGroup.prototype.show = function () { this.hidden = false; for (var i = 0; i < this.polys.length; i++) { this.polys[i].show(); } };
    PwaRegionGroup.prototype.hide = function () { this.hidden = true; for (var i = 0; i < this.polys.length; i++) { this.polys[i].hide(); } };
    PwaRegionGroup.prototype.isHidden = function () { return this.hidden; };
    PwaRegionGroup.prototype.setFillStyle = function (o) { for (var i = 0; i < this.polys.length; i++) { try { this.polys[i].setFillStyle(o); } catch (e) { } } };
    PwaRegionGroup.prototype.setStrokeStyle = function (o) { for (var i = 0; i < this.polys.length; i++) { try { this.polys[i].setStrokeStyle(o); } catch (e) { } } };
    PwaRegionGroup.prototype.getVertex = function (i) { return this.polys[0].getVertex(i); };
    PwaRegionGroup.prototype.getBounds = function () {
        var b = null;
        for (var i = 0; i < this.polys.length; i++) {
            var pb = this.polys[i].getBounds ? this.polys[i].getBounds() : null;
            if (!pb) { continue; }
            if (!b) { b = new GLatLngBounds(pb.getSouthWest(), pb.getNorthEast()); }
            else { b.extend(pb.getNorthEast()); b.extend(pb.getSouthWest()); }
        }
        return b;
    };

    // ---- اسلایدر فاصلهء خوشه‌بندی ----
    var pwaLastRows = null;   // آخرین نتیجهء سرور برای بازترسیم بدون درخواست مجدد

    function pwaGetClusterKm() {
        var el = document.getElementById('gisClusterKm');
        var v = el ? parseInt(el.value, 10) : 70;
        return isNaN(v) ? 70 : v;
    }

    function pwaApplyClusterKm(value) {
        var lbl = document.getElementById('gisClusterKmValue');
        if (lbl) { lbl.innerHTML = value + ' km'; }
    }

    // بازترسیم با داده‌ی فعلی (بدون درخواست به سرور و بدون تغییر زوم)
    function pwaRedraw() {
        if (!pwaLastRows || typeof map == 'undefined' || map == null) { return; }
        pwaClearSelection();
        try { map.closeInfoWindow(); } catch (e) { }
        gmarkers = [];
        ggans = [];
        map.clearOverlays();
        divSearchResult_html = "";
        bounds = new GLatLngBounds();
        DrawPWAProjects(pwaLastRows, true);
    }

    function pwaCircle(lat, lng, radiusKm, n) {
        var out = [];
        var dLat = radiusKm / 111.32;
        var dLng = radiusKm / (111.32 * Math.cos(lat * Math.PI / 180));
        for (var i = 0; i < n; i++) {
            var a = 2 * Math.PI * i / n;
            out.push({ lat: lat + dLat * Math.sin(a), lng: lng + dLng * Math.cos(a) });
        }
        return out;
    }

    function pwaDistKm(lat1, lng1, lat2, lng2) {
        var R = 6371, p1 = lat1 * Math.PI / 180, p2 = lat2 * Math.PI / 180;
        var dp = p2 - p1, dl = (lng2 - lng1) * Math.PI / 180;
        var h = Math.sin(dp / 2) * Math.sin(dp / 2) + Math.cos(p1) * Math.cos(p2) * Math.sin(dl / 2) * Math.sin(dl / 2);
        return 2 * R * Math.asin(Math.sqrt(h));
    }

    // ---- خوشه‌بندی پین‌ها (MarkerClusterer سبک، وابسته به زوم) ----
    // پین‌هایی که در زوم فعلی روی هم می‌افتند (فاصله‌شان کمتر از حدود 40 پیکسل است) یک نشانگر شمارنده می‌شوند.
    // خوشه‌بندی همیشه داخل یک منطقه انجام می‌شود، نه بین دو منطقهء مجاور؛ در نتیجه هیچ ناحیه‌ای که پین دارد
    // بدون خوشه/پین نمی‌ماند، و موقعیت نشانگر خوشه همیشه روی یکی از پین‌های واقعی (Medoid) است، نه میانگین
    // ریاضی، تا همیشه داخل شکل ناحیهء خودش بیفتد.
    // کلیک روی خوشه: زوم به داخل؛ در بیشترین زوم: فهرست پروژه‌های خوشه. با هر تغییر زوم دوباره محاسبه می‌شود.
    var pwaClusterEnabled = <%= EnableClustering ? "true" : "false" %>;   // پیش‌فرض از خاصیت وب‌پارت EnableClustering
    var pwaClusterMarkers = [];          // نشانگرهای خوشه که الان روی نقشه‌اند
    var PWA_CLUSTER_PX = 40;             // فاصلهء پیکسلی ادغام
    var PWA_MAX_CLUSTER_ZOOM = 13;       // از این زوم به بعد کلیک روی خوشه فهرست را نشان می‌دهد (کاشی‌های آفلاین تا 14)

    // فاصلهء کیلومتری معادل PWA_CLUSTER_PX پیکسل در زوم فعلی (مقیاس وب‌مرکاتور در عرض ~33 درجه)
    function pwaClusterThresholdKm() {
        var z = 6;
        try { z = map.getZoom(); } catch (e) { }
        return PWA_CLUSTER_PX * 156.543 * 0.84 / Math.pow(2, z);
    }

    function pwaApplyMarkerVisibility(m) {
        if (m.pwaUserHidden || m.pwaClustered) { m.hide(); } else { m.show(); }
    }

    // آیکون خوشه (SVG درون‌خطی، بدون فایل تصویری): هالهء کم‌رنگ + حلقهء رنگی (دستهء تحقق میانگین) + دایرهء سفید + عدد.
    // اندازه با تعداد بزرگ می‌شود. آیکون هر (تعداد، رنگ) یک بار ساخته و کش می‌شود.
    var pwaClusterIconCache = {};
    function pwaClusterIconWithCount(count, hex) {
        var key = count + '|' + hex;
        if (pwaClusterIconCache[key]) { return pwaClusterIconCache[key]; }
        var size = count < 10 ? 34 : (count < 50 ? 40 : 46);
        var half = size / 2;
        var fontSize = count < 100 ? 13 : 11;
        var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="' + size + '" height="' + size + '" viewBox="0 0 ' + size + ' ' + size + '">' +
            '<circle cx="' + half + '" cy="' + half + '" r="' + (half - 1) + '" fill="' + hex + '" fill-opacity="0.35"/>' +
            '<circle cx="' + half + '" cy="' + half + '" r="' + (half - 5) + '" fill="' + hex + '"/>' +
            '<circle cx="' + half + '" cy="' + half + '" r="' + (half - 9) + '" fill="#ffffff"/>' +
            '<text x="' + half + '" y="' + half + '" dy="0.36em" text-anchor="middle" font-family="Arial, Tahoma" font-size="' + fontSize + '" font-weight="bold" fill="#111827">' + count + '</text>' +
            '</svg>';
        var icon = new GIcon();
        icon.image = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg);
        icon.iconSize = new GSize(size, size);
        icon.iconAnchor = new GPoint(half, half);
        icon.infoWindowAnchor = new GPoint(half, 2);
        pwaClusterIconCache[key] = icon;
        return icon;
    }

    // نزدیک‌ترین عضو خوشه به میانگین مختصات (Medoid)؛ چون هر پین از قبل داخل شکل ناحیهء خودش تضمین‌شده
    // است (به همان روش پوستهء محدب+حاشیهء pwaRegionShape)، قرار دادن نشانگر خوشه دقیقاً روی یکی از پین‌های
    // واقعی، به‌جای میانگین ریاضی، تضمین می‌کند خوشه همیشه داخل محدودهء ناحیه بماند، نه در فاصلهء بین دو ناحیه.
    function pwaClusterMedoid(cl) {
        var sumLat = 0, sumLng = 0;
        for (var i = 0; i < cl.length; i++) { sumLat += cl[i].lat; sumLng += cl[i].lng; }
        var cLat = sumLat / cl.length, cLng = sumLng / cl.length;
        var best = cl[0], bestD = Infinity;
        for (var j = 0; j < cl.length; j++) {
            var d = pwaDistKm(cl[j].lat, cl[j].lng, cLat, cLng);
            if (d < bestD) { bestD = d; best = cl[j]; }
        }
        return best;
    }

    function pwaRebuildMarkerClusters() {
        if (typeof map == 'undefined' || map == null) { return; }
        for (var c = 0; c < pwaClusterMarkers.length; c++) {
            try { map.removeOverlay(pwaClusterMarkers[c]); } catch (e) { }
        }
        pwaClusterMarkers = [];

        if (!pwaClusterEnabled) {
            for (var i = 0; i < gmarkers.length; i++) { gmarkers[i].pwaClustered = false; pwaApplyMarkerVisibility(gmarkers[i]); }
            return;
        }

        // پین‌هایی که کاربر مخفی نکرده، به تفکیک منطقه (تا خوشه هرگز از مرز یک ناحیه به ناحیهء دیگر پل نزند
        // و در نتیجه هیچ ناحیه‌ای بدون خوشه/پین داخلش نماند)
        var byRegion = {};
        for (var k = 0; k < gmarkers.length; k++) {
            var m = gmarkers[k];
            if (m.pwaUserHidden) { m.pwaClustered = false; m.hide(); continue; }
            var ll = m.getLatLng();
            var rk = m.pwaRegion || '(بدون منطقه)';
            if (!byRegion[rk]) { byRegion[rk] = []; }
            byRegion[rk].push({ lat: ll.lat(), lng: ll.lng(), idx: k });
        }

        var thresholdKm = pwaClusterThresholdKm();
        for (var regionKey in byRegion) {
            var clusters = pwaClusterPoints(byRegion[regionKey], thresholdKm);
            for (var q = 0; q < clusters.length; q++) {
                var cl = clusters[q];
                if (cl.length == 1) {
                    var single = gmarkers[cl[0].idx];
                    single.pwaClustered = false;
                    pwaApplyMarkerVisibility(single);
                    continue;
                }
                var rows = [], members = [];
                for (var j = 0; j < cl.length; j++) {
                    var gm = gmarkers[cl[j].idx];
                    gm.pwaClustered = true;
                    gm.hide();
                    rows = rows.concat(gm.pwaRows);
                    members.push(cl[j].idx);
                }
                var medoid = pwaClusterMedoid(cl);
                var center = new GLatLng(medoid.lat, medoid.lng);
                var cat = pwaCategory(rows);
                var cm = new GMarker(center, { icon: pwaClusterIconWithCount(rows.length, PWA_CAT[cat].hex), title: rows.length + ' پروژه در ' + cl.length + ' نقطه' });
                cm.pwaMembers = members;
                cm.pwaRows = rows;
                (function (clusterMarker, pos) {
                    GEvent.addListener(clusterMarker, 'click', function () {
                        var z = map.getZoom();
                        if (z < PWA_MAX_CLUSTER_ZOOM) {
                            map.setCenter(pos, Math.min(PWA_MAX_CLUSTER_ZOOM, z + 2));
                        }
                        else {
                            map.openInfoWindowHtml(pos, BuildClusterInfoHtml(clusterMarker));
                        }
                    });
                })(cm, center);
                pwaClusterMarkers.push(cm);
                map.addOverlay(cm);
            }
        }

        // اگر مارکر انتخاب‌شده داخل خوشه رفت، انتخاب و پنجره بسته شود
        if (pwaSel.marker && pwaSel.marker.pwaClustered) {
            try { map.closeInfoWindow(); } catch (e) { }
            pwaClearSelection();
        }
    }

    // فهرست پروژه‌های یک خوشه (در بیشترین زوم): هر ردیف یک پین؛ کلیک = پنجرهء همان پین
    function BuildClusterInfoHtml(clusterMarker) {
        var html = "<div class='gis-iw gis-iw-pwa'>";
        html += "<h4>" + clusterMarker.pwaRows.length + " پروژه در " + clusterMarker.pwaMembers.length + " نقطهء نزدیک به هم</h4>";
        html += "<table>";
        for (var i = 0; i < clusterMarker.pwaMembers.length; i++) {
            var idx = clusterMarker.pwaMembers[i];
            var m = gmarkers[idx];
            var cat = pwaCategory(m.pwaRows);
            html += "<tr><td><span class='pwa-badge' style='background:" + PWA_CAT[cat].hex + "'></span>" +
                "<a href='javascript:void(0);' onclick='pwaOpenPinFromCluster(" + idx + ");'>" + gisEscapeHtml(pwaPinTitle(m.pwaRows)) + "</a></td>" +
                "<td class='lbl'>" + m.pwaRows.length + " پروژه</td></tr>";
        }
        html += "</table></div>";
        return html;
    }

    function pwaOpenPinFromCluster(idx) {
        var m = gmarkers[idx];
        if (!m) { return; }
        pwaHighlightListItem('marker' + idx);
        map.openInfoWindowHtml(m.getLatLng(), m.pwaHtml);
    }

    // ---- پنل کناری ----
    // انتخاب همه / انتخاب معکوس / پاک کردن همه: روی چک‌باکس‌های فهرست (مناطق و پین‌ها) اعمال و روی نقشه هم نمایش/مخفی می‌کند
    function pwaSetAllVisible(mode) {
        var list = document.getElementById('divSearchResult');
        if (!list) { return; }
        var boxes = list.getElementsByTagName('input');
        for (var i = 0; i < boxes.length; i++) {
            var cb = boxes[i];
            if (cb.type != 'checkbox') { continue; }
            var checked = (mode == 'all') ? true : (mode == 'none') ? false : !cb.checked;
            cb.checked = checked;
            var id = cb.id || '';
            try {
                if (id.indexOf('marker') == 0) {
                    var m = gmarkers[parseInt(id.substring(6), 10)];
                    if (m) { m.pwaUserHidden = !checked; pwaApplyMarkerVisibility(m); }
                }
                else if (id.indexOf('Gan') == 0) {
                    var g = ggans[parseInt(id.substring(3), 10)];
                    if (g) { if (checked) { g.show(); } else { g.hide(); } }
                }
            } catch (e) { }
        }
        pwaRebuildMarkerClusters();
        // اگر مورد انتخاب‌شده مخفی شد، پنجرهء اطلاعات و حالت انتخاب هم بسته شود
        var sel = pwaSel.marker || pwaSel.poly;
        if (sel) {
            var hidden = false;
            try { hidden = sel.isHidden(); } catch (e) { }
            if (hidden) {
                map.closeInfoWindow();
                pwaClearSelection();
            }
        }
    }

    function togglePanelSearch() {
        if (document.getElementById('divSearchOptions') == null) { return; }
        if (document.getElementById('divSearchOptions').style.display == 'none') {
            document.getElementById('divSearchOptions').style.display = 'block';
            document.getElementById('map_SearchArrow').title = 'بستن فهرست';
        }
        else {
            document.getElementById('divSearchOptions').style.display = 'none';
            document.getElementById('map_SearchArrow').title = 'نمایش فهرست';
        }
        gisResizeMap();
        if ((typeof map != 'undefined') && (map != null)) {
            map.checkResize();
            if (gmarkers.length > 0 || ggans.length > 0) { map.centerAndZoomOnBounds(bounds); }
        }
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
                                        <span>فهرست مناطق و پین‌ها</span>
                                    </button>
                                    <button type="button" id="btnShowSearchOption" class="gis-toggle" onclick="ShowSearchOptionProject();" title="جستجوی پیشرفته روی فیلدهای پروژه">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 5h18l-7 8v6l-4-2v-4z" /></svg>
                                        <span>جستجو</span>
                                    </button>
                                    <button type="button" id="btnDelSearchOption" class="gis-toggle pwa-toggle-danger" style="display: none;" onclick="DeLSearchOption();" title="حذف شرط‌های جستجوی پیشرفته">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18M8 6V4h8v2M6 6l1 14h10l1-14" /><path d="M10 10v7M14 10v7" /></svg>
                                        <span>حذف شرایط</span>
                                    </button>
                                </div>
                                <div class="gis-field">
                                    <span class="gis-field-label">نوع پروژه:</span>
                                    <asp:DropDownList ID="cmbProjectType" CssClass="cmbDepartment gis-select" onchange="RefershPishnahadInfo(this)" runat="server"></asp:DropDownList>
                                </div>
                                <div class="gis-field">
                                    <span class="gis-field-label">منطقه پروژه:</span>
                                    <span id="gisProjectWrap" class="gis-input-wrap">
                                        <input id="txtRegion" class="NameProjeh gis-input" runat="server" type="text" placeholder="برای انتخاب کلیک کنید یا بنویسید" />
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
                                <div class="gis-opacity" title="شفافیت داخل ناحیه‌های مناطق روی نقشه">
                                    <label class="gis-field-label" style="cursor: pointer;" title="خاموش: مرز برگهء واقعی فقط برای پین انتخاب‌شده کشیده می‌شود. روشن: مرز همهء برگه‌ها با یک ردیف در فهرست">
                                        <input type="checkbox" id="chkSheetAreas" <%= ShowSheetAreas ? "checked=\"checked\"" : "" %> onchange="pwaToggleSheetAreas(this.checked);" style="vertical-align: middle; margin: 0 0 0 4px;" />سطح برگه‌ها
                                    </label>
                                    <span class="gis-field-label">شفافیت ناحیه‌ها:</span>
                                    <input type="range" id="gisAreaOpacity" min="5" max="100" step="5" value="35" oninput="gisApplyAreaOpacity(this.value);" onchange="gisApplyAreaOpacity(this.value);" />
                                    <span id="gisAreaOpacityValue" class="gis-opacity-value">خودکار</span>
                                </div>
                                <div class="gis-opacity" title="پین‌هایی که فاصله‌شان از این مقدار کمتر است در یک ناحیه می‌افتند؛ مقدار کمتر = لکه‌های کوچک‌تر و بیشتر">
                                    <span class="gis-field-label">فاصله خوشه‌بندی:</span>
                                    <input type="range" id="gisClusterKm" min="20" max="200" step="10" value="70" oninput="pwaApplyClusterKm(this.value);" onchange="pwaApplyClusterKm(this.value); pwaRedraw();" />
                                    <span id="gisClusterKmValue" class="gis-opacity-value">70 km</span>
                                    <label class="gis-field-label" style="cursor: pointer;" title="پین‌های نزدیک به هم در هر زوم یک نشانگر شمارنده می‌شوند؛ کلیک روی آن زوم می‌کند">
                                        <input type="checkbox" id="chkClusterPins" <%= EnableClustering ? "checked=\"checked\"" : "" %> onchange="pwaClusterEnabled = this.checked; pwaRebuildMarkerClusters();" style="vertical-align: middle; margin: 0 0 0 4px;" />خوشه‌بندی پین‌ها
                                    </label>
                                </div>
                                <div class="gis-legend" title="درصد تحقق پروژه (میانگین در پین و ناحیه)">
                                    <span class="gis-legend-title">تحقق:</span>
                                    <span class="gis-legend-item"><i style="background: #22c55e"></i>بیش از ۹۰٪</span>
                                    <span class="gis-legend-item"><i style="background: #facc15"></i>۷۰ تا ۹۰٪</span>
                                    <span class="gis-legend-item"><i style="background: #f472b6"></i>۵۰ تا ۷۰٪</span>
                                    <span class="gis-legend-item"><i style="background: #ef4444"></i>کمتر از ۵۰٪</span>
                                    <span class="gis-legend-item"><i style="background: #9ca3af"></i>آغاز نشده</span>
                                </div>
                            </div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <div class="gis-map-row">
                        <div class="gis-side">
                            <div id="divSearchOptions" class="gis-panel" style="display: none;">
                                <div id="PanelSearchResult" class="gis-panel-inner">
                                    <div class="gis-panel-head">
                                        <div id="divSearchCount" class="gis-counts"></div>
                                        <div class="gis-toolbar pwa-selbar">
                                            <button type="button" class="gis-tool gis-tool-text" onclick="pwaSetAllVisible('all');" title="انتخاب همه: نمایش همهء مناطق و پین‌ها">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="3" /><path d="M7 12.5l3.5 3.5L17 9" /></svg>
                                                <span>همه</span>
                                            </button>
                                            <button type="button" class="gis-tool gis-tool-text" onclick="pwaSetAllVisible('invert');" title="انتخاب معکوس: برعکس کردن وضعیت نمایش هر مورد">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 7h11l-3-3M20 17H9l3 3" /></svg>
                                                <span>معکوس</span>
                                            </button>
                                            <button type="button" class="gis-tool gis-tool-text gis-tool-danger" onclick="pwaSetAllVisible('none');" title="پاک کردن همه: مخفی کردن همهء مناطق و پین‌ها">
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

        function togglemarker(marker_num) {
            var cb = document.getElementById('marker' + marker_num);
            if (cb && gmarkers[marker_num]) {
                gmarkers[marker_num].pwaUserHidden = !cb.checked;
                pwaApplyMarkerVisibility(gmarkers[marker_num]);
                // عضویت خوشه‌ها با مخفی/نمایش شدن یک پین عوض می‌شود
                pwaRebuildMarkerClusters();
            }
        }

        function toggleGan(Gan_num) {
            if (document.getElementById('Gan' + Gan_num)) {
                if (document.getElementById('Gan' + Gan_num).checked) {
                    ggans[Gan_num].show();
                } else {
                    ggans[Gan_num].hide();
                }
            }
        }

        // آیکون پین‌ها: همان پوشه‌های رنگی Marker/<Color>/marker.png که وب‌پارت‌های دیگر استفاده می‌کنند
        var icons = new Array();
        icons["red"] = new GIcon();
        icons["red"].image = "/_layouts/15/images/Sazmanyar.GIS/GoogleMap/mm_20_red.png";
        icons["red"].shadow = "/_layouts/15/images/Sazmanyar.GIS/GoogleMap/mm_20_shadow.png";
        icons["red"].iconSize = new GSize(12, 20);
        icons["red"].shadowSize = new GSize(22, 20);
        icons["red"].iconAnchor = new GPoint(6, 20);
        icons["red"].infoWindowAnchor = new GPoint(5, 1);
        icons["red"].imageMap = [4, 0, 0, 4, 0, 7, 3, 11, 4, 19, 7, 19, 8, 11, 11, 7, 11, 4, 7, 0];

        function get_icon(iconColor) {
            if ((typeof (iconColor) == "undefined") || (iconColor == null)) {
                iconColor = "red";
            }
            if (!icons[iconColor]) {
                icons[iconColor] = new GIcon(icons["red"]);
                icons[iconColor].image = "/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Marker/" + iconColor + "/marker.png";
            }
            return icons[iconColor];
        }

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
        // با بسته شدن پنجرهء اطلاعات، حالت انتخاب مارکر/ناحیه/ردیف فهرست هم پاک می‌شود
        GEvent.addListener(map, "infowindowclose", function () {
            pwaClearSelection();
        });
        // با هر تغییر زوم، خوشه‌بندی پین‌ها دوباره محاسبه می‌شود
        GEvent.addListener(map, "zoomend", function () {
            pwaRebuildMarkerClusters();
        });
    }
    else {
        alert("Sorry, the Google Maps API is not compatible with this browser");
    }

    //]]>
</script>
</div>
