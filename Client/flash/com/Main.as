package com {
	
	import com.mc.BaseDes;
	import com.mc.Desvideo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.getDefinitionByName;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;;
	import flash.utils.Timer;
	
	public class Main extends BaseMovie {
		
		
		public function Main() {
			// constructor code
		}
		
		var desContainer:Sprite;
		var activeDes:BaseDes;
		var desTimer:Timer;
		var playListAnalyser:PlayListAnalyser;
		
		var testTimer:Timer;
		var testArray:Array = new Array("3.mp4");
		var testIndex:int = 0;
		
		var isOnlyOneDes:Boolean = false;//是否只有一段描述
		override protected function Init():void 
		{
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			super.Init();
			if (ExternalInterface.available)
			{
				ExternalInterface.addCallback("ChangeDes", ChangeDesList);
				ExternalInterface.addCallback("StopPlay", StopPlay);
			}
			desTimer = new Timer(0);
			desTimer.addEventListener(TimerEvent.TIMER, PlayNextDes)
			
			//test
			//ChangeDesList("0");
			//ChangeDesList("3.mp4");
			//testTimer = new Timer(60*1000);
			//testTimer.addEventListener(TimerEvent.TIMER, OnTestTimer);
			//testTimer.start();
			
			//TestAddVideo();
		}
		
		function TestAddVideo():void
		{
			var player:Desvideo = new Desvideo();
			desContainer = new Sprite();
			this.addChild(desContainer);
			desContainer.addChild(player);
		}
		
		function OnTestTimer(e:Event):void 
		{
			testIndex++;
			if (testIndex > 2)
			{
				testIndex = 0;
			}
			ChangeDesList(testArray[testIndex]);
		}
		
		var currentIndex:int = 0;
		var desCount:int;
		var desTemList:Array;
		var commandVideoName:String = null;
		function ChangeDesList(videoName:String)
		{			
			commandVideoName = videoName;
			RestSetAnalyser();
		}
		
	    function RestSetAnalyser():void 
		{
			playListAnalyser = new PlayListAnalyser("playList.xml");
			playListAnalyser.addEventListener(playListAnalyser.OnAnalyserLoaded, OnAnalyserLoaded);
		}
		
		function OnAnalyserLoaded(e:Event):void 
		{
			playListAnalyser.removeEventListener(playListAnalyser.OnAnalyserLoaded, OnAnalyserLoaded);
			if (commandVideoName != null&&commandVideoName.length!=0)
			{
				//ClearStatge();
				desTemList = GetDesListbyVideoName(commandVideoName);
				desCount = desTemList.length;
				currentIndex = 0;
				//trace("desCount:" + desCount);
				if (desCount == 1)
				{
					isOnlyOneDes = true;
				}
				else
				{
					isOnlyOneDes = false;
				}
				PlayDesbyIndex(currentIndex);
			}
		}
		
		//core func
		public function GetDesListbyVideoName (videoName:String):Array
		{ 
			//return new TestDataCreater().CreateDesList(videoName);
			return playListAnalyser.ExtractVideoDesfromPlayListXML(videoName);
		}
		
		function CreateDesbyTemplete(templete:DesTemplate):BaseDes 
		{
			var des:BaseDes;
			var desName:String = "com.mc.Des" + templete.DesType;
			var temp:Class = getDefinitionByName(desName) as Class;
			des =  new temp() as BaseDes;
			des.ItemsDic = templete.Items;
			return des;
		}
		
		function PlayNextDes(e:TimerEvent):void 
		{
			if (isOnlyOneDes)
			{
				trace("OnlyOneDes,no need to turn page");
				return;
			}
			if (currentIndex < desCount - 1)
            {
                currentIndex++;
            }
            else
            {
                currentIndex = 0;
            }
			PlayDesbyIndex(currentIndex);
		}
		
		var tempContainer:Sprite;
		function PlayDesbyIndex(index:int):void //根据index切换播放内容
		{
			//trace(index);
			desTimer.stop();
			ClearOuterStage();
			var cDesTem:DesTemplate;
			cDesTem = desTemList[currentIndex] as DesTemplate;//将要播放的模板信息
			currentDelay = cDesTem.Duraion;
			var desMC:BaseDes = CreateDesbyTemplete(cDesTem);//加载的模板控件
			if ((desMC as Desvideo)!=null)//video模板，直接加载到舞台中央
			{
				ClearStatge();
				activeDes = desMC;
				desContainer = new Sprite();
				desContainer.addChild(activeDes);
				this.addChild(desContainer);
				if (currentDelay == 0)//不限制时间，完整播放视频
				{
					activeDes.addEventListener(Event.COMPLETE, OnVideoComplete);
					return;
				}
				desTimer.delay = currentDelay*1000;
				desTimer.start();
			}
			else//非video模板，先在舞台外加载完毕，再加载到舞台中央
			{
				desMC.addEventListener(desMC.DesLoaded, OnDesLoaded);
				tempContainer = new Sprite();
				tempContainer.x = -2000;
				tempContainer.y = -2000;
				tempContainer.addChild(desMC);
				this.addChild(tempContainer);
			}
		}
		
		function OnVideoComplete(e:Event):void 
		{
			activeDes.addEventListener(Event.COMPLETE, OnVideoComplete);
			PlayNextDes(null);
		}
		
		var currentDelay:Number = 10;
		function OnDesLoaded(e:Event):void 
		{
			trace("des loaded");
			var tempDes = e.target as BaseDes;//在舞台外加载完毕的模板控件
			if (tempDes != null)
			{
				ClearOuterStage();
				activeDes = tempDes;
				ClearStatge();
				desContainer = new Sprite();
				desContainer.addChild(activeDes);
				this.addChild(desContainer);
				desTimer.delay = currentDelay*1000;
				desTimer.start();
			}
		}
		
		function StopPlay(p:String)
		{
			desTimer.stop();
			ClearStatge();
		}
		
		function ClearStatge():void 
		{
			if (desContainer != null)
			{
				this.removeChild(desContainer);
				desContainer = null;
			}
			
		}
		
		function ClearOuterStage()
		{
			if (tempContainer != null)
			{
				this.removeChild(tempContainer);
				tempContainer = null;
			}
		}
		
		override protected function removed_from_stage(e:Event):void 
		{
			super.removed_from_stage(e);
			desTimer.removeEventListener(TimerEvent.TIMER, PlayNextDes);
			playListAnalyser.removeEventListener(playListAnalyser.OnAnalyserLoaded, OnAnalyserLoaded);
		}
	}
	
}
