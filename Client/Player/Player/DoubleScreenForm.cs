using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using ClientDLL;
using Helpers;
using System.Threading;
using WMPLib;
using System.IO;

namespace Player
{
    public partial class DoubleScreenForm : PlayForm
    {
        string exePath = Application.StartupPath;
       
        private CastPlan m_plan;
        //helper
        FlashHelper flashHelper;

        //检测是否有视频播放完毕
        private System.Timers.Timer videoCheckTimer;

        bool isVideoFinish = false;
        string startVideoName;
        public DoubleScreenForm()
        {
            InitializeComponent();
            InitVideoTimer();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            try
            {
                this.flashHelper = new FlashHelper(this.flashPath, this.FlashShell);
                this.VideoPlayer.uiMode = "none";
                this.VideoPlayer.stretchToFit = true;
                this.VideoPlayer.PlayStateChange += new AxWMPLib._WMPOCXEvents_PlayStateChangeEventHandler(VideoPlayer_PlayStateChange);
                this.Invoke(new VoidDelegate(RunSavedPlayList));
            }
            catch (Exception ex)
            {
                Console.WriteLine("Load err:" + ex.Message);
            }
        }

        protected override void RunPlayList(string playList)
        {
            m_plan = new CastPlan(playList);
            PlayVideos(m_plan.PlayList);
        }

        private void InitVideoTimer()
        {
            videoCheckTimer = new System.Timers.Timer();
            videoCheckTimer.Interval = 3000;
            videoCheckTimer.Elapsed += new System.Timers.ElapsedEventHandler(VideoCheckTimer_Elapsed);
        }

        private string ConfigPath()
        {
            return exePath + "\\config.xml";
        }

        private string PlayListPath()
        {
            return exePath + "\\playlist.xml";
        }

        #region Init
        private void EnableVideoCheck()
        {
            if (videoCheckTimer != null)
            {
                videoCheckTimer.Start();
            }
        }

        private void DisableVideoCheck()
        {
            if (videoCheckTimer != null)
            {
                videoCheckTimer.Stop();
            }
        }
        #endregion

        #region 根据列表播放
        int listCount;
        int currentPlayIndex;

        /// <summary>
        /// 从服务器获得播放列表，重置所有播放内容
        /// </summary>
        /// <param name="xmlPlayList"></param>
        private void ResetPlayContents(string xmlPlayList)
        {
            StopPlay();
            m_plan.UpdatePlayList(xmlPlayList);//更新播放列表
            PlayVideos(m_plan.PlayList);//根据播放列表播放
        }

        /// <summary>
        /// 根据播放列表重新播放
        /// </summary>
        /// <param name="playList"></param>
        private void PlayVideos(List<AssetPair> playList)
        {
            try
            {
                if (playList.Count == 1 && playList[0].VideoName=="0")//no video,play des
                {
                    this.flashHelper.SendtoFlash("ChangeDes", "0");
                    return;
                }
                listCount = playList.Count;
                currentPlayIndex = 0;
                if (listCount > 0)
                {
                    EnableVideoCheck();
                    PlayVideobyIndex();
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("video play error:" + e.Message);
            }
        }

        private void PlayVideobyIndex()
        {
            try
            {
                string videoName = m_plan.PlayList[currentPlayIndex].VideoName;
                this.VideoPlayer.URL = null;
                string videoPath = this.m_FileFolder + "\\" + videoName;
                if (File.Exists(videoPath))
                {
                    this.VideoPlayer.URL = videoPath;
                    Console.WriteLine("播放此路径视频：" + videoPath);
                    isVideoFinish = false;
                    this.flashHelper.SendtoFlash("ChangeDes", videoName);
                }
                else
                {
                    isVideoFinish = true;
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        void VideoPlayer_PlayStateChange(object sender, AxWMPLib._WMPOCXEvents_PlayStateChangeEvent e)
        {
            if (e.newState == 8)
            {
                isVideoFinish = true;
            }
        }

        void PlayNextVideo()
        {
            if (currentPlayIndex < listCount - 1)
            {
                currentPlayIndex++;
            }
            else
            {
                currentPlayIndex = 0;
            }
            PlayVideobyIndex();
        }

        /// <summary>
        /// 检测视频是否播放完，完则切换到下一条
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void VideoCheckTimer_Elapsed(object sender, EventArgs e)
        {
            if (isVideoFinish)
            {
                PlayNextVideo();
            }
        }

        /// <summary>
        /// 停止当前节目单内容的播放
        /// </summary>
        private void StopPlay()
        {
            try
            {
                VideoPlayer.URL = null;
                DisableVideoCheck();
                flashHelper.SendtoFlash("StopPlay", "stopPlay");
            }
            catch(Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        private void SetStartVideoName(string msg)
        {
            startVideoName = msg;
        }
        #endregion
    }
}
