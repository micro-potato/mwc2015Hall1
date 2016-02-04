using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Xml;
using CentralBusiness;
using System.IO;
using Helpers;
using Auxiliary;

namespace CentralControlFlashVer
{
    public partial class MainForm : Form,ILog,IMatrixSender
    {
        private delegate void DeleFlashCall(string func,string arg);
        private List<string> videoSuffixs = new List<string> {"mp4","flv","wmv" };
        //config
        private string configPath = Application.StartupPath + "\\config.xml";
        private string playlistConfigFolder = Application.StartupPath + "\\playlist";
        private string groupconfigPath = Application.StartupPath + "\\groupconfig.xml";

        private MConfig m_config;

        //cast
        private GroupDirector m_Director = new GroupDirector();

        //log
        private delegate void DelSetText(string data);

        //Serial
        private SerialPortHelper m_Serial;
        public MainForm()
        {
            InitializeComponent();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            SetStyle(ControlStyles.AllPaintingInWmPaint, true); // 禁止擦除背景.
            SetStyle(ControlStyles.DoubleBuffer, true); // 双缓冲
            SetStyle(ControlStyles.OptimizedDoubleBuffer, true);// 双缓冲

            rtb_data.Visible = false;
            LogHelper.GetInstance().RegisterLog(this);
            InitConfigs();
            InitForm();
            InitTitleBar();
            InitNet();
            InitFlash();
            InitSerial();
            
            m_Director.GroupConfigPath = this.groupconfigPath;
            //DisableRightClick();
            //注册热键
            //按Ctrl+Alt+F1组合键弹出或隐藏调试窗口)
            try
            {
                HotKey.RegisterHotKey(Handle, 101, HotKey.KeyModifiers.Alt | HotKey.KeyModifiers.Ctrl, Keys.F1);
            }
            catch
            {

            }
        }

        private void DisableRightClick()
        {
            MouseHook hook = new MouseHook();
            hook.StartHook();
        }

        private void InitForm()
        {
            this.Location = new Point(240,90);
        }

        private void ExitApplication()
        {
            System.Diagnostics.Process.GetCurrentProcess().Kill();
        }

        #region Config
        private void InitConfigs()
        {
            m_config = new ConfigDeal().GetMessage(this.configPath);
        }
        #endregion

        #region Flash
        private void InitFlash()
        {
            this.axShockwaveFlash1.Movie = Application.StartupPath + "\\main.swf";
            this.axShockwaveFlash1.SetVariable("y", "-60");
            this.axShockwaveFlash1.FlashCall += new AxShockwaveFlashObjects._IShockwaveFlashEvents_FlashCallEventHandler(axShockwaveFlash1_FlashCall);
        }

        void axShockwaveFlash1_FlashCall(object sender, AxShockwaveFlashObjects._IShockwaveFlashEvents_FlashCallEvent e)
        {
            XmlDocument document = new XmlDocument();
            document.LoadXml(e.request);
            // get attributes to see which command flash is trying to call
            XmlAttributeCollection attributes = document.FirstChild.Attributes;
            string attLast = document.LastChild.InnerXml.ToString();

            //方法名
            String command = attributes.Item(0).InnerText;
            //参数
            string[] deal = DealParameters(attLast);
            //get parameters
            XmlNodeList list = document.GetElementsByTagName("arguments");
            this.Invoke(new DeleFlashCall(DealFlashCall), new object[] {command,deal[0]});
        }

        //参数解析
        private string[] DealParameters(string parameters)
        {
            //<arguments><string>tgc</string><string>ctz</string></arguments>
            string msg = parameters.Replace("<arguments><string>", "").Replace("</string></arguments>", "").Replace("</string><string>", "^");
            string[] deal = msg.Split('^');
            return deal;
        }

