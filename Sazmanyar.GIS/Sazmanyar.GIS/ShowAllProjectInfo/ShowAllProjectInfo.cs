using System;
using System.ComponentModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using Microsoft.SharePoint;
using Microsoft.SharePoint.WebControls;

namespace Sazmanyar.GIS.ShowAllProjectInfo
{
    /// <summary>
    /// وب‌پارت نقشهء پروژه‌های Project Web App.
    /// داده از جدول dbo.PWAInfo (Database\PWAInfo.sql) خوانده می‌شود. الگوی رابط کاربری از
    /// ShowAllKoridorInfoUserControl_ViewTemplate1 گرفته شده: کمبوی «دپارتمان» به «نوع پروژه» و
    /// فیلد «نام پروژه» به «منطقه پروژه» تبدیل شده است.
    /// </summary>
    [ToolboxItemAttribute(false)]
    public class ShowAllProjectInfo : WebPart
    {
        // Visual Studio might automatically update this path when you change the Visual Web Part project item.
        private string _ascxPath = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllProjectInfo/ShowAllProjectInfoUserControl.ascx";
        [WebBrowsable(true)]
        [WebDisplayName("مسیر کنترل اصلی کل وب پارت")]
        [WebDescription("مسیر کنترل اصلی کل وب پارت")]
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

        private string _InitializeLatLngCamaSemicalonSeperated = "39.027719, 44.736328;26.745610, 62.050781";
        [WebBrowsable(true)]
        [WebDisplayName("محدودهء اولیهء نقشه (lat, lng ; lat, lng)")]
        [WebDescription("دو نقطهء گوشهء محدودهء اولیهء نقشه، جداشده با ; (پیش‌فرض: کل ایران)")]
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

        private bool _ShowSheetAreas = false;
        [WebBrowsable(true)]
        [WebDisplayName("نمایش سطح برگه‌های واقعی به‌صورت پیش‌فرض؟")]
        [WebDescription("غیرفعال (پیش‌فرض): فقط پین؛ مرز برگه فقط برای پین انتخاب‌شده کشیده می‌شود. فعال: مرز همهء برگه‌ها با یک ردیف در فهرست. کاربر با چک‌باکس «سطح برگه‌ها» در ریبون می‌تواند عوضش کند.")]
        [Personalizable(PersonalizationScope.Shared)]
        [Category("تنظیمات ویژه")]
        public bool ShowSheetAreas
        {
            get
            {
                return _ShowSheetAreas;
            }
            set
            {
                _ShowSheetAreas = value;
            }
        }

        private bool _EnableClustering = true;
        [WebBrowsable(true)]
        [WebDisplayName("خوشه‌بندی پین‌ها به‌صورت پیش‌فرض فعال باشد؟")]
        [WebDescription("فعال (پیش‌فرض): پین‌های نزدیک به هم در هر زوم یک نشانگر شمارنده می‌شوند. غیرفعال: همهء پین‌ها جدا. کاربر با چک‌باکس «خوشه‌بندی پین‌ها» در ریبون می‌تواند عوضش کند.")]
        [Personalizable(PersonalizationScope.Shared)]
        [Category("تنظیمات ویژه")]
        public bool EnableClustering
        {
            get
            {
                return _EnableClustering;
            }
            set
            {
                _EnableClustering = value;
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
                ShowAllProjectInfoUserControl objUserControl = (ShowAllProjectInfoUserControl)Page.LoadControl(ascxPath);
                objUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                objUserControl.ShowSheetAreas = ShowSheetAreas;
                objUserControl.EnableClustering = EnableClustering;
                Controls.Add(objUserControl);
            }
            catch (Exception ex)
            {
                ClsHelpper.WriteToLogFile("ShowAllProjectInfo.CreateChildControls: " + ex.Message);
            }
        }
    }
}
