package com.mc 
{
	import com.component.VoteResultDisPlayer;
	import com.VoteHelper;
	import com.XMLHelper;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import com.DesItemNames;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author LY
	 */
	public class Desvote extends BaseDes 
	{
		
		public function Desvote() 
		{
			
		}
		
		var voteUrl:String;
		var question:String;
		var answers:Object;
		var voteHelper:VoteHelper
		var xmlHelper:XMLHelper;
		
		override protected function Init():void 
		{
			super.Init();
			trace("desvote added");
			xmlHelper = new XMLHelper("config.xml", true);
			xmlHelper.addEventListener(xmlHelper.XMLLoadedEvent, VoteUrlLoaded);
		}
		
		function VoteUrlLoaded(e:Event):void 
		{
			xmlHelper.removeEventListener(xmlHelper.XMLLoadedEvent, VoteUrlLoaded);
			LoadVoteResult();
		}
		
		function LoadVoteResult():void 
		{
			//trace("load");
			voteUrl = xmlHelper.GetNodeValue(0, "voteurl");
			//trace(this.itemsDic[DesItemNames.iQuestion]);
			question = this.itemsDic[DesItemNames.iQuestion];
			voteHelper = new VoteHelper(voteUrl, question);
			voteHelper.addEventListener(voteHelper.OnVoteResultUpdated, UpdatedVoteResult);
		}
		
		function UpdatedVoteResult(e:Event):void 
		{
			//trace("complete");
			voteHelper.removeEventListener(voteHelper.OnVoteResultUpdated, UpdatedVoteResult);
			answers = voteHelper.Answers;
			DisPlayVoteResult();
			this.dispatchEvent(new Event(this.DesLoaded));
		}
		
		//显示投票结果
		function DisPlayVoteResult():void 
		{
			//test
			this["questionText"].text = question;
			trace("questionText:" + question);
			this["questionText"].textColor = voteHelper.UIItem.QuestionTextColor;
			var voteIndex = 0;
			var maxWidht = 1920;
			//trace("voteHelper.AnswerCount:" + voteHelper.AnswerCount);
			
			//显示问题的回答
			var initX:Number = 173;
			var initY:Number = 230;
			var offset:Number = 200;
			for(var k:String in answers) {
				var voteCount:int = answers[k];
				var votePercent = voteCount / voteHelper.AnswerCount;
				var title:String = k;
				trace(title+"		"+voteCount);
				
				var voteMC:VoteResultDisPlayer = GetDisPlayer();
				voteMC.AnswerTitle = title;
				voteMC.x = initX;
				voteMC.y = voteIndex  * offset + initY;
				voteMC.Percent = Math.round(votePercent*100);
				voteMC.AnswerTitle = title;
				//trace("add progress");
				this.addChild(voteMC);
				voteIndex++;
			}
		}
		
		//获得投票结果界面
		function GetDisPlayer():VoteResultDisPlayer 
		{
			var index = voteHelper.UIItem.VoteUINo;
			var des:VoteResultDisPlayer;
			var desName:String = "com.component.VoteResultDisPlayer" + index;
			var temp:Class = getDefinitionByName(desName) as Class;
			des =  new temp() as VoteResultDisPlayer;
			return des;
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
		}	
	}
}