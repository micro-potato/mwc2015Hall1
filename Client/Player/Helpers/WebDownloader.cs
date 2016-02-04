using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;

namespace Helpers
{
    public class WebDownloader
    {
        public WebDownloader(string fileurl)
        {
            WebClient wc = new WebClient();
            Uri uri = new Uri(fileurl);
            wc.DownloadFileAsync(uri, "test.jpg");
            wc.DownloadFileCompleted += new System.ComponentModel.AsyncCompletedEventHandler(wc_DownloadFileCompleted);
        }

        void wc_DownloadFileCompleted(object sender, System.ComponentModel.AsyncCompletedEventArgs e)
        {
            
        }
    }
}