        private void SendtoFlash(string args)
        {
            string func = "datain";
            //this.axShockwaveFlash1.CallFunction(EncodeInvoke(functionName, arg));
            string str = "<invoke name=\"" + func + "\" returntype=\"xml\"><arguments>";
            if (args != "")
            {
                str += "<string><![CDATA[" + args + "]]></string>";
            }
            str += "</arguments></invoke>";
            try
            {
                this.axShockwaveFlash1.CallFunction(str);
            }
            catch(Exception e)
            {
                Console.WriteLine("向flash发送命令失败：" + e.Message);
            }
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

        private void DealFlashCall(string fun, string arg)
        {
            switch (fun)
            {
                case "requestVideoFile":
                    SelectVideoFile(arg);
                    break;
                case "requestDesFile":
                    SelectDesFile(arg);
                    break;
                case "savePlayList":
                    SavePlayListFile(arg);
                    break;
                case "requestPlayList":
                    LoadPlayList();
                    break;
                case CommandCollection.LoadTypeError:
                    ShowPlayListTypeErrorMessage();
                    break;
                case CommandCollection.RequestPreView:
                    PrewPlayList(arg);
                    break;
                case "syncGroup":
                    SynGroup(arg);
                    break;
                case "playPlayList":
                    RunPlayList(arg);
                    break;
                case "broadcast":
                    var argParts = arg.Split(':');
                    var sourceGroupID = argParts[0];
                    var tarGroupsString = argParts[1];
                    var targetGroupIDs = tarGroupsString.Split(',');
                    BroadCast(sourceGroupID, targetGroupIDs);
                    break;
                case "requestExit":
                    ExitApplication();
                    break;
            }
        }
        #endregion

        /// <summary>
        /// show a group's content on group 0's screens
        /// </summary>
        /// <param name="arg"></param>
        private void SynGroup(string arg)
        {
            var sourceGroupID = arg;
            m_Director.SyncGroup(sourceGroupID);
        }

        /// <summary>
        /// 广播播放内容
        /// </summary>
        /// <param name="sourceGroupID">源组</param>
        /// <param name="targetGroupIDs">目标组</param>
        private void BroadCast(string sourceGroupID, string[] targetGroupIDs)
        {
            m_Director.BroadCast(sourceGroupID, targetGroupIDs);
        }

        #region PlayList
        private void SelectVideoFile(string initID)
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Multiselect = false;
            ofd.Filter = "视频文件|*.mp4;*.flv;*.mov";
            ofd.InitialDirectory = m_config.AssetFolder;
            var result = ofd.ShowDialog();
            if (result == DialogResult.OK)
            {
                FileInfo fi = new FileInfo(ofd.FileName);
                if (fi.Directory.ToString() != m_config.AssetFolder)//selected file is not in AssetFile
                {
                    MessageBox.Show("请选择资源文件夹中的文件");
                }
                else
                {
                    string fileName = ofd.SafeFileName;
                    string desCMD = "respondVideoFile:" + initID + "^" + fileName;
                    CreateVideoPreviewPic(fileName);
                    SendtoFlash(desCMD);
                }
            }
        }

        private void SelectDesFile(string initID)
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Multiselect = false;
            ofd.Filter = "多媒体文件|*.png;*.jpg;*.jpeg;*.mp4;*.flv;*.mov";
            ofd.InitialDirectory=m_config.AssetFolder;
            var result = ofd.ShowDialog();
            if (result == DialogResult.OK)
            {
                FileInfo fi = new FileInfo(ofd.FileName);
                if (fi.Directory.ToString() != m_config.AssetFolder)//selected file is not in AssetFile
                {
                    MessageBox.Show("请选择资源文件夹中的文件");
                }
                else
                {
                    string fileName = ofd.SafeFileName;
                    string desCMD = "respondDesFile:" + initID + "^" + fileName;
                    if (IsVideo(fileName))
                    {
                        CreateVideoPreviewPic(fileName);
                    }
                    SendtoFlash(desCMD);
                }
            }
        }

