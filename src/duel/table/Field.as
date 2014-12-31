package duel.table {
	import duel.cards.Card;
	import duel.cards.CardListBase;
	import duel.display.FieldSprite;
	import duel.table.FieldType;
	/**
	 * ...
	 * @author choephix
	 */
	public class Field extends CardListBase 
	{
		public var sprite:FieldSprite;
		
		private var _type:FieldType = FieldType.UNKNOWN;
		public function get type():FieldType { return _type }
		
		public function Field( type:FieldType ) { _type = type; }
		
		public function get topCard():Card { return isEmpty ? null : getFirstCard() }
	}

}