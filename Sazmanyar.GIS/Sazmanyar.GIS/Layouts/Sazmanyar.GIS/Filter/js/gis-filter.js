// صفحه‌های تنظیمات جستجو داخل iframe (fancybox) باز می‌شوند و سند جداگانه‌ای دارند؛ بنابراین فونت تم سایت
// به آن‌ها ارث نمی‌رسد و Bootstrap فونت Helvetica/Arial را می‌گذارد. این اسکریپت فونت واقعی صفحهٔ مادر را
// می‌خواند، تعریف‌های @font-face همان فونت را از استایل‌های صفحهٔ مادر (هم‌دامنه) کپی می‌کند و روی این صفحه اعمال می‌کند.
(function () {
    function familiesOf(fontFamily) {
        var out = [];
        var parts = String(fontFamily || '').split(',');
        for (var i = 0; i < parts.length; i++) {
            var f = parts[i].replace(/^\s*["']?|["']?\s*$/g, '').toLowerCase();
            if (f) { out.push(f); }
        }
        return out;
    }

    function collectFontFaces(doc, families) {
        var css = '';
        var sheets;
        try { sheets = doc.styleSheets; } catch (e) { return css; }
        for (var s = 0; s < sheets.length; s++) {
            var rules;
            try { rules = sheets[s].cssRules || sheets[s].rules; } catch (e) { continue; }
            if (!rules) { continue; }
            for (var r = 0; r < rules.length; r++) {
                var rule = rules[r];
                if (rule.type === 5 || (rule.cssText && rule.cssText.indexOf('@font-face') === 0)) {
                    var fam = '';
                    try { fam = rule.style.getPropertyValue('font-family'); } catch (e) { }
                    fam = String(fam || '').replace(/^\s*["']?|["']?\s*$/g, '').toLowerCase();
                    if (fam && families.indexOf(fam) >= 0) {
                        css += rule.cssText + '\n';
                    }
                }
            }
        }
        return css;
    }

    // فونت ثابت صفحه‌های جستجوی پیشرفته (تصمیم 1405/06/30): IRANSansWeb از Filter/fonts (تعریف @font-face در gis-filter.css).
    // مقدار خالی = رفتار قبلی: کپی فونت صفحهء مادر (تم سایت).
    var GIS_FILTER_FIXED_FONT = "'IRANSansWeb', Tahoma, Arial, sans-serif";

    function apply() {
        var font = '';
        var faces = '';
        if (GIS_FILTER_FIXED_FONT) {
            applyCss(GIS_FILTER_FIXED_FONT, '');
            return;
        }
        try {
            var pdoc = window.parent && window.parent !== window ? window.parent.document : null;
            if (pdoc) {
                font = window.parent.getComputedStyle(pdoc.body).fontFamily;
                faces = collectFontFaces(pdoc, familiesOf(font));
            }
        } catch (e) {
        }
        if (!font || /^\s*$/.test(font)) {
            // بدون صفحهء مادر (باز کردن مستقیم آدرس صفحه): همان پشتهء فونت پیش‌فرض SharePoint تا با نمای داخل پاپ‌آپ یکی باشد
            font = '"Segoe UI", Segoe, Tahoma, Helvetica, Arial, sans-serif';
        }
        applyCss(font, faces);
    }

    function applyCss(font, faces) {
        var css = faces +
            'body, .query-builder, .form-control, .btn, .selectize-input, .selectize-dropdown, .bootstrap-select, .dropdown-menu, .tooltip ' +
            '{ font-family: ' + font + ' !important; }';
        var style = document.createElement('style');
        style.type = 'text/css';
        if (style.styleSheet) { style.styleSheet.cssText = css; } else { style.appendChild(document.createTextNode(css)); }
        (document.head || document.getElementsByTagName('head')[0]).appendChild(style);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', apply);
    } else {
        apply();
    }
})();


// ==== فیلترهای جستجوی پیشرفته: مرتب‌سازی الفبایی و کمبوی قابل جستجو ====
// همهء صفحه‌های Filter*.html این دو تابع را استفاده می‌کنند (demo_widgets*.js) تا رفتار یکسان باشد.

// فهرست فیلترهای QueryBuilder را بر اساس برچسب فارسی مرتب می‌کند (نسخهء 2.3.1 گزینهء sort_filters ندارد)
function gisSortFilters(filters) {
    var arr = (filters || []).slice();
    arr.sort(function (a, b) {
        var la = String(a.label || a.id || ''), lb = String(b.label || b.id || '');
        try { return la.localeCompare(lb, 'fa'); } catch (e) { return la < lb ? -1 : (la > lb ? 1 : 0); }
    });
    return arr;
}

// پلاگین‌های QueryBuilder: خطاها به‌صورت tooltip + کمبوی «ستون» و «عملگر» با Bootstrap-select و جستجوی زنده
// (تایپ بخشی از نام ستون، فهرست فیلتر می‌شود)
function gisQueryBuilderPlugins() {
    return {
        'bt-tooltip-errors': null,
        'bt-selectpicker': {
            container: 'body',
            style: 'btn-default',
            width: 'auto',
            size: 12,
            liveSearch: true,
            liveSearchPlaceholder: 'جستجو...',
            liveSearchNormalize: false,
            noneResultsText: 'موردی یافت نشد'
        }
    };
}


// ==== شرح شرط‌های QueryBuilder به زبان گفتاری (برای نمایش در پنل جستجوی صفحهء مادر) ====
// مدل داخلی سازنده (نه SQL) پیمایش می‌شود تا برچسب فارسی ستون‌ها و مقدار انتخاب‌شدهء کمبوها در دسترس باشد.
var GIS_OP_TEXT = {
    'equal': 'برابر «{0}»', 'not_equal': 'مخالف «{0}»',
    'contains': 'شامل «{0}»', 'not_contains': 'بدون «{0}»',
    'begins_with': 'شروع‌شده با «{0}»', 'ends_with': 'پایان‌یافته با «{0}»',
    'less': 'کمتر از {0}', 'less_or_equal': 'حداکثر {0}',
    'greater': 'بیشتر از {0}', 'greater_or_equal': 'دست‌کم {0}',
    'between': 'بین {0} و {1}', 'not_between': 'خارج از {0} تا {1}',
    'in': 'یکی از «{0}»', 'not_in': 'هیچ‌کدام از «{0}»',
    'is_null': 'خالی', 'is_not_null': 'پر شده',
    'is_empty': 'خالی', 'is_not_empty': 'پر شده'
};

// متن نمایشی مقدار یک شرط: برای کمبوهای Selectize برچسب گزینه، وگرنه خود مقدار
function gisRuleValueText(rule, idx) {
    var v = rule.value;
    if (Object.prototype.toString.call(v) === '[object Array]') { v = v[idx || 0]; }
    if (v === undefined || v === null) { return ''; }
    try {
        var inputs = rule.$el.find('.rule-value-container input, .rule-value-container select');
        var el = inputs[idx || 0];
        if (el && el.selectize) {
            var item = el.selectize.getItem(String(v));
            if (item && item.length) { return item.text(); }
        }
        if (el && el.tagName == 'SELECT' && el.selectedIndex >= 0) { return el.options[el.selectedIndex].text; }
    } catch (e) { }
    return String(v);
}

function gisDescribeRule(rule) {
    if (!rule.filter || !rule.operator) { return ''; }
    var tpl = GIS_OP_TEXT[rule.operator.type] || (rule.operator.type + ' {0}');
    var txt = tpl.replace('{0}', gisRuleValueText(rule, 0)).replace('{1}', gisRuleValueText(rule, 1));
    return rule.filter.label + ' ' + txt;
}

function gisDescribeGroup(group, isRoot) {
    var parts = [];
    group.each(function (rule) {
        var t = gisDescribeRule(rule);
        if (t) { parts.push(t); }
    }, function (sub) {
        var t = gisDescribeGroup(sub, false);
        if (t) { parts.push(t); }
    });
    if (parts.length == 0) { return ''; }
    var joiner = (String(group.condition).toUpperCase() == 'OR') ? ' یا ' : ' و ';
    var s = parts.join(joiner);
    return (isRoot || parts.length == 1) ? s : '(' + s + ')';
}

// شرح کل سازنده؛ خالی اگر شرطی نباشد
function gisDescribeBuilder($builder) {
    try {
        var qb = $builder.data('queryBuilder');
        if (!qb || !qb.model || !qb.model.root) { return ''; }
        return gisDescribeGroup(qb.model.root, true);
    } catch (e) {
        return '';
    }
}


// ==== خاموش‌کردن پیشنهادهای خودکار مرورگر روی ورودی‌های شرط ====
// مرورگر مقادیر تایپ‌شدهء قبلی را زیر فیلدهای متنی/تاریخ نشان می‌دهد و روی تقویم می‌افتد؛ کاربر را به انتخاب اشتباه می‌کشاند.
// روی هر ورودی شرط (متن، عدد، تاریخ) و کادر جستجوی کمبوها autocomplete=off گذاشته می‌شود.
jQuery(function ($) {
    function gisNoAutocomplete($root) {
        $root.find('input').not('[type=checkbox],[type=radio]').each(function () {
            this.setAttribute('autocomplete', 'off');
            this.setAttribute('autocorrect', 'off');
            this.setAttribute('spellcheck', 'false');
        });
    }
    var $b = $('#builder-widgets');
    $b.on('afterCreateRuleInput.queryBuilder afterUpdateRuleValue.queryBuilder', function (e, rule) {
        if (rule && rule.$el) { gisNoAutocomplete(rule.$el); }
    });
    // کادر جستجوی Bootstrap-select (کمبوی ستون/عملگر) داخل body باز می‌شود
    $(document).on('shown.bs.select', function () { gisNoAutocomplete($('.bootstrap-select')); });
    $(document).on('focusin', 'input', function () { if (!this.getAttribute('autocomplete')) { gisNoAutocomplete($(this).parent()); } });
});
