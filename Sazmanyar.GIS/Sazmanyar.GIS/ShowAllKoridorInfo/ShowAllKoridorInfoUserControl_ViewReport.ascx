<%@ Assembly Name="$SharePoint.Project.AssemblyFullName$" %>
<%@ Assembly Name="Microsoft.Web.CommandUI, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web.Extensions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ShowAllKoridorInfoUserControl_ViewReport.ascx.cs" Inherits="Sazmanyar.GIS.ShowAllKoridorInfo.ShowAllKoridorInfoUserControl_ViewReport" %>
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
</style>
<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GIS/Script/css/gis-ui.css?v=20260921" />
<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GIS/Fansy/css/jquery.fancybox-1.3.4.css" />
<link rel="stylesheet" type="text/css" href="/_layouts/15/Sazmanyar.GIS/GoogleMap/EWindow.css" />
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-1.7.1.min.js" type="text/javascript"></script>
<link href="/_layouts/15/Sazmanyar.GIS/Script/css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" />
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/jquery-ui-1.10.3.custom.min.js" type="text/javascript"></script>
<script src="/_layouts/15/Sazmanyar.GIS/Script/js/gis-ui.js?v=20260921" type="text/javascript" charset="utf-8"></script>
<script src="/_layouts/15/Sazmanyar.GIS/Fansy/JS/jquery.fancybox-1.3.4.js" type="text/javascript"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/GoogleMap/GISBase.js"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/GoogleMap/EWindow.js"></script>
<script type="text/javascript" src="/_layouts/15/Sazmanyar.GIS/Script/js/Jalali.js"
    charset="utf-8"></script>
