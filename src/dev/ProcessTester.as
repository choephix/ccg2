package dev 
{
	import duel.processes.GameplayProcess;
	import duel.processes.GameplayProcessManager;
	import duel.processes.ProcessEvent;
	import duel.processes.ProcessManager;
	
	
	public class ProcessTester 
	{
		
		public static function initTest1( manager:ProcessManager ):void
		{
			var proN:int = 0;
			var p:GameplayProcess;
			
			function pro( func:Function = null ):GameplayProcess
			{ return GameplayProcessManager.gen( "TEST #" + (++proN), func ) }
			
			p = pro();
			manager.prependProcess( p );
			
			p = p.chain( pro() );
			p = p.chain( pro() );
			p = p.chain( pro() );
			p = p.chain( pro() );
			p = p.chain( pro() );
			p = p.chain( pro() );
			p = p.chain( pro() );
			p = p.chain( pro() );
			
			var interruptions_left:int = 2;
			manager.addEventListener( ProcessEvent.CURRENT_PROCESS, onP );
			function onP( e:ProcessEvent ):void
			{
				if ( e.process.name != "TEST #5" )
					return;
				
				interruptions_left--;
				e.process.interrupt();
				
				var p:GameplayProcess = GameplayProcessManager.gen( "declare interruption" );
				manager.prependProcess( p );
				
				p = p.chain( GameplayProcessManager.gen( "think a bit about interruption" ) );
				p = p.chain( GameplayProcessManager.gen( "find resolve for interruption" ) );
				p = p.chain( GameplayProcessManager.gen( "digress a bit to questions about nature, life and our place in the universe" ) );
				p = p.chain( GameplayProcessManager.gen( "take a quick piss" ) );
				p = p.chain( GameplayProcessManager.gen( "perform interruption", function():void { trace("INTERRUPTED, BITCH!") } ) );
				p = p.chain( GameplayProcessManager.gen( "complete interruption" ) );
				
				if ( interruptions_left <= 0 )
					manager.removeEventListener( ProcessEvent.CURRENT_PROCESS, onP );
			}
		}
		
		public static function initTest2( manager:ProcessManager ):void
		{
			var proN:int = 0;
			function pro():GameplayProcess { 
				var p:GameplayProcess = GameplayProcessManager.gen( "TEST #" + (++proN) );
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