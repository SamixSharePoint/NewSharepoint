using System;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using Microsoft.SharePoint;
using Sazmanyar.GIS.Helper;

namespace Sazmanyar.GIS.ShowAllMapSheetInfo
{
    /// <summary>
    /// کنترل وب‌پارت برگه‌های نقشه. نمایش و جستجو کاملاً سمت کلاینت (وب‌متد FetchMapSheets) است؛
    /// این کد فقط پنل «ثبت برگه» را اداره می‌کند: بارگذاری ZIP با postback، خواندن با ClsShapefile،
    /// ثبت با ClsHelpper.ImportMapSheets و فهرست/حذف Importها.
    /// </summary>
    public partial class ShowAllMapSheetInfoUserControl : UserControl
    {
        #region Variables
        public string InitializeLatLngCamaSemicalonSeperated = "";
        public bool ShowRegistrationPanel = true;
        #endregion

        #region Events

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                // محدودهء اولیهء نقشه (پیش‌فرض: کل ایران) - همان الگوی ShowAllProjectInfo
                string strPointBase = "new GLatLng(39.027719, 44.736328), new GLatLng(26.745610, 62.050781)";
                if (!string.IsNullOrEmpty(InitializeLatLngCamaSemicalonSeperated) && InitializeLatLngCamaSemicalonSeperated.Split(';').Length > 1)
                {
                    strPointBase = "";
                    foreach (string stritem in InitializeLatLngCamaSemicalonSeperated.Split(';'))
                    {
                        if (strPointBase.Length != 0)
                        {
                            strPointBase = strPointBase + ",";
                        }
                        strPointBase = strPointBase + "new GLatLng(" + stritem + ")";
                    }
                }
                InitializBounds.Text = "<script type='text/javascript'>var bounds = new GLatLngBounds(@);</script>".Replace("@", strPointBase);
            }
            catch (Exception)
            {
            }

            try
            {
                // پنل ثبت فقط برای ادمین
                phRegToggle.Visible = ShowRegistrationPanel;
                pnlRegPanel.Visible = ShowRegistrationPanel;

                // آپلود فایل به فرم multipart نیاز دارد (مسترپیج‌های SharePoint این را دارند؛ برای اطمینان)
                if (ShowRegistrationPanel && Page.Form != null)
                {
                    Page.Form.Enctype = "multipart/form-data";
                }
            }
            catch (Exception)
            {
            }

            if (IsPostBack)
            {
                return;
            }

