package duel.table {
	import duel.cards.Card;
	import duel.table.CardLotType;
	/**
	 * ...
	 * @author choephix
	 */
	public class TrapField extends IndexedField 
	{
		public function TrapField( index:int )
		{ super( CardLotType.TRAP_FIELD, index ) }
	}

}