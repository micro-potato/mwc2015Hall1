using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Threading;

namespace Player
{
    public class FileWatcher
    {
        private string targetFolder;
        private string sourceFolder;
        private FileSystemWatcher m_FileWatcher;

        public FileWatcher(string targetFolder, string sourceFolder)
        {
            // TODO: Complete member initialization
            this.targetFolder = targetFolder;
            this.sourceFolder = sourceFolder;
        }

        internal void StartWatch()
        {
            m_FileWatcher = new FileSystemWatcher();
            m_FileWatcher.Path =this.sourceFolder;
            m_FileWatcher.Created += new FileSystemEventHandler(FileWatcher_Created);
            m_FileWatcher.EnableRaisingEvents = true;
        }

        void FileWatcher_Created(object sender, FileSystemEventArgs e)
        {
            string sourceFilePath = e.FullPath;
            string targetFilePath;
            targetFilePath = targetFolder + "\\" + e.Name;
            try
            {
                while (!IsFileReady(sourceFilePath))
                {
                    if (!File.Exists(sourceFilePath))
                    {
                        return;
                    }
                    Thread.Sleep(100);
                }
                if (!File.Exists(targetFilePath))
                {
                    List<string> fileList = new List<string> {sourceFilePath,targetFilePath };
                    ThreadPool.QueueUserWorkItem(new WaitCallback(CopyFile), fileList);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error:" + ex.Message);
            }
        }

        private void CopyFile(object filePair)
        {
            try
            {
                List<string> fileList = filePair as List<string>;
                string sourceFilePath = fileList[0];
                string targetFilePath = fileList[1];
                File.Copy(sourceFilePath, targetFilePath);
                Console.WriteLine(string.Format("传输文件 {0} 到 {1}\r\n", sourceFilePath, targetFilePath));
            }
            catch(Exception e)
            {
                //Console.WriteLine(string.Format("传输文件 {0} 到 {1}\r\n", sourceFilePath, targetFilePath));
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
