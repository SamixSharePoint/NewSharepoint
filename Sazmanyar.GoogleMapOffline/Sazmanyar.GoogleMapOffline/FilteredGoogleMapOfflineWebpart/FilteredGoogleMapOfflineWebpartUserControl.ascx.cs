using Microsoft.SharePoint;
using Sazmanyar.GoogleMapOffline.Classes;
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

namespace Sazmanyar.GoogleMapOffline.FilteredGoogleMapOfflineWebpart
{
    public partial class FilteredGoogleMapOfflineWebpartUserControl : UserControl
    {
        public Boolean UseNewVersion = false;
        public string BaseWebUrlInfo = "";
        public string ListName = "";
        public string View_name = "";
        public string ListUrlHelper1 = "";
        public string ListUrlHelper2 = "";
        public string ListUrlHelper3 = "";
        public string ListUrlHelper4 = "";
        public string ListUrlHelper5 = "";

        public string TitleField = "";
        public string LatField = "";
        public string LongField = "";
        public string IsCenField = "";
        public string StateField = "";

        public Boolean ShowByAdminPrevilage = false;
        public Boolean enableScrollWheelZoom = false;
        public Boolean navigationControl = false;
        public Boolean scaleControl = false;
        public Boolean draggable = false;
        public Boolean ShowContextMenu = true;

        public string Adress_Of_Image_Location = "";
        public string JSDrowDetailInfoAddressUrl = "";
        public string JSDrowMarkerAddressUrl = "";
        public string ShouldRemovedFromBaseUrl = "";
        public string Filtered_In_QueryString = "";


        public int ZoomLevel = 0;
        public int mininumLevel = 0;
        public int maxinumLevel = 0;
        public Boolean ShowAllMarkerForFirstTime = true;
        public string RelationalColumnForloadInMapPoint = "";

        public string filterd_by_column1 = "";
        public string filterd_by_column2 = "";
        public string filterd_by_column3 = "";
        public string Searched_by_column1 = "";
        public string Searched_by_column2 = "";
        public string Searched_by_column3 = "";
        public string CheckList_by_column1 = "";
        public string CheckList_by_column2 = "";
        public string CheckList_by_column3 = "";

        public string SearchResultField1 = "";
        public string SearchResultField2 = "";

        public Boolean ShowSearchPanel = false;
        public int MaxSearchResult = 0;

        public Boolean IsOuterJoin = true;
        public string SqlQueryViewName = "";
        public string SqlQueryConnectionString = "";
        public string RelationalColumnBetweenListsAndViews = "";

        public int MarkerIcon_X = 20;
        public int MarkerIcon_Y = 10;

        public int MarkerShadowIcon_X = 20;
        public int MarkerShadowIcon_Y = 10;

        public int MarkerAnchorIcon_X = 10;
        public int MarkerAnchorIcon_Y = 5;

        public int InfoWindowAnchor_X = 10;
        public int InfoWindowAnchor_Y = 5;

        private string ModalDialogControlStyle
        {
            get
            {
                // استایل پنجرهٔ جزئیات (msg-modal/msg-content) به فایل مشترک gmo-ui.css منتقل شده است.
                return "<link rel='stylesheet' type='text/css' href='/_layouts/15/Sazmanyar.GoogleMapOffline/Script/css/gmo-ui.css' />";
            }

        }

        private Boolean bHazManipulationPermisionOnList(string ListName)
        {
            try
            {
                if (SPContext.Current.Web.CurrentUser == null)
                {
                    return false;
                }

                Boolean bResult = false;
                SPListCollection lists = null;

                string BaseReletiveWebUrlInfo = "";
                SPWeb CurrentWeb = SPContext.Current.Web;
                String strSiteUrl = SPContext.Current.Web.Site.Url;
                if ((BaseWebUrlInfo != "/") && (BaseWebUrlInfo != ""))
                {
                    try
                    {
                        SPSecurity.RunWithElevatedPrivileges(
                        delegate ()
                        {
                            SPSite TempCurrentSite = null;
                            try
                            {
                                TempCurrentSite = new SPSite(BaseWebUrlInfo);
                            }
                            catch (Exception)
                            {
                                TempCurrentSite = new SPSite(strSiteUrl + BaseWebUrlInfo);
                            }

                            BaseReletiveWebUrlInfo = BaseWebUrlInfo.Replace(TempCurrentSite.Url.ToString(), "");
                            CurrentWeb = TempCurrentSite.OpenWeb(BaseReletiveWebUrlInfo);
                            BaseReletiveWebUrlInfo = CurrentWeb.ServerRelativeUrl;

                        });
                    }
                    catch (Exception)
                    { }

                }
                else
                {
                    BaseReletiveWebUrlInfo = SPContext.Current.Web.ServerRelativeUrl;
                }

                SPSecurity.RunWithElevatedPrivileges(
                                 delegate ()
                                 {
                                     using (SPSite CurrentSite = new SPSite(CurrentWeb.Site.ID))
                                     {
                                         using (SPWeb web = CurrentSite.OpenWeb(CurrentWeb.ID))
                                         {
                                             lists = web.Lists;
                                             foreach (SPList list in lists)
                                             {
                                                 if (list.Title.Trim().ToLowerInvariant() == ListName.Trim().ToLowerInvariant())
                                                 {
                                                     if (list.DoesUserHavePermissions(SPContext.Current.Web.CurrentUser, SPBasePermissions.EditListItems) == true)
                                                     {
                                                         bResult = true;
                                                     }
                                                 }
                                             }

                                         }
                                     }
                                 }
                         );

                return bResult;
            }
            catch (Exception ex)
            {
                return false;
            }

        }

