package com.component 
{
	import com.BaseMovie;
	import com.Business.ScreenPairInfo;
	import com.customEvent.ScreenPairEvent;
	import com.EventMaster;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author LY
	 */
	public class BaseScreenPair extends BaseMovie
	{
		public const Left:String = "left";
		public const Right:String = "right";
		protected var info:ScreenPairInfo;
		
		public function get PairInfo():ScreenPairInfo
		{
			return info;
		}
		
		public function BaseScreenPair() 
		{
			
		}
		
		override protected function Init():void 
		{
			super.Init();
			this.buttonMode = true;
			InitInfo();
			this.addEventListener(MouseEvent.CLICK, OnPairClick);
		}
		
		public function CancelConnection():void 
		{
			this["connection"].visible = false;
			InitInfo();
		}
		
		private function OnPairClick(e:MouseEvent):void 
		{
			var x:Number = e.localX;
			if (x <= this.width / 2)
			{
				info.SelectedPart = this.Left;
			}
			else
			{
				info.SelectedPart = this.Right;
			}
			OnPairClicked();
		}
		
		protected function OnPairClicked():void 
		{
			
		}
		
		private function InitInfo():void 
		{
			info = new ScreenPairInfo();
			var pairNo:uint = this.name.split('_')[1];
			info.PairNo = pairNo;
			var connec:MovieClip = this["connection"] as MovieClip;
			info.HasConnection = connec.visible == true?true:false;
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
			this.removeEventListener(MouseEvent.CLICK, OnPairClick);
		}
	}
}