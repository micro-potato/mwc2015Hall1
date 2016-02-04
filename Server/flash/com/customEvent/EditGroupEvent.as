package com.customEvent 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author LY
	 */
	public class EditGroupEvent extends Event
	{
		public static const EditGroup:String = "editGroup";
		public const Single:String = "Single";
		public const Double:String = "Double";
		
		public var GroupNo:uint;
		public var configType:String;
		
		public function EditGroupEvent() 
		{
			super(EditGroup, false, false);
		}
		
	}

}