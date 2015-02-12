package other 
{
	import starling.core.Starling;
	import starling.events.KeyboardEvent;
	/**
	 * ...
	 * @author choephix
	 */
	public class Input 
	{
		public static var ctrl:Boolean;
		public static var shift:Boolean;
		public static var alt:Boolean;
		
		static public function initialize():void 
		{
			Starling.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, update );
			Starling.current.stage.addEventListener( KeyboardEvent.KEY_UP, update );
		}
		
		static private function update( e:KeyboardEvent ):void 
		{
			ctrl = e.ctrlKey;
			shift = e.shiftKey;
			alt = e.altKey;
		}
		
	}

}