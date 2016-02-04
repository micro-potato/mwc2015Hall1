using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Helpers;

namespace CentralBusiness
{
    public class GroupDirector
    {
        private SocketHelper m_socket;
        private string m_groupconfigPath;
        private Dictionary<string, GroupInfo> m_groupInfoDic = new Dictionary<string, GroupInfo>();

        public string GroupConfigPath
        {
            set { m_groupconfigPath = value; }
        }

        public SocketHelper Socket
        {
            set { m_socket = value; }
        }

        public void PreviewPlayList(string playListXML)
        {
            RunPlayList("0", playListXML);
        }

        public void RunPlayList(string groupID, string playlistXML)
        {
            if (m_socket != null)
            {
                m_socket.SendMessge(groupID, string.Format("runPlaylist:{0}",playlistXML));
                ResetScreenMatrix(groupID);
            }
        }

        /// <summary>
        /// set screens in this group showed themself
        /// </summary>
        /// <param name="groupID"></param>
        private void ResetScreenMatrix(string groupID)
        {
            GroupInfo gInfo = GetGroupInfo(groupID);
            gInfo.ResetScreenMatrix();
        }

        private GroupInfo GetGroupInfo(string groupID)
        {
            if (!this.m_groupInfoDic.ContainsKey(groupID))//configed groupinfo existed
            {
                return GetGroupInfoFromConfig(groupID);
            }
            else
            {
                return m_groupInfoDic[groupID];
            }
        }

        private GroupInfo GetGroupInfoFromConfig(string groupID)
        {
            GroupInfo info = new GroupInfo();
            info.ConfigPath = this.m_groupconfigPath;
            info.ID = groupID;
            info.FillInfoFromConfig();
            return info;
        }

        public void SyncGroup(string groupID)
        {
            var sourceInfo = GetGroupInfo(groupID);
            var targetInfo = GetGroupInfo("0");
            var sourceInputs = sourceInfo.Showed;
            targetInfo.Showed=sourceInputs;
            try
            {
                MatrixHelper.GetInstance().SwitchSignal(sourceInputs[0], targetInfo.OutPut[0]);//sync left screen
                if (sourceInputs.Length == 2)//group has 2 screens
                {
                    MatrixHelper.GetInstance().SwitchSignal(sourceInputs[1], targetInfo.OutPut[1]);//sync right screen
                }
                targetInfo.SaveCurrentConfig();
            }
            catch (Exception e)
            {
                LogHelper.GetInstance().Append(string.Format("预览组出错：{0}", e.Message));
            }
        }

        /// <summary>
        /// 广播播放内容
        /// </summary>
        /// <param name="sourceGroupID">源组</param>
        /// <param name="targetGroupIDs">目标组</param>
        public void BroadCast(string sourceGroupID, string[] targetGroupIDs)
        {
            var sourceInfo = GetGroupInfo(sourceGroupID);
            var inputCount = sourceInfo.Input.Count();
            foreach (var targetID in targetGroupIDs)
            {
                var targetInfo = GetGroupInfo(targetID);
                if (sourceInfo.Input.Count() != targetInfo.Showed.Count())
                {
                    LogHelper.GetInstance().Append(string.Format("组{0}和组{1}屏数量不一致，无法广播", sourceInfo.ID, targetInfo.ID));
                    continue;
                }
                else
                {
                    for (int i = 0; i < inputCount; i++)
                    {
                        var sourceIntput = sourceInfo.Input[i];
                        var targetOutput = targetInfo.OutPut[i];
                        MatrixHelper.GetInstance().SwitchSignal(sourceIntput, targetOutput);
                        targetInfo.Showed = sourceInfo.Input;
                        targetInfo.SaveCurrentConfig();
                    }
                }
            }
        }
    }
}
