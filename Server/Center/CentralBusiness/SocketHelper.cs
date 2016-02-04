using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ServerDLL;
using Helpers;

namespace CentralBusiness
{
    public class SocketHelper
    {
        AsyncServer m_server;
        int m_port;
        Dictionary<string, int> dicGroupIDClientID = new Dictionary<string, int>();
        private delegate void DelegateMsg(int index, int msg);

        //心跳
        private System.Timers.Timer heartTimer = new System.Timers.Timer(25000);

        public SocketHelper(int port)
        {
            // TODO: Complete member initialization
            m_port = port;
            Init();
        }

        /// <summary>
        /// 初始化socket服务
        /// </summary>
        private void Init()
        {
            if (m_server == null)
            {
                m_server = new AsyncServer();
                if (m_server.Listen(m_port, 2000))
                {
                    m_server.onConnected += new AsyncServer.SocketConnected(asyncServer_onConnected);
                    m_server.onDisconnected += new AsyncServer.SocketDisconnected(server_onDisconnected);
                    m_server.onDataByteIn += new AsyncServer.SocketDataByteIn(server_onDataByteIn);
                    heartTimer.Elapsed += new System.Timers.ElapsedEventHandler(heartTimer_Elapsed);
                    BeginHeartJump();
                }
                else
                {
                    //Helpers.MessageHelper.GetInstance().ShowMessage(string.Format("端口{0}被占用，请重新配置",m_port.ToString()));
                    LogHelper.GetInstance().Append(string.Format("端口{0}被占用，请重新配置", m_port.ToString()));
                }
            }
        }

        void heartTimer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            m_server.SendToAll("checkconnection:c|");
            LogHelper.GetInstance().Append("发送心跳");
        }

        private void BeginHeartJump()
        {
            heartTimer.Start();
        }

        //客户端连线
        void asyncServer_onConnected(int index, string ip)
        {
            string message = string.Format("{0}连线!", ip);
            //System.Threading.Thread.Sleep(100);
            LogHelper.GetInstance().Append(message);
        }

        //客户端断线
        void server_onDisconnected(int index,string ip)
        {
            string message = string.Format("{0}断线!", ip);
            //System.Threading.Thread.Sleep(100);
            LogHelper.GetInstance().Append(message);
        }

        //消息进入
        void server_onDataByteIn(int index, string ip, byte[] SocketData)
        {
            string command = System.Text.Encoding.UTF8.GetString(SocketData);
            LogHelper.GetInstance().Append(command);
            var cmds = command.Split('|');
            foreach (var cmd in cmds)
            {
                DealMsg(index, cmd);
            }
        }

        private void DealMsg(int index, string msg)
        {
            var msgPart = msg.Split(':');
            var fun = msgPart[0];
            var arg = msgPart[msgPart.Length - 1];
            switch (fun)
            {
                case "groupID":
                    UpdateGroupID(index, arg);
                    break;
            }
        }

        private void UpdateGroupID(int index, string groupID)
        {
            if (dicGroupIDClientID.ContainsKey(groupID))
            {
                dicGroupIDClientID[groupID] = index;
            }
            else
            {
                dicGroupIDClientID.Add(groupID, index);
            }
            SendMessge(groupID, "groupInfoGot:|");
            //Console.WriteLine("更新组:"+groupID.ToString());
            //LogHelper.GetInstance().Append(string.Format("更新组{0}的客户端号为：{1}", groupID, index.ToString()));
        }

        internal void SendMessge(string groupID, string msg)
        {
            if (!dicGroupIDClientID.ContainsKey(groupID))//Unknown client
            {
                return;
            }
            m_server.Send(dicGroupIDClientID[groupID], msg);
        } 
    }
}
