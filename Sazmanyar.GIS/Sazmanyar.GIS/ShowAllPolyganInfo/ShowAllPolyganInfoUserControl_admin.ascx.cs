using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

namespace Sazmanyar.GIS.ShowAllPolyganInfo
{
    public partial class ShowAllPolyganInfoUserControl_admin : UserControl
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
    }
}
