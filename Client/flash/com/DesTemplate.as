package com 
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author LY
	 */
	public class DesTemplate 
	{
		
		public function DesTemplate() 
		{
			
		}
		
		private var desType:String;
		public function get DesType():String
		{
			return items["type"];
		}
		
		public function set DesType(value:String):void
		{
			desType = value;
		}
		
		private var duraion:Number;
		public function get Duraion():Number
		{
			return items["last"];
		}
		
		public function set Duraion(value:Number):void
		{
			duraion = value;
		}
		
		private var items:Dictionary;
		public function set Items(value:Dictionary):void
		{
			items = value;
		}
		public function get Items():Dictionary
		{
			return items;
		}
	}
}