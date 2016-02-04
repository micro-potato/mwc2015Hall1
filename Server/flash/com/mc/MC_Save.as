package com.mc {
	
	import com.BaseMovie;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	public class MC_Save extends BaseMovie {
		
		public const SaveConfig:String = "saveConfig";
		public const CancelConfig:String = "cancelConfig";
		public function MC_Save() {
			// constructor code
		}
		
		override protected function Init():void 
		{
			super.Init();
			this["b_ok"].buttonMode = true;
			this["b_ok"].addEventListener(MouseEvent.CLICK, OnSave);
			this["b_cancel"].buttonMode = true;
			this["b_cancel"].addEventListener(MouseEvent.CLICK, OnCancel);
		}
		
		private function OnSave(e:Event):void 
		{
			this.dispatchEvent(new Event(SaveConfig));
		}
		
		private function OnCancel(e:Event):void 
		{
			this.dispatchEvent(new Event(CancelConfig));
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
			this["b_ok"].removeEventListener(MouseEvent.CLICK, OnSave);
			this["b_cancel"].removeEventListener(MouseEvent.CLICK, OnCancel);
		}
	}
	
}
