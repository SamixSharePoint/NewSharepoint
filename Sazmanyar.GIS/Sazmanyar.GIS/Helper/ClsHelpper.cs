using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Globalization;
using System.Data;
using System.Xml;
using Microsoft.SharePoint;
using System.Reflection;
using System.IO;
using Microsoft.SharePoint.Utilities;
using System.Web.Configuration;
using System.Data.SqlClient;
using Sazmanyar.GIS.Helper;
using System.Xml.Serialization;
using System.Web.Script.Serialization;
using System.Threading;
using System.Security;
using System.Security.Principal;
using System.Text.RegularExpressions;
using System.Web.UI.WebControls;

namespace Sazmanyar.GIS
{
    public static class ClsHelpper
    {
        /// <summary>
        /// عدد اعشاری را همیشه با نقطه و به شکل قابل‌خواندن برای جاوااسکریپت برمی‌گرداند.
        /// ToString پیش‌فرض از فرهنگ وب پیروی می‌کند (مثلاً «34,87» یا «34/87») و سمت کلاینت که
        /// رشته را با ویرگول جدا می‌کند، مختصات خراب می‌گیرد و موتور نقشه قفل می‌کند.
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

            double parsed;
            if (TryParseNumber(value.ToString(), out parsed))
            {
                return parsed.ToString("R", CultureInfo.InvariantCulture);
            }

            return value.ToString().Trim();
        }

        /// <summary>
        /// عدد را مستقل از فرهنگ می‌خواند: جداکنندهٔ اعشار ویرگول، «/» یا «٫» و ارقام فارسی/عربی را هم می‌پذیرد.
        /// </summary>
        public static bool TryParseNumber(string text, out double result)
        {
            result = 0;
            if (string.IsNullOrEmpty(text))
            {
                return false;
            }

            StringBuilder normalized = new StringBuilder(text.Trim().Length);
            foreach (char c in text.Trim())
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
                else if (c == '−')
                {
                    normalized.Append('-');
                }
                else
                {
                    normalized.Append(c);
                }
            }

