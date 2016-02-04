using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Player;
using Helpers;

namespace Player
{
    public class CastPlan
    {
        //Dictionary<string, List<VideoDes>> currentPlayList;
        List<AssetPair> currentPlayList;

        /// <summary>
        /// 节目单，key is play content,value is template
        /// </summary>
        public List<AssetPair> PlayList
        {
            get { return currentPlayList; }
        }

        XmlHelper xmlHelper;
        string playListXML;
        public CastPlan(string playListXML)
        {
            this.playListXML = playListXML;
            xmlHelper = new XmlHelper(playListXML);
            ExtractPlayListFromConfig();
        }

        /// <summary>
        /// 更新播放列表
        /// </summary>
        /// <param name="xmlList">xml格式的播放列表</param>
        /// <returns></returns>
        public void UpdatePlayList(string xmlList)
        {
            try
            {
                XmlHelper.CreateXmlDoc(xmlList,playListXML);
                ExtractPlayListFromConfig();
            }
            catch (Exception ex)
            {
                throw new Exception("未能更新播放列表："+ex.Message);
            }
        }

        /// <summary>
        /// 从xml格式配置文件解析播放列表
        /// </summary>
        private void ExtractPlayListFromConfig()
        {
            try
            {
                xmlHelper = new XmlHelper(playListXML);
                var videoList = xmlHelper.GetNodeGroupbyNodeName("video");
                if (videoList.Count > 0)
                {
                    GetVideoPlayList(videoList);
                }
                else//Only des
                {
                    GetDesPlayList();
                }
            }
            catch(Exception e)
            {
                Console.WriteLine("Extract PlayList error:" + e.Message);
            }
        }

        private void GetDesPlayList()
        {
            //Dictionary<string, List<VideoDes>> tempPlayList = new Dictionary<string, List<VideoDes>>();
            //xmlHelper = new XmlHelper(playListXML);
            //var dess = xmlHelper.GetInnerXmlsfromNode("des");//视频描述，xml格式
            //List<VideoDes> videoDesList = new List<VideoDes>();
            //foreach (var d in dess)//描述明细
            //{
            //    VideoDes videoDes = new VideoDes();
            //    Dictionary<string, string> itemDic = new Dictionary<string, string>();
            //    var desInfo = xmlHelper.GetDicFromXmlpara(d);
            //    foreach (var info in desInfo)
            //    {
            //        if (info.Key == "type")
            //        {
            //            videoDes.DesType = GetDesTypebyNo(desInfo["type"]);
            //        }
            //        else if (info.Key == "last")
            //        {
            //            videoDes.Duration = int.Parse(desInfo["last"].ToString());
            //        }
            //        else
            //        {
            //            itemDic.Add(info.Key, info.Value);
            //        }
            //    }
            //    videoDes.DesItems = itemDic;
            //    videoDesList.Add(videoDes);
            //}
            //tempPlayList.Add("0", videoDesList);
            //this.currentPlayList = tempPlayList;

            //new
            //Dictionary<string, List<VideoDes>> tempPlayList = new Dictionary<string, List<VideoDes>>();
            List<AssetPair> tempPlayList = new List<AssetPair>();
            xmlHelper = new XmlHelper(playListXML);
            var dess = xmlHelper.GetInnerXmlsfromNode("des");//视频描述，xml格式
            List<VideoDes> videoDesList = new List<VideoDes>();
            foreach (var d in dess)//描述明细
            {
                VideoDes videoDes = new VideoDes();
                Dictionary<string, string> itemDic = new Dictionary<string, string>();
                var desInfo = xmlHelper.GetDicFromXmlpara(d);
                foreach (var info in desInfo)
                {
                    if (info.Key == "type")
                    {
                        videoDes.DesType = GetDesTypebyNo(desInfo["type"]);
                    }
                    else if (info.Key == "last")
                    {
                        videoDes.Duration = int.Parse(desInfo["last"].ToString());
                    }
                    else
                    {
                        itemDic.Add(info.Key, info.Value);
                    }
                }
                videoDes.DesItems = itemDic;
                videoDesList.Add(videoDes);
            }
            //tempPlayList.Add("0", videoDesList);
            AssetPair assetPair = new AssetPair();
            assetPair.VideoDesList = videoDesList;
            assetPair.VideoName = "0";
            tempPlayList.Add(assetPair);
            this.currentPlayList = tempPlayList;
        }

