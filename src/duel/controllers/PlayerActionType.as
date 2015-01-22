package duel.controllers 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class PlayerActionType 
	{
		// MANA ACTIONS
		static public const DRAW:String				= "draw";
		static public const SUMMON_CREATURE:String	= "summonCreature";
		static public const SET_TRAP:String			= "setTrap";
		// INPLAY CREATURE ACTIONS
		static public const ATTACK:String			= "attack";
		static public const RELOCATE:String			= "relocate";
		static public const SAFEFLIP:String			= "safeflip";
		// OTHER
		static public const END_TURN:String			= "endTurn";
		static public const SURRENDER:String		= "surrender";
	}
} 