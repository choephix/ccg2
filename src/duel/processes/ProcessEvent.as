package duel.processes 
{
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class ProcessEvent extends Event 
	{
		static public const CURRENT_PROCESS:String = "process";
		
		public var process:Process;
		
		public function ProcessEvent( type:String, bubbles:Boolean=false, data:Object=null ) 
		{
			super( type, bubbles, data );
		}
	}
}