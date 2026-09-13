using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

namespace Sazmanyar.GIS.ShowAllKoridorInfo
{
    public partial class ShowAllKoridorInfoUserControl_ViewTemplate3 : UserControl
    {
        #region Variables
        public string InitializeLatLngCamaSemicalonSeperated = "";
        #endregion

        #region Events

        protected void Page_Load(object sender, EventArgs e)
        {

            try
            {
                string strPointBase = "new GLatLng(39.027719, 44.736328), new GLatLng(26.745610, 62.050781)";
                if (InitializeLatLngCamaSemicalonSeperated.Split(';').Length > 0)
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
                if (IsPostBack == true)
                {

                    return;
                }

                chbProgramName.Items.Clear();
                List<string> objList = ClsHelpper.GetProjectNameDataTable();
                foreach (string strItem in objList)
                {
                    chbProgramName.Items.Add(strItem);
                }

                //if (chbProgramName.Items.Count > 0)
                //{
                //    chbProgramName.SelectedIndex = 0;
                //}

            }
            catch (Exception ex)
            {
            }
        }

        #endregion
    }
}
