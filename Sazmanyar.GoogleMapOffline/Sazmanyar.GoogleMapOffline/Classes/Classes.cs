using Microsoft.SharePoint.Utilities;
using Microsoft.SharePoint;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;

namespace Sazmanyar.GoogleMapOffline.Classes
{
    public class HelperClass
    {
        /// <summary>
        /// مختصات را همیشه با نقطهٔ اعشار برای جاوااسکریپت برمی‌گرداند. ToString پیش‌فرض از فرهنگ وب
        /// پیروی می‌کند (مثلاً «34,87») و new GLatLng(34,87,51,10) نقشه را در حلقهٔ بی‌پایان می‌اندازد.
        /// </summary>
        public static string ToInvariantNumber(object value)
        {
            if (value == null || value == DBNull.Value)
            {
                return "";
            }

            if (value is double)
            {
                return ((double)value).ToString("R", CultureInfo.InvariantCulture);
            }

            if (value is float)
            {
                return ((float)value).ToString("R", CultureInfo.InvariantCulture);
            }

            if (value is decimal)
            {
                return ((decimal)value).ToString(CultureInfo.InvariantCulture);
            }

            string text = value.ToString().Trim();
            StringBuilder normalized = new StringBuilder(text.Length);
            foreach (char c in text)
            {
                if (c >= '۰' && c <= '۹')
                {
                    normalized.Append((char)('0' + (c - '۰')));
                }
                else if (c >= '٠' && c <= '٩')
                {
                    normalized.Append((char)('0' + (c - '٠')));
                }
                else if (c == ',' || c == '/' || c == '٫')
                {
                    normalized.Append('.');
                }
                else
                {
                    normalized.Append(c);
                }
            }

            double parsed;
            if (double.TryParse(normalized.ToString(), NumberStyles.Float, CultureInfo.InvariantCulture, out parsed))
            {
                return parsed.ToString("R", CultureInfo.InvariantCulture);
            }

            return text;
        }


        static public string getLocalizedValue(string strInput)
        {
            // Function to retreive specified Language Variation Value
            string strLocalizedValue = "";

            //strLocalizedValue = SPUtils.clsHelper.getLocalizedValue(strInput, "Sazmanyar.GoogleMapOffline");
            strLocalizedValue = SPUtility.GetLocalizedString("$Resources:" + strInput, "Sazmanyar.GoogleMapOffline\\Resources", (uint)System.Threading.Thread.CurrentThread.CurrentCulture.LCID);

            return strLocalizedValue;
        }


        public static DataTable GetFilteredDataSource(DataTable objDataTableDetailInfo, string BaseWebUrlInfo, string ListName, string strfilterd_by_column, ref string strTitle, ref string strError)
        {
            try
            {
                DataTable objResultData = new DataTable();

                if (strfilterd_by_column.ToString().Trim().Length == 0)
                {
                    strError = "نام ستون جهت دسته بندی تعیین نشده است";
                    return null;
                }

                if (ListName.ToString().Trim().Length == 0)
                {
                    strError = "نام لیست اطلاعات تعیین نشده است";
                    return null;
                }

                SPListCollection lists = null;
                SPWeb CurrentWeb = SPContext.Current.Web;
                String strSiteUrl = SPContext.Current.Web.Site.Url;
                if ((BaseWebUrlInfo != "/") && (BaseWebUrlInfo != ""))
                {
                    try
                    {
                        SPSecurity.RunWithElevatedPrivileges(
                        delegate ()
                        {
                            using (SPSite TempCurrentSite = new SPSite(BaseWebUrlInfo))
                            {
                                CurrentWeb = TempCurrentSite.OpenWeb(BaseWebUrlInfo.Replace(TempCurrentSite.Url.ToString(), ""));
                            }
                        });
                    }
                    catch (Exception)
                    { }

                }

                SPSecurity.RunWithElevatedPrivileges(
                               delegate ()
                               {
                                   using (SPSite CurrentSite = new SPSite(CurrentWeb.Site.ID))
                                   {
                                       using (SPWeb web = CurrentSite.OpenWeb(CurrentWeb.ID))
                                       {
                                           lists = web.Lists;
                                       }
                                   }
                               }
                       );

                foreach (SPList list in lists)
                {
                    if (list.Title.Trim().ToLowerInvariant() == ListName.Trim().ToLowerInvariant())
                    {
                        return GetFilteredDataSource(objDataTableDetailInfo, list, strfilterd_by_column, ref strTitle, ref strError);
                    }
                }
                strError = "اطلاعات لیست  پیدا نشده است";
            }
            catch (Exception ex)
            {
                strError = "خطای ناشناخته در هنگام واکشی اطلاعات دسته بندی موجود می باشد";
            }

            return null;
        }

