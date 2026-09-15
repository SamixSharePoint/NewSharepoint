<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ShowAllKoridorInfoUserControl_ViewRouts.ascx.cs" Inherits="Sazmanyar.GIS.ShowAllKoridorInfo.ShowAllKoridorInfoUserControl_ViewRouts" %>

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

    .ui-autocomplete {
        z-index: 100;
    }

    .gm-style-mtc {
        display: none;
    }
</style>
<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GIS/Script/css/gis-ui.css?v=20260915" />
<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GIS/GoogleMap/EWindow.css" />
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-1.7.1.min.js" type="text/javascript"></script>
<link href="/_layouts/15/Sazmanyar.GIS/Script/css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" />
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-ui-1.10.3.custom.min.js" type="text/javascript"></script>
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/gis-ui.js?v=20260915" type="text/javascript" charset="utf-8"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/GoogleMap/GISBase.js"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/GoogleMap/EWindow.js"></script>
<script type="text/javascript" language="javascript">

    // منبع دادهٔ این کنترل فقط «لیست مسیرها» است: ستون‌های لیست از سرور خوانده می‌شوند و
    // فیلترهای جستجو، فهرست نتایج و پنجرهٔ اطلاعات روی نقشه از روی همان ستون‌ها ساخته می‌شوند.

    function stopRKey(evt) {
        var evt = (evt) ? evt : ((event) ? event : null);
        var node = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);
        if ((evt.keyCode == 13) && (node.type == "text")) { return false; }
    }
    document.onkeypress = stopRKey;

    var X = jQuery.noConflict();
    var strCurrentWebUrl = window.location.protocol + "//" + window.location.host + _spPageContextInfo.webServerRelativeUrl;
    var strFetchUrl = strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/";

    var gisSchema = [];
    var gisSchemaByName = {};
    var gisItems = [];
    var gisLoadToken = 0;
    var gisLoading = false;
    var availableTags = [];
    var currentProject = null;
    var bVaziyatSelect = false;

    var divSearchResult_html = "";
    var gmarkers = [];
    var gpolys = [];
    var bHasBounds = false;
    var gisOpenLabels = [];

    var GIS_OPERATORS = [
        { id: 'contains', title: 'شامل' },
        { id: 'notcontains', title: 'شامل نباشد' },
        { id: 'eq', title: 'برابر' },
        { id: 'neq', title: 'نابرابر' },
        { id: 'starts', title: 'شروع با' },
        { id: 'gt', title: 'بزرگ‌تر از' },
        { id: 'lt', title: 'کوچک‌تر از' },
        { id: 'empty', title: 'خالی باشد' },
        { id: 'notempty', title: 'خالی نباشد' }
    ];

    var GIS_ICON_DEL = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M6 6l12 12M18 6L6 18" /></svg>';

    function gisAjax(method, data, onSuccess) {
        X.ajax({
            type: "POST",
            url: strFetchUrl + method,
            data: data,
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (strHtmlOutput) {
                onSuccess(strHtmlOutput.d);
            },
            error: function () {
                gisLoading = false;
                currentProject = null;
                gisShowMessage('خطا در دریافت اطلاعات از سرور');
            }
        });
    }

    // یکسان‌سازی متن برای مقایسه: ی/ک عربی، ارقام فارسی/عربی، فاصله‌ها و حروف بزرگ
    function gisNorm(value) {
        var s = String(value == null ? '' : value);
        s = s.replace(/[يى]/g, 'ی').replace(/ك/g, 'ک');
        s = s.replace(/[۰-۹]/g, function (d) { return String.fromCharCode(d.charCodeAt(0) - 1776 + 48); });
        s = s.replace(/[٠-٩]/g, function (d) { return String.fromCharCode(d.charCodeAt(0) - 1632 + 48); });
        return X.trim(s.replace(/\s+/g, ' ')).toLowerCase();
    }

    function gisToNumber(value) {
        var s = gisNorm(value).replace(/٫/g, '.').replace(/\s/g, '');
        if (s.indexOf(',') >= 0 && s.indexOf('.') < 0 && s.split(',').length == 2) {
            s = s.replace(',', '.');
        }
        s = s.replace(/,/g, '');
        if (!/^[-+]?(\d+\.?\d*|\.\d+)$/.test(s)) {
            return null;
        }
        return parseFloat(s);
    }

    function gisParseLatLng(lat, lng) {
        var a = gisToNumber(lat), b = gisToNumber(lng);
        if (a == null || b == null || Math.abs(a) > 90 || Math.abs(b) > 180 || (a == 0 && b == 0)) {
            return null;
        }
        return new GLatLng(a, b);
    }

    function gisDisplayFields() {
        var result = [];
        for (var i = 0; i < gisSchema.length; i++) {
            if (gisSchema[i].Technical != '1') {
                result.push(gisSchema[i]);
            }
        }
        return result;
    }

    function gisShowMessage(text, wait) {
        document.getElementById('divSearchResult').innerHTML = '<div class="gis-msg' + (wait ? ' gis-msg-wait' : '') + '">' + text + '</div>';
    }

    // ---------- ستون‌های لیست و نام پروژه‌ها ----------

    function LoadSchema(next) {
        gisAjax('FetchRoutsListSchema', '{}', function (rows) {
            gisSchema = rows || [];
            gisSchemaByName = {};
            for (var i = 0; i < gisSchema.length; i++) {
                gisSchemaByName[gisSchema[i].InternalName] = gisSchema[i];
            }
            gisAddConditionRow();
            if (next) { next(); }
        });
    }

    function LoadProjectNames() {
        gisAjax('FillSugestion_ProjectName_FromRoutsList', '{}', function (d) {
            availableTags = (d && d.length > 0) ? d.split('*') : [];
            var input = X('.NameProjeh');
            input.autocomplete({
                minLength: 0,
                source: function (request, response) {
                    response(X.ui.autocomplete.filter(availableTags, request.term).slice(0, 15));
                },
                select: function (event, ui) {
                    input.val(ui.item.value);
                    FillSugestion_Pishnahadi();
                    return false;
                },
                change: function () {
                    FillSugestion_Pishnahadi();
                }
            }).bind('click', function () {
                X(this).autocomplete('search', X(this).val());
            });
            input.on('keyup', function (e) {
                if (e.keyCode == 13) {
                    FillSugestion_Pishnahadi();
                    return;
                }
                gisUpdateProjectStatus();
            });
            gisUpdateProjectStatus();
        });
    }

    function gisMatchProject(name) {
        var n = gisNorm(name);
        if (n.length == 0) { return ''; }
        for (var i = 0; i < availableTags.length; i++) {
            if (gisNorm(availableTags[i]) == n) {
                return availableTags[i];
            }
        }
        return null;
    }

    function gisUpdateProjectStatus() {
        var matched = gisMatchProject(X('.NameProjeh').val());
        var state = (matched === null) ? 'invalid' : (matched === '' ? 'none' : 'valid');
        gisSetProjectStatus(state);
        bVaziyatSelect = (state == 'valid');
        return matched;
    }

    // gis-ui.js (دکمهٔ پاک‌کردن) این تابع را صدا می‌زند
    function FillSugestion_Pishnahadi() {
        var matched = gisUpdateProjectStatus();
        if (matched === null) {
            currentProject = null;
            gisItems = [];
            gisLoadToken++;
            gisLoading = false;
            RenderItems([]);
            gisShowMessage('پروژه‌ای با این نام در لیست مسیرها وجود ندارد');
            return;
        }
        LoadRouts(matched);
    }

    // ---------- خواندن مسیرها از لیست (صفحه‌به‌صفحه) ----------

    function LoadRouts(projectName) {
        if (currentProject === projectName) {
            return;
        }
        currentProject = projectName;
        gisItems = [];
        gisLoading = true;
        var token = ++gisLoadToken;
        gisOpenSearchPanel();
        RenderItems([]);
        gisShowMessage('لطفاً کمی صبر نمایید ...<br />سیستم در حال خواندن مسیرها از لیست مسیرها می باشد', true);
        FetchRoutsPage(projectName, 1, token);
    }

    function FetchRoutsPage(projectName, pageIndex, token) {
        gisAjax('FetchRoutsListItems_ByPaging', JSON.stringify({ NameProjeh: projectName, PageSize: 100, PageIndex: pageIndex }), function (rows) {
            if (token != gisLoadToken) {
                return;
            }
            if (rows && rows.length > 0) {
                for (var i = 0; i < rows.length; i++) {
                    gisItems.push(rows[i]);
                }
                ApplyFilters();
                FetchRoutsPage(projectName, pageIndex + 1, token);
            }
            else {
                gisLoading = false;
                ApplyFilters();
            }
        });
    }

    // ---------- شرط‌های جستجو (بر اساس ستون‌های لیست) ----------

    var gisApplyTimer = null;
    function gisScheduleApply() {
        clearTimeout(gisApplyTimer);
        gisApplyTimer = setTimeout(ApplyFilters, 300);
    }

    function gisAddConditionRow() {
        var row = X('<div class="gis-cond-row"></div>');
        var fieldSel = X('<select class="gis-cond-field" title="ستون"></select>');
        var fields = gisDisplayFields();
        for (var i = 0; i < fields.length; i++) {
            fieldSel.append(X('<option></option>').attr('value', fields[i].InternalName).text(fields[i].Title));
        }
        var opSel = X('<select class="gis-cond-op" title="عملگر"></select>');
        for (var o = 0; o < GIS_OPERATORS.length; o++) {
            opSel.append(X('<option></option>').attr('value', GIS_OPERATORS[o].id).text(GIS_OPERATORS[o].title));
        }
        var valWrap = X('<span class="gis-cond-val-wrap"></span>');
        var del = X('<button type="button" class="gis-cond-del" title="حذف این شرط">' + GIS_ICON_DEL + '</button>');
        row.append(fieldSel).append(opSel).append(valWrap).append(del);
        X('#gisCondRows').append(row);

        function rebuildValue() {
            valWrap.empty();
            var op = opSel.val();
            if (op == 'empty' || op == 'notempty') {
                return;
            }
            var f = gisSchemaByName[fieldSel.val()];
            var ctl;
            if (f && f.Choices) {
                ctl = X('<select></select>').append(X('<option></option>').attr('value', '').text('انتخاب کنید ...'));
                var choices = f.Choices.split('|');
                for (var c = 0; c < choices.length; c++) {
                    ctl.append(X('<option></option>').attr('value', choices[c]).text(choices[c]));
                }
            }
            else if (f && f.Type == 'Boolean') {
                ctl = X('<select></select>')
                    .append(X('<option></option>').attr('value', '').text('انتخاب کنید ...'))
                    .append(X('<option></option>').attr('value', 'بله').text('بله'))
                    .append(X('<option></option>').attr('value', 'خیر').text('خیر'));
            }
            else {
                ctl = X('<input type="text" />').attr('placeholder', 'مقدار');
            }
            ctl.addClass('gis-cond-val').on('input change keyup', gisScheduleApply);
            valWrap.append(ctl);
        }

        fieldSel.on('change', function () { rebuildValue(); gisScheduleApply(); });
        opSel.on('change', function () { rebuildValue(); gisScheduleApply(); });
        del.on('click', function () { row.remove(); gisScheduleApply(); });
        rebuildValue();
    }

    function gisReadConditions() {
        var result = [];
        X('#gisCondRows .gis-cond-row').each(function () {
            var row = X(this);
            var op = row.find('.gis-cond-op').val();
            var value = row.find('.gis-cond-val').val() || '';
            if (op == 'empty' || op == 'notempty' || X.trim(value).length > 0) {
                result.push({ field: row.find('.gis-cond-field').val(), op: op, value: value });
            }
        });
        return result;
    }

    function gisClearConditions() {
        X('#gisFilterText').val('');
        X('#gisCondRows').empty();
        gisAddConditionRow();
        ApplyFilters();
    }

    function gisItemMatches(item, text, conds) {
        if (text.length > 0) {
            var found = false;
            var fields = gisDisplayFields();
            for (var i = 0; i < fields.length; i++) {
                if (gisNorm(item[fields[i].InternalName]).indexOf(text) >= 0) {
                    found = true;
                    break;
                }
            }
            if (!found) { return false; }
        }

        for (var c = 0; c < conds.length; c++) {
            var v = gisNorm(item[conds[c].field]);
            var w = gisNorm(conds[c].value);
            switch (conds[c].op) {
                case 'contains': if (v.indexOf(w) < 0) { return false; } break;
                case 'notcontains': if (v.indexOf(w) >= 0) { return false; } break;
                case 'eq': if (v != w) { return false; } break;
                case 'neq': if (v == w) { return false; } break;
                case 'starts': if (v.indexOf(w) != 0) { return false; } break;
                case 'gt':
                case 'lt':
                    var a = gisToNumber(v), b = gisToNumber(w);
                    var cmp = (a != null && b != null) ? (a - b) : (v < w ? -1 : (v > w ? 1 : 0));
                    if (conds[c].op == 'gt' ? !(cmp > 0) : !(cmp < 0)) { return false; }
                    break;
                case 'empty': if (v != '') { return false; } break;
                case 'notempty': if (v == '') { return false; } break;
            }
        }
        return true;
    }

    function ApplyFilters() {
        var text = gisNorm(X('#gisFilterText').val());
        var conds = gisReadConditions();
        var matched = [];
        for (var i = 0; i < gisItems.length; i++) {
            if (gisItemMatches(gisItems[i], text, conds)) {
                matched.push(gisItems[i]);
            }
        }
        var drawn = RenderItems(matched);
        if (drawn == 0) {
            if (gisLoading) {
                gisShowMessage('لطفاً کمی صبر نمایید ...<br />سیستم در حال خواندن مسیرها از لیست مسیرها می باشد', true);
            }
            else if (gisItems.length == 0) {
                gisShowMessage('هیچ مسیری در لیست مسیرها یافت نشد');
            }
            else {
                gisShowMessage('هیچ مسیری با شرایط جستجو مطابقت ندارد');
            }
        }
    }

    // ---------- رسم روی نقشه ----------

    function gisRoutsChips(routes, stations) {
        return '<span class="gis-chip" title="مسیر">' + GIS_ICON_ROUTE + ' مسیر <b>' + routes + '</b></span>' +
            '<span class="gis-chip" title="ایستگاه">' + GIS_ICON_STATION + ' ایستگاه <b>' + stations + '</b></span>';
    }

    function gisHideLabels() {
        for (var i = 0; i < gisOpenLabels.length; i++) {
            try { gisOpenLabels[i].hide(); } catch (e) { }
        }
        gisOpenLabels = [];
    }

    function gisRouteColor(item) {
        var c = X.trim(item.Color || '');
        return c.length > 0 ? c : '#00b2ff';
    }

    function gisPinIcon() {
        var icon = new GIcon();
        icon.image = '/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Marker/Pin.png';
        icon.iconSize = new GSize(16, 20);
        icon.shadowSize = new GSize(16, 20);
        icon.iconAnchor = new GPoint(5, 5);
        icon.infoWindowAnchor = new GPoint(5, 1);
        return icon;
    }

    function RenderItems(items) {
        if ((typeof map == 'undefined') || map == null) {
            return 0;
        }
        map.closeInfoWindow();
        map.clearOverlays();
        gisOpenLabels = [];
        gpolys = [];
        gmarkers = [];
        divSearchResult_html = "";
        bounds = new GLatLngBounds();
        bHasBounds = false;

        var stations = {};
        var drawn = 0;
        for (var i = 0; i < items.length; i++) {
            if (drawRouteItem(items[i])) {
                drawn++;
                if (items[i].StationFrom_Title) { stations[items[i].StationFrom_Title] = 1; }
                if (items[i].StationTo_Title) { stations[items[i].StationTo_Title] = 1; }
            }
        }
        var nStations = 0;
        for (var key in stations) { if (stations.hasOwnProperty(key)) { nStations++; } }

        document.getElementById('divSearchCount').innerHTML = gisRoutsChips(drawn, nStations);
        document.getElementById('divSearchResult').innerHTML = divSearchResult_html;
        map.centerAndZoomOnBounds(bHasBounds ? bounds : gisInitialBounds);
        return drawn;
    }

    // پنجرهٔ اطلاعات: همهٔ ستون‌های غیرفنی لیست مسیرها، دو ستون در هر ردیف
    function BuildInfoWindowHtml(item) {
        var h = "<div class='gis-iw gis-iw-routs'><table cellpadding='5'><tr><td><table cellpadding='5'>";
        h += "<tr><td>مبدا: <b>" + gisEscapeHtml(item.StationFrom_Title || '-') + "</b></td>";
        h += "<td>مقصد: <b>" + gisEscapeHtml(item.StationTo_Title || '-') + "</b></td></tr>";

        var cells = [];
        var fields = gisDisplayFields();
        for (var i = 0; i < fields.length; i++) {
            var f = fields[i];
            if (f.InternalName == 'StartStation' || f.InternalName == 'EndStation') {
                continue;
            }
            var v = item[f.InternalName];
            if (v == null || X.trim(String(v)).length == 0) {
                continue;
            }
            cells.push(gisEscapeHtml(f.Title) + ": <b>" + gisEscapeHtml(v) + "</b>");
        }
        for (var c = 0; c < cells.length; c += 2) {
            h += "<tr><td>" + cells[c] + "</td><td>" + (cells[c + 1] || '') + "</td></tr>";
        }
        h += "</table></td></tr></table></div>";
        return h;
    }

    function drawRouteItem(item) {
        var points = [];
        if (item.Points) {
            try {
                var arr = JSON.parse(item.Points);
                for (var i = 0; i < arr.length; i++) {
                    var p = gisParseLatLng(arr[i].lat, arr[i].lng);
                    if (p) { points.push(p); }
                }
            } catch (e) {
            }
        }
        var from = gisParseLatLng(item.LatFrom, item.LongFrom);
        var to = gisParseLatLng(item.LatTo, item.LongTo);
        var color = gisRouteColor(item);
        var label = (item.Title || ('مسیر #' + item.ID)) + (item.ProgramName ? '[' + item.ProgramName + ']' : '');
        var html = BuildInfoWindowHtml(item);

        if (points.length > 1) {
            if (from) { points.splice(0, 0, from); }
            if (to) { points.push(to); }

            var pinIcon = gisPinIcon();
            var markerFrom = null, markerTo = null, ewFrom = null, ewTo = null;
            if (from) {
                markerFrom = new GMarker(from, { icon: pinIcon, title: item.StationFrom_Title });
                map.addOverlay(markerFrom);
                ewFrom = new EWindow(map, E_STYLE_0);
                map.addOverlay(ewFrom);
            }
            if (to) {
                markerTo = new GMarker(to, { icon: pinIcon, title: item.StationTo_Title });
                map.addOverlay(markerTo);
                ewTo = new EWindow(map, E_STYLE_0);
                map.addOverlay(ewTo);
            }

            var poly = new GPolyline(points, color, 5, 1);
            poly.objmarker_StationFrom = markerFrom;
            poly.objmarker_StationTo = markerTo;
            gpolys.push(poly);
            var poly_num = gpolys.length - 1;

            GEvent.addListener(poly, 'click', function (point) {
                if (!point) {
                    point = poly.getVertex(Math.floor(poly.getVertexCount() / 2));
                }
                gisHideLabels();
                map.openInfoWindowHtml(point, html);
                map.panTo(point);
                if (ewFrom) { ewFrom.openOnMarker(markerFrom, gisEscapeHtml(item.StationFrom_Title)); gisOpenLabels.push(ewFrom); }
                if (ewTo) { ewTo.openOnMarker(markerTo, gisEscapeHtml(item.StationTo_Title)); gisOpenLabels.push(ewTo); }
            });

            divSearchResult_html += gisResultItem('route', 'poly', poly_num, 'togglePoly', color, 'gpolys', label);

            if (poly.getBounds && poly.getBounds()) {
                bounds.extend(poly.getBounds().getNorthEast());
                bounds.extend(poly.getBounds().getSouthWest());
                bHasBounds = true;
            }
            map.addOverlay(poly);
            return true;
        }

        // مسیری که هنوز نقاط ندارد: فقط ایستگاه شناخته‌شده‌اش را نشان می‌دهیم
        var point = from || to;
        if (!point) {
            return false;
        }
        var marker = new GMarker(point, { icon: gisPinIcon(), title: item.Title });
        gmarkers.push(marker);
        var marker_num = gmarkers.length - 1;
        GEvent.addListener(marker, 'click', function () {
            gisHideLabels();
            marker.openInfoWindowHtml(html);
            map.panTo(marker.getPoint());
        });
        bounds.extend(point);
        bHasBounds = true;
        map.addOverlay(marker);
        divSearchResult_html += gisResultItem('station', 'marker', marker_num, 'togglemarker', color, 'gmarkers', label);
        return true;
    }

    function togglePoly(poly_num) {
        var checkbox = document.getElementById('poly' + poly_num);
        var poly = gpolys[poly_num];
        if (!checkbox || !poly) { return; }
        var show = checkbox.checked;
        if (show) { poly.show(); } else { poly.hide(); }
        if (poly.objmarker_StationFrom) { if (show) { poly.objmarker_StationFrom.show(); } else { poly.objmarker_StationFrom.hide(); } }
        if (poly.objmarker_StationTo) { if (show) { poly.objmarker_StationTo.show(); } else { poly.objmarker_StationTo.hide(); } }
    }

    function togglemarker(marker_num) {
        var checkbox = document.getElementById('marker' + marker_num);
        if (!checkbox || !gmarkers[marker_num]) { return; }
        if (checkbox.checked) { gmarkers[marker_num].show(); } else { gmarkers[marker_num].hide(); }
    }

    // ---------- پنل جستجو ----------

    function gisOpenSearchPanel() {
        var panel = document.getElementById('divSearchOptions');
        if (panel == null) { return; }
        panel.style.display = 'block';
        document.getElementById('map_SearchArrow').title = 'بستن فرم جستجو';
        gisResizeMap();
    }

    function gisCloseSearchPanel() {
        var panel = document.getElementById('divSearchOptions');
        if (panel == null) { return; }
        panel.style.display = 'none';
        document.getElementById('map_SearchArrow').title = 'نمایش فرم جستجو';
        gisResizeMap();
    }

    function togglePanelSearch() {
        var panel = document.getElementById('divSearchOptions');
        if (panel == null) { return; }
        if (panel.style.display == 'none') { gisOpenSearchPanel(); } else { gisCloseSearchPanel(); }
        if ((typeof map != 'undefined') && (map != null)) {
            map.checkResize();
            map.centerAndZoomOnBounds(bHasBounds ? bounds : gisInitialBounds);
        }
    }

    X(document).ready(function () {
        X('#gisFilterText').on('input keyup', gisScheduleApply);
        LoadSchema(function () {
            LoadProjectNames();
            LoadRouts('');
        });
    });
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
                                    <button type="button" id="map_SearchArrow" class="gis-toggle" onclick="togglePanelSearch();" title="نمایش فرم جستجو">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="16" rx="2" /><path d="M15 4v16" /><path d="M6 9h5M6 13h5" /></svg>
                                        <span>جستجو و فهرست مسیرها</span>
                                    </button>
                                </div>
                                <div class="gis-field">
                                    <span class="gis-field-label">نام پروژه:</span>
                                    <span id="gisProjectWrap" class="gis-input-wrap">
                                        <input id="txtProgramName" class="NameProjeh gis-input" runat="server" type="text" placeholder="خالی = همهٔ پروژه‌ها؛ برای انتخاب کلیک کنید" />
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
                            <div class="gis-legend" title="منبع دادهٔ این نقشه">
                                <span class="gis-legend-title">منبع داده:</span>
                                <span class="gis-legend-item">لیست مسیرها</span>
                            </div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <div class="gis-map-row">
                            <div class="gis-side">
                                <div id="divSearchOptions" class="gis-panel" style="display: none;">
                                    <div class="gis-panel-inner">
                                        <div class="gis-panel-head">
                                            <div id="divSearchCount" class="gis-counts"></div>
                                            <div class="gis-search">
                                                <div class="gis-search-text">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7" /><path d="M20 20l-3.5-3.5" /></svg>
                                                    <input type="text" id="gisFilterText" placeholder="جستجو در همهٔ ستون‌های مسیر ..." />
                                                </div>
                                                <div id="gisCondRows" class="gis-cond-rows"></div>
                                                <div class="gis-search-actions">
                                                    <button type="button" class="gis-tool gis-tool-text" onclick="gisAddConditionRow();" title="افزودن شرط بر اساس یکی از ستون‌های لیست">
                                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M12 5v14M5 12h14" /></svg>
                                                        افزودن شرط
                                                    </button>
                                                    <button type="button" class="gis-tool gis-tool-text gis-tool-danger" onclick="gisClearConditions();" title="پاک کردن متن جستجو و همهٔ شرط‌ها">
                                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18M8 6V4h8v2M6 6l1 14h10l1-14" /><path d="M10 10v7M14 10v7" /></svg>
                                                        پاک کردن
                                                    </button>
                                                </div>
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
        var center = new GLatLng(center_lat, center_lng);
        map.setCenter(center, map.getBoundsZoomLevel(bounds));
    }

    var map;
    var gisInitialBounds = bounds;

    if (GBrowserIsCompatible()) {
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
                gisHideLabels();
            }
        });
    }
    else {
        alert("Sorry, the Google Maps API is not compatible with this browser");
    }

    //]]>
</script>
</div>
