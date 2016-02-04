using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CentralBusiness
{
    public interface IMatrixSender
    {
        void Send(string cmd);
    }
}
