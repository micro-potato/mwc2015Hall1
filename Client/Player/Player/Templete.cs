using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Player
{
    public class Templete
    {
        Dictionary<string, string> filenameandTime = new Dictionary<string, string>();
        public Dictionary<string, string> FilenameandTime
        {
            get { return filenameandTime; }
            set { filenameandTime = value; }
        }
    }
}
