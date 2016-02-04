package com.Business 
{
	import com.component.BaseScreenPair;
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author LY
	 */
	public class GroupCalc 
	{
		public static function GroupNo(pairPanel:MovieClip, pairInfo:ScreenPairInfo):uint
		{
			var groupNo:uint;
			var existGroups:uint = GetExistGroups(pairPanel,pairInfo.PairNo);
			if (pairInfo.HasConnection)//2屏1组
			{
				groupNo= existGroups + 1;
			}
			else//2屏2组
			{
				if (pairInfo.SelectedPart == pairInfo.Left)//选择左屏
				{
					groupNo= existGroups + 1;
				}
				else//选择右屏
				{
					groupNo= existGroups + 2;
				}
			}
			return groupNo;
		}
		
		private static function GetExistGroups(pairPanel:MovieClip,pairNo:uint):uint 
		{
			var existGroup:uint = 0;
			for (var i:int = 1; i < pairNo; i++) 
			{
				var sp:BaseScreenPair = pairPanel["p_" + i.toString()];
				sp.PairInfo.HasConnection == true?existGroup += 1:existGroup += 2;
			}
			return existGroup;
		}
		
		public function GroupCalc() 
		{
			
		}	
		
	}

}