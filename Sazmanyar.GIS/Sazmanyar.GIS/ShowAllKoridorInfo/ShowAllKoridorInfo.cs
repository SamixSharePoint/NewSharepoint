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

        #region "تنظیمات ویژه"

        private string _ascxPath = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت )")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت )")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات ویژه")]
        public string ascxPath
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

        private string _ascxPathForNew = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl_New.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - New)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - New)")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات ویژه")]
        public string ascxPathForNew
        {
            get
            {
                return _ascxPathForNew;
            }
            set
            {
                _ascxPathForNew = value;
            }
        }

        private string _ascxPathForBonyad = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl_Bonyad.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - Bonyad)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - Bonyad)")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات ویژه")]
        public string ascxPathForBonyad
        {
            get
            {
                return _ascxPathForBonyad;
            }
            set
            {
                _ascxPathForBonyad = value;
            }
        }

        private string _ascxPathForAbOBargh = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl_AbOBargh.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - کاربر نهایی جدید)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - کاربر نهایی جدید)")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات ویژه")]
        public string ascxPathForAbOBargh
        {
            get
            {
                return _ascxPathForAbOBargh;
            }
            set
            {
                _ascxPathForAbOBargh = value;
            }
        }


        private string _ascxPathForEndUser = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl_endUser.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - endUser)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - endUser)")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات ویژه")]
        public string ascxPathForEndUser
        {
            get
            {
                return _ascxPathForEndUser;
            }
            set
            {
                _ascxPathForEndUser = value;
            }
        }


        private string _ascxPathForAdmin = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl_admin.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - admin)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - admin)")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات ویژه")]
        public string ascxPathForAdmin
        {
            get
            {
                return _ascxPathForAdmin;
            }
            set
            {
                _ascxPathForAdmin = value;
            }
        }

        private string _ascxPathForAdminLeaflet = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl_adminLeaflet.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - admin (نقشهء رایگان Leaflet)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - admin (نقشهء رایگان Leaflet، بدون نیاز به کلید/Billing گوگل)")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات ویژه")]
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

        private string _ascxPathForTajamoee = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllKoridorInfo/ShowAllKoridorInfoUserControl_NewTajamoee.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - NewTajamoee)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - NewTajamoee)")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات ویژه")]
        public string ascxPathForTajamoee
        {
            get
            {
                return _ascxPathForTajamoee;
            }
            set
            {
                _ascxPathForTajamoee = value;
            }
        }

        private ClsHelpper.FormModeRouteOfStation _FormMode = ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface_AbOBargh;
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
                if (FormMode == ClsHelpper.FormModeRouteOfStation.InAdminMode)
                {
                    ShowAllKoridorInfoUserControl_admin objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl_admin)Page.LoadControl(ascxPathForAdmin);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
                else if (FormMode == ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface)
                {
                    ShowAllKoridorInfoUserControl objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl)Page.LoadControl(ascxPath);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
                else if (FormMode == ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface_New)
                {
                    ShowAllKoridorInfoUserControl_New objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl_New)Page.LoadControl(ascxPathForNew);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
                else if (FormMode == ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface_Bonyad)
                {
                    ShowAllKoridorInfoUserControl_Bonyad objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl_Bonyad)Page.LoadControl(ascxPathForBonyad);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
                else if (FormMode == ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface_AbOBargh)
                {
                    ShowAllKoridorInfoUserControl_AbOBargh objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl_AbOBargh)Page.LoadControl(ascxPathForAbOBargh);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
                else if (FormMode == ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface_EndUser)
                {
                    ShowAllKoridorInfoUserControl_endUser objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl_endUser)Page.LoadControl(ascxPathForEndUser);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
                else if (FormMode == ClsHelpper.FormModeRouteOfStation.InEndUserModeWithInterface_Admin)
                {
                    ShowAllKoridorInfoUserControl_admin objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl_admin)Page.LoadControl(ascxPathForAdmin);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
                else if (FormMode == ClsHelpper.FormModeRouteOfStation.InEndUserModePathForTajamoee)
                {
                    ShowAllKoridorInfoUserControl_NewTajamoee objShowInNewsLetterFormatUserControl = (ShowAllKoridorInfoUserControl_NewTajamoee)Page.LoadControl(_ascxPathForTajamoee);
                    objShowInNewsLetterFormatUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
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
