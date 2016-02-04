package com 
{
	import flash.external.ExternalInterface;
	/**
	 * ...
	 * @author LY
	 */
	public class InteractHelper 
	{
		public static var instance:InteractHelper;
		public function InteractHelper() 
		{
			
		}
		
		public static function GetInstance():InteractHelper
		{
			if (instance == null)
			{
				instance = new InteractHelper();
			}
			return instance;
		}
		
		public function SendOut(fun:String, arg:String)
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.call(fun, arg);
			}
		}
	}

}