        public static DataTable GetFilteredDataSource(DataTable objDataTableDetailInfo, SPList objlist, string strfilterd_by_column, ref string strTitle, ref string strError)
        {
            try
            {
                DataTable objResultData = new DataTable();

                if (strfilterd_by_column.ToString().Trim().Length == 0)
                {
                    strError = "نام ستون جهت دسته بندی تعیین نشده است";
                    return null;
                }

                if (objlist == null)
                {
                    strError = "اطلاعات لیست  پیدا نشده است";
                    return null;
                }


                if (objlist.Items.Count == 0)
                {
                    return null;
                }

                try
                {
                    string[] strColName = { strfilterd_by_column };
                    //پیدا کردن فیلد در داخل لیست
                    foreach (SPField field in objlist.Fields)
                    {

                        if (field.InternalName.Trim() == strfilterd_by_column.Trim())
                        {
                            strTitle = field.Title;

                            DataTable objDataTable = objlist.Items.GetDataTable();
                            strError = "";
                            objResultData = objDataTable.DefaultView.ToTable(true, strColName);
                            return objResultData;
                        }
                    }

                    //پیدا کردن فیلد در داخل جدول
                    if (objDataTableDetailInfo.Columns.Contains(strfilterd_by_column) == true)
                    {
                        strError = "";
                        strTitle = strfilterd_by_column;
                        DataView objDataViewTemp = new DataView(objDataTableDetailInfo);
                        return objDataViewTemp.ToTable(true, strColName);
                    }

                    //فیلد مورد نظر درست نمی باشد
                    throw new Exception();

                }
                catch (Exception)
                {
                    strError = "اطلاعات یکی از ستون ها" + strfilterd_by_column + " در دسته بندی صحیح نمی باشد";
                    return null;
                }
            }
            catch (Exception ex)
            {
                strError = "خطای ناشناخته در هنگام واکشی اطلاعات دسته بندی موجود می باشد";
            }

            return null;
        }

        public static string GetDefaultEditFormUrl(string SubSiteUrl, string ListName)
        {
            if (ListName.Trim().Length == 0)
            {
                return "";
            }

            try
            {
                SPListCollection lists = null;
                SPWeb CurrentWeb = new SPSite(SPContext.Current.Site.ID).OpenWeb(SubSiteUrl);
                SPSecurity.RunWithElevatedPrivileges(
                              delegate ()
                              {
                                  using (SPSite CurrentSite = new SPSite(CurrentWeb.Site.ID))
                                  {
                                      using (SPWeb web = CurrentSite.OpenWeb(CurrentWeb.ID))
                                      {
                                          lists = web.Lists;
                                      }
                                  }
                              }
                      );

                foreach (SPList list in lists)
                {
                    if (list.Title.Trim().ToLowerInvariant() == ListName.Trim().ToLowerInvariant())
                    {
                        return list.DefaultEditFormUrl;
                    }
                }

            }
            catch (Exception ex)
            {

            }
            return "";
        }

        /// <summary>
        /// عنوان نمایشی (Title) یک ستون لیست را از روی نام داخلی یا نام نمایشی آن برمی‌گرداند؛
        /// اگر لیست یا ستون پیدا نشد همان مقدار ورودی برگردانده می‌شود تا برچسب خالی نماند.
        /// </summary>
        public static string GetFieldTitle(string BaseWebUrlInfo, string strListName, string strName)
        {
            if (strListName.Trim().Length == 0 || strName.Trim().Length == 0)
            {
                return strName;
            }

            string strTitle = strName;
            try
            {
                SPWeb CurrentWeb = SPContext.Current.Web;
                if ((BaseWebUrlInfo != "/") && (BaseWebUrlInfo != ""))
                {
                    try
                    {
                        SPSecurity.RunWithElevatedPrivileges(
                        delegate ()
                        {
                            using (SPSite TempCurrentSite = new SPSite(BaseWebUrlInfo))
                            {
                                CurrentWeb = TempCurrentSite.OpenWeb(BaseWebUrlInfo.Replace(TempCurrentSite.Url.ToString(), ""));
                            }
                        });
                    }
                    catch (Exception)
                    { }
                }

                SPSecurity.RunWithElevatedPrivileges(
                delegate ()
                {
                    using (SPSite CurrentSite = new SPSite(CurrentWeb.Site.ID))
                    {
                        using (SPWeb web = CurrentSite.OpenWeb(CurrentWeb.ID))
                        {
                            foreach (SPList list in web.Lists)
                            {
                                if (list.Title.Trim().ToLowerInvariant() == strListName.Trim().ToLowerInvariant())
                                {
                                    SPField field = list.Fields.GetField(strName.Trim());
                                    if (field != null && field.Title.Trim().Length > 0)
                                    {
                                        strTitle = field.Title;
                                    }
                                    return;
                                }
                            }
                        }
                    }
                });
            }
            catch (Exception)
            {
            }

            return strTitle;
        }

