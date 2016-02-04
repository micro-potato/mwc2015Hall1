using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.IO;

namespace Player
{
    public class FlashHelper
    {
        private AxShockwaveFlashObjects.AxShockwaveFlash container;
        public FlashHelper(string flashPath,AxShockwaveFlashObjects.AxShockwaveFlash flashContainer)
        {
            container=flashContainer;
            container.Movie = flashPath;
        }

        private string EncodeInvoke(string Functionname, string arg)
        {
            StringBuilder sb = new StringBuilder();
            XmlTextWriter xw = new XmlTextWriter(new StringWriter(sb));

            xw.WriteStartElement("invoke");
            xw.WriteAttributeString("name", Functionname);
            xw.WriteAttributeString("returntype", "xml");

            xw.WriteStartElement("arguments");
            xw.WriteStartElement("string");   //此处直接创建string类型，没做别的类型判断
            xw.WriteString(arg);
            xw.WriteEndElement();
            xw.WriteEndElement();

            xw.WriteEndElement();

            xw.Flush();
            xw.Close();
            return sb.ToString();
        }

        public void SendtoFlash(string functionName, string arg)
        {
            container.CallFunction(EncodeInvoke(functionName, arg));
        }
    }
}
