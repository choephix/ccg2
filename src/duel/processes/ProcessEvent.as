package duel.processes 
{
	import starling.events.Event;
	
	
	public class ProcessEvent extends Event 
	{
		static public const CURRENT_PROCESS:String = "process";
		static public const PROCESS_COMPLETE:String = "processComplete";
		static public const PROCESS_ABORTED:String = "processAborted";
		
		public var process:Process;
		
		public function ProcessEvent( type:String, bubbles:Boolean=false, data:Object=null ) 
		{
			super( type, bubbles, data );
		}
	}
}