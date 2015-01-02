package duel.cards.behaviour 
{
	import duel.otherlogic.TrapEffect;
	import duel.otherlogic.SpecialEffect;
	import duel.processes.GameplayProcess;
	/**
	 * ...
	 * @author choephix
	 */
	public class TrapCardBehaviour extends CardBehaviour 
	{
		/// Must accept one arg of type Process and return Boolean
		public var effect:TrapEffect = new TrapEffect();
		public function get isPersistent():Boolean
		{ return effect.funcUpdate != null }
		
		public function TrapCardBehaviour()
		{ startFaceDown = true }
	}
}