            return double.TryParse(normalized.ToString(), NumberStyles.Float, CultureInfo.InvariantCulture, out result);
        }


        private static string strconnectionString = "";
        private static Boolean CheckConnection(string connectionString)
        {
            Boolean bResult = false;
            SqlConnection connection = null;

            try
            {
                connection = new SqlConnection(connectionString);
                connection.Open();
                bResult = true;
            }
            catch (Exception)
            {
                Console.WriteLine("Can not connect to the sql server.");
            }
            finally
            {
                if (connection != null && connection.State == ConnectionState.Open)
                {
                    connection.Close();
                }
            }

            return bResult;
        }

        private static string strDataBaseConnectionString()
        {
            if (!CheckConnection(strconnectionString))
            {
                if (CheckConnection(strDataBaseConnectionString1()))
                {
                    strconnectionString = strDataBaseConnectionString1();
                }
                else
                {
                    strconnectionString = strDataBaseConnectionString2();
                }
            }

            return strconnectionString;
        }

        // نکته: کانکشن‌استرینگ دیگر داخل سورس هاردکد نیست و فقط از AppSettings
        // در web.config خوانده می‌شود. باید کلیدهای زیر روی سرور در web.config
        // برنامهء وب SharePoint مربوطه تنظیم شوند، وگرنه این متدها مقدار خالی برمی‌گردانند:
        //   <add key="ConnectionStringRouting1" value="Data Source=...;Initial Catalog=...;User ID=...;Password=..." />
        //   <add key="ConnectionStringRouting2" value="Data Source=...;Initial Catalog=...;User ID=...;Password=..." />
        private static string strDataBaseConnectionString1()
        {
            string connString = null;

            try
            {
                connString = System.Web.Configuration.WebConfigurationManager.AppSettings["ConnectionStringRouting1"];
            }
            catch (Exception)
            {

            }
            return connString;
        }

        private static string strDataBaseConnectionString2()
        {
            string connString = null;

            try
            {
                connString = System.Web.Configuration.WebConfigurationManager.AppSettings["ConnectionStringRouting2"];
            }
            catch (Exception)
            {

            }
            return connString;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="o"></param>
        /// <returns></returns>
        public static DataTable ConvertToDataTable(Object[] array)
        {

            PropertyInfo[] properties = array.GetType().GetElementType().GetProperties();

            DataTable dt = CreateDataTable(properties);

            if (array.Length != 0)
            {

                foreach (object o in array)

                    FillData(properties, dt, o);
            }
            return dt;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="properties"></param>
        /// <returns></returns>

        private static DataTable CreateDataTable(PropertyInfo[] properties)
        {

            DataTable dt = new DataTable();
            DataColumn dc = null;

            foreach (PropertyInfo pi in properties)
            {
                dc = new DataColumn();
                dc.ColumnName = pi.Name;
                dc.DataType = pi.PropertyType;
                dt.Columns.Add(dc);
            }
            return dt;
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="properties"></param>
        /// <param name="dt"></param>
        /// <param name="o"></param>
        private static void FillData(PropertyInfo[] properties, DataTable dt, Object o)
        {
            DataRow dr = dt.NewRow();
            foreach (PropertyInfo pi in properties)
                dr[pi.Name] = pi.GetValue(o, null);
            dt.Rows.Add(dr);
        }


        public const string Const_Radif = "Radif";
        public const string Const_ListStations_Title = "لیست ایستگاه ها";
        public const string Const_ListRouts_Title = "لیست مسیرها";
        public const string Const_ListPolygans_Title = "لیست سطح ها";
        public const string Const_ListProject_Title = "لیست پروژه ها";
        public const string Const_ListReports_Title = "لیست گزارش های طرح";

        public enum FormModeRouteOfStation
        {
            InEndUserMode_ViewTemplate1,
            InEndUserMode_ViewTemplate2,
            InEndUserMode_ViewTemplate3,
            InEndUserMode_ViewRouts,
            InEndUserMode_ViewReport,
            InEndUserMode_ViewTajamoee,
            InAdminMode_AdminGoogle,
            InAdminMode_AdminLeaflet
        }

        public enum FormModePolyganOfStation
        {
            InAdminMode,
            InEndUserModeWithInterface
        }



        #region Function

        public static void WriteToLogFile(string strMEssageToLog)
        {

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
                                                         delegate()
                                                         {
                                                             using (SPSite mySourceSite = new SPSite(CurrentWeb.Site.ID))
                                                             {

                                                                 System.Diagnostics.EventLog eventLog = new System.Diagnostics.EventLog();
                                                                 eventLog.Source = "Sazmanyar.GIS";
                                                                 eventLog.WriteEntry(ex.Message);
                                                             }
                                                         });
            }
            catch (Exception)
            {
            }
        }

        public static string GorgianDate(string strPersianDate, char strInputSep, char strOutputSep)
        {
            try
            {
                PersianCalendar cal = new PersianCalendar();
                DateTime dt = new DateTime(Convert.ToInt16(strPersianDate.Split(strInputSep)[2]), Convert.ToInt16(strPersianDate.Split(strInputSep)[1]), Convert.ToInt16(strPersianDate.Split(strInputSep)[0]), cal);
                string res = "";

                res = dt.Year + strOutputSep.ToString() + dt.Month.ToString().PadLeft(2, '0') + strOutputSep.ToString() + dt.Day.ToString().PadLeft(2, '0');
                return res;
            }
            catch (Exception)
            {

            }

            return strPersianDate;
        }

        public static string GorgianDate(string strPersianDate)
        {
            return GorgianDate(strPersianDate, '/', '-');
        }

        public static string PersianDate(DateTime dtime)
        {
            string res = "";
            PersianCalendar cal = new PersianCalendar();
            res = cal.GetYear(dtime) + "/" + cal.GetMonth(dtime).ToString().PadLeft(2, '0') + "/" + cal.GetDayOfMonth(dtime).ToString().PadLeft(2, '0') + " " + dtime.ToString("t"); ;
            return res;
        }

        public static List<String> GetAllfileInDirectory(string sDir, string strPattern)
        {
            List<String> files = new List<String>();
            try
            {
                foreach (string file in Directory.GetFiles(sDir, strPattern))
                {
                    files.Add(file);
                }
                foreach (string Directoriy in Directory.GetDirectories(sDir))
                {
                    files.AddRange(GetAllfileInDirectory(Directoriy, strPattern));
                }
            }
            catch (System.Exception excpt)
            {

            }

            return files;
        }

        public static KeyValuePair<string, string> GetPicLastFileDorbinInfoWithDate(string strIPInfo, int nMaxNumOfMiniutesAgoForFTPImg, bool bAddNoImageFound)
        {
            KeyValuePair<string, string> objResult = new KeyValuePair<string, string>("", "");
            try
            {
                FileInfo objFileInfo = null;
                string strBaseAddressOfimgesFiles = ""; // ClsHelpper.strBaseAddressOfimgesFiles();

                try
                {
                    if (strIPInfo.Trim().Length > 0)
                    {
                        objFileInfo = Directory.GetFiles(strBaseAddressOfimgesFiles + "\\" + strIPInfo, "*.jpg")
                        .Select(x => new FileInfo(x))
                        .Where(x => ((x.Length > 0) && ((nMaxNumOfMiniutesAgoForFTPImg == 0) || (DateTime.Now - x.LastWriteTime).TotalMinutes <= nMaxNumOfMiniutesAgoForFTPImg)))
                        .OrderByDescending(x => x.LastWriteTime)
                        .FirstOrDefault();
                    }
                }
                catch (Exception)
                {
                }

                if (objFileInfo == null)
                {
                    if (bAddNoImageFound == false)
                    {
                        return objResult;
                    }

                    objFileInfo = Directory.GetFiles(SPUtility.GetGenericSetupPath(@"TEMPLATE\Layouts\Sazmanyar.GIS\NoImageFound\"), "*.jpg")
                    .Select(x => new FileInfo(x)).OrderByDescending(x => x.LastWriteTime).FirstOrDefault();
                }

                string strFullName_ToLower = objFileInfo.FullName.ToLower();
                if (strFullName_ToLower.IndexOf("layouts") != -1)
                {
                    return new KeyValuePair<string, string>(PersianDate(objFileInfo.LastWriteTime) + " - " + objFileInfo.LastWriteTime.ToShortTimeString(), strFullName_ToLower.Substring(strFullName_ToLower.IndexOf("layouts")).Replace("\\", "/").Replace("layouts", "_layouts"));
                }
            }
            catch (Exception)
            {

            }

            return objResult;
        }

        public static object XmlDeserializeFromString(string objectData, Type type)
        {
            var serializer = new XmlSerializer(type);
            object result;

            using (TextReader reader = new StringReader(objectData))
            {
                result = serializer.Deserialize(reader);
            }

            return result;
        }

        public static string Fetch_BaseArrayOfRouteFromCorridorInfoInDataBase(int CorridorInfo_ID)
        {
            string strResult = "";
            //try
            //{
            //    DataTable objResult = new DataTable();
            //    SqlConnection objSqlConnection = new SqlConnection(GetConnectionStringRah141());
            //    objSqlConnection.Open();
            //    try
            //    {
            //        string Strsql = " SELECT Points  FROM CorridorInfo  where ID = " + CorridorInfo_ID.ToString();
            //        SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
            //        objSqlDataAdapter.Fill(objResult);
            //    }
            //    catch (Exception)
            //    {
            //    }

            //    objSqlConnection.Close();
            //    return objResult.Rows[0][0].ToString();

            //}
            //catch (Exception)
            //{

            //}
            return strResult;
        }

        public static DataTable Fetch_BaseArrayOfTradodshomarFromCorridorInfoInDataBase(int CorridorInfo_ID)
        {
            DataTable objResult = new DataTable();

            //            try
            //            {
            //                SqlConnection objSqlConnection = new SqlConnection(GetConnectionStringRah141());
            //                objSqlConnection.Open();
            //                try
            //                {
            //                    string Strsql = @" SELECT TradodShomarInfo.* 
            //                                       FROM CorridorTradodShomarInfo INNER JOIN
            //                                       TradodShomarInfo ON CorridorTradodShomarInfo.Mehvar_ID = TradodShomarInfo.Mehvar_ID 
            //                                       where CorridorInfo_ID = " + CorridorInfo_ID.ToString();
            //                    SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
            //                    objSqlDataAdapter.Fill(objResult);
            //                }
            //                catch (Exception)
            //                {
            //                }

            //                objSqlConnection.Close();
            //            }
            //            catch (Exception)
            //            {

            //            }
            return objResult;
        }

        public static DataTable Fetch_BaseArrayOfCameraFromCorridorInfoInDataBase(int CorridorInfo_ID)
        {
            DataTable objResult = new DataTable();

            //            try
            //            {
            //                SqlConnection objSqlConnection = new SqlConnection(GetConnectionStringRah141());
            //                objSqlConnection.Open();
            //                try
            //                {
            //                    string Strsql = @" SELECT Camera.* 
            //                                       FROM CorridorCameraInfo INNER JOIN
            //                                       Camera ON CorridorCameraInfo.Camera_ID = Camera.id 
            //                                       where CorridorInfo_ID = " + CorridorInfo_ID.ToString();
            //                    SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
            //                    objSqlDataAdapter.Fill(objResult);
            //                }
            //                catch (Exception)
            //                {
            //                }

            //                objSqlConnection.Close();
            //            }
            //            catch (Exception)
            //            {

            //            }
            return objResult;
        }

        public static DataTable FetchAllRouts_FromStations()
        {
            SPWeb objCurrentWeb = SPContext.Current.Web;
            DataTable objResult = new DataTable();
            objResult.Columns.Add("ID");
            objResult.Columns.Add("Value");


            try
            {
                SPList objSPList = null;
                SPListItemCollection objSPListItemCollection = null;

                SPSecurity.RunWithElevatedPrivileges(delegate()
                {
                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                    {
                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                        {
                            try
                            {
                                string strQueryString = "";
                                SPQuery objSPQuery = new SPQuery();
                                objSPQuery.Query = strQueryString;

                                objSPList = objWeb.Lists[Const_ListRouts_Title];
                                objSPListItemCollection = objSPList.GetItems(objSPQuery);

                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }
                        }
                    }
                });

                if (objSPList == null || objSPListItemCollection.Count == 0)
                {
                    return objResult;
                }
                else
                {
                    foreach (SPListItem objSPListItem in objSPListItemCollection)
                    {

                        SPFieldLookupValue objStartStation = new SPFieldLookupValue(objSPListItem[objSPList.Fields.GetFieldByInternalName("StartStation").Id] as String);
                        DataRow objDataRow = objResult.NewRow();
                        objDataRow["ID"] = objStartStation.LookupId;
                        objDataRow["Value"] = objStartStation.LookupValue;
                        objResult.Rows.Add(objDataRow);
                    }
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            return objResult.DefaultView.ToTable(true, new[] { "ID", "Value" });

        }

        public static DataTable FetchAllPolygans()
        {
            SPWeb objCurrentWeb = SPContext.Current.Web;
            DataTable objResult = new DataTable();
            objResult.Columns.Add("ID");
            objResult.Columns.Add("Value");


            try
            {
                SPList objSPList = null;
                SPListItemCollection objSPListItemCollection = null;

                SPSecurity.RunWithElevatedPrivileges(delegate()
                {
                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                    {
                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                        {
                            try
                            {
                                string strQueryString = "";
                                SPQuery objSPQuery = new SPQuery();
                                objSPQuery.Query = strQueryString;

                                objSPList = objWeb.Lists[Const_ListPolygans_Title];
                                objSPListItemCollection = objSPList.GetItems(objSPQuery);

                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }
                        }
                    }
                });

                if (objSPList == null || objSPListItemCollection.Count == 0)
                {
                    return objResult;
                }
                else
                {
                    foreach (SPListItem objSPListItem in objSPListItemCollection)
                    {

                        DataRow objDataRow = objResult.NewRow();
                        objDataRow["Value"] = objSPListItem.Title;
                        objDataRow["ID"] = objSPListItem.ID
                            + "*/*" + Convert.ToString(objSPListItem[objSPList.Fields.GetFieldByInternalName("PolygonPoints").Id])
                            + "*/*" + Convert.ToString(objSPListItem[objSPList.Fields.GetFieldByInternalName("FillColor").Id])
                            + "*/*" + Convert.ToString(objSPListItem[objSPList.Fields.GetFieldByInternalName("BorderColor").Id])
                            + "*/*" + Convert.ToString(objSPListItem[objSPList.Fields.GetFieldByInternalName("Opacity").Id]);

                        objResult.Rows.Add(objDataRow);
                    }
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            return objResult.DefaultView.ToTable(true, new[] { "ID", "Value" });
        }

        public static DataTable FetchAllCoridor_ToCitesByFromStationInfo(string strFromCitesID)
        {
            SPWeb objCurrentWeb = SPContext.Current.Web;
            DataTable objResult = new DataTable();
            objResult.Columns.Add("ID");
            objResult.Columns.Add("Value");

            try
            {
                SPList objSPList = null;
                SPListItemCollection objSPListItemCollection = null;

                SPSecurity.RunWithElevatedPrivileges(delegate()
                {
                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                    {
                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                        {
                            try
                            {
                                string strQueryString = @"                                <Where>
                                                                                                     <Eq>
		                                                                                                    <FieldRef Name='StartStation' LookupId='TRUE'/>
		                                                                                                    <Value Type='Lookup'>" + strFromCitesID + @"</Value>
                                                                                                     </Eq>
                                                                                          </Where>";
                                SPQuery objSPQuery = new SPQuery();
                                objSPQuery.Query = strQueryString;

                                objSPList = objWeb.Lists[Const_ListRouts_Title];
                                objSPListItemCollection = objSPList.GetItems(objSPQuery);

                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }
                        }
                    }
                });

                if (objSPList == null || objSPListItemCollection.Count == 0)
                {
                    return objResult;
                }
                else
                {
                    foreach (SPListItem objSPListItem in objSPListItemCollection)
                    {

                        SPFieldLookupValue objEndStation = new SPFieldLookupValue(objSPListItem[objSPList.Fields.GetFieldByInternalName("EndStation").Id] as String);
                        DataRow objDataRow = objResult.NewRow();
                        objDataRow["ID"] = objEndStation.LookupId;
                        objDataRow["Value"] = objEndStation.LookupValue;
                        objResult.Rows.Add(objDataRow);
                    }
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            return objResult.DefaultView.ToTable(true, new[] { "ID", "Value" });
        }

        public static DataTable FetchAllCoridorInfoFromDataBase_ByListInfo(string str_FromStationID, string str_ToStationID)
        {
            SPWeb objCurrentWeb = SPContext.Current.Web;

            DataTable objResult = new DataTable();
            objResult.Columns.Add("ID");
            objResult.Columns.Add("Title");
            objResult.Columns.Add("StationFrom_ID");
            objResult.Columns.Add("StationFrom_Title");
            objResult.Columns.Add("LatFrom");
            objResult.Columns.Add("LongFrom");
            objResult.Columns.Add("StationTo_ID");
            objResult.Columns.Add("StationTo_Title");
            objResult.Columns.Add("LatTo");
            objResult.Columns.Add("LongTo");
            objResult.Columns.Add("Points");

            objResult.Columns.Add("NumberCore").DefaultValue = 0;
            objResult.Columns.Add("RouteStartDate").DefaultValue = "";
            objResult.Columns.Add("RouteFinishDate").DefaultValue = "";
            objResult.Columns.Add("PlaneDistanceMap").DefaultValue = 0;
            objResult.Columns.Add("PlaneDistanceChart").DefaultValue = 0;
            objResult.Columns.Add("ReduceCore1").DefaultValue = 0;
            objResult.Columns.Add("ReduceCore2").DefaultValue = 0;
            objResult.Columns.Add("Complete").DefaultValue = 0;
            objResult.Columns.Add("Tahaghogh").DefaultValue = 0;
            objResult.Columns.Add("Color").DefaultValue = "Red";



            try
            {
                SPListItemCollection objSPListItemCollectionRoute = null;

                SPSecurity.RunWithElevatedPrivileges(delegate()
                {
                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                    {
                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                        {
                            try
                            {
                                string strQueryString = "";
                                if (str_FromStationID.Trim().Length != 0 && str_ToStationID.Trim().Length == 0)
                                {
                                    strQueryString = @"                                <Where>
                                                                                                         <Eq>
		                                                                                                        <FieldRef Name='StartStation' LookupId='TRUE'/>
		                                                                                                        <Value Type='Lookup'>" + str_FromStationID + @"</Value>
                                                                                                         </Eq>
                                                                                          </Where>";
                                }
                                else if (str_FromStationID.Trim().Length == 0 && str_ToStationID.Trim().Length != 0)
                                {
                                    strQueryString = @"                                <Where>
                                                                                                         <Eq>
		                                                                                                        <FieldRef Name='EndStation' LookupId='TRUE'/>
		                                                                                                        <Value Type='Lookup'>" + str_ToStationID + @"</Value>
                                                                                                         </Eq>

                                                                                          </Where>";
                                }
                                else if (str_FromStationID.Trim().Length != 0 && str_ToStationID.Trim().Length != 0)
                                {
                                    strQueryString = @"                                <Where>
                                                                                                     <And>
                                                                                                         <Eq>
		                                                                                                        <FieldRef Name='StartStation' LookupId='TRUE'/>
		                                                                                                        <Value Type='Lookup'>" + str_FromStationID + @"</Value>
                                                                                                         </Eq>
                                                                                                         <Eq>
		                                                                                                        <FieldRef Name='EndStation' LookupId='TRUE'/>
		                                                                                                        <Value Type='Lookup'>" + str_ToStationID + @"</Value>
                                                                                                         </Eq>
                                                                                                     </And>

                                                                                          </Where>";
                                }



                                SPQuery objSPQuery = new SPQuery();
                                objSPQuery.Query = strQueryString;

                                SPList objSPList = objWeb.Lists[Const_ListRouts_Title];
                                objSPListItemCollectionRoute = objSPList.GetItems(objSPQuery);

                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }
                        }
                    }
                });

                if (objSPListItemCollectionRoute == null || objSPListItemCollectionRoute.Count == 0)
                {
                    return objResult;
                }
                else
                {
                    foreach (SPListItem objSPListItem in objSPListItemCollectionRoute)
                    {
                        try
                        {
                            DataRow objDataRow = objResult.NewRow();

                            objDataRow["ID"] = objSPListItem[objSPListItem.ParentList.Fields.GetFieldByInternalName("ID").Id];
                            objDataRow["Title"] = objSPListItem[objSPListItem.ParentList.Fields.GetFieldByInternalName("Title").Id];
                            objDataRow["Points"] = objSPListItem[objSPListItem.ParentList.Fields.GetFieldByInternalName("Points").Id];

                            if (objDataRow["Points"].ToString().Trim().Length == 0)
                            {
                                //اگر پوینت نداردیم یعنی کریدور نداریم
                                continue;
                            }

                            SPFieldLookupValue objStartStation = new SPFieldLookupValue(objSPListItem[objSPListItem.ParentList.Fields.GetFieldByInternalName("StartStation").Id] as String);
                            objDataRow["StationFrom_ID"] = objStartStation.LookupId;
                            objDataRow["StationFrom_Title"] = objStartStation.LookupValue;


                            try
                            {
                                SPSecurity.RunWithElevatedPrivileges(delegate()
                                {
                                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                                    {
                                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                                        {
                                            try
                                            {
                                                string strQueryString = @"<Where>
                                                                     <Eq>
                                                                             <FieldRef Name='ID' />
                                                                              <Value Type='Counter'>" + objStartStation.LookupId + @"</Value>
                                                                     </Eq>
                                                          </Where>";

                                                SPQuery objSPQuery = new SPQuery();
                                                objSPQuery.Query = strQueryString;

                                                SPList objSPList = objWeb.Lists[Const_ListStations_Title];
                                                SPListItemCollection objSPListItemCollectionFirst = objSPList.GetItems(objSPQuery);

                                                if (objSPListItemCollectionFirst.Count == 1)
                                                {
                                                    objDataRow["LatFrom"] = ToInvariantNumber(objSPListItemCollectionFirst[0][objSPList.Fields.GetFieldByInternalName("Latitude").Id]);
                                                    objDataRow["LongFrom"] = ToInvariantNumber(objSPListItemCollectionFirst[0][objSPList.Fields.GetFieldByInternalName("Longitude").Id]);
                                                }
                                            }
                                            catch (Exception e)
                                            {
                                                ClsHelpper.WriteToLogFile(e.Message);
                                            }
                                        }
                                    }
                                });
                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }

                            SPFieldLookupValue objEndStation = new SPFieldLookupValue(objSPListItem[objSPListItem.ParentList.Fields.GetFieldByInternalName("EndStation").Id] as String);
                            objDataRow["StationTo_ID"] = objEndStation.LookupId;
                            objDataRow["StationTo_Title"] = objEndStation.LookupValue;

                            try
                            {
                                SPSecurity.RunWithElevatedPrivileges(delegate()
                                {
                                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                                    {
                                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                                        {
                                            try
                                            {
                                                string strQueryString = @"<Where>
                                                                     <Eq>
                                                                             <FieldRef Name='ID' />
                                                                              <Value Type='Counter'>" + objEndStation.LookupId + @"</Value>
                                                                     </Eq>
                                                          </Where>";

                                                SPQuery objSPQuery = new SPQuery();
                                                objSPQuery.Query = strQueryString;

                                                SPList objSPList = objWeb.Lists[Const_ListStations_Title];
                                                SPListItemCollection objSPListItemCollectionEnd = objSPList.GetItems(objSPQuery);

                                                if (objSPListItemCollectionEnd.Count == 1)
                                                {
                                                    objDataRow["LatTo"] = ToInvariantNumber(objSPListItemCollectionEnd[0][objSPList.Fields.GetFieldByInternalName("Latitude").Id]);
                                                    objDataRow["LongTo"] = ToInvariantNumber(objSPListItemCollectionEnd[0][objSPList.Fields.GetFieldByInternalName("Longitude").Id]);
                                                }
                                            }
                                            catch (Exception e)
                                            {
                                                ClsHelpper.WriteToLogFile(e.Message);
                                            }
                                        }
                                    }
                                });
                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }

                            objResult.Rows.Add(objDataRow);
                        }
                        catch (Exception e)
                        {
                            ClsHelpper.WriteToLogFile(e.Message);
                        }

                    }
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            return objResult;
        }

        public static DataTable FetchAllCoridorInfoFromDataBase_ByDataBaseInfo(string str_FromStationID, int str_ToStationID)
        {
            DataTable objResult = new DataTable();
            try
            {
                SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString());
                objSqlConnection.Open();
                string Strsql = " SELECT * FROM  GISInfo ";
                string strCondition = "";

                if (str_FromStationID.Trim().Length != 0)
                {
                    strCondition = strCondition + " StationFrom_ID = " + str_FromStationID.ToString();
                }
                if (strCondition.Trim().Length != 0)
                {
                    strCondition = strCondition + " and ";
                }
                if (str_ToStationID.ToString().Trim().Length != 0)
                {
                    strCondition = strCondition + " StationTo_ID = " + str_ToStationID.ToString();
                }

                if (strCondition.Trim().Length != 0)
                {
                    Strsql = Strsql + " where  " + strCondition;
                }
                SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
                objSqlDataAdapter.Fill(objResult);
                objSqlConnection.Close();

            }
            catch (Exception)
            {

            }

            return objResult;
        }

        public static DataTable FetchAllCoridorInfoFromDataBase_ByDataBaseInfo(string strCondition)
        {
            DataTable objResult = new DataTable();
            try
            {
                SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString());
                objSqlConnection.Open();
                string Strsql = " SELECT * FROM  GISInfo ";

                if (strCondition.Trim().Length != 0)
                {
                    Strsql = Strsql + " where  " + strCondition;
                }
                SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
                objSqlDataAdapter.Fill(objResult);
                objSqlConnection.Close();

            }
            catch (Exception)
            {

            }

            return objResult;
        }

        public static DataTable FetchAllCoridorInfoFromDataBase_ByDataBaseInfo(string strCondition, string strSelectQuery)
        {
            DataTable objResult = new DataTable();
            try
            {
                if (strSelectQuery.Length == 0)
                {
                    strSelectQuery = " * ";
                }
                SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString());
                objSqlConnection.Open();
                string Strsql = " SELECT " + strSelectQuery + " FROM  GISInfo ";

                if (strCondition.Trim().Length != 0)
                {
                    Strsql = Strsql + " where  " + strCondition;
                }
                SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
                objSqlDataAdapter.Fill(objResult);
                objSqlConnection.Close();

            }
            catch (Exception)
            {

            }

            return objResult;
        }

        public static DataTable FetchAllCoridorInfoFromDataBase_ByDataBaseInfo_CobinationToFrom(string strCondition)
        {

            strCondition = strCondition.ToLower().Replace("(n'", "(N'").Replace(",n'", ",N'");

            string strCondition_Temp = strCondition;
            List<string> lstFrom = strCondition_Temp.Split(new string[] { "from_" }, StringSplitOptions.None).ToList();
            if (lstFrom.Count > 1)
            {
                for (int nCounter = 1; nCounter < lstFrom.Count; nCounter++)
                {
                    string strItem = lstFrom[nCounter];

                    string firstPart = lstFrom[nCounter - 1].Split(new string[] { "     (((((     " }, StringSplitOptions.None)[lstFrom[nCounter - 1].Split(new string[] { "     (((((     " }, StringSplitOptions.None).Count() - 1];
                    string secondPart = lstFrom[nCounter].Split(new string[] { "     )))))     " }, StringSplitOptions.None)[0];
                    string strSingleCondition = firstPart + "from_" + secondPart;
                    string strReversCondition = strSingleCondition.Replace("from_", "to_");

                    strCondition = strCondition.Replace("     (((((     " + strSingleCondition + "     )))))     ", "((" + strSingleCondition + ") or (" + strReversCondition + "))");

                }
            }

            List<string> lstTo = strCondition_Temp.Split(new string[] { "to_" }, StringSplitOptions.None).ToList();
            if (lstTo.Count > 1)
            {
                for (int nCounter = 1; nCounter < lstTo.Count; nCounter++)
                {
                    string strItem = lstTo[nCounter];

                    string firstPart = lstTo[nCounter - 1].Split(new string[] { "     (((((     " }, StringSplitOptions.None)[lstTo[nCounter - 1].Split(new string[] { "     (((((     " }, StringSplitOptions.None).Count() - 1];
                    string secondPart = lstTo[nCounter].Split(new string[] { "     )))))     " }, StringSplitOptions.None)[0];
                    string strSingleCondition = firstPart + "to_" + secondPart;
                    string strReversCondition = strSingleCondition.Replace("to_", "from_");

                    strCondition = strCondition.Replace("     (((((     " + strSingleCondition + "     )))))     ", "((" + strSingleCondition + ") or (" + strReversCondition + "))");

                }
            }

            DataTable objResult = new DataTable();
            try
            {
                SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString());
                objSqlConnection.Open();
                string Strsql = " SELECT * FROM  GISInfo  where ProgramName is not null  ";

                if (strCondition.Trim().Length != 0)
                {
                    Strsql = Strsql + " and  " + strCondition;
                }
                SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
                objSqlDataAdapter.Fill(objResult);
                objSqlConnection.Close();

            }
            catch (Exception)
            {

            }

            return objResult;
        }

        public static DataTable FetchAllCoridorInfoFromDataBase_BySPDataBaseInfo(string strCondition)
        {


            DataTable objResult = new DataTable();
            try
            {
                if (strCondition.Trim().Length == 0)
                {
                    strCondition = " 1=1 ";
                }
                SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString());
                objSqlConnection.Open();
                string Strsql = "exec dbo.SPGISView_RouteInfo N'" + strCondition.Replace("'", "''") + "' ";


                SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
                objSqlDataAdapter.Fill(objResult);
                objSqlConnection.Close();

            }
            catch (Exception)
            {

            }

            return objResult;
        }

        public static DataTable FetchAllCoridorInfoFromDataBase_BySPDataBaseInfo_CobinationToFrom(string strCondition)
        {
            strCondition = strCondition.ToLower().Replace("(n'", "(N'").Replace(",n'", ",N'");

            string strCondition_Temp = strCondition;
            List<string> lstFrom = strCondition_Temp.Split(new string[] { "from_" }, StringSplitOptions.None).ToList();
            if (lstFrom.Count > 1)
            {
                for (int nCounter = 1; nCounter < lstFrom.Count; nCounter++)
                {
                    string strItem = lstFrom[nCounter];

                    string firstPart = lstFrom[nCounter - 1].Split(new string[] { "     (((((     " }, StringSplitOptions.None)[lstFrom[nCounter - 1].Split(new string[] { "     (((((     " }, StringSplitOptions.None).Count() - 1];
                    string secondPart = lstFrom[nCounter].Split(new string[] { "     )))))     " }, StringSplitOptions.None)[0];
                    string strSingleCondition = firstPart + "from_" + secondPart;
                    string strReversCondition = strSingleCondition.Replace("from_", "to_");

                    strCondition = strCondition.Replace("     (((((     " + strSingleCondition + "     )))))     ", "((" + strSingleCondition + ") or (" + strReversCondition + "))");

                }
            }

            List<string> lstTo = strCondition_Temp.Split(new string[] { "to_" }, StringSplitOptions.None).ToList();
            if (lstTo.Count > 1)
            {
                for (int nCounter = 1; nCounter < lstTo.Count; nCounter++)
                {
                    string strItem = lstTo[nCounter];

                    string firstPart = lstTo[nCounter - 1].Split(new string[] { "     (((((     " }, StringSplitOptions.None)[lstTo[nCounter - 1].Split(new string[] { "     (((((     " }, StringSplitOptions.None).Count() - 1];
                    string secondPart = lstTo[nCounter].Split(new string[] { "     )))))     " }, StringSplitOptions.None)[0];
                    string strSingleCondition = firstPart + "to_" + secondPart;
                    string strReversCondition = strSingleCondition.Replace("to_", "from_");

                    strCondition = strCondition.Replace("     (((((     " + strSingleCondition + "     )))))     ", "((" + strSingleCondition + ") or (" + strReversCondition + "))");

                }
            }

            DataTable objResult = new DataTable();
            try
            {
                if (strCondition.Trim().Length == 0)
                {
                    strCondition = " 1=1 ";
                }
                SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString());
                objSqlConnection.Open();
                string Strsql = "exec dbo.SPGISView_RouteInfo N'" + strCondition.Replace("'", "''") + "' ";


                SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
                objSqlDataAdapter.Fill(objResult);
                objSqlConnection.Close();

            }
            catch (Exception)
            {

            }

            return objResult;
        }


        public static DataTable GetCorrectCameraInfoForCoridor(int nCoridorID, double EnherafMayar_Mohiti_DarCamera)
        {
            //داده های مسیر از پایگاه داده ها واکشی می گردد
            string Effected_BaseArrayOfRoute = Fetch_BaseArrayOfRouteFromCorridorInfoInDataBase(nCoridorID);
            return GetCorrectCameraInfoForCoridor(Effected_BaseArrayOfRoute, EnherafMayar_Mohiti_DarCamera);
        }

        public static DataTable FetchAllCameraFromDataBase()
        {
            DataTable objResult = new DataTable();
            try
            {

                //SqlConnection objSqlConnection = new SqlConnection(GetConnectionStringRah141());
                //objSqlConnection.Open();
                //string Strsql = " SELECT *  FROM Camera";
                //SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
                //objSqlDataAdapter.Fill(objResult);
                //objSqlConnection.Close();

            }
            catch (Exception)
            {

            }

            return objResult;
        }

        public static DataTable GetCorrectCameraInfoForCoridor(string CoridorRoutPoint, double EnherafMayar_Mohiti_DarCamera)
        {
            List<DataRow> objListOfSelectedTradodRows = new List<DataRow>();
            JavaScriptSerializer js = new JavaScriptSerializer();
            clsRouteForJson[] objclsRouteForJson = js.Deserialize<clsRouteForJson[]>(CoridorRoutPoint);

            //داده های ترددشمار از پایگاه داده ها واکشی می گردد
            DataTable objCamera = FetchAllCameraFromDataBase();
            double r_Base = EnherafMayar_Mohiti_DarCamera;
            if (objCamera.Rows.Count > 0)
            {
                if (objclsRouteForJson.Length > 0)
                {
                    for (Int16 nCurentIndex = 0; nCurentIndex < objclsRouteForJson.Length; nCurentIndex++)
                    {
                        double r_BaseLocal = 1000000000;
                        DataRow objNearestTraddodShmar = objCamera.Rows[0];
                        double NearestTraddodShmar_Lat = 0;
                        double NearestTraddodShmar_Long = 0;

                        foreach (DataRow objDataRow in objCamera.Rows)
                        {

                            if (objDataRow["Latitude"] == DBNull.Value)
                            {
                                continue;
                            }
                            if (objDataRow["Longitude"] == DBNull.Value)
                            {
                                continue;
                            }
                            double TraddodShmar_Lat = Convert.ToDouble(objDataRow["Latitude"]);
                            double TraddodShmar_Long = Convert.ToDouble(objDataRow["Longitude"]);

                            NearestTraddodShmar_Lat = Convert.ToDouble(objNearestTraddodShmar["Latitude"]);
                            NearestTraddodShmar_Long = Convert.ToDouble(objNearestTraddodShmar["Longitude"]);

                            double Current_Lat = objclsRouteForJson[nCurentIndex].lat;
                            double Current_Long = objclsRouteForJson[nCurentIndex].lng;


                            double r_Nearest = Math.Sqrt((NearestTraddodShmar_Lat - Current_Lat) * (NearestTraddodShmar_Lat - Current_Lat) + (NearestTraddodShmar_Long - Current_Long) * (NearestTraddodShmar_Long - Current_Long));
                            double r_Current = Math.Sqrt((Current_Lat - TraddodShmar_Lat) * (Current_Lat - TraddodShmar_Lat) + (Current_Long - TraddodShmar_Long) * (Current_Long - TraddodShmar_Long));

                            if (r_Current < r_Nearest)
                            {
                                objNearestTraddodShmar = objDataRow;
                                r_BaseLocal = r_Current;
                            }
                            else
                            {
                                r_BaseLocal = r_Nearest;
                            }
                        }

                        if (r_BaseLocal <= r_Base)
                        {
                            objListOfSelectedTradodRows.Add(objNearestTraddodShmar);
                        }

                    }
                }
            }

            DataTable objResult = objCamera.Clone();
            foreach (DataRow row in objListOfSelectedTradodRows)
            {
                objResult.ImportRow(row);
            }

            return objResult.DefaultView.ToTable(true);
        }

        public static DataTable FetchAllTradodshomarFromDataBase()
        {
            DataTable objResult = new DataTable();
            //try
            //{

            //    SqlConnection objSqlConnection = new SqlConnection(GetConnectionStringRah141());
            //    objSqlConnection.Open();
            //    string Strsql = " SELECT *  FROM TradodShomarInfo";
            //    SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
            //    objSqlDataAdapter.Fill(objResult);
            //    objSqlConnection.Close();

            //}
            //catch (Exception)
            //{

            //}

            return objResult;
        }

        public static DataTable GetCorrectTradodShomarInfoForCoridor(int nCoridorID, double EnherafMayar_Mohiti_DarTradodShomar)
        {
            //داده های مسیر از پایگاه داده ها واکشی می گردد
            string Effected_BaseArrayOfRoute = Fetch_BaseArrayOfRouteFromCorridorInfoInDataBase(nCoridorID);
            return GetCorrectTradodShomarInfoForCoridor(Effected_BaseArrayOfRoute, EnherafMayar_Mohiti_DarTradodShomar);
        }

        public static DataTable GetCorrectTradodShomarInfoForCoridor(string CoridorRoutPoint, double EnherafMayar_Mohiti_DarTradodShomar)
        {

            List<DataRow> objListOfSelectedTradodRows = new List<DataRow>();
            JavaScriptSerializer js = new JavaScriptSerializer();
            clsRouteForJson[] objclsRouteForJson = js.Deserialize<clsRouteForJson[]>(CoridorRoutPoint);

            //داده های ترددشمار از پایگاه داده ها واکشی می گردد
            DataTable objTradodShomar = FetchAllTradodshomarFromDataBase();
            double r_Base = EnherafMayar_Mohiti_DarTradodShomar;
            if (objTradodShomar.Rows.Count > 0)
            {
                if (objclsRouteForJson.Length > 0)
                {
                    for (Int16 nCurentIndex = 0; nCurentIndex < objclsRouteForJson.Length; nCurentIndex++)
                    {
                        double r_BaseLocal = 1000000000;
                        DataRow objNearestTraddodShmar = objTradodShomar.Rows[0];
                        double NearestTraddodShmar_Lat = 0;
                        double NearestTraddodShmar_Long = 0;

                        foreach (DataRow objDataRow in objTradodShomar.Rows)
                        {

                            if (objDataRow["Latitude"] == DBNull.Value)
                            {
                                continue;
                            }
                            if (objDataRow["Longitude"] == DBNull.Value)
                            {
                                continue;
                            }
                            double TraddodShmar_Lat = Convert.ToDouble(objDataRow["Latitude"]);
                            double TraddodShmar_Long = Convert.ToDouble(objDataRow["Longitude"]);

                            NearestTraddodShmar_Lat = Convert.ToDouble(objNearestTraddodShmar["Latitude"]);
                            NearestTraddodShmar_Long = Convert.ToDouble(objNearestTraddodShmar["Longitude"]);

                            double Current_Lat = objclsRouteForJson[nCurentIndex].lat;
                            double Current_Long = objclsRouteForJson[nCurentIndex].lng;


                            double r_Nearest = Math.Sqrt((NearestTraddodShmar_Lat - Current_Lat) * (NearestTraddodShmar_Lat - Current_Lat) + (NearestTraddodShmar_Long - Current_Long) * (NearestTraddodShmar_Long - Current_Long));
                            double r_Current = Math.Sqrt((Current_Lat - TraddodShmar_Lat) * (Current_Lat - TraddodShmar_Lat) + (Current_Long - TraddodShmar_Long) * (Current_Long - TraddodShmar_Long));

                            if (r_Current < r_Nearest)
                            {
                                objNearestTraddodShmar = objDataRow;
                                r_BaseLocal = r_Current;
                            }
                            else
                            {
                                r_BaseLocal = r_Nearest;
                            }
                        }

                        if (r_BaseLocal <= r_Base)
                        {
                            objListOfSelectedTradodRows.Add(objNearestTraddodShmar);
                        }

                    }
                }
            }

            DataTable objResult = objTradodShomar.Clone();
            foreach (DataRow row in objListOfSelectedTradodRows)
            {
                objResult.ImportRow(row);
            }

            return objResult.DefaultView.ToTable(true);
        }

        public static Int64 InsertCoridor_ByListInfo(string strNameCoridor, string strDistance, string strDuration, int nSourse_ID, int nDestination_ID, string ProgramName,
            string strRoutesInfo, string LatNortheast, string LongNortheast, string LatSouthwest, string LongSouthwest, ref Boolean bIsUpdated)
        {
            int nResult = -1;
            int nIDForUpdate = 0;

            SPWeb objCurrentWeb = SPContext.Current.Web;
            try
            {
                SPList objSPList = null;
                SPSecurity.RunWithElevatedPrivileges(delegate()
                {
                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                    {
                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                        {
                            objWeb.AllowUnsafeUpdates = true;
                            try
                            {
                                objSPList = objWeb.Lists[Const_ListRouts_Title];

                                //ابتدا تست می کنیم که با این شروع و پایان باید چیزی بهنگام گردد یا نه
                                try
                                {
                                    string strQueryString = @"                                <Where>
                                                                                                   <And>   
                                                                                                        <And>
                                                                                                             <Eq>
		                                                                                                            <FieldRef Name='StartStation' LookupId='TRUE'/>
		                                                                                                            <Value Type='Lookup'>" + nSourse_ID + @"</Value>
                                                                                                             </Eq>
                                                                                                             <Eq>
		                                                                                                            <FieldRef Name='EndStation' LookupId='TRUE'/>
		                                                                                                            <Value Type='Lookup'>" + nDestination_ID + @"</Value>
                                                                                                             </Eq>
                                                                                                         </And>
                                                                                                         <Eq>
		                                                                                                        <FieldRef Name='ProgramName' LookupId='TRUE'/>
		                                                                                                        <Value Type='Text'>" + ProgramName + @"</Value>
                                                                                                         </Eq>
                                                                                                     </And>
                                                                                          </Where>";
                                    SPQuery objSPQuery = new SPQuery();
                                    objSPQuery.Query = strQueryString;
                                    SPListItemCollection objSPListItemCollectionRoute = objSPList.GetItems(objSPQuery);

                                    if (objSPListItemCollectionRoute.Count > 0)
                                    {
                                        nIDForUpdate = Convert.ToInt32(objSPListItemCollectionRoute[0][objSPList.Fields.GetFieldByInternalName("ID").Id].ToString());
                                    }
                                }
                                catch (Exception)
                                {

                                }

                                SPListItem objSPListItem = null;
                                if (nIDForUpdate > 0)
                                {
                                    objSPListItem = objSPList.GetItemById(nIDForUpdate);
                                }
                                else
                                {
                                    objSPListItem = objSPList.AddItem();
                                }

                                objSPListItem[objSPList.Fields.GetFieldByInternalName("Title").Id] = strNameCoridor;
                                objSPListItem[objSPList.Fields.GetFieldByInternalName("ProgramName").Id] = ProgramName;
                                objSPListItem[objSPList.Fields.GetFieldByInternalName("StartStation").Id] = nSourse_ID;
                                objSPListItem[objSPList.Fields.GetFieldByInternalName("EndStation").Id] = nDestination_ID;
                                objSPListItem[objSPList.Fields.GetFieldByInternalName("Points").Id] = strRoutesInfo;
                                objSPListItem[objSPList.Fields.GetFieldByInternalName("strDistance").Id] = strDistance;
                                objSPListItem[objSPList.Fields.GetFieldByInternalName("strDuration").Id] = strDuration;
                                objSPListItem[objSPList.Fields.GetFieldByInternalName("LatNortheast").Id] = LatNortheast;
                                objSPListItem[objSPList.Fields.GetFieldByInternalName("LongNortheast").Id] = LongNortheast;
                                objSPListItem[objSPList.Fields.GetFieldByInternalName("LatSouthwest").Id] = LatSouthwest;
                                objSPListItem[objSPList.Fields.GetFieldByInternalName("LongSouthwest").Id] = LongSouthwest;
                                objSPListItem.Update();
                                nResult = objSPListItem.ID;
                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }
                            objWeb.AllowUnsafeUpdates = false;
                        }
                    }
                });
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            if (nIDForUpdate > 0)
            {
                bIsUpdated = true;
            }

            return nResult;

        }
        public static Int64 InsertPolygan_ByListInfo(string strNamePolygan, string strPolygonPoints, string strFillColor, string strBorderColor, float nOpacity)
        {
            int nResult = -1;

            SPWeb objCurrentWeb = SPContext.Current.Web;
            try
            {
                SPList objSPList = null;
                SPSecurity.RunWithElevatedPrivileges(delegate()
                {
                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                    {
                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                        {
                            objWeb.AllowUnsafeUpdates = true;
                            try
                            {
                                objSPList = objWeb.Lists[Const_ListPolygans_Title];

                                //ابتدا تست می کنیم که با این شروع و پایان باید چیزی بهنگام گردد یا نه

                                SPListItem objSPListItem = objSPList.AddItem();
                                objSPListItem[objSPList.Fields.GetFieldByInternalName("Title").Id] = strNamePolygan;
                                objSPListItem[objSPList.Fields.GetFieldByInternalName("PolygonPoints").Id] = strPolygonPoints;
                                objSPListItem[objSPList.Fields.GetFieldByInternalName("FillColor").Id] = strFillColor;
                                objSPListItem[objSPList.Fields.GetFieldByInternalName("BorderColor").Id] = strBorderColor;
                                objSPListItem[objSPList.Fields.GetFieldByInternalName("Opacity").Id] = nOpacity.ToString();
                                objSPListItem.Update();
                                nResult = objSPListItem.ID;
                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }
                            objWeb.AllowUnsafeUpdates = false;
                        }
                    }
                });
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }


            return nResult;
        }
        public static Int64 InsertCameraInCoridorCamera(long nCorridorInfo_ID, long nCamera_ID)
        {
            //try
            //{
            //    using (SqlConnection objSqlConnection = new SqlConnection(GetConnectionStringRah141()))
            //    {
            //        objSqlConnection.Open();

            //        SqlCommand objSqlCommand = new SqlCommand();
            //        objSqlCommand.Connection = objSqlConnection;

            //        string strColNameForInsert = "";
            //        string strValueForInsert = "";

            //        //***********************************************
            //        if (strColNameForInsert.Trim().Length != 0)
            //        {
            //            strColNameForInsert = strColNameForInsert + " ,";
            //        }
            //        strColNameForInsert = strColNameForInsert + " CorridorInfo_ID";
            //        if (strValueForInsert.Trim().Length != 0)
            //        {
            //            strValueForInsert = strValueForInsert + " ,";
            //        }
            //        strValueForInsert = strValueForInsert + " @CorridorInfo_ID";
            //        objSqlCommand.Parameters.AddWithValue("@CorridorInfo_ID", nCorridorInfo_ID);
            //        //***********************************************
            //        if (strColNameForInsert.Trim().Length != 0)
            //        {
            //            strColNameForInsert = strColNameForInsert + " ,";
            //        }
            //        strColNameForInsert = strColNameForInsert + " Camera_ID";
            //        if (strValueForInsert.Trim().Length != 0)
            //        {
            //            strValueForInsert = strValueForInsert + " ,";
            //        }
            //        strValueForInsert = strValueForInsert + " @Camera_ID";
            //        objSqlCommand.Parameters.AddWithValue("@Camera_ID", nCamera_ID);
            //        //***********************************************

            //        try
            //        {
            //            string strQueryInsert = " Insert Into CorridorCameraInfo  ( " + strColNameForInsert + " ) Values ( " + strValueForInsert + " )";
            //            strQueryInsert = strQueryInsert + ";SELECT SCOPE_IDENTITY();";
            //            objSqlCommand.CommandText = strQueryInsert;
            //            object objResult = objSqlCommand.ExecuteScalar();

            //            return Convert.ToInt64(objResult);
            //        }
            //        catch (Exception e)
            //        {

            //        }

            //        objSqlConnection.Close();
            //    }

            //}
            //catch (Exception)
            //{

            //}
            return -1;
        }

        public static Int64 InsertCameraInCoridorTradodShomarha(long nCorridorInfo_ID, long nMehvar_ID)
        {
            //try
            //{
            //    using (SqlConnection objSqlConnection = new SqlConnection(GetConnectionStringRah141()))
            //    {
            //        objSqlConnection.Open();

            //        SqlCommand objSqlCommand = new SqlCommand();
            //        objSqlCommand.Connection = objSqlConnection;

            //        string strColNameForInsert = "";
            //        string strValueForInsert = "";

            //        //***********************************************
            //        if (strColNameForInsert.Trim().Length != 0)
            //        {
            //            strColNameForInsert = strColNameForInsert + " ,";
            //        }
            //        strColNameForInsert = strColNameForInsert + " CorridorInfo_ID";
            //        if (strValueForInsert.Trim().Length != 0)
            //        {
            //            strValueForInsert = strValueForInsert + " ,";
            //        }
            //        strValueForInsert = strValueForInsert + " @CorridorInfo_ID";
            //        objSqlCommand.Parameters.AddWithValue("@CorridorInfo_ID", nCorridorInfo_ID);
            //        //***********************************************
            //        if (strColNameForInsert.Trim().Length != 0)
            //        {
            //            strColNameForInsert = strColNameForInsert + " ,";
            //        }
            //        strColNameForInsert = strColNameForInsert + " Mehvar_ID";
            //        if (strValueForInsert.Trim().Length != 0)
            //        {
            //            strValueForInsert = strValueForInsert + " ,";
            //        }
            //        strValueForInsert = strValueForInsert + " @Mehvar_ID";
            //        objSqlCommand.Parameters.AddWithValue("@Mehvar_ID", nMehvar_ID);
            //        //***********************************************

            //        try
            //        {
            //            string strQueryInsert = " Insert Into CorridorTradodShomarInfo  ( " + strColNameForInsert + " ) Values ( " + strValueForInsert + " )";
            //            strQueryInsert = strQueryInsert + ";SELECT SCOPE_IDENTITY();";
            //            objSqlCommand.CommandText = strQueryInsert;
            //            object objResult = objSqlCommand.ExecuteScalar();

            //            return Convert.ToInt64(objResult);
            //        }
            //        catch (Exception e)
            //        {

            //        }

            //        objSqlConnection.Close();
            //    }

            //}
            //catch (Exception)
            //{

            //}
            return -1;
        }

        public static string RemoveControlCharactersFromString(string inString)
        {
            if (inString == null) return null;
            StringBuilder newString = new StringBuilder();
            char ch;
            for (int i = 0; i < inString.Length; i++)
            {
                ch = inString[i];
                if (!char.IsControl(ch))
                {
                    newString.Append(ch);
                }
            }
            return newString.ToString();
        }

        public static clsRouteForJson[] GetCorrectRoutPointByColor(int nValue, string ColorOfTheRoute)
        {
            string strBaseArrayOfRoute = Fetch_BaseArrayOfRouteFromCorridorInfoInDataBase(nValue);
            return GetCorrectRoutPointByColor(strBaseArrayOfRoute, ColorOfTheRoute);
        }

        public static clsRouteForJson[] GetCorrectRoutPointByColor(string strBaseArrayOfRoute, string ColorOfTheRoute)
        {
            JavaScriptSerializer js = new JavaScriptSerializer();
            clsRouteForJson[] objclsRouteForJson = js.Deserialize<clsRouteForJson[]>(strBaseArrayOfRoute);

            for (Int16 nCurentIndex = 0; nCurentIndex < objclsRouteForJson.Length; nCurentIndex++)
            {
                if (objclsRouteForJson[nCurentIndex].Color == null || objclsRouteForJson[nCurentIndex].Color.Trim().Length == 0)
                {
                    objclsRouteForJson[nCurentIndex].Color = ColorOfTheRoute;
                }
            }

            return objclsRouteForJson;
        }

        public static DataTable GetCorridorInfoIDByCitesInfo(string strStationFrom, string strStationTo)
        {

            DataTable objResult = new DataTable();

            //try
            //{
            //    SqlConnection objSqlConnection = new SqlConnection(GetConnectionStringRah141());
            //    objSqlConnection.Open();
            //    try
            //    {
            //        string Strsql = " SELECT ID  FROM CorridorInfo  where StationFrom = N'" + strStationFrom + "' and StationTo = N'" + strStationTo + "'";
            //        SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
            //        objSqlDataAdapter.Fill(objResult);
            //    }
            //    catch (Exception)
            //    {
            //    }

            //    objSqlConnection.Close();

            //}
            //catch (Exception)
            //{

            //}
            return objResult;

        }

        public static string FillSugestion_NameStationFromAllStations(string strStationInfo)
        {
            string strResult = "";

            SPWeb objCurrentWeb = SPContext.Current.Web;
            DataTable objResult = new DataTable();
            try
            {
                SPList objSPList = null;
                SPListItemCollection objSPListItemCollection = null;

                SPSecurity.RunWithElevatedPrivileges(delegate()
                {
                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                    {
                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                        {
                            try
                            {
                                string strQueryString = "";
                                //                                                      @"<Where>
                                //                                                                     <Or>
                                //                                                                          <Contains>
                                //                                                                                 <FieldRef Name='Title' />
                                //                                                                                  <Value Type='Text'>" + _FixFarsi(strStationInfo, true) + @"</Value>
                                //                                                                         </Contains>
                                //                                                                          <Contains>
                                //                                                                                 <FieldRef Name='Title' />
                                //                                                                                  <Value Type='Text'>" + _FixFarsi(strStationInfo, false) + @"</Value>
                                //                                                                         </Contains>
                                //                                                                    </Or>
                                //
                                //                                                          </Where>";

                                SPQuery objSPQuery = new SPQuery();
                                objSPQuery.Query = strQueryString;

                                objSPList = objWeb.Lists[Const_ListStations_Title];
                                objSPListItemCollection = objSPList.GetItems(objSPQuery);
                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }
                        }
                    }
                });

                if (objSPList == null || objSPListItemCollection.Count == 0)
                {
                    return strResult;
                }
                else
                {

                    objResult = objSPListItemCollection.GetDataTable();

                    //Farsi
                    foreach (DataRow item in objResult.Rows)
                    {
                        try
                        {
                            item["Title"] = _FixFarsi(item["Title"].ToString());
                        }
                        catch (Exception)
                        {

                        }

                    }
                    DataView objResultView_Fasi = new DataView(objResult);
                    objResultView_Fasi.RowFilter = "Title like '%" + _FixFarsi(strStationInfo) + "%' ";
                    objResult = objResultView_Fasi.ToTable();
                    foreach (DataRow item in objResult.Rows)
                    {
                        if (strResult.Trim().Length != 0)
                        {
                            strResult = strResult + "*";
                        }
                        strResult = strResult + item[0].ToString();
                    }

                    //Arabic
                    foreach (DataRow item in objResult.Rows)
                    {
                        try
                        {
                            item["Title"] = _FixArabic(item["Title"].ToString());
                        }
                        catch (Exception)
                        {

                        }

                    }

                    if (strStationInfo.Contains("ك") || strStationInfo.Contains("ي"))
                    {
                        DataView objResultView_Arabic = new DataView(objResult);
                        objResultView_Arabic.RowFilter = "Title like '%" + _FixArabic(strStationInfo) + "%' and (Title like '%ك%' or Title like '%ي%' ) ";
                        objResult = objResultView_Arabic.ToTable();
                        foreach (DataRow item in objResult.Rows)
                        {
                            if (strResult.Trim().Length != 0)
                            {
                                strResult = strResult + "*";
                            }
                            strResult = strResult + _FixArabic(item[0].ToString());
                        }

                    }
                    return strResult;
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            return strResult;
        }

        public static DataTable FillSugestion_NameCorridor_ByListInfo(string strNameInfo)
        {
            SPWeb objCurrentWeb = SPContext.Current.Web;

            DataTable objResult = new DataTable();
            objResult.Columns.Add("ID");
            objResult.Columns.Add("Title");
            objResult.Columns.Add("StationFrom");
            objResult.Columns.Add("StationFromID");
            objResult.Columns.Add("StationTo");
            objResult.Columns.Add("StationToID");
            objResult.Columns.Add("Points");
            objResult.Columns.Add("Color");

            try
            {
                SPListItemCollection objSPListItemCollectionRoute = null;

                SPSecurity.RunWithElevatedPrivileges(delegate()
                {
                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                    {
                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                        {
                            try
                            {
                                string strQueryString = "";
                                if (strNameInfo.Trim().Length != 0 && strNameInfo.Trim().Length == 0)
                                {
                                    strQueryString = @"                                   <Where>
                                                                                                         <Contains>
		                                                                                                        <FieldRef Name='Title' />
                                                                                                                <Value Type='Text'>" + strNameInfo + @"</Value>
                                                                                                         </Contains>
                                                                                          </Where>";
                                }


                                SPQuery objSPQuery = new SPQuery();
                                objSPQuery.Query = strQueryString;

                                SPList objSPList = objWeb.Lists[Const_ListRouts_Title];
                                objSPListItemCollectionRoute = objSPList.GetItems(objSPQuery);

                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }
                        }
                    }
                });

                if (objSPListItemCollectionRoute == null || objSPListItemCollectionRoute.Count == 0)
                {
                    return objResult;
                }
                else
                {
                    foreach (SPListItem objSPListItem in objSPListItemCollectionRoute)
                    {
                        try
                        {
                            DataRow objDataRow = objResult.NewRow();

                            objDataRow["ID"] = objSPListItem[objSPListItem.ParentList.Fields.GetFieldByInternalName("ID").Id];
                            objDataRow["Title"] = objSPListItem[objSPListItem.ParentList.Fields.GetFieldByInternalName("Title").Id];
                            objDataRow["Points"] = objSPListItem[objSPListItem.ParentList.Fields.GetFieldByInternalName("Points").Id];

                            if (objDataRow["Points"].ToString().Trim().Length == 0)
                            {
                                //اگر پوینت نداردیم یعنی کریدور نداریم
                                continue;
                            }

                            SPFieldLookupValue objStartStation = new SPFieldLookupValue(objSPListItem[objSPListItem.ParentList.Fields.GetFieldByInternalName("StartStation").Id] as String);
                            objDataRow["StationFrom"] = objStartStation.LookupValue;
                            objDataRow["StationFromID"] = objStartStation.LookupId;


                            SPFieldLookupValue objEndStation = new SPFieldLookupValue(objSPListItem[objSPListItem.ParentList.Fields.GetFieldByInternalName("EndStation").Id] as String);
                            objDataRow["StationTo"] = objEndStation.LookupValue;
                            objDataRow["StationToID"] = objEndStation.LookupId;

                            objResult.Rows.Add(objDataRow);
                        }
                        catch (Exception)
                        {

                        }

                    }
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            return objResult;
        }

        public static string FetchStationIDCamaLatCamaLong(string strStationInfo)
        {
            string strResult = "";
            SPWeb objCurrentWeb = SPContext.Current.Web;
            DataTable objResult = new DataTable();
            try
            {
                SPList objSPList = null;
                SPListItemCollection objSPListItemCollection = null;

                SPSecurity.RunWithElevatedPrivileges(delegate()
                {
                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                    {
                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                        {
                            try
                            {
                                string strQueryString = "";
                                //                                @"<Where>     
                                //                                                                <Or>
                                //                                                                     <Eq>
                                //                                                                             <FieldRef Name='Title' />
                                //                                                                              <Value Type='Text'>" + _FixFarsi(strStationInfo, true) + @"</Value>
                                //                                                                     </Eq>
                                //                                                                     <Eq>
                                //                                                                             <FieldRef Name='Title' />
                                //                                                                              <Value Type='Text'>" + _FixFarsi(strStationInfo, false) + @"</Value>
                                //                                                                     </Eq>
                                //                                                                </Or>
                                //                                                          </Where>";

                                SPQuery objSPQuery = new SPQuery();
                                objSPQuery.Query = strQueryString;

                                objSPList = objWeb.Lists[Const_ListStations_Title];
                                objSPListItemCollection = objSPList.GetItems(objSPQuery);
                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }
                        }
                    }
                });

                if (objSPList == null || objSPListItemCollection.Count == 0)
                {
                    return strResult;
                }
                else
                {
                    //Farsi
                    objResult = objSPListItemCollection.GetDataTable();
                    foreach (DataRow item in objResult.Rows)
                    {
                        try
                        {
                            item["Title"] = _FixFarsi(item["Title"].ToString());
                        }
                        catch (Exception)
                        {

                        }
                    }

                    DataView objResultView = new DataView(objResult);
                    objResultView.RowFilter = "Title = '" + strStationInfo + "' ";
                    objResult = objResultView.ToTable();

                }

                if (objResult.Rows.Count > 0)
                {
                    strResult = objResult.Rows[0]["ID"].ToString();
                    strResult = strResult + "," + ToInvariantNumber(objResult.Rows[0]["Latitude"]);
                    strResult = strResult + "," + ToInvariantNumber(objResult.Rows[0]["Longitude"]);
                }
                else
                {
                    //Arabic
                    objResult = objSPListItemCollection.GetDataTable();
                    foreach (DataRow item in objResult.Rows)
                    {
                        try
                        {
                            item["Title"] = _FixArabic(item["Title"].ToString());
                        }
                        catch (Exception)
                        {

                        }
                    }

                    DataView objResultView = new DataView(objResult);
                    objResultView.RowFilter = "Title = '" + strStationInfo + "' ";
                    objResult = objResultView.ToTable();

                    if (objResult.Rows.Count > 0)
                    {
                        strResult = objResult.Rows[0]["ID"].ToString();
                        strResult = strResult + "," + ToInvariantNumber(objResult.Rows[0]["Latitude"]);
                        strResult = strResult + "," + ToInvariantNumber(objResult.Rows[0]["Longitude"]);
                    }
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            return strResult;
        }


        public static List<string> GetProjectNameDistinctInfoDataBase()
        {
            SPWeb objCurrentWeb = SPContext.Current.Web;

            List<string> fieldList = new List<string>();

            try
            {
                DataTable objDatatable = new DataTable();
                SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString());
                objSqlConnection.Open();
                string Strsql = " SELECT  distinct ProgramName FROM  GISInfo ";
                SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
                objSqlDataAdapter.Fill(objDatatable);
                objSqlConnection.Close();

                foreach (DataRow objDataRow in objDatatable.Rows)
                {
                    try
                    {
                        fieldList.Add(objDataRow["ProgramName"].ToString());
                    }
                    catch (Exception)
                    {
                    }
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            return fieldList;
        }
        public static List<string> GetProjectNameDistinctInfoDataBaseForDepartment(string strDepartment)
        {
            SPWeb objCurrentWeb = SPContext.Current.Web;

            List<string> fieldList = new List<string>();

            try
            {
                DataTable objDatatable = new DataTable();
                SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString());
                objSqlConnection.Open();
                string Strsql = " SELECT  distinct ProgramName FROM  GISInfo ";
                if (strDepartment != "")
                {
                    Strsql = Strsql + " where Department = N'" + strDepartment + "' ";
                }

                SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
                objSqlDataAdapter.Fill(objDatatable);
                objSqlConnection.Close();

                foreach (DataRow objDataRow in objDatatable.Rows)
                {
                    try
                    {
                        fieldList.Add(objDataRow["ProgramName"].ToString());
                    }
                    catch (Exception)
                    {
                    }
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            return fieldList;
        }

        public static List<string> GetDepartmentDistinctInfoDataBase()
        {
            SPWeb objCurrentWeb = SPContext.Current.Web;

            List<string> fieldList = new List<string>();

            try
            {
                DataTable objDatatable = new DataTable();
                SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString());
                objSqlConnection.Open();
                string Strsql = " SELECT  distinct Department FROM  GISInfo ";
                SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
                objSqlDataAdapter.Fill(objDatatable);
                objSqlConnection.Close();

                foreach (DataRow objDataRow in objDatatable.Rows)
                {
                    try
                    {
                        fieldList.Add(objDataRow["Department"].ToString());
                    }
                    catch (Exception)
                    {
                    }
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            return fieldList;
        }

        public static List<string> GetProjectNameDataTable()
        {
            SPWeb objCurrentWeb = SPContext.Current.Web;

            List<string> fieldList = new List<string>();

            try
            {
                SPSecurity.RunWithElevatedPrivileges(delegate()
                {
                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                    {
                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                        {
                            try
                            {
                                SPList objSPList = objWeb.Lists[Const_ListRouts_Title];
                                SPFieldChoice dropdown = objSPList.Fields["ProgramName"] as SPFieldChoice;
                                foreach (string str in dropdown.Choices)
                                {
                                    fieldList.Add(str);
                                }
                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }
                        }
                    }
                });
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            return fieldList;
        }

        public static DataTable FetchAllReportsByProjectName(string ProgramName)
        {
            SPWeb objCurrentWeb = SPContext.Current.Web;
            DataTable objResult = new DataTable();
            objResult.Columns.Add("Title");
            objResult.Columns.Add("ProgramName");
            objResult.Columns.Add("URLInfo");

            try
            {
                SPList objSPList = null;
                SPListItemCollection objSPListItemCollection = null;

                SPSecurity.RunWithElevatedPrivileges(delegate()
                {
                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                    {
                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                        {
                            try
                            {
                                string strQueryString = @"<Where>
                                                                                                     <Contains>
                                                                                                             <FieldRef Name='ProgramName' />
                                                                                                              <Value Type='Text'>" + ProgramName + @"</Value>
                                                                                                     </Contains>
                                                                                          </Where>";
                                SPQuery objSPQuery = new SPQuery();
                                objSPQuery.Query = strQueryString;

                                objSPList = objWeb.Lists[Const_ListReports_Title];
                                objSPListItemCollection = objSPList.GetItems(objSPQuery);

                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }
                        }
                    }
                });

                if (objSPList == null || objSPListItemCollection.Count == 0)
                {
                    return objResult;
                }
                else
                {
                    foreach (SPListItem objSPListItem in objSPListItemCollection)
                    {
                        DataRow objDataRow = objResult.NewRow();
                        objDataRow["Title"] = objSPListItem.Title;
                        objDataRow["ProgramName"] = objSPListItem["ProgramName"];
                        objDataRow["URLInfo"] = objSPListItem["URLInfo"];
                        objResult.Rows.Add(objDataRow);
                    }
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            return objResult;

        }

        #endregion

        #region لیست مسیرها (ViewRouts)

        // ستون‌هایی که داده‌ی فنی نقشه هستند و در فیلترها/پنجرهٔ اطلاعات نمایش داده نمی‌شوند
        private static readonly string[] RoutsListTechnicalFields = { "Points", "LatNortheast", "LongNortheast", "LatSouthwest", "LongSouthwest" };
        private static readonly string[] RoutsListReadOnlyDisplayFields = { "ID", "Created", "Modified" };

        private static bool IsRoutsListDisplayField(SPField field)
        {
            if (field == null || field.Hidden)
            {
                return false;
            }

            if (Array.IndexOf(RoutsListReadOnlyDisplayFields, field.InternalName) >= 0)
            {
                return true;
            }

            if (field.ReadOnlyField)
            {
                return false;
            }

            switch (field.Type)
            {
                case SPFieldType.Attachments:
                case SPFieldType.Computed:
                case SPFieldType.File:
                case SPFieldType.ContentTypeId:
                case SPFieldType.Guid:
                case SPFieldType.WorkflowStatus:
                case SPFieldType.ModStat:
                case SPFieldType.Counter:
                    return field.InternalName == "ID";
            }

            return field.InternalName != "ContentType";
        }

        private static List<SPField> GetRoutsListDisplayFields(SPList objSPList)
        {
            List<SPField> lstFields = new List<SPField>();
            List<SPField> lstTail = new List<SPField>();

            lstFields.Add(objSPList.Fields.GetFieldByInternalName("ID"));
            lstFields.Add(objSPList.Fields.GetFieldByInternalName("Title"));

            foreach (SPField field in objSPList.Fields)
            {
                if (!IsRoutsListDisplayField(field) || field.InternalName == "ID" || field.InternalName == "Title")
                {
                    continue;
                }

                if (field.InternalName == "Created" || field.InternalName == "Modified")
                {
                    lstTail.Add(field);
                }
                else
                {
                    lstFields.Add(field);
                }
            }

            lstFields.AddRange(lstTail);
            return lstFields;
        }

        private static string GetRoutsListFieldDisplayText(SPListItem item, SPField field)
        {
            object value = null;
            try
            {
                value = item[field.Id];
            }
            catch (Exception)
            {
                return "";
            }

            if (value == null)
            {
                return "";
            }

            try
            {
                switch (field.Type)
                {
                    case SPFieldType.Lookup:
                        {
                            List<string> parts = new List<string>();
                            foreach (SPFieldLookupValue lookupValue in new SPFieldLookupValueCollection(value.ToString()))
                            {
                                parts.Add(lookupValue.LookupValue);
                            }
                            return string.Join("، ", parts.ToArray());
                        }
                    case SPFieldType.User:
                        {
                            List<string> parts = new List<string>();
                            foreach (SPFieldUserValue userValue in new SPFieldUserValueCollection(item.Web, value.ToString()))
                            {
                                parts.Add(userValue.LookupValue);
                            }
                            return string.Join("، ", parts.ToArray());
                        }
                    case SPFieldType.DateTime:
                        {
                            DateTime dt = Convert.ToDateTime(value);
                            SPFieldDateTime dateField = field as SPFieldDateTime;
                            string strPersian = PersianDate(dt);
                            if (dateField != null && dateField.DisplayFormat == SPDateTimeFieldFormatType.DateOnly)
                            {
                                strPersian = strPersian.Split(' ')[0];
                            }
                            return strPersian;
                        }
                    case SPFieldType.Boolean:
                        return Convert.ToBoolean(value) ? "بله" : "خیر";
                    case SPFieldType.URL:
                        return new SPFieldUrlValue(value.ToString()).Url;
                    case SPFieldType.Number:
                    case SPFieldType.Currency:
                        return ToInvariantNumber(value);
                    case SPFieldType.Note:
                        return Regex.Replace(value.ToString(), "<[^>]+>", " ").Replace("&nbsp;", " ").Trim();
                    default:
                        return field.GetFieldValueAsText(value);
                }
            }
            catch (Exception)
            {
                return value.ToString();
            }
        }

        /// <summary>
        /// ستون‌های قابل نمایش «لیست مسیرها»: نام داخلی، عنوان، نوع، گزینه‌ها (برای Choice) و اینکه فنی است یا نه.
        /// </summary>
        public static DataTable FetchRoutsListSchema()
        {
            SPWeb objCurrentWeb = SPContext.Current.Web;
            DataTable objResult = new DataTable();
            objResult.Columns.Add("InternalName");
            objResult.Columns.Add("Title");
            objResult.Columns.Add("Type");
            objResult.Columns.Add("Choices");
            objResult.Columns.Add("Technical");

            try
            {
                SPSecurity.RunWithElevatedPrivileges(delegate()
                {
                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                    {
                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                        {
                            try
                            {
                                SPList objSPList = objWeb.Lists[Const_ListRouts_Title];
                                foreach (SPField field in GetRoutsListDisplayFields(objSPList))
                                {
                                    DataRow objDataRow = objResult.NewRow();
                                    objDataRow["InternalName"] = field.InternalName;
                                    objDataRow["Title"] = field.Title;
                                    objDataRow["Type"] = field.Type.ToString();

                                    string strChoices = "";
                                    SPFieldMultiChoice choiceField = field as SPFieldMultiChoice;
                                    if (choiceField != null)
                                    {
                                        List<string> lstChoices = new List<string>();
                                        foreach (string strChoice in choiceField.Choices)
                                        {
                                            lstChoices.Add(strChoice);
                                        }
                                        strChoices = string.Join("|", lstChoices.ToArray());
                                    }
                                    objDataRow["Choices"] = strChoices;
                                    objDataRow["Technical"] = Array.IndexOf(RoutsListTechnicalFields, field.InternalName) >= 0 ? "1" : "0";
                                    objResult.Rows.Add(objDataRow);
                                }
                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }
                        }
                    }
                });
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            return objResult;
        }

        /// <summary>
        /// نام پروژه‌هایی که واقعاً در «لیست مسیرها» مسیر دارند (مقادیر متمایز ستون ProgramName).
        /// </summary>
        public static List<string> GetProjectNameDistinctFromRoutsList()
        {
            SPWeb objCurrentWeb = SPContext.Current.Web;
            List<string> lstResult = new List<string>();

            try
            {
                SPSecurity.RunWithElevatedPrivileges(delegate()
                {
                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                    {
                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                        {
                            try
                            {
                                SPList objSPList = objWeb.Lists[Const_ListRouts_Title];
                                SPField programField = objSPList.Fields.GetFieldByInternalName("ProgramName");
                                SPQuery objSPQuery = new SPQuery();
                                objSPQuery.ViewFields = "<FieldRef Name='ProgramName' />";
                                foreach (SPListItem objSPListItem in objSPList.GetItems(objSPQuery))
                                {
                                    string strName = GetRoutsListFieldDisplayText(objSPListItem, programField).Trim();
                                    if (strName.Length != 0 && !lstResult.Contains(strName))
                                    {
                                        lstResult.Add(strName);
                                    }
                                }
                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }
                        }
                    }
                });
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            lstResult.Sort();
            return lstResult;
        }

        /// <summary>
        /// آیتم‌های «لیست مسیرها» با متن نمایشی همهٔ ستون‌ها، به‌علاوهٔ مختصات ایستگاه‌های مبدا/مقصد
        /// که از «لیست ایستگاه ها» برداشته می‌شود. اگر نام پروژه خالی باشد همهٔ مسیرها برمی‌گردند.
        /// </summary>
        public static DataTable FetchRoutsListItems(string strProgramName)
        {
            SPWeb objCurrentWeb = SPContext.Current.Web;
            DataTable objResult = new DataTable();
            string[] strComputedColumns = { "StationFrom_ID", "StationFrom_Title", "LatFrom", "LongFrom", "StationTo_ID", "StationTo_Title", "LatTo", "LongTo" };

            try
            {
                SPSecurity.RunWithElevatedPrivileges(delegate()
                {
                    Thread.CurrentPrincipal = new WindowsPrincipal(WindowsIdentity.GetCurrent());
                    using (SPSite objSiteColl = new SPSite(objCurrentWeb.Site.ID))
                    {
                        using (SPWeb objWeb = objSiteColl.OpenWeb(objCurrentWeb.ID))
                        {
                            try
                            {
                                SPList objSPList = objWeb.Lists[Const_ListRouts_Title];
                                List<SPField> lstFields = GetRoutsListDisplayFields(objSPList);

                                foreach (SPField field in lstFields)
                                {
                                    objResult.Columns.Add(field.InternalName);
                                }
                                foreach (string strColumn in strComputedColumns)
                                {
                                    if (!objResult.Columns.Contains(strColumn))
                                    {
                                        objResult.Columns.Add(strColumn);
                                    }
                                }

                                // مختصات ایستگاه‌ها یک بار خوانده می‌شود تا برای هر مسیر پرس‌وجوی جداگانه نزنیم
                                Dictionary<int, string[]> dicStations = new Dictionary<int, string[]>();
                                try
                                {
                                    SPList objStationsList = objWeb.Lists[Const_ListStations_Title];
                                    Guid latFieldId = objStationsList.Fields.GetFieldByInternalName("Latitude").Id;
                                    Guid longFieldId = objStationsList.Fields.GetFieldByInternalName("Longitude").Id;
                                    SPQuery objStationsQuery = new SPQuery();
                                    objStationsQuery.ViewFields = "<FieldRef Name='ID' /><FieldRef Name='Latitude' /><FieldRef Name='Longitude' />";
                                    foreach (SPListItem objStation in objStationsList.GetItems(objStationsQuery))
                                    {
                                        dicStations[objStation.ID] = new[] { ToInvariantNumber(objStation[latFieldId]), ToInvariantNumber(objStation[longFieldId]) };
                                    }
                                }
                                catch (Exception e)
                                {
                                    ClsHelpper.WriteToLogFile(e.Message);
                                }

                                SPQuery objSPQuery = new SPQuery();
                                if (strProgramName.Trim().Length != 0)
                                {
                                    objSPQuery.Query = "<Where><Eq><FieldRef Name='ProgramName' /><Value Type='Text'>" + SecurityElement.Escape(strProgramName.Trim()) + "</Value></Eq></Where>";
                                }

                                foreach (SPListItem objSPListItem in objSPList.GetItems(objSPQuery))
                                {
                                    try
                                    {
                                        DataRow objDataRow = objResult.NewRow();
                                        foreach (SPField field in lstFields)
                                        {
                                            objDataRow[field.InternalName] = GetRoutsListFieldDisplayText(objSPListItem, field);
                                        }
                                        objDataRow["ID"] = objSPListItem.ID.ToString();

                                        string strStartStation = Convert.ToString(objSPListItem[objSPList.Fields.GetFieldByInternalName("StartStation").Id]);
                                        if (strStartStation.Length != 0)
                                        {
                                            SPFieldLookupValue objStartStation = new SPFieldLookupValue(strStartStation);
                                            objDataRow["StationFrom_ID"] = objStartStation.LookupId.ToString();
                                            objDataRow["StationFrom_Title"] = objStartStation.LookupValue;
                                            if (dicStations.ContainsKey(objStartStation.LookupId))
                                            {
                                                objDataRow["LatFrom"] = dicStations[objStartStation.LookupId][0];
                                                objDataRow["LongFrom"] = dicStations[objStartStation.LookupId][1];
                                            }
                                        }

                                        string strEndStation = Convert.ToString(objSPListItem[objSPList.Fields.GetFieldByInternalName("EndStation").Id]);
                                        if (strEndStation.Length != 0)
                                        {
                                            SPFieldLookupValue objEndStation = new SPFieldLookupValue(strEndStation);
                                            objDataRow["StationTo_ID"] = objEndStation.LookupId.ToString();
                                            objDataRow["StationTo_Title"] = objEndStation.LookupValue;
                                            if (dicStations.ContainsKey(objEndStation.LookupId))
                                            {
                                                objDataRow["LatTo"] = dicStations[objEndStation.LookupId][0];
                                                objDataRow["LongTo"] = dicStations[objEndStation.LookupId][1];
                                            }
                                        }

                                        objResult.Rows.Add(objDataRow);
                                    }
                                    catch (Exception e)
                                    {
                                        ClsHelpper.WriteToLogFile(e.Message);
                                    }
                                }
                            }
                            catch (Exception e)
                            {
                                ClsHelpper.WriteToLogFile(e.Message);
                            }
                        }
                    }
                });
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile(e.Message);
            }

            return objResult;
        }

        #endregion

        #region Operation

        public static string _FixFarsi(string objValue)
        {
            string str = null;
            str = _CorrectNumericValue(objValue);
            str = str.Replace('ي', 'ی');
            str = str.Replace('ك', 'ک');
            return str;
        }

        public static string _FixArabic(string objValue)
        {
            string str = null;
            str = _CorrectNumericValue(objValue);
            str = str.Replace('ی', 'ي');
            str = str.Replace('ک', 'ك');
            return str;
        }

        public static string _CorrectNumericValue(string strValue)
        {

            string strFinal = "";

            if ((strValue == null))
            {
                return "";
            }

            if ((string.IsNullOrEmpty(strValue)))
            {
                return "";
            }

            foreach (char Chr in strValue)
            {
                if ((char.IsDigit(Chr) == false))
                {
                    strFinal = strFinal + Chr;
                }
                else
                {
                    strFinal = strFinal + Convert.ToInt64(char.GetNumericValue(Chr));
                }
            }

            return strFinal;
        }

        #endregion



            #region PWAInfo (نقشهء پروژه‌های Project Web App - وب‌پارت ShowAllProjectInfo)

        // ستون‌هایی که به کلاینت فرستاده می‌شود (فقط سطرهایی که مختصات دارند)
        private const string PWAINFO_SELECT_COLUMNS =
            " ID, ProjectName, ProjectCode, Status, PlannedProgress, ActualProgress, AchievementPct, " +
            " StartDateJ, FinishDateJ, PlannedStartJ, PlannedFinishJ, TotalCost, ProjectType, Region, ExecutionMethod, " +
            " ProjectManager, ProjectSupervisor, OrgLevel1, OrgLevel2, Lat, [Long], TahaghoghCategory ";

        /// <summary>انواع پروژهء موجود در PWAInfo (برای کمبوی «نوع پروژه»)</summary>
        public static List<string> GetPWAProjectTypes()
        {
            List<string> fieldList = new List<string>();
            try
            {
                DataTable objDatatable = new DataTable();
                using (SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString()))
                {
                    objSqlConnection.Open();
                    string Strsql = " SELECT DISTINCT ProjectType FROM dbo.PWAInfo WHERE ProjectType IS NOT NULL AND LTRIM(RTRIM(ProjectType)) <> N'' ORDER BY ProjectType ";
                    SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
                    objSqlDataAdapter.Fill(objDatatable);
                    objSqlConnection.Close();
                }
                foreach (DataRow objDataRow in objDatatable.Rows)
                {
                    fieldList.Add(objDataRow["ProjectType"].ToString());
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile("GetPWAProjectTypes: " + e.Message);
            }
            return fieldList;
        }

        /// <summary>منطقه‌های پروژه (برای پیشنهاد خودکار فیلد «منطقه پروژه»)؛ خالی بودن نوع = همهء انواع</summary>
        public static List<string> GetPWARegions(string strProjectType)
        {
            List<string> fieldList = new List<string>();
            try
            {
                DataTable objDatatable = new DataTable();
                using (SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString()))
                {
                    objSqlConnection.Open();
                    string Strsql = " SELECT DISTINCT Region FROM dbo.PWAInfo " +
                                    " WHERE Region IS NOT NULL AND LTRIM(RTRIM(Region)) <> N'' " +
                                    "   AND (@ProjectType = N'' OR ProjectType = @ProjectType) " +
                                    " ORDER BY Region ";
                    SqlCommand objCmd = new SqlCommand(Strsql, objSqlConnection);
                    objCmd.Parameters.Add("@ProjectType", SqlDbType.NVarChar, 50).Value = (strProjectType ?? "").Trim();
                    SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(objCmd);
                    objSqlDataAdapter.Fill(objDatatable);
                    objSqlConnection.Close();
                }
                foreach (DataRow objDataRow in objDatatable.Rows)
                {
                    fieldList.Add(objDataRow["Region"].ToString());
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile("GetPWARegions: " + e.Message);
            }
            return fieldList;
        }

        /// <summary>
        /// پروژه‌های PWAInfo برای نمایش روی نقشه. فقط سطرهایی که Lat/Long دارند.
        /// نوع یا منطقهء خالی = بدون فیلتر. پروژهء چندنوعی چند سطر دارد و هر سطر جدا برمی‌گردد.
        /// strCondition: شرط WHERE ساخته‌شده توسط query-builder صفحهء FilterProject.html (همان قرارداد قالب 1:
        /// کوتیشن‌ها به‌صورت #@# و تاریخ‌های شمسی با پیشوند DDDDDDDDDDD می‌آیند). خالی = بدون شرط.
        /// </summary>
        public static DataTable FetchPWAProjects(string strProjectType, string strRegion, string strCondition)
        {
            DataTable objDatatable = new DataTable();
            try
            {
                string strExtra = PWABuildConditionSql(strCondition);

                using (SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString()))
                {
                    objSqlConnection.Open();
                    string Strsql = " SELECT " + PWAINFO_SELECT_COLUMNS +
                                    " FROM dbo.PWAInfo " +
                                    " WHERE Lat IS NOT NULL AND [Long] IS NOT NULL " +
                                    "   AND (@ProjectType = N'' OR ProjectType = @ProjectType) " +
                                    "   AND (@Region = N'' OR Region = @Region) " +
                                    (strExtra.Length > 0 ? "   AND ( " + strExtra + " ) " : "") +
                                    " ORDER BY Region, ProjectName ";
                    SqlCommand objCmd = new SqlCommand(Strsql, objSqlConnection);
                    objCmd.Parameters.Add("@ProjectType", SqlDbType.NVarChar, 50).Value = (strProjectType ?? "").Trim();
                    objCmd.Parameters.Add("@Region", SqlDbType.NVarChar, 50).Value = (strRegion ?? "").Trim();
                    SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(objCmd);
                    objSqlDataAdapter.Fill(objDatatable);

                    // برگه‌های واقعی (dbo.MapSheets از طریق dbo.MapSheetProjects) هر پروژه به‌صورت JSON در ستون Sheets؛ وب‌پارت پین را روی مرکز برگه می‌گذارد،
                    // مرز واقعی برگه را می‌کشد و این پروژه‌ها را از ساخت ناحیهء تقریبی منطقه کنار می‌گذارد.
                    // اگر جدول MapSheets روی این پایگاه نباشد، فقط لاگ می‌شود و ستون خالی می‌ماند.
                    AttachMapSheetsToProjects(objDatatable, objSqlConnection);
                    objSqlConnection.Close();
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile("FetchPWAProjects: " + e.Message);
            }
            return objDatatable;
        }

        /// <summary>ستون Sheets (JSON آرایهء برگه‌های متصل به هر ProjectCode از طریق MapSheetProjects) را به جدول پروژه‌ها اضافه می‌کند؛ بدون برگه: []</summary>
        private static void AttachMapSheetsToProjects(DataTable objProjects, SqlConnection objSqlConnection)
        {
            if (!objProjects.Columns.Contains("Sheets")) { objProjects.Columns.Add("Sheets", typeof(string)); }
            foreach (DataRow r in objProjects.Rows) { r["Sheets"] = "[]"; }

            List<string> codes = new List<string>();
            foreach (DataRow r in objProjects.Rows)
            {
                string c = r["ProjectCode"] == DBNull.Value ? "" : Convert.ToString(r["ProjectCode"]).Trim();
                if (c.Length > 0 && !codes.Contains(c)) { codes.Add(c); }
            }
            if (codes.Count == 0) { return; }

            Dictionary<string, List<Dictionary<string, string>>> byCode = new Dictionary<string, List<Dictionary<string, string>>>();
            try
            {
                for (int start = 0; start < codes.Count; start += 200)
                {
                    List<string> names = new List<string>();
                    SqlCommand objCmd = new SqlCommand();
                    objCmd.Connection = objSqlConnection;
                    for (int i = start; i < Math.Min(codes.Count, start + 200); i++)
                    {
                        string prm = "@c" + i;
                        names.Add(prm);
                        objCmd.Parameters.Add(prm, SqlDbType.VarChar, 20).Value = codes[i];
                    }
                    objCmd.CommandText = " SELECT l.ProjectCode, ms.SheetNo, ms.SheetScale, ms.SheetSeries, ms.SheetQuarter, ms.SheetNameFa, ms.SheetNameEn, " +
                                         "        ms.CentroidLat, ms.CentroidLong, ms.AreaKm2, ms.Boundary, ms.SourceFile, ms.SourceLayer, ms.SourceCrs, " +
                                         "        l.ProjectName AS LinkProjectName, l.Contractor, l.Supervisor, l.Geologist " +
                                         " FROM dbo.MapSheetProjects l JOIN dbo.MapSheets ms ON ms.ID = l.SheetID " +
                                         " WHERE l.ProjectCode IN (" + string.Join(",", names.ToArray()) + ") ORDER BY l.ProjectCode, ms.SheetNo ";
                    DataTable objSheets = new DataTable();
                    new SqlDataAdapter(objCmd).Fill(objSheets);
                    foreach (DataRow sr in objSheets.Rows)
                    {
                        string code = Convert.ToString(sr["ProjectCode"]).Trim();
                        Dictionary<string, string> item = new Dictionary<string, string>();
                        foreach (DataColumn col in objSheets.Columns)
                        {
                            if (col.ColumnName == "ProjectCode") { continue; }
                            object v = sr[col.ColumnName];
                            item[col.ColumnName] = (v is decimal || v is double || v is float) ? ToInvariantNumber(v) : (v == null || v == DBNull.Value ? "" : v.ToString());
                        }
                        if (!byCode.ContainsKey(code)) { byCode[code] = new List<Dictionary<string, string>>(); }
                        byCode[code].Add(item);
                    }
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile("FetchPWAProjects.AttachMapSheetsToProjects: " + e.Message);
                return;
            }

            JavaScriptSerializer ser = new JavaScriptSerializer();
            ser.MaxJsonLength = int.MaxValue;
            foreach (DataRow r in objProjects.Rows)
            {
                string c = r["ProjectCode"] == DBNull.Value ? "" : Convert.ToString(r["ProjectCode"]).Trim();
                if (c.Length > 0 && byCode.ContainsKey(c)) { r["Sheets"] = ser.Serialize(byCode[c]); }
            }
        }

        // ستون‌هایی که در شرط جستجو مجازند (شناسهء فیلترهای demo_widgetsProject.js)
        private static readonly string[] PWA_FILTER_COLUMNS = new string[] {
            "ProjectName", "ProjectCode", "ProjectType", "Region", "Status", "ExecutionMethod", "TahaghoghCategory",
            "PlannedProgress", "ActualProgress", "AchievementPct", "StartDate", "FinishDate", "PlannedStart", "PlannedFinish",
            "ProjectManager", "ProjectSupervisor", "OrgLevel1", "OrgLevel2", "TotalCost" };

        /// <summary>
        /// شرط query-builder را به SQL قابل استفاده تبدیل می‌کند:
        ///   #@# -> '   ،   DDDDDDDDDDD'yyyy/mm/dd' (شمسی) -> 'yyyy-MM-dd' (میلادی)
        /// و یک کنترل ایمنی ساده انجام می‌دهد: فقط ستون‌های مجاز، بدون ; -- /* و دستورات غیر از مقایسه.
        /// در صورت تشخیص محتوای نامعتبر، شرط نادیده گرفته می‌شود و در لاگ نوشته می‌شود.
        /// </summary>
        private static string PWABuildConditionSql(string strCondition)
        {
            return BuildConditionSql(strCondition, PWA_FILTER_COLUMNS, "FetchPWAProjects");
        }

        /// <summary>نسخهء عمومی سازندهء شرط: فهرست ستون‌های مجاز و برچسب لاگ را می‌گیرد (PWAInfo و MapSheets از همین استفاده می‌کنند)</summary>
        private static string BuildConditionSql(string strCondition, string[] allowedColumns, string strLogTag)
        {
            if (strCondition == null) { return ""; }
            string cond = strCondition.Trim();
            if (cond.Length == 0) { return ""; }

            cond = cond.Replace("#@#", "'");

            // تاریخ‌های شمسی
            cond = Regex.Replace(cond, @"DDDDDDDDDDD'%?(\d{4})/(\d{1,2})/(\d{1,2})%?'", delegate (Match m)
            {
                try
                {
                    PersianCalendar cal = new PersianCalendar();
                    DateTime dt = new DateTime(Convert.ToInt32(m.Groups[1].Value), Convert.ToInt32(m.Groups[2].Value), Convert.ToInt32(m.Groups[3].Value), cal);
                    return "'" + dt.ToString("yyyy-MM-dd") + "'";
                }
                catch (Exception)
                {
                    return "'" + m.Groups[1].Value + "-" + m.Groups[2].Value.PadLeft(2, '0') + "-" + m.Groups[3].Value.PadLeft(2, '0') + "'";
                }
            });
            cond = cond.Replace("DDDDDDDDDDD", "");

            // کنترل ایمنی
            string lowered = cond.ToLowerInvariant();
            if (lowered.Contains(";") || lowered.Contains("--") || lowered.Contains("/*") || lowered.Contains("*/") ||
                Regex.IsMatch(lowered, @"\b(select|insert|update|delete|drop|alter|exec|execute|union|truncate|merge|create|grant|xp_|sp_)\b"))
            {
                ClsHelpper.WriteToLogFile(strLogTag + ": شرط جستجو رد شد (محتوای غیرمجاز): " + strCondition);
                return "";
            }

            // شناسه‌های بیرون از رشته‌ها باید یا ستون مجاز باشند یا کلیدواژهء مقایسه
            string noStrings = Regex.Replace(cond, @"N?'([^']|'')*'", " ");
            string[] allowedWords = new string[] { "and", "or", "not", "like", "in", "between", "is", "null", "n" };
            foreach (Match m in Regex.Matches(noStrings, @"[A-Za-z_][A-Za-z0-9_]*"))
            {
                string w = m.Value;
                if (Array.IndexOf(allowedWords, w.ToLowerInvariant()) >= 0) { continue; }
                bool ok = false;
                foreach (string c in allowedColumns) { if (string.Equals(c, w, StringComparison.OrdinalIgnoreCase)) { ok = true; break; } }
                if (!ok)
                {
                    ClsHelpper.WriteToLogFile(strLogTag + ": شرط جستجو رد شد (ستون نامعتبر " + w + "): " + strCondition);
                    return "";
                }
            }
            return cond;
        }

        #region MapSheets (وب‌پارت ShowAllMapSheetInfo)

        /// <summary>نتیجهء یک بار Import برگه‌ها (مدل دو جدولی: MapSheets + MapSheetProjects)</summary>
        public class MapSheetsImportResult
        {
            public Guid Batch;
            public int SheetsInserted;                             // برگه‌های جدید
            public int SheetsUpdated;                              // برگه‌هایی که هندسه/نامشان بازنویسی شد
            public int Inserted;                                   // اتصال‌های جدید (برگه‌ـ‌پروژه)
            public int Updated;                                    // اتصال‌های بازنویسی‌شده
            public int Skipped;                                    // اتصال‌های تکراری که رد شدند
            public int Failed;
            public int Unlinked;                                   // رکوردهای بدون کد یا با کدی که در PWAInfo نیست
            public List<string> Messages = new List<string>();     // پیام هر رکورد به ترتیب فایل
        }

        /// <summary>
        /// رکوردهای خوانده‌شده از Shapefile را ثبت می‌کند:
        ///   1) برگه: upsert روی (SheetScale, SheetNo). برگهء موجود فقط با bOverwrite بازنویسی می‌شود.
        ///   2) اتصال: اگر رکورد ProjectCode دارد، upsert روی (SheetID, ProjectCode). اتصال موجود بدون bOverwrite رد می‌شود.
        /// کد پروژه‌ای که در PWAInfo نباشد خطا نیست؛ فقط در پیام‌ها علامت می‌خورد تا به کارفرما گزارش شود.
        /// </summary>
        public static MapSheetsImportResult ImportMapSheets(List<MapSheetRecord> records, bool bOverwrite, string strSourceFile, string strImportedBy)
        {
            MapSheetsImportResult res = new MapSheetsImportResult();
            res.Batch = Guid.NewGuid();
            if (records == null || records.Count == 0) { return res; }

            try
            {
                using (SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString()))
                {
                    objSqlConnection.Open();

                    SqlCommand cmdSheetExists = new SqlCommand("SELECT ID FROM dbo.MapSheets WHERE SheetScale = @Scale AND SheetNo = @SheetNo", objSqlConnection);
                    cmdSheetExists.Parameters.Add("@Scale", SqlDbType.Int);
                    cmdSheetExists.Parameters.Add("@SheetNo", SqlDbType.NVarChar, 20);

                    SqlCommand cmdLinkExists = new SqlCommand("SELECT ID FROM dbo.MapSheetProjects WHERE SheetID = @SheetID AND ProjectCode = @Code", objSqlConnection);
                    cmdLinkExists.Parameters.Add("@SheetID", SqlDbType.Int);
                    cmdLinkExists.Parameters.Add("@Code", SqlDbType.VarChar, 20);

                    SqlCommand cmdPwa = new SqlCommand("SELECT COUNT(*) FROM dbo.PWAInfo WHERE ProjectCode = @Code", objSqlConnection);
                    cmdPwa.Parameters.Add("@Code", SqlDbType.VarChar, 20);

                    // ---- برگه ----
                    SqlCommand cmdSheetInsert = new SqlCommand(
                        "INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa, " +
                        " Boundary, VertexCount, CentroidLat, CentroidLong, MinLat, MinLong, MaxLat, MaxLong, AreaKm2, " +
                        " SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedAt, ImportedBy) " +
                        " VALUES (@SheetNo, @SheetScale, @SheetSeries, @SheetQuarter, @SourceSheetID, @SheetNameEn, @SheetNameFa, " +
                        " @Boundary, @VertexCount, @CentroidLat, @CentroidLong, @MinLat, @MinLong, @MaxLat, @MaxLong, @AreaKm2, " +
                        " @SourceFile, @SourceLayer, @SourceCrs, @ImportBatch, GETDATE(), @ImportedBy); SELECT CAST(SCOPE_IDENTITY() AS INT);", objSqlConnection);
                    SqlCommand cmdSheetUpdate = new SqlCommand(
                        "UPDATE dbo.MapSheets SET SheetSeries=@SheetSeries, SheetQuarter=@SheetQuarter, SourceSheetID=@SourceSheetID, " +
                        " SheetNameEn=@SheetNameEn, SheetNameFa=@SheetNameFa, Boundary=@Boundary, VertexCount=@VertexCount, " +
                        " CentroidLat=@CentroidLat, CentroidLong=@CentroidLong, MinLat=@MinLat, MinLong=@MinLong, MaxLat=@MaxLat, MaxLong=@MaxLong, " +
                        " AreaKm2=@AreaKm2, SourceFile=@SourceFile, SourceLayer=@SourceLayer, SourceCrs=@SourceCrs, " +
                        " ImportBatch=@ImportBatch, ImportedBy=@ImportedBy, UpdatedAt=GETDATE() WHERE ID=@ID", objSqlConnection);
                    cmdSheetUpdate.Parameters.Add("@ID", SqlDbType.Int);
                    foreach (SqlCommand cmd in new[] { cmdSheetInsert, cmdSheetUpdate })
                    {
                        cmd.Parameters.Add("@SheetNo", SqlDbType.NVarChar, 20);
                        cmd.Parameters.Add("@SheetScale", SqlDbType.Int);
                        cmd.Parameters.Add("@SheetSeries", SqlDbType.NVarChar, 10);
                        cmd.Parameters.Add("@SheetQuarter", SqlDbType.NVarChar, 4);
                        cmd.Parameters.Add("@SourceSheetID", SqlDbType.BigInt);
                        cmd.Parameters.Add("@SheetNameEn", SqlDbType.NVarChar, 100);
                        cmd.Parameters.Add("@SheetNameFa", SqlDbType.NVarChar, 100);
                        cmd.Parameters.Add("@Boundary", SqlDbType.NVarChar, -1);
                        cmd.Parameters.Add("@VertexCount", SqlDbType.Int);
                        cmd.Parameters.Add("@CentroidLat", SqlDbType.Decimal);
                        cmd.Parameters.Add("@CentroidLong", SqlDbType.Decimal);
                        cmd.Parameters.Add("@MinLat", SqlDbType.Decimal);
                        cmd.Parameters.Add("@MinLong", SqlDbType.Decimal);
                        cmd.Parameters.Add("@MaxLat", SqlDbType.Decimal);
                        cmd.Parameters.Add("@MaxLong", SqlDbType.Decimal);
                        cmd.Parameters.Add("@AreaKm2", SqlDbType.Decimal);
                        cmd.Parameters.Add("@SourceFile", SqlDbType.NVarChar, 255);
                        cmd.Parameters.Add("@SourceLayer", SqlDbType.NVarChar, 100);
                        cmd.Parameters.Add("@SourceCrs", SqlDbType.NVarChar, 200);
                        cmd.Parameters.Add("@ImportBatch", SqlDbType.UniqueIdentifier);
                        cmd.Parameters.Add("@ImportedBy", SqlDbType.NVarChar, 100);
                        foreach (SqlParameter prm in cmd.Parameters)
                        {
                            if (prm.SqlDbType != SqlDbType.Decimal) { continue; }
                            if (prm.ParameterName == "@AreaKm2") { prm.Precision = 12; prm.Scale = 3; }
                            else { prm.Precision = 9; prm.Scale = 6; }
                        }
                    }

                    // ---- اتصال ----
                    SqlCommand cmdLinkInsert = new SqlCommand(
                        "INSERT INTO dbo.MapSheetProjects (SheetID, ProjectCode, ProjectName, Contractor, Supervisor, Geologist, ExtraAttributes, " +
                        " SourceFile, SourceLayer, ImportBatch, ImportedAt, ImportedBy) " +
                        " VALUES (@SheetID, @Code, @ProjectName, @Contractor, @Supervisor, @Geologist, @ExtraAttributes, " +
                        " @SourceFile, @SourceLayer, @ImportBatch, GETDATE(), @ImportedBy)", objSqlConnection);
                    SqlCommand cmdLinkUpdate = new SqlCommand(
                        "UPDATE dbo.MapSheetProjects SET ProjectName=@ProjectName, Contractor=@Contractor, Supervisor=@Supervisor, Geologist=@Geologist, " +
                        " ExtraAttributes=@ExtraAttributes, SourceFile=@SourceFile, SourceLayer=@SourceLayer, ImportBatch=@ImportBatch, " +
                        " ImportedBy=@ImportedBy, UpdatedAt=GETDATE() WHERE ID=@ID", objSqlConnection);
                    cmdLinkUpdate.Parameters.Add("@ID", SqlDbType.Int);
                    foreach (SqlCommand cmd in new[] { cmdLinkInsert, cmdLinkUpdate })
                    {
                        cmd.Parameters.Add("@SheetID", SqlDbType.Int);
                        cmd.Parameters.Add("@Code", SqlDbType.VarChar, 20);
                        cmd.Parameters.Add("@ProjectName", SqlDbType.NVarChar, 200);
                        cmd.Parameters.Add("@Contractor", SqlDbType.NVarChar, 100);
                        cmd.Parameters.Add("@Supervisor", SqlDbType.NVarChar, 100);
                        cmd.Parameters.Add("@Geologist", SqlDbType.NVarChar, 100);
                        cmd.Parameters.Add("@ExtraAttributes", SqlDbType.NVarChar, -1);
                        cmd.Parameters.Add("@SourceFile", SqlDbType.NVarChar, 255);
                        cmd.Parameters.Add("@SourceLayer", SqlDbType.NVarChar, 100);
                        cmd.Parameters.Add("@ImportBatch", SqlDbType.UniqueIdentifier);
                        cmd.Parameters.Add("@ImportedBy", SqlDbType.NVarChar, 100);
                    }

                    foreach (MapSheetRecord rec in records)
                    {
                        try
                        {
                            // 1) برگه
                            cmdSheetExists.Parameters["@Scale"].Value = rec.SheetScale;
                            cmdSheetExists.Parameters["@SheetNo"].Value = rec.SheetNo;
                            object oSheetId = cmdSheetExists.ExecuteScalar();
                            int nSheetId;
                            string strSheetAction;
                            if (oSheetId == null || oSheetId == DBNull.Value)
                            {
                                FillSheetParams(cmdSheetInsert, rec, strSourceFile, strImportedBy, res.Batch);
                                nSheetId = Convert.ToInt32(cmdSheetInsert.ExecuteScalar());
                                res.SheetsInserted++;
                                strSheetAction = "برگه ثبت شد";
                            }
                            else
                            {
                                nSheetId = Convert.ToInt32(oSheetId);
                                if (bOverwrite)
                                {
                                    FillSheetParams(cmdSheetUpdate, rec, strSourceFile, strImportedBy, res.Batch);
                                    cmdSheetUpdate.Parameters["@ID"].Value = nSheetId;
                                    cmdSheetUpdate.ExecuteNonQuery();
                                    res.SheetsUpdated++;
                                    strSheetAction = "برگه بازنویسی شد";
                                }
                                else
                                {
                                    strSheetAction = "برگه از قبل موجود بود";
                                }
                            }

                            // 2) اتصال به پروژه
                            string strWarn = rec.Warnings.Count > 0 ? " | " + string.Join(" ", rec.Warnings.ToArray()) : "";
                            if (string.IsNullOrEmpty(rec.ProjectCode))
                            {
                                res.Unlinked++;
                                res.Messages.Add(rec.Label + ": " + strSheetAction + " | بدون کد پروژه (به هیچ پروژه‌ای وصل نشد)" + strWarn);
                                continue;
                            }

                            cmdPwa.Parameters["@Code"].Value = rec.ProjectCode;
                            int nPwa = Convert.ToInt32(cmdPwa.ExecuteScalar());
                            string strLink;
                            if (nPwa == 0)
                            {
                                res.Unlinked++;
                                strLink = " | کد " + rec.ProjectCode + " در PWAInfo نیست";
                            }
                            else
                            {
                                strLink = " | متصل به PWAInfo (" + nPwa + " سطر)";
                            }

                            cmdLinkExists.Parameters["@SheetID"].Value = nSheetId;
                            cmdLinkExists.Parameters["@Code"].Value = rec.ProjectCode;
                            object oLinkId = cmdLinkExists.ExecuteScalar();
                            SqlCommand cmdLink;
                            string strLinkAction;
                            if (oLinkId == null || oLinkId == DBNull.Value)
                            {
                                cmdLink = cmdLinkInsert;
                                strLinkAction = "پروژه " + rec.ProjectCode + " به برگه وصل شد";
                            }
                            else if (bOverwrite)
                            {
                                cmdLink = cmdLinkUpdate;
                                cmdLink.Parameters["@ID"].Value = Convert.ToInt32(oLinkId);
                                strLinkAction = "اتصال پروژه " + rec.ProjectCode + " بازنویسی شد";
                            }
                            else
                            {
                                res.Skipped++;
                                res.Messages.Add(rec.Label + ": " + strSheetAction + " | اتصال پروژه " + rec.ProjectCode + " از قبل وجود دارد؛ رد شد (برای بازنویسی گزینهء مربوطه را فعال کنید)" + strLink + strWarn);
                                continue;
                            }

                            cmdLink.Parameters["@SheetID"].Value = nSheetId;
                            cmdLink.Parameters["@Code"].Value = rec.ProjectCode;
                            cmdLink.Parameters["@ProjectName"].Value = NullIfEmpty(rec.ProjectName);
                            cmdLink.Parameters["@Contractor"].Value = NullIfEmpty(rec.Contractor);
                            cmdLink.Parameters["@Supervisor"].Value = NullIfEmpty(rec.Supervisor);
                            cmdLink.Parameters["@Geologist"].Value = NullIfEmpty(rec.Geologist);
                            cmdLink.Parameters["@ExtraAttributes"].Value = NullIfEmpty(rec.ExtraAttributesJson);
                            cmdLink.Parameters["@SourceFile"].Value = NullIfEmpty(strSourceFile);
                            cmdLink.Parameters["@SourceLayer"].Value = NullIfEmpty(rec.SourceLayer);
                            cmdLink.Parameters["@ImportBatch"].Value = res.Batch;
                            cmdLink.Parameters["@ImportedBy"].Value = NullIfEmpty(strImportedBy);
                            cmdLink.ExecuteNonQuery();

                            if (cmdLink == cmdLinkInsert) { res.Inserted++; } else { res.Updated++; }
                            res.Messages.Add(rec.Label + ": " + strSheetAction + " | " + strLinkAction + strLink + strWarn);
                        }
                        catch (Exception exRow)
                        {
                            res.Failed++;
                            res.Messages.Add(rec.Label + ": خطا در ثبت: " + exRow.Message);
                            ClsHelpper.WriteToLogFile("ImportMapSheets row " + rec.Label + ": " + exRow.Message);
                        }
                    }
                    objSqlConnection.Close();
                }
            }
            catch (Exception e)
            {
                res.Failed += Math.Max(0, records.Count - res.Inserted - res.Updated - res.Skipped - res.Failed);
                res.Messages.Add("خطای کلی در اتصال یا ثبت: " + e.Message);
                ClsHelpper.WriteToLogFile("ImportMapSheets: " + e.Message);
            }
            return res;
        }

        private static void FillSheetParams(SqlCommand cmd, MapSheetRecord rec, string strSourceFile, string strImportedBy, Guid gBatch)
        {
            cmd.Parameters["@SheetNo"].Value = rec.SheetNo;
            cmd.Parameters["@SheetScale"].Value = rec.SheetScale;
            cmd.Parameters["@SheetSeries"].Value = NullIfEmpty(rec.SheetSeries);
            cmd.Parameters["@SheetQuarter"].Value = NullIfEmpty(rec.SheetQuarter);
            cmd.Parameters["@SourceSheetID"].Value = rec.SourceSheetID.HasValue ? (object)rec.SourceSheetID.Value : DBNull.Value;
            cmd.Parameters["@SheetNameEn"].Value = NullIfEmpty(rec.SheetNameEn);
            cmd.Parameters["@SheetNameFa"].Value = NullIfEmpty(rec.SheetNameFa);
            cmd.Parameters["@Boundary"].Value = rec.BoundaryJson;
            cmd.Parameters["@VertexCount"].Value = rec.Boundary.Count;
            cmd.Parameters["@CentroidLat"].Value = rec.CentroidLat;
            cmd.Parameters["@CentroidLong"].Value = rec.CentroidLong;
            cmd.Parameters["@MinLat"].Value = rec.MinLat;
            cmd.Parameters["@MinLong"].Value = rec.MinLong;
            cmd.Parameters["@MaxLat"].Value = rec.MaxLat;
            cmd.Parameters["@MaxLong"].Value = rec.MaxLong;
            cmd.Parameters["@AreaKm2"].Value = rec.AreaKm2;
            cmd.Parameters["@SourceFile"].Value = NullIfEmpty(strSourceFile);
            cmd.Parameters["@SourceLayer"].Value = NullIfEmpty(rec.SourceLayer);
            cmd.Parameters["@SourceCrs"].Value = NullIfEmpty(rec.SourceCrs);
            cmd.Parameters["@ImportBatch"].Value = gBatch;
            cmd.Parameters["@ImportedBy"].Value = NullIfEmpty(strImportedBy);
        }

        private static object NullIfEmpty(string s)
        {
            if (s == null) { return DBNull.Value; }
            s = s.Trim();
            return s.Length == 0 ? (object)DBNull.Value : s;
        }

        private const string MAPSHEETS_SELECT_COLUMNS =
            " ID, LinkID, SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa, " +
            " ProjectCode, SheetProjectName, Contractor, Supervisor, Geologist, " +
            " Boundary, VertexCount, CentroidLat, CentroidLong, MinLat, MinLong, MaxLat, MaxLong, AreaKm2, " +
            " SourceFile, SourceLayer, SourceCrs, LinkSourceFile, ImportBatch, ImportedAt, ImportedBy, UpdatedAt, " +
            " PwaRowCount, PwaID, ProjectName, Status, PlannedProgress, ActualProgress, AchievementPct, " +
            " StartDateJ, FinishDateJ, PlannedStartJ, PlannedFinishJ, ProjectType, Region, ExecutionMethod, " +
            " ProjectManager, ProjectSupervisor, PwaLat, PwaLong, TahaghoghCategory ";

        // ستون‌هایی که در شرط جستجوی پیشرفتهء برگه‌ها مجازند (شناسهء فیلترهای Filter\js\demo_widgetsMapSheet.js = ستون‌های vw_MapSheetsProjects)
        private static readonly string[] MAPSHEETS_FILTER_COLUMNS = new string[] {
            "SheetNo", "SheetNameFa", "SheetNameEn", "SheetSeries", "SheetQuarter", "SheetScale", "SourceSheetID",
            "Contractor", "Supervisor", "Geologist", "AreaKm2", "ImportedAt", "SourceFile", "SourceLayer", "LinkSourceFile", "SheetProjectName", "LinkID",
            "PwaID", "PwaRowCount", "ProjectCode", "ProjectName", "ProjectType", "Region", "Status", "ExecutionMethod", "TahaghoghCategory",
            "PlannedProgress", "ActualProgress", "AchievementPct", "StartDate", "FinishDate", "PlannedStart", "PlannedFinish",
            "ProjectManager", "ProjectSupervisor", "OrgLevel1", "OrgLevel2", "TotalCost" };

        /// <summary>
        /// جفت‌های برگه‌ـ‌پروژه به همراه اطلاعات پروژهء PWA (نمای vw_MapSheetsProjects). هر فیلتر خالی = بدون فیلتر.
        /// strRegion: منطقهء پروژهء متصل؛ مقدار ویژهء *NOPWA* = فقط اتصال‌هایی که کدشان در PWAInfo نیست.
        /// strSheet: بخشی از شمارهء برگه یا نام برگه (LIKE)؛ strImportBatch: GUID یک بارگذاری (اتصال‌ها).
        /// strCondition: شرط query-builder صفحهء FilterMapSheet.html (همان قرارداد PWAInfo: کوتیشن #@# و تاریخ شمسی با پیشوند DDDDDDDDDDD).
        /// شرط و منطقه روی همهء سطرهای PWA هر اتصال ارزیابی می‌شوند (EXISTS روی vw_MapSheetsProjectsAll با کلید LinkID):
        /// اتصالی برمی‌گردد که دست‌کم یکی از سطرهای پروژه‌اش کل شرط را برآورده کند. خروجی همچنان یک سطر برای هر اتصال است.
        /// </summary>
        public static DataTable FetchMapSheets(string strRegion, string strSheet, string strImportBatch, string strCondition)
        {
            DataTable objDatatable = new DataTable();
            try
            {
                Guid gBatch = Guid.Empty;
                bool bHasBatch = !string.IsNullOrEmpty(strImportBatch) && Guid.TryParse(strImportBatch.Trim(), out gBatch);
                string strRegionValue = (strRegion ?? "").Trim();
                bool bOnlyUnlinked = strRegionValue == "*NOPWA*";
                string strExtra = BuildConditionSql(strCondition, MAPSHEETS_FILTER_COLUMNS, "FetchMapSheets");

                using (SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString()))
                {
                    objSqlConnection.Open();
                    // منطقه و شرط پیشرفته روی همهء سطرهای PWA اتصال (نمای All) با EXISTS؛ نام ستون‌های شرط بدون پیشوند به
                    // جدول داخلی (a) بسته می‌شوند چون همهء ستون‌های مجاز در آن نما هستند
                    string strAllExists = " EXISTS (SELECT 1 FROM dbo.vw_MapSheetsProjectsAll a WHERE a.LinkID = v.LinkID AND ( {0} )) ";
                    string Strsql = " SELECT " + MAPSHEETS_SELECT_COLUMNS +
                                    " FROM dbo.vw_MapSheetsProjects v " +
                                    " WHERE (@Sheet = N'' OR v.SheetNo LIKE N'%' + @Sheet + N'%' OR v.SheetNameFa LIKE N'%' + @Sheet + N'%' OR v.SheetNameEn LIKE N'%' + @Sheet + N'%') " +
                                    (bOnlyUnlinked ? "   AND v.PwaID IS NULL " : "   AND (@Region = N'' OR " + string.Format(strAllExists, "a.Region = @Region") + ") ") +
                                    (bHasBatch ? "   AND v.ImportBatch = @Batch " : "") +
                                    (strExtra.Length > 0 ? "   AND " + string.Format(strAllExists, strExtra) : "") +
                                    " ORDER BY v.SheetScale, v.SheetNo, v.ProjectCode ";
                    SqlCommand objCmd = new SqlCommand(Strsql, objSqlConnection);
                    objCmd.Parameters.Add("@Sheet", SqlDbType.NVarChar, 100).Value = (strSheet ?? "").Trim();
                    objCmd.Parameters.Add("@Region", SqlDbType.NVarChar, 50).Value = bOnlyUnlinked ? "" : strRegionValue;
                    if (bHasBatch) { objCmd.Parameters.Add("@Batch", SqlDbType.UniqueIdentifier).Value = gBatch; }
                    SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(objCmd);
                    objSqlDataAdapter.Fill(objDatatable);

                    // همهء سطرهای PWAInfo هر کد (پروژهء چندنوعی = چند سطر) به‌صورت JSON در ستون PwaRows؛
                    // وب‌پارت با آن تب‌های پنجرهء اطلاعات و رنگ میانگین برگه را می‌سازد (همان رفتار پین‌های ShowAllProjectInfo)
                    AttachPwaRows(objDatatable, objSqlConnection);
                    objSqlConnection.Close();
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile("FetchMapSheets: " + e.Message);
            }
            return objDatatable;
        }

        /// <summary>ستون PwaRows (JSON آرایهء سطرهای PWAInfo با همان کد) را به جدول برگه‌ها اضافه می‌کند؛ بدون کد یا بدون سطر: []</summary>
        private static void AttachPwaRows(DataTable objSheets, SqlConnection objSqlConnection)
        {
            if (!objSheets.Columns.Contains("PwaRows")) { objSheets.Columns.Add("PwaRows", typeof(string)); }
            foreach (DataRow r in objSheets.Rows) { r["PwaRows"] = "[]"; }

            List<string> codes = new List<string>();
            foreach (DataRow r in objSheets.Rows)
            {
                string c = r["ProjectCode"] == DBNull.Value ? "" : Convert.ToString(r["ProjectCode"]).Trim();
                if (c.Length > 0 && !codes.Contains(c)) { codes.Add(c); }
            }
            if (codes.Count == 0) { return; }

            Dictionary<string, List<Dictionary<string, string>>> byCode = new Dictionary<string, List<Dictionary<string, string>>>();
            try
            {
                // کدها دسته‌ای (حداکثر 200 پارامتر در هر پرس‌وجو)
                for (int start = 0; start < codes.Count; start += 200)
                {
                    List<string> names = new List<string>();
                    SqlCommand objCmd = new SqlCommand();
                    objCmd.Connection = objSqlConnection;
                    for (int i = start; i < Math.Min(codes.Count, start + 200); i++)
                    {
                        string prm = "@c" + i;
                        names.Add(prm);
                        objCmd.Parameters.Add(prm, SqlDbType.VarChar, 20).Value = codes[i];
                    }
                    objCmd.CommandText = " SELECT " + PWAINFO_SELECT_COLUMNS + " FROM dbo.PWAInfo WHERE ProjectCode IN (" + string.Join(",", names.ToArray()) + ") ORDER BY ProjectCode, ID ";
                    DataTable objPwa = new DataTable();
                    new SqlDataAdapter(objCmd).Fill(objPwa);
                    foreach (DataRow pr in objPwa.Rows)
                    {
                        string code = Convert.ToString(pr["ProjectCode"]).Trim();
                        Dictionary<string, string> item = new Dictionary<string, string>();
                        foreach (DataColumn col in objPwa.Columns)
                        {
                            object v = pr[col.ColumnName];
                            item[col.ColumnName] = (v is decimal || v is double || v is float) ? ToInvariantNumber(v) : (v == null || v == DBNull.Value ? "" : v.ToString());
                        }
                        if (!byCode.ContainsKey(code)) { byCode[code] = new List<Dictionary<string, string>>(); }
                        byCode[code].Add(item);
                    }
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile("FetchMapSheets.AttachPwaRows: " + e.Message);
                return;
            }

            JavaScriptSerializer ser = new JavaScriptSerializer();
            ser.MaxJsonLength = int.MaxValue;
            foreach (DataRow r in objSheets.Rows)
            {
                string c = r["ProjectCode"] == DBNull.Value ? "" : Convert.ToString(r["ProjectCode"]).Trim();
                if (c.Length > 0 && byCode.ContainsKey(c)) { r["PwaRows"] = ser.Serialize(byCode[c]); }
            }
        }

        /// <summary>
        /// خلاصهء هر بارگذاری (برای فهرست ادمین)؛ جدیدترین اول. برگه‌ها و اتصال‌های یک بارگذاری همان ImportBatch را دارند.
        /// Sheets = تعداد برگه‌های درگیر، Links = تعداد اتصال پروژه، WithoutCode = برگه‌های این بارگذاری که هیچ پروژه‌ای ندارند،
        /// NotInPwa = اتصال‌هایی که کدشان در PWAInfo نیست.
        /// </summary>
        public static DataTable FetchMapSheetsImportBatches()
        {
            DataTable objDatatable = new DataTable();
            try
            {
                using (SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString()))
                {
                    objSqlConnection.Open();
                    string Strsql =
                        " SELECT u.ImportBatch, MIN(u.ImportedAt) AS ImportedAt, MAX(u.ImportedBy) AS ImportedBy, MAX(u.SourceFile) AS SourceFile, MAX(u.SourceLayer) AS SourceLayer, " +
                        "        COUNT(DISTINCT u.SheetID) AS Sheets, SUM(u.IsLink) AS Links, SUM(u.WithoutCode) AS WithoutCode, SUM(u.NotInPwa) AS NotInPwa " +
                        " FROM ( " +
                        "   SELECT ms.ImportBatch, ms.ImportedAt, ms.ImportedBy, ms.SourceFile, ms.SourceLayer, ms.ID AS SheetID, 0 AS IsLink, " +
                        "          CASE WHEN NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects l WHERE l.SheetID = ms.ID) THEN 1 ELSE 0 END AS WithoutCode, 0 AS NotInPwa " +
                        "   FROM dbo.MapSheets ms " +
                        "   UNION ALL " +
                        "   SELECT mp.ImportBatch, mp.ImportedAt, mp.ImportedBy, mp.SourceFile, mp.SourceLayer, mp.SheetID, 1, 0, " +
                        "          CASE WHEN NOT EXISTS (SELECT 1 FROM dbo.PWAInfo p WHERE p.ProjectCode = mp.ProjectCode) THEN 1 ELSE 0 END " +
                        "   FROM dbo.MapSheetProjects mp " +
                        " ) u " +
                        " GROUP BY u.ImportBatch " +
                        " ORDER BY MIN(u.ImportedAt) DESC ";
                    SqlDataAdapter objSqlDataAdapter = new SqlDataAdapter(Strsql, objSqlConnection);
                    objSqlDataAdapter.Fill(objDatatable);
                    objSqlConnection.Close();
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile("FetchMapSheetsImportBatches: " + e.Message);
            }
            return objDatatable;
        }

        /// <summary>
        /// حذف یک بارگذاری: اتصال‌های آن حذف می‌شوند و برگه‌هایی که با همان بارگذاری ساخته شده‌اند و دیگر هیچ اتصالی ندارند هم پاک می‌شوند
        /// (برگه‌ای که از بارگذاری دیگری آمده یا هنوز پروژهء دیگری روی آن است می‌ماند). خروجی: تعداد اتصال + برگهء حذف‌شده؛ 1- = خطا
        /// </summary>
        public static int DeleteMapSheetsImportBatch(string strImportBatch)
        {
            int nResult = -1;
            try
            {
                Guid gBatch;
                if (string.IsNullOrEmpty(strImportBatch) || !Guid.TryParse(strImportBatch.Trim(), out gBatch)) { return -1; }
                using (SqlConnection objSqlConnection = new SqlConnection(strDataBaseConnectionString()))
                {
                    objSqlConnection.Open();
                    SqlCommand objCmd = new SqlCommand(
                        " DELETE FROM dbo.MapSheetProjects WHERE ImportBatch = @Batch; " +
                        " DECLARE @n INT = @@ROWCOUNT; " +
                        " DELETE FROM dbo.MapSheets WHERE ImportBatch = @Batch AND NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects l WHERE l.SheetID = MapSheets.ID); " +
                        " SELECT @n + @@ROWCOUNT; ", objSqlConnection);
                    objCmd.Parameters.Add("@Batch", SqlDbType.UniqueIdentifier).Value = gBatch;
                    nResult = Convert.ToInt32(objCmd.ExecuteScalar());
                    objSqlConnection.Close();
                }
            }
            catch (Exception e)
            {
                ClsHelpper.WriteToLogFile("DeleteMapSheetsImportBatch: " + e.Message);
            }
            return nResult;
        }

        #endregion

        #endregion


    }
}
