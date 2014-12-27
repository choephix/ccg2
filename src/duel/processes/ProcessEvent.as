package duel.processes 
{
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class ProcessEvent extends Event 
	{
		static public const PROCESS:String = "process";
		static public const COMPLETE_ALL:String = "completeAll";
		
		public var processName:String;
		public var processArgs:Array;
		
		public function ProcessEvent( type:String, bubbles:Boolean=false, data:Object=null ) 
		{
			super( type, bubbles, data );
		}
	}
}