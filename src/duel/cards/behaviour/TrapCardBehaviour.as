package duel.cards.behaviour 
{
	import duel.processes.Process;
	/**
	 * ...
	 * @author choephix
	 */
	public class TrapCardBehaviour extends CardBehaviour 
	{
		/// must accept one arg of type Process and return Boolean
		public var activationConditionFunc:Function;
		public var onActivateFunc:Function;
		
		public var persistent:Boolean = false;
		
		//private var watchers:Vector.<ProcessWatcher>;
		
		
		public function TrapCardBehaviour() { startFaceDown = true }
		
		//public function addProcessWatcher( pw:ProcessWatcher ):void
		//{
			//if ( watchers == null )
				//watchers = new Vector.<ProcessWatcher>();
			//watchers.push( pw );
		//}
		
		public function activationConditionMet( p:Process ):Boolean
		{
			//if ( watchers == null ) return false;
			//for ( var i:int = 0, iMax:int = watchers.length; i < iMax; i++ ) 
				//return watchers[ i ].processMeetsConditions( p );
			return activationConditionFunc == null ? false : activationConditionFunc( p );
		}
	}
}