package duel 
{
	import duel.cards.Card;
	/**
	 * ...
	 * @author choephix
	 */
	public class Damage 
	{
		public var type:DamageType;
		public var amount:int;
		public var source:Card;
		
		public function Damage( amount:int, type:DamageType, source:Card ) 
		{
			this.amount = amount;
			this.type = type;
			this.source = source;
		}
		
	}

}