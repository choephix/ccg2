package duel.table 
{
	import duel.cards.Card;
	/**
	 * ...
	 * @author choephix
	 */
	public class IndexedField extends Field 
	{
		
		protected var _index:int;
		public function get index():int { return _index }
		public function IndexedField( type:FieldType, index:int ) 
		{
			_index = index;
			super(type);
		}
		
		//
		public function get topCard():Card { return isEmpty ? null : getFirstCard() }
		public function get opposingCreatureField():IndexedField { return owner.opponent.fieldsC[index] }
		public function get opposingTrapField():IndexedField { return owner.opponent.fieldsT[index] }
		public function get opposingCreature():Card { return opposingCreatureField.topCard }
		public function get opposingTrap():Card { return opposingTrapField.topCard }
		public function get samesideCreatureField():IndexedField { return owner.fieldsC[index] }
		public function get samesideTrapField():IndexedField { return owner.fieldsT[index] }
		public function get samesideCreature():Card { return samesideCreatureField.topCard }
		public function get samesideTrap():Card { return samesideTrapField.topCard }
	}

}