<script type="text/javascript" language="javascript">


    function stopRKey(evt) {
        var evt = (evt) ? evt : ((event) ? event : null);
        var node = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);
        if ((evt.keyCode == 13) && (node.type == "text")) { return false; }
    }

    document.onkeypress = stopRKey;

    var SearchOption_Istgah = null;
    var SearchOption_Maseer = null;
    var SearchOption_Sath = null;
    var strCurrentWebUrl = window.location.protocol + "//" + window.location.host + _spPageContextInfo.webServerRelativeUrl;
    if (typeof ($) != 'undefined') {
        $(document).ready(function () {

            var X = jQuery.noConflict();
            X('.NameProjeh').on('change', function () {
                FillSugestion_Pishnahadi();
            });

            X('.NameProjeh').keyup(function (event) {
                FillSugestion_Pishnahadi();
            });

            X.ajax({
                type: "POST",
                url: strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FillSugestion_ProjectName",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (strHtmlOutput) {
                    if (strHtmlOutput.d.trim != '') {
                        availableTags = strHtmlOutput.d.split("*")



                        //global variable that stores the last focused option  
                        var search_option = false;

                        X(".NameProjeh").autocomplete({
                            source: availableTags,

                            //when an item is focused, store item in the global variable  
                            focus: function (event, ui) {
                                search_option = ui.item;
                            },

                            change: function (event, ui) {
                                FillSugestion_Pishnahadi();
                            },

                            //when an item is selected with the keyboard, trigger  
                            //the mouse down event for consistency  
                            select: function (event, ui) {
                                search_option = ui.item;
                                X(".NameProjeh").autocomplete('widget').trigger('mousedown.choose_option');
                            }
                        })

                        //bind the select event to mousedown  
                        X(".NameProjeh").autocomplete('widget').bind('mousedown.choose_option', function () {
                            //immediately closes autocomplete when option is selected  
                            X(".NameProjeh").autocomplete('close');

                            //perform desired action  
                            X(".NameProjeh").val(search_option.value);
                            FillSugestion_Pishnahadi();

                        });




                        //X(".NameProjeh").autocomplete({
                        //    minLength: 1,
                        //    source: availableTags,
                        //    messages: {
                        //        noResults: '',
                        //        results: function () { }
                        //    },
                        //    select: function (event, ui) {
                        //        FillSugestion_Pishnahadi();
                        //    },
                        //    change: function (event, ui) {
                        //        FillSugestion_Pishnahadi();
                        //    }

                        //});

                        X('.NameProjeh').trigger("click"); //or "click", at least one should work
                    }
                },
                error: function (MSG) {
                    alert('error' + MSG);
                }
            });

        });
    }

    function HidePanelSearchAndReports() {
        document.getElementById('divReportsOptions').style.display = 'none';
        document.getElementById('map_ReportsArrow').src = '/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Reports.jpg';
        document.getElementById('map_ReportsArrow').title = 'نمایش فرم گزارشات';


        document.getElementById('divSearchOptions').style.display = 'none';
        document.getElementById('map_SearchArrow').src = '/_layouts/15/images/Sazmanyar.GIS/GoogleMap/left-arrow.png';
        document.getElementById('map_SearchArrow').title = 'نمایش فرم جستجو';

        gisResizeMap();
    }

    var bVaziyatSelect = false;
    var availableTags;
    function FillSugestion_Pishnahadi() {
        var X = jQuery.noConflict();
        var strNameProjeh = X(".NameProjeh").val();
        if (strNameProjeh == null || strNameProjeh.toString().length == 0) {
            gisSetProjectStatus('none');
            bVaziyatSelect = false;
            currentProject = "";

            map.clearOverlays();
            HidePanelSearchAndReports();

        }
        else {
            gisSetProjectStatus('invalid');
            bVaziyatSelect = false;
            currentProject = "";
            map.clearOverlays();
            HidePanelSearchAndReports();

        }

        for (var i = 0; i < availableTags.length; i++) {
            if (strNameProjeh == availableTags[i]) {
                gisSetProjectStatus('valid');
                bVaziyatSelect = true;
                InitializeFilterInMap();
                break;
            }
        }
    }
    function RefereshReportsLinks() {

        if (bVaziyatSelect == false) {

            document.getElementById("divReportsOptions").innerHTML = "<div class='gis-msg'>جهت نمایش گزارش انتخاب نام پروژه الزامی است</div>";
            HidePanelSearchAndReports();

            return;
        }

        var NameProjeh = X('.NameProjeh').val();

        document.getElementById('divReportsOptions').innerHTML = '<div class="gis-msg gis-msg-wait">لطفاً کمی صبر نمایید ...<br />سیستم در حال جستجوی اطلاعات مورد نیاز شما می باشد</div>';

        X.ajax({
            type: "POST",
            url: strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchAllReportsByProjectName",
            data: "{'ProgramName':'" + NameProjeh.replace("#@#", "") + "'}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (strHtmlOutput) {

                if (NameProjeh != X('.NameProjeh').val()) {
                    //Not Continue
                    return;
                }

                var divReportsOptions_innerHTML = "<div class='gis-reports-title'>گزارش های طرح " + gisEscapeHtml(NameProjeh.replace("#@#", "")) + "</div>";
                if (strHtmlOutput.d != '' && strHtmlOutput.d != null && strHtmlOutput.d.length > 0) {


                    var result = strHtmlOutput.d;
                    for (var i = 0; i < result.length; i++) {
                        divReportsOptions_innerHTML = divReportsOptions_innerHTML + "<a class='gis-report-link' target='_blank' href='" + gisEscapeHtml(result[i].URLInfo) + "'>" + (i + 1).toString() + ". " + gisEscapeHtml(result[i].Title) + "</a>";
                    }
                    document.getElementById('divReportsOptions').innerHTML = divReportsOptions_innerHTML;
                }
                else {
                    document.getElementById("divReportsOptions").innerHTML = "<div class='gis-msg'>هیچ موردی جهت نمایش گزارش یافت نشد</div>";
                }
            },
            error: function (MSG) {
                alert('error' + MSG);
            }
        });
    }


    var X = jQuery.noConflict();
    var ListSearchResultID = [];
    var bRidirect = false;
    bUseDataBaseRah141 = true;

    function GetRulesWidgets_Istgah() {
        if (SearchOption_Istgah != null) {
            var Sql = SearchOption_Istgah.sql.replace("SELECT * FROM table WHERE ", "").replace(/NNNNNNNNNNN/g, "").replace(/DDDDDDDDDDD/g, ""); // For Unucode Support;
            if (Sql.trim().length == 0) {
                return null;
            }
            SearchOption_Istgah.sql = Sql
        }
        return SearchOption_Istgah;
    }

    function GetRulesWidgets_Maseer() {
        if (SearchOption_Maseer != null) {
            var Sql = SearchOption_Maseer.sql.replace("SELECT * FROM table WHERE ", "").replace(/NNNNNNNNNNN/g, "").replace(/DDDDDDDDDDD/g, ""); // For Unucode Support;
            if (Sql.trim().length == 0) {
                return null;
            }
            SearchOption_Maseer.sql = Sql
        }
        return SearchOption_Maseer;
    }

    function GetRulesWidgets_Sath() {
        if (SearchOption_Sath != null) {
            var Sql = SearchOption_Sath.sql.replace("SELECT * FROM table WHERE ", "").replace(/NNNNNNNNNNN/g, "").replace(/DDDDDDDDDDD/g, ""); // For Unucode Support;
            if (Sql.trim().length == 0) {
                return null;
            }
            SearchOption_Sath.sql = Sql
        }
        return SearchOption_Sath;
    }

    function setInformation_Istgah(data, description) {
        gisSetSearchDescription('Istgah', description);
        return SearchOption_Istgah = data;
    };

    function setInformation_Sath(data, description) {
        gisSetSearchDescription('Sath', description);
        return SearchOption_Sath = data;
    };

    function setInformation_Maseer(data, description) {
        gisSetSearchDescription('Maseer', description);
        return SearchOption_Maseer = data;
    };

    var currentProject = "";
    function InitializeFilterInMap() {
        var NameProjeh = X('.NameProjeh').val();
        if (currentProject == NameProjeh) {
            return;
        }
        currentProject = NameProjeh

        document.getElementById('btnDelSearchOption').style.visibility = 'hidden';
        document.getElementById('btnShowSearchOptionSath').style.visibility = 'hidden';
        document.getElementById('btnShowSearchOptionMaseer').style.visibility = 'hidden';
        document.getElementById('btnShowSearchOptionIstgah').style.visibility = 'hidden';


        X.ajax({
            type: "POST",
            url: strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchAbstractInfoFromDataBase_New",
            data: "{'NameProjeh':'" + NameProjeh + "'}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (strHtmlOutput) {

                if (NameProjeh != X('.NameProjeh').val() || bVaziyatSelect == false) {
                    //Not Continue
                    return;
                }

                if (strHtmlOutput.d != '' && strHtmlOutput.d != null) {

                    var result = strHtmlOutput.d;

                    var polygon_count = 0;
                    try {
                        polygon_count = result.polygon;
                    } catch (e) {

                    }
                    var polyline_count = 0;
                    try {
                        polyline_count = result.polyline;
                    } catch (e) {

                    }
                    var point_count = 0;
                    try {
                        point_count = result.point;

                    } catch (e) {

                    }

                    if (polygon_count > 0) {
                        document.getElementById('btnDelSearchOption').style.visibility = 'visible';
                        document.getElementById('btnShowSearchOptionSath').style.visibility = 'visible';
                    }


                    if (polyline_count > 0) {
                        document.getElementById('btnDelSearchOption').style.visibility = 'visible';
                        document.getElementById('btnShowSearchOptionMaseer').style.visibility = 'visible';
                    }


                    if (point_count > 0) {
                        document.getElementById('btnDelSearchOption').style.visibility = 'visible';
                        document.getElementById('btnShowSearchOptionIstgah').style.visibility = 'visible';
                    }

                }

                RefereshAllRoutInMap();
                RefereshReportsLinks();
            },
            error: function (MSG) {
                alert('error' + MSG);
            }
        });
    }

    function RefereshAllRoutInMap() {

        if (bVaziyatSelect == false) {
            alert("جهت جستجو انتخاب نام پروژه الزامی است");

            HidePanelSearchAndReports();

            return;
        }

        var NameProjeh = X('.NameProjeh').val();
        var Condition = "";
        if (SearchOption_Istgah != null) {
            Condition = SearchOption_Istgah.sql.replace("SELECT * FROM table WHERE ", "").replace(/'/g, "#@#").replace(/NNNNNNNNNNN/g, "N"); // For Unucode Support
            Condition = " ( " + Condition + ") and ( Title is null ) "
        }

        if (SearchOption_Maseer != null) {

            if (Condition != "") {
                Condition = " ( " + Condition + ") OR  "
            }

            Condition = Condition + ' (' + SearchOption_Maseer.sql.replace("SELECT * FROM table WHERE ", "").replace(/'/g, "#@#").replace(/NNNNNNNNNNN/g, "N") + " )"; // For Unucode Support
        }

        if (SearchOption_Sath != null) {

            if (Condition != "") {
                Condition = " ( " + Condition + ") OR  "
            }

            Condition = Condition + ' (' + SearchOption_Sath.sql.replace("SELECT * FROM table WHERE ", "").replace(/'/g, "#@#").replace(/NNNNNNNNNNN/g, "N") + " )"; // For Unucode Support
        }

        X.fancybox.close();

        document.getElementById("divSearchCount").innerHTML = '';
        document.getElementById('divSearchResult').innerHTML = '<div class="gis-msg gis-msg-wait">لطفاً کمی صبر نمایید ...<br />سیستم در حال جستجوی اطلاعات مورد نیاز شما می باشد</div>';

        gpolys = [];
        gmarkers = [];
        map.clearOverlays();
        divSearchResult_html = ""
        bounds = new GLatLngBounds(new GLatLng(39.027719, 44.736328), new GLatLng(26.745610, 62.050781)); // Iran
        FetchRecursiveAllCoridorInfoFromDataBase(NameProjeh, Condition, 100, 1);
    }

    function FetchRecursiveAllCoridorInfoFromDataBase(NameProjeh, Condition, PageSize, PageIndex) {
        if (PageIndex == 1) {
            bounds = new GLatLngBounds();
        }

        X.ajax({
            type: "POST",
            url: strCurrentWebUrl + "/_layouts/15/Sazmanyar.GIS/ApplicationPage_FetchingData.aspx/FetchAllCoridorInfoFromDataBase_NewCombine_ByPaging",
            data: "{'NameProjeh':'" + NameProjeh + "' ,'Condition':'" + Condition + "' , 'PageSize':'" + PageSize + "', 'PageIndex':'" + PageIndex + "'}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (strHtmlOutput) {

                if (NameProjeh != X('.NameProjeh').val()) {
                    //Not Continue
                    return;
                }

                if (strHtmlOutput.d != '' && strHtmlOutput.d != null && strHtmlOutput.d.length > 0) {
                    var result = strHtmlOutput.d;
                    for (var i = 0; i < result.length; i++) {
                        ListSearchResultID.push(result[i].ID)
                        initializeGMapForKoridorInfo(result[i]);
                    }

                    map.centerAndZoomOnBounds(bounds);
                    document.getElementById("divSearchCount").innerHTML = gisKoridorFilterSummary(NameProjeh, '') + gisCountChips(gmarkers.length, gpolys.length, ggans.length);
                    document.getElementById("divSearchResult").innerHTML = divSearchResult_html;
                    FetchRecursiveAllCoridorInfoFromDataBase(NameProjeh, Condition, PageSize, PageIndex + 1);

                }
                else {

                    if (PageIndex == 1) {
                        document.getElementById("divSearchCount").innerHTML = gisKoridorFilterSummary(NameProjeh, '');
                        document.getElementById('divSearchResult').innerHTML = '<div class="gis-msg">هیچ موردی جهت نمایش در لیست یافت نشد</div>';
                    }
                }

                //divSearchResult_html = "";
                //if (divSearchResult_html != '') {
                //    document.getElementById("divSearchResult").innerHTML = divSearchResult_html;
                //}
                //else {
                //    document.getElementById('divSearchResult').innerHTML = '<p style=\'color:blue\'>هیچ موردی جهت نمایش در لیست یافت نشد </p>';
                //}

            },
            error: function (MSG) {
                alert('error' + MSG);
            }
        });
    }


    function initializeGMapForKoridorInfo(ObjAllRoutInfo) {

        var result = "";

        if (ObjAllRoutInfo.Points != null && ObjAllRoutInfo.Points != "") {
            try {
                result = JSON.parse(ObjAllRoutInfo.Points);
            } catch (e) {
            }
        }
        var CurrentColor = ObjAllRoutInfo.Color;

        var ID = 0;
        var Title = "";
        var points = [];
        var BaseColor = '#00b2ff';

        var StationFrom_ID = 0;
        var StationFrom_Title = "";
        var LatFrom = 0;
        var LongFrom = 0;

        var StationTo_ID = 0;
        var StationTo_Title = "";
        var LatTo = 0;
        var LongTo = 0;


        if (typeof (ObjAllRoutInfo.ID) != 'undefined' && ObjAllRoutInfo.ID != null) {
            ID = ObjAllRoutInfo.ID;
        }

        if (typeof (ObjAllRoutInfo.Title) != 'undefined' && ObjAllRoutInfo.Title != null) {
            Title = ObjAllRoutInfo.Title;
        }

        for (var i = 0, len = result.length; i < len; i++) {
            var point = new GLatLng(result[i].lat, result[i].lng);
            points.push(point);
        }
        if (typeof (CurrentColor) != 'undefined' && CurrentColor != null) {
            BaseColor = CurrentColor;
        }


        if (typeof (ObjAllRoutInfo.StationFrom_ID) != 'undefined' && ObjAllRoutInfo.StationFrom_ID != null) {
            StationFrom_ID = ObjAllRoutInfo.StationFrom_ID;
        }

        if (typeof (ObjAllRoutInfo.StationFrom_Title) != 'undefined' && ObjAllRoutInfo.StationFrom_Title != null) {
            StationFrom_Title = ObjAllRoutInfo.StationFrom_Title;
        }

        if (typeof (ObjAllRoutInfo.LatFrom) != 'undefined' && ObjAllRoutInfo.LatFrom != null) {
            LatFrom = ObjAllRoutInfo.LatFrom;
        }

        if (typeof (ObjAllRoutInfo.LongFrom) != 'undefined' && ObjAllRoutInfo.LongFrom != null) {
            LongFrom = ObjAllRoutInfo.LongFrom;
        }


        if (typeof (ObjAllRoutInfo.StationTo_ID) != 'undefined' && ObjAllRoutInfo.StationTo_ID != null) {
            StationTo_ID = ObjAllRoutInfo.StationTo_ID;
        }

        if (typeof (ObjAllRoutInfo.StationTo_Title) != 'undefined' && ObjAllRoutInfo.StationTo_Title != null) {
            StationTo_Title = ObjAllRoutInfo.StationTo_Title;
        }

        if (typeof (ObjAllRoutInfo.LatTo) != 'undefined' && ObjAllRoutInfo.LatTo != null) {
            LatTo = ObjAllRoutInfo.LatTo;
        }

        if (typeof (ObjAllRoutInfo.LongTo) != 'undefined' && ObjAllRoutInfo.LongTo != null) {
            LongTo = ObjAllRoutInfo.LongTo;
        }

        createClickableObject_Custom(ID, Title, points, BaseColor, StationFrom_ID, StationFrom_Title, LatFrom, LongFrom, StationTo_ID, StationTo_Title, LatTo, LongTo, ObjAllRoutInfo);

    }

    function GetExtendTableForPopUp(ObjAllRoutInfo, bIsRoute) {
        var ExtendHtml = "";
        if (ObjAllRoutInfo.ProgramType == 'فیبر') {

            ExtendHtml = ExtendHtml + "<table  style='border: thin solid #0000FF' border='1'  cellpadding ='5' >";

            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " طول مسير: <b>" + ObjAllRoutInfo.FibrLongRoute + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";

            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " نوع كابل: <b>" + ObjAllRoutInfo.TypeCable + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";

            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " تعداد کابل: <b>" + ObjAllRoutInfo.FibrCountCable + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";

            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " نوع مسير: <b>" + ObjAllRoutInfo.FibrTypeRoute + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";

            ExtendHtml = ExtendHtml + "</table>";
        } else if (ObjAllRoutInfo.ProgramType == 'رادیویی') {

            ExtendHtml = ExtendHtml + "<table  style='border: thin solid #0000FF' border='1'  cellpadding ='5' >";

            if (bIsRoute == false) {

                ExtendHtml = ExtendHtml + "<tr>";
                ExtendHtml = ExtendHtml + "<td>";
                try {

                    ExtendHtml = ExtendHtml + " ديوايدر: <b>" + ObjAllRoutInfo.FibrTypeRoute + "</b>";
                } catch (e) {

                }
                ExtendHtml = ExtendHtml + "</td>";
                ExtendHtml = ExtendHtml + "</tr>";


                ExtendHtml = ExtendHtml + "<tr>";
                ExtendHtml = ExtendHtml + "<td>";
                try {

                    ExtendHtml = ExtendHtml + " مديريت شبكه : <b>" + ObjAllRoutInfo.RadioStationNetWork + "</b>";
                } catch (e) {

                }
                ExtendHtml = ExtendHtml + "</td>";
                ExtendHtml = ExtendHtml + "</tr>";




                ExtendHtml = ExtendHtml + "<tr>";
                ExtendHtml = ExtendHtml + "<td>";
                try {

                    ExtendHtml = ExtendHtml + " راديو : <b>" + ObjAllRoutInfo.RadioStationRadio + "</b>";
                } catch (e) {

                }
                ExtendHtml = ExtendHtml + "</td>";
                ExtendHtml = ExtendHtml + "</tr>";



                ExtendHtml = ExtendHtml + "<tr>";
                ExtendHtml = ExtendHtml + "<td>";
                try {

                    ExtendHtml = ExtendHtml + " تغذيه نيرو : <b>" + ObjAllRoutInfo.RadioStationPower + "</b>";
                } catch (e) {

                }
                ExtendHtml = ExtendHtml + "</td>";
                ExtendHtml = ExtendHtml + "</tr>";





                ExtendHtml = ExtendHtml + "<tr>";
                ExtendHtml = ExtendHtml + "<td>";
                try {

                    ExtendHtml = ExtendHtml + " دكل : <b>" + ObjAllRoutInfo.RadioStationTower + "</b>";
                } catch (e) {

                }
                ExtendHtml = ExtendHtml + "</td>";
                ExtendHtml = ExtendHtml + "</tr>";

            } else {

                ExtendHtml = ExtendHtml + "<tr>";
                ExtendHtml = ExtendHtml + "<td>";
                try {

                    ExtendHtml = ExtendHtml + " فیبر : <b>" + ObjAllRoutInfo.RadioRouteFiber + "</b>";
                } catch (e) {

                }
                ExtendHtml = ExtendHtml + "</td>";
                ExtendHtml = ExtendHtml + "</tr>";



                ExtendHtml = ExtendHtml + "<tr>";
                ExtendHtml = ExtendHtml + "<td>";
                try {

                    ExtendHtml = ExtendHtml + " فيبر-  لاين ترمينال: <b>" + ObjAllRoutInfo.RadioRouteLineTerminal + "</b>";
                } catch (e) {

                }
                ExtendHtml = ExtendHtml + "</td>";
                ExtendHtml = ExtendHtml + "</tr>";


                ExtendHtml = ExtendHtml + "<tr>";
                ExtendHtml = ExtendHtml + "<td>";
                try {

                    ExtendHtml = ExtendHtml + " راديو : <b>" + ObjAllRoutInfo.RadioRouteRadio + "</b>";
                } catch (e) {

                }
                ExtendHtml = ExtendHtml + "</td>";
                ExtendHtml = ExtendHtml + "</tr>";

            }

            ExtendHtml = ExtendHtml + "</table>";
        } else if (ObjAllRoutInfo.ProgramType == 'دیتا و سوئیج') {

            ExtendHtml = ExtendHtml + "<table  style='border: thin solid #0000FF' border='1'  cellpadding ='5' >";

            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " نوع تجهيزات: <b>" + ObjAllRoutInfo.SwitchTypeEquipment + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";

            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " تعداد لينك: <b>" + ObjAllRoutInfo.SwitchCountLink + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";


            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " پهناي باند واگذارشده : <b>" + ObjAllRoutInfo.SwitchBandwidth + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";

            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " ظرفيت اينترنت واگذارشده : <b>" + ObjAllRoutInfo.SwitchInternetCapacity + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";

            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " تعداد پورت دسترسي : <b>" + ObjAllRoutInfo.SwitchCountPortAccess + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";

            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " تعداد پورت قابل واگذاري : <b>" + ObjAllRoutInfo.SwitchCountPortAssignment + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";


            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " تعداد اسلات خالي : <b>" + ObjAllRoutInfo.SwitchBlankSlot + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";

            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " تعداد اينترفيس خالي برابر لينكهاي جديد: <b>" + ObjAllRoutInfo.SwitchInterface + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";
            ExtendHtml = ExtendHtml + "</table>";
        } else if (ObjAllRoutInfo.ProgramType == 'مالتی پلکس') {

            ExtendHtml = ExtendHtml + "<table  style='border: thin solid #0000FF' border='1'  cellpadding ='5' >";

            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " ظرفيت لينك: <b>" + ObjAllRoutInfo.MultiplexLinkCapacity + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";

            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " تضعيف لينك: <b>" + ObjAllRoutInfo.MultiplexWeakeningLink + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";


            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " مسافت : <b>" + ObjAllRoutInfo.MultiplexDistance + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";

            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " تضعيف كابل : <b>" + ObjAllRoutInfo.MultiplexCableAttenuation + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";

            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " تعداد لاندا : <b>" + ObjAllRoutInfo.MultiplexCountLynda + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";

            ExtendHtml = ExtendHtml + "<tr>";
            ExtendHtml = ExtendHtml + "<td>";
            try {

                ExtendHtml = ExtendHtml + " نوع ايستگاه : <b>" + ObjAllRoutInfo.MultiplexTypeStation + "</b>";
            } catch (e) {

            }
            ExtendHtml = ExtendHtml + "</td>";
            ExtendHtml = ExtendHtml + "</tr>";

            ExtendHtml = ExtendHtml + "</table>";
        }



        return ExtendHtml;
    }

    function createClickableObject_Custom(ID, label, points, BaseColor, StationFrom_ID, StationFrom_Title, LatFrom, LongFrom, StationTo_ID, StationTo_Title, LatTo, LongTo, ObjAllRoutInfo) {

        var myIcon = get_icon(BaseColor);
        var ExtendTableForPopUp = "";

        if (points.length > 0 && LatFrom == 0 && LongFrom == 0) {
            // ExtendTableForPopUp = GetExtendTableForPopUp(ObjAllRoutInfo, true);

            var HTMlGan = "";
            HTMlGan = HTMlGan + "<div class='gis-iw'>";

            HTMlGan = HTMlGan + "<table cellpadding ='5' >";

            HTMlGan = HTMlGan + "<tr>";
            HTMlGan = HTMlGan + "<td>";


            //-------------------------


            HTMlGan = HTMlGan + "<table cellpadding ='5' >";

            HTMlGan = HTMlGan + "<tr>";
            HTMlGan = HTMlGan + "<td>";
            try {

                HTMlGan = HTMlGan + " سطح: <b>" + gisEscapeHtml(String(label || "").replace(/\s*\[[^\]]*\]\s*$/, "")) + "</b>";
            } catch (e) {

            }
            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "<td>";
            try {

                HTMlGan = HTMlGan + " پروژه: <b>" + gisEscapeHtml(ObjAllRoutInfo.ProgramName || "-") + "</b>";
            } catch (e) {

            }
            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "</tr>";

            //            HTMlGan = HTMlGan + "<tr>";
            //            HTMlGan = HTMlGan + "<td>";
            //            try {

            //                HTMlGan = HTMlGan + "عنوان: <b>" + Title + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlGan = HTMlGan + "</td>";
            //            HTMlGan = HTMlGan + "<td>";
            //            try {

            //                //                HTMlGan = HTMlGan + "تعداد کر: <b>" + ObjAllRoutInfo.NumberCore + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlGan = HTMlGan + "</td>";
            //            HTMlGan = HTMlGan + "</tr>";


            HTMlGan = HTMlGan + "<tr>";
            HTMlGan = HTMlGan + "<td>";
            try {

                if (ObjAllRoutInfo.RouteStartDate == null || ObjAllRoutInfo.RouteStartDate == '' || ObjAllRoutInfo.RouteStartDate == 'NULL') {
                    HTMlGan = HTMlGan + "تاریخ شروع : <b> - </b>";
                }
                else {
                    HTMlGan = HTMlGan + "تاریخ شروع : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.RouteStartDate) + "</b>";
                }
            } catch (e) {

            }
            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "<td>";
            try {
                if (ObjAllRoutInfo.RouteFinishDate == null || ObjAllRoutInfo.RouteFinishDate == '' || ObjAllRoutInfo.RouteFinishDate == 'NULL') {
                    HTMlGan = HTMlGan + "تاریخ پایان : <b> - </b>";
                }
                else {
                    HTMlGan = HTMlGan + "تاریخ پایان : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.RouteFinishDate) + "</b>";
                }
            } catch (e) {

            }
            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "</tr>";
            HTMlGan = HTMlGan + "<tr>";
            HTMlGan = HTMlGan + "<td>";
            try {

                if (ObjAllRoutInfo.RouteBaselineStartDate == null || ObjAllRoutInfo.RouteBaselineStartDate == '' || ObjAllRoutInfo.RouteBaselineStartDate == 'NULL') {
                    HTMlGan = HTMlGan + "تاریخ شروع برنامه ای : <b> - </b>";
                }
                else {
                    HTMlGan = HTMlGan + "تاریخ شروع برنامه ای : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.RouteBaselineStartDate) + "</b>";
                }
            } catch (e) {

            }
            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "<td>";
            try {
                if (ObjAllRoutInfo.RouteBaselineFinishDate == null || ObjAllRoutInfo.RouteFinishDate == '' || ObjAllRoutInfo.RouteBaselineFinishDate == 'NULL') {
                    HTMlGan = HTMlGan + "تاریخ پایان برنامه ای : <b> - </b>";
                }
                else {
                    HTMlGan = HTMlGan + "تاریخ پایان برنامه ای : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.RouteBaselineFinishDate) + "</b>";
                }
            } catch (e) {

            }
            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "</tr>";
            HTMlGan = HTMlGan + "<tr>";
            HTMlGan = HTMlGan + "<td>";
            try {

                if (ObjAllRoutInfo.RouteActualStartDate == null || ObjAllRoutInfo.RouteActualStartDate == '' || ObjAllRoutInfo.RouteActualStartDate == 'NULL') {
                    HTMlGan = HTMlGan + "تاریخ شروع واقعی : <b> - </b>";
                }
                else {
                    HTMlGan = HTMlGan + "تاریخ شروع واقعی : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.RouteActualStartDate) + "</b>";
                }
            } catch (e) {

            }
            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "<td>";
            try {
                if (ObjAllRoutInfo.RouteActualFinishDate == null || ObjAllRoutInfo.RouteActualFinishDate == '' || ObjAllRoutInfo.RouteActualFinishDate == 'NULL') {
                    HTMlGan = HTMlGan + "تاریخ پایان واقعی : <b> - </b>";
                }
                else {
                    HTMlGan = HTMlGan + "تاریخ پایان واقعی : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.RouteActualFinishDate) + "</b>";
                }
            } catch (e) {

            }
            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "</tr>";
            //            HTMlGan = HTMlGan + "<tr>";
            //            HTMlGan = HTMlGan + "<td>";
            //            try {

            //                HTMlGan = HTMlGan + "طول مسیر هوایی: <b>" + ObjAllRoutInfo.PlaneDistanceMap + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlGan = HTMlGan + "</td>";
            //            HTMlGan = HTMlGan + "<td>";
            //            try {

            //                HTMlGan = HTMlGan + "طول مسیر جغرافیایی: <b>" + ObjAllRoutInfo.PlaneDistanceChart + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlGan = HTMlGan + "</td>";
            //            HTMlGan = HTMlGan + "</tr>";


            //            HTMlGan = HTMlGan + "<tr>";
            //            HTMlGan = HTMlGan + "<td>";
            //            try {

            //                HTMlGan = HTMlGan + "میزان افت کر اول: <b>" + ObjAllRoutInfo.ReduceCore1 + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlGan = HTMlGan + "</td>";
            //            HTMlGan = HTMlGan + "<td>";
            //            try {

            //                HTMlGan = HTMlGan + "میزان افت کر دوم: <b>" + ObjAllRoutInfo.ReduceCore2 + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlGan = HTMlGan + "</td>";
            //            HTMlGan = HTMlGan + "</tr>";


            HTMlGan = HTMlGan + "<tr>";
            HTMlGan = HTMlGan + "<td>";
            try {

                HTMlGan = HTMlGan + "درصد پیشرفت برنامه ای: <b>" + ObjAllRoutInfo.RoutePlan + "</b>";
            } catch (e) {

            }
            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "<td>";
            try {

                HTMlGan = HTMlGan + "درصد پیشرفت واقعی: <b>" + ObjAllRoutInfo.RouteActual + "</b>";
            } catch (e) {

            }
            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "</tr>";


            HTMlGan = HTMlGan + "<tr>";
            HTMlGan = HTMlGan + "<td>";
            try {
                HTMlGan = HTMlGan + "درصد تحقق: <b>" + ObjAllRoutInfo.PercentTahaghoghRoute + "</b>";

            } catch (e) {

            }
            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "<td>";
            try {
                HTMlGan = HTMlGan + "<a href='/reports/SitePages/SReport_Route.aspx?ProjectUID=" + ObjAllRoutInfo.ProjectUID + "&Route=" + ObjAllRoutInfo.RouteID + "' target='_blank'>نمودار S</a> ";

            } catch (e) {

            }
            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "</tr>";

            HTMlGan = HTMlGan + "<tr>";
            HTMlGan = HTMlGan + "<td>";
            try {
                HTMlGan = HTMlGan + "<a href='/reports/SitePages/CashFlow_Route.aspx?ProjectUID=" + ObjAllRoutInfo.ProjectUID + "&Route=" + ObjAllRoutInfo.RouteID + "' target='_blank'>جریان نقدینگی</a> ";

            } catch (e) {

            }
            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "<td>";
            try {
                HTMlGan = HTMlGan + "<a href='/reports/SitePages/TaskDetails_Route.aspx?ProjectUID=" + ObjAllRoutInfo.ProjectUID + "&Route=" + ObjAllRoutInfo.RouteID + "' target='_blank'>فعالیت مسیر</a> ";

            } catch (e) {

            }
            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "</tr>";
            HTMlGan = HTMlGan + "</tr>";
            HTMlGan = HTMlGan + "</table>";


            //-------------------------

            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "<td>";

            HTMlGan = HTMlGan + ExtendTableForPopUp;


            HTMlGan = HTMlGan + "</td>";
            HTMlGan = HTMlGan + "</tr>";

            HTMlGan = HTMlGan + "</table>";

            HTMlGan = HTMlGan + "</div>";


            //if (Polygon) { map.removeOverlay(Polygon); } //Remove existing Polygon from Map

            PolygonPoints = points
            if (PolygonPoints.length < 1) {
                return;
            }

            //Add first marker in the end to close the Polygon
            PolygonPoints.push(points[0]);

            // رنگ دور/داخل و شفافیت سطح از ستون‌های BorderColor / FillColor / Opacity؛ اگر خالی بودند رنگ ردیف و شفافیت پیش‌فرض
            var FillColor = ObjAllRoutInfo.FillColor ? ObjAllRoutInfo.FillColor : BaseColor;
            var BorderColor = ObjAllRoutInfo.BorderColor ? ObjAllRoutInfo.BorderColor : BaseColor;
            var Polygon = new GPolygon(PolygonPoints, BorderColor, 2, 1, FillColor, gisAreaOpacity(ObjAllRoutInfo.Opacity), { clickable: false }); //New GPolygon object
            Polygon.gisOpacity = gisAreaOpacity(ObjAllRoutInfo.Opacity);

            ggans.push(Polygon);

            ////TO DO: Function Call triggered after Polygon is drawn
            //fitPolygon(Polygon);

            var gan_num = ggans.length - 1;
            if (HTMlGan) {

                GEvent.addListener(Polygon, 'click', function (point) {
                    if (!point) {
                        point = Polygon.getVertex(Math.floor(Polygon.getVertexCount() / 2));
                    }
                });

                GEvent.addListener(map, "click", function (overlay, point) {
                    if (!overlay) {
                        if (Polygon.Contains(point)) {
                            map.openInfoWindowHtml(point, HTMlGan);
                        }
                    }
                });
            }

            if (!label) {
                label = "polyGan #" + gan_num;
            }
            divSearchResult_html += gisResultItem('area', 'Gan', gan_num, 'toggleGan', FillColor, 'ggans', label);

            if (Polygon && Polygon.getBounds && Polygon.getBounds()) {
                if (debug) { GLog.write(Polygon.getBounds() + ":" + Polygon.getBounds().getNorthEast() + ":" + Polygon.getBounds().getSouthWest()) }
                bounds.extend(Polygon.getBounds().getNorthEast());
                bounds.extend(Polygon.getBounds().getSouthWest());
            }
            map.addOverlay(Polygon);
        }
        else if (points.length > 0) {
            // ExtendTableForPopUp = GetExtendTableForPopUp(ObjAllRoutInfo, true);

            var HTMlPoly = "";
            HTMlPoly = HTMlPoly + "<div class='gis-iw'>";

            HTMlPoly = HTMlPoly + "<table cellpadding ='5' >";

            HTMlPoly = HTMlPoly + "<tr>";
            HTMlPoly = HTMlPoly + "<td>";


            //-------------------------


            HTMlPoly = HTMlPoly + "<table cellpadding ='5' >";

            HTMlPoly = HTMlPoly + "<tr>";
            HTMlPoly = HTMlPoly + "<td>";
            try {

                HTMlPoly = HTMlPoly + " مبدا: <b>" + StationFrom_Title + "</b>";
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "<td>";
            try {

                HTMlPoly = HTMlPoly + " مقصد: <b>" + StationTo_Title + "</b>";
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "</tr>";

            //            HTMlPoly = HTMlPoly + "<tr>";
            //            HTMlPoly = HTMlPoly + "<td>";
            //            try {

            //                HTMlPoly = HTMlPoly + "عنوان: <b>" + Title + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlPoly = HTMlPoly + "</td>";
            //            HTMlPoly = HTMlPoly + "<td>";
            //            try {

            //                //                HTMlPoly = HTMlPoly + "تعداد کر: <b>" + ObjAllRoutInfo.NumberCore + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlPoly = HTMlPoly + "</td>";
            //            HTMlPoly = HTMlPoly + "</tr>";


            HTMlPoly = HTMlPoly + "<tr>";
            HTMlPoly = HTMlPoly + "<td>";
            try {

                if (ObjAllRoutInfo.RouteStartDate == null || ObjAllRoutInfo.RouteStartDate == '' || ObjAllRoutInfo.RouteStartDate == 'NULL') {
                    HTMlPoly = HTMlPoly + "تاریخ شروع : <b> - </b>";
                }
                else {
                    HTMlPoly = HTMlPoly + "تاریخ شروع : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.RouteStartDate) + "</b>";
                }
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "<td>";
            try {
                if (ObjAllRoutInfo.RouteFinishDate == null || ObjAllRoutInfo.RouteFinishDate == '' || ObjAllRoutInfo.RouteFinishDate == 'NULL') {
                    HTMlPoly = HTMlPoly + "تاریخ پایان : <b> - </b>";
                }
                else {
                    HTMlPoly = HTMlPoly + "تاریخ پایان : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.RouteFinishDate) + "</b>";
                }
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "</tr>";
            HTMlPoly = HTMlPoly + "<tr>";
            HTMlPoly = HTMlPoly + "<td>";
            try {

                if (ObjAllRoutInfo.RouteBaselineStartDate == null || ObjAllRoutInfo.RouteBaselineStartDate == '' || ObjAllRoutInfo.RouteBaselineStartDate == 'NULL') {
                    HTMlPoly = HTMlPoly + "تاریخ شروع برنامه ای : <b> - </b>";
                }
                else {
                    HTMlPoly = HTMlPoly + "تاریخ شروع برنامه ای : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.RouteBaselineStartDate) + "</b>";
                }
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "<td>";
            try {
                if (ObjAllRoutInfo.RouteBaselineFinishDate == null || ObjAllRoutInfo.RouteFinishDate == '' || ObjAllRoutInfo.RouteBaselineFinishDate == 'NULL') {
                    HTMlPoly = HTMlPoly + "تاریخ پایان برنامه ای : <b> - </b>";
                }
                else {
                    HTMlPoly = HTMlPoly + "تاریخ پایان برنامه ای : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.RouteBaselineFinishDate) + "</b>";
                }
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "</tr>";
            HTMlPoly = HTMlPoly + "<tr>";
            HTMlPoly = HTMlPoly + "<td>";
            try {

                if (ObjAllRoutInfo.RouteActualStartDate == null || ObjAllRoutInfo.RouteActualStartDate == '' || ObjAllRoutInfo.RouteActualStartDate == 'NULL') {
                    HTMlPoly = HTMlPoly + "تاریخ شروع واقعی : <b> - </b>";
                }
                else {
                    HTMlPoly = HTMlPoly + "تاریخ شروع واقعی : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.RouteActualStartDate) + "</b>";
                }
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "<td>";
            try {
                if (ObjAllRoutInfo.RouteActualFinishDate == null || ObjAllRoutInfo.RouteActualFinishDate == '' || ObjAllRoutInfo.RouteActualFinishDate == 'NULL') {
                    HTMlPoly = HTMlPoly + "تاریخ پایان واقعی : <b> - </b>";
                }
                else {
                    HTMlPoly = HTMlPoly + "تاریخ پایان واقعی : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.RouteActualFinishDate) + "</b>";
                }
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "</tr>";
            //            HTMlPoly = HTMlPoly + "<tr>";
            //            HTMlPoly = HTMlPoly + "<td>";
            //            try {

            //                HTMlPoly = HTMlPoly + "طول مسیر هوایی: <b>" + ObjAllRoutInfo.PlaneDistanceMap + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlPoly = HTMlPoly + "</td>";
            //            HTMlPoly = HTMlPoly + "<td>";
            //            try {

            //                HTMlPoly = HTMlPoly + "طول مسیر جغرافیایی: <b>" + ObjAllRoutInfo.PlaneDistanceChart + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlPoly = HTMlPoly + "</td>";
            //            HTMlPoly = HTMlPoly + "</tr>";


            //            HTMlPoly = HTMlPoly + "<tr>";
            //            HTMlPoly = HTMlPoly + "<td>";
            //            try {

            //                HTMlPoly = HTMlPoly + "میزان افت کر اول: <b>" + ObjAllRoutInfo.ReduceCore1 + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlPoly = HTMlPoly + "</td>";
            //            HTMlPoly = HTMlPoly + "<td>";
            //            try {

            //                HTMlPoly = HTMlPoly + "میزان افت کر دوم: <b>" + ObjAllRoutInfo.ReduceCore2 + "</b>";
            //            } catch (e) {

            //            }
            //            HTMlPoly = HTMlPoly + "</td>";
            //            HTMlPoly = HTMlPoly + "</tr>";


            HTMlPoly = HTMlPoly + "<tr>";
            HTMlPoly = HTMlPoly + "<td>";
            try {

                HTMlPoly = HTMlPoly + "درصد پیشرفت برنامه ای: <b>" + ObjAllRoutInfo.RoutePlan + "</b>";
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "<td>";
            try {

                HTMlPoly = HTMlPoly + "درصد پیشرفت واقعی: <b>" + ObjAllRoutInfo.RouteActual + "</b>";
            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "</tr>";


            HTMlPoly = HTMlPoly + "<tr>";
            HTMlPoly = HTMlPoly + "<td>";
            try {
                HTMlPoly = HTMlPoly + "درصد تحقق: <b>" + ObjAllRoutInfo.PercentTahaghoghRoute + "</b>";

            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "<td>";
            try {
                HTMlPoly = HTMlPoly + "<a href='/reports/SitePages/SReport_Route.aspx?ProjectUID=" + ObjAllRoutInfo.ProjectUID + "&Route=" + ObjAllRoutInfo.RouteID + "' target='_blank'>نمودار S</a> ";

            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "</tr>";

            HTMlPoly = HTMlPoly + "<tr>";
            HTMlPoly = HTMlPoly + "<td>";
            try {
                HTMlPoly = HTMlPoly + "<a href='/reports/SitePages/CashFlow_Route.aspx?ProjectUID=" + ObjAllRoutInfo.ProjectUID + "&Route=" + ObjAllRoutInfo.RouteID + "' target='_blank'>جریان نقدینگی</a> ";

            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "<td>";
            try {
                HTMlPoly = HTMlPoly + "<a href='/reports/SitePages/TaskDetails_Route.aspx?ProjectUID=" + ObjAllRoutInfo.ProjectUID + "&Route=" + ObjAllRoutInfo.RouteID + "' target='_blank'>فعالیت مسیر</a> ";

            } catch (e) {

            }
            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "</tr>";
            HTMlPoly = HTMlPoly + "</tr>";
            HTMlPoly = HTMlPoly + "</table>";


            //-------------------------

            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "<td>";

            HTMlPoly = HTMlPoly + ExtendTableForPopUp;


            HTMlPoly = HTMlPoly + "</td>";
            HTMlPoly = HTMlPoly + "</tr>";

            HTMlPoly = HTMlPoly + "</table>";

            HTMlPoly = HTMlPoly + "</div>";


            points.splice(0, 0, new GLatLng(LatFrom, LongFrom));
            points.push(new GLatLng(LatTo, LongTo));

            var myPinIcon = new GIcon();
            myPinIcon.image = '/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Marker/Pin.png';
            myPinIcon.iconSize = new GSize(16, 20);
            myPinIcon.shadowSize = new GSize(16, 20);
            myPinIcon.iconAnchor = new GPoint(5, 5);
            myPinIcon.infoWindowAnchor = new GPoint(5, 1);



            var objmarker_StationFrom = new GMarker(new GLatLng(LatFrom, LongFrom), { icon: myPinIcon, title: StationFrom_Title });
            map.addOverlay(objmarker_StationFrom);
            var ew_objmarker_StationFrom = new EWindow(map, E_STYLE_0);
            map.addOverlay(ew_objmarker_StationFrom);

            var objmarker_StationTo = new GMarker(new GLatLng(LatTo, LongTo), { icon: myPinIcon, title: StationTo_Title });
            map.addOverlay(objmarker_StationTo);
            var ew_objmarker_StationTo = new EWindow(map, E_STYLE_0);
            map.addOverlay(ew_objmarker_StationTo);


            var poly = new GPolyline(points, BaseColor, 5, 1);
            poly.objmarker_StationFrom = objmarker_StationFrom;
            poly.objmarker_StationTo = objmarker_StationTo;

            gpolys.push(poly);


            var poly_num = gpolys.length - 1;
            if (HTMlPoly) {
                GEvent.addListener(poly, 'click', function (point) {
                    if (!point) {
                        point = poly.getVertex(Math.floor(poly.getVertexCount() / 2));
                    }
                    map.openInfoWindowHtml(point, HTMlPoly);
                    map.panTo(point);
                    map.setCenter(point);
                    ew_objmarker_StationFrom.openOnMarker(objmarker_StationFrom, StationFrom_Title);
                    ew_objmarker_StationTo.openOnMarker(objmarker_StationTo, StationTo_Title);
                });

                GEvent.addListener(map, "click", function (overlay, point) {
                    if (!overlay) {

                        ew_objmarker_StationFrom.hide();
                        ew_objmarker_StationTo.hide();
                    }
                });

            }

            if (!label) {
                label = "polyline #" + poly_num;
            }
            divSearchResult_html += gisResultItem('route', 'poly', poly_num, 'togglePoly', BaseColor, 'gpolys', label);

            if (poly && poly.getBounds && poly.getBounds()) {
                if (debug) { GLog.write(poly.getBounds() + ":" + poly.getBounds().getNorthEast() + ":" + poly.getBounds().getSouthWest()) }
                bounds.extend(poly.getBounds().getNorthEast());
                bounds.extend(poly.getBounds().getSouthWest());
            }
            map.addOverlay(poly);
        }
        else {
            //فقط به نقطه شروع نگاه می کنیم
            //ExtendTableForPopUp = GetExtendTableForPopUp(ObjAllRoutInfo, false);
            if (LatFrom == 0 || LongFrom == 0) {
                return;
            }
            var objmarker_StationFrom = new GMarker(new GLatLng(LatFrom, LongFrom), { icon: myIcon, title: StationFrom_Title });
            //objmarker_StationFrom.poly_ID = ID;
            gmarkers.push(objmarker_StationFrom);
            GEvent.addListener(objmarker_StationFrom, "click", function () {

                var HTMl = "";
                HTMl = HTMl + "<div class='gis-iw'>";

                HTMl = HTMl + "<table cellpadding ='5' >";

                HTMl = HTMl + "<tr>";
                HTMl = HTMl + "<td>";


                //-------------------------

                HTMl = HTMl + "<table cellpadding ='5' >";

                HTMl = HTMl + "<tr>";
                HTMl = HTMl + "<td>";
                try {

                    HTMl = HTMl + "نام ایستگاه : <b>" + StationFrom_Title + "</b>";
                } catch (e) {

                }
                HTMl = HTMl + "</td>";
                HTMl = HTMl + "<td>";
                try {

                    HTMl = HTMl + "مالکیت: <b>" + ObjAllRoutInfo.StationFrom_OwnerShip + "</b>";
                } catch (e) {

                }
                HTMl = HTMl + "</td>";
                HTMl = HTMl + "</tr>";
                HTMl = HTMl + "<tr>";
                HTMl = HTMl + "<td>";
                try {

                    HTMl = HTMl + "درصد پیشرفت برنامه ای: <b>" + ObjAllRoutInfo.StationFrom_PlanPercent + "</b>";
                } catch (e) {

                }
                HTMl = HTMl + "</td>";
                HTMl = HTMl + "<td>";
                try {

                    HTMl = HTMl + "درصد پیشرفت واقعی: <b>" + ObjAllRoutInfo.StationFrom_ActualPercent + "</b>";
                } catch (e) {

                }
                HTMl = HTMl + "</td>";
                HTMl = HTMl + "</tr>";

                HTMl = HTMl + "<tr>";
                HTMl = HTMl + "<td>";

                try {

                    if (ObjAllRoutInfo.StationFrom_StartDate == null || ObjAllRoutInfo.StationFrom_StartDate == '' || ObjAllRoutInfo.StationFrom_StartDate == 'NULL') {
                        HTMl = HTMl + "تاریخ شروع : <b> - </b>";
                    }
                    else {
                        HTMl = HTMl + "تاریخ شروع : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.StationFrom_StartDate) + "</b>";
                    }
                } catch (e) {

                }

                HTMl = HTMl + "</td>";
                HTMl = HTMl + "<td>";
                try {

                    if (ObjAllRoutInfo.StationFrom_FinishDate == null || ObjAllRoutInfo.StationFrom_FinishDate == '' || ObjAllRoutInfo.StationFrom_FinishDate == 'NULL') {
                        HTMl = HTMl + "تاریخ پایان : <b> - </b>";
                    }
                    else {
                        HTMl = HTMl + "تاریخ پایان : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.StationFrom_FinishDate) + "</b>";
                    }
                } catch (e) {

                }

                HTMl = HTMl + "</td>";
                HTMl = HTMl + "</tr>";
                HTMl = HTMl + "<tr>";
                HTMl = HTMl + "<td>";

                try {

                    if (ObjAllRoutInfo.StationFrom_BaselineStartDate == null || ObjAllRoutInfo.StationFrom_BaselineStartDate == '' || ObjAllRoutInfo.StationFrom_BaselineStartDate == 'NULL') {
                        HTMl = HTMl + "تاریخ شروع برنامه ای : <b> - </b>";
                    }
                    else {
                        HTMl = HTMl + "تاریخ شروع برنامه ای : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.StationFrom_BaselineStartDate) + "</b>";
                    }
                } catch (e) {

                }

                HTMl = HTMl + "</td>";
                HTMl = HTMl + "<td>";
                try {

                    if (ObjAllRoutInfo.StationFrom_BaselineFinishDate == null || ObjAllRoutInfo.StationFrom_BaselineFinishDate == '' || ObjAllRoutInfo.StationFrom_BaselineFinishDate == 'NULL') {
                        HTMl = HTMl + "تاریخ پایان برنامه ای : <b> - </b>";
                    }
                    else {
                        HTMl = HTMl + "تاریخ پایان برنامه ای : <b>" + ConvertGDateObjToJ(ObjAllRoutInfo.StationFrom_BaselineFinishDate) + "</b>";
                    }
                } catch (e) {

                }

                HTMl = HTMl + "</td>";
                HTMl = HTMl + "</tr>";

                HTMl = HTMl + "<tr>";
                HTMl = HTMl + "<td>";
                try {

                    HTMl = HTMl + "مدت زمان: <b>" + ObjAllRoutInfo.StationFrom_Duration + "</b>";
                } catch (e) {

                }
                HTMl = HTMl + "</td>";
                HTMl = HTMl + "<td>";
                try {

                    HTMl = HTMl + "انحراف مدت زمان: <b>" + ObjAllRoutInfo.StationFrom_DurationVariance + "</b>";
                } catch (e) {

                }
                HTMl = HTMl + "</td>";
                HTMl = HTMl + "</tr>";



                HTMl = HTMl + "<tr>";
                HTMl = HTMl + "<td>";
                try {

                    HTMl = HTMl + "انحراف هزینه: <b>" + ObjAllRoutInfo.StationFrom_CostVariance + "</b>";
                } catch (e) {

                }
                HTMl = HTMl + "</td>";
                HTMl = HTMl + "<td>";
                try {

                    HTMl = HTMl + "درصد تحقق: <b>" + ObjAllRoutInfo.StationFrom_PercentTahaghogh + "</b>";
                } catch (e) {

                }
                HTMl = HTMl + "</td>";
                HTMl = HTMl + "</tr>";

                HTMl = HTMl + "<tr>";
                HTMl = HTMl + "<td>";
                try {

                    HTMl = HTMl + "<a href='/reports/SitePages/SReport_Station.aspx?ProjectUID=" + ObjAllRoutInfo.ProjectUID + "&Station=" + ObjAllRoutInfo.StationID + "' target='_blank'>نمودار S</a> ";
                } catch (e) {

                }
                HTMl = HTMl + "</td>";
                HTMl = HTMl + "<td>";
                try {

                    HTMl = HTMl + "<a href='/reports/SitePages/CashFlow_Station.aspx?ProjectUID=" + ObjAllRoutInfo.ProjectUID + "&Station=" + ObjAllRoutInfo.StationID + "' target='_blank'>جریان نقدینگی</a> ";
                } catch (e) {

                }
                HTMl = HTMl + "</td>";
                HTMl = HTMl + "</tr>";
                HTMl = HTMl + "<tr>";
                HTMl = HTMl + "<td>";
                try {

                    HTMl = HTMl + "<a href='/reports/SitePages/TaskDetails_Station.aspx?ProjectUID=" + ObjAllRoutInfo.ProjectUID + "&Stations=" + ObjAllRoutInfo.StationID + "' target='_blank'>فعالیت ایستگاه</a> ";
                } catch (e) {

                }
                HTMl = HTMl + "</td>";
                HTMl = HTMl + "</tr>";
                HTMl = HTMl + "</table>";

                //------------------------------


                HTMl = HTMl + "</td>";
                HTMl = HTMl + "<td>";

                HTMl = HTMl + ExtendTableForPopUp;


                HTMl = HTMl + "</td>";
                HTMl = HTMl + "</tr>";

                HTMl = HTMl + "</table>";

                HTMl = HTMl + "</div>";

                objmarker_StationFrom.openInfoWindowHtml(HTMl);
            });
            bounds.extend(objmarker_StationFrom.getPoint());
            map.addOverlay(objmarker_StationFrom);

            var marker_num = gmarkers.length - 1;
            divSearchResult_html += gisResultItem('station', 'marker', marker_num, 'togglemarker', BaseColor, 'gmarkers', StationFrom_Title);

        }
    }

    function createMarker(point, html, estyle) {
        var marker = new GMarker(point);
        // ========== Open a *new* EWindow instead of a Google Info Window ==========
        var ew = new EWindow(map, estyle);
        map.addOverlay(ew);
        ew.openOnMarker(marker, html);
        return marker;
    }


    function ButtonSearchClicked() {

        if (bVaziyatSelect == false) {

            alert("جهت جستجو انتخاب نام پروژه الزامی است");
            HidePanelSearchAndReports();

            return;
        }

        document.getElementById('divSearchOptions').style.display = 'block';
        document.getElementById('map_SearchArrow').src = '/_layouts/15/images/Sazmanyar.GIS/GoogleMap/right-arrow.png';
        document.getElementById('map_SearchArrow').title = 'بستن فرم جستجو';
        document.getElementById('PanelSearchResult').style.visibility = 'visible';


        document.getElementById('divReportsOptions').style.display = 'none';
        document.getElementById('map_ReportsArrow').src = '/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Reports.jpg';
        document.getElementById('map_ReportsArrow').title = 'نمایش فرم گزارشات';

        RefereshAllRoutInMap();

    }

    function togglePanelSearch() {

        if (document.getElementById('divSearchOptions') == null) { return; }


        if (bVaziyatSelect == false) {
            alert("جهت جستجو انتخاب نام پروژه الزامی است");

            HidePanelSearchAndReports();

            return;
        }

        var NameProjeh = X('.NameProjeh').val();
        if (document.getElementById('divSearchOptions').style.display == 'none') {

            document.getElementById('divSearchOptions').style.display = 'block';
            document.getElementById('map_SearchArrow').src = '/_layouts/15/images/Sazmanyar.GIS/GoogleMap/right-arrow.png';
            document.getElementById('map_SearchArrow').title = 'بستن فرم جستجو';

            document.getElementById('divReportsOptions').style.display = 'none';
            document.getElementById('map_ReportsArrow').src = '/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Reports.jpg';
            document.getElementById('map_ReportsArrow').title = 'نمایش فرم گزارشات';

            gisResizeMap();

        }
        else {
            document.getElementById('divSearchOptions').style.display = 'none';
            document.getElementById('map_SearchArrow').src = '/_layouts/15/images/Sazmanyar.GIS/GoogleMap/left-arrow.png';
            document.getElementById('map_SearchArrow').title = 'نمایش فرم جستجو';

            gisResizeMap();
        }

        if ((typeof map != 'undefined') && (map != null)) {
            map.checkResize();
            map.centerAndZoomOnBounds(bounds);
        }

    }


    function togglePanelReports() {
        if (document.getElementById('divReportsOptions') == null) { return; }

        if (bVaziyatSelect == false) {
            alert("جهت گزارش انتخاب نام پروژه الزامی است");

            HidePanelSearchAndReports();

            return;
        }

        if (document.getElementById('divReportsOptions').style.display == 'none') {
            RefereshReportsLinks();
            document.getElementById('divReportsOptions').style.display = 'block';
            document.getElementById('map_ReportsArrow').src = '/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Reports.jpg';
            document.getElementById('map_ReportsArrow').title = 'بستن فرم گزارشات';

            document.getElementById('divSearchOptions').style.display = 'none';
            document.getElementById('map_SearchArrow').src = '/_layouts/15/images/Sazmanyar.GIS/GoogleMap/left-arrow.png';
            document.getElementById('map_SearchArrow').title = 'نمایش فرم جستجو';

            gisResizeMap();

        }
        else {
            document.getElementById('divReportsOptions').style.display = 'none';
            document.getElementById('map_ReportsArrow').src = '/_layouts/15/images/Sazmanyar.GIS/GoogleMap/Reports.jpg';
            document.getElementById('map_ReportsArrow').title = 'نمایش فرم گزارشات';

            gisResizeMap();

        }

        if ((typeof map != 'undefined') && (map != null)) {
            map.checkResize();
            map.centerAndZoomOnBounds(bounds);
        }

    }
    var MyLocationMarker;
    function CheckBoxOrderByLocationClick() {
        if (document.getElementById('chbMainContentOrderByLocation').checked) {
            addMyLocationMarker();
            document.getElementById('btnSearch').title = 'جستجو بر اساس نزدیکی به موقعیت آدمک';
        }
        else {
            ClearMyLocationMarker();
            document.getElementById('btnSearch').title = 'جستجو بر اساس نزدیکی به مرکز نقشه';
        }
    }
    function addMyLocationMarker() {
        if (map != null) {
            if ((typeof MyLocationMarker == 'undefined') || (MyLocationMarker == null)) {
                var myIcon = new GIcon();
                myIcon.image = '/_layouts/15/images/Sazmanyar.GoogleMapOffline/Marker/iconMe.png';
                myIcon.iconAnchor = new GPoint(1, 1);
                var point = new GLatLng(map.getCenter().lat(), map.getCenter().lng());
                MyLocationMarker = new GMarker(point, { draggable: true, title: 'موقعیت من', icon: myIcon });
                map.addOverlay(MyLocationMarker);
            }
        }
    }

    function DoToggleelectSearchResult() {
        var checkBoxes = X(".checkboxSearchResult");
        checkBoxes.prop("checked", !checkBoxes.prop("checked"));
    }

    function SetMyLocationMarkerInCenter() {
        if (typeof MyLocationMarker == 'undefined') { return false; }
        if (MyLocationMarker != null) { MyLocationMarker.setLatLng(map.getCenter()); }
    }

    function ClearMyLocationMarker() {
        if (MyLocationMarker == null) { return; }
        map.removeOverlay(MyLocationMarker);;
        MyLocationMarker = null;
    }
    function rad(x) { return x * Math.PI / 180; }
    function find_closest_marker() {
        //                                    if (mapPoints == null) { return null; }  
        //                                    if (mapPoints.bindings == null) { return null;  }  
        //                                    var mapPoints_bindings = []  ;
        //                                    for (var counter = 0; counter < mapPoints.bindings.length; counter++) {
        //                                        mapPoints_bindings.push(mapPoints.bindings[counter]);
        //                                    }

        //                                    var SortedPointsmarkers = [];
        //                               
        //                                    var lat = -1;
        //                                    var lng = -1;

        //                                    if ((typeof map != 'undefined') && (map != null)) {
        //                                                        lat = map.getCenter().lat();
        //                                                        lng = map.getCenter().lng();
        //                                    }

        //                                    if (document.getElementById('chbMainContentOrderByLocation').checked) {
        //                                        if (typeof MyLocationMarker != 'undefined') {
        //                                            lat = MyLocationMarker.getLatLng().lat();
        //                                            lng = MyLocationMarker.getLatLng().lng();
        //                                        }
        //                                    }
        //            
        //                                    var R = 6371; // radius of earth in km
        //                             
        //                                    while  (mapPoints_bindings.length > 0)
        //                                    {
        //                                        var closest = -1;
        //                                        var distances = [];
        //                                        for (var i = 0; i < mapPoints_bindings.length; i++) {
        //                                            var mlat = mapPoints_bindings[i]." + LatField + @"; 
        //                                            var mlng = mapPoints_bindings[i]." + LongField + @";
        //                                            var dLat  = rad(mlat - lat);
        //                                            var dLong = rad(mlng - lng);
        //                                            var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
        //                                                Math.cos(rad(lat)) * Math.cos(rad(lat)) * Math.sin(dLong/2) * Math.sin(dLong/2);
        //                                            var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        //                                            var d = R * c;
        //                                            distances[i] = d;
        //                                            if ( closest == -1 || d < distances[closest] ) {
        //                                                closest = i;
        //                                            }
        //                                        } 
        //                                    
        //                                        SortedPointsmarkers.push(mapPoints_bindings[closest]);                            
        //                                        removeByIndex(mapPoints_bindings, closest);
        //                                  }
        //                                return  SortedPointsmarkers;                      
    }

    function removeByIndex(arr, index) {
        arr.splice(index, 1);
    }

    function FillDivSearchResult(SortedPointsmarkers) {
        //                                    document.getElementById('divSearchResult').innerHTML ='';           
        //                                    if (SortedPointsmarkers == null) 
        //                                    { 
        //                                        document.getElementById('divSearchResult').innerHTML = '<p style=\'color:blue\' >هیچ موردی جهت نمایش در لیست یافت نشد </p>';
        //                                        return; 
        //                                    }  

        //                                    if (SortedPointsmarkers.length == 0) 
        //                                    { 
        //                                        document.getElementById('divSearchResult').innerHTML = '<p style=\'color:blue\'>هیچ موردی جهت نمایش در لیست یافت نشد </p>';
        //                                        return; 
        //                                    }  

        //                                    var HTML = '' ;
        //                                    var cnt = 0 ;
        //            
        //                                    HTML += '<p style=\'color:blue\' >تعداد موارد یافت شده '  + SortedPointsmarkers.length + ' عدد می باشد';

        //                                    var MaxSearchResult  =  " + MaxSearchResult + @";
        //                                    if(MaxSearchResult== 0)
        //                                    {
        //                                        MaxSearchResult = SortedPointsmarkers.length;
        //                                    }
        //                                    else if(MaxSearchResult < SortedPointsmarkers.length)
        //                                    {
        //                                        HTML += 'که '  + MaxSearchResult + ' مورد از آنها در لیست زیر نشان داده شده است';
        //                                    }
        //                                    HTML += '</p>';
        //         
        //          
        //                                    for (var r = 0; r < MaxSearchResult ; r++) {

        //                                            if(r > SortedPointsmarkers.length-1) { break; }
        //                                            var BusinessID = SortedPointsmarkers[r].ID;
        //                                            var strInternalNameResult1 = SortedPointsmarkers[r]." + TitleField + @" ;;
        //                                            if ('" + strInternalNameResult1 + @"' != '_____Null_____') 
        //                                            {
        //                                               strInternalNameResult1 = SortedPointsmarkers[r]." + strInternalNameResult1 + @" ;
        //                                            }
        //                    
        //                                            var strInternalNameResult2 ='';
        //                                            if ('" + strInternalNameResult2 + @"' != '_____Null_____') 
        //                                            {
        //                                                strInternalNameResult2 = SortedPointsmarkers[r]." + strInternalNameResult2 + @" ;
        //                                            }
        //             
        //                                            var Latitude = SortedPointsmarkers[r]." + LatField + @";
        //                                            var Longitude = SortedPointsmarkers[r]." + LongField + @";
        //                                            var IconFileName = '" + CurrentWeb.Url + "/_layouts/15/images/Sazmanyar.GoogleMapOffline/Marker/' + SortedPointsmarkers[r]." + StateField + @"  +  '/marker.png';
        //          
        //                                        if (cnt > 0) {
        //                                            HTML += '<br/>';
        //                                        }

        //                                        HTML += '<table>';
        //                                        HTML += '<tr>';
        //                                        HTML += '<td style='vertical-align:top'>';
        //                                        if (parseFloat(Latitude) < 0 || parseFloat(Longitude) < 0) {
        //                                            HTML += ' <img src='img/Markers/disabledMarker.gif' title='موقعیت هنوز مشخص نشده است' />';
        //                                        }
        //                                        else {
        //                                            HTML += ' <img style='cursor:pointer' src='' + IconFileName + '' title='نمایش موقعیت بر روی نقشه' onclick='javascript:ShowLocation(' +  BusinessID +  ' ,' + Latitude + ',' + Longitude + ')' />';
        //                                        }
        //                                        HTML += '</td>';
        //                                        HTML += '<td>';

        //                                        HTML += '<strong style='Color:gray;margin-right:5px' >' + ( r + 1) + '-' + '</strong>' + ' <a  class='Link' href='#' onclick='javascript:ShowDetailInfo(' +  BusinessID +  ' )'> ' + '<strong>' + strInternalNameResult1 + '</strong> </a> ';

        //                                        HTML += '<br/>';
        //                                        if (strInternalNameResult2 != '') {
        //                                            if (strInternalNameResult2.length > 65) {
        //                                                strInternalNameResult2 = strInternalNameResult2.substring(0, 65);
        //                                                strInternalNameResult2 += ' ... ';
        //                                            }
        //                                            HTML += strInternalNameResult2;
        //                                        }
        //                                        HTML += '</td>';
        //                                        HTML += '</tr>';
        //                                        HTML += '</table>';
        //                                        cnt++;

        //                                        }
        //                                        document.getElementById('divSearchResult').innerHTML = HTML;
    }


    //Fits the Map to Polygon bounds
    function fitPolygon(Polygon) {
        bounds = Polygon.getBounds();
        map.setCenter(bounds.getCenter(), map.getBoundsZoomLevel(bounds));
    }

</script>
<div class="gis-root">
<input id="MyLocationMarkerHidden" type="hidden" runat="server" />
<table style="width: 100%">
    <tr>
        <td>
            <table style="width: 100%" cellpadding="5" cellspacing="5">
                <tr>
                    <td>
                        <div class="gis-topbar">
                            <div class="gis-fields">
                                <%-- اسکریپت‌های قدیمی روی این دو دکمه .src و .title می‌نویسند؛ src روی button بی‌اثر است و
                                     حالت باز/بسته از روی title (که با «بستن» شروع می‌شود) در CSS تشخیص داده می‌شود. --%>
                                <div class="gis-toggles">
                                    <button type="button" class="gis-toggle gis-fs-btn" onclick="gisToggleFullscreen(this);" title="نمایش تمام‌صفحه">
                                        <svg class="gis-fs-enter" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 9V4h5M20 9V4h-5M4 15v5h5M20 15v5h-5" /></svg><svg class="gis-fs-exit" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 4v5H4M15 4v5h5M9 20v-5H4M15 20v-5h5" /></svg>
                                        <span class="gis-fs-enter">تمام‌صفحه</span><span class="gis-fs-exit">خروج از تمام‌صفحه</span>
                                    </button>
                                    <button type="button" id="map_SearchArrow" class="gis-toggle" onclick="togglePanelSearch();" title="نمایش فرم جستجو">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="16" rx="2" /><path d="M15 4v16" /><path d="M6 9h5M6 13h5" /></svg>
                                        <span>پنل جستجو</span>
                                    </button>
                                    <button type="button" id="map_ReportsArrow" class="gis-toggle" style="display: none;" onclick="togglePanelReports();" title="نمایش فرم گزارشات">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 3h9l5 5v13H6z" /><path d="M14 3v6h6" /><path d="M9 14h6M9 17h6" /></svg>
                                        <span>گزارش‌ها</span>
                                    </button>
                                </div>
                                <div class="gis-field">
                                    <span class="gis-field-label">نام قرارداد:</span>
                                    <span id="gisProjectWrap" class="gis-input-wrap">
                                        <input id="txtProgramName" class="NameProjeh gis-input" runat="server" type="text" placeholder="برای انتخاب کلیک کنید یا بنویسید" />
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
                                <div class="gis-opacity" title="شفافیت داخل سطح‌ها (چندضلعی‌ها) روی نقشه">
                                    <span class="gis-field-label">شفافیت سطح‌ها:</span>
                                    <input type="range" id="gisAreaOpacity" min="5" max="100" step="5" value="35" oninput="gisApplyAreaOpacity(this.value);" onchange="gisApplyAreaOpacity(this.value);" />
                                    <span id="gisAreaOpacityValue" class="gis-opacity-value" title="تا وقتی اسلایدر را حرکت نداده‌اید، شفافیت هر سطح از دادهٔ خودش می‌آید">خودکار</span>
                                </div>
                                <div class="gis-legend" title="درصد تحقق مسیر">
                                    <span class="gis-legend-title">تحقق:</span>
                                    <span class="gis-legend-item"><i style="background: #22c55e"></i>بیش از ۹۰٪</span>
                                    <span class="gis-legend-item"><i style="background: #facc15"></i>۷۰ تا ۹۰٪</span>
                                    <span class="gis-legend-item"><i style="background: #f472b6"></i>۵۰ تا ۷۰٪</span>
                                    <span class="gis-legend-item"><i style="background: #ef4444"></i>کمتر از ۵۰٪</span>
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
                                        <div class="gis-toolbar">
                                            <button type="button" class="gis-tool" id="btnShowSearchOptionIstgah" onclick="ShowSearchOptionIstgah();" title="تنظیمات جستجوی ایستگاه">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 21s7-6.2 7-11a7 7 0 1 0-14 0c0 4.8 7 11 7 11z" /><circle cx="12" cy="10" r="2.5" /></svg>
                                            </button>
                                            <button type="button" class="gis-tool" id="btnShowSearchOptionMaseer" onclick="ShowSearchOptionMaseer();" title="تنظیمات جستجوی مسیر">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="5" cy="18" r="2" /><circle cx="19" cy="6" r="2" /><path d="M7 17.5c4 0 4-11 8-11h2" /></svg>
                                            </button>
                                            <button type="button" class="gis-tool" id="btnShowSearchOptionSath" onclick="ShowSearchOptionSath();" title="تنظیمات جستجوی سطح">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 8l7-4 9 5-3 10-10-1z" /></svg>
                                            </button>
                                            <button type="button" class="gis-tool gis-tool-danger" id="btnDelSearchOption" onclick="DeLSearchOption();" title="حذف تنظیمات جستجو">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18M8 6V4h8v2M6 6l1 14h10l1-14" /><path d="M10 10v7M14 10v7" /></svg>
                                            </button>
                                        </div>
                                    </div>
                                    <div id="divSearchResult" class="gis-list"></div>
                                </div>
                            </div>
                            <div id="divReportsOptions" class="gis-panel gis-reports" style="display: none;">
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

    X("#various").fancybox({
        'width': '85%',
        'height': '65%',
        'autoScale': false,
        'transitionIn': 'none',
        'transitionOut': 'none',
        'type': 'iframe'
    });


    function ShowSearchOptionIstgah() {
        X.fancybox({
            'width': 960,
            'height': 560,
            'padding': 0,
            'autoScale': false,
            'transitionIn': 'none',
            'transitionOut': 'none',
            'type': 'iframe',
            'href': '/_layouts/15/Sazmanyar.GIS/FilterInstgah.html?nc=' + new Date().getTime()
        });

    }


    function ShowSearchOptionMaseer() {
        X.fancybox({
            'width': 960,
            'height': 560,
            'padding': 0,
            'autoScale': false,
            'transitionIn': 'none',
            'transitionOut': 'none',
            'type': 'iframe',
            'href': '/_layouts/15/Sazmanyar.GIS/FilterMaseer.html?nc=' + new Date().getTime()
        });

    }

    function ShowSearchOptionSath() {
        X.fancybox({
            'width': 960,
            'height': 560,
            'padding': 0,
            'autoScale': false,
            'transitionIn': 'none',
            'transitionOut': 'none',
            'type': 'iframe',
            'href': '/_layouts/15/Sazmanyar.GIS/FilterSath.html?nc=' + new Date().getTime()
        });

    }

    function DeLSearchOption() {
        gisClearSearchDescriptions();
        SearchOption_Istgah = null;
        SearchOption_Maseer = null;
        SearchOption_Sath = null;
        RefereshAllRoutInMap();
    }

    GMap.prototype.centerAndZoomOnBounds = function (bounds) {
        if (debug) GLog.write("centerAndZoomOnBounds()");
        var center_lat = (bounds.getNorthEast().lat() + bounds.getSouthWest().lat()) / 2.0;
        var center_lng = (bounds.getNorthEast().lng() + bounds.getSouthWest().lng()) / 2.0;
        var center = new GLatLng(center_lat, center_lng)
        map.setCenter(center, map.getBoundsZoomLevel(bounds));
    }

    if (GBrowserIsCompatible()) {
        // this variable will collect the html which will eventualkly be placed in the divSearchResult
        var divSearchResult_html = "";

        // arrays to hold copies of the markers and html used by the divSearchResult
        // because the function closure trick doesnt work there
        var gmarkers = [];
        var gpolys = [];
        var ggans = [];

        // global variables
        var map;
        var request;
        var geonamesUrl;
        var earthtoolsUrl;
        var addFile = false;
        var debug = false;
        var loadtime = false;

        function zoomIN(i) {
            map.setCenter(gmarkers[i].getPoint(), 16);
        }

        //Zoom-Out Function 
        function zoomOUT(i) {
            // map.closeInfoWindow();
            // map.centerAndZoom(gmarkers[i].point, 4);
            map.centerAndZoomOnBounds(bounds);
        }

        // Create our "tiny" marker icon
        var icons = new Array();
        icons["red"] = new GIcon();
        icons["red"].image = "/_layouts/15/images/Sazmanyar.GIS/GoogleMap/mm_20_red.png";
        icons["red"].shadow = "/_layouts/15/images/Sazmanyar.GIS/GoogleMap/mm_20_shadow.png";
        icons["red"].iconSize = new GSize(12, 20);
        icons["red"].shadowSize = new GSize(22, 20);
        icons["red"].iconAnchor = new GPoint(6, 20);
        icons["red"].infoWindowAnchor = new GPoint(5, 1);
        icons["red"].imageMap = [4, 0, 0, 4, 0, 7, 3, 11, 4, 19, 7, 19, 8, 11, 11, 7, 11, 4, 7, 0];
        icons["red"].transparent = "mapIcons/mm_20_transparent.png";

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

        function togglePoly(poly_num) {
            if (document.getElementById('poly' + poly_num)) {
                if (document.getElementById('poly' + poly_num).checked) {
                    gpolys[poly_num].show();
                    gpolys[poly_num].objmarker_StationFrom.show();
                    gpolys[poly_num].objmarker_StationTo.show();

                } else {
                    gpolys[poly_num].hide();
                    gpolys[poly_num].objmarker_StationFrom.hide();
                    gpolys[poly_num].objmarker_StationTo.hide();
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

        function togglemarker(marker_num) {
            if (document.getElementById('marker' + marker_num)) {
                if (document.getElementById('marker' + marker_num).checked) {
                    gmarkers[marker_num].show();
                } else {
                    gmarkers[marker_num].hide();
                }
            }
        }

        function createClickablePolyline(poly, html, label) {
            gpolys.push(poly);
            var poly_num = gpolys.length - 1;
            if (!html) { html = ""; }
            else { html += "<br>"; }
            html += "length=";
            if (poly.getLength() < 1000.0) {
                html += poly.getLength().toFixed(2) + " m; " + (poly.getLength() * 3.2808399).toFixed(2) + " ft; ";
            }
            html += (poly.getLength() * 0.000621371192).toFixed(2) + " miles";
            if (html) {
                GEvent.addListener(poly, 'click', function (point) {
                    if (!point) point = poly.getVertex(Math.floor(poly.getVertexCount() / 2));
                    map.openInfoWindowHtml(point, html);
                });
            }
            if (!label) {
                label = "polyline #" + poly_num;
            }
            label = "<a href='javascript:GEvent.trigger(gpolys[" + poly_num + "],\"click\");'>" + label + "</a>";
            // add a line to the divSearchResult html
            divSearchResult_html += '<input type="checkbox" class="checkboxSearchResult" id="poly' + poly_num + '" checked="checked" onclick="togglePoly(' + poly_num + ');">' + label + '<br />';

        }

        var trafficOverlay = null;
        function addTrafficOverlay() {
            var trafficCheckBox = document.getElementById('traffic');
            if (trafficCheckBox && trafficCheckBox.checked) {
                trafficOverlay = new GTrafficOverlay();
                map.addOverlay(trafficOverlay);
            } else if (trafficOverlay) {
                map.removeOverlay(trafficOverlay);
                trafficOverlay = null;
            }
        }



        var mapCenter, mapZoom;
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
        //map.setCenter(new GLatLng(35.7150676237549, 51.3955078125), 6);
        map.centerAndZoomOnBounds(bounds);
        GEvent.addListener(map, "click", function (overlay, point) {
            if (!overlay) {
                map.closeInfoWindow();
            }
        });

    }

    else {
        alert("Sorry, the Google Maps API is not compatible with this browser");
    }




    // This Javascript is based on code provided by the
    // Blackpool Community Church Javascript Team
    // http://www.commchurch.freeserve.co.uk/
    // http://www.econym.demon.co.uk/googlemaps/

    //]]>
</script>
</div>
