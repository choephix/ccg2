package duel.cards.behaviour 
{
	import duel.otherlogic.PersistentTrapEffect;
	import duel.otherlogic.SpecialEffect;
	import duel.processes.GameplayProcess;
	/**
	 * ...
	 * @author choephix
	 */
	public class TrapCardBehaviour extends CardBehaviour 
	{
		/// Must accept one arg of type Process and return Boolean
		public var effect:SpecialEffect = new SpecialEffect();
		
		public var persistentEffect:PersistentTrapEffect = new PersistentTrapEffect();
		public function get isPersistent():Boolean
		{ return persistentEffect != null }
		
		public function TrapCardBehaviour() { startFaceDown = true }
	}
}