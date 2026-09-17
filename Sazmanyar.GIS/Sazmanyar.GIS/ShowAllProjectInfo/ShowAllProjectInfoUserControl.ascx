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
    var availableTags = [];            // فهرست منطقه‌ها برای پیشنهاد خودکار
    var bVaziyatSelect = false;        // آیا منطقهء معتبری انتخاب شده؟
    var currentRegion = "";
    var strCurrentWebUrl = window.location.protocol + "//" + window.location.host + _spPageContextInfo.webServerRelativeUrl;
    var strFetchUrl = strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/";

    // ---- جستجوی پیشرفته (همان سازوکار قالب 1: صفحهء FilterProject.html داخل fancybox، خروجی query-builder به‌صورت SQL) ----
    var SearchOption_Project = null;   // { sql: "SELECT * FROM table WHERE ..." } که صفحهء فیلتر برمی‌گرداند

    function ShowSearchOptionProject() {
        X.fancybox({
            'width': 960,
            'height': 600,
            'padding': 0,
            'autoScale': false,
            'transitionIn': 'none',
            'transitionOut': 'none',
            'type': 'iframe',
            'href': '/_layouts/15/Sazmanyar.GIS/FilterProject.html?v=20260917'
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

    function setInformation_Project(data) {
        SearchOption_Project = data;
        return SearchOption_Project;
    }

    // صفحهء فیلتر بعد از «جستجوی اطلاعات» این را صدا می‌زند
    function ShowAllRoutInMap() {
        RefereshAllInMap();
    }

    function DeLSearchOption() {
        SearchOption_Project = null;
        RefereshAllInMap();
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
                    document.getElementById('divSearchResult').innerHTML = '<div class="gis-msg">هیچ موردی جهت نمایش در لیست یافت نشد</div>';
                    map.centerAndZoomOnBounds(new GLatLngBounds(new GLatLng(39.027719, 44.736328), new GLatLng(26.745610, 62.050781)));
                    return;
                }
                DrawPWAProjects(result);
            },
            error: function (MSG) {
                alert('error' + MSG.responseText);
            }
        });
    }

    function DrawPWAProjects(rows) {
        // 1) گروه‌بندی بر اساس منطقه و بر اساس نقطه
        var byRegion = {}, regionOrder = [];
        var byPoint = {}, pointOrder = [];
        var nProjects = 0;

        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            var lat = pwaNum(r.Lat), lng = pwaNum(r.Long);
            if (lat == 0 || lng == 0) { continue; }
            nProjects++;

            var regionKey = (r.Region == null || r.Region == '') ? '(بدون منطقه)' : r.Region;
            if (!byRegion[regionKey]) { byRegion[regionKey] = []; regionOrder.push(regionKey); }
            byRegion[regionKey].push(r);

            var pointKey = lat.toFixed(5) + ',' + lng.toFixed(5);
            if (!byPoint[pointKey]) { byPoint[pointKey] = { lat: lat, lng: lng, rows: [] }; pointOrder.push(pointKey); }
            byPoint[pointKey].rows.push(r);
        }

        // 2) ناحیهء هر منطقه (پوستهء محدب پین‌های آن منطقه)
        var areaHtml = "";
        for (var a = 0; a < regionOrder.length; a++) {
            var regionName = regionOrder[a];
            var regionRows = byRegion[regionName];
            var pts = [];
            var seen = {};
            for (var j = 0; j < regionRows.length; j++) {
                var k = pwaNum(regionRows[j].Lat).toFixed(5) + ',' + pwaNum(regionRows[j].Long).toFixed(5);
                if (seen[k]) { continue; }
                seen[k] = true;
                pts.push({ lat: pwaNum(regionRows[j].Lat), lng: pwaNum(regionRows[j].Long) });
            }
            var hull = pwaRegionShape(pts);
            if (hull.length < 3) { continue; }

            var cat = pwaCategory(regionRows);
            var color = PWA_CAT[cat].hex;
            var PolygonPoints = [];
            for (var h = 0; h < hull.length; h++) {
                PolygonPoints.push(new GLatLng(hull[h].lat, hull[h].lng));
            }
            PolygonPoints.push(new GLatLng(hull[0].lat, hull[0].lng));

            var Polygon = new GPolygon(PolygonPoints, color, 2, 0.9, color, gisAreaOpacity(null), { clickable: true });
            Polygon.gisOpacity = gisAreaOpacity(null);
            Polygon.pwaRegion = regionName;
            Polygon.pwaColor = color;
            ggans.push(Polygon);
            var gan_num = ggans.length - 1;

            (function (poly, html, num) {
                GEvent.addListener(poly, 'click', function (point) {
                    if (!point) {
                        // کلیک از فهرست کناری: مرکز ناحیه
                        var b = poly.getBounds();
                        point = b ? b.getCenter() : poly.getVertex(0);
                        map.panTo(point);
                    }
                    pwaSelectPolygon(poly, num);
                    map.openInfoWindowHtml(point, html);
                });
            })(Polygon, BuildRegionInfoHtml(regionName, regionRows, cat), gan_num);

            areaHtml += gisResultItem('area', 'Gan', gan_num, 'toggleGan', color, 'ggans', regionName + ' [' + regionRows.length + ' پروژه]');

            if (Polygon.getBounds && Polygon.getBounds()) {
                bounds.extend(Polygon.getBounds().getNorthEast());
                bounds.extend(Polygon.getBounds().getSouthWest());
            }
            map.addOverlay(Polygon);
        }

        // 3) پین‌ها (یک پین برای هر نقطه؛ InfoWindow همهء پروژه‌های آن نقطه را فهرست می‌کند)
        var pinHtml = "";
        for (var p = 0; p < pointOrder.length; p++) {
            var pt = byPoint[pointOrder[p]];
            var pcat = pwaCategory(pt.rows);
            var pcolor = PWA_CAT[pcat].hex;
            var point = new GLatLng(pt.lat, pt.lng);
            var title = pwaPinTitle(pt.rows);

            var pIcon = get_icon(PWA_CAT[pcat].marker);
            var marker = new GMarker(point, { icon: pIcon, title: title });
            marker.pwaRows = pt.rows;
            marker.pwaImage = pIcon.image;
            gmarkers.push(marker);
            var marker_num = gmarkers.length - 1;

            (function (mk, html, num) {
                GEvent.addListener(mk, "click", function () {
                    pwaSelectMarker(mk, num);
                    mk.openInfoWindowHtml(html);
                });
            })(marker, BuildPinInfoHtml(pt.rows), marker_num);

            pinHtml += gisResultItem('station', 'marker', marker_num, 'togglemarker', pcolor, 'gmarkers', title + ' [' + pt.rows.length + ' پروژه]');

            bounds.extend(point);
            map.addOverlay(marker);
        }

        divSearchResult_html = areaHtml + pinHtml;
        document.getElementById("divSearchCount").innerHTML = pwaCountChips(regionOrder.length, pointOrder.length, nProjects);
        document.getElementById("divSearchResult").innerHTML = divSearchResult_html;

        if (regionOrder.length > 0 || pointOrder.length > 0) {
            map.centerAndZoomOnBounds(bounds);
        }
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
    var pwaSel = { marker: null, markerImg: '', poly: null, polyTimer: null, listEl: null };
    var PWA_SEL_STROKE = '#1d4ed8';

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
        try { mk.setImage(mk.pwaImage + '?pwasel=' + marker_num); } catch (e) { }
        setTimeout(function () {
            var imgs = document.querySelectorAll('.gis-root img[src*="pwasel=' + marker_num + '"]');
            for (var i = 0; i < imgs.length; i++) {
                // موتور نقشه تصویر مارکر را داخل یک div با overflow:hidden می‌گذارد؛ کلاس روی همان div می‌نشیند
                var el = (imgs[i].parentNode && imgs[i].parentNode.tagName == 'DIV') ? imgs[i].parentNode : imgs[i];
                if (el.className.indexOf('pwa-marker-selected') < 0) { el.className += ' pwa-marker-selected'; }
            }
        }, 30);
        pwaHighlightListItem('marker' + marker_num);
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
        html += "<div class='gis-hint'>مرز ناحیه به‌صورت تقریبی از موقعیت پین‌های همین منطقه ساخته شده است.</div>";
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

    // اگر کمتر از 3 نقطهء متمایز (یا همه روی یک خط) باشند، دایره‌ای دور مرکز نقاط با شعاع حداقل 12 کیلومتر
    function pwaRegionShape(points) {
        if (points.length == 0) { return []; }
        var hull = pwaConvexHull(points);
        if (hull.length >= 3) {
            // حاشیهء کوچک (حدود 3 کیلومتر) تا پین‌های روی مرز داخل ناحیه بیفتند
            return pwaBuffer(hull, 0.03);
        }
        var cLat = 0, cLng = 0;
        for (var i = 0; i < points.length; i++) { cLat += points[i].lat; cLng += points[i].lng; }
        cLat /= points.length; cLng /= points.length;
        var radiusKm = 12;
        for (var j = 0; j < points.length; j++) {
            var d = pwaDistKm(cLat, cLng, points[j].lat, points[j].lng) + 8;
            if (d > radiusKm) { radiusKm = d; }
        }
        return pwaCircle(cLat, cLng, radiusKm, 24);
    }

    function pwaBuffer(hull, deg) {
        var cLat = 0, cLng = 0;
        for (var i = 0; i < hull.length; i++) { cLat += hull[i].lat; cLng += hull[i].lng; }
        cLat /= hull.length; cLng /= hull.length;
        var out = [];
        for (var j = 0; j < hull.length; j++) {
            var dLat = hull[j].lat - cLat, dLng = hull[j].lng - cLng;
            var len = Math.sqrt(dLat * dLat + dLng * dLng) || 1;
            out.push({ lat: hull[j].lat + dLat / len * deg, lng: hull[j].lng + dLng / len * deg });
        }
        return out;
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
                    if (m) { if (checked) { m.show(); } else { m.hide(); } }
                }
                else if (id.indexOf('Gan') == 0) {
                    var g = ggans[parseInt(id.substring(3), 10)];
                    if (g) { if (checked) { g.show(); } else { g.hide(); } }
                }
            } catch (e) { }
        }
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
                                    <span class="gis-field-label">شفافیت ناحیه‌ها:</span>
                                    <input type="range" id="gisAreaOpacity" min="5" max="100" step="5" value="35" oninput="gisApplyAreaOpacity(this.value);" onchange="gisApplyAreaOpacity(this.value);" />
                                    <span id="gisAreaOpacityValue" class="gis-opacity-value">خودکار</span>
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
            if (document.getElementById('marker' + marker_num)) {
                if (document.getElementById('marker' + marker_num).checked) {
                    gmarkers[marker_num].show();
                } else {
                    gmarkers[marker_num].hide();
                }
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
    }
    else {
        alert("Sorry, the Google Maps API is not compatible with this browser");
    }

    //]]>
</script>
</div>
