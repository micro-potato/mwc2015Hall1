package com.mc {
	
	import com.ResourceLoader;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	import com.FileFolderPathGetter;
	
	
	public class Despic extends BaseDes {
				
		var loader:ResourceLoader;
		public function Des2() {
			// constructor code
		}
		
		override protected function Init():void 
		{
			//trace("pic init");
			if (loader != null)
			{
				this.removeChild(loader);
			}
			//trace(this.itemsDic["pic1"]);
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
			//trace("pic path:" + FileFolderPathGetter.GetInstance().FileFolder);
			//for (var name:String in itemsDic) 
			//{
				//trace(name+"	" + itemsDic[name]);
			//}
			//trace("itemsDic:"+itemsDic);
			loader = new ResourceLoader(FileFolderPathGetter.GetInstance().FileFolder +"\\"+ this.itemsDic["fileName"]);
			loader.addEventListener(loader.Loaded, OnLoaded);
		}
		
		function OnLoaded(e:Event):void 
		{
			e.target.removeEventListener((e.target as ResourceLoader).Loaded, OnLoaded);
			var pic:Bitmap = (e.target as ResourceLoader).Content as Bitmap;
			pic.smoothing = true;
			this.addChild(pic);
			pic.width = 1920;
			pic.height = 1080;
			//this.addChild((e.target as ResourceLoader).Content);
			this.dispatchEvent(new Event(this.DesLoaded));
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
			loader.removeEventListener(loader.Loaded, OnLoaded);
		}
	}
	
}
