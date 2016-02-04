package com.component {
	
	import com.BaseMovie;
	import com.Business.GroupCalc;
	import com.Business.ScreenConnectionState;
	import com.Business.ScreenPairInfo;
	import com.customEvent.EditGroupEvent;
	import com.customEvent.ScreenPairEvent;
	import com.EventMaster;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	public class GroupSelectPannel extends BaseMovie {
		
		var groupNo:uint;
		var m_pairCount = 9;
		var m_activeInfo:ScreenPairInfo;
		
		public function get GroupNo():uint
		{
			return groupNo;
		}
		public function GroupSelectPannel() {
			//constructor code
		}
		
		override protected function Init():void 
		{
			super.Init();
			InitConnection();
			InitPairClick();
			ResetScreenBtns();
		}
		
		function InitConnection():void 
		{
			for (var i:int = 0; i < ScreenConnectionState.DisconnectedPairNos.length; i++) 
			{
				var pairNo = ScreenConnectionState.DisconnectedPairNos[i];
				(this["p_" +pairNo] as BaseScreenPair).CancelConnection();
			}
		}
		
		function InitPairClick():void 
		{
			for (var i:int = 1; i <=m_pairCount ; i++) 
			{
				var pair:CP_ConfigPair = this["p_" + i.toString()];
				pair.addEventListener(ScreenPairEvent.SingleSelect, OnPairSelected);
			}
		}
		
		function RemovePairClick():void 
		{
			for (var i:int = 1; i <=m_pairCount ; i++) 
			{
				var pair:CP_ConfigPair = this["p_" + i.toString()];
				pair.removeEventListener(ScreenPairEvent.SingleSelect, OnPairSelected);
			}
		}
		
		function OnPairSelected(e:ScreenPairEvent):void 
		{
			var selectedGroupID = GroupCalc.GroupNo(this, e.PairInfo);
			//if (m_activeInfo)
			//{
				//trace("groupID:" + m_activeInfo.GroupNo + "	" + selectedGroupID);
			//}
			if (m_activeInfo&&(m_activeInfo.GroupNo == selectedGroupID))//Select active group
			{
				return;
			}
			m_activeInfo = e.PairInfo;
			UpdateScreenBtn();
			UpdateGroupNo();
			BeginEditGroup();
		}
		
		function UpdateScreenBtn():void 
		{
			ResetScreenBtns();
			if (m_activeInfo.HasConnection)//2屏1组
			{
				this["s" + m_activeInfo.LeftScreenNo].gotoAndStop(2);
				this["s" + m_activeInfo.RightScreenNo].gotoAndStop(2);
			}
			else//2屏2组
			{
				if (m_activeInfo.SelectedPart == m_activeInfo.Left)//选择左屏
				{
					this["s" + m_activeInfo.LeftScreenNo].gotoAndStop(2);
				}
				else//选择右屏
				{
					this["s" + m_activeInfo.RightScreenNo].gotoAndStop(2);
				}
			}
		}
		
		function ResetScreenBtns():void 
		{
			for (var i:int = 1; i <=m_pairCount*2 ; i++) //18屏
			{
				this["s"+i.toString()].gotoAndStop(1);
			}
		}
		
		private function UpdateGroupNo()
		{
			m_activeInfo.GroupNo=GroupCalc.GroupNo(this, m_activeInfo);
		}
		
		function  BeginEditGroup():void 
		{
			var event:EditGroupEvent = new EditGroupEvent();
			if (m_activeInfo == null)
			{
				event.GroupNo = 0;
				EventMaster.getInstance().dispatchEvent(event);
			}
			else
			{
				event.GroupNo = m_activeInfo.GroupNo;
				event.configType = m_activeInfo.HasConnection?event.Double:event.Single;
				EventMaster.getInstance().dispatchEvent(event);
				trace("EditGroup:" + event.GroupNo+"	"+event.configType);
			}
		}
		
		function OnGroupEdit(e:MouseEvent):void 
		{
			var event:EditGroupEvent = new EditGroupEvent();
			if (m_activeInfo == null)
			{
				event.GroupNo = 0;
				EventMaster.getInstance().dispatchEvent(event);
			}
			else
			{
				event.GroupNo = m_activeInfo.GroupNo;
				event.configType = m_activeInfo.HasConnection?event.Double:event.Single;
				EventMaster.getInstance().dispatchEvent(event);
			}
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
		}
	}
	
}
