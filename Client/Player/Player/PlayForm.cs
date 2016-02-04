using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using ClientDLL;
using System.Threading;
using System.Diagnostics;
using System.Xml;
using System.Runtime.InteropServices;

namespace Player
{
    public class PlayForm:Form
    {
        [DllImport("user32.dll", EntryPoint = "ShowCursor", CharSet = CharSet.Auto)]
        public static extern void ShowCursor(int status);
        //playlist
        protected string playListPath = Application.StartupPath + "\\playList.xml";
        protected string flashPath = Application.StartupPath + "\\VideoDes.swf";
        //
        protected string m_FileFolder;

        //net
        AsyncClient asyncClient;
        private System.Timers.Timer asyncTimer;
        string ip; int port;
        char[] m_spliter = new char[] { '|' };
        private System.Timers.Timer heartTimer = new System.Timers.Timer(30000);
        private bool m_IsGetHeartJump = false;

        //groupinfo
        protected delegate void VoidDelegate();
        System.Timers.Timer groupInfoSenderTimer = new System.Timers.Timer(2000);

        protected MConfig m_Config;
        public MConfig MConfig
        {
            set { m_Config = value; }
        }
        private void InitializeComponent()
        {
            this.SuspendLayout();
            // 
            // PlayForm
            // 
            this.ClientSize = new System.Drawing.Size(284, 262);
            this.Name = "PlayForm";
            this.Load += new System.EventHandler(this.PlayForm_Load);
            this.ResumeLayout(false);
        }

        public PlayForm()
        {
            InitializeComponent();
        }

        private void PlayForm_Load(object sender, EventArgs e)
        {
            //if (!Site.DesignMode)
            //{
                this.FormBorderStyle = FormBorderStyle.None;
                this.Width = m_Config.Width;
                this.Height = m_Config.Height;
                this.Left = m_Config.LocationX;
                this.Top = m_Config.LocationY;
                m_FileFolder = m_Config.LocalFolder;
                groupInfoSenderTimer.Elapsed += new System.Timers.ElapsedEventHandler(groupInfoSenderTimer_Elapsed);
                InitNet();

                heartTimer.Elapsed += new System.Timers.ElapsedEventHandler(heartTimer_Elapsed);
                BeginCheckHeartJump();

                HideMouse();
            //}
        }

        private void HideMouse()
        {
            ShowCursor(0);
        }

        void heartTimer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            if (!m_IsGetHeartJump)
            {
                Console.WriteLine("未收到心跳，开始重连");
                ReConnect();
            }
            else
            {
                Console.WriteLine("收到心跳，重置监听状态");
                m_IsGetHeartJump = false;
            }
        }

        private void BeginCheckHeartJump()
        {
            heartTimer.Start();
        }

        #region groupid to server
        void BeginSendGroupID()
        {
            groupInfoSenderTimer.Start();
        }

        void StopSendGroupID()
        {
            groupInfoSenderTimer.Stop();
            Console.WriteLine("停止发送组");
        }

        void groupInfoSenderTimer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            this.Invoke(new VoidDelegate(SendGroupIDtoServer));
            //SendGroupIDtoServer();
        }

        public void SendGroupIDtoServer()
        {
            asyncClient.Send("groupID:" + this.m_Config.GroupID + "|");
            Console.WriteLine("发送组信息");
        }
        #endregion

        #region PlayList
        private void OnPlayListIn(string arg)
        {
            string playList = arg;
            SavePlayList(playList);
            UpdatePlayList(playList);
        }

        private void UpdatePlayList(string playList)
        {
            RunPlayList(playList);
        }

        private void SavePlayList(string playList)
        {
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(playList);
            doc.Save(this.playListPath);
            //Console.WriteLine(playList);
        }

        protected void RunSavedPlayList()
        {
            string playList = LoadSavedPlayList();
            RunPlayList(playList);
        }

        private string LoadSavedPlayList()
        {
            XmlDocument xdoc = new XmlDocument();
            try
            {
                xdoc.Load(playListPath);
                return xdoc.InnerXml;
            }
            catch(Exception e)
            {
                Console.WriteLine("load playlist from config file fail:" + e.Message);
                return null;
            }
        }

        /// <summary>
        /// 运行播放列表
        /// </summary>
        /// <param name="playList"></param>
        protected virtual void RunPlayList(string playList)
        {

        }
        #endregion

        #region Socket
        private delegate void DelDataDeal(string data);
        private void InitNet()
        {
            try
            {
                InitAsyncTimer();
                ip = m_Config.IP;
                port = m_Config.Port;
                if (this.asyncClient != null)
                {
                    this.asyncClient.Dispose();
                    this.asyncClient.onConnected -= new AsyncClient.Connected(client_onConnected);
                    this.asyncClient.onDisConnect -= new AsyncClient.DisConnect(client_onDisConnect);
                    this.asyncClient.onDataByteIn -= new AsyncClient.DataByteIn(client_onDataByteIn);
                }
                asyncClient = new AsyncClient();
                asyncClient.onConnected += new AsyncClient.Connected(client_onConnected);
                asyncClient.Connect(ip, port);
                asyncClient.onDataByteIn += new AsyncClient.DataByteIn(client_onDataByteIn);
                asyncClient.onDisConnect += new AsyncClient.DisConnect(client_onDisConnect);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void InitAsyncTimer()
        {
            asyncTimer = new System.Timers.Timer();
            asyncTimer.Interval = 1500;
            asyncTimer.Elapsed += new System.Timers.ElapsedEventHandler(asyncTimer_Elapsed);
            asyncTimer.Start();
        }

        /// <summary>
        /// 服务器信息
        /// </summary>
        /// <param name="SocketData"></param>
        void client_onDataByteIn(byte[] SocketData)
        {
            string data = System.Text.Encoding.UTF8.GetString(SocketData);
            Console.WriteLine("收到：" + data);
            var msgList = data.Split(m_spliter, StringSplitOptions.RemoveEmptyEntries);
            foreach (var msg in msgList)
            {
                this.Invoke(new DelDataDeal(DataDeal), new object[] { msg });
            }
        }

        void DataDeal(string data)
        {
            var msgparts = data.Split(':');
            var fun = msgparts[0];
            //var arg = msgparts[1];
            var arg = data.Substring(data.IndexOf(':') + 1);
            switch (fun)
            {
                case "runPlaylist":
                    OnPlayListIn(arg);
                    break;
                case "groupInfoGot":
                    StopSendGroupID();
                    break;
                case "checkconnection":
                    m_IsGetHeartJump = true;
                    break;
            }
        }    

        void client_onConnected()
        {
            try
            {
                Thread.Sleep(100);
                asyncTimer.Stop();
                BeginSendGroupID();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        void client_onDisConnect()
        {
            asyncTimer.Start();
        }

        private void asyncTimer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            ReConnect();
        }

        private void ReConnect()
        {
            asyncClient.Dispose();
            asyncClient.Connect(ip, port);
        }
        #endregion
    }
}
