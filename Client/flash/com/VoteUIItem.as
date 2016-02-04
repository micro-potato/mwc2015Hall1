package com 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author LY
	 */
	public class VoteUIItem extends EventDispatcher
	{
		var isModeDataReady:Boolean = false;
		var configPath:String = "topicmode.xml";
		var xmlHelper:XMLHelper;
		public const ConfigLoaded:String = "ConfigLoaded";
		public function VoteUIItem() 
		{
			xmlHelper = new XMLHelper(configPath,true);
			xmlHelper.addEventListener(xmlHelper.XMLLoadedEvent, DataReady);
		}
		
		function DataReady(e:Event):void 
		{
			isModeDataReady = true;
			this.dispatchEvent(new Event(ConfigLoaded));
		}
		
		private var questionTextColor:uint;
		public function get QuestionTextColor(): uint
		{
			return questionTextColor;
		}
		
		private var voteUINo:int;
		public function get VoteUINo():int
		{
			return voteUINo;
		}
		
		public function LoadUIGroup(topic:String)
		{
			SetUiByTopic(topic);
		}
		
		function SetUiByTopic(topic:String):void 
		{
			try
			{
				voteUINo = GetTopicUINumber(topic);
				trace("Get voteUINo:" + voteUINo);
			}
			catch (e:Error)
			{
				trace("未能获得topic的UI样式：" + e.message);
				voteUINo = 1;
			}
			switch (voteUINo)
			{
				case 1:
					questionTextColor = 0xED1C24;
					break;
				case 2:
					questionTextColor = 0x2F4D68;
					break;
				case 3:
					questionTextColor = 0x435D6C;
					break;
				case 4:
					questionTextColor = 0xA9AE1C;
					break;
				default:
					voteUINo = 1;
					questionTextColor = 0xED1C24;
					break;
			}
		}
		
		function GetTopicUINumber(topic:String):int 
		{
			trace("Topic to get mode:" + topic);
			var xmlPara = xmlHelper.GetNodesInnerXmlbyNodeNameandAttribute("topic", "desc", topic)[0];
			trace("topicPara:" + xmlPara);
			var tempXml:XMLHelper = new XMLHelper("<data>\r\n" + xmlPara + "</data>\r\n",false);
			var id:int = int(tempXml.GetAttributeValue("topic", "modeid"));
			return id;
		}
	}
}