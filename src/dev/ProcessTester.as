package dev 
{
	import duel.processes.Process;
	import duel.processes.ProcessEvent;
	import duel.processes.ProcessManager;
	/**
	 * ...
	 * @author choephix
	 */
	public class ProcessTester 
	{
		
		public static function initTest1( manager:ProcessManager ):void
		{
			var proN:int = 0;
			function pro():Process { 
				var p:Process = ProcessManager.gen( "TEST #" + (++proN) );
				return p;
			}
			manager.appendProcess( pro() );
			manager.appendProcess( pro() );
			manager.appendProcess( pro() );
			manager.appendProcess( pro() );
			manager.appendProcess( pro() );
			manager.appendProcess( pro() );
			manager.appendProcess( pro() );
			
			var interruptions_left:int = 20;
			manager.addEventListener( ProcessEvent.CURRENT_PROCESS, onP );
			function onP( e:ProcessEvent ):void
			{
				if ( interruptions_left > 0 )
				{
				  interruptions_left--;
				  e.process.interrupt();
				}
			}
		}
		
	}

}