        private void SavePlayListFile(string arg)
        {
            var playList = arg;
            var playListXML = PlaylistXML(playList);
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(playListXML);
            SaveFileDialog sfd = new SaveFileDialog();
            sfd.Filter = "播放列表|*.xml";
            if (sfd.ShowDialog() == DialogResult.OK)
            {
                var fileName = sfd.FileName;
                doc.Save(fileName);
            } 
        }

        private void LoadPlayList()
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.InitialDirectory = m_config.AssetFolder;
            ofd.Filter = "播放列表|*.xml";
            var result = ofd.ShowDialog();
            if (result == DialogResult.OK)
            {
                try
                {
                    var filePath = ofd.FileName;
                    XmlDocument doc = new XmlDocument();
                    doc.Load(filePath);
                    SendtoFlash(CommandCollection.RespondPlayList+":"+doc.InnerXml);
                }
                catch(Exception e)
                {
                    Console.WriteLine("Load playlist failure:"+e.Message);
                }
            }
        }

        private void ShowPlayListTypeErrorMessage()
        {
            MessageBox.Show("该播放列表不能加载，请确认单双屏的匹配是否正确");
        }

        private void PrewPlayList(string arg)
        {
            var playListXML = PlaylistXML(arg);
            m_Director.PreviewPlayList(playListXML);
        }

        private void RunPlayList(string arg)
        {
            var groupID = arg.Split(':')[0].ToString();
            var playlistText = arg.Substring(arg.IndexOf(':')+1);
            string playlistXML = PlaylistXML(playlistText);
            UpdateGroupConfig(groupID, playlistXML);
        }

        /// <summary>
        /// 更新本地播放列表配置文件
        /// </summary>
        /// <param name="groupID"></param>
        /// <param name="playlistXML"></param>
        private void UpdateGroupConfig(string groupID, string playlistXML)
        {
            try
            {
                var savePath = string.Format(@"{0}\{1}.xml", this.playlistConfigFolder, groupID);
                XmlDocument xd = new XmlDocument();
                xd.LoadXml(playlistXML);
                xd.Save(savePath);
                m_Director.RunPlayList(groupID, playlistXML);
            }
            catch (Exception e)
            {
                Console.WriteLine("保存播放列表失败：" + e.Message);
            }
        }

        /// <summary>
        /// 将配置的播放列表加工成可保存的xml文件
        /// </summary>
        /// <param name="playlistText"></param>
        /// <returns></returns>
        private string PlaylistXML(string playlistText)
        {
            playlistText = playlistText.Replace("&lt;", "<").Replace("&gt;", ">");
            return string.Format("{0}\r\n{1}\r\n{2}", "<data>", playlistText, "</data>");
        }

        private void CreateVideoPreviewPic(string fileName)
        {
            string videoPath = m_config.AssetFolder + "\\" + fileName;
            string fileNamewithoutSuffix=fileName.Substring(0,fileName.LastIndexOf('.'));
            string videoThrumbNailPath = m_config.AssetFolder + "\\" + fileNamewithoutSuffix + ".jpg";
            if (!File.Exists(videoThrumbNailPath))
            {
                VideoThumbConverter.CreateThumbnail(videoPath, videoThrumbNailPath);//生成视频缩略图
            }
        }

        private bool IsVideo(string fileName)
        {
            var suffix = fileName.Substring(fileName.LastIndexOf('.') + 1);
            if (videoSuffixs.Contains(suffix))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        #endregion

        #region Net
        private void InitNet()
        {
            var socket = new SocketHelper(m_config.Port);
            m_Director.Socket = socket;
        }
        #endregion

        #region Log
        public void AppendLog(string msg)
        {
            this.Invoke(new DelSetText(SetText), new object[] { msg });
        }

        private void SetText(string data)
        {
            rtb_data.AppendText(data + "\n");
        }

        protected override void WndProc(ref Message m)
        {
            const int WM_HOTKEY = 0x0312;
            //按快捷键    
            switch (m.Msg)
            {
                case WM_HOTKEY:
                    switch (m.WParam.ToInt32())
                    {
                        case 101:
                            rtb_data.Visible = !rtb_data.Visible;
                            return;
                    }
                    break;
            }
            base.WndProc(ref m);
        }
        #endregion

        #region Serial
        private void InitSerial()
        {
            m_Serial = new SerialPortHelper(m_config.Serialport, 9600);
            MatrixHelper.GetInstance().InsertSender(this);
        }

        public void Send(string cmd)
        {
            if (m_Serial != null)
            {
                m_Serial.Send0x(cmd);
            }
        }
        #endregion

        #region Titlebar
        private void InitTitleBar()
        {
            this.FormBorderStyle = FormBorderStyle.None;
            panel1.MouseDown += new MouseEventHandler(panel1_MouseDown);
            panel1.MouseMove += new MouseEventHandler(panel1_MouseMove);
            panel1.MouseUp += new MouseEventHandler(panel1_MouseUp);
        }

        #region MOUSE-EVENTS ON PANEL CONTROL
        // Routines to perform moving form by click & drag on TitleBar

        private bool m_MousePressed = false;
        private int m_oldX, m_oldY;
        void panel1_MouseDown(object sender, MouseEventArgs e)
        {
            Point TS = this.PointToScreen(e.Location);
            m_oldX = TS.X;
            m_oldY = TS.Y;
            m_MousePressed = true;
        }
        void panel1_MouseUp(object sender, MouseEventArgs e)
        {
            m_MousePressed = false;
        }
        void panel1_MouseMove(object sender, MouseEventArgs e)
        {
            // if not maximized we can move our form
            if (m_MousePressed == true && m_WindowState != FormWindowState.Maximized)
            {
                Point TS = this.PointToScreen(e.Location);

                this.Location = new Point(this.Location.X + (TS.X - m_oldX),
                                          this.Location.Y + (TS.Y - m_oldY));
                m_oldX = TS.X;
                m_oldY = TS.Y;
            }
        }

        #endregion

        #region Changing WindowState Function

        private void ButtonClose_Click(object sender, EventArgs e)
        {
            Close();
        }

        private FormWindowState m_WindowState = FormWindowState.Normal;
        private Rectangle m_FormSizeAndLocation = Rectangle.Empty;
        private void ChangeWindowState(FormWindowState p_NewState)
        {
            this.WindowState = FormWindowState.Normal;
            switch (p_NewState)
            {
                case FormWindowState.Maximized:
                    // if in normal mode we remind window size and location
                    if (m_WindowState == FormWindowState.Normal)
                    {
                        m_FormSizeAndLocation.Location = this.Location;
                        m_FormSizeAndLocation.Size = this.Size;
                    }
                    // make our form to be borderless in Maximized mode
                    this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
                    // calculate the window dimensions manually to prevent overlap the taskbar
                    this.Size = SystemInformation.WorkingArea.Size;
                    this.Location = SystemInformation.WorkingArea.Location;
                    break;
                case FormWindowState.Minimized:
                    this.WindowState = FormWindowState.Minimized;
                    break;
                case FormWindowState.Normal:
                    // make our form Sizeable by code
                    this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Sizable;
                    // Return to previous state values for window ocation & size
                    this.Location = m_FormSizeAndLocation.Location;
                    this.Size = m_FormSizeAndLocation.Size;
                    break;
            }
            // to remind our last WindowState mode applied
            m_WindowState = p_NewState;
        }

        #endregion

        private void Close_Click(object sender, EventArgs e)
        {
            ExitApplication();
        }
        #endregion

        /// <summary>
        /// 重置矩阵
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button2_Click(object sender, EventArgs e)
        {
            //MatrixHelper.GetInstance().ResetMatrix();
            this.WindowState = FormWindowState.Minimized;
        }
    }
}
