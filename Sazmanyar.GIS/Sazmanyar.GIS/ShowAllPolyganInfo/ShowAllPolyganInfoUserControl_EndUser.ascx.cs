using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

namespace Sazmanyar.GIS.ShowAllPolyganInfo
{
    public partial class ShowAllPolyganInfoUserControl_EndUser : UserControl
    {
        #region Variables

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
            }
            catch (Exception ex)
            {
            }
        }

        #endregion

        protected void btnSabt_Click(object sender, EventArgs e)
        {

        }
    }
}
