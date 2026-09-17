using System;
using Microsoft.SharePoint;
using Microsoft.SharePoint.WebControls;
using System.Data;
using System.Web.Services;
using System.Collections.Generic;

namespace Sazmanyar.GIS.Layouts.Sazmanyar.GIS
{
    public partial class ApplicationPage_FetchingData : LayoutsPageBase
    {

        public static string GetNodesItemsAsString_TrradodShomarInfo_forCoridorInDataBase(int nCoridorID)
        {
            DataTable objResultEffectiveTradodShomar = ClsHelpper.Fetch_BaseArrayOfTradodshomarFromCorridorInfoInDataBase(nCoridorID);
            return GetNodesItemsAsString_TrradodShomarInfo_forCoridorInDataTable(objResultEffectiveTradodShomar);
        }

        public static string GetNodesItemsAsString_TrradodShomarInfo_forCoridorInDataTable(DataTable objResultEffectiveTradodShomar)
        {

            if (objResultEffectiveTradodShomar == null)
            {
                return "";
            }

            if (objResultEffectiveTradodShomar.Rows.Count == 0)
            {
                return "";
            }

            string jsArray = string.Empty;
            string strSeperator = Environment.NewLine;
            foreach (DataRow objRowItem in objResultEffectiveTradodShomar.Rows)
            {
                // اگر اطلاعات لت و لانگ آنها مشکل داشت آنها را درج نکند
                try
                {
                    if (objRowItem["Latitude"].ToString().Trim().Length == 0)
                    {
                        continue;
                    }

                    if (objRowItem["Longitude"].ToString().Trim().Length == 0)
                    {
                        continue;
                    }

                    double latValue, longValue;
                    if (!ClsHelpper.TryParseNumber(objRowItem["Latitude"].ToString(), out latValue) || latValue == 0)
                    {
                        continue;
                    }

                    if (!ClsHelpper.TryParseNumber(objRowItem["Longitude"].ToString(), out longValue) || longValue == 0)
                    {
                        continue;
                    }

                }
                catch (Exception)
                {
                    //اگر خطا داد بی خیال این لطف زیادی می شویم
                    continue;
                }

                if (jsArray != string.Empty)
                {
                    jsArray += " , ";
                }

                jsArray += " { ";
                jsArray += " \"ID\" : \"" + objRowItem["Mehvar_ID"].ToString() + "\" ";
                jsArray += ",\"Title\" : \"" + objRowItem["Ostan_Name"].ToString() + "\" ";
                jsArray += ",\"Desc\" : \"" + objRowItem["Mehvar_Name"].ToString() + "\" ";
                jsArray += ",\"Longitude\" : \"" + ClsHelpper.ToInvariantNumber(objRowItem["Longitude"]) + "\" ";
                jsArray += ",\"Latitude\" : \"" + ClsHelpper.ToInvariantNumber(objRowItem["Latitude"]) + "\" ";
                jsArray += ",\"State\" : \"دستگاههاي تردد شمار برخط\" ";

                try
                {
                    jsArray += ",\"m_name\" : \"" + objRowItem["Mehvar_Name"].ToString() + "\" ";

                }
                catch (Exception)
                {
                }
                try
                {
                    jsArray += ",\"Ostan_Name\" : \"" + objRowItem["o_name"].ToString() + "\" ";

                }
                catch (Exception)
                {
                }
                try
                {
                    jsArray += ",\"spd\" : \"" + objRowItem["Speed"].ToString() + "\" ";

                }
                catch (Exception)
                {
                }

                try
                {
                    jsArray += ",\"cnt\" : \"" + objRowItem["Counter"].ToString() + "\" ";

                }
                catch (Exception)
                {
                }
                try
                {
                    jsArray += ",\"trf\" : \"" + objRowItem["TrafficStatus_Far"].ToString() + "\" ";

                }
                catch (Exception)
                {
                }
                try
                {
                    jsArray += ",\"trf_eng\" : \"" + objRowItem["TrafficStatus_Far"].ToString() + "\" ";

                }
                catch (Exception)
                {
                }

                //foreach (DataColumn objColitem in _result.Columns)
                //{
                //    try
                //    {
                //        jsArray += ",\"" + objColitem.ColumnName + "\" : \"" + objRowItem[objColitem.ColumnName] + "\" ";
                //    }
                //    catch (Exception)
                //    {
                //        //اگر خطا داد آن را بی خیال می شویم تا از حرکت نایستند
                //    }
                //}

                jsArray += " } " + strSeperator;

            }

            return ClsHelpper.RemoveControlCharactersFromString(jsArray);
        }

        public static string GetNodesItemsAsString_CameraInfo_forCoridorInDataBase(int nCoridorID)
        {
            DataTable objResultEffectiveCamera = ClsHelpper.Fetch_BaseArrayOfCameraFromCorridorInfoInDataBase(nCoridorID);
            return GetNodesItemsAsString_CameraInfo_forCoridorInDataTable(objResultEffectiveCamera);

        }

