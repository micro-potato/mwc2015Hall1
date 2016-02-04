package com 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import com.adobe.serialization.json.JSON;
	import flash.utils.*;
	/**
	 * ...
	 * @author LY
	 */
	public class VoteHelper extends EventDispatcher
	{
		public const OnVoteResultUpdated:String = "OnVoteResultUpdated";
		
		var voteUrl:String;
		var voteQuestion:String;
		var topic:String;
		var answers:Object;
		var xmlHelper:XMLHelper;
		var answerCount:int;//总投票数
		var localVoteXml:XMLHelper;
		var localVoteConfigPath = "vote.xml";
		private var uiItem:VoteUIItem;
		
		public function get Answers():Object
		{
			return answers;
		}
		
		//回答总数
		public function get AnswerCount():int
		{
			return answerCount;
		}
		
		public function get UIItem():VoteUIItem
		{
			return uiItem;
		}
		
		public function VoteHelper(url:String,question:String) 
		{
			voteUrl = url;
			voteQuestion = question;
			 var loader:URLLoader = new URLLoader();
			loader.load(new URLRequest(url));//获取投票的网址
			loader.addEventListener(Event.COMPLETE, BegintoAnalyse);
		}
		
		function BegintoAnalyse(evt:Event):void 
		{
			var jsdata:String = (evt.target ).data;
			AnalyseVoteData(jsdata);
			BeginAnalyseLocalVoteData();
			GetVoteUIItem(); 
			//PrintVoteData(jsdata);//打印问题回答集，仅测试用
		}
		
		//////////////////////////////////////////////////////本地投票结果处理//////////////////////////////////////////////////////////
		function OnLocalXMLLoaded(e:Event):void 
		{
			AnalyseLocalVoteData();
		}
		//解析本地xml投票结果,累加投票结果
		function BeginAnalyseLocalVoteData():void 
		{
			localVoteXml = new XMLHelper(localVoteConfigPath, true);
			localVoteXml.addEventListener(localVoteXml.XMLLoadedEvent, OnLocalXMLLoaded);
		}
		
		function AnalyseLocalVoteData():void 
		{
			var localAnswers:Object = GetLocalAnswersDic();
			for (var k:String in localAnswers) {
				try
				{
					var localVoteCount:int = localAnswers[k];
					var remoteCount:int = answers[k];
					var collectCount:int = localVoteCount + remoteCount;
					answers[k] = collectCount;
					answerCount += localVoteCount;
				}
				catch (e:Error)
				{
					trace("local vote analyse error:" + e.message);
					continue;
				}
			}
		}
		
		function GetLocalAnswersDic():Object 
		{
			//test
			//var localVote:Object = new Object();
			//localVote["To provide ubiquitous mobile connections, including M2M communications"] = 0;
			//localVote["To cope with the rapid growth of mobile data traffic"] = 2;
			//return localVote;
			
			var localVote:Object = new Object();
			var question:String = this.voteQuestion;
			//trace("question:" + question);
			var votepara:String=localVoteXml.GetNodesInnerXmlbyNodeNameandAttribute("question", "desc", question)[0];//包含问题的xml
			var qXml:XMLHelper = new XMLHelper(votepara, false);
			
			for (var k:String in answers) {
				try
				{
					trace("answers:" + k + "	" + answers[k]);
					
					var answerPara:String = qXml.GetNodesInnerXmlbyNodeNameandAttribute("answer", "desc", k.replace("<", "&lt"))[0];//一个回答的xml
					//var answerPara:String = qXml.GetNodesInnerXmlbyNodeNameandAttribute("answer", "desc", k)[0];//一个回答的xml
					trace("answerPara==null?:" + answerPara);
					//trace("answerPara:" + answerPara.substring(answerPara.lastIndexOf('=')+1));
					var localVoteCount:int = int(((answerPara.substring(answerPara.lastIndexOf('=')+1).replace("\"","")).replace("\"/>","")));//截取回答投票数
					//trace(k + "  localVoteCount:" + localVoteCount);
					localVote[k] = localVoteCount;
				}
				catch (e:Error)
				{
					trace("read local xml error:" + e.message);
					continue;
				}
			}
			return localVote;
		}
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		//解析josn投票结果
		function AnalyseVoteData(jsdata):void 
		{
			//trace(jsdata);
			this.answerCount = 0;
			 var vote = com.adobe.serialization.json.JSON.decode(jsdata, true);
			 var state = vote.statusCode;
			 var results = vote.result;//结果集合
			 var rLenght = results.length;
			 for (var i:int = 0; i < rLenght; i++) 
			 {
				 var result = results[i];
				 var topics = result.topics;
				 var tLength = topics.length;
				 for (var j:int = 0; j < tLength; j++) //遍历topics
				 {
					 var topic = topics[j];
					 var questions = topic.questions;
					 var qLength = questions.length
					 for (var k:int = 0; k < qLength; k++)  //遍历questions
					 {
						 var question = questions[k];
						 var questionText = question.question;
						 //trace("questionText:" + question.question);
						 if (questionText != this.voteQuestion)
						 {
							 continue;
						 }
						 else//找到匹配的问题
						 {
							 //trace("find question");
							 this.topic = topic.topic;
							 var ansPairs:Object = new Object();
							 var answers = question.answers;
							 var aLength = answers.length;
							 for (var l:int = 0; l < aLength; l++) 
							 {
								 var answer = answers[l];
								 var num:Number = answer.num;
								 this.answerCount += num;
								 var answerText:String = answer.name;
								 ansPairs[answerText] = num;
							 }
							 this.answers = ansPairs;
							 return;
						 }
					 }
				 }
			 }
		}
		
		//test:打印投票结果，仅测试使用
		function PrintVoteData(jsdata):void 
		{
			//trace(jsdata);
			this.answerCount = 0;
			 var vote = com.adobe.serialization.json.JSON.decode(jsdata, true);
			 var state = vote.statusCode;
			 var results = vote.result;//结果集合
			 var rLenght = results.length;
			 for (var i:int = 0; i < rLenght; i++) 
			 {
				 var result = results[i];
				 var topics = result.topics;
				 var tLength = topics.length;
				 for (var j:int = 0; j < tLength; j++) //遍历topics
				 {
					 var topic = topics[j];
					 var questions = topic.questions;
					 var qLength = questions.length
					 for (var k:int = 0; k < qLength; k++)  //遍历questions
					 {
						 var question = questions[k];
						 var questionText = question.question;
						 trace("Question:" + question.question);
						 this.topic = topic.topic;
						 var ansPairs:Object = new Object();
						 var answers = question.answers;
						 var aLength = answers.length;
						 for (var l:int = 0; l < aLength; l++) 
						 {
							 var answer = answers[l];
							 var num:Number = answer.num;
							 this.answerCount += num;
							 var answerText:String = answer.name;
							 trace("					Answer:" + answerText);
							 ansPairs[answerText] = num;
						 }
						 this.answers = ansPairs;
						 continue;
					 }
				 }
			 }
		}
		
		//根据问题所在的topic确定显示效果
		function GetVoteUIItem():void 
		{
			uiItem = new VoteUIItem();
			uiItem.addEventListener(uiItem.ConfigLoaded, GetTopicMode);
			trace("topic---" + topic);
		}
		
		function GetTopicMode(e:Event):void 
		{
			uiItem.LoadUIGroup(topic);
			this.dispatchEvent(new Event(this.OnVoteResultUpdated));
		}
	}
}