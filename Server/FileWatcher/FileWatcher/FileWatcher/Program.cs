using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Threading;
using System.Xml;

namespace FileWatcher
{
    class Program
    {
        static string configPath = AppDomain.CurrentDomain.BaseDirectory + "config.xml";
        static private List<string> objFolders=new List<string>();
        static private string m_watchedFolder;
        static FileSystemWatcher fsw;
        static void Main(string[] args)
        {
            PrePare();
            fsw = new FileSystemWatcher();
            fsw.Path = m_watchedFolder;
            fsw.Created += new FileSystemEventHandler(fsw_Created);
            fsw.EnableRaisingEvents = true;
            Console.ReadKey();
        }

        /// <summary>
        /// 配置文件传输相关的路径
        /// </summary>
        private static void PrePare()
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(configPath);
            m_watchedFolder = doc.SelectSingleNode("//localFolder").InnerText;
            objFolders = new List<string>();
            for (int i = 1; i <= 3; i++)
            {
                string folder = doc.SelectSingleNode("//pc"+i.ToString()).InnerText;
                if (!string.IsNullOrEmpty(folder.Trim()))
                {
                    objFolders.Add(folder);
                }
            }
        }

        static void fsw_Created(object sender, FileSystemEventArgs e)
        {
            string sFullName = e.FullPath;
            string dFullName;
            foreach (var p in objFolders)
            {
                dFullName = p + "\\" + e.Name;
                try
                {
                    while (!IsFileReady(sFullName))
                    {
                        if (!File.Exists(sFullName))
                        {
                            return;
                        }
                        Thread.Sleep(100);
                    }
                    if (!File.Exists(dFullName))
                    {
                        File.Copy(sFullName, dFullName);
                        Console.WriteLine(string.Format("传输文件 {0} 到 {1}\r\n", sFullName, dFullName));
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error:" + ex.Message);
                    continue;
                }
            }
        }

        private static bool IsFileReady(string filename)
        {
            FileInfo fi = new FileInfo(filename);
            FileStream fs = null;
            try
            {
                fs = fi.Open(FileMode.Open, FileAccess.ReadWrite,
           FileShare.None);
                return true;
            }

            catch (IOException)
            {
                return false;
            }

            finally
            {
                if (fs != null)
                    fs.Close();
            }
        }
    }
}
