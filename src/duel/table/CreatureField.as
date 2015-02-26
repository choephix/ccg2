package duel.table {
	import duel.cards.Card;
	import duel.table.CardLotType;
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureField extends IndexedField
	{
		public function CreatureField( index:int )
		{ super( CardLotType.CREATURE_FIELD, index ) }
	}
}