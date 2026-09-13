using System;
using System.ComponentModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using Microsoft.SharePoint;
using Microsoft.SharePoint.WebControls;

namespace Sazmanyar.GIS.ShowAllPolyganInfo
{
    [ToolboxItemAttribute(false)]
    public class ShowAllPolyganInfo : WebPart
    {
        // Visual Studio might automatically update this path when you change the Visual Web Part project item.
        private string _ascxPathForEndUser = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllPolyganInfo/ShowAllPolyganInfoUserControl_EndUser.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - کاربر نهایی)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - کاربر نهایی)")]
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

        private string _ascxPathForAdmin = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllPolyganInfo/ShowAllPolyganInfoUserControl_admin.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت - ادمین)")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت - ادمین)")]
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


        private ClsHelpper.FormModePolyganOfStation _FormMode = ClsHelpper.FormModePolyganOfStation.InAdminMode;
        [WebBrowsable(true)]
        [WebDisplayName("نحوهء نمایش اطلاعات بر روی صفحه؟")]
        [WebDescription("نحوهء نمایش اطلاعات بر روی صفحه؟")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات ویژه")]
        public ClsHelpper.FormModePolyganOfStation FormMode
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

        protected override void CreateChildControls()
        {
            if (this.Page.Header == null)
            {
                return;
            }

            try
            {
                if (FormMode == ClsHelpper.FormModePolyganOfStation.InAdminMode)
                {
                    ShowAllPolyganInfoUserControl_admin objShowInNewsLetterFormatUserControl = (ShowAllPolyganInfoUserControl_admin)Page.LoadControl(ascxPathForAdmin);
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
                else if (FormMode == ClsHelpper.FormModePolyganOfStation.InEndUserModeWithInterface)
                {
                    ShowAllPolyganInfoUserControl_EndUser objShowInNewsLetterFormatUserControl = (ShowAllPolyganInfoUserControl_EndUser)Page.LoadControl(ascxPathForEndUser);
                    Controls.Add(objShowInNewsLetterFormatUserControl);
                }
            }
            catch (Exception)
            {

            }
        }
    }
}
