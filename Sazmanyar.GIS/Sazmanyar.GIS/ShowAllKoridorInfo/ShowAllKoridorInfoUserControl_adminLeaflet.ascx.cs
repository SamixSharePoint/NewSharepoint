using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

namespace Sazmanyar.GIS.ShowAllKoridorInfo
{
    public partial class ShowAllKoridorInfoUserControl_adminLeaflet : UserControl
    {
        #region Variables
        public string InitializeLatLngCamaSemicalonSeperated = "";
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
