using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CentralBusiness
{
    public class LogHelper
    {
        private static LogHelper instance;
        private ILog log;
        private LogHelper()
        {

        }

        public static LogHelper GetInstance()
        {
            if (instance == null)
            {
                instance = new LogHelper();
            }
            return instance;
        }

        public void RegisterLog(ILog ilog)
        {
            log = ilog;
        }

        public void Append(string message)
        {
            if (log != null)
            {
                log.AppendLog(message);
            }
        }
    }
}
