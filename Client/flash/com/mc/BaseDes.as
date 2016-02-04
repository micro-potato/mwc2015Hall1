package com.mc 
{
	import com.BaseMovie;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author LY
	 */
	public class BaseDes extends BaseMovie
	{
		public const DesLoaded:String = "DesLoaded";
		
		public function BaseDes() 
		{

		}
		
		protected var itemsDic:Dictionary;
		public function set ItemsDic(value:Dictionary)
		{
			itemsDic = value;
		}
		
		public function get ItemsDic():Dictionary
		{
			return itemsDic;
		}
		
		override protected function Init():void 
		{
			super.Init();
		}
		
	}

}