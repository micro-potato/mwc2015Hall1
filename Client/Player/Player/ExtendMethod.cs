using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ClientDLL;

namespace Player
{
    public static class ExtendMethod
    {
        public static void Send(this AsyncClient client,string type,string msg)
        {
            client.Send(type + ":" + msg);
        }
    }
}
