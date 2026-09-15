// توابع مشترک وب‌پارت‌های نقشهٔ GIS: ساخت ردیف نتایج، چیپ‌های شمارنده، وضعیت فیلد نام پروژه،
// و اطلاع‌رسانی تغییر اندازهٔ نقشه. به متغیرهای سراسری هر کنترل (map، FillSugestion_Pishnahadi) در زمان اجرا تکیه می‌کند.

var GIS_ICON_STATION = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 21s7-6.2 7-11a7 7 0 1 0-14 0c0 4.8 7 11 7 11z"/><circle cx="12" cy="10" r="2.5"/></svg>';
var GIS_ICON_ROUTE = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="5" cy="18" r="2"/><circle cx="19" cy="6" r="2"/><path d="M7 17.5c4 0 4-11 8-11h2"/></svg>';
var GIS_ICON_AREA = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 8l7-4 9 5-3 10-10-1z"/></svg>';

function gisEscapeHtml(value) {
    return String(value == null ? '' : value)
        .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

// یک ردیف لیست نتایج: چک‌باکس نمایش/مخفی + سواچ رنگ + عنوان؛ اگر عنوان به «[نام پروژه]» ختم شود،
// نام پروژه به‌صورت زیرنویس کوچک جدا نمایش داده می‌شود.
function gisResultItem(kind, idPrefix, num, toggleFn, color, triggerArray, text) {
    var title = text, sub = '';
    var open = text.lastIndexOf('[');
    if (open > 0 && text.charAt(text.length - 1) == ']') {
        sub = text.substring(open + 1, text.length - 1);
        title = text.substring(0, open);
    }
    return '<div class="gis-item gis-item-' + kind + '">' +
        '<input type="checkbox" class="checkboxSearchResult" id="' + idPrefix + num + '" checked="checked" onclick="' + toggleFn + '(' + num + ');" title="نمایش / مخفی کردن روی نقشه" />' +
        '<span class="gis-swatch" style="background:' + gisEscapeHtml(color) + '"></span>' +
        '<a class="gis-item-text" href="javascript:GEvent.trigger(' + triggerArray + '[' + num + '],\'click\');" title="' + gisEscapeHtml(text) + '">' +
        '<span class="gis-item-title">' + gisEscapeHtml(title) + '</span>' +
        (sub ? '<span class="gis-item-sub">' + gisEscapeHtml(sub) + '</span>' : '') +
        '</a></div>';
}

// وضعیت فیلد «نام پروژه»: none = خالی (همهٔ پروژه‌ها) / invalid = نامی که در لیست نیست / valid = پروژهٔ معتبر
// در حالت خالی پیامی نشان نمی‌دهیم (placeholder خود فیلد کافی است) تا نوار شلوغ نشود
var GIS_PROJECT_HINT = {
    none: '',
    invalid: 'پروژه‌ای با این نام در لیست نیست',
    valid: 'فیلتر روی این پروژه اعمال شد'
};

function gisSetProjectStatus(state) {
    var wrap = jQuery('#gisProjectWrap');
    var hint = jQuery('#gisProjectHint');
    wrap.removeClass('is-valid is-invalid has-value');
    hint.removeClass('is-valid is-invalid');
    if (state == 'valid' || state == 'invalid') {
        wrap.addClass('is-' + state + ' has-value');
        hint.addClass('is-' + state);
    }
    hint.text(GIS_PROJECT_HINT[state] || '');
}

function gisClearProject() {
    jQuery('.NameProjeh').val('').focus();
    FillSugestion_Pishnahadi();
}

jQuery(function () {
    // دکمهٔ پاک‌کردن همان لحظهٔ تایپ ظاهر شود، نه فقط بعد از رویداد change
    jQuery('.NameProjeh').on('input keyup', function () {
        jQuery('#gisProjectWrap').toggleClass('has-value', this.value.length > 0);
    });
    gisSetProjectStatus('none');
});

// پهنای نقشه را CSS (flex) تعیین می‌کند؛ بعد از باز/بسته شدن پنل یا تمام‌صفحه فقط باید به موتور نقشه خبر داد.
// سه موتور در کنترل‌ها استفاده می‌شود: نقشهٔ آفلاین (API نسخهٔ ۲: checkResize)، Leaflet (invalidateSize) و Google v3 (رویداد resize).
function gisResizeMap() {
    if ((typeof map == 'undefined') || map == null) {
        return;
    }
    if (map.checkResize) {
        map.checkResize();
    }
    else if (map.invalidateSize) {
        map.invalidateSize();
    }
    else if (window.google && google.maps && google.maps.event) {
        google.maps.event.trigger(map, 'resize');
    }
}

// ==== فونت پنجرهٔ اطلاعات (InfoWindow) و برچسب‌های روی نقشه ====
// استایل داخلی موتور نقشه روی .gm-style فونت Roboto/Arial را تحمیل می‌کند، پس فونت تم سایت به داخل
// پنجره ارث نمی‌رسد. فونت واقعی صفحه (body) را می‌خوانیم و با !important روی محتوای پنجره می‌گذاریم.
function gisApplyPageFontToMap() {
    var font = '';
    try {
        font = window.getComputedStyle ? window.getComputedStyle(document.body).fontFamily : document.body.currentStyle.fontFamily;
    } catch (e) {
    }
    if (!font || /^\s*$/.test(font)) {
        font = 'Tahoma, Arial, sans-serif';
    }
    // بدون پیشوند .gm-style: موتور نقشه محتوای پنجره را قبل از نمایش، بیرون از نقشه اندازه می‌گیرد؛
    // اگر آن‌جا فونت دیگری اعمال شود اندازهٔ پنجره کوچک‌تر از متن واقعی می‌شود و متن بیرون می‌زند.
    var css = '.gis-iw, .gis-iw td, .gis-iw b, .gis-iw a, ' +
        '.gis-map-label, .estyle1, .estyle2, .estyle3, .estyle4, .estyle5, .estyle6, .estyle7 ' +
        '{ font-family: ' + font + ' !important; }';
    var style = document.createElement('style');
    style.type = 'text/css';
    style.id = 'gisMapFontStyle';
    if (style.styleSheet) {
        style.styleSheet.cssText = css;
    } else {
        style.appendChild(document.createTextNode(css));
    }
    (document.head || document.getElementsByTagName('head')[0]).appendChild(style);
}

jQuery(function () {
    if (!document.getElementById('gisMapFontStyle')) {
        gisApplyPageFontToMap();
    }
});

// ==== شفافیت سطح‌ها (چندضلعی‌ها) ====
// هر ردیف سطح می‌تواند ستون Opacity (0 تا 1) داشته باشد؛ اسلایدر «شفافیت سطح‌ها» وقتی حرکت کند
// روی همهٔ سطح‌های رسم‌شده و سطح‌هایی که بعداً رسم می‌شوند اولویت پیدا می‌کند.
var GIS_AREA_DEFAULT_OPACITY = 0.35;
var gisAreaOpacityOverride = null;

function gisAreaOpacity(value) {
    if (gisAreaOpacityOverride != null) {
        return gisAreaOpacityOverride;
    }
    var v = parseFloat(String(value == null ? '' : value)
        .replace(/[۰-۹]/g, function (d) { return String.fromCharCode(d.charCodeAt(0) - 1776 + 48); })
        .replace(/[,٫]/g, '.'));
    if (isNaN(v) || v < 0 || v > 1) {
        return GIS_AREA_DEFAULT_OPACITY;
    }
    return v;
}

function gisApplyAreaOpacity(percent) {
    var p = parseInt(percent, 10);
    if (isNaN(p)) {
        return;
    }
    gisAreaOpacityOverride = p / 100;
    var lbl = document.getElementById('gisAreaOpacityValue');
    if (lbl) {
        lbl.innerHTML = p + '%';
    }
    if (typeof ggans == 'undefined' || !ggans) {
        return;
    }
    for (var i = 0; i < ggans.length; i++) {
        try {
            if (ggans[i] && ggans[i].setFillStyle) {
                ggans[i].setFillStyle({ opacity: gisAreaOpacityOverride });
            }
        } catch (e) {
        }
    }
}

// ==== حالت تمام‌صفحه ====
// ریشهٔ هر کنترل (div.gis-root) با کلاس gis-fullscreen روی کل پنجرهٔ مرورگر ثابت می‌شود؛ خود API تمام‌صفحهٔ
// مرورگر به کار نمی‌رود چون لیست پیشنهاد و پنجره‌های fancybox خارج از ریشه (روی body) ساخته می‌شوند و
// در آن حالت دیده نمی‌شدند. Esc از حالت تمام‌صفحه خارج می‌کند.
var gisFullscreenRoot = null;

function gisFindRoot(el) {
    while (el && el !== document.body) {
        if (el.className && (' ' + el.className + ' ').indexOf(' gis-root ') >= 0) {
            return el;
        }
        el = el.parentNode;
    }
    return null;
}

function gisToggleFullscreen(btn) {
    var root = gisFindRoot(btn);
    if (!root) {
        return;
    }
    if (gisFullscreenRoot === root) {
        gisExitFullscreen();
        return;
    }
    if (gisFullscreenRoot) {
        gisExitFullscreen();
    }
    gisFullscreenRoot = root;
    jQuery(root).addClass('gis-fullscreen').find('.gis-fs-btn').attr('title', 'خروج از تمام‌صفحه (Esc)');
    jQuery(document.body).addClass('gis-fullscreen-active');
    gisAfterFullscreenChange();
}

function gisExitFullscreen() {
    if (!gisFullscreenRoot) {
        return;
    }
    jQuery(gisFullscreenRoot).removeClass('gis-fullscreen').find('.gis-fs-btn').attr('title', 'نمایش تمام‌صفحه');
    jQuery(document.body).removeClass('gis-fullscreen-active');
    gisFullscreenRoot = null;
    gisAfterFullscreenChange();
}

function gisAfterFullscreenChange() {
    // اندازهٔ جدید بعد از اعمال CSS محاسبه می‌شود؛ یک تیک صبر می‌کنیم
    setTimeout(gisResizeMap, 60);
}

jQuery(document).on('keydown', function (e) {
    if (e.keyCode == 27 && gisFullscreenRoot) {
        gisExitFullscreen();
    }
});

function gisCountChips(stations, routes, areas) {
    return '<span class="gis-chip" title="ایستگاه">' + GIS_ICON_STATION + ' ایستگاه <b>' + stations + '</b></span>' +
        '<span class="gis-chip" title="مسیر">' + GIS_ICON_ROUTE + ' مسیر <b>' + routes + '</b></span>' +
        '<span class="gis-chip" title="سطح">' + GIS_ICON_AREA + ' سطح <b>' + areas + '</b></span>';
}
