using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Helpers;

namespace Player
{
    public partial class TestForm : Form
    {
        public TestForm()
        {
            InitializeComponent(); 
        }

        private void TestForm_Load(object sender, EventArgs e)
        {
            //this.Location = new Point(0, 0);
            this.Left = 0;
            this.Top = 0;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            GetPlayListbyConfig();
        }

        public void GetPlayListbyConfig()
        {
            CastPlan cp = new CastPlan(Application.StartupPath + "\\playlist.xml");
        }

        private VideoDesType GetDesTypebyNo(string typeNo)
        {
            switch (typeNo)
            {
                case "1":
                    return VideoDesType.Video;
                case "2":
                    return VideoDesType.Pic1;
                default:
                    throw new Exception("错误的格式");
            }
        }
    }
}
