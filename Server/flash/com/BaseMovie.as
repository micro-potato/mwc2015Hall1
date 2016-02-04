package com  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.LocalConnection;
	/**
	 * 所有需要添加到舞台的MovieClip基类
	 * @author ...
	 */
	public class BaseMovie extends MovieClip 
	{
		public function BaseMovie() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, added_to_stage);
		}
		
		private function added_to_stage(e:Event):void 
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, added_to_stage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removed_from_stage);
			Init();
		}
		
		protected function Init():void 
		{
			
		}
		
		private function CollectGarbage()
		{
			try{
				new LocalConnection().connect("MoonSpirit");
				new LocalConnection().connect("MoonSpirit");
			}catch(error : Error){

			}
		}
		
		protected function removed_from_stage(e:Event):void 
		{	
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removed_from_stage);
			this.addEventListener(Event.ADDED_TO_STAGE, added_to_stage);
			//CollectGarbage();
		}
	}

}