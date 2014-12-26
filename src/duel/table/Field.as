package duel.table {
	import duel.cards.CardListBase;
	import duel.table.FieldType;
	/**
	 * ...
	 * @author choephix
	 */
	public class Field extends CardListBase 
	{
		private var _type:FieldType = FieldType.UNKNOWN;
		public function get type():FieldType { return _type }
		
		public function Field( type:FieldType ) { _type = type; }
	}

}