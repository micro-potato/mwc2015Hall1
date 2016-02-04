package com.mc {
	
	import com.BaseMovie;
	import com.Business.ModifyState;
	import com.customEvent.EditGroupEvent;
	import com.EventMaster;
	import com.Main;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class MC_HomePage extends BaseMovie {
		
		private var activeMC:MovieClip;
		private var nextActiveMC:MovieClip;
		
		public function MC_HomePage() {
			// constructor code
		}
		
		override protected function Init():void 
		{
			super.Init();
			this["btnMap"].buttonMode = true;
			this["btnMap"].addEventListener(MouseEvent.CLICK, OnMapClick);
			this["btnClose"].buttonMode = true;
			this["btnClose"].addEventListener(MouseEvent.CLICK, OnCloseClick);
			EventMaster.getInstance().addEventListener(EditGroupEvent.EditGroup, OnEditGroup);
			SwitchMC(new MC_Map());
		}
		
		function OnCloseClick(e:MouseEvent):void 
		{
			Main.Instace.SendMsgtoWin("requestExit", "");
		}
		
		function OnEditGroup(e:EditGroupEvent):void 
		{
			//将要进行的配置
			var mc:MC_Config = new MC_Config();
			mc.GroupNo = e.GroupNo;
			mc.ConfigType = e.configType;
			nextActiveMC = mc;
			
			//处理现有配置
			var configMCClosing:MC_Config = this.activeMC as MC_Config;
			trace("ModifyState:" + ModifyState.ModifyState);
			if (configMCClosing&&(ModifyState.ModifyState==ModifyState.Modified))
			{
				configMCClosing.addEventListener("Closed", OnOldConfigPanelClosed);
				configMCClosing.RequestClose();
			}
			else
			{
				SwitchMC(mc);
			}
		}
		
		function OnOldConfigPanelClosed(e:Event):void 
		{
			if (nextActiveMC)
			{
				SwitchMC(nextActiveMC);
				ModifyState.ModifyState = ModifyState.None;
				nextActiveMC = null;
			}
		}
		
		function OnMapClick(e:Event):void 
		{
			if (activeMC && activeMC as MC_Map)
			{
				return;
			}
			else
			{
				SwitchMC(new MC_Map());
				//this["gp"].SetEditVisible(true);
			}
		}
		
		public function SwitchMC(mc:MovieClip)
		{
			RemoveCurrentMC();
			activeMC = mc;
			this.addChildAt(activeMC, 1);
			if (activeMC is MC_Config)//配置界面置顶
			{
				this.setChildIndex(activeMC, this.numChildren - 1);
			}
		}
		
		function RemoveCurrentMC():void 
		{
			if (activeMC && this.contains(activeMC))
			{
				this.removeChild(activeMC);
			}
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
			this["btnMap"].removeEventListener(MouseEvent.CLICK, OnMapClick);
			this["btnClose"].removeEventListener(MouseEvent.CLICK, OnCloseClick);
		}
	}
	
}