            if (ShowRegistrationPanel)
            {
                BindBatches();
            }
        }

        protected void btnImport_Click(object sender, EventArgs e)
        {
            StringBuilder sb = new StringBuilder();
            hdnRegOpen.Value = "1";
            try
            {
                if (fupZip == null || !fupZip.HasFile)
                {
                    litResult.Text = "<div class='ms-err'>فایلی انتخاب نشده است.</div>";
                    BindBatches();
                    return;
                }

                string strFileName = Path.GetFileName(fupZip.FileName);
                if (!strFileName.EndsWith(".zip", StringComparison.OrdinalIgnoreCase))
                {
                    litResult.Text = "<div class='ms-err'>فقط فایل ZIP پذیرفته می‌شود.</div>";
                    BindBatches();
                    return;
                }

                // 1) خواندن Shapefile
                ShapefileParseResult objParse = ClsShapefile.ParseZip(fupZip.PostedFile.InputStream);

                foreach (string strMsg in objParse.Messages)
                {
                    sb.Append("<div class='ms-warn'>").Append(HttpUtility.HtmlEncode(strMsg)).Append("</div>");
                }
                foreach (string strErr in objParse.Errors)
                {
                    sb.Append("<div class='ms-err'>").Append(HttpUtility.HtmlEncode(strErr)).Append("</div>");
                }

                if (objParse.HasFatalError || objParse.Records.Count == 0)
                {
                    sb.Insert(0, "<div class='ms-err'><b>هیچ برگه‌ای از فایل «" + HttpUtility.HtmlEncode(strFileName) + "» خوانده نشد.</b></div>");
                    litResult.Text = sb.ToString();
                    BindBatches();
                    return;
                }

                // 2) ثبت در MapSheets
                string strUser = "";
                try
                {
                    strUser = SPContext.Current.Web.CurrentUser.Name;
                }
                catch (Exception)
                {
                }

                ClsHelpper.MapSheetsImportResult objImport = ClsHelpper.ImportMapSheets(objParse.Records, chkOverwrite.Checked, strFileName, strUser);
                hdnFocusBatch.Value = (objImport.Inserted + objImport.Updated) > 0 ? objImport.Batch.ToString() : "";

                string strSummary = "<div class='" + (objImport.Failed == 0 ? "ms-ok" : "ms-err") + "'><b>فایل «" + HttpUtility.HtmlEncode(strFileName) + "»: "
                    + objParse.Records.Count + " برگه خوانده شد - "
                    + objImport.Inserted + " ثبت جدید، " + objImport.Updated + " بازنویسی، " + objImport.Skipped + " تکراری (رد شد)، " + objImport.Failed + " خطا"
                    + (objImport.Unlinked > 0 ? " - " + objImport.Unlinked + " برگه بدون پروژه در PWAInfo" : "")
                    + "</b></div>";

                sb.Insert(0, strSummary);
                sb.Append("<div class='ms-log'>");
                foreach (string strMsg in objImport.Messages)
                {
                    string strCls = strMsg.Contains("خطا") ? "ms-err" : (strMsg.Contains("رد شد") || strMsg.Contains("نیست") || strMsg.Contains("بدون کد") ? "ms-warn" : "ms-ok");
                    sb.Append("<div class='").Append(strCls).Append("'>").Append(HttpUtility.HtmlEncode(strMsg)).Append("</div>");
                }
                sb.Append("</div>");
                litResult.Text = sb.ToString();
            }
            catch (Exception ex)
            {
                ClsHelpper.WriteToLogFile("ShowAllMapSheetInfoUserControl.btnImport_Click: " + ex.Message);
                litResult.Text = "<div class='ms-err'>خطا در بارگذاری: " + HttpUtility.HtmlEncode(ex.Message) + "</div>" + sb.ToString();
            }

            BindBatches();
        }

        protected void rptBatches_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            hdnRegOpen.Value = "1";
            try
            {
                if (e.CommandName == "DeleteBatch")
                {
                    string strBatch = Convert.ToString(e.CommandArgument);
                    int nDeleted = ClsHelpper.DeleteMapSheetsImportBatch(strBatch);
                    litResult.Text = nDeleted < 0
                        ? "<div class='ms-err'>حذف انجام نشد.</div>"
                        : "<div class='ms-ok'>" + nDeleted + " برگه حذف شد.</div>";
                    hdnFocusBatch.Value = "";
                }
            }
            catch (Exception ex)
            {
                ClsHelpper.WriteToLogFile("ShowAllMapSheetInfoUserControl.rptBatches_ItemCommand: " + ex.Message);
                litResult.Text = "<div class='ms-err'>خطا: " + HttpUtility.HtmlEncode(ex.Message) + "</div>";
            }

            BindBatches();
        }

        #endregion

        #region Helpers

        private void BindBatches()
        {
            try
            {
                DataTable objDataTable = ClsHelpper.FetchMapSheetsImportBatches();
                rptBatches.DataSource = objDataTable;
                rptBatches.DataBind();
                pnlNoBatches.Visible = objDataTable.Rows.Count == 0;
            }
            catch (Exception ex)
            {
                ClsHelpper.WriteToLogFile("ShowAllMapSheetInfoUserControl.BindBatches: " + ex.Message);
            }
        }

        /// <summary>تاریخ شمسی + ساعت برای فهرست Importها</summary>
        protected string FormatDate(object oValue)
        {
            try
            {
                if (oValue == null || oValue == DBNull.Value) { return ""; }
                DateTime dt = Convert.ToDateTime(oValue);
                return ClsHelpper.PersianDate(dt) + " " + dt.ToString("HH:mm");
            }
            catch (Exception)
            {
                return Convert.ToString(oValue);
            }
        }

        /// <summary>تعداد برگه‌های بدون پروژه (بدون کد + کد خارج از PWAInfo)</summary>
        protected string BadCount(object oWithoutCode, object oNotInPwa)
        {
            int n = SafeInt(oWithoutCode) + SafeInt(oNotInPwa);
            return n == 0 ? "-" : n.ToString();
        }

        protected string BadClass(object oWithoutCode, object oNotInPwa)
        {
            int n = SafeInt(oWithoutCode) + SafeInt(oNotInPwa);
            return n == 0 ? "ms-num" : "ms-num ms-bad";
        }

        private static int SafeInt(object o)
        {
            try
            {
                if (o == null || o == DBNull.Value) { return 0; }
                return Convert.ToInt32(o);
            }
            catch (Exception)
            {
                return 0;
            }
        }

        #endregion
    }
}