        protected void Page_Load(object sender, EventArgs e)
        {

            if (Page.Header != null)
            {
                Page.Header.Controls.Add(new Literal() { Text = ModalDialogControlStyle });
            }

            string BaseReletiveWebUrlInfo = "";
            SPWeb CurrentWeb = SPContext.Current.Web;
            String strSiteUrl = SPContext.Current.Web.Site.Url;
            if ((BaseWebUrlInfo != "/") && (BaseWebUrlInfo != ""))
            {
                try
                {
                    SPSecurity.RunWithElevatedPrivileges(
                    delegate ()
                    {
                        SPSite TempCurrentSite = null;
                        try
                        {
                            TempCurrentSite = new SPSite(BaseWebUrlInfo);
                        }
                        catch (Exception)
                        {
                            TempCurrentSite = new SPSite(strSiteUrl + BaseWebUrlInfo);
                        }

                        BaseReletiveWebUrlInfo = BaseWebUrlInfo.Replace(TempCurrentSite.Url.ToString(), "");
                        CurrentWeb = TempCurrentSite.OpenWeb(BaseReletiveWebUrlInfo);
                        BaseReletiveWebUrlInfo = CurrentWeb.ServerRelativeUrl;


                    });
                }
                catch (Exception)
                { }

            }
            else
            {
                BaseReletiveWebUrlInfo = SPContext.Current.Web.ServerRelativeUrl;
            }

            string Filterd_In_QueryStringName = "";
            string Filterd_In_QueryStringValue = "";
            if (Filtered_In_QueryString.Trim().Length > 0)
            {
                try
                {
                    Filterd_In_QueryStringValue = Page.Request.QueryString[Filtered_In_QueryString];
                    if (Filterd_In_QueryStringValue != null)
                    {
                        Filterd_In_QueryStringName = Filtered_In_QueryString;
                    }
                    else
                    {
                        Filterd_In_QueryStringValue = "";
                    }
                }
                catch
                {

                }
            }


            LiteralControl googlemap = new LiteralControl();
            try
            {
                //Page.IsCallback

                if (!IsPostBack)
                {
                    RenderingFilterPart(CurrentWeb);
                }

                // string strSeperator = " ";  // Environment.NewLine;
                string strSeperator = Environment.NewLine;

                //string height = (this.Height.ToString() == "") ? "400px" : this.Height.ToString();
                //string width = (this.Width.ToString() == "") ? "100%" : this.Width.ToString();

                if (maxinumLevel == 0)
                {
                    maxinumLevel = 15;
                }
                if (mininumLevel > maxinumLevel)
                {
                    maxinumLevel = mininumLevel;
                }

                if (this.ZoomLevel == 0)
                {
                    if (mininumLevel > 6)
                    {
                        this.ZoomLevel = mininumLevel;
                    }
                    else
                    {
                        this.ZoomLevel = 6;
                    }
                }

                //Attaching Google make URI and API key
                string jsArray = string.Empty;
                string jsCenter = string.Empty;
                GetListItemsAsString(CurrentWeb, ref jsArray, ref jsCenter);

                if (jsCenter == string.Empty)
                {
                    jsCenter = "new GLatLng(36,51)";
                }


                Adress_Of_Image_Location = Adress_Of_Image_Location.Trim();

                if (Adress_Of_Image_Location.Length == 0)
                {
                    Adress_Of_Image_Location = "/_layouts/15/images/Sazmanyar.GoogleMapOffline/Google%20Maps%20Image/";
                }
                else
                {
                    if ((Adress_Of_Image_Location.StartsWith("http:") == false) && (Adress_Of_Image_Location.StartsWith("www.") == false) && (Adress_Of_Image_Location.StartsWith("/") == false))
                    {
                        Adress_Of_Image_Location = "/" + Adress_Of_Image_Location;
                    }
                    if ((Adress_Of_Image_Location.EndsWith("/") == false))
                    {
                        Adress_Of_Image_Location = Adress_Of_Image_Location + "/";
                    }
                }

                if (UseNewVersion == true)
                {
                    googlemap.Text = "<script type='text/javascript'> var myurl = '" + SPContext.Current.Web.Url + "/_layouts/15/Sazmanyar.GoogleMapOffline/Script'; </script>" + strSeperator +
                    "<script src='/_layouts/15/Sazmanyar.GoogleMapOffline/Script/mapfiles/maps_Sazmanyar.js' type='text/javascript'></script>" + strSeperator +
                    "<script type='text/javascript'> GUnload(); </script>";
                }
                else
                {
                    googlemap.Text = "<script src='/_layouts/15/Sazmanyar.GoogleMapOffline/Script/js/Base.js' type='text/javascript' > </script>" + strSeperator +
                    "<script src='/_layouts/15/Sazmanyar.GoogleMapOffline/Script/js/ToolBars.js' type='text/javascript' > </script>" + strSeperator +
                    "<script src='/_layouts/15/Sazmanyar.GoogleMapOffline/Script/js/mod_apiiw.js' type='text/javascript' > </script>" + strSeperator +
                    "<script src='/_layouts/15/Sazmanyar.GoogleMapOffline/Script/js/mod_exdom.js' type='text/javascript' > </script>";
                }


                googlemap.Text = googlemap.Text + "<script src='" + JSDrowMarkerAddressUrl + "' type='text/javascript' > </script>" + strSeperator +
                 "<script src='" + JSDrowDetailInfoAddressUrl + "' type='text/javascript'> </script>" + strSeperator +
                 "<script type='text/javascript'>" + strSeperator +
                 "var map; " + strSeperator +
                 "var mapPoints; " + strSeperator +
                 "var clickedLatLng;" + strSeperator +
                 "var spmodaldlgwindow;" + strSeperator +
                 "var listItem ;" + strSeperator +
                 "var contextMenu ;" + strSeperator +
                 "var Arrayesmarkers = []; " + strSeperator +
                 "var infowindow ;" + strSeperator +
                 //    //<PolyGon
                 //    "var global = this;" + strSeperator +
                 //    "var PolygonMarkers = []; //Array for Map Markers " + strSeperator +
                 //    "var PolygonPoints = []; //Array for Polygon Node Markers " + strSeperator +
                 //    "var bounds = new GLatLngBounds; //Polygon Bounds " + strSeperator +
                 //    "var Polygon; //Polygon overlay object " + strSeperator +
                 //    "var polygon_resizing = false; //To track Polygon Resizing " + strSeperator +

                 //"//Polygon Marker/Node icons " + strSeperator +
                 //    "var redpin = new GIcon(); //Red Pushpin Icon " + strSeperator +
                 //    "redpin.image = 'http://maps.google.com/mapfiles/ms/icons/red-pushpin.png';" + strSeperator +
                 //    "redpin.iconSize = new GSize(32, 32);" + strSeperator +
                 //    "redpin.iconAnchor = new GPoint(10, 32);" + strSeperator +
                 //    "var bluepin = new GIcon(); //Blue Pushpin Icon " + strSeperator +
                 //    "bluepin.image = 'http://maps.google.com/mapfiles/ms/icons/blue-pushpin.png';" + strSeperator +
                 //    "bluepin.iconSize = new GSize(32, 32);" + strSeperator +
                 //    "bluepin.iconAnchor = new GPoint(10, 32);" + strSeperator +
                 //    //PolyGon>
                 "function initializeGMap() " + strSeperator +
                 "{  " + strSeperator +

                                         //"  document.getElementById('divSearchResult').style.height='" + (Convert.ToInt16((height.Replace("px", ""))) - 90).ToString() + "px'; " + strSeperator +
                                         //"  document.getElementById('map_canvas').style.width='" + width + "'; " + strSeperator +
                                         //"  document.getElementById('map_canvas').style.height='" + height + "'; " + strSeperator +
                                         "        " + strSeperator +
                "  if (GBrowserIsCompatible()) " + strSeperator +
                "{ " + strSeperator +
                // ============================================================ 
                // ====== Create a copyright entry ===== 
                "var copyright = new GCopyright(1, new GLatLngBounds(new GLatLng(-90, -180), new GLatLng(90, 180)), 0, 'Sazmanyar'); " + strSeperator +


                // ============================================================ 
                // ====== Create a copyright collection ===== 
                // ====== and add the copyright to it   ===== 
                "var copyrightCollection = new GCopyrightCollection('Map Data:'); " + strSeperator +
                "copyrightCollection.addCopyright(copyright); " + strSeperator +


                // ============================================================ 
                // == Write our own getTileUrl function ========
                // In this case the tiles are names like  8053_5274_3.jpg  
                "CustomGetTileUrl = function (a, b) { " + strSeperator +
                 //converts tile x,y into keyhole string 
                 " return '" + Adress_Of_Image_Location + "' + b + '/' + a.x + '/' + a.y + '.png'; " + strSeperator +
                 // Adress_Of_Image_Location

                 //"  var c = Math.pow(2, b); " + strSeperator +
                 //"  var d = a.x; " + strSeperator +
                 //"  var e = a.y; " + strSeperator +
                 //"  var f = 't'; " + strSeperator +
                 //"  for (var g = 0; g < b; g++) { " + strSeperator +
                 //"      c = c / 2; " + strSeperator +
                 //"      if (e < c) { " + strSeperator +
                 //"          if (d < c) { f += 'q' } " + strSeperator +
                 //"          else { f += 'r'; d -= c } " + strSeperator +
                 //"       } " + strSeperator +
                 //"       else { " + strSeperator +
                 //"           if (d < c) { f += 't'; e -= c } " + strSeperator +
                 //"           else { f += 's'; d -= c; e -= c } " + strSeperator +
                 //"       } " + strSeperator +
                 //"   } " + strSeperator +
                 //"  return 'http://www.Sazmanyar.org/_layouts/mapGIS/Naruto/Iran/' + f + '.png'; " + strSeperator +

                 "}; " + strSeperator +

                // ============================================================ "
                // ===== Create the GTileLayer ===== "
                // ===== adn apply the CustomGetTileUrl to it "
                "var tilelayers = [new GTileLayer(copyrightCollection, " + mininumLevel.ToString() + ", " + maxinumLevel.ToString() + ")]; " + strSeperator +
                "tilelayers[0].getTileUrl = CustomGetTileUrl; " + strSeperator +

                // ============================================================ 
                // ===== Create the GMapType =====
                // ===== and add it to the map ===== 
                "var custommap = new GMapType(tilelayers, new GMercatorProjection(20), \"Sazmanyar\"); " + strSeperator +
                " map = new GMap2(document.getElementById('map_canvas'), { mapTypes: [custommap] }); " + strSeperator +
            "} " + strSeperator +
            "else { " + strSeperator +
            "   return; " + strSeperator +
            "   } " + strSeperator +
            " map.setCenter(" + jsCenter + ", " + ((this.ZoomLevel != 0) ? this.ZoomLevel.ToString().Trim() : "13").ToString() + ");";  // Set Center of Map

                if (this.enableScrollWheelZoom == true)
                {
                    googlemap.Text += " map.enableScrollWheelZoom(); " + strSeperator;
                }

                if (this.navigationControl == true)
                {
                    if (UseNewVersion == true)
                    {
                        googlemap.Text += " map.addControl(new GLargeMapControl()); " + strSeperator;
                    }
                    else
                    {
                        googlemap.Text += " map.addControl(new GLargeMapControl3D()); " + strSeperator;
                    }

                }

                if (this.scaleControl == true)
                {
                    googlemap.Text += " map.addControl(new GScaleControl()); " + strSeperator;
                }

                if (this.draggable == true)
                {
                    googlemap.Text += " map.draggable= true; " + strSeperator;
                }

                if (jsArray.ToString().Length > 0)
                {
                    googlemap.Text += "  mapPoints = {'bindings':" + jsArray + " }; " + strSeperator; // Add Points Array to Script
                }
                else
                {
                    googlemap.Text += "  mapPoints = {'bindings':[] }; " + strSeperator; // Add Points Array to Script
                }

                //                //<PolyGon
                //                //Add Shift+Click event to add Polygon markers 
                //                googlemap.Text += @"  GEvent.addListener(map, 'click', function (overlay, point, overlaypoint) {
                //                      var p = (overlaypoint) ? overlaypoint : point;
                //                      //Add polygon marker if overlay is not an existing marker and shift key is pressed 
                //                      if (global.shiftKey && !checkPolygonMarkers(overlay)) { addMarker(p); }
                //                   });";
                //                //PolyGon>

                if (ShowAllMarkerForFirstTime == true)
                {
                    //اگر موردی برای نمایش وجود نداشت در تابع چیزی نشان نمی دهد
                    googlemap.Text += "    RefereshMarkerInfo(mapPoints);  " + strSeperator;
                }

                if (ShowContextMenu == true)
                {
                    // Create the context menu element
                    googlemap.Text += "  contextMenu = document.createElement('div'); " + strSeperator +
                    "        contextMenu.id = 'contextMenu'; " + strSeperator +
                    "        contextMenu.style.zIndex = '2147483647'; " + strSeperator +
                    "        contextMenu.style.display = 'none'; " + strSeperator +
                    "        contextMenu.style.position = 'absolute'; " + strSeperator +
                    "        contextMenu.style.backgroundColor = 'White'; " + strSeperator +
                    // Fill our context menu with links " + strSeperator +
                    "        contextMenu.innerHTML = " +
                    "        			'<div class=\"gmo-ctx\" dir=\"rtl\">' + " + strSeperator;
                    if (bHazManipulationPermisionOnList(ListName) == true)
                    {
                        googlemap.Text += "        			'<div><a href=\"#\" id=\\'NewLocation\\' onclick=\\'openPopup()\\' target=\"_self\">ثبت نقطه علامت جدید</a></div>' +  " + strSeperator;
                    }

                    googlemap.Text += " '<div><a href=\"#\" id=\\'zoomIn\\' onclick= \\'zoomIn()\\' >بزرگ نمایی این تقطه</a></div>' + " + strSeperator +
                    "        			'<div><a href=\"#\" id=\\'zoomOut\\' onclick= \\'zoomOut()\\'>کوچک نمایی این نقطه</a></div>' + " + strSeperator +
                    "        			'<div><a href=\"#\" id=\\'centerHere\\' onclick= \\'centerHere()\\'>متمرکز نمودن در این نقطه</a></div>' +   " + strSeperator +
                    "                   '</div>';    " + strSeperator +
                    "        document.oncontextmenu = function () { contextMenu.style.display = ''; return false; }; " + strSeperator +
                    // Disable the browser context menu on our context menu
                    "        var map_Div = document.getElementById('map_canvas'); " + strSeperator +
                    "        map_Div.appendChild(contextMenu); " + strSeperator +

                    "        contextMenu.hide = function () { contextMenu.style.display = 'none' }; " + strSeperator +
                    "        GEvent.addListener(map,'singlerightclick', function(point,src,overlay) " + strSeperator +
                    "        { clickedLatLng =map.fromContainerPixelToLatLng(point);" + strSeperator +
                    "        contextMenu.hide(); " + strSeperator +
                    "        var map_Div = document.getElementById('map_canvas'); " + strSeperator +
                    "        contextMenu.style.left = point.x + 'px'; " + strSeperator +
                    "        contextMenu.style.top = point.y + 'px'; " + strSeperator +
                    "        contextMenu.style.display = 'block'; " + strSeperator +
                    "        contextMenu.style.display = ''; " + strSeperator +

                    "        }); " + strSeperator +


                    "        GEvent.addListener(map, 'click', function () { contextMenu.hide() }); " + strSeperator +
                    "        GEvent.addListener(map, 'dragstart', function () { contextMenu.hide() }); " + strSeperator +
                    "        GEvent.addListener(map, 'zoom_changed', function () { contextMenu.hide() }); " + strSeperator +
                    "        GEvent.addListener(map, 'maptypeid_changed', function () { contextMenu.hide() }); " + strSeperator;

                }

                googlemap.Text += " } " + strSeperator +
                " function RefereshMarkerInfo(mapPoints , bNotClearOldMarker , FieldNameForMarker , FieldNameForMarkerIcon_X , FieldNameForMarkerIcon_Y , FieldNameForMarkerAnchorIcon_X , FieldNameForMarkerAnchorIcon_Y) { " + strSeperator +
                       "     if(bNotClearOldMarker == true) " + strSeperator +
                       "     {                              " + strSeperator +
                       "        //Nothing Done              " + strSeperator +
                       "     }                              " + strSeperator +
                       "     else                           " + strSeperator +
                       "     {                              " + strSeperator +
                       "         clearMarkers();             " + strSeperator +
                       "     }                              " + strSeperator +
                       "     if (typeof(mapPoints) == 'undefined') return; " + strSeperator +
                       "     if (mapPoints  == null ) return; " + strSeperator +
                       "     if (mapPoints.bindings  == null ) return; " + strSeperator +
                       "     if (mapPoints.bindings.length  == 0 ) return; " + strSeperator +
                       // Adding Long and Lat to Map Control
                       "        for (var i = 0; i < mapPoints.bindings.length; i++) {" + strSeperator +
                                     //Creating our custom icon

                                     " if  (  mapPoints.bindings[i]." + StateField + "=='')   " + strSeperator +
                                     " { mapPoints.bindings[i]." + StateField + " ='Red';  }  " + strSeperator +

                                    "        var point = new GLatLng(mapPoints.bindings[i]." + LatField + " , mapPoints.bindings[i]." + LongField + "); " + strSeperator +
                                    "        var myIcon = new GIcon(); " + strSeperator +
                                    "        if ((typeof FieldNameForMarkerIcon_X == 'undefined') || (FieldNameForMarkerIcon_X == null ) || (typeof FieldNameForMarkerIcon_Y == 'undefined') || (FieldNameForMarkerIcon_Y == null ))   " + strSeperator +
                                    "        {      " + strSeperator +
                                    "           myIcon.iconSize = new GSize(" + MarkerIcon_X + ", " + MarkerIcon_Y + "); " + strSeperator +
                                    "        } " + strSeperator +
                                    "        else" + strSeperator +
                                    "        {      " + strSeperator +
                                    "               var nFieldNameForMarkerIcon_X = parseInt(mapPoints.bindings[i][FieldNameForMarkerIcon_X]);  " + strSeperator +
                                    "               var nFieldNameForMarkerIcon_Y = parseInt(mapPoints.bindings[i][FieldNameForMarkerIcon_Y]);  " + strSeperator +
                                    "               myIcon.iconSize = new GSize(nFieldNameForMarkerIcon_X , nFieldNameForMarkerIcon_Y); " + strSeperator +
                                    "        }      " + strSeperator +

                                    "        myIcon.shadowSize  = new GSize(" + MarkerShadowIcon_X + ", " + MarkerShadowIcon_Y + "); " + strSeperator +
                                    "        if ((typeof FieldNameForMarker == 'undefined') || (FieldNameForMarker == null ))   " + strSeperator +
                                    "        {      " + strSeperator +
                                    "               myIcon.image = '" + CurrentWeb.Url + "' + '/_layouts/15/images/Sazmanyar.GoogleMapOffline/Marker/' + mapPoints.bindings[i]." + StateField + " + '/marker.png'; " + strSeperator +
                                    "               myIcon.shadow = '" + CurrentWeb.Url + "' + '/_layouts/15/images/Sazmanyar.GoogleMapOffline/Marker/shadow.png'; " + strSeperator +
                                    "        } " + strSeperator +
                                    "        else" + strSeperator +
                                    "        {      " + strSeperator +
                                    "               myIcon.image = '" + CurrentWeb.Url + "' + '/_layouts/15/images/Sazmanyar.GoogleMapOffline/Marker/' + mapPoints.bindings[i]." + StateField + " + '/' + mapPoints.bindings[i][FieldNameForMarker]+ '.png'; " + strSeperator +
                                    "        }      " + strSeperator +

                                    "        if ((typeof FieldNameForMarkerAnchorIcon_X == 'undefined') || (FieldNameForMarkerAnchorIcon_X == null ) || (typeof FieldNameForMarkerAnchorIcon_Y == 'undefined') || (FieldNameForMarkerAnchorIcon_Y == null ))   " + strSeperator +
                                    "        {      " + strSeperator +
                                    "               myIcon.iconAnchor = new GPoint(" + MarkerAnchorIcon_X + ", " + MarkerAnchorIcon_Y + "); " + strSeperator +
                                    "               myIcon.infoWindowAnchor  = new GPoint(" + MarkerAnchorIcon_X + ", " + MarkerAnchorIcon_Y + "); " + strSeperator +
                                    "        } " + strSeperator +
                                    "        else" + strSeperator +
                                    "        {      " + strSeperator +
                                    "               var nFieldNameForMarkerAnchorIcon_X = parseInt(mapPoints.bindings[i][FieldNameForMarkerAnchorIcon_X]);  " + strSeperator +
                                    "               var nFieldNameForMarkerAnchorIcon_Y = parseInt(mapPoints.bindings[i][FieldNameForMarkerAnchorIcon_Y]);  " + strSeperator +
                                    "               myIcon.iconAnchor = new GPoint(nFieldNameForMarkerAnchorIcon_X , nFieldNameForMarkerAnchorIcon_Y); " + strSeperator +
                                    "               myIcon.infoWindowAnchor = new GPoint(nFieldNameForMarkerAnchorIcon_X , nFieldNameForMarkerAnchorIcon_Y); " + strSeperator +
                                    "        }      " + strSeperator +

                                    "        var objmarker = new GMarker(point, {icon:myIcon , title:mapPoints.bindings[i]." + TitleField + "}); " + strSeperator +
                                     //Creating the event listener. It now has access to the values of 
                                     //i and marker as they were during its creation
                                     "        (function(objBindings , marker) { " + strSeperator +
                                     "        var strcontent = createMarker_strcontent(objBindings ," + bHazManipulationPermisionOnList(ListName).ToString().ToLower() + ");  " + strSeperator +
                                     "        GEvent.addListener(marker, 'click', function () { " + strSeperator +
                                     //Creating a Dispay Content 
                                     "        marker.openInfoWindowHtml(strcontent); " + strSeperator +
                                     "        }); " + strSeperator +
                                     "           map.addOverlay(marker);" + strSeperator +
                                     "        })( mapPoints.bindings[i] , objmarker );" + strSeperator +

                                     "        Arrayesmarkers.push(objmarker); " + strSeperator +

                                     "                                                         }" + strSeperator +

     "        } " + strSeperator +

     "        function clearMarkers() { " + strSeperator +
     "        map.closeInfoWindow();    " + strSeperator +
     "        if (Arrayesmarkers == null) { return; } " + strSeperator +
     "        for (var ix = 0; ix < Arrayesmarkers.length; ix++) { " + strSeperator +
     "           if (Arrayesmarkers[ix] != null) { " + strSeperator +
     "              map.removeOverlay(Arrayesmarkers[ix]); " + strSeperator +
     "              Arrayesmarkers[ix] = null; " + strSeperator +
     "          } " + strSeperator +
     "        } " + strSeperator +
     "        Arrayesmarkers.length = 0; " + strSeperator +
     "        } " + strSeperator +

     "        function zoomIn() { " + strSeperator +
     "        map.setZoom(map.getZoom() + 1); " + strSeperator +
     "        map.panTo(clickedLatLng); " + strSeperator +
     "        return false; " + strSeperator +
     "        } " + strSeperator +


     "        function zoomOut() { " + strSeperator +
     "        map.setZoom(map.getZoom() - 1); " + strSeperator +
     "        map.panTo(clickedLatLng); " + strSeperator +
     "            return false; " + strSeperator +
     "        } " + strSeperator +

     "        function centerHere() { " + strSeperator +
     "        map.panTo(clickedLatLng); " + strSeperator +
     "        return false; " + strSeperator +
     "        } " + strSeperator +

     "        function NewLocation() { " + strSeperator +
     "        map.panTo(clickedLatLng); " + strSeperator +
     "        return false; " + strSeperator +
     "        } " + strSeperator +

     "        function openPopup() {   " + strSeperator +
     "        SP.SOD.executeFunc('sp.js', 'SP.ClientContext', openPopup_Execute); " + strSeperator +
     "        return false; " + strSeperator +
     "        } " + strSeperator +
     "        function openPopup_Execute() {   " + strSeperator +
     "        var context = new SP.ClientContext('" + BaseReletiveWebUrlInfo + "'); " + strSeperator +
     "        var web = context.get_web(); " + strSeperator +
     "        var list = web.get_lists().getByTitle('" + ListName + "');   " + strSeperator +
     //Create a new record
     "       var listItemCreationInformation = new SP.ListItemCreationInformation(); " + strSeperator +
     "       listItem = list.addItem(listItemCreationInformation); " + strSeperator;

                if (Filterd_In_QueryStringValue.Trim().Length > 0)
                {
                    googlemap.Text += " listItem.set_item('" + Filterd_In_QueryStringName + "',  '" + Filterd_In_QueryStringValue.Trim() + "' ); " + strSeperator;
                }
                //Set the values
                googlemap.Text += " listItem.set_item('" + LatField + "',  clickedLatLng.lat() ); " + strSeperator +
                  "       listItem.set_item('" + LongField + "', clickedLatLng.lng() ); " + strSeperator +
                  "       listItem.set_item('" + TitleField + "', 'نامشخص'); " + strSeperator +

                  "       listItem.update(); " + strSeperator +
                  "       context.load(listItem); " + strSeperator +
                  "       ListItemIDCreated = listItem.get_id()  ; " + strSeperator +

                  "       context.executeQueryAsync(AddListItemSucceeded, AddListItemFailed); " + strSeperator +
                  "         " + strSeperator +
                  "        } " + strSeperator +

                //  -   -   -   -   -   -   -   -   -   -   

                "       function AddListItemSucceeded(sender, args) { " + strSeperator +
                "        var context = SP.ClientContext.get_current(); " + strSeperator +
                "        var strUrlListItem = \"" + HelperClass.GetDefaultEditFormUrl(CurrentWeb.ServerRelativeUrl.ToString(), ListName) + "?id= \" + listItem.get_id() ; " + strSeperator +
                //"        if(context.get_url() != \"/\") " + strSeperator +
                //"        {                              " + strSeperator +
                //"           strUrlListItem = context.get_url() + strUrlListItem ; " + strSeperator +
                //"        }                              " + strSeperator +
                "        var options = { " + strSeperator +
                "        url: strUrlListItem , " + strSeperator +
                "        title: 'ثبت نقطهء جدید', " + strSeperator +
                "        allowMaximize: false, " + strSeperator +
                "        showClose: true, " + strSeperator +
                "        dialogReturnValueCallback : Function.createDelegate( this, CloseCallback)  ,  " + strSeperator + // Function to capture dialog closed event
                "        width: 600, " + strSeperator +
                "        height: 500  " + strSeperator +
                "        } ; " + strSeperator +
                "         " + strSeperator +
                "        contextMenu.hide();  " + strSeperator +
                "        spmodaldlgwindow = SP.UI.ModalDialog.showModalDialog(options); " + strSeperator +
                "       } " + strSeperator +

                "       function AddListItemFailed(sender, args) { " + strSeperator +
                "           alert('Request failed. ' + args.get_message() + ' - ' + args.get_stackTrace()); " + strSeperator +
                "       } " + strSeperator +

                //  -   -   -   -   -   -   -   -   -   -   

                "        function CloseCallback(strReturnValue, target)           " + strSeperator +    // refresh function  
                "        { " + strSeperator +
                "        if (strReturnValue != SP.UI.DialogResult.OK)       " + strSeperator +     // Perform action on Ok. 
                "           { " + strSeperator +
                "               listItem.deleteObject();  " + strSeperator +
                "               var context = SP.ClientContext.get_current(); " + strSeperator +
                "               context.executeQueryAsync(Delete_ExecuteOnSuccess,Delete_ExecuteOnFailure);   " + strSeperator +
                "           }                 " + strSeperator +
                "        else   " + strSeperator +
                "           {   " + strSeperator +
                "               SP.UI.ModalDialog.RefreshPage(SP.UI.DialogResult.OK);   " + strSeperator +
                "           }   " + strSeperator +
                "       }     " + strSeperator +

                //  -   -   -   -   -   -   -   -   -   -   

                "       function Delete_ExecuteOnSuccess(sender, args) {  " + strSeperator +
                //"           alert('ثبت نقطهء جدید انجام نشده است');  " + strSeperator +
                "       }  " + strSeperator +

                "       function Delete_ExecuteOnFailure(sender, args) {  " + strSeperator +
                "           alert('Request failed. ' + args.get_message() + ' - ' + args.get_stackTrace()); " + strSeperator +
                "       }  " + strSeperator +

                //  -   -   -   -   -   -   -   -   -   -   
                "        function Delete_SelectedMarkListItems(itemId)              " + strSeperator +
                "        { " + strSeperator +
                "               SP.SOD.executeFunc('sp.js', 'SP.ClientContext', function() { Delete_SelectedMarkListItems_Execute(itemId); }); " + strSeperator +
                "               return false; " + strSeperator +
                "        } " + strSeperator +
                "        function Delete_SelectedMarkListItems_Execute(itemId)      " + strSeperator +
                "        { " + strSeperator +
                "               var context = new SP.ClientContext('" + BaseReletiveWebUrlInfo + "'); " + strSeperator +
                "               var web = context.get_web(); " + strSeperator +
                "               var list = web.get_lists().getByTitle('" + ListName + "');   " + strSeperator +
                "               var TempListItem = list.getItemById(itemId);     " + strSeperator +
                "               TempListItem.deleteObject();  " + strSeperator +
                "               context.executeQueryAsync(Function.createDelegate(this, this.Delete_SelectedMarkListItems_ExecuteOnSuccess),Function.createDelegate(this, this.Delete_ExecuteOnFailure));   " + strSeperator +
                "       }     " + strSeperator +

                "       function Delete_SelectedMarkListItems_ExecuteOnSuccess(sender, args) {  " + strSeperator +
                "               SP.UI.ModalDialog.RefreshPage(SP.UI.DialogResult.OK);  } " + strSeperator +
                //"               alert('نشان مورد نظر حذف شده است');  " + strSeperator +
                @"   
                   function getchlSelectedValues(chlElement)    
                   {
                        var chkText = '';        
                        var ltchktr = chlElement.getElementsByTagName('tr');                
                        for(var i=0; i<ltchktr.length; i++)        
                        {            
                            var ltchktd = ltchktr[i].getElementsByTagName('td');            
                            for(var j=0; j<ltchktd.length; j++)            
                            {               
                                var ltchkinput = ltchktd[j].getElementsByTagName('input');               
                                var chklabel= ltchktd[j].getElementsByTagName('label');                                            
                                for(k=0;k<ltchkinput.length;k++)                
                                {                                        
                                    var chkopt = ltchkinput[k];                                        
                                    if(chkopt.checked)                    
                                    {                        
                                        chkText = chkText + chklabel[k].innerHTML + '#@#';                    
                                    }                
                                }             
                            }                    
                        }               
                        return chkText;    
                    }
              
                " + strSeperator +
                   //                    //<PolyGon
                   //                    @"// Adds a new Polygon boundary marker 
                   //                    function addMarker(point) {
                   //                       var markerOptions = { icon: bluepin, draggable: true };
                   //                       var marker = new GMarker(point, markerOptions);
                   //                       PolygonMarkers.push(marker); //Add marker to PolygonMarkers array 
                   //                       map.addOverlay(marker); //Add marker on the map 
                   //                       GEvent.addListener(marker, 'dragstart', function () { //Add drag start event 
                   //                          marker.setImage(redpin.image);
                   //                          polygon_resizing = true;
                   //                       });
                   //                       GEvent.addListener(marker, 'drag', function () { drawPolygon(); }); //Add drag event 
                   //                       GEvent.addListener(marker, 'dragend', function () {   //Add drag end event 
                   //                          marker.setImage(bluepin.image);
                   //                          polygon_resizing = false;
                   //                          drawPolygon();
                   //                          fitPolygon();
                   //                       });
                   //                       GEvent.addListener(marker, 'click', function (point) { //Add Ctrl+Click event to remove marker 
                   //                          if (global.ctrlKey) { removeMarker(point); }
                   //                       });
                   //                       drawPolygon();
                   //                    
                   //                       //If more then 2 nodes then automatically fit the polygon 
                   //                       if (PolygonMarkers.length > 2) fitPolygon();
                   //                    }
                   //                    
                   //                    // Removes a Polygon boundary marker 
                   //                    function removeMarker(point) {
                   //                       if (PolygonMarkers.length == 1) { //Only one marker in the array 
                   //                          map.removeOverlay(PolygonMarkers[0]);
                   //                          map.removeOverlay(PolygonMarkers[0]);
                   //                          PolygonMarkers = [];
                   //                          if (Polygon) { map.removeOverlay(Polygon) };
                   //                       }
                   //                       else //More then one marker 
                   //                       {
                   //                          var RemoveIndex = -1;
                   //                          var Remove;
                   //                          //Search for clicked Marker in PolygonMarkers Array 
                   //                          for (var m = 0; m < PolygonMarkers.length; m++) {
                   //                             if (PolygonMarkers[m].getPoint().equals(point)) {
                   //                                RemoveIndex = m; Remove = PolygonMarkers[m]
                   //                                break;
                   //                             }
                   //                          }
                   //                          //Shift Array elemeents to left 
                   //                          for (var n = RemoveIndex; n < PolygonMarkers.length - 1; n++) {
                   //                             PolygonMarkers[n] = PolygonMarkers[n + 1];
                   //                          }
                   //                          PolygonMarkers.length = PolygonMarkers.length - 1 //Decrease Array length by 1 
                   //                          map.removeOverlay(Remove); //Remove Marker 
                   //                          drawPolygon(); //Redraw Polygon 
                   //                       }
                   //                    }
                   //                    
                   //                    //Draw Polygon from the PolygonMarkers Array 
                   //                    function drawPolygon() {
                   //                       PolygonPoints.length = 0;
                   //                       for (var m = 0; m < PolygonMarkers.length; m++) {
                   //                          PolygonPoints.push(PolygonMarkers[m].getPoint()); //Add Markers to PolygonPoints node array 
                   //                       }
                   //                       //Add first marker in the end to close the Polygon 
                   //                       PolygonPoints.push(PolygonMarkers[0].getPoint());
                   //                       if (Polygon) { map.removeOverlay(Polygon); } //Remove existing Polygon from Map 
                   //                       var fillColor = (polygon_resizing) ? 'red' : 'blue'; //Set Polygon Fill Color 
                   //                       Polygon = new GPolygon(PolygonPoints, '#FF0000', 2, 1, fillColor, 0.2); //New GPolygon object 
                   //                       map.addOverlay(Polygon); //Add Polygon to the Map 
                   //                    
                   //                       //TO DO: Function Call triggered after Polygon is drawn 
                   //                    }
                   //                    
                   //                    //Fits the Map to Polygon bounds 
                   //                    function fitPolygon() {
                   //                       bounds = Polygon.getBounds();
                   //                       map.setCenter(bounds.getCenter(), map.getBoundsZoomLevel(bounds));
                   //                    }
                   //                    //check is the marker is a polygon boundary marker 
                   //                    function checkPolygonMarkers(marker) {
                   //                       var flag = false;
                   //                       for (var m = 0; m < PolygonMarkers.length; m++) {
                   //                          if (marker == PolygonMarkers[m])
                   //                          { flag = true; break; }
                   //                       }
                   //                       return flag;
                   //                    }
                   //                    
                   //                    //////////////////[ Key down event handler ]///////////////////// 
                   //                    //Event handler class to attach events 
                   //                    var EventUtil = {
                   //                       addHandler: function (element, type, handler) {
                   //                          if (element.addEventListener) {
                   //                             element.addEventListener(type, handler, false);
                   //                          } else if (element.attachEvent) {
                   //                             element.attachEvent('on' + type, handler);
                   //                          } else {
                   //                             element['on' + type] = handler;
                   //                          }
                   //                       }
                   //                    }
                   //                    
                   //                    // Attach Key down/up events to document 
                   //                    EventUtil.addHandler(document, 'keydown', function (event) { keyDownHandler(event) });
                   //                    EventUtil.addHandler(document, 'keyup', function (event) { keyUpHandler(event) });
                   //                    
                   //                    //Checks for shift and Ctrl key press 
                   //                    function keyDownHandler(e) {
                   //                       if (!e) var e = window.event;
                   //                       var target = (!e.target) ? e.srcElement : e.target;
                   //                       if (e.keyCode == 16 && !global.shiftKey) { //Shift Key 
                   //                          global.shiftKey = true;
                   //                       }
                   //                       if (e.keyCode == 17 && !global.ctrlKey) { //Ctrl Key 
                   //                          global.ctrlKey = true;
                   //                       }
                   //                    }
                   //                    //Checks for shift and Ctrl key release 
                   //                    function keyUpHandler(e) {
                   //                       if (!e) var e = window.event;
                   //                       if (e.keyCode == 16 && global.shiftKey) { //Shift Key 
                   //                          global.shiftKey = false;
                   //                       }
                   //                       if (e.keyCode == 17 && global.ctrlKey) { //Ctrl Key 
                   //                          global.ctrlKey = false;
                   //                       }
                   //                    } " +
                   //                    //PolyGon>
                   strSeperator;

                googlemap.Text += " initializeGMap();";

                map_Search.Visible = ShowSearchPanel;
                if (ShowSearchPanel == true)
                {
                    string strInternalNameResult1 = HelperClass.GetInternalName(CurrentWeb.ServerRelativeUrl.ToString(), ListName, SearchResultField1);
                    string strInternalNameResult2 = HelperClass.GetInternalName(CurrentWeb.ServerRelativeUrl.ToString(), ListName, SearchResultField2);

                    if (strInternalNameResult1.Trim().Length == 0)
                    {
                        strInternalNameResult1 = "_____Null_____";
                    }

                    if (strInternalNameResult2.Trim().Length == 0)
                    {
                        strInternalNameResult2 = "_____Null_____";
                    }

                    googlemap.Text += @"
                            var MyLocationMarker;
                            function CheckBoxOrderByLocationClick() {
                                if (document.getElementById(""ctl00_MainContent_CheckBoxOrderByLocation"").checked) {
                                    addMyLocationMarker();
                                    document.getElementById('btnSearch').title = ""جستجو بر اساس نزدیکی به موقعیت آدمک"";
                                }
                                else {
                                    ClearMyLocationMarker();
                                    document.getElementById('btnSearch').title = ""جستجو بر اساس نزدیکی به مرکز نقشه"";
                                }
                            }
                            function addMyLocationMarker() {
                                if (map != null) {
                                    if ((typeof MyLocationMarker == ""undefined"") || (MyLocationMarker == null )) 
                                    {       var myIcon = new GIcon(); 
                                            myIcon.image = '/_layouts/15/images/Sazmanyar.GoogleMapOffline/Marker/iconMe.png';
                                            myIcon.iconAnchor = new GPoint(1, 1);
                                            var point = new GLatLng(map.getCenter().lat() , map.getCenter().lng()); 
                                            MyLocationMarker = new GMarker( point ,{ draggable: true, title: 'موقعیت من', icon:myIcon } );
                                            map.addOverlay(MyLocationMarker);
                                    }
                                 }
                            }
                        
                           function hazfPanelSearchResult() {
                                document.getElementById(""PanelSearchResult"").style.visibility = ""hidden"";
                                document.getElementById(""PanelSearchOptions"").style.visibility = ""visible"";

                            }

                           function SetMyLocationMarkerInCenter() {
                                if (typeof MyLocationMarker == ""undefined"") { return false; }
                                if (MyLocationMarker != null) { MyLocationMarker.setLatLng(map.getCenter()); }
                            }

                            function ClearMyLocationMarker() {
                                if (MyLocationMarker == null) { return; }
                                map.removeOverlay(MyLocationMarker);;
                                MyLocationMarker = null;
                            }
                            function rad(x) {return x*Math.PI/180;}
                            function find_closest_marker() {
                                    if (mapPoints == null) { return null; }  
                                    if (mapPoints.bindings == null) { return null;  }  
                                    var mapPoints_bindings = []  ;
                                    for (var counter = 0; counter < mapPoints.bindings.length; counter++) {
                                        mapPoints_bindings.push(mapPoints.bindings[counter]);
                                    }

                                    var SortedPointsmarkers = [];
                               
                                    var lat = -1;
                                    var lng = -1;

                                    if ((typeof map != 'undefined') && (map != null)) {
                                                        lat = map.getCenter().lat();
                                                        lng = map.getCenter().lng();
                                    }

                                    if (document.getElementById('ctl00_MainContent_CheckBoxOrderByLocation').checked) {
                                        if (typeof MyLocationMarker != 'undefined') {
                                            lat = MyLocationMarker.getLatLng().lat();
                                            lng = MyLocationMarker.getLatLng().lng();
                                        }
                                    }
            
                                    var R = 6371; // radius of earth in km
                             
                                    while  (mapPoints_bindings.length > 0)
                                    {
                                        var closest = -1;
                                        var distances = [];
                                        for (var i = 0; i < mapPoints_bindings.length; i++) {
                                            var mlat = mapPoints_bindings[i]." + LatField + @"; 
                                            var mlng = mapPoints_bindings[i]." + LongField + @";
                                            var dLat  = rad(mlat - lat);
                                            var dLong = rad(mlng - lng);
                                            var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                                                Math.cos(rad(lat)) * Math.cos(rad(lat)) * Math.sin(dLong/2) * Math.sin(dLong/2);
                                            var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
                                            var d = R * c;
                                            distances[i] = d;
                                            if ( closest == -1 || d < distances[closest] ) {
                                                closest = i;
                                            }
                                        } 
                                    
                                        SortedPointsmarkers.push(mapPoints_bindings[closest]);                            
                                        removeByIndex(mapPoints_bindings, closest);
                                  }
                                return  SortedPointsmarkers;                      
                                }  

                                function removeByIndex(arr, index) {
	                                arr.splice(index, 1);
                                }

                                function FillDivSearchResult(SortedPointsmarkers) {
                                    document.getElementById(""divSearchResult"").innerHTML ='';
                                    if (SortedPointsmarkers == null || SortedPointsmarkers.length == 0)
                                    {
                                        document.getElementById(""divSearchResult"").innerHTML = '<div class=""gmo-msg"">هیچ موردی جهت نمایش در لیست یافت نشد</div>';
                                        return;
                                    }

                                    var HTML = '' ;
                                    var cnt = 0 ;

                                    HTML += '<div class=""gmo-count"">تعداد موارد یافت شده: <b>'  + SortedPointsmarkers.length + '</b>';

                                    var MaxSearchResult  =  " + MaxSearchResult + @";
                                    if(MaxSearchResult== 0)
                                    {
                                        MaxSearchResult = SortedPointsmarkers.length;
                                    }
                                    else if(MaxSearchResult < SortedPointsmarkers.length)
                                    {
                                        HTML += ' (نمایش '  + MaxSearchResult + ' مورد)';
                                    }
                                    HTML += '</div>';
         
          
                                    for (var r = 0; r < MaxSearchResult ; r++) {

                                            if(r > SortedPointsmarkers.length-1) { break; }
                                            var BusinessID = SortedPointsmarkers[r].ID;
                                            var strInternalNameResult1 = SortedPointsmarkers[r]." + TitleField + @" ;;
                                            if ('" + strInternalNameResult1 + @"' != '_____Null_____') 
                                            {
                                               strInternalNameResult1 = SortedPointsmarkers[r]." + strInternalNameResult1 + @" ;
                                            }
                    
                                            var strInternalNameResult2 ='';
                                            if ('" + strInternalNameResult2 + @"' != '_____Null_____') 
                                            {
                                                strInternalNameResult2 = SortedPointsmarkers[r]." + strInternalNameResult2 + @" ;
                                            }
             
                                            var Latitude = SortedPointsmarkers[r]." + LatField + @";
                                            var Longitude = SortedPointsmarkers[r]." + LongField + @";
                                            var IconFileName = '" + CurrentWeb.Url + "/_layouts/15/images/Sazmanyar.GoogleMapOffline/Marker/' + SortedPointsmarkers[r]." + StateField + @"  +  '/marker.png';
          
                                        HTML += ""<div class='gmo-item'>"";
                                        if (parseFloat(Latitude) < 0 || parseFloat(Longitude) < 0) {
                                            HTML += ""<span class='gmo-item-icon gmo-item-icon-off' title='موقعیت هنوز مشخص نشده است'></span>"";
                                        }
                                        else {
                                            HTML += ""<img class='gmo-item-icon' src='"" + IconFileName + ""' title='نمایش موقعیت بر روی نقشه' onclick='javascript:ShowLocation("" +  BusinessID +  "" ,"" + Latitude + "","" + Longitude + "")' />"";
                                        }
                                        HTML += ""<div class='gmo-item-text'>"";
                                        HTML += ""<a class='gmo-item-title' href='#' title='نمایش جزئیات' onclick='javascript:ShowDetailInfo("" +  BusinessID +  "" );return false;'><span class='gmo-item-num'>"" + ( r + 1) + ""</span>"" + strInternalNameResult1 + ""</a>"";
                                        if (strInternalNameResult2 != """") {
                                            if (strInternalNameResult2.length > 65) {
                                                strInternalNameResult2 = strInternalNameResult2.substring(0, 65);
                                                strInternalNameResult2 += "" ... "";
                                            }
                                            HTML += ""<span class='gmo-item-sub'>"" + strInternalNameResult2 + ""</span>"";
                                        }
                                        HTML += ""</div></div>"";
                                        cnt++;

                                        }
                                        document.getElementById(""divSearchResult"").innerHTML = HTML;
                                    }


                                   function togglePanel() {
                                        hazfPanelSearchResult();
                                        if (document.getElementById(""divRightOptions"") == null) { return; }
                                        if (document.getElementById(""divRightOptions"").style.display == ""none"") {
                                            document.getElementById(""divRightOptions"").style.display = ""block"";
                                            document.getElementById(""ctl00_panelArrow"").src = ""/_layouts/15/images/Sazmanyar.GoogleMapOffline/Search/right-arrow.png"";
                                            document.getElementById(""ctl00_panelArrow"").title = ""بستن فرم جستجو"";
                                        }
                                        else {
                                            document.getElementById(""divRightOptions"").style.display = ""none"";
                                            document.getElementById(""ctl00_panelArrow"").src = ""/_layouts/15/images/Sazmanyar.GoogleMapOffline/Search/left-arrow.png"";
                                            document.getElementById(""ctl00_panelArrow"").title = ""نمایش فرم جستجو"";
                                        }

                                        if ((typeof map != 'undefined') && (map != null)) {
                                            map.checkResize();
                                        }
                                    }

                                  function ButtonSearchClicked() {
                                        document.getElementById('divRightOptions').style.display = 'block';
                                        document.getElementById('ctl00_panelArrow').src = '/_layouts/15/images/Sazmanyar.GoogleMapOffline/Search/right-arrow.png';
                                        document.getElementById('ctl00_panelArrow').title = 'بستن فرم جستجو';
                                        document.getElementById(""PanelSearchResult"").style.visibility = ""visible"";
                                        document.getElementById(""PanelSearchOptions"").style.visibility = ""hidden"";
                
                                        var SqlQueryViewName= '" + SqlQueryViewName.ToString() + @"';
                                        var SqlQueryConnectionString= '" + SqlQueryConnectionString.ToString() + @"';
                                        var RelationalColumnBetweenListsAndViews= '" + RelationalColumnBetweenListsAndViews.ToString() + @"';
                                        var RelationalColumnForloadInMapPoint= '" + RelationalColumnForloadInMapPoint.ToString() + @"';
                                        var IsOuterJoin= '" + IsOuterJoin.ToString().ToLower() + @"';
                                        var Filterd_In_QueryStringName= '" + Filterd_In_QueryStringName.ToString() + @"';
                                        var Filterd_In_QueryStringValue= '" + Filterd_In_QueryStringValue.ToString() + @"';

                                        var SiteID= '" + CurrentWeb.Site.ID.ToString() + @"';
                                        var Weburl= '" + CurrentWeb.ServerRelativeUrl.ToString() + @"';
                                        var ListName = """ + ListName + @""";

                                        var ListUrlHelper1 = """ + ListUrlHelper1 + @""";
                                        var ListUrlHelper2 = """ + ListUrlHelper2 + @""";
                                        var ListUrlHelper3 = """ + ListUrlHelper3 + @""";
                                        var ListUrlHelper4 = """ + ListUrlHelper4 + @""";
                                        var ListUrlHelper5 = """ + ListUrlHelper5 + @""";

                                        var ViewName = """ + View_name + @""";
                                        var ShowByAdminPrevilage = " + ShowByAdminPrevilage.ToString().ToLower() + @";
                                        var LatField = """ + LatField + @""";
                                        var LongField = """ + LongField + @""";
                                        var IsCenField = """ + IsCenField + @""";
                                        var StateField = """ + StateField + @""";
                                        var ShouldRemovedFromBaseUrl = """ + ShouldRemovedFromBaseUrl + @""";
                
                                        var cmbMarekerFilter1_SelectedValue = """";
                                        var cmbMarekerFilter2_SelectedValue = """";
                                        var cmbMarekerFilter3_SelectedValue = """";               
                                        var e1 = document.getElementById(""" + cmbMarekerFilter1.ClientID + @""")
                                        var e2 = document.getElementById(""" + cmbMarekerFilter2.ClientID + @""")
                                        var e3 = document.getElementById(""" + cmbMarekerFilter3.ClientID + @""")
                                        if(e1 != null)
                                            cmbMarekerFilter1_SelectedValue = e1.options[e1.selectedIndex].value ;
                                        if(e2 != null)
                                            cmbMarekerFilter2_SelectedValue = e2.options[e2.selectedIndex].value ;
                                        if(e3 != null)
                                            cmbMarekerFilter3_SelectedValue = e3.options[e3.selectedIndex].value ;
                
                                        var txtMarekerSearch1_TextValue = """";
                                        var txtMarekerSearch2_TextValue = """";
                                        var txtMarekerSearch3_TextValue = """";
                                        var t1 = document.getElementById(""" + txtMarekerSearch1.ClientID + @""")
                                        var t2 = document.getElementById(""" + txtMarekerSearch2.ClientID + @""")
                                        var t3 = document.getElementById(""" + txtMarekerSearch3.ClientID + @""")
                                        if(t1 != null)
                                            txtMarekerSearch1_TextValue = t1.value ;
                                        if(t2 != null)
                                            txtMarekerSearch2_TextValue = t2.value ;
                                        if(t3 != null)
                                            txtMarekerSearch3_TextValue = t3.value ;
                
                                        var chlMarekerCheckList1_SelectedValues = """";
                                        var chlMarekerCheckList2_SelectedValues = """";
                                        var chlMarekerCheckList3_SelectedValues = """";
                                        var c1 = document.getElementById(""" + chlMarekerCheckList1.ClientID + @""")
                                        var c2 = document.getElementById(""" + chlMarekerCheckList2.ClientID + @""")
                                        var c3 = document.getElementById(""" + chlMarekerCheckList3.ClientID + @""")
                                        if(c1 != null)
                                            chlMarekerCheckList1_SelectedValues = getchlSelectedValues(c1);
                                        if(c2 != null)
                                            chlMarekerCheckList2_SelectedValues = getchlSelectedValues(c2);
                                        if(c3 != null)
                                            chlMarekerCheckList3_SelectedValues = getchlSelectedValues(c3);

                                        var filterd_by_column1 = """ + filterd_by_column1 + @""";
                                        var filterd_by_column2 = """ + filterd_by_column2 + @""";
                                        var filterd_by_column3 = """ + filterd_by_column3 + @""";
                    
                                        var Searched_by_column1 = """ + Searched_by_column1 + @""";
                                        var Searched_by_column2 = """ + Searched_by_column2 + @""";
                                        var Searched_by_column3 = """ + Searched_by_column3 + @""";
                
                                        var CheckList_by_column1 = """ + CheckList_by_column1 + @""";
                                        var CheckList_by_column2 = """ + CheckList_by_column2 + @""";
                                        var CheckList_by_column3 = """ + CheckList_by_column3 + @""";
                    
                                            document.getElementById(""divSearchResult"").innerHTML = '';
                                            if(mapPoints != null)
                                            {
                       
                                               document.getElementById(""divSearchResult"").innerHTML = '<div class=""gmo-msg gmo-msg-wait"">لطفاً کمی صبر نمایید ...<br />سیستم در حال جستجوی اطلاعات مورد نیاز شما می باشد</div>';
                                                    $.ajax({
                                                    type: ""POST"",
                                                    url: ""/_layouts/15/Sazmanyar.GoogleMapOffline/ApplicationPage_ForloaddingMarkerData.aspx/" + (RelationalColumnForloadInMapPoint.Trim().Length > 0 ? "GetListItemsAsStringByCustomColumn" : "GetListItemsAsString") + @""",
                                                    data: ""{" + (RelationalColumnForloadInMapPoint.Trim().Length > 0 ? @"'RelationalColumnForloadInMapPoint':'"" + RelationalColumnForloadInMapPoint + ""'," : "") + @"'SqlQueryViewName':'"" + SqlQueryViewName + ""','SqlQueryConnectionString':'"" + SqlQueryConnectionString  + ""','RelationalColumnBetweenListsAndViews':'"" + RelationalColumnBetweenListsAndViews + ""','IsOuterJoin':'"" + IsOuterJoin + ""','Filterd_In_QueryStringName':'"" + Filterd_In_QueryStringName + ""','Filterd_In_QueryStringValue':'"" + Filterd_In_QueryStringValue + ""','SiteID':'"" + SiteID + ""','Weburl':'"" + Weburl + ""','ListName':'"" + ListName + ""','ListUrlHelper1':'"" + ListUrlHelper1 + ""','ListUrlHelper2':'"" + ListUrlHelper2 + ""','ListUrlHelper3':'"" + ListUrlHelper3 + ""','ListUrlHelper4':'"" + ListUrlHelper4 + ""','ListUrlHelper5':'"" + ListUrlHelper5 + ""','ViewName':'"" + ViewName + ""','ShowByAdminPrevilage':'"" + ShowByAdminPrevilage + ""','LatField':'"" + LatField + ""','LongField':'"" + LongField + ""','StateField':'"" + StateField + ""','IsCenField':'"" + IsCenField + ""','ShouldRemovedFromBaseUrl':'"" + ShouldRemovedFromBaseUrl + ""','cmbMarekerFilter1_SelectedValue':'"" + cmbMarekerFilter1_SelectedValue + ""','cmbMarekerFilter2_SelectedValue':'"" + cmbMarekerFilter2_SelectedValue + ""','cmbMarekerFilter3_SelectedValue':'"" + cmbMarekerFilter3_SelectedValue + ""','txtMarekerSearch1_TextValue':'"" + txtMarekerSearch1_TextValue + ""','txtMarekerSearch2_TextValue':'"" + txtMarekerSearch2_TextValue + ""','txtMarekerSearch3_TextValue':'"" + txtMarekerSearch3_TextValue + ""','chlMarekerCheckList1_SelectedValues':'"" + chlMarekerCheckList1_SelectedValues + ""','chlMarekerCheckList2_SelectedValues':'"" + chlMarekerCheckList2_SelectedValues + ""','chlMarekerCheckList3_SelectedValues':'"" + chlMarekerCheckList3_SelectedValues + ""','filterd_by_column1':'"" + filterd_by_column1 + ""','filterd_by_column2':'"" + filterd_by_column2 + ""','filterd_by_column3':'"" + filterd_by_column3 + ""','Searched_by_column1':'"" + Searched_by_column1 + ""','Searched_by_column2':'"" + Searched_by_column2 + ""','Searched_by_column3':'"" + Searched_by_column3 + ""','CheckList_by_column1':'"" + CheckList_by_column1 + ""','CheckList_by_column2':'"" + CheckList_by_column2 + ""','CheckList_by_column3':'"" + CheckList_by_column3 + ""'}"",
                                                    contentType: ""application/json; charset=utf-8"",
                                                    dataType: ""json"",
                                                    success: function (strHtmlOutput) {
                                                        if(strHtmlOutput.d != '')
                                                            {
                                                            mapPoints.bindings = JSON.parse(strHtmlOutput.d);
                                                        }
                                                        else
                                                        {
                                                            mapPoints.bindings = null;
                                                        }
                                                        RefereshMarkerInfo(mapPoints);
                                                        var SortedPointsmarkers = find_closest_marker();
                                                        FillDivSearchResult(SortedPointsmarkers);
                        
                                                    }
                                                });
                                             }
                                             else
                                             {
                                                document.getElementById(""divSearchResult"").innerHTML = '<div class=""gmo-msg"">هیچ موردی جهت نمایش در لیست یافت نشد</div>';
                                             }
                                        }
  
                                        function ShowDetailInfo_Temp( BusinessID ) {
                                           var strUrlListItem = '/Lists/" + ListName + @"/DispForm.aspx?id= ' + BusinessID ; 
                                           var options = { 
                                           url: strUrlListItem , 
                                           title: 'نمایش جزئیات', 
                                           allowMaximize: false, 
                                           showClose: true}; 
                                           SP.UI.ModalDialog.showModalDialog(options);           
                                        }

                                        function ShowDetailInfo( BusinessID ) {
                                            document.getElementById('pnlShowDetails').style.visibility='visible';
                                            var objbindings;
                                            for (var i = 0; i < mapPoints.bindings.length; i++) { 
                                                if  (  mapPoints.bindings[i].ID == BusinessID )   
                                                {
                                                    objbindings =mapPoints.bindings[i];
                                                    break;

                                                }
                                            }
                                            if(objbindings != null)
                                            {
                                               var strcontent = DrowDetailInfo_strcontent(objbindings , " + bHazManipulationPermisionOnList(ListName).ToString().ToLower() + @"); 
                                               document.getElementById('pnl_msgbody').innerHTML =  strcontent;
                                               document.getElementById('pnl_title').innerHTML =  objbindings." + TitleField + @";
                        
                                            }
                                        }

                                        function closeDetailInfo() {
                                          document.getElementById('pnlShowDetails').style.visibility='hidden';
                                        }

                                        function ShowLocation( BusinessID, Latitude, Longitude) {
                                            if (Arrayesmarkers == null) { return; }
                                            var selectedIdx = -1;
                                            for (var ix = 0; ix < Arrayesmarkers.length; ix++) {
                                                map.closeInfoWindow(); 
                                                if ( (Arrayesmarkers[ix].getLatLng().lat() == Latitude) && (Arrayesmarkers[ix].getLatLng().lng() == Longitude)) {
                                                     selectedIdx = ix;
                                                  }
                                                //if (Arrayesmarkers[ix].BusinessID == BusinessID)  {
                                                //     selectedIdx = ix;
                                                //}
                                            }
                                            if (selectedIdx >= 0) {
                                                GEvent.trigger(Arrayesmarkers[selectedIdx],'click'); ;                                               
                                                map.setCenter(new GLatLng(Latitude, Longitude));
                                            }
                                        } togglePanel();  ";
                }
                else
                {
                    map_Search.Visible = false;
                }

                googlemap.Text += "</script>";

                if (strSeperator != Environment.NewLine)
                {
                    for (int i = 0; i < 1000; i++)
                    {
                        googlemap.Text = googlemap.Text.Replace("  ", " ");
                    }
                }

                Page.RegisterStartupScript("googlemap", googlemap.Text);

            }
            catch (Exception ex)
            {
                this.Controls.Add(new LiteralControl(ex.Message));
            }

        }

        private void RenderingFilterPart(SPWeb CurrentWeb)
        {

            DataTable objDataTableDetailInfo = HelperClass.Get_DetailInfoFromSqlView(SqlQueryViewName, SqlQueryConnectionString, CurrentWeb.Site.ID);

            lblError.Text = "";

            pnlSearch1.Visible = false;
            lblOnvanSearch1.Visible = false;
            txtMarekerSearch1.Visible = false;

            if (this.Searched_by_column1.ToString().Trim().Length != 0)
            {
                lblOnvanSearch1.Text = "";
                txtMarekerSearch1.Text = "";

                string strTitle = this.Searched_by_column1.ToString();

                pnlSearch1.Visible = true;
                lblOnvanSearch1.Visible = true;
                lblOnvanSearch1.Text = strTitle + " : ";
                txtMarekerSearch1.Visible = true;
            }

            pnlSearch2.Visible = false;
            lblOnvanSearch2.Visible = false;
            txtMarekerSearch2.Visible = false;

            if (this.Searched_by_column2.ToString().Trim().Length != 0)
            {

                lblOnvanSearch2.Text = "";
                txtMarekerSearch2.Text = "";

                string strTitle = this.Searched_by_column2.ToString();

                pnlSearch2.Visible = true;
                lblOnvanSearch2.Visible = true;
                lblOnvanSearch2.Text = strTitle + " : ";
                txtMarekerSearch2.Visible = true;
            }

            pnlSearch3.Visible = false;
            lblOnvanSearch3.Visible = false;
            txtMarekerSearch3.Visible = false;

            if (this.Searched_by_column3.ToString().Trim().Length != 0)
            {
                lblOnvanSearch3.Text = "";
                txtMarekerSearch3.Text = "";

                string strTitle = this.Searched_by_column3.ToString();

                pnlSearch3.Visible = true;
                lblOnvanSearch3.Visible = true;
                lblOnvanSearch3.Text = strTitle + " : ";
                txtMarekerSearch3.Visible = true;
            }

            pnlFilter1.Visible = false;
            lblOnvanFilter1.Visible = false;
            cmbMarekerFilter1.Visible = false;

            if (this.filterd_by_column1.ToString().Trim().Length != 0)
            {
                lblOnvanFilter1.Text = "";
                cmbMarekerFilter1.Items.Clear();

                string strTitle = "";
                string strError = "";
                string strInternalName = "";

                DataTable objFilterDataSource = GetFilteredDataSource(objDataTableDetailInfo, this.filterd_by_column1, ref strTitle, ref strError, ref strInternalName);

                if ((objFilterDataSource == null) || (strError.Trim().Length != 0))
                {
                    lblError.Text = lblError.Text + strError;
                }
                else
                {
                    pnlFilter1.Visible = true;
                    lblOnvanFilter1.Visible = true;
                    lblOnvanFilter1.Text = strTitle + " : ";
                    cmbMarekerFilter1.Visible = true;
                    cmbMarekerFilter1.Attributes.Add("InternalColName", strInternalName);
                    try
                    {
                        cmbMarekerFilter1.Items.Add(" ");
                        foreach (DataRow objDataRow in objFilterDataSource.Rows)
                        {
                            if (objDataRow[0].ToString().Trim().Length > 0)
                            {
                                cmbMarekerFilter1.Items.Add(objDataRow[0].ToString());
                            }
                        }
                    }
                    catch (Exception)
                    {

                    }
                }
            }

            pnlFilter2.Visible = false;
            lblOnvanFilter2.Visible = false;
            cmbMarekerFilter2.Visible = false;

            if (this.filterd_by_column2.ToString().Trim().Length != 0)
            {

                lblOnvanFilter2.Text = "";
                cmbMarekerFilter2.Items.Clear();

                string strTitle = "";
                string strError = "";
                string strInternalName = "";
                DataTable objFilterDataSource = GetFilteredDataSource(objDataTableDetailInfo, this.filterd_by_column2, ref strTitle, ref strError, ref strInternalName);

                if ((objFilterDataSource == null) || (strError.Trim().Length != 0))
                {
                    lblError.Text = lblError.Text + strError;
                }
                else
                {
                    pnlFilter2.Visible = true;
                    lblOnvanFilter2.Visible = true;
                    lblOnvanFilter2.Text = strTitle + " : ";
                    cmbMarekerFilter2.Visible = true;
                    cmbMarekerFilter2.Attributes.Add("InternalColName", strInternalName);

                    try
                    {
                        cmbMarekerFilter2.Items.Add(" ");
                        foreach (DataRow objDataRow in objFilterDataSource.Rows)
                        {
                            if (objDataRow[0].ToString().Trim().Length > 0)
                            {
                                cmbMarekerFilter2.Items.Add(objDataRow[0].ToString());
                            }
                        }
                    }
                    catch (Exception)
                    {

                    }
                }
            }

            pnlFilter3.Visible = false;
            lblOnvanFilter3.Visible = false;
            cmbMarekerFilter3.Visible = false;

            if (this.filterd_by_column3.ToString().Trim().Length != 0)
            {
                lblOnvanFilter3.Text = "";
                cmbMarekerFilter3.Items.Clear();

                string strTitle = "";
                string strError = "";
                string strInternalName = "";
                DataTable objFilterDataSource = GetFilteredDataSource(objDataTableDetailInfo, this.filterd_by_column3, ref strTitle, ref strError, ref strInternalName);

                if ((objFilterDataSource == null) || (strError.Trim().Length != 0))
                {
                    lblError.Text = lblError.Text + strError;
                }
                else
                {
                    pnlFilter3.Visible = true;
                    lblOnvanFilter3.Visible = true;
                    lblOnvanFilter3.Text = strTitle + " : ";
                    cmbMarekerFilter3.Visible = true;
                    cmbMarekerFilter3.Attributes.Add("InternalColName", strInternalName);
                    try
                    {
                        cmbMarekerFilter3.Items.Add(" ");
                        foreach (DataRow objDataRow in objFilterDataSource.Rows)
                        {
                            if (objDataRow[0].ToString().Trim().Length > 0)
                            {
                                cmbMarekerFilter3.Items.Add(objDataRow[0].ToString());
                            }
                        }
                    }
                    catch (Exception)
                    {

                    }
                }
            }

            //***********************************
            pnlCheckList1.Visible = false;
            lblOnvanCheckList1.Visible = false;
            chlMarekerCheckList1.Visible = false;

            if (this.CheckList_by_column1.ToString().Trim().Length != 0)
            {
                lblOnvanCheckList1.Text = "";
                chlMarekerCheckList1.Items.Clear();

                string strTitle = "";
                string strError = "";
                string strInternalName = "";
                DataTable objCheckListDataSource = GetFilteredDataSource(objDataTableDetailInfo, this.CheckList_by_column1, ref strTitle, ref strError, ref strInternalName);

                if ((objCheckListDataSource == null) || (strError.Trim().Length != 0))
                {
                    lblError.Text = lblError.Text + strError;
                }
                else
                {
                    pnlCheckList1.Visible = true;
                    lblOnvanCheckList1.Visible = true;
                    lblOnvanCheckList1.Text = strTitle + " : ";
                    chlMarekerCheckList1.Visible = true;
                    chlMarekerCheckList1.Attributes.Add("InternalColName", strInternalName);
                    try
                    {
                        foreach (DataRow objDataRow in objCheckListDataSource.Rows)
                        {
                            if (objDataRow[0].ToString().Trim().Length > 0)
                            {
                                chlMarekerCheckList1.Items.Add(objDataRow[0].ToString());
                            }
                        }
                    }
                    catch (Exception)
                    {

                    }
                }
            }

            pnlCheckList2.Visible = false;
            lblOnvanCheckList2.Visible = false;
            chlMarekerCheckList2.Visible = false;

            if (this.CheckList_by_column2.ToString().Trim().Length != 0)
            {

                lblOnvanCheckList2.Text = "";
                chlMarekerCheckList2.Items.Clear();

                string strTitle = "";
                string strError = "";
                string strInternalName = "";
                DataTable objCheckListDataSource = GetFilteredDataSource(objDataTableDetailInfo, this.CheckList_by_column2, ref strTitle, ref strError, ref strInternalName);

                if ((objCheckListDataSource == null) || (strError.Trim().Length != 0))
                {
                    lblError.Text = lblError.Text + strError;
                }
                else
                {
                    pnlCheckList2.Visible = true;
                    lblOnvanCheckList2.Visible = true;
                    lblOnvanCheckList2.Text = strTitle + " : ";
                    chlMarekerCheckList2.Visible = true;
                    chlMarekerCheckList2.Attributes.Add("InternalColName", strInternalName);
                    try
                    {
                        foreach (DataRow objDataRow in objCheckListDataSource.Rows)
                        {
                            if (objDataRow[0].ToString().Trim().Length > 0)
                            {
                                chlMarekerCheckList2.Items.Add(objDataRow[0].ToString());
                            }
                        }
                    }
                    catch (Exception)
                    {

                    }
                }
            }

            pnlCheckList3.Visible = false;
            lblOnvanCheckList3.Visible = false;
            chlMarekerCheckList3.Visible = false;

            if (this.CheckList_by_column3.ToString().Trim().Length != 0)
            {
                lblOnvanCheckList3.Text = "";
                chlMarekerCheckList3.Items.Clear();

                string strTitle = "";
                string strError = "";
                string strInternalName = "";
                DataTable objCheckListDataSource = GetFilteredDataSource(objDataTableDetailInfo, this.CheckList_by_column3, ref strTitle, ref strError, ref strInternalName);

                if ((objCheckListDataSource == null) || (strError.Trim().Length != 0))
                {
                    lblError.Text = lblError.Text + strError;
                }
                else
                {
                    pnlCheckList3.Visible = true;
                    lblOnvanCheckList3.Visible = true;
                    lblOnvanCheckList3.Text = strTitle + " : ";
                    chlMarekerCheckList3.Visible = true;
                    chlMarekerCheckList3.Attributes.Add("InternalColName", strInternalName);
                    try
                    {
                        foreach (DataRow objDataRow in objCheckListDataSource.Rows)
                        {
                            if (objDataRow[0].ToString().Trim().Length > 0)
                            {
                                chlMarekerCheckList3.Items.Add(objDataRow[0].ToString());
                            }
                        }
                    }
                    catch (Exception)
                    {

                    }
                }
            }
            //***********************************
            if (
                (lblError.Text.Trim().Length > 0)
                || (chlMarekerCheckList1.Visible == true) || (chlMarekerCheckList2.Visible == true) || (chlMarekerCheckList3.Visible == true)
                || (cmbMarekerFilter1.Visible == true) || (cmbMarekerFilter2.Visible == true) || (cmbMarekerFilter3.Visible == true)
                || (txtMarekerSearch1.Visible == true) || (txtMarekerSearch2.Visible == true) || (txtMarekerSearch3.Visible == true)
                )
            {
                pnlFilterPart.Visible = true;
            }
            else
            {
                pnlFilterPart.Visible = false;
            }
        }

        private void GetListItemsAsString(SPWeb CurrentWeb, ref string BasejsArray, ref string BasejsCenter)
        {

            string Filterd_In_QueryStringName = "";
            string Filterd_In_QueryStringValue = "";
            if (Filtered_In_QueryString.Trim().Length > 0)
            {
                try
                {
                    Filterd_In_QueryStringName = Filtered_In_QueryString;
                    Filterd_In_QueryStringValue = Page.Request.QueryString[Filtered_In_QueryString];
                    if (Filterd_In_QueryStringValue == null)
                    {
                        //اطلاعات هیچ مارکری را لود نکند
                        Filterd_In_QueryStringValue = "@*@";
                    }
                }
                catch
                {

                }
            }

            DataTable objDataTableDetailInfo = HelperClass.Get_DetailInfoFromSqlView(SqlQueryViewName, SqlQueryConnectionString, CurrentWeb.Site.ID);

            string jsArray = string.Empty;
            string jsCenter = string.Empty;


            string chlMarekerCheckList1_SelectedValues = "";
            foreach (ListItem objitem in chlMarekerCheckList1.Items)
            {
                if (objitem.Selected == true)
                {
                    chlMarekerCheckList1_SelectedValues = chlMarekerCheckList1_SelectedValues + objitem.Text + "#@#";
                }
            }

            string chlMarekerCheckList2_SelectedValues = "";
            foreach (ListItem objitem in chlMarekerCheckList2.Items)
            {
                if (objitem.Selected == true)
                {
                    chlMarekerCheckList2_SelectedValues = chlMarekerCheckList2_SelectedValues + objitem.Text + "#@#";
                }
            }

            string chlMarekerCheckList3_SelectedValues = "";
            foreach (ListItem objitem in chlMarekerCheckList3.Items)
            {
                if (objitem.Selected == true)
                {
                    chlMarekerCheckList3_SelectedValues = chlMarekerCheckList3_SelectedValues + objitem.Text + "#@#";
                }
            }

            if (ListName.ToString().Trim().Length > 0)
            {
                SPListCollection lists = null;
                SPList objBaseSelectedList = null;
                SPSecurity.RunWithElevatedPrivileges(
                               delegate ()
                               {
                                   using (SPSite CurrentSite = new SPSite(CurrentWeb.Site.ID))
                                   {
                                       using (SPWeb web = CurrentSite.OpenWeb(CurrentWeb.ID))
                                       {
                                           lists = web.Lists;
                                       }
                                   }
                               }
                       );

                foreach (SPList list in lists)
                {
                    if (list.Title.Trim().ToLowerInvariant() == ListName.Trim().ToLowerInvariant())
                    {
                        objBaseSelectedList = list;
                        break;
                    }
                }
                HelperClass.GetListItemsAsString(objDataTableDetailInfo, RelationalColumnBetweenListsAndViews, IsOuterJoin, objBaseSelectedList, View_name, ShowByAdminPrevilage, LatField, LongField, StateField, IsCenField, ShouldRemovedFromBaseUrl,
                                                RelationalColumnForloadInMapPoint, cmbMarekerFilter1.SelectedValue, cmbMarekerFilter2.SelectedValue, cmbMarekerFilter3.SelectedValue,
                                                txtMarekerSearch1.Text, txtMarekerSearch2.Text, txtMarekerSearch3.Text,
                                                chlMarekerCheckList1_SelectedValues, chlMarekerCheckList2_SelectedValues, chlMarekerCheckList3_SelectedValues,
                                                filterd_by_column1, filterd_by_column2, filterd_by_column3,
                                                Searched_by_column1, Searched_by_column2, Searched_by_column3,
                                                CheckList_by_column1, CheckList_by_column2, CheckList_by_column3,
                                                ref jsArray, ref jsCenter, Filterd_In_QueryStringName, Filterd_In_QueryStringValue);
            }



            if (ListUrlHelper1.Trim().Length > 0 && ListUrlHelper1 != "*")
            {
                try
                {
                    SPList objSelectedList = null;
                    SPSecurity.RunWithElevatedPrivileges(
                   delegate ()
                   {
                       SPSite TempCurrentSite = null;
                       try
                       {
                           TempCurrentSite = new SPSite(ListUrlHelper1); //شاید مربوط به سایت کالکشن دیگری باشد و با اچ تی تی پی باز شده باشد
                       }
                       catch
                       {
                           TempCurrentSite = new SPSite(CurrentWeb.Site.ID);//در حالتی که در سایت کالکشن های داخلی باشد 
                       }

                       //در هر دو حالت جواب می دهد
                       SPWeb ListTempCurrentWeb = TempCurrentSite.OpenWeb();
                       objSelectedList = ListTempCurrentWeb.GetList(ListUrlHelper1);

                   });

                    HelperClass.GetListItemsAsString(objDataTableDetailInfo, RelationalColumnBetweenListsAndViews, IsOuterJoin, objSelectedList, View_name, ShowByAdminPrevilage, LatField, LongField, StateField, IsCenField, ShouldRemovedFromBaseUrl,
                                                RelationalColumnForloadInMapPoint, cmbMarekerFilter1.SelectedValue, cmbMarekerFilter2.SelectedValue, cmbMarekerFilter3.SelectedValue,
                                                txtMarekerSearch1.Text, txtMarekerSearch2.Text, txtMarekerSearch3.Text,
                                                chlMarekerCheckList1_SelectedValues, chlMarekerCheckList2_SelectedValues, chlMarekerCheckList3_SelectedValues,
                                                filterd_by_column1, filterd_by_column2, filterd_by_column3,
                                                Searched_by_column1, Searched_by_column2, Searched_by_column3,
                                                CheckList_by_column1, CheckList_by_column2, CheckList_by_column3,
                                                ref jsArray, ref jsCenter, Filterd_In_QueryStringName, Filterd_In_QueryStringValue);

                }
                catch (Exception)
                { }
            }

            if (ListUrlHelper2.Trim().Length > 0 && ListUrlHelper2 != "*")
            {
                try
                {
                    SPList objSelectedList = null;
                    SPSecurity.RunWithElevatedPrivileges(
                   delegate ()
                   {
                       SPSite TempCurrentSite = null;
                       try
                       {
                           TempCurrentSite = new SPSite(ListUrlHelper2); //شاید مربوط به سایت کالکشن دیگری باشد و با اچ تی تی پی باز شده باشد
                       }
                       catch
                       {
                           TempCurrentSite = new SPSite(CurrentWeb.Site.ID);//در حالتی که در سایت کالکشن های داخلی باشد 
                       }

                       //در هر دو حالت جواب می دهد
                       SPWeb ListTempCurrentWeb = TempCurrentSite.OpenWeb();
                       objSelectedList = ListTempCurrentWeb.GetList(ListUrlHelper2);

                   });

                    HelperClass.GetListItemsAsString(objDataTableDetailInfo, RelationalColumnBetweenListsAndViews, IsOuterJoin, objSelectedList, View_name, ShowByAdminPrevilage, LatField, LongField, StateField, IsCenField, ShouldRemovedFromBaseUrl,
                                                RelationalColumnForloadInMapPoint, cmbMarekerFilter1.SelectedValue, cmbMarekerFilter2.SelectedValue, cmbMarekerFilter3.SelectedValue,
                                                txtMarekerSearch1.Text, txtMarekerSearch2.Text, txtMarekerSearch3.Text,
                                                chlMarekerCheckList1_SelectedValues, chlMarekerCheckList2_SelectedValues, chlMarekerCheckList3_SelectedValues,
                                                filterd_by_column1, filterd_by_column2, filterd_by_column3,
                                                Searched_by_column1, Searched_by_column2, Searched_by_column3,
                                                CheckList_by_column1, CheckList_by_column2, CheckList_by_column3,
                                                ref jsArray, ref jsCenter, Filterd_In_QueryStringName, Filterd_In_QueryStringValue);

                }
                catch (Exception)
                { }
            }

            if (ListUrlHelper3.Trim().Length > 0 && ListUrlHelper3 != "*")
            {
                try
                {
                    SPList objSelectedList = null;
                    SPSecurity.RunWithElevatedPrivileges(
                   delegate ()
                   {
                       SPSite TempCurrentSite = null;
                       try
                       {
                           TempCurrentSite = new SPSite(ListUrlHelper3); //شاید مربوط به سایت کالکشن دیگری باشد و با اچ تی تی پی باز شده باشد
                       }
                       catch
                       {
                           TempCurrentSite = new SPSite(CurrentWeb.Site.ID);//در حالتی که در سایت کالکشن های داخلی باشد 
                       }

                       //در هر دو حالت جواب می دهد
                       SPWeb ListTempCurrentWeb = TempCurrentSite.OpenWeb();
                       objSelectedList = ListTempCurrentWeb.GetList(ListUrlHelper3);
                   });

                    HelperClass.GetListItemsAsString(objDataTableDetailInfo, RelationalColumnBetweenListsAndViews, IsOuterJoin, objSelectedList, View_name, ShowByAdminPrevilage, LatField, LongField, StateField, IsCenField, ShouldRemovedFromBaseUrl,
                                                RelationalColumnForloadInMapPoint, cmbMarekerFilter1.SelectedValue, cmbMarekerFilter2.SelectedValue, cmbMarekerFilter3.SelectedValue,
                                                txtMarekerSearch1.Text, txtMarekerSearch2.Text, txtMarekerSearch3.Text,
                                                chlMarekerCheckList1_SelectedValues, chlMarekerCheckList2_SelectedValues, chlMarekerCheckList3_SelectedValues,
                                                filterd_by_column1, filterd_by_column2, filterd_by_column3,
                                                Searched_by_column1, Searched_by_column2, Searched_by_column3,
                                                CheckList_by_column1, CheckList_by_column2, CheckList_by_column3,
                                                ref jsArray, ref jsCenter, Filterd_In_QueryStringName, Filterd_In_QueryStringValue);
                }
                catch (Exception)
                { }
            }

            if (ListUrlHelper4.Trim().Length > 0 && ListUrlHelper4 != "*")
            {
                try
                {
                    SPList objSelectedList = null;
                    SPSecurity.RunWithElevatedPrivileges(
                   delegate ()
                   {
                       SPSite TempCurrentSite = null;
                       try
                       {
                           TempCurrentSite = new SPSite(ListUrlHelper4); //شاید مربوط به سایت کالکشن دیگری باشد و با اچ تی تی پی باز شده باشد
                       }
                       catch
                       {
                           TempCurrentSite = new SPSite(CurrentWeb.Site.ID);//در حالتی که در سایت کالکشن های داخلی باشد 
                       }

                       //در هر دو حالت جواب می دهد
                       SPWeb ListTempCurrentWeb = TempCurrentSite.OpenWeb();
                       objSelectedList = ListTempCurrentWeb.GetList(ListUrlHelper4);
                   });

                    HelperClass.GetListItemsAsString(objDataTableDetailInfo, RelationalColumnBetweenListsAndViews, IsOuterJoin, objSelectedList, View_name, ShowByAdminPrevilage, LatField, LongField, StateField, IsCenField, ShouldRemovedFromBaseUrl,
                                                RelationalColumnForloadInMapPoint, cmbMarekerFilter1.SelectedValue, cmbMarekerFilter2.SelectedValue, cmbMarekerFilter3.SelectedValue,
                                                txtMarekerSearch1.Text, txtMarekerSearch2.Text, txtMarekerSearch3.Text,
                                                chlMarekerCheckList1_SelectedValues, chlMarekerCheckList2_SelectedValues, chlMarekerCheckList3_SelectedValues,
                                                filterd_by_column1, filterd_by_column2, filterd_by_column3,
                                                Searched_by_column1, Searched_by_column2, Searched_by_column3,
                                                CheckList_by_column1, CheckList_by_column2, CheckList_by_column3,
                                                ref jsArray, ref jsCenter, Filterd_In_QueryStringName, Filterd_In_QueryStringValue);

                }
                catch (Exception)
                { }
            }

            if (ListUrlHelper5.Trim().Length > 0 && ListUrlHelper5 != "*")
            {
                try
                {
                    SPList objSelectedList = null;
                    SPSecurity.RunWithElevatedPrivileges(
                   delegate ()
                   {
                       SPSite TempCurrentSite = null;
                       try
                       {
                           TempCurrentSite = new SPSite(ListUrlHelper5); //شاید مربوط به سایت کالکشن دیگری باشد و با اچ تی تی پی باز شده باشد
                       }
                       catch
                       {
                           TempCurrentSite = new SPSite(CurrentWeb.Site.ID);//در حالتی که در سایت کالکشن های داخلی باشد 
                       }

                       //در هر دو حالت جواب می دهد
                       SPWeb ListTempCurrentWeb = TempCurrentSite.OpenWeb();
                       objSelectedList = ListTempCurrentWeb.GetList(ListUrlHelper5);
                   });

                    HelperClass.GetListItemsAsString(objDataTableDetailInfo, RelationalColumnBetweenListsAndViews, IsOuterJoin, objSelectedList, View_name, ShowByAdminPrevilage, LatField, LongField, StateField, IsCenField, ShouldRemovedFromBaseUrl,
                                                RelationalColumnForloadInMapPoint, cmbMarekerFilter1.SelectedValue, cmbMarekerFilter2.SelectedValue, cmbMarekerFilter3.SelectedValue,
                                                txtMarekerSearch1.Text, txtMarekerSearch2.Text, txtMarekerSearch3.Text,
                                                chlMarekerCheckList1_SelectedValues, chlMarekerCheckList2_SelectedValues, chlMarekerCheckList3_SelectedValues,
                                                filterd_by_column1, filterd_by_column2, filterd_by_column3,
                                                Searched_by_column1, Searched_by_column2, Searched_by_column3,
                                                CheckList_by_column1, CheckList_by_column2, CheckList_by_column3,
                                                ref jsArray, ref jsCenter, Filterd_In_QueryStringName, Filterd_In_QueryStringValue);

                }
                catch (Exception)
                { }
            }

            BasejsArray = jsArray;
            BasejsCenter = jsCenter;

        }

        private DataTable GetFilteredDataSource(DataTable objDataTableDetailInfo, string strfilterd_by_column, ref string strTitle, ref string strError, ref string strInternalName)
        {
            SPWeb CurrentWeb = SPContext.Current.Web;

            DataTable FilteredDataSource = HelperClass.GetFilteredDataSource(objDataTableDetailInfo, BaseWebUrlInfo, ListName, strfilterd_by_column, ref strTitle, ref strError);

            if (ListUrlHelper1.Trim().Length > 0 && ListUrlHelper1 != "*")
            {
                DataTable objTemp = null;
                string strTitleTemp = "";
                string strErrorTemp = "";

                try
                {
                    SPWeb TempCurrentWeb = CurrentWeb;
                    String strSiteUrl = SPContext.Current.Web.Site.Url;
                    SPSecurity.RunWithElevatedPrivileges(
                    delegate ()
                    {
                        SPSite TempCurrentSite = null;
                        try
                        {
                            TempCurrentSite = new SPSite(BaseWebUrlInfo);
                        }
                        catch (Exception)
                        {
                            TempCurrentSite = new SPSite(strSiteUrl + BaseWebUrlInfo);
                        }
                        SPWeb ListTempCurrentWeb = TempCurrentSite.OpenWeb(ListUrlHelper1.Replace(TempCurrentSite.Url.ToString(), ""));
                        SPList objSelectedList = ListTempCurrentWeb.GetList(ListUrlHelper1);
                        objTemp = HelperClass.GetFilteredDataSource(objDataTableDetailInfo, objSelectedList, strfilterd_by_column, ref strTitleTemp, ref strErrorTemp);

                    });


                }
                catch (Exception)
                { }

                if (objTemp != null)
                {
                    if (FilteredDataSource != null)
                    {
                        FilteredDataSource.Load(objTemp.CreateDataReader());
                    }
                    else
                    {
                        FilteredDataSource = objTemp;
                    }
                }

            }

            //  -   -   -   -   -   -   -  -   -   
            if (ListUrlHelper2.Trim().Length > 0 && ListUrlHelper2 != "*")
            {
                DataTable objTemp = null;
                string strTitleTemp = "";
                string strErrorTemp = "";

                try
                {
                    SPWeb TempCurrentWeb = CurrentWeb;
                    String strSiteUrl = SPContext.Current.Web.Site.Url;
                    SPSecurity.RunWithElevatedPrivileges(
                    delegate ()
                    {
                        SPSite TempCurrentSite = null;
                        try
                        {
                            TempCurrentSite = new SPSite(BaseWebUrlInfo);
                        }
                        catch (Exception)
                        {
                            TempCurrentSite = new SPSite(strSiteUrl + BaseWebUrlInfo);
                        }

                        SPWeb ListTempCurrentWeb = TempCurrentSite.OpenWeb(ListUrlHelper2.Replace(TempCurrentSite.Url.ToString(), ""));
                        SPList objSelectedList = ListTempCurrentWeb.GetList(ListUrlHelper2);
                        objTemp = HelperClass.GetFilteredDataSource(objDataTableDetailInfo, objSelectedList, strfilterd_by_column, ref strTitleTemp, ref strErrorTemp);

                    });


                }
                catch (Exception)
                { }

                if (objTemp != null)
                {
                    if (FilteredDataSource != null)
                    {
                        FilteredDataSource.Load(objTemp.CreateDataReader());
                    }
                    else
                    {
                        FilteredDataSource = objTemp;
                    }
                }

            }

            //  -   -   -   -   -   -   -  -   -   
            if (ListUrlHelper3.Trim().Length > 0 && ListUrlHelper3 != "*")
            {
                DataTable objTemp = null;
                string strTitleTemp = "";
                string strErrorTemp = "";

                try
                {
                    SPWeb TempCurrentWeb = CurrentWeb;
                    String strSiteUrl = SPContext.Current.Web.Site.Url;
                    SPSecurity.RunWithElevatedPrivileges(
                    delegate ()
                    {
                        SPSite TempCurrentSite = null;
                        try
                        {
                            TempCurrentSite = new SPSite(BaseWebUrlInfo);
                        }
                        catch (Exception)
                        {
                            TempCurrentSite = new SPSite(strSiteUrl + BaseWebUrlInfo);
                        }

                        SPWeb ListTempCurrentWeb = TempCurrentSite.OpenWeb(ListUrlHelper3.Replace(TempCurrentSite.Url.ToString(), ""));
                        SPList objSelectedList = ListTempCurrentWeb.GetList(ListUrlHelper3);
                        objTemp = HelperClass.GetFilteredDataSource(objDataTableDetailInfo, objSelectedList, strfilterd_by_column, ref strTitleTemp, ref strErrorTemp);

                    });


                }
                catch (Exception)
                { }

                if (objTemp != null)
                {
                    if (FilteredDataSource != null)
                    {
                        FilteredDataSource.Load(objTemp.CreateDataReader());
                    }
                    else
                    {
                        FilteredDataSource = objTemp;
                    }
                }

            }

            //  -   -   -   -   -   -   -  -   -   
            if (ListUrlHelper4.Trim().Length > 0 && ListUrlHelper4 != "*")
            {
                DataTable objTemp = null;
                string strTitleTemp = "";
                string strErrorTemp = "";

                try
                {
                    SPWeb TempCurrentWeb = CurrentWeb;
                    String strSiteUrl = SPContext.Current.Web.Site.Url;
                    SPSecurity.RunWithElevatedPrivileges(
                    delegate ()
                    {
                        SPSite TempCurrentSite = null;
                        try
                        {
                            TempCurrentSite = new SPSite(BaseWebUrlInfo);
                        }
                        catch (Exception)
                        {
                            TempCurrentSite = new SPSite(strSiteUrl + BaseWebUrlInfo);
                        }

                        SPWeb ListTempCurrentWeb = TempCurrentSite.OpenWeb(ListUrlHelper4.Replace(TempCurrentSite.Url.ToString(), ""));
                        SPList objSelectedList = ListTempCurrentWeb.GetList(ListUrlHelper4);
                        objTemp = HelperClass.GetFilteredDataSource(objDataTableDetailInfo, objSelectedList, strfilterd_by_column, ref strTitleTemp, ref strErrorTemp);

                    });


                }
                catch (Exception)
                { }

                if (objTemp != null)
                {
                    if (FilteredDataSource != null)
                    {
                        FilteredDataSource.Load(objTemp.CreateDataReader());
                    }
                    else
                    {
                        FilteredDataSource = objTemp;
                    }
                }

            }

            //  -   -   -   -   -   -   -  -   -   
            if (ListUrlHelper5.Trim().Length > 0 && ListUrlHelper5 != "*")
            {
                DataTable objTemp = null;
                string strTitleTemp = "";
                string strErrorTemp = "";

                try
                {
                    SPWeb TempCurrentWeb = CurrentWeb;
                    String strSiteUrl = SPContext.Current.Web.Site.Url;
                    SPSecurity.RunWithElevatedPrivileges(
                    delegate ()
                    {
                        SPSite TempCurrentSite = null;
                        try
                        {
                            TempCurrentSite = new SPSite(BaseWebUrlInfo);
                        }
                        catch (Exception)
                        {
                            TempCurrentSite = new SPSite(strSiteUrl + BaseWebUrlInfo);
                        }

                        SPWeb ListTempCurrentWeb = TempCurrentSite.OpenWeb(ListUrlHelper5.Replace(TempCurrentSite.Url.ToString(), ""));
                        SPList objSelectedList = ListTempCurrentWeb.GetList(ListUrlHelper5);
                        objTemp = HelperClass.GetFilteredDataSource(objDataTableDetailInfo, objSelectedList, strfilterd_by_column, ref strTitleTemp, ref strErrorTemp);

                    });


                }
                catch (Exception)
                { }

                if (objTemp != null)
                {
                    if (FilteredDataSource != null)
                    {
                        FilteredDataSource.Load(objTemp.CreateDataReader());
                    }
                    else
                    {
                        FilteredDataSource = objTemp;
                    }
                }

            }

            //  -   -   -   -   -   -   -  -   -   
            if (FilteredDataSource == null)
            {
                return null;
            }
            else
            {
                strInternalName = FilteredDataSource.Columns[0].ColumnName;
                return FilteredDataSource.DefaultView.ToTable(true, FilteredDataSource.Columns[0].ColumnName); ;
            }
        }

    }
}