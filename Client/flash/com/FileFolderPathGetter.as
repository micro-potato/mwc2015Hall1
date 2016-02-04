package com 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author LY
	 */
	public class FileFolderPathGetter extends EventDispatcher
	{
		public const PathLoaded:String = "PathLoaded";
		var isAvailable:Boolean = false;
	    var fileFolder:String;
		static var instance:FileFolderPathGetter;
		var xmlHelper:XMLHelper;
		public function FileFolderPathGetter() 
		{
			xmlHelper = new XMLHelper("config.xml",true);
			xmlHelper.addEventListener(xmlHelper.XMLLoadedEvent, ConfigLoaded);
		}
		
		function ConfigLoaded(e:Event):void 
		{
			fileFolder = xmlHelper.GetNodeValue(0, "LocalFolder");
			trace(fileFolder);
			instance.dispatchEvent(new Event(instance.PathLoaded));
		}
		
		public function get FileFolder():String
		{
			return fileFolder;
		}
		
		public static function GetInstance():FileFolderPathGetter
		{
			if (instance == null)
			{
				instance = new FileFolderPathGetter();
			}
			return instance;
		}
	}
}