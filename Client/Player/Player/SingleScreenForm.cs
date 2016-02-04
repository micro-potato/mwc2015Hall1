using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Player
{
    public partial class SingleScreenForm : PlayForm
    {
        private FlashHelper flashHelper;
        private CastPlan m_plan;

        public SingleScreenForm()
        {
            InitializeComponent();
        }

        private void SingleScreenForm_Load(object sender, EventArgs e)
        {
            this.flashHelper = new FlashHelper(this.flashPath, this.axShockwaveFlash1);
            this.Invoke(new VoidDelegate(RunSavedPlayList));
        }

        protected override void RunPlayList(string playList)
        {
            m_plan = new CastPlan(playList);
            this.flashHelper.SendtoFlash("ChangeDes", "0");
        }

        /// <summary>
        /// test
        /// </summary>
        private void button1_Click(object sender, EventArgs e)
        {
            this.Invoke(new VoidDelegate(SendGroupIDtoServer));
        }
    }
}
