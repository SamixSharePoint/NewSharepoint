// توابع مشترک وب‌پارت نقشهٔ آفلاین (Sazmanyar.GoogleMapOffline) — هم‌خانواده با gis-ui.js پروژهٔ GIS:
// فونت پنجرهٔ اطلاعات/جزئیات و حالت تمام‌صفحه. به متغیر سراسری map (GMap2) در زمان اجرا تکیه می‌کند.
// این پروژه jQuery 1.3.2 دارد؛ از bind/keydown استفاده شده نه on.

// ==== فونت پنجرهٔ اطلاعات (InfoWindow) و پنجرهٔ جزئیات ====
// موتور نقشه روی ظرف نقشه فونت خودش (Arial) را می‌گذارد و فونت تم سایت به داخل پنجره ارث نمی‌رسد.
// فونت واقعی صفحه (body) خوانده و با !important روی محتوا اعمال می‌شود؛ بدون پیشوند ظرف نقشه،
// چون موتور محتوا را قبل از نمایش بیرون از نقشه اندازه می‌گیرد و فونت متفاوت باعث بیرون‌زدگی می‌شود.
function gmoApplyPageFontToMap() {
    var font = '';
    try {
        font = window.getComputedStyle ? window.getComputedStyle(document.body).fontFamily : document.body.currentStyle.fontFamily;
    } catch (e) {
    }
    if (!font || /^\s*$/.test(font)) {
        font = 'Tahoma, Arial, sans-serif';
    }
    var css = '.gmo-iw, .gmo-iw h2, .gmo-iw p, .gmo-iw a, #info, .msg-content, .msg-content .title, .msg-content .body, .gmo-ctx, .gmo-ctx a ' +
        '{ font-family: ' + font + ' !important; }';
    var style = document.createElement('style');
    style.type = 'text/css';
    style.id = 'gmoMapFontStyle';
    if (style.styleSheet) {
        style.styleSheet.cssText = css;
    } else {
        style.appendChild(document.createTextNode(css));
    }
    (document.head || document.getElementsByTagName('head')[0]).appendChild(style);
}

jQuery(function () {
    if (!document.getElementById('gmoMapFontStyle')) {
        gmoApplyPageFontToMap();
    }
});

// ==== اندازهٔ نقشه ====
function gmoResizeMap() {
    if ((typeof map != 'undefined') && map != null && map.checkResize) {
        map.checkResize();
    }
}

// ==== حالت تمام‌صفحه ====
// ریشهٔ کنترل (div.gmo-root) با کلاس gmo-fullscreen روی کل پنجرهٔ مرورگر ثابت می‌شود؛ بقیهٔ صفحهٔ شیرپوینت
// زیر آن پنهان می‌ماند. Esc از حالت تمام‌صفحه خارج می‌کند.
var gmoFullscreenRoot = null;

function gmoFindRoot(el) {
    while (el && el !== document.body) {
        if (el.className && (' ' + el.className + ' ').indexOf(' gmo-root ') >= 0) {
            return el;
        }
        el = el.parentNode;
    }
    return null;
}

// حالت تمام‌صفحه در localStorage (به‌ازای آدرس صفحه و شمارهٔ کنترل در صفحه) نگه داشته می‌شود
// تا با رفرش صفحه دوباره برقرار شود؛ با خروج (دکمه یا Esc) پاک می‌شود.
function gmoFullscreenKey(root) {
    var roots = jQuery('.gmo-root').get();
    var idx = 0;
    for (var i = 0; i < roots.length; i++) {
        if (roots[i] === root) {
            idx = i;
        }
    }
    return 'gmoFullscreen:' + window.location.pathname + '#' + idx;
}

function gmoSaveFullscreen(root, on) {
    try {
        if (on) {
            window.localStorage.setItem(gmoFullscreenKey(root), '1');
        } else {
            window.localStorage.removeItem(gmoFullscreenKey(root));
        }
    } catch (e) {
    }
}

function gmoToggleFullscreen(btn) {
    var root = gmoFindRoot(btn);
    if (!root) {
        return;
    }
    if (gmoFullscreenRoot === root) {
        gmoExitFullscreen();
        return;
    }
    if (gmoFullscreenRoot) {
        gmoExitFullscreen();
    }
    gmoFullscreenRoot = root;
    jQuery(root).addClass('gmo-fullscreen').find('.gmo-fs-btn').attr('title', 'خروج از تمام‌صفحه (Esc)');
    jQuery(document.body).addClass('gmo-fullscreen-active');
    gmoSaveFullscreen(root, true);
    setTimeout(gmoResizeMap, 60);
}

function gmoExitFullscreen() {
    if (!gmoFullscreenRoot) {
        return;
    }
    jQuery(gmoFullscreenRoot).removeClass('gmo-fullscreen').find('.gmo-fs-btn').attr('title', 'نمایش تمام‌صفحه');
    jQuery(document.body).removeClass('gmo-fullscreen-active');
    gmoSaveFullscreen(gmoFullscreenRoot, false);
    gmoFullscreenRoot = null;
    setTimeout(gmoResizeMap, 60);
}

jQuery(function () {
    jQuery('.gmo-root').each(function () {
        var root = this;
        try {
            if (window.localStorage.getItem(gmoFullscreenKey(root)) == '1') {
                var btn = jQuery(root).find('.gmo-fs-btn').get(0);
                if (btn) {
                    gmoToggleFullscreen(btn);
                }
            }
        } catch (e) {
        }
    });
});

jQuery(document).keydown(function (e) {
    if (e.keyCode == 27 && gmoFullscreenRoot) {
        gmoExitFullscreen();
    }
});
