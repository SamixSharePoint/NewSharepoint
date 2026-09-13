(function ($) {
    $.fn.SlideToggle = function (Settings) {

        var Config = $.extend({
            'Speed': 'fast', //fast or slow
            'PlusImageUrl': null,
            'MinusImageUrl': null,
            'Display': true //false or true
        }, Settings);

        var myObj = this;

        Config.Display ? myObj.show() : myObj.hide();

        myObj.wrap('<div id="SlideToggle">');
        var frame = myObj.parent();
        var lblAttr = 'data-label';

        frame.prepend(
					'<div id="ToggleButton" style="cursor: default;">' +
                        '<table cellpadding="0" cellspacing="0"><tr>' +
                            '<td>' +
						        '<span id="ToggleButtonImg"></span>' +
                            '</td>' +
                            '<td>' +
						        '<span>' + ((myObj.attr(lblAttr) == 'undefined') ? 'No Label' : myObj.attr(lblAttr)) + '</span>' +
                            '<td>' +
                        '</tr></table>' +
					'</div>');
        var toggleButton = frame.children('#ToggleButton');
        var toggleButtonImg = frame.find('#ToggleButtonImg');

        toggleButton.click(function () {
            myObj.toggle(Config.Speed, function () {
                RenderToggleButtonImg();
            });
        });

        myObj.wrap('<div id="SlideToggleContent"></div>');

        RenderToggleButtonImg();

        function RenderToggleButtonImg() {
            if (myObj.css('display') == 'none') {
                if (Config.PlusImageUrl == null)
                    toggleButtonImg.html('<span>+</span>');
                else
                    toggleButtonImg.html('<img src="' + Config.PlusImageUrl + '" border="0" width="16" height="16" />');
            }
            else {
                if (Config.MinusImageUrl == null)
                    toggleButtonImg.html('<span>-</span>');
                else
                    toggleButtonImg.html('<img src="' + Config.MinusImageUrl + '" border="0" width="16" height="16" />');
            }
        }
    }
})($);