package com 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.media.SoundTransform;
	/**
	 * ...
	 * @author 
	 */
	public class MoviePlayer extends MovieClip
	{
		//影片属性
		private var nc:NetConnection;
		private var ns:NetStream;
		private var video:Video;
		
		private var nowTime:Number;
		private var totalTime:Number;//影片时长
		
	
		//
		private var partList:Array ;
		
		
		private var path:String;
		
		public function MoviePlayer(_path:String,_partList:Array) 
		{
			this.path = _path;
			this.partList = _partList;
			this.addEventListener(Event.ADDED_TO_STAGE, added_to_stage);
		}
		
		private function added_to_stage(e:Event):void 
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, added_to_stage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removed_from_stage);
			Init();
		}
		
		private function Init():void 
		{
			//加载并播放影片
			video = new Video();
			nc = new NetConnection();
			nc.connect(null);
			ns = new NetStream(nc);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			ns.addEventListener(NetStatusEvent.NET_STATUS,stream_statusHandle);
			
			var obj:Object = new Object();
			ns.client = obj;
			obj.onMetaData = streamInfo;
			
			ns.play(path);
			video.attachNetStream(ns);
			this.addChild(video);	
			
			video.width = 1920;
			video.height = 1080;
			//trace("video add");
		}
		
		private function streamInfo(info:Object):void 
		{
			totalTime = info.duration;
		}
		
		private function asyncErrorHandler(e:AsyncErrorEvent):void 
		{
			trace("error");
		}
		
		private var percent:Number;
		public function get Percent():Number 
		{
			
			percent = ns.time / totalTime;
			if (percent.toString() != "NaN")
			{
				return percent;
			}
			return 0;
		}
		
		public function set Percent(_percent:Number):void 
		{
			nowTime = totalTime * _percent;
			ns.seek(nowTime);
			if (isplay)
			{
				ns.resume();
			}
			else 
			{
				ns.pause();
			}
		}
		
		
		private var isplay:Boolean = true;
		public function get IsPlay():Boolean
		{
			return isplay;
		}
		public function set IsPlay(_isplay:Boolean):void 
		{
			isplay = _isplay;
			if (isplay)
			{
				ns.resume();
			}
			else
			{
				ns.pause();
			}
		}
		
		//快进
		public function Advance():void 
		{
			ns.seek(ns.time + 2 > totalTime?totalTime:ns.time + 2);
			if (IsPlay)
			{
				ns.resume();
			}
			else
			{
				ns.pause();
			}
		}
		
		//快退
		public function Retreat():void 
		{
			ns.seek(ns.time-2 > 0?ns.time-2:0);
			if (IsPlay)
			{
				ns.resume();
			}
			else
			{
				ns.pause();
			}
		}
		
		public function get PartIndex():int
		{
			var index:int = getPartIndex();
			return index;
		}
		
		public function set PartIndex(_index:int):void 
		{
			ns.seek(partList[_index]);
		}
		
		private function getPartIndex():int 
		{
			var index:int = -1;
			for (var i:int = partList.length - 1; i >= 0; i--)
			{
				if (ns.time>= partList[i]-1.5)
				{
					return i;
				}
			}
			
			return index;
		}
		
		//重播
		public function Replay():void 
		{
			ns.seek(0);
			IsPlay = true;
			
		}
		
		public function set Volume(_volume:Number):void 
		{
			var san:SoundTransform = ns.soundTransform;
			san.volume = _volume;
			ns.soundTransform = san;
		}
		
		private function stream_statusHandle(event:NetStatusEvent):void
		{
			switch(event.info.code)
			{
				case "NetStream.Play.StreamNotFound":
				  trace("没有发现可播放的视频流"  );
				  break;
				 case "NetStream.Play.Failed":
				 trace("Error");
				 break;
				 case "NetStream.Play.Stop":
				 trace("视频播放结束");
				 playComplete();
				 break;
			}
		}
		
		private function playComplete():void 
		{
			ns.seek(0);
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function removed_from_stage(e:Event):void 
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removed_from_stage);
			ns.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			ns.removeEventListener(NetStatusEvent.NET_STATUS, stream_statusHandle);
			ns.close();
			video.clear();
			this.Volume = 0;
		}
		
	}

}