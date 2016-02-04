package com.component {
	
	import com.BaseMovie;
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
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	
	public class CP_Video extends BaseMovie {
		
		public var InitID:uint;
		private var m_dessText:String;
		private var m_assetText:String;
		private var m_isSelected:Boolean = false;
		private var m_VideoName:String;
		
		//videoID
		var m_videoIDTxt:TextField;
		
		//preview pic
		private var m_showedPicPath:String;
		private var m_picTimer:Timer;
		private var m_picPanel:Sprite;
		private var m_picWidth:int=364;
		private var m_picHeight:int = 205;
		
		public function CP_Video() {
			// constructor code
		}
		
		public function set VideoID(value:int):void
		{
			UpdateVideoID(value);
		}
		
		public function set VideoName(value:String)
		{
			this.m_VideoName = value;
			var showedPicName = m_VideoName.substring(0, m_VideoName.lastIndexOf('.')) + ".jpg";
			m_showedPicPath = MConfig.AssetFolder + "\\" + showedPicName;
		}
		
		public function get VideoTitle():String
		{
			return this["t_title"].text;
		}
		public function set VideoTitle(value:String)
		{
			this["t_title"].text = value;
		}
		
		public function get VideoText():String
		{
			return this["t_des"].text;
		}
		public function set VideoText(value:String)
		{
			this["t_des"].text = value;
		}
		
		public function set IsSelected(value:Boolean)
		{
			m_isSelected = value;
			var fmt:TextFormat;
			if (value == true)
			{
				this.gotoAndStop(2);
				m_videoIDTxt.textColor = 0xE65B34;
				
				fmt= new TextFormat();
				fmt.size = 14;
				this["t_des"].setTextFormat(fmt);
			}
			else
			{
				this.gotoAndStop(1);
				m_videoIDTxt.textColor = 0x000000;
				
				fmt = new TextFormat();
				fmt.size = 15;
				this["t_des"].setTextFormat(fmt);
			}
		}
		
		public function get IsSelected():Boolean
		{
			return m_isSelected;
		}
		
		public function get AssetText():String
		{
			UpdateAssetText();
			return m_assetText;
		}
		
		private function UpdateAssetText():String 
		{
			if (this.m_VideoName==null||this.m_VideoName==""||this.m_dessText == null || this.m_dessText == "")//not a complete config
			{
				return null;
			}
			else
			{
				m_assetText = "";
				m_assetText += "<video>\r\n";
				m_assetText += "<fileName>" + this.m_VideoName + "</fileName>\r\n";
				m_assetText += "<videoTitle>" + this.VideoTitle+"</videoTitle>\r\n";
				m_assetText += "<videoText>" + this.VideoText+"</videoText>\r\n";
				m_assetText += m_dessText + "\r\n";
				m_assetText += "</video>\r\n";
				return m_assetText;
			}
		}
		
		public function set DessText(value:String)
		{
			m_dessText = value;
		}
		
		public function get DessText():String
		{
			return m_dessText;
		}
		
		override protected function Init():void 
		{
			super.Init();
			m_videoIDTxt = this["txt_VideoID"];
			InitBtns();
			InitTextInputs();
			EventMaster.getInstance().addEventListener("respondVideoFile", OnVideoFileResponed);
			m_picTimer = new Timer(2000);
			m_picTimer.addEventListener(TimerEvent.TIMER, OnPicTimer);
			InitPicPanel();
			this.addEventListener(MouseEvent.CLICK, OnClick);
			if (m_VideoName != null && m_VideoName != "")
			{
				BeginShowPrewPic();
			}
		}
		
		private function InitPicPanel():void 
		{
		    m_picPanel = this["p_pic"];
			m_picPanel.addEventListener(MouseEvent.CLICK, OnPicClicked);
		}
		
		private function InitBtns():void 
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
		
		private function InitTextInputs()
		{
			this["t_title"].addEventListener(Event.CHANGE, OnTitleChange);
			this["t_des"].addEventListener(Event.CHANGE, OnTextChange);
		}
		
		private function OnTitleChange(e:Event)
		{
			ModifyState.ModifyState = ModifyState.Modified;
		}
		private function OnTextChange(e:Event)
		{
			ModifyState.ModifyState = ModifyState.Modified;
		}
		
		private function OnEditClick(e:MouseEvent)
		{
			e.stopPropagation();
			FireSelect();
			EditVideoFile();
		}

		private function OnDeleteClick(e:MouseEvent)
		{
			e.stopPropagation();
			this.dispatchEvent(new Event("VIDEODELETE"));
		}
		
		private function OnUpClick(e:MouseEvent)
		{
			e.stopPropagation();
			this.dispatchEvent(new Event("VIDEOUP"));
		}
		
		private function OnDownClick(e:MouseEvent)
		{
			e.stopPropagation();
			this.dispatchEvent(new Event("VIDEODOWN"));
		}
		
		private function OnPicClicked(e:MouseEvent)
		{
			e.stopPropagation();
			if (this.IsSelected)
			{
				FireSelect();
			}
			EditVideoFile();
		}
		
		function OnClick(e:MouseEvent):void 
		{
			e.stopPropagation();
			FireSelect();
		}
		
		function FireSelect():void 
		{
			if (this.m_isSelected == false)
			{
				this.dispatchEvent(new Event("Selected"));
			}
		}
		
		private function EditVideoFile():void 
		{
			Main.Instace.SendMsgtoWin("requestVideoFile", this.InitID.toString());
		}
		
		//a video is selected from outside
		private function OnVideoFileResponed(e:ExternalCmdEvent):void 
		{
			var tID:uint = e.arg.split('^')[0];
			if (tID != this.InitID)//file not for this
			{
				return;
			}
			else
			{
				this.VideoName=e.arg.split('^')[1];
			}
			BeginShowPrewPic();
			ModifyState.ModifyState = ModifyState.Modified;
		}
		
		function UpdateVideoID(value:int):void 
		{
			m_videoIDTxt.text = "";
			if (value < 10)
			{
				m_videoIDTxt.text = "0" + value;
			}
			else
			{
				m_videoIDTxt.text =value.toString();
			}
		}
		
		function BeginShowPrewPic():void 
		{
			m_picTimer.start();
		}
		
		function OnPicTimer(e:TimerEvent):void 
		{
			try
			{	
				var loader:Loader = new Loader();
				var url:URLRequest = new URLRequest(m_showedPicPath);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, OnPicLoaded);
				loader.load(url);
			}
			catch(err:Error)
			{
				trace("load video's pic error:" + err.message);
			}
		}
		
		function OnPicLoaded(e:Event):void 
		{
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
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
			this["b_edit"].removeEventListener(MouseEvent.CLICK, OnEditClick);
			this["b_delete"].removeEventListener(MouseEvent.CLICK, OnDeleteClick);
			this["b_up"].removeEventListener(MouseEvent.CLICK, OnUpClick);
			this["b_down"].removeEventListener(MouseEvent.CLICK, OnDownClick);
			this["t_title"].removeEventListener(Event.CHANGE, OnTitleChange);
			this["t_des"].removeEventListener(Event.CHANGE, OnTextChange);
			m_picPanel.removeEventListener(MouseEvent.CLICK, OnPicClicked);
			this.removeEventListener(MouseEvent.CLICK, OnClick);
			EventMaster.getInstance().removeEventListener("respondVideoFile", OnVideoFileResponed);
		}
	}
	
}
