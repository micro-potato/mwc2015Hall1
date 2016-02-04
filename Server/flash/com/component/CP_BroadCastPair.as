package com.component 
{
	import com.customEvent.ScreenPairEvent;
	import com.EventMaster;
	/**
	 * ...
	 * @author LY
	 */
	public class CP_BroadCastPair extends BaseScreenPair
	{
		
		public function CP_BroadCastPair() 
		{
			
		}
		
		override protected function OnPairClicked():void 
		{
			super.OnPairClicked();
			var event:ScreenPairEvent = new ScreenPairEvent(ScreenPairEvent.BroadPairClicked);
			event.PairInfo = this.info;
			EventMaster.getInstance().dispatchEvent(event);
		}
		
	}

}