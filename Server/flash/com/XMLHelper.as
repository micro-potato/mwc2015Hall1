package com
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.xml.XMLNode;
	import XML;
	public class  XMLHelper extends EventDispatcher
	{
		public static function GetXmlFromPara(para:String):XML
		{
			return new XML("<?xml version=\"1.0\" encoding=\"UTF-8\"?><alarmlist>" + para + "</alarmlist>");
		}
		
		private var doc:XML;
		public const XMLLoadedEvent:String = "XMLLoaded";
		public function XMLHelper(path:String,isFromExternal:Boolean)
		{
			if (isFromExternal)
			{
			var request:URLRequest = new URLRequest(path);
			var loader:URLLoader = new URLLoader(request);
			loader.addEventListener(Event.COMPLETE, On_loadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, On_Error);
			loader.load(request);
			}
			else
			{
				doc = new XML(path);
			}
		}
		
		public function get Doc():XML
		{
			return doc;
		}
		
		private function On_loadComplete(e:Event)
		{
			//trace("XMLLoadedEvent");
			doc = new XML(e.target.data);
			//EventMaster.getInstance().dispatchEvent(new Event(EventMaster.getInstance().XMLLoaded));
			//trace(doc);
			this.dispatchEvent(new Event(this.XMLLoadedEvent));
		}
		
		public function get XMLDoc():XML
		{
			return doc;
		}
		
		public function GetNodesXMLStringbyName(name:String):Array
		{
			var array:Array = new Array();
			for each (var node:XML in doc.elements())
			{
				if (node.name() == name)
				{
					array.push(node.toXMLString());
				}
			}
			return array;
		}
		
		function GetNodeNameInnerTextDic():Dictionary 
		{
			var dic:Dictionary = new Dictionary();
			for each (var node:XML in doc.elements())
			{
				dic[node.name()] = node.text();
			}
			return dic;
		}
		
		public static function GetNodesXMLStringbyNameFromXMLPara(xmlPara:String,name:String):Array
		{
			var xmlDoc:String = GetXmlDocFromXMLPara(xmlPara);
			//trace(xmlDoc);
		    var doc:XML = new XML(xmlDoc);
			var array:Array = new Array();
			for each (var node:XML in doc.elements())
			{
				if (node.name() == name)
				{
					array.push(node.toXMLString());
				}
			}
			return array;
		}
		
		public static function GetXmlDocFromXMLPara(xmlPara:String):String 
		{
			return "<root>\r\n" + xmlPara + "\r\n</root>";
		}
		
		///第level个节点下名为nodeName节点的值
		public function GetNodeValue(level:int,nodeName:String):String
		{
			var tempDoc:XMLList=new XMLList(doc);
			for (var i:int = 0; i < level; i++)
			{
				tempDoc = doc.children();
			}
			return tempDoc[nodeName];
		}
		
		public function GetValuebyArray(array:Array):String
		{
			var currentDoc:XMLList = new XMLList(doc);
			for (var i:int = 0; i < array.length; i++)
			{
				var list:XMLList = currentDoc[array[i]];
				currentDoc = list;
			}
			return list.toString();
		}
		
		private function On_Error(e:Event)
		{
			trace("Error");
		}
		
		//获取nodeName节点下属性为attribute的innerXml
		public function GetNodesInnerXmlbyNodeNameandAttribute(nodeName:String, attributeName:String,attributeValue:String):Array
		{
			var array:Array = new Array();
			for each (var node:XML in doc.elements())
			{
				if (node.name() == nodeName &&node.@[attributeName]==attributeValue)
				{
					//trace(node.toXMLString());
					array.push(node.toXMLString());
				}
			}
			return array;
		}
		
		public function GetAttributeValue(nodeName:String,attributeName:String):String
		{
			//trace("doc:" + doc);
			return doc[nodeName].@[attributeName];
		}
	}
	
}