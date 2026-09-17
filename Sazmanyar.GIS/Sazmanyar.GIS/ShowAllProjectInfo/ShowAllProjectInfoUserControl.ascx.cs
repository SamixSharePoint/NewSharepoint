using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

namespace Sazmanyar.GIS.ShowAllProjectInfo
{
    public partial class ShowAllProjectInfoUserControl : UserControl
    {
        #region Variables
        public string InitializeLatLngCamaSemicalonSeperated = "";
        #endregion

        #region Events

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                // محدودهء اولیهء نقشه (پیش‌فرض: کل ایران) - همان الگوی ViewTemplate1
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

            if (IsPostBack)
            {
                return;
            }

            // کمبوی نوع پروژه: «همه موارد» + انواع موجود در PWAInfo
            try
            {
                List<string> objTypes = ClsHelpper.GetPWAProjectTypes();
                cmbProjectType.Items.Add("همه موارد");
                foreach (string strItem in objTypes)
                {
                    cmbProjectType.Items.Add(strItem);
                }
            }
            catch (Exception ex)
            {
                ClsHelpper.WriteToLogFile("ShowAllProjectInfoUserControl.Page_Load: " + ex.Message);
            }
        }

        #endregion
    }
}
