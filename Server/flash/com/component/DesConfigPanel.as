package com.component 
{
	import adobe.utils.CustomActions;
	import com.Business.Des;
	import com.Business.ModifyState;
	import com.XMLHelper;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author LY
	 */
	public class DesConfigPanel extends BaseConfigPanel
	{	
		//asset
		private var m_desAssets:Array = new Array();
		private var m_InitID:int = 0;
		//location
		protected var initX:int = 280;
		protected var InitY:int = 10;
		protected var currentY:int=10;
		protected var offsetY:int = 20;
		protected var panelX:int = 0;
		protected var panelY:int = 0;
		protected var editX:int;
		
		//scroll bar
		protected var m_assetPanel:Sprite;
		private var m_scrollBar:ScrollBar;
		
		public function DesConfigPanel() 
		{
			
		}
		
		override protected function Init():void 
		{
			super.Init();
			this["b_add"].buttonMode = true;
			this["b_add"].addEventListener(MouseEvent.CLICK, OnAddClick);
			this.m_assetPanel = new Sprite();
			m_assetPanel.x = panelX
			m_assetPanel.y = panelY;
			this.addChildAt(m_assetPanel, 0);
			InitScrollBar();
			m_desAssets = new Array();
			currentY = InitY;
		}
		
		override public function get PlayListText():String 
		{
			var text:String = "";
			for (var i:int = 0; i < this.m_assetPanel.numChildren; i++) 
			{
				var item:CP_Des = m_assetPanel.getChildAt(i) as CP_Des;
				if (item)
				{
					text += item.Text+"\r\n";
				}
			}
			return text;
		}
		
		public function ResetAssetPanel():void 
		{
			while (m_assetPanel.numChildren > 0)
			{
				m_assetPanel.removeChildAt(0);
			}
			this.currentY = this.InitY;
		}
		
		private function InitScrollBar():void 
		{
			m_scrollBar = new ScrollBar(m_assetPanel, this["maskmc"], this["bar"], this["line"]);
			m_scrollBar.elastic=false; 
		}
		
		//添加des
		private function OnAddClick(e:MouseEvent):void 
		{
			var mc_desc:CP_Des = new CP_Des();
			mc_desc.InitID = m_InitID;
			m_InitID++;
			AddDesMCtoPanel(mc_desc);
			m_desAssets.push(mc_desc);
			ModifyState.ModifyState = ModifyState.Modified;
		}
		
		private function AddDesMCtoPanel(mc:CP_Des):void 
		{
			mc.addEventListener("DESDELETE", OnDesDelete);
			mc.addEventListener("DESUP", OnDesUp);
			mc.addEventListener("DESDOWN", OnDesDown);
			mc.addEventListener(Event.REMOVED_FROM_STAGE, OnDesRemoved);
			
			m_assetPanel.addChild(mc);
			mc.x = initX;
			mc.y = currentY;
			currentY += mc.height + offsetY;
			m_scrollBar.refresh();
		}
		
		private function OnDesRemoved(e:Event):void 
		{
			e.currentTarget.removeEventListener("DESDELETE", OnDesDelete);
			e.currentTarget.removeEventListener("DESUP", OnDesUp);
			e.currentTarget.removeEventListener("DESDOWN", OnDesDown);
			e.currentTarget.removeEventListener(Event.REMOVED_FROM_STAGE, OnDesRemoved);
		}
		
		private function OnDesDelete(e:Event):void 
		{
			var mc_desc:CP_Des = e.currentTarget as CP_Des;
			var tIndex:int = m_desAssets.indexOf(mc_desc);
			if (tIndex >= 0)
			{
				m_desAssets.splice(tIndex, 1);
				var oldLength:Number = m_scrollBar.BarLength;
				UpdateDess();
				var newLength : Number = m_scrollBar.BarLength;
				if (newLength > oldLength)//element has been deleted
				{
					m_scrollBar.SetY(oldLength - newLength);
				}
				else
				{
					m_scrollBar.SetTop();
				}
				ModifyState.ModifyState = ModifyState.Modified;
			}
		}
		
		private function OnDesUp(e:Event):void 
		{
			var mc_desc:CP_Des = e.currentTarget as CP_Des;
			var tIndex:int = m_desAssets.indexOf(mc_desc);
			if (tIndex == 0)//1st element
			{
				return;
			}
			else
			{
				var tmp:CP_Des = m_desAssets[tIndex];
				var tmp2:CP_Des = m_desAssets[tIndex-1];
				m_desAssets[tIndex] = tmp2;
				m_desAssets[tIndex - 1] = tmp;
				UpdateDess();
				ModifyState.ModifyState = ModifyState.Modified;
			}
		}
		
		private function OnDesDown(e:Event):void 
		{
			var mc_desc:CP_Des = e.currentTarget as CP_Des;
			var tIndex:int = m_desAssets.indexOf(mc_desc);
			if (tIndex == m_desAssets.length-1)//last element
			{
				return;
			}
			else
			{
				var tmp:CP_Des = m_desAssets[tIndex];
				var tmp2:CP_Des = m_desAssets[tIndex+1];
				m_desAssets[tIndex] = tmp2;
				m_desAssets[tIndex + 1] = tmp;
				UpdateDess();
				ModifyState.ModifyState = ModifyState.Modified;
			}
		}
		
		public function UpdateDess():void 
		{
			ResetAssetPanel();
			for (var i:int = 0; i < m_desAssets.length; i++) 
			{
				var mc_des:CP_Des = m_desAssets[i];
				AddDesMCtoPanel(mc_des);
			}
		}
		
		override protected function UpdateUI(assetListText:String):void 
		{
			//trace("DesListText:" + assetListText);
			var desArray:Array = ExtractDessFromConfig(assetListText);
		    m_desAssets = new Array();
			this.m_InitID = 0;
			for (var i:int = 0; i < desArray.length; i++) 
			{
				var desc:Des = desArray[i];
				var descMC:CP_Des = new CP_Des();
				descMC.Desc = desc;
				descMC.InitID = m_InitID;
				m_InitID++;
				m_desAssets.push(descMC);
			}
			UpdateDess();
		}
		
		private function ExtractDessFromConfig(assetListText:String):Array 
		{
			var doc:XML = new XML(assetListText);
			var desArray:Array = new Array();
			var desList = doc["des"];
			for each (var desXml:XML in desList) 
			{
				var des:Des = new Des();
				des.Type = desXml["type"];
				des.LastTime = desXml["last"];
				des.FileName = desXml["fileName"];
				desArray.push(des);
			}
			return desArray;
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
			this["b_add"].removeEventListener(MouseEvent.CLICK, OnAddClick);
		}
	}

}