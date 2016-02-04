using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace FlashContainerTest
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        FlashHelper flashHelper;
        private void Form1_Load(object sender, EventArgs e)
        {
            //flashHelper=new FlashHelper(@"F:\Project\2014巴展品牌Hall1多媒体导播系统\Client\flash\VideoDes.swf",this.axShockwaveFlash1);
            flashHelper = new FlashHelper(@"F:\Project\2014巴展品牌Hall1多媒体导播系统\Client\Player\Player\bin\Debug\VideoDes.swf", this.axShockwaveFlash1);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            flashHelper.SendtoFlash(textBox1.Text, textBox2.Text);
        }
    }
}
