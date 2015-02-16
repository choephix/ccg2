package duel.cards
{
	import duel.cards.CardListBase;
	import duel.cards.history.CardHistory;
	import duel.cards.properties.CardProperties;
	import duel.cards.properties.CreatureCardProperties;
	import duel.cards.properties.TrapCardProperties;
	import duel.cards.status.CardStatus;
	import duel.cards.status.CreatureCardStatus;
	import duel.cards.status.TrapCardStatus;
	import duel.display.CardSprite;
	import duel.Game;
	import duel.GameEntity;
	import duel.gameplay.CardEvents;
	import duel.players.Player;
	import duel.processes.GameplayProcess;
	import duel.table.CreatureField;
	import duel.table.Field;
	import duel.table.Hand;
	import duel.table.IndexedField;
	import duel.table.TrapField;
	import global.CardPrimalData;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Card extends GameEntity
	{
		// PERSISTENT
		public var uid:int;
		private var _id:int;
		private var _name:String;
		private var _description:String;
		public var cost:int = 1;
		
		public var primalData:CardPrimalData;
		private var _status:CardStatus;
		private var _props:CardProperties;
		private var _history:CardHistory;
		
		// BATTLE
		public var owner:Player;
		private var _lot:CardListBase;
		
		public var actionsRelocate:int = 0;
		public var actionsAttack:int = 0;
		public var summonedThisTurn:Boolean = false;
		
		private var _faceDown:Boolean = true;
		
		//
		public var sprite:CardSprite;
		
		//
		public function initialize():void
		{
			CONFIG::development
			{
				if ( _props == null )
					throw VerifyError( "You left " + this + "'s behaviour = NULL, you dickface." );
				if ( _status == null )
					throw VerifyError( "You left " + this + "'s status = NULL, you asscunt." );
			}
			_history = new CardHistory();
			sprite = new CardSprite();
			sprite.initialize( this );
		}
		
		// -.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'
		
		// GAMEPLAY SHIT
		
		//
		
		public function onGameProcess( p:GameplayProcess ):void
		{
			CONFIG::development
			{ if ( p.isInterrupted ) throw new Error( "HANDLE PROCESS INTERRUPTIONS!" ) }
			
			if ( isInPlay )
				if ( p.name == GameplayProcess.TURN_START )
					if ( game.currentPlayer == controller )
						resetState();
			
			status.onGameProcess( p );
		}
		
		/// This must be called on turn start as well as when the card leaves play
		public function resetState():void
		{
			actionsRelocate = 0;
			actionsAttack = 0;
			summonedThisTurn = false;
		}
		
		// 
		
		// -.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'-.-'
		
		// GETTERS & SETTERS - PROPERTIES
		
		public function get props():CardProperties
		{ return _props }
		public function set props(value:CardProperties):void 
		{ _props = value; value.card = this; }
		
		public function get propsC():CreatureCardProperties
		{ return _props as CreatureCardProperties }
		
		public function get propsT():TrapCardProperties
		{ return _props as TrapCardProperties }
		
		// GETTERS & SETTERS - STATUS
		
		public function get status():CardStatus
		{ return _status }
		public function set status(value:CardStatus):void 
		{ _status = value; value.card = this; value.initialize(); }
		
		public function get statusC():CreatureCardStatus
		{ return _status as CreatureCardStatus }
		
		public function get statusT():TrapCardStatus
		{ return _status as TrapCardStatus }
		
		// GETTERS & SETTERS - HISTORY
		
		public function get history():CardHistory 
		{ return _history }
		
		// GETTERS & SETTERS - TYPE
		
		public function get isCreature():Boolean
		{ return props is CreatureCardProperties }
		
		public function get isTrap():Boolean
		{ return props is TrapCardProperties }
		
		// GETTERS & SETTERS - 1
		
		public function set lot(value:CardListBase):void 
		{ 
			if ( _lot == value )
				return;
			if ( lot is IndexedField )
				history.lastIndexedField = lot as IndexedField;
			game.cardEvents.dispatchEventWith( CardEvents.LEAVE_LOT, this, _lot );
			_lot = value;
			game.cardEvents.dispatchEventWith( CardEvents.ENTER_LOT, this, _lot );
		}
		
		public function get lot():CardListBase 
		{ return _lot }
		
		public function get field():Field
		{ return lot as Field }
		
		public function get indexedField():IndexedField
		{ return lot as IndexedField }
		
		public function get fieldC():CreatureField
		{ return lot as CreatureField }
		
		public function get fieldT():TrapField
		{ return lot as TrapField }
		
		public function get controller():Player
		{ return lot == null ? null : lot.owner }
		
		// GETTERS & SETTERS - 2
		
		public function get isInPlay():Boolean
		{ return lot is IndexedField }
		
		public function get isInHand():Boolean
		{ return lot is Hand }
		
		public function get isInGrave():Boolean
		{ return field != null && field.type.isGraveyard }
		
		public function get isInDeck():Boolean
		{ return field != null && field.type.isDeck }
		
		// GETTERS & SETTERS - 3
		public function get faceDown():Boolean{return _faceDown}
		public function set faceDown( value:Boolean ):void
		{
			if ( _faceDown == value )
				return;
			_faceDown = value;
		}
		
		public function get exhausted():Boolean {
			if ( firstTurnExhaustion ) return true;
			if ( statusC.hasSwift ) return actionsAttack > 0 && actionsRelocate > 0;
			return actionsRelocate + actionsAttack > 0;
		}
		
		private function get firstTurnExhaustion():Boolean {
			CONFIG::development
			{ if ( Game.GODMODE ) return false }
			if ( statusC.hasHaste ) return false;
			return summonedThisTurn;
		}
		
		// GETTERS & SETTERS - 3
		public function get canAttack():Boolean { 
			if ( !isCreature ) return false;
			if ( !isInPlay ) return false;
			if ( exhausted ) return false;
			if ( statusC.hasNoAttack ) return false;
			return actionsAttack == 0;
		}
		public function get canRelocate():Boolean { 
			if ( !isCreature ) return false;
			if ( !isInPlay ) return false;
			if ( exhausted ) return false;
			if ( statusC.hasNoRelocation ) return false;
			return actionsRelocate == 0;
		}
		
		public function get id():int 
		{ return primalData.id }
		
		public function get slug():String 
		{ return primalData.slug }
		
		public function get name():String 
		{ return primalData.name }
		
		public function get description():String 
		{ return primalData.description }
		
		//
		public function toString():String 
		{
			return "\"" + name + "\"";
		}
	}
}