        public static string GetNodesItemsAsString_CameraInfo_forCoridorInDataTable(DataTable objResultEffectiveCamera)
        {

            if (objResultEffectiveCamera == null)
            {
                return "";
            }

            if (objResultEffectiveCamera.Rows.Count == 0)
            {
                return "";
            }

            if (objResultEffectiveCamera.Columns.Contains("FinalFTPImg") == false)
            {
                objResultEffectiveCamera.Columns.Add("FinalFTPImg");
            }
            if (objResultEffectiveCamera.Columns.Contains("FinalFTPImgDateTime") == false)
            {
                objResultEffectiveCamera.Columns.Add("FinalFTPImgDateTime");
            }
            if (objResultEffectiveCamera.Columns.Contains("FinalFTPImgTime") == false)
            {
                objResultEffectiveCamera.Columns.Add("FinalFTPImgTime");
            }

            string jsArray = string.Empty;
            string strSeperator = Environment.NewLine;
            foreach (DataRow objRowItem in objResultEffectiveCamera.Rows)
            {
                // اگر اطلاعات لت و لانگ آنها مشکل داشت آنها را درج نکند
                try
                {
                    if (objRowItem["Latitude"].ToString().Trim().Length == 0)
                    {
                        continue;
                    }

                    if (objRowItem["Longitude"].ToString().Trim().Length == 0)
                    {
                        continue;
                    }

                    double latValue, longValue;
                    if (!ClsHelpper.TryParseNumber(objRowItem["Latitude"].ToString(), out latValue) || latValue == 0)
                    {
                        continue;
                    }

                    if (!ClsHelpper.TryParseNumber(objRowItem["Longitude"].ToString(), out longValue) || longValue == 0)
                    {
                        continue;
                    }

                }
                catch (Exception)
                {
                    //اگر خطا داد بی خیال این لطف زیادی می شویم
                    continue;
                }

                string strIPInfo = "";
                if (objRowItem["IPInfo"] != null)
                {
                    strIPInfo = objRowItem["IPInfo"].ToString();
                }

                KeyValuePair<string, string> objPicFileDorbinInfo = ClsHelpper.GetPicLastFileDorbinInfoWithDate(strIPInfo, 15, true);

                if (objPicFileDorbinInfo.Value.Trim().Length == 0)
                {
                    continue;
                }
                try
                {
                    objRowItem["FinalFTPImg"] = objPicFileDorbinInfo.Value;
                    objRowItem["FinalFTPImgDateTime"] = objPicFileDorbinInfo.Key.Split('-')[0].ToString();
                    objRowItem["FinalFTPImgTime"] = objPicFileDorbinInfo.Key.Split('-')[1].ToString();
                }
                catch (Exception)
                {

                }

                if (jsArray != string.Empty)
                {
                    jsArray += " , ";
                }

                jsArray += " { ";
                jsArray += " \"ID\" : \"" + objRowItem["id"].ToString() + "\" ";
                jsArray += ",\"Title\" : \"" + objRowItem["Title"].ToString() + "\" ";
                jsArray += ",\"Desc\" : \"" + objRowItem["Title"].ToString() + "\" ";
                jsArray += ",\"FinalFTPImg\" : \"" + objRowItem["FinalFTPImg"].ToString() + "\" ";
                jsArray += ",\"Longitude\" : \"" + ClsHelpper.ToInvariantNumber(objRowItem["Longitude"]) + "\" ";
                jsArray += ",\"Latitude\" : \"" + ClsHelpper.ToInvariantNumber(objRowItem["Latitude"]) + "\" ";
                jsArray += ",\"State\" : \"دوربین های نظارتی\" ";

                jsArray += " } " + strSeperator;

            }

            return ClsHelpper.RemoveControlCharactersFromString(jsArray);
        }

        [WebMethod]
        public static string FetchingStringData_TrradodShomarInfo_forCoridorInDataBase(int nCoridorID)
        {
            string strResult = "";
            try
            {

                strResult = GetNodesItemsAsString_TrradodShomarInfo_forCoridorInDataBase(nCoridorID);
            }
            catch (Exception)
            {

            }
            return strResult;
        }

        [WebMethod]
        public static string FetchingStringData_CameraInfo_forCoridorInDataBase(int nCoridorID)
        {
            string strResult = "";
            try
            {

                strResult = GetNodesItemsAsString_CameraInfo_forCoridorInDataBase(nCoridorID);
            }
            catch (Exception)
            {

            }
            return strResult;
        }

        [WebMethod]
        public static string FillSugestion_NameStationFromAllStations(string strStationInfo)
        {
            return ClsHelpper.FillSugestion_NameStationFromAllStations(strStationInfo);
        }

        [WebMethod]
        public static string FillSugestion_NameCorridor(string str_NameCorridor)
        {
            string strResult = "";
            DataTable objDataTable = objDataTable = ClsHelpper.FillSugestion_NameCorridor_ByListInfo(str_NameCorridor);

            if (objDataTable != null)
            {
                foreach (DataRow item in objDataTable.Rows)
                {
                    if (strResult.Trim().Length != 0)
                    {
                        strResult = strResult + "*";
                    }
                    strResult = strResult + item["Name"].ToString();
                }
            }

            return strResult;

        }

        [WebMethod]
        public static string FillSugestion_ProjectName()
        {
            string strResult = "";
            List<string> objResult = ClsHelpper.GetProjectNameDataTable();

            foreach (string item in objResult)
            {
                if (strResult.Trim().Length != 0)
                {
                    strResult = strResult + "*";
                }
                strResult = strResult + item.ToString();
            }

            return strResult;

        }

        #region لیست مسیرها (ViewRouts)

