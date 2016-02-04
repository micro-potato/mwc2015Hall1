package com.component 
{
	import com.customEvent.ScreenPairEvent;
	import com.EventMaster;
	/**
	 * ...
	 * @author LY
	 */
	public class CP_ConfigPair extends BaseScreenPair
	{
		
		public function CP_ConfigPair() 
		{
			
		}
		
		override protected function OnPairClicked():void 
		{
			super.OnPairClicked();
			var event:ScreenPairEvent = new ScreenPairEvent(ScreenPairEvent.SingleSelect);
			event.PairInfo = this.info;
			this.dispatchEvent(event);
		}
		
	}

}