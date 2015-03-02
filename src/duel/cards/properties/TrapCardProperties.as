package duel.cards.properties {
	import duel.cards.Card;
	import duel.otherlogic.TrapEffect;
	import duel.otherlogic.SpecialEffect;
	import duel.processes.GameplayProcess;
	
	use namespace cardprops;
	/**
	 * ...
	 * @author choephix
	 */
	public class TrapCardProperties extends CardProperties 
	{
		cardprops var persistent:Boolean = false;
		
		public function get isPersistent():Boolean
		{ return persistent }
		
		public var effect:TrapEffect;
	}
}