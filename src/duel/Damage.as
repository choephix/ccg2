package duel 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class Damage 
	{
		public var type:DamageType;
		public var amount:int;
		public var source:*;
		
		public function Damage( amount:int, type:DamageType, source:* ) 
		{
			this.amount = amount;
			this.type = type;
			this.source = source;
		}
		
	}

}