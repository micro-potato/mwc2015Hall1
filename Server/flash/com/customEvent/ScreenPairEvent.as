package com.customEvent 
{
	import com.Business.ScreenPairInfo;
	import flash.events.Event;
	/**
	 * ...
	 * @author LY
	 */
	public class ScreenPairEvent extends Event
	{
		public static const SingleSelect:String = "singleSelect";
		public static const BroadPairClicked:String = "broadPairClicked";
		public static const PairUpdated:String = "pairUpdated";
		public var PairInfo:ScreenPairInfo;
		
		public function ScreenPairEvent(eventType:String) 
		{
			super(eventType, false, false);
		}
	}

}