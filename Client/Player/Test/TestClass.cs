using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NUnit.Framework;
using Helpers;

namespace Test
{
    [TestFixture]
    public class TestClass
    {
        [TestCase]
        public void UpdateAllContentTest()
        {
            string content = string.Format(@"<content>
  <video>
    <filename>test1.mp4</filename>
    <des>
      <type>1</type>
      <last>5</last>
    </des>
    <des>
      <type>2</type>
      <last>5</last>
    </des>
  </video>
  <video>
    <filename>test2.mp4</filename>
    <des>
      <type>1</type>
      <last>5</last>
    </des>
    <des>
      <type>2</type>
      <last>5</last>
    </des>
  </video>
</content>");
            XmlHelper.CreateXmlDoc(content,@"F:\Project\2014巴展品牌Hall1多媒体导播系统\Client\Player\Player\bin\Debug\playlist.xml");
            //xmlHelper.UpdateAllContent(content);
        }
    }
}
