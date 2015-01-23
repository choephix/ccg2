package duel.players {
	import duel.controllers.PlayerAction;
	import duel.display.cardlots.HandSprite;
	import duel.display.TableSide;
	import duel.G;
	import duel.players.ManaPool;
	import duel.table.CardLotType;
	import duel.table.Field;
	import duel.table.fieldlists.CreatureFieldsRow;
	import duel.table.fieldlists.TrapFieldsRow;
	import duel.table.Hand;
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
		
		// helpers
		private var e:PlayerEvent = new PlayerEvent('');
		
		// = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = 
		// CONSTRUCTION
		// = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = 
		
		public function Player( name:String, lifePoints:int )
		{
			hand = new Hand();
			deck = new Field( CardLotType.DECK );
			grave = new Field( CardLotType.GRAVEYARD );
			
			fieldsC = new CreatureFieldsRow( G.FIELD_COLUMNS );
			fieldsT = new TrapFieldsRow( G.FIELD_COLUMNS );
			
			mana = new ManaPool();
			
			_name = name;
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
			//dispatchEvent( e.reset( PlayerEvent.ACTION, false, a ) );
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
		// QUESTIONS
		// = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = - = 
		
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