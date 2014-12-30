package duel.cards.behaviour 
{
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
		
		/// If true, the trap will not leave the field after activation.
		public var persistent:Boolean = false; //TODO add ongoing effect tot this
		
		public function TrapCardBehaviour() { startFaceDown = true }
	}
}