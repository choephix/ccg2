package duel.cards.behaviour 
{
	import duel.processes.GameplayProcess;
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
		
		public function TrapCardBehaviour() { startFaceDown = true }
		
		public function activationConditionMet( p:GameplayProcess ):Boolean
		{
			return activationConditionFunc == null ? false : activationConditionFunc( p );
		}
	}
}