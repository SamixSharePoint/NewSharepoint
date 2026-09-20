/*
    برگه‌های نقشه (dbo.MapSheets) - کد مشترک نمایش برای دو کنترل وب‌پارت ShowAllMapSheets (ادمین و کاربر نهایی)
    ---------------------------------------------------------------------------------------------------
    * داده از وب‌متد FetchMapSheets (نمای vw_MapSheetsProjects) می‌آید: هر سطر یک برگه + پروژهء متصل از PWAInfo.
    * Boundary هر برگه JSON [{"lat":..,"lng":..},...] است (همان قالب PolygonPoints لیست سطح‌ها) و با GPolygon کشیده می‌شود.
    * رنگ سطح و پین = دستهء تحقق پروژهء متصل (همان کدهای PWAInfo.TahaghoghCategory / GISInfo.TahaghoghRoute)؛
      برگهء بدون پروژه در PWA خاکستری-آبی (دسته 0).
    وابستگی: jquery، gis-ui.js (gisResultItem / gisEscapeHtml / gisAreaOpacity)، GISBase.js (نقشهء آفلاین)
*/

var msMap = null;
var msSheets = [];       // سطرهای برگشتی از وب‌متد
var msPolys = [];        // GPolygon هر برگه (هم‌اندیس با msSheets) - نام این آرایه در gisResultItem استفاده می‌شود
var msMarkers = [];      // GMarker مرکز هر برگه
var msSel = -1;
var msIcons = {};
var msLoading = false;

var MS_CAT = {
    0: { title: 'بدون پروژه در PWA', hex: '#64748b', marker: 'Gray' },
    1: { title: 'بیش از ۹۰٪', hex: '#22c55e', marker: 'Green' },
    2: { title: '۷۰ تا ۹۰٪', hex: '#facc15', marker: 'Yellow' },
    3: { title: '۵۰ تا ۷۰٪', hex: '#f472b6', marker: 'Pink' },
    4: { title: 'کمتر از ۵۰٪', hex: '#ef4444', marker: 'Red' },
    5: { title: 'آغاز نشده', hex: '#9ca3af', marker: 'Black' }
};

function msWebUrl() {
    return window.location.protocol + '//' + window.location.host + _spPageContextInfo.webServerRelativeUrl;
}

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

// دستهء رنگ یک برگه: 0 = بدون پروژه در PWA، وگرنه دستهء تحقق پروژه
function msCategory(s) {
    if (!s || s.PwaID == null || s.PwaID === '') { return 0; }
    var c = parseInt(s.TahaghoghCategory, 10);
    return (c >= 1 && c <= 5) ? c : 5;
}

// ---- نقشه (همان نقشهء آفلاین وب‌پارت‌های دیگر) ----
function msInitMap(canvasId) {
    if (!GBrowserIsCompatible()) { return; }
    var copyright = new GCopyright(1, new GLatLngBounds(new GLatLng(-90, -180), new GLatLng(90, 180)), 0, 'Sazmanyar');
    var copyrightCollection = new GCopyrightCollection('Map Data:');
    copyrightCollection.addCopyright(copyright);
    var customGetTileUrl = function (a, b) {
        return '/_layouts/15/images/Sazmanyar.GoogleMapOffline/Google Maps Image/' + b + '/' + a.x + '/' + a.y + '.png';
    };
    var tilelayers = [new GTileLayer(copyrightCollection, 1, 14)];
    tilelayers[0].getTileUrl = customGetTileUrl;
    var custommap = new GMapType(tilelayers, new GMercatorProjection(14), 'Sazmanyar');
    msMap = new GMap(document.getElementById(canvasId), { mapTypes: [custommap] });
    msMap.addControl(new GLargeMapControl());
    msMap.addMapType(G_PHYSICAL_MAP);
    msMap.setCenter(new GLatLng(32.5, 54.0), 5);

    var ui = new GMapUIOptions();
    ui.maptypes = { normal: true, satellite: true, hybrid: true, physical: false };
    ui.zoom = { scrollwheel: true, doubleclick: true };
    ui.controls = { largemapcontrol3d: true, maptypecontrol: true, scalecontrol: true };
    msMap.setUI(ui);
    if (typeof (gisApplyPageFontToMap) == 'function') { try { gisApplyPageFontToMap(msMap); } catch (e) { } }
}