        [WebMethod]
        public static string FillSugestion_ProjectName_FromRoutsList()
        {
            return string.Join("*", ClsHelpper.GetProjectNameDistinctFromRoutsList().ToArray());
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FetchRoutsListSchema()
        {
            return DataTableToDictionaryList(ClsHelpper.FetchRoutsListSchema());
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FetchRoutsListItems_ByPaging(string NameProjeh, int PageSize, int PageIndex)
        {
            DataTable objDataTable = ClsHelpper.FetchRoutsListItems(NameProjeh ?? "");

            if (PageSize > 0)
            {
                DataTable objPage = objDataTable.Clone();
                int nStart = PageSize * (PageIndex - 1);
                for (int nCounter = nStart; nCounter < objDataTable.Rows.Count && nCounter < nStart + PageSize; nCounter++)
                {
                    objPage.ImportRow(objDataTable.Rows[nCounter]);
                }
                objDataTable = objPage;
            }

            return DataTableToDictionaryList(objDataTable);
        }

        private static List<Dictionary<string, string>> DataTableToDictionaryList(DataTable objDataTable)
        {
            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            foreach (DataRow item in objDataTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTable.Columns)
                {
                    objItem.Add(ColItem.ColumnName, item[ColItem.ColumnName].ToString());
                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }

        #endregion

        [WebMethod]
        public static string FillSugestion_ProjectNameDistinctInfoDataBase()
        {
            string strResult = "";
            List<string> objResult = ClsHelpper.GetProjectNameDistinctInfoDataBase();

            foreach (string item in objResult)
            {
                if (strResult.Trim().Length != 0)
                {
                    strResult = strResult + "*";
                }
                strResult = strResult + item.ToString();
            }

            return strResult;

        }


        [WebMethod]
        public static string FillSugestion_ProjectNameDistinctInfoDataBaseForDepartment(string strDepartment)
        {
            string strResult = "";
            List<string> objResult = ClsHelpper.GetProjectNameDistinctInfoDataBaseForDepartment(strDepartment);

            foreach (string item in objResult)
            {
                if (strResult.Trim().Length != 0)
                {
                    strResult = strResult + "*";
                }
                strResult = strResult + item.ToString();
            }

            return strResult;

        }


        [WebMethod]
        public static string FetchStationIDCamaLatCamaLong(string strStationInfo)
        {
            return ClsHelpper.FetchStationIDCamaLatCamaLong(strStationInfo);
        }

        [WebMethod]
        public static string FetchingStringData_TrradodShomarInfo_forCoridorRoutPoint(string CoridorRoutPoint, double EnherafMayar_Mohiti_DarTradodShomar)
        {
            if (CoridorRoutPoint.Trim().Length == 0)
            {
                return "";
            }

            DataTable objResultEffectiveTradodShomar = ClsHelpper.GetCorrectTradodShomarInfoForCoridor(CoridorRoutPoint, EnherafMayar_Mohiti_DarTradodShomar);
            return GetNodesItemsAsString_TrradodShomarInfo_forCoridorInDataTable(objResultEffectiveTradodShomar);
        }

        [WebMethod]
        public static string FetchingStringData_CameraInfo_forCoridorRoutPoint(string CoridorRoutPoint, double EnherafMayar_Mohiti_DarCamera)
        {
            if (CoridorRoutPoint.Trim().Length == 0)
            {
                return "";
            }

            DataTable objResultEffectiveCamera = ClsHelpper.GetCorrectCameraInfoForCoridor(CoridorRoutPoint, EnherafMayar_Mohiti_DarCamera);
            return GetNodesItemsAsString_CameraInfo_forCoridorInDataTable(objResultEffectiveCamera);
        }

        [WebMethod]
        public static string InsertCoridorInDatabase(string strNameCoridor, string strDistance, string strDuration,
            int nSourse_ID, int nDestination_ID, string ProgramName, string strRoutesInfo, string LatNortheast, string LongNortheast, string LatSouthwest,
            string LongSouthwest, string strCamaSeperatedDorbinhaIDS, string strCamaSeperatedTradodShomarhaIDS)
        {
            if (strRoutesInfo.Trim().Length == 0)
            {
                return "";
            }

            Boolean bIsUpdated = false;
            Int64 nResult = ClsHelpper.InsertCoridor_ByListInfo(strNameCoridor, strDistance, strDuration, nSourse_ID, nDestination_ID, ProgramName, strRoutesInfo, LatNortheast, LongNortheast, LatSouthwest, LongSouthwest, ref bIsUpdated);
            if (nResult < 1)
            {
                return "";
            }

            //if (strCamaSeperatedDorbinhaIDS.Trim().Length > 0)
            //{
            //    string[] Array_strCamaSeperatedDorbinhaIDS = strCamaSeperatedDorbinhaIDS.Split(',');
            //    if (Array_strCamaSeperatedDorbinhaIDS.Length > 0)
            //    {
            //        foreach (string item in Array_strCamaSeperatedDorbinhaIDS)
            //        {
            //            ClsHelpper.InsertCameraInCoridorCamera(nResult, Convert.ToInt64(item));
            //        }
            //    }
            //}

            //if (strCamaSeperatedTradodShomarhaIDS.Trim().Length > 0)
            //{
            //    string[] Array_strCamaSeperatedTradodShomarhaIDS = strCamaSeperatedTradodShomarhaIDS.Split(',');
            //    if (Array_strCamaSeperatedTradodShomarhaIDS.Length > 0)
            //    {
            //        foreach (string item in Array_strCamaSeperatedTradodShomarhaIDS)
            //        {
            //            ClsHelpper.InsertCameraInCoridorTradodShomarha(nResult, Convert.ToInt64(item));
            //        }
            //    }
            //}


            if (bIsUpdated)
            {
                return "عملیات بهنگام سازی با موفقیت انجام شده است ";
            }
            else
            {
                return "عملیات ثبت جدید با موفقیت انجام شده است ، شناسه:" + nResult.ToString();
            }


        }


        [WebMethod]
        public static string InsertPolyganInDatabase(string strNamePolygan, string strPolygonPoints, string strFillColor, string strBorderColor, float nOpacity)
        {
            if (strPolygonPoints.Trim().Length == 0)
            {
                return "";
            }
            strPolygonPoints = strPolygonPoints.Replace("G", "lat").Replace("K", "lng");
            Int64 nResult = ClsHelpper.InsertPolygan_ByListInfo(strNamePolygan, strPolygonPoints, strFillColor, strBorderColor, nOpacity);

            return "عملیات ثبت جدید با موفقیت انجام شده است ، شناسه:" + nResult.ToString();

        }

        [WebMethod]
        public static List<Dictionary<string, string>> FetchAllRouts_FromStations()
        {
            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            DataTable objDataTable = ClsHelpper.FetchAllRouts_FromStations();

            foreach (DataRow item in objDataTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTable.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());

                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FetchAllPolygans()
        {
            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            DataTable objDataTable = ClsHelpper.FetchAllPolygans();

            foreach (DataRow item in objDataTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTable.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());

                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FetchAllReportsByProjectName(string ProgramName)
        {
            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            DataTable objDataTable = ClsHelpper.FetchAllReportsByProjectName(ProgramName);

            foreach (DataRow item in objDataTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTable.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());

                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FetchAllCoridor_ToCitesByFromStationInfo(string strFromCitesID)
        {
            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            DataTable objDataTable = ClsHelpper.FetchAllCoridor_ToCitesByFromStationInfo(strFromCitesID);
            foreach (DataRow item in objDataTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTable.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());

                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FetchAllCoridorInfoFromDataBase_By_FromStation_ToStation(string str_FromStationID, string str_ToStationID)
        {
            if (str_FromStationID.Trim().Length == 0)
            {
                str_FromStationID = "-1";
            }

            if (str_ToStationID.Trim().Length == 0)
            {
                str_ToStationID = "-1";
            }

            //اگر خالی بود خطا دهد

            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            //DataTable objDataTable = ClsHelpper.FetchAllCoridorInfoFromDataBase_ByDataBaseInfo(str_FromStationID, str_ToStationID);
            DataTable objDataTable = ClsHelpper.FetchAllCoridorInfoFromDataBase_ByListInfo(str_FromStationID, str_ToStationID);
            foreach (DataRow item in objDataTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTable.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());

                }
                lstResult.Add(objItem);
            }

            return lstResult;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FetchAllCoridorInfoFromDataBase_ByStation_ID(int Station_ID)
        {
            string strRowFilter = "";
            if (Station_ID != 0)
            {
                strRowFilter = strRowFilter + " StationFrom_ID = " + Station_ID + " and Points  is null ";
            }

            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            DataTable objDataTable = ClsHelpper.FetchAllCoridorInfoFromDataBase_ByDataBaseInfo(strRowFilter);

            foreach (DataRow item in objDataTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTable.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());

                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }

        [WebMethod]
        public static Dictionary<string, string> FetchAbstractInfoFromDataBase_New(string NameProjeh)
        {
            DataTable objDataTableResult = null;
            Dictionary<string, string> lstResult = new Dictionary<string, string>();

            string strRowFilter = " [Points] is not  null and   [LatFrom] is null and [LongFrom] is null and [StationTo_Title] Is null and [LatTo] IS null and [LongTo] is null";
            if (NameProjeh.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ProgramName in (N'" + NameProjeh.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
            }

            objDataTableResult = ClsHelpper.FetchAllCoridorInfoFromDataBase_ByDataBaseInfo(strRowFilter, " Count(*) ");
            lstResult.Add("polygon", objDataTableResult.Rows[0][0].ToString());

            strRowFilter = " [Points] is not  null and   [LatFrom] is not  null and [LongFrom] is not  null and [StationTo_Title] Is not  null and [LatTo] IS not  null and [LongTo] is not  null";
            if (NameProjeh.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ProgramName in (N'" + NameProjeh.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
            }

            objDataTableResult = ClsHelpper.FetchAllCoridorInfoFromDataBase_ByDataBaseInfo(strRowFilter, " Count(*) ");
            lstResult.Add("polyline", objDataTableResult.Rows[0][0].ToString());


            strRowFilter = " [Points] is  null and   [LatFrom] is not  null and [LongFrom] is not  null ";
            if (NameProjeh.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ProgramName in (N'" + NameProjeh.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
            }

            objDataTableResult = ClsHelpper.FetchAllCoridorInfoFromDataBase_ByDataBaseInfo(strRowFilter, " Count(*) ");
            lstResult.Add("point", objDataTableResult.Rows[0][0].ToString());

            return lstResult;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FetchAllCoridorInfoFromDataBase(string NameProjeh, string OnvanMaseer, string OnvanStation, string VaziyatTehaghoghMaseer, string VaziyatTehaghoghStation)
        {
            string strRowFilter = "";
            if (OnvanMaseer.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " Title like N'%" + OnvanMaseer.Trim() + "%' ";
            }

            if (OnvanStation.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ( StationFrom_Title like N'%" + OnvanStation.Trim() + "%'  or  StationTo_Title like N'%" + OnvanStation.Trim() + "%' ) ";
            }


            if (VaziyatTehaghoghMaseer.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " TahaghoghRoute in (N'" + VaziyatTehaghoghMaseer.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
            }


            if (NameProjeh.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ProgramName in (N'" + NameProjeh.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
            }



            if (VaziyatTehaghoghStation.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ( ";
                strRowFilter = strRowFilter + " StationFrom_Tahaghogh in (N'" + VaziyatTehaghoghStation.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
                strRowFilter = strRowFilter + " OR ";
                strRowFilter = strRowFilter + " StationTo_Tahaghogh in (N'" + VaziyatTehaghoghStation.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
                strRowFilter = strRowFilter + " ) ";
            }

            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            DataTable objDataTable = ClsHelpper.FetchAllCoridorInfoFromDataBase_ByDataBaseInfo(strRowFilter);

            //DataTable objDataTable = ClsHelpper.FetchAllCoridorInfoFromDataBase_ByListInfo("", "");
            //DataView objDataView = objDataTable.DefaultView;
            //objDataView.RowFilter = strRowFilter;
            //objDataTable = objDataView.ToTable();

            foreach (DataRow item in objDataTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTable.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());

                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FetchAllCoridorInfoFromDataBase_ByPaging(string NameProjeh, string OnvanMaseer, string OnvanStation, string VaziyatTehaghoghMaseer, string VaziyatTehaghoghStation, int PageSize, int PageIndex)
        {
            string strRowFilter = "";
            if (OnvanMaseer.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " Title like N'%" + OnvanMaseer.Trim() + "%' ";
            }

            if (OnvanStation.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ( StationFrom_Title like N'%" + OnvanStation.Trim() + "%'  or  StationTo_Title like N'%" + OnvanStation.Trim() + "%' ) ";
            }


            if (VaziyatTehaghoghMaseer.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " TahaghoghRoute in (N'" + VaziyatTehaghoghMaseer.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
            }


            if (NameProjeh.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ProgramName in (N'" + NameProjeh.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
            }



            if (VaziyatTehaghoghStation.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ( ";
                strRowFilter = strRowFilter + " StationFrom_Tahaghogh in (N'" + VaziyatTehaghoghStation.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
                strRowFilter = strRowFilter + " OR ";
                strRowFilter = strRowFilter + " StationTo_Tahaghogh in (N'" + VaziyatTehaghoghStation.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
                strRowFilter = strRowFilter + " ) ";
            }

            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            DataTable objDataTableResult = ClsHelpper.FetchAllCoridorInfoFromDataBase_ByDataBaseInfo(strRowFilter);
            DataTable objDestinationTable = null;

            if (PageSize == 0)
            {
                objDestinationTable = objDataTableResult;
            }
            else
            {
                int countItems = objDataTableResult.Rows.Count;

                if (PageSize > countItems)
                {
                    if (PageIndex == 1)
                    {
                        objDestinationTable = objDataTableResult;
                    }
                    else
                    {
                        //یعنی ایندکس گذاری بلا ایتفاده است
                        return lstResult;
                    }
                }
                else
                {
                    objDestinationTable = objDataTableResult.Clone();
                    int startIndex = (PageSize) * (PageIndex - 1);
                    int EndIndex = startIndex + PageSize;

                    for (int nCounter = 0; nCounter < objDataTableResult.Rows.Count; nCounter++)
                    {
                        if (nCounter >= startIndex && nCounter < EndIndex)
                        {
                            objDestinationTable.ImportRow(objDataTableResult.Rows[nCounter]);
                        }
                    }

                }
            }

            foreach (DataRow item in objDestinationTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTableResult.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());

                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }

        #region Base Function

        #region FromDataBase

        [WebMethod]
        public static List<Dictionary<string, string>> FetchAllCoridorInfoFromDataBase_New(string NameProjeh, string Condition)
        {
            string strRowFilter = "";
            if (NameProjeh.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ProgramName in (N'" + NameProjeh.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
            }




            if (Condition.Trim().Length > 0)
            {

                Condition = Condition.Replace("#@#", "'");

                //برای تشخیص تاریخ 
                #region DateField
                string[] strConditionSplit = Condition.Split(new[] { "DDDDDDDDDDD" }, StringSplitOptions.RemoveEmptyEntries);

                if (strConditionSplit.Length > 1)
                {
                    foreach (string strItem in strConditionSplit)
                    {
                        if (strItem.Split('/').Length == 3)
                        {
                            //اگر فیلد تاریخ در آن پیدا شد
                            string strDateInfo = strItem.Substring(1);
                            strDateInfo = strDateInfo.Replace("%", "");
                            strDateInfo = strDateInfo.Substring(0, strDateInfo.IndexOf('\''));
                            if (strDateInfo.Length >= 8 && strDateInfo.Length <= 10)
                            {
                                Condition = Condition.Replace(strDateInfo, ClsHelpper.GorgianDate(strDateInfo));
                            }
                        }
                    }

                    Condition = Condition.Replace("DDDDDDDDDDD", "");
                }
                #endregion

                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + "( " + Condition + " )";
            }
            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            DataTable objDataTable = ClsHelpper.FetchAllCoridorInfoFromDataBase_ByDataBaseInfo(strRowFilter);

            //DataTable objDataTable = ClsHelpper.FetchAllCoridorInfoFromDataBase_ByListInfo("", "");
            //DataView objDataView = objDataTable.DefaultView;
            //objDataView.RowFilter = strRowFilter;
            //objDataTable = objDataView.ToTable();

            foreach (DataRow item in objDataTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTable.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());

                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FetchAllCoridorInfoFromDataBase_New_ByPaging(string NameProjeh, string Condition, int PageSize, int PageIndex)
        {
            string strRowFilter = "";
            if (NameProjeh.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ProgramName in (N'" + NameProjeh.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
            }




            if (Condition.Trim().Length > 0)
            {

                Condition = Condition.Replace("#@#", "'");

                //برای تشخیص تاریخ 
                #region DateField
                string[] strConditionSplit = Condition.Split(new[] { "DDDDDDDDDDD" }, StringSplitOptions.RemoveEmptyEntries);

                if (strConditionSplit.Length > 1)
                {
                    foreach (string strItem in strConditionSplit)
                    {
                        if (strItem.Split('/').Length == 3)
                        {
                            //اگر فیلد تاریخ در آن پیدا شد
                            string strDateInfo = strItem.Substring(1);
                            strDateInfo = strDateInfo.Replace("%", "");
                            strDateInfo = strDateInfo.Substring(0, strDateInfo.IndexOf('\''));
                            if (strDateInfo.Length >= 8 && strDateInfo.Length <= 10)
                            {
                                Condition = Condition.Replace(strDateInfo, ClsHelpper.GorgianDate(strDateInfo));
                            }
                        }
                    }

                    Condition = Condition.Replace("DDDDDDDDDDD", "");
                }
                #endregion

                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + "( " + Condition + " )";
            }
            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            DataTable objDataTableResult = ClsHelpper.FetchAllCoridorInfoFromDataBase_ByDataBaseInfo(strRowFilter);
            DataTable objDestinationTable = null;

            if (PageSize == 0)
            {
                objDestinationTable = objDataTableResult;
            }
            else
            {
                int countItems = objDataTableResult.Rows.Count;

                if (PageSize > countItems)
                {
                    if (PageIndex == 1)
                    {
                        objDestinationTable = objDataTableResult;
                    }
                    else
                    {
                        //یعنی ایندکس گذاری بلا ایتفاده است
                        return lstResult;
                    }
                }
                else
                {
                    objDestinationTable = objDataTableResult.Clone();
                    int startIndex = (PageSize) * (PageIndex - 1);
                    int EndIndex = startIndex + PageSize;

                    for (int nCounter = 0; nCounter < objDataTableResult.Rows.Count; nCounter++)
                    {
                        if (nCounter >= startIndex && nCounter < EndIndex)
                        {
                            objDestinationTable.ImportRow(objDataTableResult.Rows[nCounter]);
                        }
                    }

                }
            }

            foreach (DataRow item in objDestinationTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTableResult.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());

                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FetchAllCoridorInfoFromDataBase_NewCombine_ByPaging(string NameProjeh, string Condition, int PageSize, int PageIndex)
        {
            string strRowFilter = "";
            if (NameProjeh.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ProgramName in (N'" + NameProjeh.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
            }




            if (Condition.Trim().Length > 0)
            {

                Condition = Condition.Replace("#@#", "'");

                //برای تشخیص تاریخ 
                #region DateField
                string[] strConditionSplit = Condition.Split(new[] { "DDDDDDDDDDD" }, StringSplitOptions.RemoveEmptyEntries);

                if (strConditionSplit.Length > 1)
                {
                    foreach (string strItem in strConditionSplit)
                    {
                        if (strItem.Split('/').Length == 3)
                        {
                            //اگر فیلد تاریخ در آن پیدا شد
                            string strDateInfo = strItem.Substring(1);
                            strDateInfo = strDateInfo.Replace("%", "");
                            strDateInfo = strDateInfo.Substring(0, strDateInfo.IndexOf('\''));
                            if (strDateInfo.Length >= 8 && strDateInfo.Length <= 10)
                            {
                                Condition = Condition.Replace(strDateInfo, ClsHelpper.GorgianDate(strDateInfo));
                            }
                        }
                    }

                    Condition = Condition.Replace("DDDDDDDDDDD", "");
                }
                #endregion

                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + "( " + Condition + " )";
            }
            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            DataTable objDataTableResult = ClsHelpper.FetchAllCoridorInfoFromDataBase_ByDataBaseInfo_CobinationToFrom(strRowFilter);
            DataTable objDestinationTable = null;

            if (PageSize == 0)
            {
                objDestinationTable = objDataTableResult;
            }
            else
            {
                int countItems = objDataTableResult.Rows.Count;

                if (PageSize > countItems)
                {
                    if (PageIndex == 1)
                    {
                        objDestinationTable = objDataTableResult;
                    }
                    else
                    {
                        //یعنی ایندکس گذاری بلا ایتفاده است
                        return lstResult;
                    }
                }
                else
                {
                    objDestinationTable = objDataTableResult.Clone();
                    int startIndex = (PageSize) * (PageIndex - 1);
                    int EndIndex = startIndex + PageSize;

                    for (int nCounter = 0; nCounter < objDataTableResult.Rows.Count; nCounter++)
                    {
                        if (nCounter >= startIndex && nCounter < EndIndex)
                        {
                            objDestinationTable.ImportRow(objDataTableResult.Rows[nCounter]);
                        }
                    }

                }
            }

            foreach (DataRow item in objDestinationTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTableResult.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());

                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FetchAllCoridorInfoFromDataBase_NewCombine_Department_ByPaging(string NameProjeh, string NameDepartment, string Condition, int PageSize, int PageIndex)
        {
            string strRowFilter = "";
            if (NameProjeh.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ProgramName in (N'" + NameProjeh.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
            }

            if (NameDepartment.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " Department = (N'" + NameDepartment.Trim() + "') ".Replace(",N''", "");
            }


            if (Condition.Trim().Length > 0)
            {

                Condition = Condition.Replace("#@#", "'");

                //برای تشخیص تاریخ 
                #region DateField
                string[] strConditionSplit = Condition.Split(new[] { "DDDDDDDDDDD" }, StringSplitOptions.RemoveEmptyEntries);

                if (strConditionSplit.Length > 1)
                {
                    foreach (string strItem in strConditionSplit)
                    {
                        if (strItem.Split('/').Length == 3)
                        {
                            //اگر فیلد تاریخ در آن پیدا شد
                            string strDateInfo = strItem.Substring(1);
                            strDateInfo = strDateInfo.Replace("%", "");
                            strDateInfo = strDateInfo.Substring(0, strDateInfo.IndexOf('\''));
                            if (strDateInfo.Length >= 8 && strDateInfo.Length <= 10)
                            {
                                Condition = Condition.Replace(strDateInfo, ClsHelpper.GorgianDate(strDateInfo));
                            }
                        }
                    }

                    Condition = Condition.Replace("DDDDDDDDDDD", "");
                }
                #endregion

                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + "( " + Condition + " )";
            }
            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            DataTable objDataTableResult = ClsHelpper.FetchAllCoridorInfoFromDataBase_ByDataBaseInfo_CobinationToFrom(strRowFilter);
            DataTable objDestinationTable = null;

            if (PageSize == 0)
            {
                objDestinationTable = objDataTableResult;
            }
            else
            {
                int countItems = objDataTableResult.Rows.Count;

                if (PageSize > countItems)
                {
                    if (PageIndex == 1)
                    {
                        objDestinationTable = objDataTableResult;
                    }
                    else
                    {
                        //یعنی ایندکس گذاری بلا ایتفاده است
                        return lstResult;
                    }
                }
                else
                {
                    objDestinationTable = objDataTableResult.Clone();
                    int startIndex = (PageSize) * (PageIndex - 1);
                    int EndIndex = startIndex + PageSize;

                    for (int nCounter = 0; nCounter < objDataTableResult.Rows.Count; nCounter++)
                    {
                        if (nCounter >= startIndex && nCounter < EndIndex)
                        {
                            objDestinationTable.ImportRow(objDataTableResult.Rows[nCounter]);
                        }
                    }

                }
            }

            foreach (DataRow item in objDestinationTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTableResult.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());

                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }


        #endregion

        #region FromSPDataBase

        [WebMethod]
        public static List<Dictionary<string, string>> FetchAllCoridorInfoFromSPDataBase_New(string NameProjeh, string Condition)
        {
            string strRowFilter = "";
            if (NameProjeh.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ProgramName in (N'" + NameProjeh.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
            }




            if (Condition.Trim().Length > 0)
            {

                Condition = Condition.Replace("#@#", "'");

                //برای تشخیص تاریخ 
                #region DateField
                string[] strConditionSplit = Condition.Split(new[] { "DDDDDDDDDDD" }, StringSplitOptions.RemoveEmptyEntries);

                if (strConditionSplit.Length > 1)
                {
                    foreach (string strItem in strConditionSplit)
                    {
                        if (strItem.Split('/').Length == 3)
                        {
                            //اگر فیلد تاریخ در آن پیدا شد
                            string strDateInfo = strItem.Substring(1);
                            strDateInfo = strDateInfo.Replace("%", "");
                            strDateInfo = strDateInfo.Substring(0, strDateInfo.IndexOf('\''));
                            if (strDateInfo.Length >= 8 && strDateInfo.Length <= 10)
                            {
                                Condition = Condition.Replace(strDateInfo, ClsHelpper.GorgianDate(strDateInfo));
                            }
                        }
                    }

                    Condition = Condition.Replace("DDDDDDDDDDD", "");
                }
                #endregion

                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + "( " + Condition + " )";
            }
            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            DataTable objDataTable = ClsHelpper.FetchAllCoridorInfoFromDataBase_BySPDataBaseInfo(strRowFilter);

            //DataTable objDataTable = ClsHelpper.FetchAllCoridorInfoFromDataBase_ByListInfo("", "");
            //DataView objDataView = objDataTable.DefaultView;
            //objDataView.RowFilter = strRowFilter;
            //objDataTable = objDataView.ToTable();

            foreach (DataRow item in objDataTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTable.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());

                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FetchAllCoridorInfoFromSPDataBase_New_ByPaging(string NameProjeh, string Condition, int PageSize, int PageIndex)
        {
            string strRowFilter = "";
            if (NameProjeh.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ProgramName in (N'" + NameProjeh.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
            }




            if (Condition.Trim().Length > 0)
            {

                Condition = Condition.Replace("#@#", "'");

                //برای تشخیص تاریخ 
                #region DateField
                string[] strConditionSplit = Condition.Split(new[] { "DDDDDDDDDDD" }, StringSplitOptions.RemoveEmptyEntries);

                if (strConditionSplit.Length > 1)
                {
                    foreach (string strItem in strConditionSplit)
                    {
                        if (strItem.Split('/').Length == 3)
                        {
                            //اگر فیلد تاریخ در آن پیدا شد
                            string strDateInfo = strItem.Substring(1);
                            strDateInfo = strDateInfo.Replace("%", "");
                            strDateInfo = strDateInfo.Substring(0, strDateInfo.IndexOf('\''));
                            if (strDateInfo.Length >= 8 && strDateInfo.Length <= 10)
                            {
                                Condition = Condition.Replace(strDateInfo, ClsHelpper.GorgianDate(strDateInfo));
                            }
                        }
                    }

                    Condition = Condition.Replace("DDDDDDDDDDD", "");
                }
                #endregion

                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + "( " + Condition + " )";
            }
            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            DataTable objDataTableResult = ClsHelpper.FetchAllCoridorInfoFromDataBase_BySPDataBaseInfo(strRowFilter);
            DataTable objDestinationTable = null;

            if (PageSize == 0)
            {
                objDestinationTable = objDataTableResult;
            }
            else
            {
                int countItems = objDataTableResult.Rows.Count;

                if (PageSize > countItems)
                {
                    if (PageIndex == 1)
                    {
                        objDestinationTable = objDataTableResult;
                    }
                    else
                    {
                        //یعنی ایندکس گذاری بلا ایتفاده است
                        return lstResult;
                    }
                }
                else
                {
                    objDestinationTable = objDataTableResult.Clone();
                    int startIndex = (PageSize) * (PageIndex - 1);
                    int EndIndex = startIndex + PageSize;

                    for (int nCounter = 0; nCounter < objDataTableResult.Rows.Count; nCounter++)
                    {
                        if (nCounter >= startIndex && nCounter < EndIndex)
                        {
                            objDestinationTable.ImportRow(objDataTableResult.Rows[nCounter]);
                        }
                    }

                }
            }

            foreach (DataRow item in objDestinationTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTableResult.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());

                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FetchAllCoridorInfoFromSPDataBase_NewCombine_ByPaging(string NameProjeh, string Condition, int PageSize, int PageIndex)
        {
            string strRowFilter = "";
            if (NameProjeh.Trim().Length != 0)
            {
                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + " ProgramName in (N'" + NameProjeh.Trim().Replace("#@#", "',N'") + "') ".Replace(",N''", "");
            }




            if (Condition.Trim().Length > 0)
            {

                Condition = Condition.Replace("#@#", "'");

                //برای تشخیص تاریخ 
                #region DateField
                string[] strConditionSplit = Condition.Split(new[] { "DDDDDDDDDDD" }, StringSplitOptions.RemoveEmptyEntries);

                if (strConditionSplit.Length > 1)
                {
                    foreach (string strItem in strConditionSplit)
                    {
                        if (strItem.Split('/').Length == 3)
                        {
                            //اگر فیلد تاریخ در آن پیدا شد
                            string strDateInfo = strItem.Substring(1);
                            strDateInfo = strDateInfo.Replace("%", "");
                            strDateInfo = strDateInfo.Substring(0, strDateInfo.IndexOf('\''));
                            if (strDateInfo.Length >= 8 && strDateInfo.Length <= 10)
                            {
                                Condition = Condition.Replace(strDateInfo, ClsHelpper.GorgianDate(strDateInfo));
                            }
                        }
                    }

                    Condition = Condition.Replace("DDDDDDDDDDD", "");
                }
                #endregion

                if (strRowFilter.Trim().Length != 0)
                {
                    strRowFilter = strRowFilter + " AND ";
                }

                strRowFilter = strRowFilter + "( " + Condition + " )";
            }
            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            DataTable objDataTableResult = ClsHelpper.FetchAllCoridorInfoFromDataBase_BySPDataBaseInfo_CobinationToFrom(strRowFilter);
            DataTable objDestinationTable = null;

            if (PageSize == 0)
            {
                objDestinationTable = objDataTableResult;
            }
            else
            {
                int countItems = objDataTableResult.Rows.Count;

                if (PageSize > countItems)
                {
                    if (PageIndex == 1)
                    {
                        objDestinationTable = objDataTableResult;
                    }
                    else
                    {
                        //یعنی ایندکس گذاری بلا ایتفاده است
                        return lstResult;
                    }
                }
                else
                {
                    objDestinationTable = objDataTableResult.Clone();
                    int startIndex = (PageSize) * (PageIndex - 1);
                    int EndIndex = startIndex + PageSize;

                    for (int nCounter = 0; nCounter < objDataTableResult.Rows.Count; nCounter++)
                    {
                        if (nCounter >= startIndex && nCounter < EndIndex)
                        {
                            objDestinationTable.ImportRow(objDataTableResult.Rows[nCounter]);
                        }
                    }

                }
            }

            foreach (DataRow item in objDestinationTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTableResult.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());

                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }


        #region PWAInfo (وب‌پارت ShowAllProjectInfo)

        /// <summary>انواع پروژهء PWAInfo</summary>
        [WebMethod]
        public static List<string> FetchPWAProjectTypes()
        {
            return ClsHelpper.GetPWAProjectTypes();
        }

        /// <summary>منطقه‌های پروژهء PWAInfo؛ ProjectType خالی = همهء انواع</summary>
        [WebMethod]
        public static List<string> FetchPWARegions(string ProjectType)
        {
            return ClsHelpper.GetPWARegions(ProjectType);
        }

        /// <summary>پروژه‌های PWAInfo با مختصات؛ ProjectType / Region خالی = بدون فیلتر؛ Condition = شرط جستجوی پیشرفته (خالی = بدون شرط)</summary>
        [WebMethod]
        public static List<Dictionary<string, string>> FetchPWAProjects(string ProjectType, string Region, string Condition)
        {
            List<Dictionary<string, string>> lstResult = new List<Dictionary<string, string>>();
            DataTable objDataTable = ClsHelpper.FetchPWAProjects(ProjectType, Region, Condition);

            foreach (DataRow item in objDataTable.Rows)
            {
                Dictionary<string, string> objItem = new Dictionary<string, string>();
                foreach (DataColumn ColItem in objDataTable.Columns)
                {
                    objItem.Add(ColItem.ColumnName.ToString(), item[ColItem.ColumnName].ToString());
                }
                lstResult.Add(objItem);
            }
            return lstResult;
        }

        #endregion

        #endregion

        #endregion

    }

}
