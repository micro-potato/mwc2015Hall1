package com.mc {
	
	import adobe.utils.CustomActions;
	import com.BaseMovie;
	import com.Business.GroupCalc;
	import com.Business.ScreenPairInfo;
	import com.component.BaseScreenPair;
	import com.customEvent.ScreenPairEvent;
	import com.EventMaster;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.Business.ScreenConnectionState;
	
	
	public class MC_BroadCastPanel extends BaseMovie {
		
		public const BroadcastRequest:String = "broadcastRequest";
		private var selectedGroup:Array = new Array();
		public var BroadcastConfigType:String;
		
		public function get SelectedGroup():Array
		{
			return selectedGroup;
		}
		
		public function MC_BroadCastPanel() {
			// constructor code
			
		}
		
		override protected function Init():void 
		{
			super.Init();
			InitConnection();
			ResetScreenBtns();
			this["b_ok"].buttonMode = true;
			this["b_ok"].addEventListener(MouseEvent.CLICK, OnConformClick);
			this["b_cancel"].buttonMode = true;
			this["b_cancel"].addEventListener(MouseEvent.CLICK, OnCancelClick);
			EventMaster.getInstance().addEventListener(ScreenPairEvent.BroadPairClicked, OnBroadPairClicked);
		}
		
		function InitConnection():void 
		{
			for (var i:int = 0; i < ScreenConnectionState.DisconnectedPairNos.length; i++) 
			{
				var pairNo = ScreenConnectionState.DisconnectedPairNos[i];
				(this["p_" +pairNo] as BaseScreenPair).CancelConnection();
			}
		}
		
		function ResetScreenBtns():void 
		{
			for (var i:int = 1; i <=18 ; i++) //18屏
			{
				this["s_"+i.toString()].gotoAndStop(1);
			}
		}
		
		function OnBroadPairClicked(e:ScreenPairEvent):void 
		{
			//类型检测：双屏内容不能在单屏播放
			if (this.BroadcastConfigType == "Double" && !e.PairInfo.HasConnection)
			{
				return;
			}
			
			var info:ScreenPairInfo = e.PairInfo;
			var gID:uint = GroupCalc.GroupNo(this, info);
			//trace("Broad group:" + gID);
			if (info.HasConnection)//double screen
			{
				if (this["s_" + info.LeftScreenNo].currentFrame == 2)//取消选中
				{
					this["s_" + info.LeftScreenNo].gotoAndStop(1);
					this["s_" + info.RightScreenNo].gotoAndStop(1);
					RemoveGroup(gID);
				}
				else//选中
				{
					this["s_" + info.LeftScreenNo].gotoAndStop(2)
					this["s_" + info.RightScreenNo].gotoAndStop(2);
					AddGroup(gID);
				}
			}
			else //single screen
			{
				var selectedPart:String = info.SelectedPart;
				var clickedScreenID:uint;
				if (selectedPart == info.Left)
				{
					clickedScreenID = info.LeftScreenNo;
				}
				else
				{
					clickedScreenID = info.RightScreenNo;
				}
				
				if (this["s_" + clickedScreenID].currentFrame == 2)//取消屏选中状态
				{
					this["s_" + clickedScreenID].gotoAndStop(1);
					RemoveGroup(gID);
				}
				else//选中屏
				{
					this["s_" + clickedScreenID].gotoAndStop(2);
					AddGroup(gID);
				}
			}
		}
		
		function AddGroup(gid:uint):void
		{
			if (this.selectedGroup.indexOf(gid) < 0)
			{
				this.selectedGroup.push(gid);
			}
		}
		
		function RemoveGroup(gid:uint):void
		{
			var index:int = this.selectedGroup.indexOf(gid);
			if (index >= 0)
			{
				this.selectedGroup.splice(index, 1);
			}
		}
		
		function OnConformClick(e:Event):void 
		{
			//UpdateSelectedGroup();
			this.dispatchEvent(new Event(this.BroadcastRequest));
		}
		
		function OnCancelClick(e:Event):void 
		{
			this.parent.removeChild(this);
		}
		
		//function UpdateSelectedGroup():void 
		//{
			//
		//}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
			this["b_ok"].removeEventListener(MouseEvent.CLICK, OnConformClick);
			this["b_cancel"].removeEventListener(MouseEvent.CLICK, OnCancelClick);
			EventMaster.getInstance().addEventListener(ScreenPairEvent.BroadPairClicked, OnBroadPairClicked);
		}
	}
	
}
