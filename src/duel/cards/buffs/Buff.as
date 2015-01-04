package duel.cards.buffs 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class Buff 
	{
		internal var next:Buff;
		internal var prev:Buff;
		
		public var expiryCondition:Function;
		
		public var description:String;
		internal var name:String;
		internal var value:*;
		
		internal var sticky:Boolean;
		
		public function Buff( name:String, value:*, description:String = "" ) 
		{
			this.value = value;
			this.name = name;
			this.description = description;
		}
		
		public function reset():void
		{
			
		}
		
		// LIST
		
		static public const POWER_OFFSET:String = "powerOffset";
		
		static public const FLIPPABLE:String = "flippable";
		static public const NEED_TRIBUTE:String = "needTribute";
		
		static public const HASTE:String = "haste";
		static public const NO_ATTACK:String = "noAttack";
		static public const NO_RELOCATION:String = "noRelocation";
		static public const SWIFT:String = "swift";
		
		//SPECIAL_EFFECT
		
		// S T A T I C
		static public function generateFlagBuff( name:String ):Buff
		{ return new Buff( name, true ); }
	}
}