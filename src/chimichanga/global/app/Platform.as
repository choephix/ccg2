package chimichanga.global.app
{
	import flash.system.Capabilities;
	
	
	public class Platform
	{
		
		public static function isIOS():Boolean
		{
			return Capabilities.manufacturer.indexOf( "iOS" ) > -1;
		}
	
	}

}