using Microsoft.SharePoint;
using Microsoft.SharePoint.WebControls;
using Sazmanyar.GoogleMapOffline.Classes;
using System;
using System.Web.Services;

namespace Sazmanyar.GoogleMapOffline.Layouts.Sazmanyar.GoogleMapOffline
{
    public partial class ApplicationPage_ForloaddingMarkerData : LayoutsPageBase
    {
        #region WebMethod
        [WebMethod]
        public static string GetListItemsAsStringByCustomColumn(
                                 string RelationalColumnForloadInMapPoint,
                                 string SqlQueryViewName,
                                 string SqlQueryConnectionString,
                                 string RelationalColumnBetweenListsAndViews,
                                 Boolean IsOuterJoin,
                                 string Filterd_In_QueryStringName,
                                 string Filterd_In_QueryStringValue,
                                 string SiteID,
                                 string Weburl,
                                 string ListName,
                                 string ListUrlHelper1,
                                 string ListUrlHelper2,
                                 string ListUrlHelper3,
                                 string ListUrlHelper4,
                                 string ListUrlHelper5,
                                 string ViewName,
                                 Boolean ShowByAdminPrevilage,
                                 string LatField,
                                 string LongField,
                                 string StateField,
                                 string IsCenField,
                                 string ShouldRemovedFromBaseUrl,
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
                                 string CheckList_by_column3)
        {

            string jsArray = "";
            string jsCenter = "";

            if (ListName.ToString().Trim().Length > 0)
            {
                SPListCollection lists = null;
                SPList objBaseSelectedList = null;
                SPSecurity.RunWithElevatedPrivileges(
                               delegate ()
                               {
                                   using (SPSite CurrentSite = new SPSite(new Guid(SiteID)))
                                   {
                                       using (SPWeb web = CurrentSite.OpenWeb(Weburl))
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
                        objBaseSelectedList = list;
                        break;
                    }
                }

                HelperClass.GetListItemsAsString(SqlQueryViewName, SqlQueryConnectionString, new Guid(SiteID), RelationalColumnBetweenListsAndViews, IsOuterJoin, objBaseSelectedList, ViewName,
                    ShowByAdminPrevilage, LatField, LongField, StateField
                   , IsCenField, ShouldRemovedFromBaseUrl,
                   RelationalColumnForloadInMapPoint, cmbMarekerFilter1_SelectedValue, cmbMarekerFilter2_SelectedValue, cmbMarekerFilter3_SelectedValue,
                    txtMarekerSearch1_TextValue, txtMarekerSearch2_TextValue, txtMarekerSearch3_TextValue,
                    chlMarekerCheckList1_SelectedValues, chlMarekerCheckList2_SelectedValues, chlMarekerCheckList3_SelectedValues,
                    filterd_by_column1, filterd_by_column2, filterd_by_column3,
                    Searched_by_column1, Searched_by_column2, Searched_by_column3,
                    CheckList_by_column1, CheckList_by_column2, CheckList_by_column3,
                    ref jsArray, ref jsCenter, Filterd_In_QueryStringName, Filterd_In_QueryStringValue);

            }

            if (ListUrlHelper1.Trim().Length > 0 && ListUrlHelper1 != "*")
            {
                try
                {
                    SPList objSelectedList = null;
                    SPSecurity.RunWithElevatedPrivileges(
                   delegate ()
                   {
                       SPSite TempCurrentSite = null;
                       try
                       {
                           TempCurrentSite = new SPSite(ListUrlHelper1); //شاید مربوط به سایت کالکشن دیگری باشد و با اچ تی تی پی باز شده باشد
                       }
                       catch
                       {
                           TempCurrentSite = new SPSite(new Guid(SiteID));//در حالتی که در سایت کالکشن های داخلی باشد 
                       }

                       //در هر دو حالت جواب می دهد
                       SPWeb ListTempCurrentWeb = TempCurrentSite.OpenWeb();
                       objSelectedList = ListTempCurrentWeb.GetList(ListUrlHelper1);
                   });

                    HelperClass.GetListItemsAsString(SqlQueryViewName, SqlQueryConnectionString, new Guid(SiteID), RelationalColumnBetweenListsAndViews, IsOuterJoin, objSelectedList, ViewName, ShowByAdminPrevilage, LatField, LongField, StateField, IsCenField, ShouldRemovedFromBaseUrl,
                                                RelationalColumnForloadInMapPoint, cmbMarekerFilter1_SelectedValue, cmbMarekerFilter2_SelectedValue, cmbMarekerFilter3_SelectedValue,
                                                 txtMarekerSearch1_TextValue, txtMarekerSearch2_TextValue, txtMarekerSearch3_TextValue,
                                                 chlMarekerCheckList1_SelectedValues, chlMarekerCheckList2_SelectedValues, chlMarekerCheckList3_SelectedValues,
                                                 filterd_by_column1, filterd_by_column2, filterd_by_column3,
                                                 Searched_by_column1, Searched_by_column2, Searched_by_column3,
                                                 CheckList_by_column1, CheckList_by_column2, CheckList_by_column3,
                                                 ref jsArray, ref jsCenter, Filterd_In_QueryStringName, Filterd_In_QueryStringValue);

                }
                catch (Exception)
                { }
            }

            if (ListUrlHelper2.Trim().Length > 0 && ListUrlHelper2 != "*")
            {
                try
                {
                    SPList objSelectedList = null;
                    SPSecurity.RunWithElevatedPrivileges(
                   delegate ()
                   {
                       SPSite TempCurrentSite = null;
                       try
                       {
                           TempCurrentSite = new SPSite(ListUrlHelper2); //شاید مربوط به سایت کالکشن دیگری باشد و با اچ تی تی پی باز شده باشد
                       }
                       catch
                       {
                           TempCurrentSite = new SPSite(new Guid(SiteID));//در حالتی که در سایت کالکشن های داخلی باشد 
                       }

                       //در هر دو حالت جواب می دهد
                       SPWeb ListTempCurrentWeb = TempCurrentSite.OpenWeb();
                       objSelectedList = ListTempCurrentWeb.GetList(ListUrlHelper2);
                   });

                    HelperClass.GetListItemsAsString(SqlQueryViewName, SqlQueryConnectionString, new Guid(SiteID), RelationalColumnBetweenListsAndViews, IsOuterJoin, objSelectedList, ViewName, ShowByAdminPrevilage, LatField, LongField, StateField, IsCenField, ShouldRemovedFromBaseUrl,
                                                   RelationalColumnForloadInMapPoint, cmbMarekerFilter1_SelectedValue, cmbMarekerFilter2_SelectedValue, cmbMarekerFilter3_SelectedValue,
                                                    txtMarekerSearch1_TextValue, txtMarekerSearch2_TextValue, txtMarekerSearch3_TextValue,
                                                    chlMarekerCheckList1_SelectedValues, chlMarekerCheckList2_SelectedValues, chlMarekerCheckList3_SelectedValues,
                                                    filterd_by_column1, filterd_by_column2, filterd_by_column3,
                                                    Searched_by_column1, Searched_by_column2, Searched_by_column3,
                                                    CheckList_by_column1, CheckList_by_column2, CheckList_by_column3,
                                                    ref jsArray, ref jsCenter, Filterd_In_QueryStringName, Filterd_In_QueryStringValue);

                }
                catch (Exception)
                { }
            }

            if (ListUrlHelper3.Trim().Length > 0 && ListUrlHelper3 != "*")
            {

                try
                {
                    SPList objSelectedList = null;
                    SPSecurity.RunWithElevatedPrivileges(
                   delegate ()
                   {
                       SPSite TempCurrentSite = null;
                       try
                       {
                           TempCurrentSite = new SPSite(ListUrlHelper3); //شاید مربوط به سایت کالکشن دیگری باشد و با اچ تی تی پی باز شده باشد
                       }
                       catch
                       {
                           TempCurrentSite = new SPSite(new Guid(SiteID));//در حالتی که در سایت کالکشن های داخلی باشد 
                       }

                       //در هر دو حالت جواب می دهد
                       SPWeb ListTempCurrentWeb = TempCurrentSite.OpenWeb();
                       objSelectedList = ListTempCurrentWeb.GetList(ListUrlHelper3);
                   });

                    HelperClass.GetListItemsAsString(SqlQueryViewName, SqlQueryConnectionString, new Guid(SiteID), RelationalColumnBetweenListsAndViews, IsOuterJoin, objSelectedList, ViewName, ShowByAdminPrevilage, LatField, LongField, StateField, IsCenField, ShouldRemovedFromBaseUrl,
                                                       RelationalColumnForloadInMapPoint, cmbMarekerFilter1_SelectedValue, cmbMarekerFilter2_SelectedValue, cmbMarekerFilter3_SelectedValue,
                                                        txtMarekerSearch1_TextValue, txtMarekerSearch2_TextValue, txtMarekerSearch3_TextValue,
                                                        chlMarekerCheckList1_SelectedValues, chlMarekerCheckList2_SelectedValues, chlMarekerCheckList3_SelectedValues,
                                                        filterd_by_column1, filterd_by_column2, filterd_by_column3,
                                                        Searched_by_column1, Searched_by_column2, Searched_by_column3,
                                                        CheckList_by_column1, CheckList_by_column2, CheckList_by_column3,
                                                        ref jsArray, ref jsCenter, Filterd_In_QueryStringName, Filterd_In_QueryStringValue);
                }
                catch (Exception)
                { }
            }

            if (ListUrlHelper4.Trim().Length > 0 && ListUrlHelper4 != "*")
            {

                try
                {
                    SPList objSelectedList = null;
                    SPSecurity.RunWithElevatedPrivileges(
                   delegate ()
                   {
                       SPSite TempCurrentSite = null;
                       try
                       {
                           TempCurrentSite = new SPSite(ListUrlHelper4); //شاید مربوط به سایت کالکشن دیگری باشد و با اچ تی تی پی باز شده باشد
                       }
                       catch
                       {
                           TempCurrentSite = new SPSite(new Guid(SiteID));//در حالتی که در سایت کالکشن های داخلی باشد 
                       }

                       //در هر دو حالت جواب می دهد
                       SPWeb ListTempCurrentWeb = TempCurrentSite.OpenWeb();
                       objSelectedList = ListTempCurrentWeb.GetList(ListUrlHelper4);
                   });


                    HelperClass.GetListItemsAsString(SqlQueryViewName, SqlQueryConnectionString, new Guid(SiteID), RelationalColumnBetweenListsAndViews, IsOuterJoin, objSelectedList, ViewName, ShowByAdminPrevilage, LatField, LongField, StateField, IsCenField, ShouldRemovedFromBaseUrl,
                                                       RelationalColumnForloadInMapPoint, cmbMarekerFilter1_SelectedValue, cmbMarekerFilter2_SelectedValue, cmbMarekerFilter3_SelectedValue,
                                                        txtMarekerSearch1_TextValue, txtMarekerSearch2_TextValue, txtMarekerSearch3_TextValue,
                                                        chlMarekerCheckList1_SelectedValues, chlMarekerCheckList2_SelectedValues, chlMarekerCheckList3_SelectedValues,
                                                        filterd_by_column1, filterd_by_column2, filterd_by_column3,
                                                        Searched_by_column1, Searched_by_column2, Searched_by_column3,
                                                        CheckList_by_column1, CheckList_by_column2, CheckList_by_column3,
                                                        ref jsArray, ref jsCenter, Filterd_In_QueryStringName, Filterd_In_QueryStringValue);

                }
                catch (Exception)
                { }
            }

            if (ListUrlHelper5.Trim().Length > 0 && ListUrlHelper5 != "*")
            {

                try
                {
                    SPList objSelectedList = null;
                    SPSecurity.RunWithElevatedPrivileges(
                   delegate ()
                   {
                       SPSite TempCurrentSite = null;
                       try
                       {
                           TempCurrentSite = new SPSite(ListUrlHelper5); //شاید مربوط به سایت کالکشن دیگری باشد و با اچ تی تی پی باز شده باشد
                       }
                       catch
                       {
                           TempCurrentSite = new SPSite(new Guid(SiteID));//در حالتی که در سایت کالکشن های داخلی باشد 
                       }

                       //در هر دو حالت جواب می دهد
                       SPWeb ListTempCurrentWeb = TempCurrentSite.OpenWeb();
                       objSelectedList = ListTempCurrentWeb.GetList(ListUrlHelper5);
                   });

                    HelperClass.GetListItemsAsString(SqlQueryViewName, SqlQueryConnectionString, new Guid(SiteID), RelationalColumnBetweenListsAndViews, IsOuterJoin, objSelectedList, ViewName, ShowByAdminPrevilage, LatField, LongField, StateField, IsCenField, ShouldRemovedFromBaseUrl,
                                                        RelationalColumnForloadInMapPoint, cmbMarekerFilter1_SelectedValue, cmbMarekerFilter2_SelectedValue, cmbMarekerFilter3_SelectedValue,
                                                         txtMarekerSearch1_TextValue, txtMarekerSearch2_TextValue, txtMarekerSearch3_TextValue,
                                                         chlMarekerCheckList1_SelectedValues, chlMarekerCheckList2_SelectedValues, chlMarekerCheckList3_SelectedValues,
                                                         filterd_by_column1, filterd_by_column2, filterd_by_column3,
                                                         Searched_by_column1, Searched_by_column2, Searched_by_column3,
                                                         CheckList_by_column1, CheckList_by_column2, CheckList_by_column3,
                                                         ref jsArray, ref jsCenter, Filterd_In_QueryStringName, Filterd_In_QueryStringValue);

                }
                catch (Exception)
                { }
            }


            return jsArray;
        }

        [WebMethod]
        public static string GetListItemsAsString(
                                 string SqlQueryViewName,
                                 string SqlQueryConnectionString,
                                 string RelationalColumnBetweenListsAndViews,
                                 Boolean IsOuterJoin,
                                 string Filterd_In_QueryStringName,
                                 string Filterd_In_QueryStringValue,
                                 string SiteID,
                                 string Weburl,
                                 string ListName,
                                 string ListUrlHelper1,
                                 string ListUrlHelper2,
                                 string ListUrlHelper3,
                                 string ListUrlHelper4,
                                 string ListUrlHelper5,
                                 string ViewName,
                                 Boolean ShowByAdminPrevilage,
                                 string LatField,
                                 string LongField,
                                 string StateField,
                                 string IsCenField,
                                 string ShouldRemovedFromBaseUrl,
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
                                 string CheckList_by_column3)
        {
            return GetListItemsAsStringByCustomColumn("",
                                       SqlQueryViewName,
                                      SqlQueryConnectionString,
                                      RelationalColumnBetweenListsAndViews,
                                      IsOuterJoin,
                                      Filterd_In_QueryStringName,
                                      Filterd_In_QueryStringValue,
                                      SiteID,
                                      Weburl,
                                      ListName,
                                      ListUrlHelper1,
                                      ListUrlHelper2,
                                      ListUrlHelper3,
                                      ListUrlHelper4,
                                      ListUrlHelper5,
                                      ViewName,
                                      ShowByAdminPrevilage,
                                      LatField,
                                      LongField,
                                      StateField,
                                      IsCenField,
                                      ShouldRemovedFromBaseUrl,
                                      cmbMarekerFilter1_SelectedValue,
                                      cmbMarekerFilter2_SelectedValue,
                                      cmbMarekerFilter3_SelectedValue,
                                      txtMarekerSearch1_TextValue,
                                      txtMarekerSearch2_TextValue,
                                      txtMarekerSearch3_TextValue,
                                      chlMarekerCheckList1_SelectedValues,
                                      chlMarekerCheckList2_SelectedValues,
                                      chlMarekerCheckList3_SelectedValues,
                                      filterd_by_column1,
                                      filterd_by_column2,
                                      filterd_by_column3,
                                      Searched_by_column1,
                                      Searched_by_column2,
                                      Searched_by_column3,
                                      CheckList_by_column1,
                                      CheckList_by_column2,
                                      CheckList_by_column3);
        }
        #endregion

    }
}
