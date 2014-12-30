package duel.processes 
{
	import chimichanga.debug.logging.error;
	/**
	 * ...
	 * @author choephix
	 */
	public class ProcessWatcher 
	{
		public var funcCondition:Function;
		public var funcEffect:Function;
		
		public function ProcessWatcher() 
		{
			
		}
		
		/// Returns true if the process was interrupted here, false otherwise
		public function interruptProcessMaybe( p:GameplayProcess ):Boolean 
		{
			if ( p.isInterrupted )
			{
				CONFIG::development { error( "ProcessWatcher: already interrupted." ) }
				return false;
			}
			if ( funcCondition( p ) )
			{
				p.interrupt();
				funcEffect( p );
				return true;
			}
			return false;
		}
		
	}

}