package duel.players {
	import duel.controllers.PlayerController;
	import duel.controllers.UserPlayerController;
	import duel.display.TableSide;
	import duel.G;
	import duel.players.ManaPool;
	import duel.table.CreatureField;
	import duel.table.Field;
	import duel.table.fieldlists.CreatureFieldsRow;
	import duel.table.fieldlists.TrapFieldsRow;
	import duel.table.Hand;
	import duel.table.TrapField;
	import duel.cards.Card;
	import duel.display.cardlots.HandSprite;
	import duel.table.CardLotType;
	/**
	 * ...
	 * @author choephix
	 */
	public class Player 
	{
		public var opponent:Player;
		
		public var controllable:Boolean = true;
		public var ctrl:PlayerController;
		
		public var hand:Hand;
		public var deck:Field;
		public var grave:Field;
		public var fieldsC:CreatureFieldsRow;
		public var fieldsT:TrapFieldsRow;
		
		public var mana:ManaPool;
		
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
			deck = new Field( CardLotType.DECK );
			grave = new Field( CardLotType.GRAVEYARD );
			
			fieldsC = new CreatureFieldsRow( G.FIELD_COLUMNS );
			fieldsT = new TrapFieldsRow( G.FIELD_COLUMNS );
			
			mana = new ManaPool();
			
			ctrl = new UserPlayerController( this );
			
			_name = name;
			_lp = lifePoints;
			
			setAsFieldsOwner();
			
			// INITIALIZE
			ctrl.initialize();
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
		
		// CARD ACTIONS
		
		// GAMELPLAY
		
		public function takeDirectDamage( amount:int ):void
		{
			_lp -= amount;
			
			if ( _lp <= 0 )
				die();
		}
		
		public function die():void 
		{ trace( this + " is dead" ) }
		
		// QUESTIONS
		
		public function canPerformAction():Boolean
		{
			CONFIG::sandbox { return true }
			return mana.current > 0;
		}
		
		public function get creatureCount():int
		{ return fieldsC.countOccupied }
		
		public function get trapCount():int
		{ return fieldsT.countOccupied }
		
		public function get lifePoints():int
		{ return _lp }
		
		public function get name():String
		{ return _name }
		
	}
}