package com.component {
	
	import com.BaseMovie;
	import com.Business.Des;
	import com.Business.ModifyState;
	import com.customEvent.ExternalCmdEvent;
	import com.EventMaster;
	import com.Main;
	import com.MConfig;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	
	public class CP_Des extends BaseMovie {
		
		private var desc:Des;
		public var InitID:uint;
		
		public function set Desc(value:Des):void
		{
			desc = value;
		}
		
		private function UpdateUI()
		{
			this["t_Time"].text = desc.LastTime;
			SetDescFileInfo(desc.FileName);
		}
		
		//pic
		private var m_showPicName:String;
		private var m_picTimer:Timer;
		private var m_picPanel:Sprite;
		private var m_picWidth:int=293;
		private var m_picHeight:int=164;
		
		public function CP_Des() {
			// constructor code
		}
		
	    public function get Text():String 
		{
			if (desc == null)
			{
				return null;
			}
			else
			{
				desc.LastTime = this["t_Time"].text;
				if (desc.Type == desc.VideoType)
				{
					desc.LastTime = "0";//Video，no time limitation，play once
				}
				return desc.CreateText();
			}
		}
		
		override protected function Init():void 
		{
			super.Init();
			InitPicPanel();
			InitBtns();
			m_picTimer = new Timer(2000);
			m_picTimer.addEventListener(TimerEvent.TIMER, OnPicTimer);
			EventMaster.getInstance().addEventListener("respondDesFile", OnGetDesResponse);
			if (desc)
			{
				UpdateUI();
			}
			else
			{
				desc = new Des();
			}
		}
		
		private function InitPicPanel():void 
		{
			//m_picPanel = new Sprite();
			m_picPanel = this["p_pic"];
			m_picPanel.addEventListener(MouseEvent.CLICK, OnPicClick);
			this.addChild(m_picPanel);
		}
		
		private function InitBtns()
		{
			this["b_edit"].buttonMode = true;
			this["b_edit"].addEventListener(MouseEvent.CLICK, OnEditClick);
			
			this["b_delete"].buttonMode = true;
			this["b_delete"].addEventListener(MouseEvent.CLICK, OnDeleteClick);
			
			this["b_up"].buttonMode = true;
			this["b_up"].addEventListener(MouseEvent.CLICK, OnUpClick);
			
			this["b_down"].buttonMode = true;
			this["b_down"].addEventListener(MouseEvent.CLICK, OnDownClick);
		}
		
		private function OnEditClick(e:MouseEvent):void 
		{
			e.stopPropagation();
			SelectDesFile();
		}
		
		private function OnDeleteClick(e:Event):void 
		{
			this.dispatchEvent(new Event("DESDELETE"));
		}
		
		private function OnUpClick(e:Event):void 
		{
			this.dispatchEvent(new Event("DESUP"));
		}
		
		private function OnDownClick(e:Event):void 
		{
			this.dispatchEvent(new Event("DESDOWN"));
		}
		
		private function OnPicClick(e:Event):void 
		{
			SelectDesFile();
		}
		
		function SelectDesFile():void 
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.call("requestDesFile", this.InitID.toString());
			}
		}

		private function OnGetDesResponse(e:ExternalCmdEvent)
		{
			var initID:int =int(e.arg.substring(0, e.arg.indexOf('^')));
			if (initID != InitID)//the file is not for this cp_des
			{
				return;
			}
			else
			{
				this.desc.FileName = e.arg.substring(e.arg.indexOf('^') + 1);
				SetDescFileInfo(this.desc.FileName);
				ModifyState.ModifyState = ModifyState.Modified;
			}
		}
		
		private function SetDescFileInfo(fileName:String):void 
		{
			var suffix:String = fileName.substring(fileName.lastIndexOf('.') + 1);
			if (MConfig.PicSuffix.indexOf(suffix) >= 0)//current asset is a pic
			{
				m_showPicName = fileName;
				desc.Type = desc.PicType;
				ShowTime();
			}
			else if (MConfig.VideoSuffix.indexOf(suffix) >= 0)
			{
				//m_showPicName = fileName.substring(0, fileName.lastIndexOf('.')) + ".jpg";
				m_showPicName = fileName.substring(0, fileName.lastIndexOf('.')) + "." + suffix.toLowerCase();
				desc.Type = desc.VideoType;
				HideTime();
			}
			LoadPic();
		}
		
		private function LoadPic():void 
		{
			try
			{
				var loader:Loader = new Loader();
				var url:URLRequest = new URLRequest(MConfig.AssetFolder + "\\" + m_showPicName);
				//Main.Instace.AppendLog("load pic:" + url.url);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, OnPicLoaded);
				loader.load(url);
			}
			catch(e:Error)
			{
				Main.Instace.AppendLog("load pic error:" + e.message)
				ReLoadPic();
			}
		}
		
		private function OnPicLoaded(e:Event):void 
		{
			//Main.Instace.AppendLog("Pic loaded")
			var loaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE, OnPicLoaded);
			var pic:Bitmap = loaderInfo.content as Bitmap;
			pic.smoothing = true;
			pic.width = this.m_picWidth;
			pic.height = this.m_picHeight;
			ShowPic(pic);
		}
		
		private function ShowPic(pic:Bitmap):void 
		{
			if (m_picPanel.numChildren != 0)
			{
				m_picPanel.removeChildAt(0);
			}
			m_picPanel.addChild(pic);
			m_picTimer.stop();
		}
		
		private function OnPicTimer(e:Event):void 
		{
			LoadPic();
		}
		
		private function ReLoadPic():void 
		{
			m_picTimer.start();
		}
		
		public function ShowTime()
		{
			this["t_Time"].visible = true;
			this["second"].visible = true;
		}
		
		public function HideTime()
		{
			this["t_Time"].visible = false;
			this["second"].visible = false;
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
			this["b_edit"].removeEventListener(MouseEvent.CLICK, OnEditClick);
			this["b_delete"].removeEventListener(MouseEvent.CLICK, OnDeleteClick);
			this["b_up"].removeEventListener(MouseEvent.CLICK, OnUpClick);
			this["b_down"].removeEventListener(MouseEvent.CLICK, OnDownClick);
			EventMaster.getInstance().removeEventListener("respondDesFile", OnGetDesResponse);
		}
	}
	
}
