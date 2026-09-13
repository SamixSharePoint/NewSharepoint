using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Sazmanyar.GIS.Helper
{
    public class clsRouteForJson
    {
        public double k { get; set; }
        public double b { get; set; }
        public string C { get; set; }
        public int T { get; set; }
        
        public string Color
        {
            get
            {
                return C;
            }
            set
            {
                C = value;
            }

        }

        public int State
        {
            get
            {
                return T;
            }
            set
            {
                T = value;
            }

        }

        public double lat
        {
            get
            {
                return k;
            }
            set
            {
                k = value;
            }

        }

        public double lng
        {
            get
            {
                return b;
            }
            set
            {
                b = value;
            }
        }

    }
}
