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

// پهنای نقشه را CSS (flex) تعیین می‌کند؛ بعد از باز/بسته شدن پنل فقط باید به موتور نقشه خبر داد.
function gisResizeMap() {
    if ((typeof map != 'undefined') && (map != null) && map.checkResize) {
        map.checkResize();
    }
}

function gisCountChips(stations, routes, areas) {
    return '<span class="gis-chip" title="ایستگاه">' + GIS_ICON_STATION + ' ایستگاه <b>' + stations + '</b></span>' +
        '<span class="gis-chip" title="مسیر">' + GIS_ICON_ROUTE + ' مسیر <b>' + routes + '</b></span>' +
        '<span class="gis-chip" title="سطح">' + GIS_ICON_AREA + ' سطح <b>' + areas + '</b></span>';
}
