package com.customEvent 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author LY
	 */
	public class ExternalCmdEvent extends Event
	{
		public var arg:String;
		public static const RespondPlayList = "respondPlayList";
		public function ExternalCmdEvent(eventType:String) 
		{
			super(eventType, false, false);
		}
	}

}