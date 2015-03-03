package duel.players {
	import duel.cards.Card;
	import duel.controllers.PlayerAction;
	import duel.display.cardlots.HandSprite;
	import duel.display.TableSide;
	import duel.G;
	import duel.players.ManaPool;
	import duel.table.CardLotType;
	import duel.table.CreatureField;
	import duel.table.Field;
	import duel.table.fieldlists.CreatureFieldsRow;
	import duel.table.fieldlists.TrapFieldsRow;
	import duel.table.Hand;
	import duel.table.TrapField;
	import starling.events.EventDispatcher;
	/**
	 * ...
	 * @author choephix
	 */
	public class Player extends EventDispatcher
	{
		public var opponent:Player;
		
		public var hand:Hand;
		public var deck:Field;
		public var grave:Field;
		public var fieldsC:CreatureFieldsRow;
		public var fieldsT:TrapFieldsRow;
		
		public var mana:ManaPool;
		private var _isMyTurn:Boolean;
		
		public var controllable:Boolean;
		private var _name:String;
		private var _lp:int;
		private var _color:uint = 0x44FFFF;
		
		// visuals
		public var tableSide:TableSide;
		public var handSprite:HandSprite;
		
		// = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = 
		// CONSTRUCTION
		// = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = 
		
		public function Player( lifePoints:int )
		{
			hand = new Hand();
			deck = new Field( CardLotType.DECK );
			grave = new Field( CardLotType.GRAVEYARD );
			
			fieldsC = new CreatureFieldsRow( G.FIELD_COLUMNS );
			fieldsT = new TrapFieldsRow( G.FIELD_COLUMNS );
			
			mana = new ManaPool();
			
			_name = "?";
			_lp = lifePoints;
			
			setAsFieldsOwner();
		}
		
		private function setAsFieldsOwner():void 
		{
			hand.owner = this;
			
			deck.owner = this;
			grave.owner = this;
			
			var i:int;
			i = fieldsC.count;
			while ( --i >= 0 ) fieldsC.getAt( i ).owner = this;
			i = fieldsT.count;
			while ( --i >= 0 ) fieldsT.getAt( i ).owner = this;
		}
		
		public function updateDetails( name:String, color:uint ):void
		{
			this._name = name;
			this._color = color;
		}
		
		// = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = 
		// ACTIONS
		// = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = 
		
		public function performAction( a:PlayerAction ):void
		{
			dispatchEvent( new PlayerEvent( PlayerEvent.ACTION, false, a ) );
		}
		
		// = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = 
		// GAMELPLAY
		// = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = 
		
		public function get isMyTurn():Boolean 
		{
			return _isMyTurn;
		}
		
		public function set isMyTurn(value:Boolean):void 
		{
			_isMyTurn = value;
			handSprite.active = value;
		}
		
		public function takeDirectDamage( amount:int ):void
		{
			_lp -= amount;
			
			if ( _lp <= 0 )
				die();
		}
		
		public function heal( amount:int ):void
		{
			_lp += amount;
		}
		
		public function die():void 
		{ trace( this + " is dead" ) }
		
		// = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = 
		// TABLE
		// = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = 
		
		public function samesideCreatureFieldAtIndex( index:int ):CreatureField
		{ return fieldsC.getAt( index ) }
		
		public function samesideCreatureAtIndex( index:int ):Card
		{ return samesideCreatureFieldAtIndex( index ) == null ? null : samesideCreatureFieldAtIndex( index ).topCard }
		
		public function samesideTrapFieldAtIndex( index:int ):TrapField
		{ return fieldsT.getAt( index ) }
		
		public function samesideTrapAtIndex( index:int ):Card
		{ return samesideTrapFieldAtIndex( index ) == null ? null : samesideTrapFieldAtIndex( index ).topCard }
		
		public function opposingCreatureFieldAtIndex( index:int ):CreatureField
		{ return opponent.fieldsC.getAt( index ) }
		
		public function opposingCreatureAtIndex( index:int ):Card
		{ return opposingCreatureFieldAtIndex( index ) == null ? null : opposingCreatureFieldAtIndex( index ).topCard }
		
		public function opposingTrapFieldAtIndex( index:int ):TrapField
		{ return opponent.fieldsT.getAt( index ) }
		
		public function opposingTrapAtIndex( index:int ):Card
		{ return opposingTrapFieldAtIndex( index ) == null ? null : opposingTrapFieldAtIndex( index ).topCard }
		
		// = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = 
		// QUESTIONS
		// = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = 
		
		public function knowsCard( c:Card ):Boolean
		{ 
			if ( CONFIG::sandbox ) return true;
			
			if ( !c.faceDown ) return true;
			if ( c.status.publiclyKnown ) return true;
			
			if ( c.lot == null ) return false;
			if ( c.lot.type.isDeck ) return false;
			if ( c.controller != this ) return false;
			
			return true;
		}
		
		public function get creatureCount():int
		{ return fieldsC.countOccupied }
		
		public function get trapCount():int
		{ return fieldsT.countOccupied }
		
		public function get lifePoints():int
		{ return _lp }
		
		public function get name():String
		{ return _name }
		
		public function get color():uint
		{ return _color }
		
		//
		public function toString():String 
		{return name}
	}
}