        public static string GetInternalName(string SubSiteUrl, string strListName, string strName)
        {
            if (strListName.Trim().Length == 0)
            {
                return "";
            }

            if (strName.Trim().Length == 0)
            {
                return "";
            }

            string strInternalName = "";
            SPWeb CurrentWeb = new SPSite(SPContext.Current.Site.ID).OpenWeb(SubSiteUrl);
            SPSecurity.RunWithElevatedPrivileges(
                               delegate ()
                               {
                                   using (SPSite CurrentSite = new SPSite(CurrentWeb.Site.ID))
                                   {
                                       using (SPWeb web = CurrentSite.OpenWeb(CurrentWeb.ID))
                                       {
                                           SPListCollection lists = web.Lists;

                                           foreach (SPList list in lists)
                                           {
                                               if (list.Title.Trim().ToLowerInvariant() == strListName.Trim().ToLowerInvariant())
                                               {
                                                   strInternalName = list.Fields.GetField(strName).InternalName;
                                                   return;
                                               }
                                           }
                                       }
                                   }
                               }
                       );

            return strInternalName;
        }

        public static DataTable Join(DataTable First, DataTable Second, DataColumn[] FJC, DataColumn[] SJC)
        {

            //Create Empty Table

            DataTable table = new DataTable("Join");

            // Use a DataSet to leverage DataRelation

            using (DataSet ds = new DataSet())
            {

                //Add Copy of Tables

                ds.Tables.AddRange(new DataTable[] { First.Copy(), Second.Copy() });

                //Identify Joining Columns from First

                DataColumn[] parentcolumns = new DataColumn[FJC.Length];

                for (int i = 0; i < parentcolumns.Length; i++)
                {

                    parentcolumns[i] = ds.Tables[0].Columns[FJC[i].ColumnName];

                }

                //Identify Joining Columns from Second

                DataColumn[] childcolumns = new DataColumn[SJC.Length];

                for (int i = 0; i < childcolumns.Length; i++)
                {

                    childcolumns[i] = ds.Tables[1].Columns[SJC[i].ColumnName];

                }

                //Create DataRelation

                DataRelation r = new DataRelation(string.Empty, parentcolumns, childcolumns, false);

                ds.Relations.Add(r);

                //Create Columns for JOIN table

                for (int i = 0; i < First.Columns.Count; i++)
                {

                    table.Columns.Add(First.Columns[i].ColumnName, First.Columns[i].DataType);

                }

                for (int i = 0; i < Second.Columns.Count; i++)
                {

                    //Beware Duplicates

                    if (!table.Columns.Contains(Second.Columns[i].ColumnName))

                        table.Columns.Add(Second.Columns[i].ColumnName, Second.Columns[i].DataType);

                    else

                        table.Columns.Add(Second.Columns[i].ColumnName + "_Second", Second.Columns[i].DataType);

                }

                //Loop through First table

                table.BeginLoadData();

                foreach (DataRow firstrow in ds.Tables[0].Rows)
                {

                    //Get "joined" rows

                    DataRow[] childrows = firstrow.GetChildRows(r);

                    if (childrows != null && childrows.Length > 0)
                    {

                        object[] parentarray = firstrow.ItemArray;

                        foreach (DataRow secondrow in childrows)
                        {

                            object[] secondarray = secondrow.ItemArray;

                            object[] joinarray = new object[parentarray.Length + secondarray.Length];

                            Array.Copy(parentarray, 0, joinarray, 0, parentarray.Length);

                            Array.Copy(secondarray, 0, joinarray, parentarray.Length, secondarray.Length);

                            table.LoadDataRow(joinarray, true);

                        }

                    }

                }

                table.EndLoadData();

            }

            return table;

        }

        public static DataTable Join(DataTable First, DataTable Second, DataColumn FJC, DataColumn SJC)
        {

            return Join(First, Second, new DataColumn[] { FJC }, new DataColumn[] { SJC });
        }

        public static DataTable Join(DataTable First, DataTable Second, string FJC, string SJC)
        {
            if (First.Columns.Contains(FJC) == false || Second.Columns.Contains(SJC) == false)
            {
                return null;
            }

            return Join(First, Second, new DataColumn[] { First.Columns[FJC] }, new DataColumn[] { Second.Columns[SJC] });
        }

