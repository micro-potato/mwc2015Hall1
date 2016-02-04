package com.component 
{
	import adobe.utils.CustomActions;
	import com.Business.ModifyState;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author LY
	 */
	public class VideoConfigPanel extends BaseConfigPanel
	{
		//video location
		private var initVideoX:int=5;
		private var currentVideoY:int = 25;
		private var initVideoY = 25;
		private var offsetVideoY:int = 20;
		private var m_InitID:int = 0;
		
		//scroll bar
		private var m_VideoPanel:Sprite;
		private var m_VideoBar:ScrollBar;
		
		//Assets
		private var m_VideoComponents:Array;
		private var  m_desPanel:DesConfigPanel;
		
		public function VideoConfigPanel() 
		{
			
		}
		
		override protected function Init():void 
		{
			super.Init();
			currentVideoY = initVideoY;
			m_desPanel = this["desConfig"];
			this["videoAdd"].buttonMode = true;
			this["videoAdd"].addEventListener(MouseEvent.CLICK, OnAddVideoClick);
			InitPanel();
			InitScrollBar();
			m_VideoComponents = new Array();
		}
		
		private function InitPanel():void 
		{
			m_VideoPanel = new Sprite();
			m_VideoPanel.x = 21;
			m_VideoPanel.y = 21;
			this.addChildAt(m_VideoPanel, 0);
		}
		
		private function InitScrollBar():void 
		{
			m_VideoBar = new ScrollBar(m_VideoPanel, this["videoMask"], this["videoBar"], this["videoLine"]);
			m_VideoBar.refresh();
		}
		
		override public function get PlayListText():String 
		{
			SaveCurrentConfig();
			if (m_VideoComponents.length == 0)//未配置
			{
				return "";
			}
			else
			{
				var playListText:String = "";
				for (var i:int = 0; i < m_VideoComponents.length; i++) 
				{
					var mcVideo:CP_Video = m_VideoComponents[i];
					UpdateVideoConfig(mcVideo);
					playListText += mcVideo.AssetText + "\r\n";
				}
				return playListText;
			}
		}
		
		private function UpdateVideoConfig(videoMC:CP_Video):void 
		{
			if (videoMC.IsSelected)
			{
				videoMC.DessText = m_desPanel.PlayListText;
			}
		}
		
		private function OnVideoSelected(e:Event)
		{
			SaveCurrentConfig();
			UnSelectedAll();
			var cp_video:CP_Video = e.currentTarget as CP_Video;
			cp_video.IsSelected = true;
			m_desPanel.ResetAssetPanel();
			m_desPanel.PlayListText = "<data>\r\n" + cp_video.DessText + "</data>\r\n";
		}
		
		private function OnVideoDelete(e:Event)
		{
			var cp_video:CP_Video = e.currentTarget as CP_Video;
			
			if (cp_video.IsSelected)//if video is selected,remove its dess
			{
				this.m_desPanel.ResetAssetPanel();
			}
			
			var tIndex:int = this.m_VideoComponents.indexOf(cp_video);
			if (tIndex >= 0)
			{
				m_VideoComponents.splice(tIndex, 1);
				RefreshVideoCPs();
				ModifyState.ModifyState = ModifyState.Modified;
			}
		}
		
		private function OnVideoUp(e:Event)
		{
			var cp_video:CP_Video = e.currentTarget as CP_Video;
			var tIndex:int = m_VideoComponents.indexOf(cp_video);
			if (tIndex == 0)//1st element
			{
				return;
			}
			else
			{
				var tmp:CP_Video = m_VideoComponents[tIndex];
				var tmp2:CP_Video = m_VideoComponents[tIndex-1];
				m_VideoComponents[tIndex] = tmp2;
				m_VideoComponents[tIndex - 1] = tmp;
				RefreshVideoCPs();
				ModifyState.ModifyState = ModifyState.Modified;
			}
		}
		
		private function OnVideoDown(e:Event)
		{
			var cp_video:CP_Video = e.currentTarget as CP_Video;
			var tIndex:int = m_VideoComponents.indexOf(cp_video);
			if (tIndex == m_VideoComponents.length-1)//last element
			{
				return;
			}
			else
			{
				var tmp:CP_Video = m_VideoComponents[tIndex];
				var tmp2:CP_Video = m_VideoComponents[tIndex+1];
				m_VideoComponents[tIndex] = tmp2;
				m_VideoComponents[tIndex + 1] = tmp;
				RefreshVideoCPs();
				ModifyState.ModifyState = ModifyState.Modified;
			}
		}
		
		//add video by click add button
		private function OnAddVideoClick(e:MouseEvent):void 
		{
			SaveCurrentConfig();
			UnSelectedAll();
			var mc_video:CP_Video = new CP_Video();
			AddaVideotoPanel(mc_video);
			m_VideoComponents.push(mc_video);
			mc_video.IsSelected = true;
			mc_video.VideoID = m_VideoComponents.length;
			mc_video.InitID = m_InitID;
			m_InitID++;
			m_VideoBar.refresh();
			m_desPanel.ResetAssetPanel();
			trace("added video des:" + mc_video.DessText);
			ModifyState.ModifyState = ModifyState.Modified;
		}
		
		function AddaVideotoPanel(mc:CP_Video):void 
		{
			//add events for the new cp_video
			mc.addEventListener("Selected", OnVideoSelected);
			mc.addEventListener("VIDEODELETE", OnVideoDelete);
			mc.addEventListener("VIDEOUP", OnVideoUp);
			mc.addEventListener("VIDEODOWN", OnVideoDown);
			mc.addEventListener(Event.REMOVED_FROM_STAGE, OnVideoRemoved);
			
			m_VideoPanel.addChild(mc);
			mc.x = initVideoX;
			mc.y = currentVideoY;
			currentVideoY += mc.height + offsetVideoY;
		}
		
		private function RefreshVideoCPs()
		{
			ResetPanel();
			for (var i:int = 0; i < m_VideoComponents.length; i++) 
			{
				var mc:CP_Video = m_VideoComponents[i];
				mc.InitID = this.m_InitID;
				m_InitID++;
				AddaVideotoPanel(mc);
				mc.VideoID = i + 1;
			}
		}
		
		function ResetPanel():void 
		{
			while (this.m_VideoPanel.numChildren > 0)//Cleaer videos
			{
				this.m_VideoPanel.removeChildAt(0);
			}
			this.currentVideoY = this.initVideoY;
			m_InitID = 0;
		}
		
		function OnVideoRemoved(e:Event):void 
		{
			e.currentTarget.removeEventListener("Selected", OnVideoSelected);
			e.currentTarget.removeEventListener("VIDEODELETE", OnVideoDelete);
			e.currentTarget.removeEventListener("VIDEOUP", OnVideoUp);
			e.currentTarget.removeEventListener("VIDEODOWN", OnVideoDown);
			e.currentTarget.removeEventListener(Event.REMOVED_FROM_STAGE, OnVideoRemoved);
		}
		
		private function SaveCurrentConfig():void 
		{
			for (var i:int = 0; i < m_VideoComponents.length; i++) 
			{
				var cur_videoCP:CP_Video = m_VideoComponents[i];
				if (cur_videoCP.IsSelected)
				{
					cur_videoCP.DessText = this.m_desPanel.PlayListText;
				}
			}
		}
		
		function UnSelectedAll():void 
		{
			for (var i:int = 0; i < m_VideoComponents.length; i++) 
			{
				var cur_videoCP:CP_Video = m_VideoComponents[i];
				cur_videoCP.IsSelected = false;
			}
			m_desPanel.ResetAssetPanel();
		}
		
		//Refresh videos and dess according by Playlist.
		override protected function UpdateUI(playListText:String):void 
		{
			var doc:XML = new XML(playListText);
			ExtractAssetsFromDoc(doc);
			RefreshVideoCPs();
			SelectFirstVideo();
		}
		
		private function ExtractAssetsFromDoc(doc:XML)
		{
			var videoList = doc["video"];
			m_VideoComponents = new Array();
			for each (var videoXML:XML in videoList) 
			{
				//trace("video:" + videoXML);
				var videoName:String = videoXML["fileName"];
				//trace("videoName" + videoName);
				var desList = videoXML["des"];
				var dessText:String = "";
				for each (var desXML:XML in desList) 
				{
					dessText += desXML + "\r\n";
				}
				//trace("dessText:" + dessText);
				var cp_video:CP_Video = new CP_Video();
				cp_video.VideoName = videoName;
				cp_video.DessText = dessText;
				m_VideoComponents.push(cp_video);
				cp_video.VideoTitle = videoXML["videoTitle"];
				cp_video.VideoText = videoXML["videoText"];
			}
		}
		
		function SelectFirstVideo():void 
		{
			if (m_VideoComponents.length > 0)
			{
				var firstVideo:CP_Video = m_VideoComponents[0];
				firstVideo.IsSelected = true;
				m_desPanel.PlayListText = "<data>\r\n" + firstVideo.DessText + "</data>\r\n";
			}
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
			this["videoAdd"].removeEventListener(MouseEvent.CLICK, OnAddVideoClick);
		}	
	}
}