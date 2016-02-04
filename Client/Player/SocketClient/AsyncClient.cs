using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;

namespace ClientDLL
{
    public class AsyncClient
    {
        private Socket socket;

        public AsyncClient()
        {
        }

        public void Connect(string ip, int port)
        {
            this.socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            IPEndPoint pEndPoint = new IPEndPoint(IPAddress.Parse(ip), port);
            this.socket.BeginConnect(pEndPoint, new AsyncCallback(this.ConnectCallback), this.socket);
        }

        private void ConnectCallback(IAsyncResult ar)
        {
            try
            {
                Socket asyncState = (Socket)ar.AsyncState;
                asyncState.EndConnect(ar);
                StateObject stateObject = new StateObject()
                {
                    workSocket = asyncState
                };
                asyncState.BeginReceive(stateObject.buffer, 0, 307200, SocketFlags.None, new AsyncCallback(this.ReceiveCallback), stateObject);
                if (this.onConnected != null)
                {
                    this.onConnected();
                }
            }
            catch
            {
                if (this.onDisConnect != null)
                {
                    this.onDisConnect();
                }
            }
        }

        public void Dispose()
        {
            this.socket.Close();
        }

        private void ReceiveCallback(IAsyncResult ar)
        {
            try
            {
                StateObject asyncState = (StateObject)ar.AsyncState;
                Socket socket = asyncState.workSocket;
                int num = socket.EndReceive(ar);
                if (num <= 0)
                {
                    if (this.onDisConnect != null)
                    {
                        this.onDisConnect();
                    }
                    return;
                }
                else
                {
                    byte[] numArray = new byte[num];
                    Array.ConstrainedCopy(asyncState.buffer, 0, numArray, 0, num);
                    if (this.onDataByteIn != null)
                    {
                        this.onDataByteIn(numArray);
                    }
                    socket.BeginReceive(asyncState.buffer, 0, 307200, SocketFlags.None, new AsyncCallback(this.ReceiveCallback), asyncState);
                }
            }
            catch
            {
                if (this.onDisConnect != null)
                {
                    this.onDisConnect();
                }
            }
        }

        public void Send(string data)
        {
            byte[] bytes = Encoding.GetEncoding("utf-8").GetBytes(data);
            this.socket.BeginSend(bytes, 0, (int)bytes.Length, SocketFlags.None, new AsyncCallback(this.SendCallback), this.socket);
        }

        private void SendCallback(IAsyncResult ar)
        {
            ((Socket)ar.AsyncState).EndSend(ar);
        }

        public event AsyncClient.Connected onConnected;

        public event AsyncClient.DataByteIn onDataByteIn;

        public event AsyncClient.DisConnect onDisConnect;

        public delegate void Connected();

        public delegate void DataByteIn(byte[] SocketData);

        public delegate void DisConnect();
    }
}