package duel {
	import duel.battleobjects.Creature;
	import duel.battleobjects.Trap;
	import duel.display.TableSide;
	import duel.table.CreatureField;
	import duel.table.Field;
	import duel.table.Hand;
	import duel.table.TrapField;
	import duel.cards.Card;
	import duel.display.cardlots.HandSprite;
	import duel.table.FieldType;
	/**
	 * ...
	 * @author choephix
	 */
	public class Player 
	{
		public var opponent:Player;
		
		public var controllable:Boolean = true;
		
		public var hand:Hand;
		public var deck:Field;
		public var grave:Field;
		public var fieldsC:Vector.<CreatureField>;
		public var fieldsT:Vector.<TrapField>;
		
		public var creatures:Vector.<Creature>;
		public var traps:Vector.<Trap>;
		
		protected var _name:String;
		protected var _lp:int;
		
		//VISUAL
		
		public var tableSide:TableSide;
		public var handSprite:HandSprite;
		
		// = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = 
		
		// CONSTRUCTION
		public function Player( name:String, lifePoints:int )
		{
			hand = new Hand();
			deck = new Field( FieldType.DECK );
			grave = new Field( FieldType.GRAVEYARD );
			
			fieldsC = new Vector.<CreatureField>();
			while ( fieldsC.length < G.FIELD_COLUMNS ) fieldsC.push( new CreatureField( fieldsC.length ) );
			fieldsT = new Vector.<TrapField>();
			while ( fieldsT.length < G.FIELD_COLUMNS ) fieldsT.push( new TrapField( fieldsT.length ) );
			
			creatures = new Vector.<Creature>( G.FIELD_COLUMNS );
			traps = new Vector.<Trap>( G.FIELD_COLUMNS );
			
			_name = name;
			_lp = lifePoints;
			
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
		
		// GAMELPLAY
		
		public function takeDirectDamage( amount:int ):void
		{
			_lp -= amount;
			
			if ( _lp <= 0 )
				die();
		}
		
		public function die():void 
		{
			trace( this + " is dead" );
		}
		
		// QUESTIONS
		
		public function get creatureCount():int
		{ 
			var r:int = 0;
			for ( var i:int = 0; i < G.FIELD_COLUMNS; i++ ) 
				if ( fieldsC[ i ].topCard != null && fieldsC[ i ].topCard.type.isCreature ) r++;
			return r;
		}
		
		public function get trapCount():int
		{ 
			var r:int = 0;
			for ( var i:int = 0; i < G.FIELD_COLUMNS; i++ ) 
				if ( !fieldsT[ i ].isEmpty ) r++;
			return r;
		}
		
		public function get lifePoints():int
		{ 
			return _lp;
		}
		
		public function get name():String
		{ 
			return _name;
		}
		
		// BATTLE ENTITIES
		public function getCreatureAt( index:int ):Creature { return creatures[ index ]; }
		public function setCreatureAt( index:int, o:Creature ):void { creatures[ index ] = o; }
		
		public function getTrapAt( index:int ):Trap { return traps[ index ]; }
		public function setTrapAt( index:int, o:Trap ):void { traps[ index ] = o; }
		
	}
}