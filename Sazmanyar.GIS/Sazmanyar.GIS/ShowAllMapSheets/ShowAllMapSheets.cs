using System;
using System.ComponentModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using Microsoft.SharePoint;
using Microsoft.SharePoint.WebControls;

namespace Sazmanyar.GIS.ShowAllMapSheets
{
    /// <summary>
    /// وب‌پارت برگه‌های نقشه (جدول dbo.MapSheets، اسکریپت Database\MapSheets.sql).
    /// الگو: ShowAllPolyganInfo با دو کنترل:
    ///   * ادمین: بارگذاری ZIP شامل Shapefile (shp/dbf/prj/cpg)، ثبت در MapSheets و مدیریت Importها
    ///   * کاربر نهایی: نمایش برگه‌های ثبت‌شده روی نقشه به همراه پروژهء متصل از PWAInfo (کلید: ProjectCode)
    /// </summary>
    [ToolboxItemAttribute(false)]
    public class ShowAllMapSheets : WebPart
    {
        // Visual Studio might automatically update this path when you change the Visual Web Part project item.
        private string _ascxPathForEndUser = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllMapSheets/ShowAllMapSheetsUserControl_EndUser.ascx";
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

        private string _ascxPathForAdmin = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllMapSheets/ShowAllMapSheetsUserControl_admin.ascx";
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

        private ClsHelpper.FormModeMapSheets _FormMode = ClsHelpper.FormModeMapSheets.InAdminMode;
        [WebBrowsable(true)]
        [WebDisplayName("نحوهء نمایش اطلاعات بر روی صفحه؟")]
        [WebDescription("ادمین: بارگذاری ZIP و مدیریت Importها - کاربر نهایی: فقط نمایش برگه‌های ثبت‌شده")]
        [Personalizable(PersonalizationScope.User)]
        [Category("تنظیمات ویژه")]
        public ClsHelpper.FormModeMapSheets FormMode
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
                if (FormMode == ClsHelpper.FormModeMapSheets.InAdminMode)
                {
                    ShowAllMapSheetsUserControl_admin objControl = (ShowAllMapSheetsUserControl_admin)Page.LoadControl(ascxPathForAdmin);
                    Controls.Add(objControl);
                }
                else if (FormMode == ClsHelpper.FormModeMapSheets.InEndUserModeWithInterface)
                {
                    ShowAllMapSheetsUserControl_EndUser objControl = (ShowAllMapSheetsUserControl_EndUser)Page.LoadControl(ascxPathForEndUser);
                    Controls.Add(objControl);
                }
            }
            catch (Exception ex)
            {
                ClsHelpper.WriteToLogFile("ShowAllMapSheets.CreateChildControls: " + ex.Message);
            }
        }
    }
}
