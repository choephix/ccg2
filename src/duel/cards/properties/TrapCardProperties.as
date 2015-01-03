package duel.cards.properties {
	import duel.otherlogic.TrapEffect;
	import duel.otherlogic.SpecialEffect;
	import duel.processes.GameplayProcess;
	/**
	 * ...
	 * @author choephix
	 */
	public class TrapCardProperties extends CardProperties 
	{
		/// Must accept one arg of type Process and return Boolean
		public var effect:TrapEffect = new TrapEffect();
		public function get isPersistent():Boolean
		{ return effect.funcUpdate != null }
		
		public function TrapCardProperties()
		{ startFaceDown = true }
	}
}