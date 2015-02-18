package duel.cards.history 
{
	import duel.cards.Card;
	import duel.cards.CardListBase;
	import duel.table.IndexedField;
	/**
	 * ...
	 * @author choephix
	 */
	public class CardHistory 
	{
		public var tribute:Card;
		
		public var lastValidLot:CardListBase = null;
		public var lastIndexedField:IndexedField = null;
		public function get lastFieldIndex():int 
		{ return lastIndexedField == null ? -1 : lastIndexedField.index }
	}
}