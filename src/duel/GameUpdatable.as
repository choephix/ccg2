package duel
{
	import duel.processes.GameplayProcess;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class GameUpdatable extends GameEntity
	{
		private var _initialized:Boolean;
		
		protected function initialize():void
		{
			_initialized = true
		}
		
		public function advanceTime( time:Number ):void
		{
			if ( !_initialized )
				initialize()
		}
		
		public function onProcessUpdateOrComplete( p:GameplayProcess ):void
		{
			if ( !_initialized )
				initialize()
		}
	
	}
}