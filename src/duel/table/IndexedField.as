package duel.table 
{
	import duel.cards.Card;
	
	public class IndexedField extends Field 
	{
		
		protected var _index:int;
		public function get index():int { return _index }
		public function IndexedField( type:CardLotType, index:int ) 
		{
			_index = index;
			super(type);
		}
		
		// LOCKING
		private var locks:int = 0;
		public function addLock():void { locks++ }
		public function removeLock():void { locks-- }
		public function get isLocked():Boolean { return locks > 0 }
		
		// SAME-COLUMN FIELDS
		public function get opposingCreatureField():CreatureField
		{ return owner.opponent.fieldsC.getAt( index ) }
		
		public function get opposingTrapField():TrapField
		{ return owner.opponent.fieldsT.getAt( index ) }
		
		public function get samesideCreatureField():CreatureField
		{ return owner.fieldsC.getAt( index ) }
		
		public function get samesideTrapField():TrapField
		{ return owner.fieldsT.getAt( index ) }
		
		// SAME-COLUMN CARDS
		public function get opposingCreature():Card
		{ return opposingCreatureField.topCard }
		
		public function get opposingTrap():Card
		{ return opposingTrapField.topCard }
		
		public function get samesideCreature():Card
		{ return samesideCreatureField.topCard }
		
		public function get samesideTrap():Card
		{ return samesideTrapField.topCard }
		
		
		public function get samesideCreatureFieldToTheLeft():CreatureField
		{ return owner.fieldsC.getAt( index - 1 ) }
		
		public function get samesideCreatureFieldToTheRight():CreatureField
		{ return owner.fieldsC.getAt( index + 1 ) }
		
		public function get samesideCreatureToTheLeft():Card
		{ return samesideCreatureFieldToTheLeft == null ? null : samesideCreatureFieldToTheLeft.topCard }
		
		public function get samesideCreatureToTheRight():Card
		{ return samesideCreatureFieldToTheRight == null ? null : samesideCreatureFieldToTheRight.topCard }
		
		
		public function get samesideTrapFieldToTheLeft():TrapField
		{ return owner.fieldsT.getAt( index - 1 ) }
		
		public function get samesideTrapFieldToTheRight():TrapField
		{ return owner.fieldsT.getAt( index + 1 ) }
		
		public function get samesideTrapToTheLeft():Card
		{ return samesideTrapFieldToTheLeft == null ? null : samesideTrapFieldToTheLeft.topCard }
		
		public function get samesideTrapToTheRight():Card
		{ return samesideTrapFieldToTheRight == null ? null : samesideTrapFieldToTheRight.topCard }
		
		
	}

}