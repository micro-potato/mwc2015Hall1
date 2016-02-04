package com.component {
	
	import com.BaseMovie;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	public class DoubleScreenDesPanel extends DesConfigPanel {
		
		
		public function DoubleScreenDesPanel() {
			// constructor code
		}
		
		override protected function Init():void 
		{
			initX= 5;
			InitY = 9;
			currentY=9;
			offsetY = 20;
			panelX = 13;
			panelY = 11;
			super.Init();
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
		}
	}
	
}
