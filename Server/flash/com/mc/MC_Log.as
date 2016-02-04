package com.mc {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	
	public class MC_Log extends MovieClip {
		
		
		public function MC_Log() {
			// constructor code
		}
		
		public function AppendLog(log:String)
		{
			var txt:TextField = this["txt_log"];
			txt.appendText(log + "\r\n");
		}
	}
	
}
