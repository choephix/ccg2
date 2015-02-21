package global 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class CardPrimalData 
	{
		public static const FACTION_SCIENCE:int = 0;
		public static const FACTION_NATURE:int 	= 1;
		public static const FACTION_MAGIC:int 	= 2;
		public static const FACTION_NEUTRAL:int = 3;
		public static const FACTION_NONE:int 	= 4;
		
		public static const TYPE_CREATURE_NORMAL:int = 1;
		public static const TYPE_CREATURE_FLIPPABLE:int = 2;
		public static const TYPE_CREATURE_GRAND:int = 3;
		public static const TYPE_TRAP:int = 4;
		
		public var id:int;
		public var slug:String;
		public var name:String;
		public var description:String;
		public var power:int;
		public var faction:int;
		public var type:int;
		public var vars:Array;
		
		public function getVarString( index:int ):String
		{ return vars.length > index ? vars[ index ] as String : "!ERROR!" }
		
		public function getVarInt( index:int ):int
		{ return vars.length > index ? int( vars[ index ] ) : 0 }
	}
}