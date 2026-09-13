using Microsoft.SharePoint;
using Microsoft.SharePoint.WebControls;
using Sazmanyar.GoogleMapOffline.Classes;
using System;
using System.ComponentModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

namespace Sazmanyar.GoogleMapOffline.FilteredGoogleMapOfflineWebpart
{
    [ToolboxItemAttribute(false)]
    public class FilteredGoogleMapOfflineWebpart : WebPart
    {
        // Visual Studio might automatically update this path when you change the Visual Web Part project item.
        private string _ascxPath = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GoogleMapOffline/FilteredGoogleMapOfflineWebpart/FilteredGoogleMapOfflineWebpartUserControl.ascx";

        #region MultiLanguage definition

        [AttributeUsage(AttributeTargets.Property, AllowMultiple = false, Inherited = true)]
        public sealed class LocalizedWebDisplayNameAttribute
           : WebDisplayNameAttribute
        {
            bool m_isLocalized;
            public LocalizedWebDisplayNameAttribute(string displayName)
                : base(displayName)
            {
            }
            public override string DisplayName
            {
                get
                {
                    if (!m_isLocalized)
                    {
                        this.DisplayNameValue = HelperClass.getLocalizedValue(base.DisplayName);
                        m_isLocalized = true;
                    }
                    return base.DisplayName;
                }
            }
        }

        [AttributeUsage(AttributeTargets.Property, AllowMultiple = false, Inherited = true)]
        public sealed class LocalizedWebDescriptionAttribute
           : WebDescriptionAttribute
        {
            bool m_isLocalized;
            public LocalizedWebDescriptionAttribute(string displayName)
                : base(displayName)
            {
            }
            public override string Description
            {
                get
                {
                    if (!m_isLocalized)
                    {
                        this.DescriptionValue = HelperClass.getLocalizedValue(base.Description);
                        m_isLocalized = true;
                    }
                    return base.Description;
                }
            }
        }

        #endregion

        #region Check License

        protected override void CreateChildControls()
        {
            //TrialMaker tm = new TrialMaker("GoogleMapOffline", "145", Microsoft.SharePoint.Administration.SPFarm.Local.Id.ToString(), SPUtility.GetGenericSetupPath(@"TEMPLATE\FEATURES\Sazmanyar.GoogleMapOffline_Feature"));
            //if ((tm.c() == TrialMaker.RunTypes.a || tm.c() == TrialMaker.RunTypes.b))
            //{
            DO();
            //}
            //else
            //{
            //   Label MessageError = new Label();
            //   MessageError.ID = "MessageError";
            //   MessageError.Text = SPUtils.getLocalizedValue("_SettingsLicenseTrialEndedDescription", "Sazmanyar.GoogleMapOffline");

            //   HtmlGenericControl objNewLine1 = new HtmlGenericControl("br");

            //   HyperLink hlSettingsPage = new HyperLink();
            //   hlSettingsPage.ID = "hlSettingsPage";
            //   hlSettingsPage.Text = "Enter The Serial Number";
            //   hlSettingsPage.NavigateUrl = string.Format("{0}/_layouts/15/Sazmanyar.GoogleMapOffline/Settings.aspx", SPContext.Current.Site.Url);

            //   HtmlGenericControl objNewLine2 = new HtmlGenericControl("br");

            //   Controls.Add(MessageError);
            //   Controls.Add(objNewLine1);
            //   Controls.Add(hlSettingsPage);
            //   Controls.Add(objNewLine2);


            //   return;
            //}
        }

        private void DO()
        {
            //Place your code here
            _CreateChildControls();
        }

        #endregion

        #region Base Settings - Do not Change

