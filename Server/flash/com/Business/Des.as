package com.Business 
{
	/**
	 * ...
	 * @author LY
	 */
	public class Des 
	{
		public const PicType:String = "pic";
		public const VideoType:String = "video";
		
		public var Type:String;
		public var LastTime:String="30";
		public var FileName:String="pic.jpg";
		public var Text:String;
		public function Des() 
		{
			
		}
		
		//Create XML string by fileName&LastTime
		public function CreateText():String
		{
			if (FileName == null)//invalidate config
			{
				return "";
			}
			else
			{
				Text = "<des>\r\n";
				Text += "<type>" + this.Type + "</type>\r\n";//add type
				Text += "<last>" + this.LastTime.toString() + "</last>\r\n";//add LastTime
				Text += "<fileName>" + this.FileName + "</fileName>\r\n";//add FileName
				Text += "</des>\r\n";
				return Text;
			}
		}
		
	}

}