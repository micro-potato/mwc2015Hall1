package com.mc {
	
	import com.MoviePlayer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import com.FileFolderPathGetter;
	
	public class Desvideo extends BaseDes {
		
		var player:MoviePlayer;
		public function Desvideo() {
			// constructor code
		}
		
		override protected function Init():void 
		{
			super.Init();
			//trace(this.itemsDic["desvideo"]);
			if (FileFolderPathGetter.GetInstance().FileFolder != null)
			{
				LoadFile();
			}
			else
			{
				FileFolderPathGetter.GetInstance().addEventListener(FileFolderPathGetter.GetInstance().PathLoaded, OnPathLoaded);
			}
		}
		
		function OnPathLoaded(e:Event):void
		{
			LoadFile();
		}
		
		function LoadFile():void 
		{
			//for (var item:String in itemsDic) 
			//{
				//trace(item+"	"+itemsDic[item]);
			//}
			//trace("FilePath:"+FileFolderPathGetter.GetInstance().FileFolder+"\\"+ this.itemsDic["video"]);
			player = new MoviePlayer(FileFolderPathGetter.GetInstance().FileFolder + "\\" + this.itemsDic["fileName"], null);
			player.addEventListener(Event.COMPLETE, OnVideoComplete);
			this.addChild(player);
			this.dispatchEvent(new Event(this.DesLoaded));
		}
		
		function OnVideoComplete(e:Event):void 
		{
			player.removeEventListener(Event.COMPLETE, OnVideoComplete);
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
		}
	}
	
}
