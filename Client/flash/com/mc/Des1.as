package com.mc {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	
	public class Des1 extends BaseDes {
		
		
		public function Des1() {
			 //constructor code
		}
		
		override protected function Init():void 
		{
			super.Init();
			this["txt"].text = this.itemsDic["text1"];
			this.dispatchEvent(new Event(this.DesLoaded));
		}
	}
	
}
