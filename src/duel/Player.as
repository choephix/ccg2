package duel {
	import duel.battleobjects.Creature;
	import duel.battleobjects.Trap;
	import duel.cardlots.CreatureField;
	import duel.cardlots.Field;
	import duel.cardlots.Hand;
	import duel.cardlots.TrapField;
	import duel.cards.Card;
	import duel.cards.visual.HandSprite;
	import duel.table.FieldType;
	/**
	 * ...
	 * @author choephix
	 */
	public class Player 
	{
		public var opponent:Player;
		
		public var name:String;
		public var lp:int;
		
		public var controllable:Boolean = true;
		
		public var hand:Hand;
		public var deck:Field;
		public var grave:Field;
		public var fieldsC:Vector.<CreatureField>;
		public var fieldsT:Vector.<TrapField>;
		
		//VISUAL
		
		public var tableSide:TableSide;
		public var handSprite:HandSprite;
		
		// = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = 
		
		// CONSTRUCTION
		public function Player() 
		{
			hand = new Hand();
			deck = new Field( FieldType.DECK );
			grave = new Field( FieldType.GRAVEYARD );
			
			fieldsC = new Vector.<CreatureField>();
			while ( fieldsC.length < G.FIELD_COLUMNS ) fieldsC.push( new CreatureField( fieldsC.length ) );
			fieldsT = new Vector.<TrapField>();
			while ( fieldsT.length < G.FIELD_COLUMNS ) fieldsT.push( new TrapField( fieldsT.length ) );
			
			setAsFieldsOwner();
		}
		
		private function setAsFieldsOwner():void 
		{
			hand.owner = this;
			
			deck.owner = this;
			grave.owner = this;
			
			var f:Field;
			for each ( f in fieldsC ) f.owner = this;
			for each ( f in fieldsT ) f.owner = this;
		}
		
		// CARD ACTIONS
		public function draw():void 
		{
			var c:Card = deck.getCardAt( deck.cardsCount - 1 );
			deck.removeCard( c );
			hand.addCard( c );
			c.faceDown = false;
			
			trace( name + " drew a card." );
		}
		
		public function discard( c:Card ):void 
		{
			grave.addCard( c );
			c.faceDown = true;
			
			trace( name + " put a card to the grave." );
		}
	}
}