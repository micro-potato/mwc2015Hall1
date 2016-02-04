using System;
using System.Xml;

namespace CentralBusiness
{
    public class ConfigDeal
    {
        public MConfig GetMessage(string configPath)
        {
            MConfig mConfig = new MConfig();
            XmlDocument xmlDocument = new XmlDocument();
            xmlDocument.Load(configPath);
            mConfig.Port = Convert.ToInt32(xmlDocument.SelectSingleNode("Data/Port").InnerText);
            mConfig.AssetFolder = xmlDocument.SelectSingleNode("Data/AssetFolder").InnerText;
            mConfig.Width = Convert.ToInt32(xmlDocument.SelectSingleNode("Data/Width").InnerText);
            mConfig.Height = Convert.ToInt32(xmlDocument.SelectSingleNode("Data/Height").InnerText);
            mConfig.Serialport = xmlDocument.SelectSingleNode("Data/Serialport").InnerText;
            return mConfig;
        }
    }
}
