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

    function apply() {
        var font = '';
        var faces = '';
        try {
            var pdoc = window.parent && window.parent !== window ? window.parent.document : null;
            if (pdoc) {
                font = window.parent.getComputedStyle(pdoc.body).fontFamily;
                faces = collectFontFaces(pdoc, familiesOf(font));
            }
        } catch (e) {
        }
        if (!font || /^\s*$/.test(font)) {
            font = 'Tahoma, Arial, sans-serif';
        }
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
