package com {
	
	import com.customEvent.ExternalCmdEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	
	public class Main extends BaseMovie {
		
		private var configPath:String = "config.xml";
		private var m_xml:XMLHelper;
		public static var Instace:Main;
		public function Main() {
			// constructor code
		}
		
		override protected function Init():void 
		{
			super.Init();
			Instace = this;
			m_xml = new XMLHelper(configPath, true);
			m_xml.addEventListener(m_xml.XMLLoadedEvent, OnXMLLoaded);
			if (ExternalInterface.available)
			{
				ExternalInterface.addCallback("datain", OnDataIn);
			}
		}
		
		private function OnXMLLoaded(e:Event):void 
		{
			try
			{
				m_xml.removeEventListener(m_xml.XMLLoadedEvent, OnXMLLoaded);
				var assetFolder:String = m_xml.GetNodeValue(0, "AssetFolder");
				MConfig.AssetFolder = assetFolder;
				//AppendLog("AssetFolder:" + assetFolder);
			}
			catch(err:Error)
			{
				trace("get assetFolder error:" + err.message);
			}
			
		}
		
		private function OnDataIn(datain:String):void 
		{
			var fun:String = datain.substring(0, datain.indexOf(':'));
			var arg:String = datain.substring(datain.indexOf(':')+1);
			var event:ExternalCmdEvent = new ExternalCmdEvent(fun);
			event.arg = arg;
			EventMaster.getInstance().dispatchEvent(event);
			//this.AppendLog("datain:" + datain);
		}
		
		public function SendMsgtoWin(fun:String,arg:String)
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.call(fun, arg);
				//this.AppendLog("Send to win:" + fun + "	" + arg);
			}
		}
		
		public function AppendLog(log:String)
		{
			this["txt_log"].AppendLog(log);
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
		}
	}
	
}
