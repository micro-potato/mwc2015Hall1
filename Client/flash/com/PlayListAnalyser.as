package com 
{
	import adobe.utils.CustomActions;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author LY
	 */
	public class PlayListAnalyser extends EventDispatcher
	{
		var xmlHelper:XMLHelper;
		public const OnAnalyserLoaded:String = "OnAnalyserLoaded";
		public function PlayListAnalyser(playListPath:String) 
		{
			xmlHelper = new XMLHelper(playListPath, true);
			xmlHelper.addEventListener(xmlHelper.XMLLoadedEvent, OnXMLLoaded);
		}
		
		function OnXMLLoaded(e:Event):void 
		{
			var doc:XML = xmlHelper.doc;
			var videos:XMLList = doc["video"];
			if (videos.length()==0)//no video
			{
				AdaptePlayList();
			}
			this.dispatchEvent(new Event(this.OnAnalyserLoaded));
			//trace("OnAnalyserLoaded");
		}
		
		function AdaptePlayList():void//将不含video的配置文件改写为可以解析播放的形式
		{
			var doc:XML = xmlHelper.doc;
			var desList:XMLList = doc["des"];
			var newDoc:String = "";
			newDoc += "<data>\r\n<video>\r\n<fileName>0</fileName>\r\n";
			for each (var item:XML in desList) 
			{
				newDoc += item+"\r\n";
			}
			newDoc += "</video>\r\n</data>";
			//trace(newDoc);
			xmlHelper = new XMLHelper(newDoc, false);
		}
		
		function ExtractVideoDesfromPlayListXML(videoName:String):Array 
		{
			var vdArray:Array = new Array();
			//trace(xmlHelper.doc);
			var videos:Array = xmlHelper.GetNodesXMLStringbyName("video");
			//trace(videos[0]);
			var checkVideoPara:String;
			for (var i:int = 0; i < videos.length; i++) 
			{
				checkVideoPara = videos[i];
				//trace(GetValueFromPara(checkVideoPara, "filename"));
				if (GetValueFromPara(checkVideoPara,"fileName") == videoName)
				{
					break;
				}
			}
			//trace("videopara:"+checkVideoPara);
			if (checkVideoPara.length > 0)
			{
				var dess :Array=new XMLHelper(checkVideoPara,false).GetNodesXMLStringbyName("des");
				//trace(dess[0]);
				for (var j:int = 0; j <dess.length ; j++) 
				{
					//trace(dess[j]);
					var desDic:Dictionary = new XMLHelper(dess[j],false).GetNodeNameInnerTextDic();
					//trace(desDic["last"]);
					var desTemplate:DesTemplate = new DesTemplate();
					desTemplate.Items = desDic;
					vdArray.push(desTemplate);
				}
			}
			return vdArray;
		}
		
		function GetValueFromPara(para:String,nodeName:String):String 
		{
			var temp:String = para.substring(para.indexOf("<" + nodeName + ">"), para.indexOf("</" + nodeName + ">"));
			//trace("temp:"+temp);
			var temp2:String = temp.replace("<" + nodeName + ">", "");
			//trace(temp2);
			return temp2.replace("/<" + nodeName + ">", "");
		}
	}

}