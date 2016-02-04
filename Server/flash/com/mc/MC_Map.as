package com.mc {
	
	import com.BaseMovie;
	import com.Business.GroupCalc;
	import com.Business.ScreenConnectionState;
	import com.Business.ScreenPairInfo;
	import com.component.BaseScreenPair;
	import com.component.CP_BroadCastPair;
	import com.component.CP_ConfigPair;
	import com.customEvent.ScreenPairEvent;
	import com.EventMaster;
	import com.Main;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	public class MC_Map extends BaseMovie {
		
		private var m_GroupNo:uint;
		public function MC_Map() {
			// constructor code
		}
		
		override protected function Init():void 
		{
			super.Init();
			InitPairConnection();
			InitPairClick();
		}
		
		function InitPairConnection():void 
		{
			for (var i:int = 0; i < ScreenConnectionState.DisconnectedPairNos.length; i++) 
			{
				var pairNo = ScreenConnectionState.DisconnectedPairNos[i];
				(this["p_" +pairNo] as BaseScreenPair).CancelConnection();
			}
		}
		
		function InitPairClick():void 
		{
			for (var i:int = 1; i <=9 ; i++) 
			{
				var pair:CP_ConfigPair = this["p_" + i.toString()];
				pair.addEventListener(ScreenPairEvent.SingleSelect, OnPairSelected);
			}
		}
		
		function RemovePairClick():void 
		{
			for (var i:int = 1; i <=9 ; i++) 
			{
				var pair:CP_ConfigPair = this["p_" + i.toString()];
				pair.removeEventListener(ScreenPairEvent.SingleSelect, OnPairSelected);
			}
		}
		
		function OnPairSelected(e:ScreenPairEvent):void 
		{
			AcquireGroupNo(e.PairInfo);
			PreviewGroup();
		}
		
		function AcquireGroupNo(pairInfo:ScreenPairInfo):void 
		{
			m_GroupNo = GroupCalc.GroupNo(this, pairInfo);
		}
		
		//同步选中组到控制机2屏
		function PreviewGroup():void 
		{
			//trace("PreviewGroup:" + m_GroupNo);
			Main.Instace.SendMsgtoWin("syncGroup", m_GroupNo.toString());
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
			RemovePairClick();
		}
	}
	
}
