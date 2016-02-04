using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;

namespace Player
{
    static class Program
    {
        /// <summary>
        /// 应用程序的主入口点。
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            MConfig mConfig = new ConfigDeal().GetMessage();
            if (mConfig.IsManageFile == 1)
            {
                EnableFileWatcher(mConfig.LocalFolder,mConfig.ServerFolder);
            }
            PlayForm playForm;
            if (mConfig.IsDouble==1)
            {
                playForm = new DoubleScreenForm();
                playForm.MConfig = mConfig;
                Application.Run(playForm);
            }
            else
            {
                playForm = new SingleScreenForm();
                playForm.MConfig = mConfig;
                Application.Run(playForm);
            }
        }

        /// <summary>
        /// 检测服务端的文件
        /// </summary>
        private static void EnableFileWatcher(string localFolder,string serverFolder)
        {
            FileWatcher fileWatcher = new FileWatcher(localFolder, serverFolder);
            fileWatcher.StartWatch();
        }
    }
}
