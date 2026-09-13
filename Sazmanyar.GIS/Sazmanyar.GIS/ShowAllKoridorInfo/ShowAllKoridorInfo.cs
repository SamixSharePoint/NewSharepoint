using System;
using System.ComponentModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using Microsoft.SharePoint;
using Microsoft.SharePoint.WebControls;

namespace Sazmanyar.GIS.ShowAllKoridorInfo
{
    [ToolboxItemAttribute(false)]
    public class ShowAllKoridorInfo : WebPart
    {

        #region "تنظیمات نمایش (View)"

        private string _ascxPathForViewTemplate1 = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl_ViewTemplate1.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - ViewTemplate1)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - ViewTemplate1)")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات نمایش (View)")]
        public string ascxPathForViewTemplate1
        {
            get
            {
                return _ascxPathForViewTemplate1;
            }
            set
            {
                _ascxPathForViewTemplate1 = value;
            }
        }

        private string _ascxPathForViewTemplate2 = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl_ViewTemplate2.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - ViewTemplate2)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - ViewTemplate2)")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات نمایش (View)")]
        public string ascxPathForViewTemplate2
        {
            get
            {
                return _ascxPathForViewTemplate2;
            }
            set
            {
                _ascxPathForViewTemplate2 = value;
            }
        }

        private string _ascxPathForViewTemplate3 = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl_ViewTemplate3.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - ViewTemplate3)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - ViewTemplate3)")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات نمایش (View)")]
        public string ascxPathForViewTemplate3
        {
            get
            {
                return _ascxPathForViewTemplate3;
            }
            set
            {
                _ascxPathForViewTemplate3 = value;
            }
        }

        private string _ascxPathForViewRouts = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl_ViewRouts.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - ViewRouts)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - ViewRouts)")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات نمایش (View)")]
        public string ascxPathForViewRouts
        {
            get
            {
                return _ascxPathForViewRouts;
            }
            set
            {
                _ascxPathForViewRouts = value;
            }
        }

        private string _ascxPathForViewReport = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl_ViewReport.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - ViewReport (نمایش گزارشات)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - ViewReport (نمایش گزارشات)")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات نمایش (View)")]
        public string ascxPathForViewReport
        {
            get
            {
                return _ascxPathForViewReport;
            }
            set
            {
                _ascxPathForViewReport = value;
            }
        }

        private string _ascxPathForViewTajamoee = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl_ViewTajamoee.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - ViewTajamoee)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - ViewTajamoee)")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات نمایش (View)")]
        public string ascxPathForViewTajamoee
        {
            get
            {
                return _ascxPathForViewTajamoee;
            }
            set
            {
                _ascxPathForViewTajamoee = value;
            }
        }

        #endregion

        #region "تنظیمات مدیریت (Admin)"

        private string _ascxPathForAdminGoogle = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl_adminGoogle.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - admin (نقشهء Google، نیازمند کلید/Billing گوگل)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - admin (نقشهء Google، نیازمند کلید/Billing گوگل)")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات مدیریت (Admin)")]
        public string ascxPathForAdminGoogle
        {
            get
            {
                return _ascxPathForAdminGoogle;
            }
            set
            {
                _ascxPathForAdminGoogle = value;
            }
        }

        private string _GoogleMapsApiKey = "AIzaSyBk2zY1PsSNsYBAFC7Gi-qCbTm4rvvAo_g";
        [WebBrowsable(true)]
        [WebDisplayName("کلید Google Maps API (فقط برای admin - نقشهء Google)")]
        [WebDescription("کلید Google Maps JavaScript API که در کنترل admin (نقشهء Google) استفاده می‌شود؛ باید در پنل Google Cloud با Billing فعال ساخته شود. اگر کلید معتبری ندارید، از کنترل «admin (نقشهء رایگان Leaflet)» استفاده کنید که نیازی به کلید ندارد.")]
        [Personalizable(PersonalizationScope.Shared)]
        [Category("تنظیمات مدیریت (Admin)")]
        public string GoogleMapsApiKey
        {
            get
            {
                return _GoogleMapsApiKey;
            }
            set
            {
                _GoogleMapsApiKey = value;
            }
        }

        private string _ascxPathForAdminLeaflet = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl_adminLeaflet.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - admin (نقشهء رایگان Leaflet)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - admin (نقشهء رایگان Leaflet، بدون نیاز به کلید/Billing گوگل)")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات مدیریت (Admin)")]
        public string ascxPathForAdminLeaflet
        {
            get
            {
                return _ascxPathForAdminLeaflet;
            }
            set
            {
                _ascxPathForAdminLeaflet = value;
            }
        }

        #endregion

        #region "تنظیمات ویژه"

        private ClsHelpper.FormModeRouteOfStation _FormMode = ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface_ViewTemplate1;
        [WebBrowsable(true)]
        [WebDisplayName("نحوهء نمایش اطلاعات بر روی صفحه؟")]
        [WebDescription("نحوهء نمایش اطلاعات بر روی صفحه؟")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات ویژه")]
        public ClsHelpper.FormModeRouteOfStation FormMode
        {
            get
            {
                return _FormMode;
            }
            set
            {
                _FormMode = value;

            }
        }

        private string _InitializeLatLngCamaSemicalonSeperated = @"39.027719, 44.736328;26.745610, 62.050781";
        [WebBrowsable(true)]
        [WebDisplayName("نقاط اولیه مبنای نمایش نقشه ")]
        [WebDescription("نقاط اولیه مبنای نمایش نقشه")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات ویژه")]
        public string InitializeLatLngCamaSemicalonSeperated
        {
            get
            {
                return _InitializeLatLngCamaSemicalonSeperated;
            }
            set
            {
                _InitializeLatLngCamaSemicalonSeperated = value;
            }
        }

        #endregion

        protected override void CreateChildControls()
        {
            if (this.Page.Header == null)
            {
                return;
            }

            try
            {
                if (FormMode == ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface_ViewTemplate1)
                {
                    ShowAllKoridorInfoUserControl_ViewTemplate1 objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl_ViewTemplate1)Page.LoadControl(ascxPathForViewTemplate1);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
                else if (FormMode == ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface_ViewTemplate2)
                {
                    ShowAllKoridorInfoUserControl_ViewTemplate2 objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl_ViewTemplate2)Page.LoadControl(ascxPathForViewTemplate2);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
                else if (FormMode == ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface_ViewTemplate3)
                {
                    ShowAllKoridorInfoUserControl_ViewTemplate3 objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl_ViewTemplate3)Page.LoadControl(ascxPathForViewTemplate3);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
                else if (FormMode == ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface_ViewRouts)
                {
                    ShowAllKoridorInfoUserControl_ViewRouts objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl_ViewRouts)Page.LoadControl(ascxPathForViewRouts);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
                else if (FormMode == ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface_ViewReport)
                {
                    ShowAllKoridorInfoUserControl_ViewReport objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl_ViewReport)Page.LoadControl(ascxPathForViewReport);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
                else if (FormMode == ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface_ViewTajamoee)
                {
                    ShowAllKoridorInfoUserControl_ViewTajamoee objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl_ViewTajamoee)Page.LoadControl(ascxPathForViewTajamoee);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
                else if (FormMode == ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface_AdminGoogle)
                {
                    ShowAllKoridorInfoUserControl_adminGoogle objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl_adminGoogle)Page.LoadControl(ascxPathForAdminGoogle);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                    objShowInNewsLetterFormatUserControl.GoogleMapsApiKey = GoogleMapsApiKey;
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
                else if (FormMode == ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface_AdminLeaflet)
                {
                    ShowAllKoridorInfoUserControl_adminLeaflet objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl_adminLeaflet)Page.LoadControl(ascxPathForAdminLeaflet);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
            }
            catch (Exception)
            {

            }
        }

    }
}
