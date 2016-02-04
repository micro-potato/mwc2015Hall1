package com.component {
	
	import com.BaseMovie;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	public class VoteResultDisPlayer extends BaseMovie {
		
		public function VoteResultDisPlayer() {
			// constructor code
		}
		
		private var answerTitle:String;
		public function set AnswerTitle(value:String)
		{
			answerTitle = value;
		}
		
		private var percent:int;
		public function set Percent(value:int)
		{
			percent = value;
		}
		
		public function get MaxFrame():Number
		{
			return percent * 3;
		}
		
		override protected function Init():void 
		{
			super.Init();
			if (this.title.length>0)
			{
				//trace("answerTitle:"+answerTitle);
				this["title"].text = answerTitle;
				//this["percentText"].text = ((percent * 100) * 1 / 1).toString() + "%";
				this["percentText"].text = percent.toString() + "%";
				this.addEventListener(Event.ENTER_FRAME, CheckLoadedPercent);
			}
		}
		
		function CheckLoadedPercent(e:Event):void 
		{
			//trace("wk:" + this.currentFrame + "---" + MaxFrame+"--"+this);
			if (this.currentFrame >= MaxFrame)
			{
				//trace("percent loaded");
				this.gotoAndStop(MaxFrame);
				this.removeEventListener(Event.ENTER_FRAME, CheckLoadedPercent);
			}
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
		}
	}
	
}
