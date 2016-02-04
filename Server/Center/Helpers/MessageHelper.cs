using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Helpers
{
    public class MessageHelper
    {
        static MessageHelper helper;
        private MessageHelper()
        {

        }

        static public MessageHelper GetInstance()
        {
            if (helper == null)
            {
                helper = new MessageHelper();
            }
            return helper;
        }

        private IMessageShower shower;
        public void InsertIMessageShower(IMessageShower iMessageShower)
        {
            shower = iMessageShower;
        }
        public void ShowMessage(string msg)
        {
            if (shower != null)
            {
                shower.ShowMessage(msg);
            }
        }
    }
}