        //private void GetVideoPlayList(List<string> videoList)
        //{
        //    Dictionary<string, List<VideoDes>> tempPlayList = new Dictionary<string, List<VideoDes>>();
        //    foreach (var v in videoList)//
        //    {
        //        var fileName = xmlHelper.GetInnerTextfromXmlpara(v, "fileName");
        //        var dess = xmlHelper.GetInnerXmlsfromXmlpara(v, "des");//视频描述，xml格式
        //        List<VideoDes> videoDesList = new List<VideoDes>();
        //        foreach (var d in dess)//描述明细
        //        {
        //            VideoDes videoDes = new VideoDes();
        //            Dictionary<string, string> itemDic = new Dictionary<string, string>();
        //            var desInfo = xmlHelper.GetDicFromXmlpara(d);
        //            foreach (var info in desInfo)
        //            {
        //                if (info.Key == "type")
        //                {
        //                    videoDes.DesType = GetDesTypebyNo(desInfo["type"]);
        //                }
        //                else if (info.Key == "last")
        //                {
        //                    videoDes.Duration = int.Parse(desInfo["last"].ToString());
        //                }
        //                else
        //                {
        //                    itemDic.Add(info.Key, info.Value);
        //                }
        //            }
        //            videoDes.DesItems = itemDic;
        //            videoDesList.Add(videoDes);
        //        }
        //        tempPlayList.Add(fileName, videoDesList);
        //    }
        //    this.currentPlayList = tempPlayList;
        //}

        private void GetVideoPlayList(List<string> videoList)
        {
            //Dictionary<string, List<VideoDes>> tempPlayList = new Dictionary<string, List<VideoDes>>();
            List<AssetPair> tempPlayList = new List<AssetPair>();
            foreach (var v in videoList)//
            {
                var fileName = xmlHelper.GetInnerTextfromXmlpara(v, "fileName");
                var dess = xmlHelper.GetInnerXmlsfromXmlpara(v, "des");//视频描述，xml格式
                List<VideoDes> videoDesList = new List<VideoDes>();
                foreach (var d in dess)//描述明细
                {
                    VideoDes videoDes = new VideoDes();
                    Dictionary<string, string> itemDic = new Dictionary<string, string>();
                    var desInfo = xmlHelper.GetDicFromXmlpara(d);
                    foreach (var info in desInfo)
                    {
                        if (info.Key == "type")
                        {
                            videoDes.DesType = GetDesTypebyNo(desInfo["type"]);
                        }
                        else if (info.Key == "last")
                        {
                            videoDes.Duration = int.Parse(desInfo["last"].ToString());
                        }
                        else
                        {
                            itemDic.Add(info.Key, info.Value);
                        }
                    }
                    videoDes.DesItems = itemDic;
                    videoDesList.Add(videoDes);
                }
                //tempPlayList.Add(fileName, videoDesList);
                AssetPair ap = new AssetPair();
                ap.VideoName = fileName;
                ap.VideoDesList = videoDesList;
                tempPlayList.Add(ap);
            }
            this.currentPlayList = tempPlayList;
        }

        private VideoDesType GetDesTypebyNo(string typeNo)
        {
            switch (typeNo)
            {
                case "video":
                    return VideoDesType.Video;
                case "pic":
                    return VideoDesType.Pic1;
                case "vote":
                    return VideoDesType.Vote;
                default:
                    throw new Exception("错误的格式");
            }
        }
    }

    public enum VideoDesType { Video, Pic1, Vote }
    public class VideoDes
    {
        int duration;
        /// <summary>
        /// 轮播时间
        /// </summary>
        public int Duration
        {
            get { return duration; }
            set { duration = value; }
        }

        VideoDesType desType;
        public VideoDesType DesType
        {
            get { return desType; }
            set { desType = value; }
        }

        Dictionary<string, string> desItems;
        public Dictionary<string, string> DesItems
        {
            get { return desItems; }
            set { desItems = value; }
        }
    }
}
