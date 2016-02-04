package com.Business 
{
	/**
	 * ...
	 * @author LY
	 */
	public class ScreenPairInfo 
	{
		public const Left:String = "left";
		public const Right:String = "right";
		
		private var pairNo:uint;
		private var hasConnection:Boolean;
		private var selectedPart:String;
		private var groupNo:uint;
		
		public function get PairNo():uint
		{
			return pairNo;
		}
		public function set PairNo(value:uint):void
		{
			pairNo = value;
		}
		
		public function get LeftScreenNo():uint
		{
			return pairNo*2-1;
		}
		
		public function get RightScreenNo():uint
		{
			return pairNo*2;
		}
		
		public function get HasConnection():Boolean
		{
			return hasConnection;
		}
		public function set HasConnection(value:Boolean)
		{
			hasConnection=value;
		}
		
		public function get SelectedPart():String
		{
			return selectedPart;
		}
		public function set SelectedPart(value:String)
		{
			selectedPart=value;
		}
		
		public function get GroupNo():uint
		{
			return groupNo;
		}
		public function set GroupNo(value:uint)
		{
			groupNo=value;
		}
		
		public function ScreenPairInfo() 
		{
			
		}
		
	}

}