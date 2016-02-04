using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;

namespace CentralBusiness
{
    public class MatrixHelper
    {
        private static MatrixHelper m_instance;
        private IMatrixSender m_matrixSender;
        public static MatrixHelper GetInstance()
        {
            if (m_instance == null)
            {
                m_instance = new MatrixHelper();
            }
            return m_instance;
        }

        private MatrixHelper()
        {
            
        }

        /// <summary>
        /// 矩阵信号切换
        /// </summary>
        /// <param name="sourceInputID">源口</param>
        /// <param name="targetInputID">目标口</param>
        public void SwitchSignal(string sourceInputID, string targetInputID)
        {
            try
            {
                if (m_matrixSender == null)
                {
                    return;
                }
                var tInput = Convert.ToString(int.Parse(sourceInputID), 16);
                var tOutput = Convert.ToString(int.Parse(targetInputID), 16);

                string cmd = string.Format("FF 01 05 {0} {1} AA", tInput, tOutput);
                m_matrixSender.Send(cmd);
                Helpers.LogHelper.GetInstance().Append(string.Format("切换矩阵信号：{0} 到 {1}", sourceInputID, targetInputID));
                Thread.Sleep(50);
            }
            catch (Exception e)
            {
                Helpers.LogHelper.GetInstance().Append(string.Format("切换矩阵信号错误：{0}", e.Message));
            }
        }

        public void InsertSender(IMatrixSender sender)
        {
            m_matrixSender = sender;
        }

        public void ResetMatrix()
        {
            string cmd = "FF 01 03 00 00 AA";
            m_matrixSender.Send(cmd);
        }
    }  
}
