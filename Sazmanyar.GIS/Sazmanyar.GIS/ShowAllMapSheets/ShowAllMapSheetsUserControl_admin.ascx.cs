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

namespace Sazmanyar.GIS.ShowAllMapSheets
{
    /// <summary>
    /// حالت ادمین وب‌پارت برگه‌های نقشه: بارگذاری ZIP (Shapefile) و ثبت در dbo.MapSheets + مدیریت Importها.
    /// خواندن فایل در ClsShapefile (بدون پایگاه داده) و ثبت در ClsHelpper.ImportMapSheets انجام می‌شود.
    /// </summary>
    public partial class ShowAllMapSheetsUserControl_admin : UserControl
    {
        #region Events

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                // آپلود فایل به فرم multipart نیاز دارد (مسترپیج‌های SharePoint این را دارند؛ برای اطمینان)
                if (Page.Form != null)
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

            BindBatches();
        }

        protected void btnImport_Click(object sender, EventArgs e)
        {
            StringBuilder sb = new StringBuilder();
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
                hdnFocusBatch.Value = objImport.Batch.ToString();

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
                ClsHelpper.WriteToLogFile("ShowAllMapSheetsUserControl_admin.btnImport_Click: " + ex.Message);
                litResult.Text = "<div class='ms-err'>خطا در بارگذاری: " + HttpUtility.HtmlEncode(ex.Message) + "</div>" + sb.ToString();
            }

            BindBatches();
        }

        protected void rptBatches_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                if (e.CommandName == "DeleteBatch")
                {
                    string strBatch = Convert.ToString(e.CommandArgument);
                    int nDeleted = ClsHelpper.DeleteMapSheetsImportBatch(strBatch);
                    if (nDeleted < 0)
                    {
                        litResult.Text = "<div class='ms-err'>حذف انجام نشد.</div>";
                    }
                    else
                    {
                        litResult.Text = "<div class='ms-ok'>" + nDeleted + " برگه حذف شد.</div>";
                    }
                    if (string.Equals(hdnFocusBatch.Value, strBatch, StringComparison.OrdinalIgnoreCase))
                    {
                        hdnFocusBatch.Value = "";
                    }
                }
            }
            catch (Exception ex)
            {
                ClsHelpper.WriteToLogFile("ShowAllMapSheetsUserControl_admin.rptBatches_ItemCommand: " + ex.Message);
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
                ClsHelpper.WriteToLogFile("ShowAllMapSheetsUserControl_admin.BindBatches: " + ex.Message);
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
