package com 
{
	/**
	 * ...
	 * @author LY
	 */
	public class TestDataCreater 
	{
		
		public function TestDataCreater() 
		{
			
		}
		
		public function CreateDesList(videoName:String):Array
		{
			var temArray:Array = new Array();
			var t1:DesTemplate = new DesTemplate();
			t1.DesType = "1";
			t1.Duraion = 2000;
			
			var t2:DesTemplate = new DesTemplate();
			t2.DesType = "2";
			t2.Duraion = 2000;
			
			var t3:DesTemplate = new DesTemplate();
			t3.DesType = "3";
			t3.Duraion = 2000;
			
			temArray.push(t1, t2,t3);
			
			return temArray;
		}
		
	}

}