        private string _BaseWebUrlInfo = "/";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsBaseWebUrlInfo")]
        [LocalizedWebDescriptionAttribute("_SettingsBaseWebUrlInfo")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Base Settings - Do not Change")]
        public string BaseWebUrlInfo
        {
            get
            {
                return _BaseWebUrlInfo;
            }
            set
            {
                _BaseWebUrlInfo = value;

            }
        }

        string _ListName = "Google Map List";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsListName")]
        [LocalizedWebDescriptionAttribute("_SettingsListName")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Base Settings - Do not Change")]
        public string ListName
        {
            get
            {
                return _ListName;
            }
            set
            {
                _ListName = value;

            }
        }

        string _View_name = "View name";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsView_name")]
        [LocalizedWebDescriptionAttribute("_SettingsView_name")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Base Settings - Do not Change")]
        public string View_name
        {
            get
            {
                return _View_name;
            }
            set
            {
                _View_name = value;

            }
        }

        string _TitleField = "Title";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsTitleField")]
        [LocalizedWebDescriptionAttribute("_SettingsTitleField")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Base Settings - Do not Change")]
        public string TitleField
        {
            get
            {
                return _TitleField;
            }
            set
            {
                _TitleField = value;

            }
        }

        string _LatField = "Latitude";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsLatField")]
        [LocalizedWebDescriptionAttribute("_SettingsLatField")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Base Settings - Do not Change")]
        public string LatField
        {
            get
            {
                return _LatField;
            }
            set
            {
                _LatField = value;

            }
        }

        string _LongField = "Longitude";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsLongField")]
        [LocalizedWebDescriptionAttribute("_SettingsLongField")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Base Settings - Do not Change")]
        public string LongField
        {
            get
            {
                return _LongField;
            }
            set
            {
                _LongField = value;

            }
        }

        string _IsCenField = "IsCenter";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsIsCenField")]
        [LocalizedWebDescriptionAttribute("_SettingsIsCenField")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Base Settings - Do not Change")]
        public string IsCenField
        {
            get
            {
                return _IsCenField;
            }
            set
            {
                _IsCenField = value;

            }
        }

        string _StateField = "State";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsStateField")]
        [LocalizedWebDescriptionAttribute("_SettingsStateField")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Base Settings - Do not Change")]
        public string StateField
        {
            get
            {
                return _StateField;
            }
            set
            {
                _StateField = value;

            }
        }

        #endregion

        #region ListUrlHelper

        //this List Use Only for Dispalying Items

        string _ListUrlHelper1 = "*";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsListUrlHelper1")]
        [LocalizedWebDescriptionAttribute("_SettingsListUrlHelper1")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General ListUrlHelper Setting")]
        public string ListUrlHelper1
        {
            get
            {
                return _ListUrlHelper1;
            }
            set
            {
                _ListUrlHelper1 = value;

            }
        }

        string _ListUrlHelper2 = "*";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsListUrlHelper2")]
        [LocalizedWebDescriptionAttribute("_SettingsListUrlHelper2")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General ListUrlHelper Setting")]
        public string ListUrlHelper2
        {
            get
            {
                return _ListUrlHelper2;
            }
            set
            {
                _ListUrlHelper2 = value;

            }
        }


        string _ListUrlHelper3 = "*";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsListUrlHelper3")]
        [LocalizedWebDescriptionAttribute("_SettingsListUrlHelper3")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General ListUrlHelper Setting")]
        public string ListUrlHelper3
        {
            get
            {
                return _ListUrlHelper3;
            }
            set
            {
                _ListUrlHelper3 = value;

            }
        }

        string _ListUrlHelper4 = "*";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsListUrlHelper4")]
        [LocalizedWebDescriptionAttribute("_SettingsListUrlHelper4")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General ListUrlHelper Setting")]
        public string ListUrlHelper4
        {
            get
            {
                return _ListUrlHelper4;
            }
            set
            {
                _ListUrlHelper4 = value;

            }
        }

        string _ListUrlHelper5 = "*";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsListUrlHelper5")]
        [LocalizedWebDescriptionAttribute("_SettingsListUrlHelper5")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General ListUrlHelper Setting")]
        public string ListUrlHelper5
        {
            get
            {
                return _ListUrlHelper5;
            }
            set
            {
                _ListUrlHelper5 = value;

            }
        }

        #endregion

        #region SqlQueryHelper

        string _RelationalColumnBetweenListsAndViews = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsRelationalColumnBetweenListsAndViews")]
        [LocalizedWebDescriptionAttribute("_SettingsRelationalColumnBetweenListsAndViews")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General SQLHelper Setting")]
        public string RelationalColumnBetweenListsAndViews
        {
            get
            {
                return _RelationalColumnBetweenListsAndViews;
            }
            set
            {
                _RelationalColumnBetweenListsAndViews = value;
            }
        }

        Boolean _IsOuterJoin = true;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsIsOuterJoin")]
        [LocalizedWebDescriptionAttribute("_SettingsIsOuterJoin")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General SQLHelper Setting")]
        public Boolean IsOuterJoin
        {
            get
            {
                return _IsOuterJoin;
            }
            set
            {
                _IsOuterJoin = value;

            }
        }

        string _SqlQueryViewName = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsSqlQueryViewName")]
        [LocalizedWebDescriptionAttribute("_SettingsSqlQueryViewName")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General SQLHelper Setting")]
        public string SqlQueryViewName
        {
            get
            {
                return _SqlQueryViewName;
            }
            set
            {
                _SqlQueryViewName = value;

            }
        }

        private string _SqlQueryConnectionString = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsSqlQueryConnectionString")]
        [LocalizedWebDescriptionAttribute("_SettingsSqlQueryConnectionString")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General SQLHelper Setting")]
        public string SqlQueryConnectionString
        {
            get
            {
                return _SqlQueryConnectionString;
            }
            set
            {
                _SqlQueryConnectionString = value;

            }
        }

        #endregion

        #region General Settings

        private Boolean _UseNewVersion = false;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsUseNewVersion")]
        [LocalizedWebDescriptionAttribute("_SettingsUseNewVersion")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public Boolean UseNewVersion
        {
            get
            {
                return _UseNewVersion;
            }
            set
            {
                _UseNewVersion = value;

            }
        }

        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsAdress_ascxPath")]
        [LocalizedWebDescriptionAttribute("_SettingsAdress_ascxPath")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public string Url_ascxPath
        {
            get
            {
                return _ascxPath;
            }
            set
            {
                _ascxPath = value;
            }
        }

        private Boolean _ShowAllMarkerForFirstTime = true;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsShowAllMarkerForFirstTime")]
        [LocalizedWebDescriptionAttribute("_SettingsShowAllMarkerForFirstTime")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public Boolean ShowAllMarkerForFirstTime
        {
            get
            {
                return _ShowAllMarkerForFirstTime;
            }
            set
            {
                _ShowAllMarkerForFirstTime = value;

            }
        }


        string _RelationalColumnForloadInMapPoint = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsRelationalColumnForloadInMapPoint")]
        [LocalizedWebDescriptionAttribute("_SettingsRelationalColumnForloadInMapPoint")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public string RelationalColumnForloadInMapPoint
        {
            get
            {
                return _RelationalColumnForloadInMapPoint;
            }
            set
            {
                _RelationalColumnForloadInMapPoint = value;
            }
        }


        private string _ShouldRemovedFromBaseUrl = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsShouldRemovedFromBaseUrl")]
        [LocalizedWebDescriptionAttribute("_SettingsShouldRemovedFromBaseUrl")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public string ShouldRemovedFromBaseUrl
        {
            get
            {
                return _ShouldRemovedFromBaseUrl;
            }
            set
            {
                _ShouldRemovedFromBaseUrl = value;

            }
        }

        private string _Adress_Of_Image_Location = "/_layouts/15/images/Sazmanyar.GoogleMapOffline/Google Maps Image/";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsAdress_Of_Image_Location")]
        [LocalizedWebDescriptionAttribute("_SettingsAdress_Of_Image_Location")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public string Adress_Of_Image_Location
        {
            get
            {
                return _Adress_Of_Image_Location;
            }
            set
            {
                _Adress_Of_Image_Location = value;

            }
        }

        private Boolean _ShowByAdminPrevilage = true;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsShowByAdminPrevilage")]
        [LocalizedWebDescriptionAttribute("_SettingsShowByAdminPrevilage")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public Boolean ShowByAdminPrevilage
        {
            get
            {
                return _ShowByAdminPrevilage;
            }
            set
            {
                _ShowByAdminPrevilage = value;

            }
        }

        private Boolean _enableScrollWheelZoom = false;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsenableScrollWheelZoom")]
        [LocalizedWebDescriptionAttribute("_SettingsenableScrollWheelZoom")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public Boolean enableScrollWheelZoom
        {
            get
            {
                return _enableScrollWheelZoom;
            }
            set
            {
                _enableScrollWheelZoom = value;

            }
        }

        private Boolean _navigationControl = false;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsnavigationControl")]
        [LocalizedWebDescriptionAttribute("_SettingsnavigationControl")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public Boolean navigationControl
        {
            get
            {
                return _navigationControl;
            }
            set
            {
                _navigationControl = value;

            }
        }


        private Boolean _scaleControl = false;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsscaleControl")]
        [LocalizedWebDescriptionAttribute("_SettingsscaleControl")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public Boolean scaleControl
        {
            get
            {
                return _scaleControl;
            }
            set
            {
                _scaleControl = value;

            }
        }

        private Boolean _draggable = false;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_Settingsdraggable")]
        [LocalizedWebDescriptionAttribute("_Settingsdraggable")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public Boolean draggable
        {
            get
            {
                return _draggable;
            }
            set
            {
                _draggable = value;

            }
        }


        private Boolean _ShowContextMenu = true;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsShowContextMenu")]
        [LocalizedWebDescriptionAttribute("_SettingsShowContextMenu")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public Boolean ShowContextMenu
        {
            get
            {
                return _ShowContextMenu;
            }
            set
            {
                _ShowContextMenu = value;

            }
        }

        private int _ZoomLevel = 0;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsZoomLevel")]
        [LocalizedWebDescriptionAttribute("_SettingsZoomLevel")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public int ZoomLevel
        {
            get
            {
                return _ZoomLevel;
            }
            set
            {
                _ZoomLevel = value;

            }
        }


        private int _mininumLevel = 0;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsmininumLevel")]
        [LocalizedWebDescriptionAttribute("_SettingsmininumLevel")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public int mininumLevel
        {
            get
            {
                if (_mininumLevel < 0)
                {
                    return 0;
                }
                else
                {
                    return _mininumLevel;
                }
            }

            set
            {
                _mininumLevel = value;
            }
        }

        private int _maxinumLevel = 20;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsmaxinumLevel")]
        [LocalizedWebDescriptionAttribute("_SettingsmaxinumLevel")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public int maxinumLevel
        {
            get
            {
                if (_maxinumLevel > 20)
                {
                    return 20;
                }
                else
                {
                    return _maxinumLevel;
                }
            }
            set
            {
                _maxinumLevel = value;
            }
        }

        private string _JSDrowMarkerAddressUrl = @"/_layouts/15/Sazmanyar.GoogleMapOffline/Script/js/DrowMarker.js";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsJSDrowMarkerAddressUrl")]
        [LocalizedWebDescriptionAttribute("_SettingsJSDrowMarkerAddressUrl")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public string JSDrowMarkerAddressUrl
        {
            get
            {
                return _JSDrowMarkerAddressUrl;
            }
            set
            {
                _JSDrowMarkerAddressUrl = value;

            }
        }


        public int _MarkerIcon_X = 20;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_Settings_MarkerIcon_X")]
        [LocalizedWebDescriptionAttribute("_Settings_MarkerIcon_X")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public int MarkerIcon_X
        {
            get
            {
                return _MarkerIcon_X;
            }
            set
            {
                _MarkerIcon_X = value;
            }
        }

        public int _MarkerIcon_Y = 20;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_Settings_MarkerIcon_Y")]
        [LocalizedWebDescriptionAttribute("_Settings_MarkerIcon_Y")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public int MarkerIcon_Y
        {
            get
            {
                return _MarkerIcon_Y;
            }
            set
            {
                _MarkerIcon_Y = value;
            }
        }

        public int _MarkerShadowIcon_X = 20;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_Settings_MarkerShadowIcon_X")]
        [LocalizedWebDescriptionAttribute("_Settings_MarkerShadowIcon_X")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public int MarkerShadowIcon_X
        {
            get
            {
                return _MarkerShadowIcon_X;
            }
            set
            {
                _MarkerShadowIcon_X = value;
            }
        }
        public int _MarkerShadowIcon_Y = 20;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_Settings_MarkerShadowIcon_Y")]
        [LocalizedWebDescriptionAttribute("_Settings_MarkerShadowIcon_Y")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public int MarkerShadowIcon_Y
        {
            get
            {
                return _MarkerShadowIcon_Y;
            }
            set
            {
                _MarkerShadowIcon_Y = value;
            }
        }

        public int _MarkerAnchorIcon_X = 10;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_Settings_MarkerAnchorIcon_X")]
        [LocalizedWebDescriptionAttribute("_Settings_MarkerAnchorIcon_X")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public int MarkerAnchorIcon_X
        {
            get
            {
                return _MarkerAnchorIcon_X;
            }
            set
            {
                _MarkerAnchorIcon_X = value;
            }
        }
        public int _MarkerAnchorIcon_Y = 10;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_Settings_MarkerAnchorIcon_Y")]
        [LocalizedWebDescriptionAttribute("_Settings_MarkerAnchorIcon_Y")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public int MarkerAnchorIcon_Y
        {
            get
            {
                return _MarkerAnchorIcon_Y;
            }
            set
            {
                _MarkerAnchorIcon_Y = value;
            }
        }

        public int _InfoWindowAnchor_X = 10;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_Settings_InfoWindowAnchor_X")]
        [LocalizedWebDescriptionAttribute("_Settings_InfoWindowAnchor_X")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public int InfoWindowAnchor_X
        {
            get
            {
                return _InfoWindowAnchor_X;
            }
            set
            {
                _InfoWindowAnchor_X = value;
            }
        }

        public int _InfoWindowAnchor_Y = 10;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_Settings_InfoWindowAnchor_Y")]
        [LocalizedWebDescriptionAttribute("_Settings_InfoWindowAnchor_Y")]
        [Personalizable(PersonalizationScope.User)]
        [Category("General Settings")]
        public int InfoWindowAnchor_Y
        {
            get
            {
                return _InfoWindowAnchor_Y;
            }
            set
            {
                _InfoWindowAnchor_Y = value;
            }
        }

        #endregion

        #region Search Panel

        private string _Filtered_In_QueryString = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsFiltered_In_QueryString")]
        [LocalizedWebDescriptionAttribute("_SettingsFiltered_In_QueryString")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Search Panel")]
        public string Filtered_In_QueryString
        {
            get
            {
                return _Filtered_In_QueryString;
            }
            set
            {
                _Filtered_In_QueryString = value;

            }
        }

        private Boolean _ShowSearchPanel = false;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsShowSearchPanel")]
        [LocalizedWebDescriptionAttribute("_SettingsShowSearchPanel")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Search Panel")]
        public Boolean ShowSearchPanel
        {
            get
            {
                return _ShowSearchPanel;
            }
            set
            {
                _ShowSearchPanel = value;

            }
        }

        private string _Searched_by_column1 = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsSearched_by_column1")]
        [LocalizedWebDescriptionAttribute("_SettingsSearched_by_column1")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Search Panel")]
        public string Searched_by_column1
        {
            get
            {
                return _Searched_by_column1;
            }
            set
            {
                _Searched_by_column1 = value;

            }
        }

        private string _Searched_by_column2 = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsSearched_by_column2")]
        [LocalizedWebDescriptionAttribute("_SettingsSearched_by_column2")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Search Panel")]
        public string Searched_by_column2
        {
            get
            {
                return _Searched_by_column2;
            }
            set
            {
                _Searched_by_column2 = value;

            }
        }

        private string _Searched_by_column3 = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsSearched_by_column3")]
        [LocalizedWebDescriptionAttribute("_SettingsSearched_by_column3")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Search Panel")]
        public string Searched_by_column3
        {
            get
            {
                return _Searched_by_column3;
            }
            set
            {
                _Searched_by_column3 = value;

            }
        }


        private string _filterd_by_column1 = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_Settingsfilterd_by_column1")]
        [LocalizedWebDescriptionAttribute("_Settingsfilterd_by_column1")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Search Panel")]
        public string filterd_by_column1
        {
            get
            {
                return _filterd_by_column1;
            }
            set
            {
                _filterd_by_column1 = value;

            }
        }

        private string _filterd_by_column2 = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_Settingsfilterd_by_column2")]
        [LocalizedWebDescriptionAttribute("_Settingsfilterd_by_column2")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Search Panel")]
        public string filterd_by_column2
        {
            get
            {
                return _filterd_by_column2;
            }
            set
            {
                _filterd_by_column2 = value;

            }
        }

        private string _filterd_by_column3 = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_Settingsfilterd_by_column3")]
        [LocalizedWebDescriptionAttribute("_Settingsfilterd_by_column3")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Search Panel")]
        public string filterd_by_column3
        {
            get
            {
                return _filterd_by_column3;
            }
            set
            {
                _filterd_by_column3 = value;

            }
        }




        //------------------------------

        private string _CheckList_by_column1 = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsCheckList_by_column1")]
        [LocalizedWebDescriptionAttribute("_SettingsCheckList_by_column1")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Search Panel")]
        public string CheckList_by_column1
        {
            get
            {
                return _CheckList_by_column1;
            }
            set
            {
                _CheckList_by_column1 = value;

            }
        }

        private string _CheckList_by_column2 = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsCheckList_by_column2")]
        [LocalizedWebDescriptionAttribute("_SettingsCheckList_by_column2")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Search Panel")]
        public string CheckList_by_column2
        {
            get
            {
                return _CheckList_by_column2;
            }
            set
            {
                _CheckList_by_column2 = value;

            }
        }

        private string _CheckList_by_column3 = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsCheckList_by_column3")]
        [LocalizedWebDescriptionAttribute("_SettingsCheckList_by_column3")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Search Panel")]
        public string CheckList_by_column3
        {
            get
            {
                return _CheckList_by_column3;
            }
            set
            {
                _CheckList_by_column3 = value;

            }
        }

        //------------------------------



        private string _JSDrowDetailInfoAddressUrl = @"/_layouts/15/Sazmanyar.GoogleMapOffline/Script/js/DrowDetailInfo.js";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsJSDrowDetailInfoAddressUrl")]
        [LocalizedWebDescriptionAttribute("_SettingsJSDrowDetailInfoAddressUrl")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Search Panel")]
        public string JSDrowDetailInfoAddressUrl
        {
            get
            {
                return _JSDrowDetailInfoAddressUrl;
            }
            set
            {
                _JSDrowDetailInfoAddressUrl = value;

            }
        }


        private string _SearchResultField1 = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsSearchResultField1")]
        [LocalizedWebDescriptionAttribute("_SettingsSearchResultField1")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Search Panel")]
        public string SearchResultField1
        {
            get
            {
                return _SearchResultField1;
            }
            set
            {
                _SearchResultField1 = value;

            }
        }


        private string _SearchResultField2 = "";
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsSearchResultField2")]
        [LocalizedWebDescriptionAttribute("_SettingsSearchResultField2")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Search Panel")]
        public string SearchResultField2
        {
            get
            {
                return _SearchResultField2;
            }
            set
            {
                _SearchResultField2 = value;

            }
        }

        private int _MaxSearchResult = 10;
        [WebBrowsable(true)]
        [LocalizedWebDisplayNameAttribute("_SettingsMaxSearchResult")]
        [LocalizedWebDescriptionAttribute("_SettingsMaxSearchResult")]
        [Personalizable(PersonalizationScope.User)]
        [Category("Search Panel")]
        public int MaxSearchResult
        {
            get
            {
                return _MaxSearchResult;
            }
            set
            {
                _MaxSearchResult = value;

            }
        }



        #endregion

        private void _CreateChildControls()
        {
            FilteredGoogleMapOfflineWebpartUserControl objFilteredGoogleMapOfflineWebpartUserControl = (FilteredGoogleMapOfflineWebpartUserControl)Page.LoadControl(Url_ascxPath);

            objFilteredGoogleMapOfflineWebpartUserControl.BaseWebUrlInfo = BaseWebUrlInfo;
            objFilteredGoogleMapOfflineWebpartUserControl.ListName = ListName;

            objFilteredGoogleMapOfflineWebpartUserControl.ListUrlHelper1 = ListUrlHelper1;
            objFilteredGoogleMapOfflineWebpartUserControl.ListUrlHelper2 = ListUrlHelper2;
            objFilteredGoogleMapOfflineWebpartUserControl.ListUrlHelper3 = ListUrlHelper3;
            objFilteredGoogleMapOfflineWebpartUserControl.ListUrlHelper4 = ListUrlHelper4;
            objFilteredGoogleMapOfflineWebpartUserControl.ListUrlHelper5 = ListUrlHelper5;
            objFilteredGoogleMapOfflineWebpartUserControl.View_name = View_name;

            objFilteredGoogleMapOfflineWebpartUserControl.TitleField = TitleField;
            objFilteredGoogleMapOfflineWebpartUserControl.LatField = LatField;
            objFilteredGoogleMapOfflineWebpartUserControl.LongField = LongField;
            objFilteredGoogleMapOfflineWebpartUserControl.IsCenField = IsCenField;
            objFilteredGoogleMapOfflineWebpartUserControl.StateField = StateField;

            objFilteredGoogleMapOfflineWebpartUserControl.ShowByAdminPrevilage = ShowByAdminPrevilage;
            objFilteredGoogleMapOfflineWebpartUserControl.enableScrollWheelZoom = enableScrollWheelZoom;
            objFilteredGoogleMapOfflineWebpartUserControl.navigationControl = navigationControl;
            objFilteredGoogleMapOfflineWebpartUserControl.scaleControl = scaleControl;
            objFilteredGoogleMapOfflineWebpartUserControl.draggable = draggable;
            objFilteredGoogleMapOfflineWebpartUserControl.ShowContextMenu = ShowContextMenu;
            objFilteredGoogleMapOfflineWebpartUserControl.ZoomLevel = ZoomLevel;

            objFilteredGoogleMapOfflineWebpartUserControl.MarkerIcon_X = MarkerIcon_X;
            objFilteredGoogleMapOfflineWebpartUserControl.MarkerIcon_Y = MarkerIcon_Y;

            objFilteredGoogleMapOfflineWebpartUserControl.MarkerShadowIcon_X = MarkerShadowIcon_X;
            objFilteredGoogleMapOfflineWebpartUserControl.MarkerShadowIcon_Y = MarkerShadowIcon_Y;

            objFilteredGoogleMapOfflineWebpartUserControl.MarkerAnchorIcon_X = MarkerAnchorIcon_X;
            objFilteredGoogleMapOfflineWebpartUserControl.MarkerAnchorIcon_Y = MarkerAnchorIcon_Y;

            objFilteredGoogleMapOfflineWebpartUserControl.InfoWindowAnchor_X = InfoWindowAnchor_X;
            objFilteredGoogleMapOfflineWebpartUserControl.InfoWindowAnchor_Y = InfoWindowAnchor_Y;

            objFilteredGoogleMapOfflineWebpartUserControl.Adress_Of_Image_Location = Adress_Of_Image_Location;
            objFilteredGoogleMapOfflineWebpartUserControl.JSDrowDetailInfoAddressUrl = JSDrowDetailInfoAddressUrl;

            objFilteredGoogleMapOfflineWebpartUserControl.mininumLevel = mininumLevel;
            objFilteredGoogleMapOfflineWebpartUserControl.maxinumLevel = maxinumLevel;
            objFilteredGoogleMapOfflineWebpartUserControl.ShowAllMarkerForFirstTime = ShowAllMarkerForFirstTime;
            objFilteredGoogleMapOfflineWebpartUserControl.RelationalColumnForloadInMapPoint = RelationalColumnForloadInMapPoint;

            objFilteredGoogleMapOfflineWebpartUserControl.UseNewVersion = UseNewVersion;

            objFilteredGoogleMapOfflineWebpartUserControl.Filtered_In_QueryString = Filtered_In_QueryString;
            objFilteredGoogleMapOfflineWebpartUserControl.SearchResultField1 = SearchResultField1;
            objFilteredGoogleMapOfflineWebpartUserControl.SearchResultField2 = SearchResultField2;
            objFilteredGoogleMapOfflineWebpartUserControl.ShowSearchPanel = ShowSearchPanel;
            objFilteredGoogleMapOfflineWebpartUserControl.MaxSearchResult = MaxSearchResult;
            objFilteredGoogleMapOfflineWebpartUserControl.filterd_by_column1 = filterd_by_column1;
            objFilteredGoogleMapOfflineWebpartUserControl.filterd_by_column2 = filterd_by_column2;
            objFilteredGoogleMapOfflineWebpartUserControl.filterd_by_column3 = filterd_by_column3;
            objFilteredGoogleMapOfflineWebpartUserControl.Searched_by_column1 = Searched_by_column1;
            objFilteredGoogleMapOfflineWebpartUserControl.Searched_by_column2 = Searched_by_column2;
            objFilteredGoogleMapOfflineWebpartUserControl.Searched_by_column3 = Searched_by_column3;
            objFilteredGoogleMapOfflineWebpartUserControl.CheckList_by_column1 = CheckList_by_column1;
            objFilteredGoogleMapOfflineWebpartUserControl.CheckList_by_column2 = CheckList_by_column2;
            objFilteredGoogleMapOfflineWebpartUserControl.CheckList_by_column3 = CheckList_by_column3;

            objFilteredGoogleMapOfflineWebpartUserControl.ShouldRemovedFromBaseUrl = ShouldRemovedFromBaseUrl;
            objFilteredGoogleMapOfflineWebpartUserControl.JSDrowMarkerAddressUrl = JSDrowMarkerAddressUrl;

            objFilteredGoogleMapOfflineWebpartUserControl.IsOuterJoin = IsOuterJoin;
            objFilteredGoogleMapOfflineWebpartUserControl.SqlQueryViewName = SqlQueryViewName;
            objFilteredGoogleMapOfflineWebpartUserControl.SqlQueryConnectionString = SqlQueryConnectionString;
            objFilteredGoogleMapOfflineWebpartUserControl.RelationalColumnBetweenListsAndViews = RelationalColumnBetweenListsAndViews;

            //objFilteredGoogleMapOfflineWebpartUserControl.Height = this.Height;
            //objFilteredGoogleMapOfflineWebpartUserControl.Width = this.Width;

            Controls.Add(objFilteredGoogleMapOfflineWebpartUserControl);
        }
    }
}
