package com.component 
{
	import com.BaseMovie;
	/**
	 * ...
	 * @author LY
	 */
	public class BaseConfigPanel extends BaseMovie
	{
		protected var groupID:uint;
		
		protected function UpdateUI(playListText:String):void 
		{
			
		}
		
		public function set GroupID(value:uint):void
		{
			groupID = value;
		}
		
		public function get PlayListText():String
		{
			return null;
		}
		
		public function set PlayListText(value:String):void
		{
			UpdateUI(value);
		}
		
		public function BaseGroupConfig() 
		{
			
		}
		
	}

}