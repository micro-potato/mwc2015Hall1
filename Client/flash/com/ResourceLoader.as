package com
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	public class ResourceLoader extends MovieClip
	{
		public  const Loaded = "Loaded";
		private var resourcePath:String = "";
		public function get ResourcePath():String
		{
			return resourcePath;
		}
		
		public function set ResourcePath(value:String)
		{
			resourcePath = value;
		}

		private var myLoader:Loader;
		
		public function get Content():DisplayObject
		{
			return myLoader.content as DisplayObject;
		}
		
		public function set MyLoader(value:Loader)
		{
			myLoader = value;
		}
		
		public function ResourceLoader(path:String)
		{
			resourcePath = path;
			Load();
		}
		
		public function Load()
		{
			myLoader = new Loader();
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			var fileRequest:URLRequest = new URLRequest(resourcePath);
			myLoader.load(fileRequest);
		}
		
		private function onLoaderComplete(e:Event):void
		{
			myLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete);
		    this.dispatchEvent(new Event(this.Loaded));
			//this.addChild(myLoader.content);
		}
	}	
}