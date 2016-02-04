package com.component {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	public class SingleScreenDesConfigPanel extends DesConfigPanel {
		
		
		public function SingleScreenDesConfigPanel() {
			// constructor code
		}
		
		override protected function Init():void 
		{
			initX= 280;
			InitY = 10;
			currentY=10;
			offsetY = 20;
			panelX = 37;
			panelY = 83;
			super.Init();
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
		}
	}
	
}
