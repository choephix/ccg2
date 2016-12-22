package duel.table {
	import duel.cards.Card;
	import duel.cards.CardListBase;
	import duel.display.FieldSprite;
	import duel.table.CardLotType;
	
	public class Field extends CardListBase 
	{
		public var sprite:FieldSprite;
		
		public function Field( type:CardLotType )
		{ _type = type }
		
		public function get topCard():Card
		{ return isEmpty ? null : getFirstCard() }
		
		override public function toString():String 
		{ return type.toString() }
	}
}