function msIcon(color) {
    if (!msIcons[color]) {
        var icon = new GIcon();
        icon.image = '/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Marker/' + color + '/marker.png';
        icon.shadow = '/_layouts/15/images/Sazmanyar.GIS/GoogleMap/mm_20_shadow.png';
        icon.iconSize = new GSize(20, 34);
        icon.shadowSize = new GSize(22, 20);
        icon.iconAnchor = new GPoint(10, 34);
        icon.infoWindowAnchor = new GPoint(10, 2);
        msIcons[color] = icon;
    }
    return msIcons[color];
}

// ---- بارگذاری ----
function msSetStatus(html) {
    var el = document.getElementById('divMsCount');
    if (el) { el.innerHTML = html; }
}

function msLoad(sheetNo, projectCode, importBatch, onDone) {
    if (msLoading) { return; }
    msLoading = true;
    msSetStatus('<span class="gis-msg gis-msg-wait">در حال بارگذاری برگه‌ها...</span>');
    var X = jQuery.noConflict();
    X.ajax({
        type: 'POST',
        url: msWebUrl() + '/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchMapSheets',
        data: JSON.stringify({ SheetNo: sheetNo || '', ProjectCode: projectCode || '', ImportBatch: importBatch || '' }),
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (res) {
            msLoading = false;
            msSheets = (res && res.d) ? res.d : [];
            msDraw();
            if (typeof (onDone) == 'function') { onDone(msSheets); }
        },
        error: function (xhr) {
            msLoading = false;
            msSheets = [];
            msDraw();
            msSetStatus('<span class="gis-msg">خطا در خواندن برگه‌ها' + (xhr && xhr.status ? ' (' + xhr.status + ')' : '') + '</span>');
        }
    });
}

