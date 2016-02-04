using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace Helpers
{
    public class XmlHelper
    {
        private XmlDocument doc;
        //private string path;
        //public XmlHelper(string filePath)
        //{
        //    path = filePath;
        //    doc = new XmlDocument();
        //    doc.Load(path);
        //}
        public XmlHelper(string xmlContent)
        {
            doc = new XmlDocument();
            doc.LoadXml(xmlContent);
        }

        //public void AddNode(string parent, string key, string value)
        //{
        //    if (doc != null)
        //    {
        //        var parentNode = doc.SelectSingleNode(parent);
        //        if (parentNode.SelectNodes(key).Count != 0)
        //        {
        //            throw new Exception("node has already exist,can not add");
        //        }
        //        var node = doc.CreateElement(key);
        //        node.InnerText = value;
        //        parentNode.AppendChild(node);
        //        doc.Save(path);
        //        Refresh();
        //    }
        //}

        //public void AlterNode(string parent, string key, string value)
        //{
        //    if (doc != null)
        //    {
        //        var parentNode = doc.SelectSingleNode("*//" + parent);
        //        var node = parentNode.SelectSingleNode(key);
        //        if (node == null)
        //        {
        //            throw new Exception("node has not exist,can not alter");
        //        }
        //        node.InnerText = value;
        //        doc.Save(path);
        //        Refresh();
        //    }
        //}

        public Dictionary<string, string> GetDicUnderNode(string nodeName)
        {
            if (doc != null)
            {
                var node = doc.SelectSingleNode("*//" + nodeName);
                if (node == null)
                {
                    throw new Exception("node does not exist");
                }
                var nodes = node.ChildNodes;
                Dictionary<string, string> dic = new Dictionary<string, string>();
                foreach (XmlNode n in nodes)
                {
                    dic.Add(n.Name, n.InnerText);
                }
                return dic;
            }
            else
            {
                throw new Exception("xml file doesn't exist");
            }
        }

        public List<string> GetInnerXmlsfromNode(string nodeName)
        {
            if (doc != null)
            {
                var node = doc.SelectSingleNode("*//" + nodeName);
                if (node == null)
                {
                    throw new Exception("node does not exist");
                }
                var nodes = node.ChildNodes;
                List<string> list = new List<string>();
                foreach (XmlNode n in nodes)
                {
                    list.Add(n.InnerText);
                }
                return list;
            }
            else
            {
                throw new Exception("xml file doesn't exist");
            }
        }

        public string GetNodeValue(string nodeName)
        {
            return doc.SelectSingleNode("*//" + nodeName).InnerText;
        }

        public List<string> GetNodeGroupbyNodeName(string parent, string nodeName)
        {
            List<string> nodeList = new List<string>();
            var parentNode = doc.SelectSingleNode("*//" + parent);
            var nodes = parentNode.SelectNodes("*//" + nodeName);
            foreach (var n in nodes)
            {
                nodeList.Add((n as XmlElement).InnerXml.ToString());
            }
            return nodeList;
        }

        public List<string> GetNodeGroupbyNodeName(string nodeName)
        {
            List<string> nodeList = new List<string>();
            var nodes = doc.SelectNodes("//" + nodeName);
            foreach (var n in nodes)
            {
                nodeList.Add((n as XmlElement).InnerXml.ToString());
            }
            return nodeList;
        }

        public Dictionary<string,string> GetDicFromXmlpara(string xmlPara)
        {
            XmlDocument xd = new XmlDocument();
            StringBuilder sb = new StringBuilder();
            sb.Append("<root>");
            sb.Append(xmlPara);
            sb.Append("</root>");
            xd.InnerXml = sb.ToString();
            var nodes = xd.SelectSingleNode("/root").ChildNodes;
            Dictionary<string, string> dic = new Dictionary<string, string>();
            foreach (XmlNode n in nodes)
            {
                dic.Add(n.Name, n.InnerText);
            }
            return dic;
        }

        /// <summary>
        /// 获取xml片段中节点的值
        /// </summary>
        /// <param name="xmlPara"></param>
        /// <param name="nodeName"></param>
        /// <returns></returns>
        public string GetInnerTextfromXmlpara(string xmlPara, string nodeName)
        {
            XmlDocument xd = new XmlDocument();
            StringBuilder sb = new StringBuilder();
            sb.Append("<root>");
            sb.Append(xmlPara);
            sb.Append("</root>");
            xd.InnerXml = sb.ToString();
            return xd.SelectSingleNode("*//" + nodeName).InnerText;
        }

        /// <summary>
        /// 获取xml片段中节点的值
        /// </summary>
        /// <param name="xmlPara"></param>
        /// <param name="nodeName"></param>
        /// <returns></returns>
        public List<string> GetInnerTextsfromXmlpara(string xmlPara, string nodeName)
        {
            XmlDocument xd = new XmlDocument();
            StringBuilder sb = new StringBuilder();
            sb.Append("<root>");
            sb.Append(xmlPara);
            sb.Append("</root>");
            xd.InnerXml = sb.ToString();
            List<string> texts = new List<string>();
            var nodes = xd.SelectNodes("*//" + nodeName);
            foreach (var n in nodes)
            {
                texts.Add((n as XmlNode).InnerText);
            }
            return texts;
        }

        public List<string> GetInnerXmlsfromXmlpara(string xmlPara, string nodeName)
        {
            XmlDocument xd = new XmlDocument();
            StringBuilder sb = new StringBuilder();
            sb.Append("<root>");
            sb.Append(xmlPara);
            sb.Append("</root>");
            xd.InnerXml = sb.ToString();
            List<string> texts = new List<string>();
            var nodes = xd.SelectNodes("*//" + nodeName);
            foreach (var n in nodes)
            {
                texts.Add((n as XmlNode).InnerXml);
            }
            return texts;
        }

        //private void Refresh()
        //{
        //    if (!string.IsNullOrEmpty(path))
        //    {
        //        doc = null;
        //        doc = new XmlDocument();
        //        doc.Load(path);
        //    }
        //}

        /// <summary>
        /// 检测节点值为目标值的个数
        /// </summary>
        /// <param name="p"></param>
        /// <param name="inputID"></param>
        /// <returns></returns>
        public int GetNodeCountHasVeryInnerText(string nodeName, string innerText)
        {
            var nodes = doc.SelectNodes("*//" + nodeName);
            int count = 0;
            for (int i = 0; i < nodes.Count; i++)
            {
                if (nodes[i].InnerText == innerText)
                {
                    count++;
                }
            }
            return count;
        }

        /// <summary>
        /// 获得已知值节点的兄弟节点的值
        /// </summary>
        /// <param name="nodeName">已知值节点</param>
        /// <param name="targetNodeName">求值的节点</param>
        /// <param name="innerText">已知节点的值</param>
        /// <returns></returns>
        public string GetNodeSiblingValue(string nodeName, string targetNodeName, string innerText)
        {
            var nodes = doc.SelectNodes("//" + nodeName);
            for (int i = 0; i < nodes.Count; i++)
            {
                if (nodes[i].InnerText == innerText)
                {
                    return nodes[i].ParentNode.SelectSingleNode(targetNodeName).InnerText;
                }
            }
            return null;
        }

        public void DeleteNode(string p, string p_2)
        {
            throw new NotImplementedException();
        }

        //public void UpdateAllContent(string xmlList)
        //{
        //    doc.RemoveAll();
        //    doc.InnerXml = xmlList;
        //    doc.Save(path);
        //    Refresh();
        //}

        public static void CreateXmlDoc(string xmlPlayList, string playListConfigPath)
        {
            XmlDocument xd = new XmlDocument();
            xd.InnerXml = xmlPlayList;
            xd.Save(playListConfigPath);
        }
    }
}
