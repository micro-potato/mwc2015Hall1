using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CentralBusiness
{
    public class CommandCollection
    {
        //win to flash:
        public const string RespondDesFile = "respondDesFile";//返回选择的video资源文件：初始ID^文件名
        public const string RespondVideoFile = "respondVideoFile";//返回选择的des资源文件：初始ID^文件名
        public const string RespondPlayList = "respondPlayList";//返回播放列表：列表xml

        //flash to win
        public const string LoadTypeError = "loadTypeError"; //加载的列表不符合当前组
        public const string RequestPreView = "requestPreView"; //预览播放列表
    }
}
