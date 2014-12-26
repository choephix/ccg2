package duel.cards.behaviour 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureCardBehaviour extends CardBehaviour 
	{
		public var attack:int = 0;
		
		public var haste:Boolean = false; 		// CAN ATTACK OR MOVE FIRST TURN
		public var defender:Boolean = false; 	// CANNOT ATTACK
		public var immobile:Boolean = false; 	// CANNOT MOVE
		public var swift:Boolean = false; 		// CAN ATTACK AND MOVE SAME TURN
		public var berserk:Boolean = false;		// ATTACKS AUTOMATICALLY
	}
}