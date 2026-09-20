using System;
using System.ComponentModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using Microsoft.SharePoint;
using Microsoft.SharePoint.WebControls;

namespace Sazmanyar.GIS.ShowAllMapSheetInfo
{
    /// <summary>
    /// وب‌پارت برگه‌های نقشه (جدول dbo.MapSheets، اسکریپت Database\MapSheets.sql).
    /// الگوی رابط کاربری: ShowAllProjectInfo (ریبون بالای نقشه + پنل کناری). یک کنترل برای همه:
    ///   * پنل «ثبت برگه» (بارگذاری ZIP شامل Shapefile کارفرما و مدیریت Importها) که با خاصیت
    ///     ShowRegistrationPanel برای کاربران نهایی پنهان می‌شود.
    ///   * پنل جستجو (فهرست برگه‌ها) + جستجوی پیشرفته با query-builder (FilterMapSheet.html).
    /// </summary>
    [ToolboxItemAttribute(false)]
    public class ShowAllMapSheetInfo : WebPart
    {
        // Visual Studio might automatically update this path when you change the Visual Web Part project item.
        private string _ascxPath = @"~/_CONTROLTEMPLATES/15/Sazmanyar.GIS/ShowAllMapSheetInfo/ShowAllMapSheetInfoUserControl.ascx";
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

        private bool _ShowRegistrationPanel = true;
        [WebBrowsable(true)]
        [WebDisplayName("نمایش پنل ثبت برگه (بارگذاری ZIP)؟")]
        [WebDescription("فعال: دکمهء «ثبت برگه» در ریبون و پنل بارگذاری Shapefile نمایش داده می‌شود (ادمین). غیرفعال: فقط نمایش و جستجو (کاربر نهایی).")]
        [Personalizable(PersonalizationScope.Shared)]
        [Category("تنظیمات ویژه")]
        public bool ShowRegistrationPanel
        {
            get
            {
                return _ShowRegistrationPanel;
            }
            set
            {
                _ShowRegistrationPanel = value;
            }
        }

        private bool _ShowSheetAreas = false;
        [WebBrowsable(true)]
        [WebDisplayName("نمایش سطح برگه‌ها به‌صورت پیش‌فرض؟")]
        [WebDescription("غیرفعال (پیش‌فرض): فقط پین برگه‌ها؛ سطح فقط برای برگهء انتخاب‌شده کشیده می‌شود. فعال: سطح همهء برگه‌ها. کاربر با چک‌باکس «سطح برگه‌ها» در ریبون می‌تواند عوضش کند.")]
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

        protected override void CreateChildControls()
        {
            if (this.Page.Header == null)
            {
                return;
            }

            try
            {
                ShowAllMapSheetInfoUserControl objUserControl = (ShowAllMapSheetInfoUserControl)Page.LoadControl(ascxPath);
                objUserControl.InitializeLatLngCamaSemicalonSeperated = InitializeLatLngCamaSemicalonSeperated;
                objUserControl.ShowRegistrationPanel = ShowRegistrationPanel;
                objUserControl.ShowSheetAreas = ShowSheetAreas;
                Controls.Add(objUserControl);
            }
            catch (Exception ex)
            {
                ClsHelpper.WriteToLogFile("ShowAllMapSheetInfo.CreateChildControls: " + ex.Message);
            }
        }
    }
}
