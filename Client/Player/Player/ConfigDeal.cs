using System;
using System.Xml;

namespace Player
{
    public class ConfigDeal
    {
        private readonly string xmlPath = System.Windows.Forms.Application.StartupPath + @"\config.xml";
        public MConfig GetMessage()
        {
            MConfig mConfig = new MConfig();
            XmlDocument xmlDocument = new XmlDocument();
            xmlDocument.Load(xmlPath);
            mConfig.IP = xmlDocument.SelectSingleNode("Data/IP").InnerText;
            mConfig.Port = Convert.ToInt32(xmlDocument.SelectSingleNode("Data/Port").InnerText);
            mConfig.Width = Convert.ToInt32(xmlDocument.SelectSingleNode("Data/Width").InnerText);
            mConfig.Height = Convert.ToInt32(xmlDocument.SelectSingleNode("Data/Height").InnerText);
            mConfig.LocationX = Convert.ToInt32(xmlDocument.SelectSingleNode("Data/LocationX").InnerText);
            mConfig.LocationY = Convert.ToInt32(xmlDocument.SelectSingleNode("Data/LocationY").InnerText);
            mConfig.ServerFolder = xmlDocument.SelectSingleNode("Data/ServerFolder").InnerText;
            mConfig.LocalFolder = xmlDocument.SelectSingleNode("Data/LocalFolder").InnerText;
            mConfig.IsDouble = Convert.ToInt32(xmlDocument.SelectSingleNode("Data/IsDouble").InnerText);
            mConfig.IsManageFile = Convert.ToInt32(xmlDocument.SelectSingleNode("Data/IsManageFile").InnerText);
            mConfig.GroupID = xmlDocument.SelectSingleNode("Data/GroupID").InnerText;
            return mConfig;
        }
    }
}
