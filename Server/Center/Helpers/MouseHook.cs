using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.Reflection;
using System.Drawing;
using System.Diagnostics;

namespace Helpers
{
    public class MouseHook
    {
       #region Fields

        private int hMouseHook = 0;

        //全局钩子常量
        private const int WH_MOUSE_LL = 14;

        //声明消息的常量,鼠标按下和释放
        private const int WM_RBUTTONDOWN = 0x204;
        private const int WM_RBUTTONUP = 0x205;
        //保存任务栏的矩形区域
        private Rectangle taskBarRect;
        private Rectangle newTaskBarRect;

        //定义委托
        public delegate int HookProc(int nCode, int wParam, IntPtr lParam);
        private HookProc MouseHookProcedure;

        #endregion

        #region 声明Api函数，需要引入空间(System.Runtime.InteropServices)

        //寻找符合条件的窗口
        [DllImport("user32.dll", EntryPoint = "FindWindow")]
        public static extern int FindWindow(string lpClassName,string lpWindowName);

        //获取窗口的矩形区域
        [DllImport("user32.dll", EntryPoint = "GetWindowRect")]
        public static extern int GetWindowRect(int hwnd,ref Rectangle lpRect);

        //安装钩子
        [DllImport("user32.dll")]
        public static extern int SetWindowsHookEx(int idHook,HookProc lpfn,IntPtr hInstance,int threadId);

        //卸载钩子
        [DllImport("user32.dll", EntryPoint = "UnhookWindowsHookEx")]
        public static extern bool UnhookWindowsHookEx(int hHook);

        //调用下一个钩子
        [DllImport("user32.dll")]
        public static extern int CallNextHookEx(int idHook,int nCode,int wParam,IntPtr lParam);

        //获取当前线程的标识符
        [DllImport("kernel32.dll")]
        public static extern int GetCurrentThreadId();

        //获取一个应用程序或动态链接库的模块句柄
        [DllImport("kernel32.dll")]
        public static extern IntPtr GetModuleHandle(string name);

        //鼠标结构，保存了鼠标的信息
        [StructLayout(LayoutKind.Sequential)]
        public struct MOUSEHOOKSTRUCT
        {
            public Point pt;
            public int hwnd;
            public int wHitTestCode;
            public int dwExtraInfo;
        }

        #endregion

        private LowLevelMouseProc _proc;
        private delegate IntPtr LowLevelMouseProc(int nCode, IntPtr wParam, IntPtr lParam);
        /// <summary>
        /// 安装钩子
        /// </summary>
        public void StartHook()
        {
            //added
            MouseHookProcedure = new HookProc(MouseHookProc);
            //added end
            if (hMouseHook == 0)
            {
                hMouseHook = SetWindowsHookEx(WH_MOUSE_LL, MouseHookProcedure, GetModuleHandle(Process.GetCurrentProcess().MainModule.ModuleName), 0);

                if (hMouseHook == 0)
                {//如果设置钩子失败.

                    this.StopHook();
                    Console.WriteLine("Set windows hook failed!");
                }
            }
        }

        /// <summary>
        /// 卸载钩子
        /// </summary>
        private void StopHook()
        {
            bool stop = true;

            if (hMouseHook != 0)
            {
                stop = UnhookWindowsHookEx(hMouseHook);
                hMouseHook = 0;

                if (!stop)
                {//卸载钩子失败

                    Debug.WriteLine("Unhook failed!");
                }
            }
        }

        private int MouseHookProc(int nCode, int wParam, IntPtr lParam)
        {
            if (nCode >= 0)
            {
                //把参数lParam在内存中指向的数据转换为MOUSEHOOKSTRUCT结构
                MOUSEHOOKSTRUCT mouse = (MOUSEHOOKSTRUCT)Marshal.PtrToStructure(lParam, typeof(MOUSEHOOKSTRUCT));//鼠标
                
                //这句为了看鼠标的位置
               Debug.WriteLine("MousePosition:" + mouse.pt.ToString());

                if (wParam == WM_RBUTTONDOWN || wParam == WM_RBUTTONUP)
                {
                    if (wParam == WM_RBUTTONUP)
                    {
                        if (RightMouseUpEvent != null)
                        {
                            RightMouseUpEvent();
                        }
                    }
                     return 1;
                }
            }
            return CallNextHookEx(hMouseHook, nCode, wParam, lParam);
        }

        #region Events
        public delegate void RightMouseHandle();
        public event RightMouseHandle RightMouseUpEvent;

        #endregion
    }
}
