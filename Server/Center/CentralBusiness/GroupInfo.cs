using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using Helpers;

namespace CentralBusiness
{
    public class GroupInfo
    {
        public string ID { get; set; }

        private string configPath;
        public string ConfigPath { set { configPath = value; } }

        private string[] input;
        public string[] Input
        {
            get { return input; }
        }

        private string[] showed;
        public string[] Showed
        {
            get { return showed; }
            set { showed = value; }
        }

        private string[] output;
        public string[] OutPut
        {
            get { return output; }
        }

        internal void FillInfoFromConfig()
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(this.configPath);
            var inputString = doc.SelectSingleNode("Data/group" + this.ID+"/input").InnerText;
            var showedString = doc.SelectSingleNode("Data/group" + this.ID + "/showed").InnerText;
            var outputString = doc.SelectSingleNode("Data/group" + this.ID + "/output").InnerText;
            if (!string.IsNullOrEmpty(inputString))
            {
                input = inputString.Split(',');
            }
            if (!string.IsNullOrEmpty(showedString))
            {
                showed = showedString.Split(',');
            }
            if (!string.IsNullOrEmpty(outputString))
            {
                output = outputString.Split(',');
            }
        }

        internal void ResetScreenMatrix()
        {
            if (this.input == null || this.input.Length == 0)//no input
            {
                return;
            }
            this.showed = this.input;

            for (int i = 0; i < this.input.Count(); i++)
            {
                MatrixHelper.GetInstance().SwitchSignal(this.input[i], this.output[i]);
            }
            SaveCurrentConfig();
        }

        public void SaveCurrentConfig()
        {
            try
            {
                string inputString = string.Join(",", this.input);
                string showedString = string.Join(",", this.showed);
                string outputString = string.Join(",", this.output);
                XmlDocument doc = new XmlDocument();
                doc.Load(configPath);
                var inputNode = doc.SelectSingleNode("Data/group" + this.ID + "/input");
                inputNode.InnerText = inputString;
                var showedNode = doc.SelectSingleNode("Data/group" + this.ID + "/showed");
                showedNode.InnerText = showedString;
                var outputNode = doc.SelectSingleNode("Data/group" + this.ID + "/output");
                outputNode.InnerText = outputString;
                doc.Save(configPath);
            }
            catch(Exception e)
            {
                //Helpers.MessageHelper.GetInstance().ShowMessage("未能保存组配置：" + e.Message);
                LogHelper.GetInstance().Append("未能保存组配置：" + e.Message);
            }
        }
    }
}
