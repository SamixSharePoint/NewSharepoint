using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

namespace Sazmanyar.GIS.ShowAllKoridorInfo
{
    public partial class ShowAllKoridorInfoUserControl_adminGoogle : UserControl
    {
        #region Variables
        public string InitializeLatLngCamaSemicalonSeperated = "";
        // مقدار واقعی از پراپرتی وب‌پارت (ShowAllKoridorInfo.GoogleMapsApiKey) قبل از Controls.Add ست می‌شود؛
        // این مقدار پیش‌فرض فقط برای زمانی است که کنترل مستقیم (بدون عبور از وب‌پارت) بارگذاری شود.
        public string GoogleMapsApiKey = "AIzaSyBk2zY1PsSNsYBAFC7Gi-qCbTm4rvvAo_g";
        #endregion

        #region Events

        protected void Page_Load(object sender, EventArgs e)
        {

          
            try
            {
                if (IsPostBack == true)
                {
                    return;
                }

                cmbNameProjeh.Items.Clear();
                List<string> objList = ClsHelpper.GetProjectNameDataTable();
                foreach (string strItem in objList)
                {
                    cmbNameProjeh.Items.Add(strItem);
                }

            }
            catch (Exception ex)
            {
            }
        }

        #endregion

    }
}
