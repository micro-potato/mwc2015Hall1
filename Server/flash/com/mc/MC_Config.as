package com.mc 
{
	import adobe.utils.CustomActions;
	import com.BaseMovie;
	import com.Business.ModifyState;
	import com.component.BaseConfigPanel;
	import com.component.SingleScreenDesConfigPanel;
	import com.component.VideoConfigPanel;
	import com.customEvent.ExternalCmdEvent;
	import com.customEvent.ScreenPairEvent;
	import com.EventMaster;
	import com.Main;
	import com.XMLHelper;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author LY
	 */
	public class MC_Config extends BaseMovie
	{
		public const Single:String = "Single";
		public const Double:String = "Double";
		
		private var configType:String;
		private var activePanel:BaseConfigPanel;
		private var m_broadCastpanel:Sprite;
		
		public function set ConfigType(value:String)
		{
			configType = value;
		}
		
		private var groupNo:uint;
		public function set GroupNo(value:uint)
		{
			groupNo = value;
		}
		
		private function get PlayListText():String
		{
			return this.activePanel.PlayListText;
		}
		
		public function MC_Config() 
		{
			
		}
		
		override protected function Init():void 
		{
			super.Init();
			InitPanel();
			EventMaster.getInstance().addEventListener(ExternalCmdEvent.RespondPlayList, OnGetPlayListfromOutSide);
			InitBtns();
			CheckHasConfiged();
		}
		
		private function CheckHasConfiged():void 
		{
			var configPath:String = "playlist\\" + this.groupNo.toString() + ".xml";
			try
			{
				var xmlHelper:XMLHelper = new XMLHelper(configPath, true);
				xmlHelper.addEventListener(xmlHelper.XMLLoadedEvent, OnConfigLoaded);
			}
			catch(err:Error)
			{
				trace("group hasn't configed");
			}
		}
		
		private function OnConfigLoaded(e:Event):void 
		{
			var xmlHelper:XMLHelper = e.currentTarget as XMLHelper;
			xmlHelper.removeEventListener(xmlHelper.XMLLoadedEvent, OnConfigLoaded);
			var doc:XML = xmlHelper.Doc;
			this.activePanel.PlayListText = doc;
		}
		
		///btns at bottom
		private function InitBtns():void 
		{
			this["btn_load"].buttonMode = true;
			this["btn_load"].addEventListener(MouseEvent.CLICK, OnLoadClick);
			this["btn_save"].buttonMode = true;
			this["btn_save"].addEventListener(MouseEvent.CLICK, OnSaveClick);
			this["btn_play"].buttonMode = true;
			this["btn_play"].addEventListener(MouseEvent.CLICK, OnPlayClick);
			this["btn_broadcast"].buttonMode = true;
			this["btn_broadcast"].addEventListener(MouseEvent.CLICK, OnBroadcastClick);
			this["btn_preview"].buttonMode = true;
			this["btn_preview"].addEventListener(MouseEvent.CLICK, OnPreviewClick);
		}
		
		private function OnLoadClick(e:Event):void 
		{
			Main.Instace.SendMsgtoWin("requestPlayList", "");
		}
		
		private function OnSaveClick(e:Event):void 
		{
			var playListText:String = this.PlayListText;
			if (playListText && playListText != "")
			{
				Main.Instace.SendMsgtoWin("savePlayList", playListText);
			}
		}
		
		private function OnPlayClick(e:Event):void 
		{
			PlayCurrentConfigedList();
		}
		
		private function PlayCurrentConfigedList()
		{
			Main.Instace.AppendLog("playListconfig:" + activePanel.PlayListText);
			trace("CurrentList:" + activePanel.PlayListText);
			var playListText:String = activePanel.PlayListText;
			Main.Instace.SendMsgtoWin("playPlayList", this.groupNo.toString() + ":" + playListText);
			ModifyState.ModifyState = ModifyState.None;
		}
		
		private function OnBroadcastClick(e:Event):void 
		{
			ResetBroadCastPanel();
			var pc_bc:MC_BroadCastPanel = new MC_BroadCastPanel();
			m_broadCastpanel.addChild(pc_bc);
			pc_bc.BroadcastConfigType = this.configType;
			pc_bc.addEventListener(pc_bc.BroadcastRequest, OnBroadCastSelected);
		}
		
		private function ResetBroadCastPanel()
		{
			if (m_broadCastpanel && this.contains(m_broadCastpanel))
			{
				this.removeChild(m_broadCastpanel);
			}
			m_broadCastpanel = new Sprite();
			this.addChild(m_broadCastpanel);
		}
		
		private function OnBroadCastSelected(e:Event):void 
		{
			var pc_bc:MC_BroadCastPanel = e.currentTarget as MC_BroadCastPanel;
			pc_bc.removeEventListener(pc_bc.BroadcastRequest, OnBroadCastSelected);
			var selectedArray:Array = pc_bc.SelectedGroup;
			ResetBroadCastPanel();
			BroadCastGroups(selectedArray);
		}
		
		private function BroadCastGroups(groups:Array):void 
		{
			if (groups.length != 0)
			{
				var selectedString:String = groups.join();
				Main.Instace.SendMsgtoWin("broadcast", this.groupNo.toString() + ":" + selectedString);
				trace("broadcast", this.groupNo.toString() + ":" + selectedString);
			}
		}
		
		private function OnPreviewClick(e:Event):void 
		{
			Main.Instace.SendMsgtoWin("requestPreView", this.PlayListText);
		}
		
		public function RequestClose()
		{
			if (ModifyState.ModifyState == ModifyState.Modified)
			{
				var mc_save:MC_Save = new MC_Save();
				mc_save.addEventListener(mc_save.SaveConfig, OnSaveConfig);
				mc_save.addEventListener(mc_save.CancelConfig, OnCancelConfig);
				this.addChild(mc_save);
			}
		}
		
		function OnSaveConfig(e:Event):void 
		{
			var mc_save:MC_Save = e.currentTarget as MC_Save;
			mc_save.removeEventListener(mc_save.SaveConfig, OnSaveConfig);
			mc_save.removeEventListener(mc_save.CancelConfig, OnCancelConfig);
			var playListText:String = activePanel.PlayListText;
			Main.Instace.SendMsgtoWin("playPlayList", this.groupNo.toString() + ":" + playListText);
			this.dispatchEvent(new Event("Closed"));
		}
		
		function OnCancelConfig(e:Event):void 
		{
			var mc_save:MC_Save = e.currentTarget as MC_Save;
			mc_save.removeEventListener(mc_save.SaveConfig, OnSaveConfig);
			mc_save.removeEventListener(mc_save.CancelConfig, OnCancelConfig);
			this.dispatchEvent(new Event("Closed"));
		}
		
		private function InitPanel():void 
		{
			var panel:BaseConfigPanel;
			if (groupNo == 0)
			{
				return;
			}
			if (this.configType == this.Single)
			{
				panel = new SingleScreenDesConfigPanel();
			}
			else
			{
				panel = new VideoConfigPanel();
			}
			SwitchPanel(panel);
		}
		
		private function SwitchPanel(panel:BaseConfigPanel)
		{
			RemoveCurrentPanel();
			activePanel = panel;
			this.addChild(panel);
			panel.x = 227;
			panel.y = 50;
		}
		
		private function RemoveCurrentPanel():void 
		{
			if (activePanel && this.contains(activePanel))
			{
				this.removeChild(activePanel);
			}
		}
		
		private function OnGetPlayListfromOutSide(e:ExternalCmdEvent):void 
		{
			var list:String = e.arg;
			var playType:String = CheckPlayListType(list);
			//Main.Instace.AppendLog("load type:" + playType);
			if (this.configType == playType)
			{
				this.activePanel.PlayListText = list;
			}
			else//selected playlist can't match 
			{
				Main.Instace.SendMsgtoWin("loadTypeError", "");
			}
		}
		
		private function CheckPlayListType(playList:String):String 
		{
			var listXML:XML = new XML(playList);
			//Main.Instace.AppendLog("listXML:" + listXML);
			var videoAssets:XMLList = listXML["video"];
			
			//Main.Instace.AppendLog("videoAssets:" + videoAssets);
			if (videoAssets!=null&&videoAssets.toString()!="")//has vidieo,double
			{
				return this.Double;
			}
			else//single
			{
				return this.Single;
			}
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
			this["btn_load"].removeEventListener(MouseEvent.CLICK, OnLoadClick);
			this["btn_save"].removeEventListener(MouseEvent.CLICK, OnSaveClick);
			this["btn_play"].removeEventListener(MouseEvent.CLICK, OnPlayClick);
			this["btn_broadcast"].removeEventListener(MouseEvent.CLICK, OnBroadcastClick);
			this["btn_preview"].removeEventListener(MouseEvent.CLICK, OnPreviewClick);
			EventMaster.getInstance().removeEventListener(ExternalCmdEvent.RespondPlayList, OnGetPlayListfromOutSide);
		}
		
	}

}