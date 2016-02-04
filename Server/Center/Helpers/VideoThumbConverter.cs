using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Helpers
{
    public class VideoThumbConverter
    {
        public static void CreateThumbnail(string videoPath, string videoThrumbNailPath)
        {
            new NReco.VideoConverter.FFMpegConverter().GetVideoThumbnail(videoPath, videoThrumbNailPath);//生成视频缩略图
        }
    }
}