function msClear() {
    try { msMap.closeInfoWindow(); } catch (e) { }
    for (var i = 0; i < msPolys.length; i++) { if (msPolys[i]) { msMap.removeOverlay(msPolys[i]); } }
    for (var j = 0; j < msMarkers.length; j++) { if (msMarkers[j]) { msMap.removeOverlay(msMarkers[j]); } }
    msPolys = [];
    msMarkers = [];
    msSel = -1;
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

function msDraw() {
    msClear();
    var bounds = new GLatLngBounds();
    var listHtml = '';
    var counts = { total: 0, linked: 0, unlinked: 0 };

    for (var i = 0; i < msSheets.length; i++) {
        var s = msSheets[i];
        var pts = msParseBoundary(s.Boundary);
        if (pts.length < 3) { msPolys.push(null); msMarkers.push(null); continue; }
        pts.push(pts[0]);

        var cat = msCategory(s);
        var color = MS_CAT[cat].hex;
        counts.total++;
        if (cat == 0) { counts.unlinked++; } else { counts.linked++; }

        var poly = new GPolygon(pts, color, 2, 0.9, color, gisAreaOpacity(null), { clickable: true });
        poly.msIndex = i;
        msMap.addOverlay(poly);
        msPolys.push(poly);

        var center = new GLatLng(msNum(s.CentroidLat), msNum(s.CentroidLong));
        var marker = new GMarker(center, { icon: msIcon(MS_CAT[cat].marker), title: msSheetTitle(s) });
        marker.msIndex = i;
        msMap.addOverlay(marker);
        msMarkers.push(marker);

        (function (idx, c) {
            GEvent.addListener(poly, 'click', function (point) { msSelect(idx, point || c); });
            GEvent.addListener(marker, 'click', function () { msSelect(idx, c); });
        })(i, center);

        var b = poly.getBounds();
        bounds.extend(b.getNorthEast());
        bounds.extend(b.getSouthWest());

        var sub = (s.PwaID != null && s.PwaID !== '') ? s.ProjectName : (s.ProjectCode ? 'کد ' + s.ProjectCode + ' در PWA نیست' : 'بدون کد پروژه');
        listHtml += gisResultItem('area', 'MsSheet', i, 'msToggle', color, 'msPolys', msSheetTitle(s) + ' [' + sub + ']');
    }

    var list = document.getElementById('divMsList');
    if (list) { list.innerHTML = listHtml; }
    msSetStatus(counts.total == 0
        ? '<span class="gis-msg">برگه‌ای یافت نشد</span>'
        : '<span class="gis-chip">' + counts.total + ' برگه</span> <span class="gis-chip">' + counts.linked + ' متصل به PWA</span>' + (counts.unlinked > 0 ? ' <span class="gis-chip">' + counts.unlinked + ' بدون پروژه</span>' : ''));

    if (counts.total > 0) {
        msMap.setCenter(bounds.getCenter(), Math.min(msMap.getBoundsZoomLevel(bounds), 12));
    }
}

function msSheetTitle(s) {
    var t = 'برگه ' + (s.SheetNo || '');
    if (s.SheetNameFa) { t += ' - ' + s.SheetNameFa; }
    else if (s.SheetNameEn) { t += ' - ' + s.SheetNameEn; }
    return t;
}

// ---- نمایش/مخفی و انتخاب ----
function msToggle(i) {
    var chk = document.getElementById('MsSheet' + i);
    if (!chk || !msPolys[i]) { return; }
    if (chk.checked) { msPolys[i].show(); if (msMarkers[i]) { msMarkers[i].show(); } }
    else { msPolys[i].hide(); if (msMarkers[i]) { msMarkers[i].hide(); } if (msSel == i) { try { msMap.closeInfoWindow(); } catch (e) { } } }
}

function msSetAllVisible(mode) {
    for (var i = 0; i < msPolys.length; i++) {
        var chk = document.getElementById('MsSheet' + i);
        if (!chk) { continue; }
        chk.checked = (mode == 'all') ? true : (mode == 'none' ? false : !chk.checked);
        msToggle(i);
    }
}

function msSelect(i, point) {
    var s = msSheets[i];
    if (!s) { return; }
    msSel = i;
    var items = document.querySelectorAll('.gis-root .gis-item.is-selected');
    for (var k = 0; k < items.length; k++) { items[k].className = items[k].className.replace(/\s*is-selected/g, ''); }
    var chk = document.getElementById('MsSheet' + i);
    if (chk && chk.parentNode) {
        chk.parentNode.className += ' is-selected';
        try { chk.parentNode.scrollIntoView({ block: 'nearest' }); } catch (e) { }
    }
    if (!point) { point = new GLatLng(msNum(s.CentroidLat), msNum(s.CentroidLong)); }
    msMap.panTo(point);
    msMap.openInfoWindowHtml(point, msInfoHtml(s));
}

// ---- InfoWindow ----
function msInfoHtml(s) {
    var cat = msCategory(s);
    var html = '<div class="gis-iw gis-iw-pwa gis-iw-ms">';
    html += '<h4><span class="pwa-badge" style="background:' + MS_CAT[cat].hex + '"></span>' + gisEscapeHtml(msSheetTitle(s)) + '</h4>';

    html += '<div class="pwa-item"><div class="pwa-name">مشخصات برگه</div><table>';
    html += '<tr><td class="lbl">شماره برگه:</td><td><b>' + msVal(s.SheetNo) + '</b></td><td class="lbl">مقیاس:</td><td>' + msScale(s.SheetScale) + '</td></tr>';
    html += '<tr><td class="lbl">نام فارسی:</td><td>' + msVal(s.SheetNameFa) + '</td><td class="lbl">نام انگلیسی:</td><td>' + msVal(s.SheetNameEn) + '</td></tr>';
    html += '<tr><td class="lbl">برگه مادر:</td><td>' + msVal(s.SheetSeries) + '</td><td class="lbl">ربع:</td><td>' + msVal(s.SheetQuarter) + '</td></tr>';
    html += '<tr><td class="lbl">مساحت:</td><td>' + (s.AreaKm2 ? gisEscapeHtml(String(Math.round(msNum(s.AreaKm2)))) + ' km²' : '-') + '</td><td class="lbl">مرکز:</td><td>' + msVal(s.CentroidLat) + ' , ' + msVal(s.CentroidLong) + '</td></tr>';
    html += '<tr><td class="lbl">مجری:</td><td>' + msVal(s.Contractor) + '</td><td class="lbl">ناظر:</td><td>' + msVal(s.Supervisor) + '</td></tr>';
    html += '<tr><td class="lbl">زمین‌شناس:</td><td colspan="3">' + msVal(s.Geologist) + '</td></tr>';
    if (s.SheetProjectName) {
        html += '<tr><td class="lbl">عنوان در فایل کارفرما:</td><td colspan="3" style="white-space:normal">' + msVal(s.SheetProjectName) + '</td></tr>';
    }
    html += '</table></div>';

    html += '<div class="pwa-item"><div class="pwa-name">پروژه در PWA</div>';
    if (s.PwaID != null && s.PwaID !== '') {
        html += '<table>';
        html += '<tr><td class="lbl">نام:</td><td colspan="3" style="white-space:normal"><b>' + msVal(s.ProjectName) + '</b></td></tr>';
        html += '<tr><td class="lbl">کد:</td><td>' + msVal(s.ProjectCode) + '</td><td class="lbl">وضعیت:</td><td>' + msVal(s.Status) + '</td></tr>';
        html += '<tr><td class="lbl">نوع:</td><td>' + msVal(s.ProjectType) + (msNum(s.PwaRowCount) > 1 ? ' <span class="gis-hint">(' + gisEscapeHtml(s.PwaRowCount) + ' نوع)</span>' : '') + '</td><td class="lbl">منطقه:</td><td>' + msVal(s.Region) + '</td></tr>';
        html += '<tr><td class="lbl">پیشرفت برنامه‌ای:</td><td>' + msPct(s.PlannedProgress) + '</td><td class="lbl">پیشرفت واقعی:</td><td>' + msPct(s.ActualProgress) + '</td></tr>';
        html += '<tr><td class="lbl">درصد تحقق:</td><td><b>' + msPct(s.AchievementPct) + '</b></td><td class="lbl">دستهء تحقق:</td><td><span class="pwa-badge" style="background:' + MS_CAT[cat].hex + '"></span>' + MS_CAT[cat].title + '</td></tr>';
        html += '<tr><td class="lbl">شروع:</td><td>' + msVal(s.StartDateJ) + '</td><td class="lbl">پایان:</td><td>' + msVal(s.FinishDateJ) + '</td></tr>';
        html += '<tr><td class="lbl">نحوه اجرا:</td><td>' + msVal(s.ExecutionMethod) + '</td><td class="lbl">مدیر پروژه:</td><td>' + msVal(s.ProjectManager) + '</td></tr>';
        html += '<tr><td class="lbl">ناظر (PWA):</td><td colspan="3">' + msVal(s.ProjectSupervisor) + '</td></tr>';
        html += '</table>';
    } else if (s.ProjectCode) {
        html += '<div class="gis-hint">کد پروژه «' + gisEscapeHtml(s.ProjectCode) + '» در PWAInfo پیدا نشد؛ باید با کارفرما بررسی شود.</div>';
    } else {
        html += '<div class="gis-hint">در فایل کارفرما کد پروژه (P_Code) برای این برگه خالی است.</div>';
    }
    html += '</div>';

    html += '<div class="gis-hint">منبع: ' + msVal(s.SourceFile) + (s.SourceLayer ? ' / ' + gisEscapeHtml(s.SourceLayer) : '') + (s.SourceCrs ? ' - ' + gisEscapeHtml(s.SourceCrs) : '') + '</div>';
    html += '</div>';
    return html;
}

// ---- کمبوی انتخاب برگه (کاربر نهایی) ----
function msFillCombo(selectId) {
    var cmb = document.getElementById(selectId);
    if (!cmb) { return; }
    cmb.innerHTML = '';
    var optAll = document.createElement('option');
    optAll.value = '';
    optAll.innerHTML = 'همهء برگه‌ها (' + msSheets.length + ')';
    cmb.appendChild(optAll);
    for (var i = 0; i < msSheets.length; i++) {
        var opt = document.createElement('option');
        opt.value = String(i);
        opt.innerHTML = gisEscapeHtml(msSheetTitle(msSheets[i]));
        cmb.appendChild(opt);
    }
}

function msComboChanged(cmb) {
    if (cmb.value === '') {
        msSetAllVisible('all');
        try { msMap.closeInfoWindow(); } catch (e) { }
        msDraw();
        return;
    }
    var i = parseInt(cmb.value, 10);
    if (!msPolys[i]) { return; }
    var b = msPolys[i].getBounds();
    msMap.setCenter(b.getCenter(), Math.min(msMap.getBoundsZoomLevel(b), 13));
    msSelect(i, null);
}