        public static string TarikhEmrooz(int nDayGHablBad)
        {
            DateTime objDateBase = DateTime.Now.AddDays(nDayGHablBad);
            PersianCalendar persianCalendar = new PersianCalendar();
            int year = persianCalendar.GetYear(objDateBase);
            string str1 = year.ToString();
            year = persianCalendar.GetMonth(objDateBase);
            string str2 = year.ToString();
            year = persianCalendar.GetDayOfMonth(objDateBase);
            string str3 = year.ToString();
            if (str2.Length == 1)
            {
                str2 = string.Concat("0", str2);
            }
            if (str3.Length == 1)
            {
                str3 = string.Concat("0", str3);
            }
            string[] strArrays = new string[5];
            strArrays[0] = str1;
            strArrays[1] = "/";
            strArrays[2] = str2;
            strArrays[3] = "/";
            strArrays[4] = str3;
            return string.Concat(strArrays);

        }

        public static void LogExeption(Exception ex)
        {
            try
            {
                SPWeb CurrentWeb = SPContext.Current.Web;
                SPSecurity.RunWithElevatedPrivileges(
                                                         delegate ()
                                                         {
                                                             using (SPSite mySourceSite = new SPSite(CurrentWeb.Site.ID))
                                                             {

                                                                 System.Diagnostics.EventLog eventLog = new System.Diagnostics.EventLog();
                                                                 eventLog.Source = "SPW.Webpart.MasafatYab";
                                                                 eventLog.WriteEntry(ex.Message);
                                                             }
                                                         });
            }
            catch (Exception)
            {
            }
        }

        public static void GetListItemsAsString(
                                 string SqlQueryViewName,
                                 string SqlQueryConnectionString,
                                 Guid SiteID,
                                 string RelationalColumnBetweenListsAndViews,
                                 Boolean IsOuterJoin,
                                 SPList objBaseList,
                                 string ViewName,
                                 Boolean ShowByAdminPrevilage,
                                 string LatField,
                                 string LongField,
                                 string StateField,
                                 string IsCenField,
                                 string ShouldRemovedFromBaseUrl,
                                 string RelationalColumnForloadInMapPoint,
                                 string cmbMarekerFilter1_SelectedValue,
                                 string cmbMarekerFilter2_SelectedValue,
                                 string cmbMarekerFilter3_SelectedValue,
                                 string txtMarekerSearch1_TextValue,
                                 string txtMarekerSearch2_TextValue,
                                 string txtMarekerSearch3_TextValue,
                                 string chlMarekerCheckList1_SelectedValues,
                                 string chlMarekerCheckList2_SelectedValues,
                                 string chlMarekerCheckList3_SelectedValues,
                                 string filterd_by_column1,
                                 string filterd_by_column2,
                                 string filterd_by_column3,
                                 string Searched_by_column1,
                                 string Searched_by_column2,
                                 string Searched_by_column3,
                                 string CheckList_by_column1,
                                 string CheckList_by_column2,
                                 string CheckList_by_column3,
                                 ref string BasejsArray,
                                 ref string BasejsCenter,
                                 string Filterd_In_QueryStringName,
                                 string Filterd_In_QueryStringValue
           )
        {

            DataTable objDetailInfo = HelperClass.Get_DetailInfoFromSqlView(SqlQueryViewName, SqlQueryConnectionString, SiteID);

            GetListItemsAsString(objDetailInfo, RelationalColumnBetweenListsAndViews, IsOuterJoin, objBaseList, ViewName, ShowByAdminPrevilage, LatField, LongField, StateField, IsCenField, ShouldRemovedFromBaseUrl,
                                                RelationalColumnForloadInMapPoint, cmbMarekerFilter1_SelectedValue, cmbMarekerFilter2_SelectedValue, cmbMarekerFilter3_SelectedValue,
                                                txtMarekerSearch1_TextValue, txtMarekerSearch2_TextValue, txtMarekerSearch3_TextValue,
                                                chlMarekerCheckList1_SelectedValues, chlMarekerCheckList2_SelectedValues, chlMarekerCheckList3_SelectedValues,
                                                filterd_by_column1, filterd_by_column2, filterd_by_column3,
                                                Searched_by_column1, Searched_by_column2, Searched_by_column3,
                                                CheckList_by_column1, CheckList_by_column2, CheckList_by_column3,
                                                ref BasejsArray, ref BasejsCenter, Filterd_In_QueryStringName, Filterd_In_QueryStringValue);
        }

