using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

namespace Sazmanyar.GIS.ShowAllMapSheets
{
    /// <summary>
    /// حالت کاربر نهایی وب‌پارت برگه‌های نقشه: فقط نمایش. همهء کار سمت کلاینت (mapsheets.js) و
    /// وب‌متد FetchMapSheets انجام می‌شود؛ این‌جا چیزی برای اجرا در سرور نیست.
    /// </summary>
    public partial class ShowAllMapSheetsUserControl_EndUser : UserControl
    {
        #region Events

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (IsPostBack == true)
                {
                    return;
                }
            }
            catch (Exception ex)
            {
                ClsHelpper.WriteToLogFile("ShowAllMapSheetsUserControl_EndUser.Page_Load: " + ex.Message);
            }
        }

        #endregion
    }
}
