package duel.table {
	import duel.cards.Card;
	import duel.G;
	import duel.table.CardLotType;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureField extends IndexedField
	{
		public function CreatureField( index:int )
		{ super( CardLotType.CREATURE_FIELD, index ) }
		
		public function get adjacentLeft():CreatureField
		{
			return owner.fieldsC.getAt( index - 1 );
		}
		
		public function get adjacentRight():CreatureField
		{
			return owner.fieldsC.getAt( index + 1 );
		}
		
		public function get adjacentCreatureLeft():Card
		{
			return adjacentLeft == null ? null : adjacentLeft.topCard;
		}
		
		public function get adjacentCreatureRight():Card
		{
			return adjacentRight == null ? null : adjacentRight.topCard;
		}
		
		//
		override public function toString():String 
		{ return "f_" + owner.id + "C" + index }
	}
}