        public static void GetListItemsAsString(
                                 DataTable objDetailInfo,
                                 string RelationalColumnBetweenListsAndViews,
                                 Boolean IsOuterJoin,
                                 SPList objBaseList,
                                 string ViewName,
                                 Boolean ShowByAdminPrevilage,
                                 string LatField,
                                 string LongField,
                                 string StateField,
                                 string IsCenField,
                                 string ShouldRemovedFromBaseUrl,
                                 string RelationalColumnForloadInMapPoint,
                                 string cmbMarekerFilter1_SelectedValue,
                                 string cmbMarekerFilter2_SelectedValue,
                                 string cmbMarekerFilter3_SelectedValue,
                                 string txtMarekerSearch1_TextValue,
                                 string txtMarekerSearch2_TextValue,
                                 string txtMarekerSearch3_TextValue,
                                 string chlMarekerCheckList1_SelectedValues,
                                 string chlMarekerCheckList2_SelectedValues,
                                 string chlMarekerCheckList3_SelectedValues,
                                 string filterd_by_column1,
                                 string filterd_by_column2,
                                 string filterd_by_column3,
                                 string Searched_by_column1,
                                 string Searched_by_column2,
                                 string Searched_by_column3,
                                 string CheckList_by_column1,
                                 string CheckList_by_column2,
                                 string CheckList_by_column3,
                                 ref string BasejsArray,
                                 ref string BasejsCenter,
                                 string Filterd_In_QueryStringName,
                                 string Filterd_In_QueryStringValue
           )
        {

            string TempjsArray = BasejsArray;
            string TempjsCenter = BasejsCenter;

            try
            {



                if (objBaseList == null)
                {
                    return;
                }

                SPList objList = null;
                SPWeb CurrentWeb = objBaseList.ParentWeb;
                Guid strListGUID = objBaseList.ID;

                if (ShowByAdminPrevilage == true)
                {
                    SPSecurity.RunWithElevatedPrivileges(
                               delegate ()
                               {
                                   using (SPSite CurrentSite = new SPSite(CurrentWeb.Site.ID))
                                   {
                                       using (SPWeb web = CurrentSite.OpenWeb(CurrentWeb.ID))
                                       {
                                           objList = web.Lists[strListGUID];
                                       }
                                   }
                               }
                       );
                }
                else
                {
                    using (SPSite CurrentSite = new SPSite(CurrentWeb.Site.ID))
                    {
                        using (SPWeb web = CurrentSite.OpenWeb(CurrentWeb.ID))
                        {
                            objList = web.Lists[strListGUID];
                        }
                    }
                }


                if (objList.Items.Count == 0)
                {
                    //اگر آیتمی در لیست وجود نداشت از آن خارج شود
                    return;
                }

                int nCounterItems = 0;
                if (TempjsArray.Trim().Length > 0)
                {
                    if (TempjsArray.Replace(" ", "").ToString() != "[]")
                    {
                        nCounterItems = 1;
                    }
                    TempjsArray = TempjsArray.Substring(0, TempjsArray.LastIndexOf(']'));
                }
                else
                {
                    TempjsArray += "  [";
                }

                SPListItemCollection objSPListItemCollection = null;
                if (ViewName.Trim().Length > 0)
                {
                    try
                    {
                        SPView objSPView = objList.Views[ViewName];
                        SPQuery objSPQuery = new SPQuery(objSPView);
                        objSPQuery.RowLimit = 0;
                        objSPListItemCollection = objList.GetItems(objSPQuery);
                        //objSPListItemCollection = list.GetItems(list.Views[ViewName]);
                    }
                    catch (Exception)
                    {
                    }
                }

                if (objSPListItemCollection == null)
                {
                    objSPListItemCollection = objList.GetItems();
                }

                if (objSPListItemCollection.Count < 1)
                {
                    return;
                }

                DataView objResultView = null;
                DataTable objResultDatatble = objSPListItemCollection.GetDataTable();

                if (objDetailInfo != null && objDetailInfo.Rows.Count > 0 && RelationalColumnBetweenListsAndViews.Trim().Length > 0)
                {
                    if (objResultDatatble.Rows.Count > 0)
                    {
                        DataTable objResultDatatbleTemp = Join(objResultDatatble, objDetailInfo, RelationalColumnBetweenListsAndViews, RelationalColumnBetweenListsAndViews);
                        if (objResultDatatbleTemp != null && objResultDatatbleTemp.Rows.Count > 0)
                        {
                            DataView objResultDatatbleTempView = new DataView(objResultDatatbleTemp);
                            if (IsOuterJoin == true)
                            {
                                foreach (DataRow objDataRowItem in objResultDatatble.Rows)
                                {
                                    objResultDatatbleTempView.RowFilter = " ID = " + objDataRowItem["ID"].ToString();
                                    if (objResultDatatbleTempView.Count == 0)
                                    {
                                        DataRow objExtendedDataRow = objResultDatatbleTemp.NewRow();
                                        foreach (DataColumn objColitem in objResultDatatble.Columns)
                                        {
                                            objExtendedDataRow[objColitem.ColumnName] = objDataRowItem[objColitem.ColumnName];
                                        } // end foreach
                                        objResultDatatbleTemp.Rows.Add(objExtendedDataRow);
                                    }
                                } // end foreach
                            }
                            objResultDatatble = objResultDatatbleTemp;
                        }
                        else
                        {
                            if (IsOuterJoin == false)
                            {
                                //تمامی ردیف هارا پاک می کنیم
                                objResultDatatble.Clear();
                            }
                        }
                    }

                    objResultView = objResultDatatble.DefaultView;
                }
                else
                {
                    objResultView = objResultDatatble.DefaultView;
                }

                //اطلاعات مربوط به فیلد های خاص را درست کنیم
                foreach (SPField objSPField in objList.Fields)
                {
                    switch (objSPField.Type)
                    {
                        case SPFieldType.Text:
                        case SPFieldType.Note:
                        case SPFieldType.Choice:
                        case SPFieldType.MultiChoice:
                            try
                            {
                                foreach (DataRowView item in objResultView)
                                {
                                    item[objSPField.InternalName] = (((item[objSPField.InternalName].ToString().Length < 1) || (item[objSPField.InternalName] == null)) ? "" : item[objSPField.InternalName].ToString().Replace(Microsoft.VisualBasic.ControlChars.NewLine, "<br/>").Replace("\r\n", "<br/>").Replace("'", "").Replace("\\", "___").Replace("/*", "").Replace("*/", ""));
                                }
                            }
                            catch (Exception ex)
                            {
                            }
                            break;
                        case SPFieldType.URL:
                            try
                            {
                                foreach (DataRowView item in objResultView)
                                {
                                    item[objSPField.InternalName] = (((item[objSPField.InternalName].ToString().Length < 1) || (item[objSPField.InternalName] == null)) ? "" : (new SPFieldUrlValue(item[objSPField.InternalName].ToString())).Url.Replace("'", ""));
                                    if (ShouldRemovedFromBaseUrl.Trim().Length > 0)
                                    {
                                        item[objSPField.InternalName] = item[objSPField.InternalName].ToString().Replace(ShouldRemovedFromBaseUrl, "");
                                    }
                                }
                            }
                            catch (Exception ex)
                            {

                            }
                            break;

                        default:

                            break;
                    }
                }

                string strFilter = "";

                //جستجو بر اساس اطلاعات متنی
                if ((!string.IsNullOrEmpty(txtMarekerSearch1_TextValue)) && txtMarekerSearch1_TextValue.Trim().Length != 0 && Searched_by_column1.Trim().Length > 0)
                {
                    if (strFilter.Trim().Length != 0)
                    {
                        strFilter = strFilter + " AND ";
                    }

                    strFilter = strFilter + Searched_by_column1 + " like '%" + txtMarekerSearch1_TextValue + "%' ";
                }

                if ((!string.IsNullOrEmpty(txtMarekerSearch2_TextValue)) && txtMarekerSearch2_TextValue.Trim().Length != 0 && Searched_by_column2.Trim().Length > 0)
                {
                    if (strFilter.Trim().Length != 0)
                    {
                        strFilter = strFilter + " AND ";
                    }

                    strFilter = strFilter + Searched_by_column2 + " like '%" + txtMarekerSearch2_TextValue + "%' ";
                }

                if ((!string.IsNullOrEmpty(txtMarekerSearch3_TextValue)) && txtMarekerSearch3_TextValue.Trim().Length != 0 && Searched_by_column3.Trim().Length > 0)
                {
                    if (strFilter.Trim().Length != 0)
                    {
                        strFilter = strFilter + " AND ";
                    }

                    strFilter = strFilter + Searched_by_column3 + " like '%" + txtMarekerSearch3_TextValue + "%' ";
                }

                if (Filterd_In_QueryStringName.Trim().Length > 0 && Filterd_In_QueryStringValue.Trim().Length > 0)
                {
                    try
                    {
                        //ممکن است فیلد وجود نداشته باشد
                        if (objResultView.Table.Columns.Contains(Filterd_In_QueryStringName) == true)
                        {
                            if (strFilter.Trim().Length != 0)
                            {
                                strFilter = strFilter + " AND ";
                            }

                            strFilter = strFilter + Filterd_In_QueryStringName + " like '%" + Filterd_In_QueryStringValue + "%' ";
                        }
                        else
                        {
                            strFilter = strFilter + " AND (1 = 2) ";  //هیچ داده ای لود نکند
                        }
                    }
                    catch
                    {

                    }

                }

                objResultView.RowFilter = strFilter;
                DataTable objResult = objResultView.ToTable();

                foreach (DataRow item in objResult.Rows)
                {

                    if ((!string.IsNullOrEmpty(cmbMarekerFilter1_SelectedValue)) && cmbMarekerFilter1_SelectedValue.Trim().Length != 0 && filterd_by_column1.Trim().Length > 0)
                    {
                        if ((item[filterd_by_column1] == null) || ((item[filterd_by_column1] != null) && (item[filterd_by_column1].ToString() != cmbMarekerFilter1_SelectedValue)))
                        {
                            //در گروه اول نمی باشد
                            continue;
                        }
                    }

                    if ((!string.IsNullOrEmpty(cmbMarekerFilter2_SelectedValue)) && cmbMarekerFilter2_SelectedValue.Trim().Length != 0 && filterd_by_column2.Trim().Length > 0)
                    {
                        if ((item[filterd_by_column2] == null) || ((item[filterd_by_column2] != null) && (item[filterd_by_column2].ToString() != cmbMarekerFilter2_SelectedValue)))
                        {
                            //در گروه دوم نمی باشد
                            continue;
                        }
                    }


                    if ((!string.IsNullOrEmpty(cmbMarekerFilter3_SelectedValue)) && cmbMarekerFilter3_SelectedValue.Trim().Length != 0 && filterd_by_column3.Trim().Length > 0)
                    {
                        if ((item[filterd_by_column3] == null) || ((item[filterd_by_column3] != null) && (item[filterd_by_column3].ToString() != cmbMarekerFilter3_SelectedValue)))
                        {
                            //در گروه سوم نمی باشد
                            continue;
                        }
                    }


                    if ((!string.IsNullOrEmpty(chlMarekerCheckList1_SelectedValues)) && chlMarekerCheckList1_SelectedValues.Trim().Length != 0 && CheckList_by_column1.Trim().Length > 0)
                    {
                        if ((item[CheckList_by_column1] == null))
                        {
                            //در انتخاب اول نمی باشد
                            continue;
                        }
                        else
                        {
                            Boolean bFounded = false;
                            string[] splitSepetator = { "#@#" };
                            string[] strVales = chlMarekerCheckList1_SelectedValues.Split(splitSepetator, StringSplitOptions.RemoveEmptyEntries);
                            foreach (string itemValue in strVales)
                            {
                                if (item[CheckList_by_column1].ToString() == itemValue)
                                {
                                    bFounded = true;
                                    break;
                                }
                            }

                            if (bFounded == false)
                            {
                                //در انتخاب اول نمی باشد
                                continue;
                            }
                        }
                    }

                    if ((!string.IsNullOrEmpty(chlMarekerCheckList2_SelectedValues)) && chlMarekerCheckList2_SelectedValues.Trim().Length != 0 && CheckList_by_column2.Trim().Length > 0)
                    {
                        if ((item[CheckList_by_column2] == null))
                        {
                            //در انتخاب اول نمی باشد
                            continue;
                        }
                        else
                        {
                            Boolean bFounded = false;
                            string[] splitSepetator = { "#@#" };
                            string[] strVales = chlMarekerCheckList2_SelectedValues.Split(splitSepetator, StringSplitOptions.RemoveEmptyEntries);
                            foreach (string itemValue in strVales)
                            {
                                if (item[CheckList_by_column2].ToString() == itemValue)
                                {
                                    bFounded = true;
                                    break;
                                }
                            }

                            if (bFounded == false)
                            {
                                //در انتخاب اول نمی باشد
                                continue;
                            }
                        }
                    }


                    if ((!string.IsNullOrEmpty(chlMarekerCheckList3_SelectedValues)) && chlMarekerCheckList3_SelectedValues.Trim().Length != 0 && CheckList_by_column3.Trim().Length > 0)
                    {
                        if ((item[CheckList_by_column3] == null))
                        {
                            //در انتخاب اول نمی باشد
                            continue;
                        }
                        else
                        {
                            Boolean bFounded = false;
                            string[] splitSepetator = { "#@#" };
                            string[] strVales = chlMarekerCheckList3_SelectedValues.Split(splitSepetator, StringSplitOptions.RemoveEmptyEntries);
                            foreach (string itemValue in strVales)
                            {
                                if (item[CheckList_by_column3].ToString() == itemValue)
                                {
                                    bFounded = true;
                                    break;
                                }
                            }

                            if (bFounded == false)
                            {
                                //در انتخاب اول نمی باشد
                                continue;
                            }
                        }
                    }


                    string _IDValue = (item["ID"] == null) ? "" : item["ID"].ToString();
                    string _LatValue = ToInvariantNumber(item[LatField]);
                    string _LongValue = ToInvariantNumber(item[LongField]);
                    string jsCenterBuffer = (item[IsCenField] == null) ? "" : item[IsCenField].ToString().ToLower();
                    string State = (item[StateField] == null) ? "" : item[StateField].ToString();

                    if (nCounterItems != 0)
                    {
                        TempjsArray += " , ";
                    }
                    nCounterItems = nCounterItems + 1;

                    TempjsArray += "{\"ID\" : \"" + _IDValue + "\"  ";
                    TempjsArray += " ,\"" + LatField + "\" : \"" + _LatValue + "\"   ";
                    TempjsArray += " ,\"" + LongField + "\" : \"" + _LongValue + "\"   ";
                    TempjsArray += " ,\"" + IsCenField + "\" : \"" + jsCenterBuffer + "\" ";
                    TempjsArray += " ,\"" + StateField + "\" : \"" + State + "\" ";

                    List<string> RelationalColumnForloadInMapPointArray = new List<string>();
                    if (RelationalColumnForloadInMapPoint.Trim().Length > 0 && RelationalColumnForloadInMapPoint.Contains(','))
                    {
                        RelationalColumnForloadInMapPointArray = RelationalColumnForloadInMapPoint.Split(',').ToList();
                    }

                    foreach (DataColumn objSPField in item.Table.Columns)
                    {
                        if (objSPField.ColumnName == "ID" || objSPField.ColumnName == LatField || objSPField.ColumnName == LongField || objSPField.ColumnName == IsCenField)
                        {
                            continue;
                        }

                        if (RelationalColumnForloadInMapPointArray.Count > 0)
                        {
                            if (RelationalColumnForloadInMapPointArray.Contains(objSPField.ColumnName) == false)
                            {
                                continue;
                            }
                        }

                        TempjsArray += " , ";
                        TempjsArray += " \"" + objSPField.ColumnName + "\" : ";
                        TempjsArray += " \"" + (((item[objSPField.ColumnName].ToString().Length < 1) || (item[objSPField.ColumnName] == null)) ? "" : item[objSPField.ColumnName].ToString()) + "\" ";
                    }

                    TempjsArray += "}";

                    if (jsCenterBuffer == "true" && string.IsNullOrEmpty(TempjsCenter))
                        TempjsCenter += "new google.maps.LatLng(" + _LatValue + "," + _LongValue + ")";

                }

                if (string.IsNullOrEmpty(TempjsCenter))
                {
                    if (objResult.Rows.Count > 0)
                    {
                        string _LatValue = ToInvariantNumber(objResult.Rows[0][LatField]);
                        string _LongValue = ToInvariantNumber(objResult.Rows[0][LongField]);
                        TempjsCenter += "new google.maps.LatLng(" + _LatValue + "," + _LongValue + ")";
                    }
                }
                TempjsArray = TempjsArray.TrimEnd(',');
                TempjsArray += "]";


                BasejsArray = TempjsArray;
                BasejsCenter = TempjsCenter;
            }
            catch (Exception ex)
            {
            }
        }

        public static DataTable Get_DetailInfoFromSqlView(string SqlQueryViewName, string SqlQueryConnectionString, Guid SiteID)
        {
            DataTable objDataTableDetailInfo = null;

            try
            {
                if (SqlQueryViewName.Trim().Length > 0)
                {
                    SPSecurity.RunWithElevatedPrivileges(
                                                             delegate ()
                                                             {
                                                                 using (SPSite mySourceSite = new SPSite(SiteID))
                                                                 {
                                                                     if (SqlQueryConnectionString.Trim().Length == 0)
                                                                     {
                                                                         SqlQueryConnectionString = mySourceSite.ContentDatabase.DatabaseConnectionString;
                                                                     }
                                                                     using (SqlCommand cmd = new SqlCommand(SqlQueryViewName, new SqlConnection(SqlQueryConnectionString)))
                                                                     {
                                                                         SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(cmd);
                                                                         objDataTableDetailInfo = new DataTable("DetailInfo");
                                                                         objSqlDataAdapter.Fill(objDataTableDetailInfo);
                                                                     }
                                                                 }
                                                             });
                }
            }
            catch (Exception ex)
            {
                HelperClass.LogExeption(ex);
            }

            return objDataTableDetailInfo;
        }
    }
}
