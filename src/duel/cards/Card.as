package duel.cards
{
	import duel.cards.buffs.GlobalBuff;
	import duel.cards.CardListBase;
	import duel.cards.history.CardHistory;
	import duel.cards.properties.CardProperties;
	import duel.cards.properties.CreatureCardProperties;
	import duel.cards.properties.TrapCardProperties;
	import duel.cards.status.CardStatus;
	import duel.cards.status.CreatureCardStatus;
	import duel.cards.status.TrapCardStatus;
	import duel.display.cards.CardSprite;
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
		private var _faq:CardFAQ;
		
		// BATTLE
		public var owner:Player;
		private var _controller:Player;
		private var _lot:CardListBase;
		public var lotIndex:int;
		
		public var faceDown:Boolean = true;
		
		//
		public var sprite:CardSprite;
		
		CONFIG::development
		public var unimplemented:Boolean;
		
		public function Card() 
		{
			_history = new CardHistory();
			_faq = new CardFAQ( this );
		}
		
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
			
			if ( isInPlay && isCreature )
				if ( p.name == GameplayProcess.TURN_START )
					//if ( game.currentPlayer == controller )
						statusC.onTurnEnd();
			
			status.onGameProcess( p );
		}
		
		// 
		
		public function registerGlobalBuff( gb:GlobalBuff ):void
		{
			if ( game.globalBuffs.hasBuff( gb ) )
				return;
			
			game.globalBuffs.registerBuff( gb );
		}
		
		public function removeGlobalBuff( gb:GlobalBuff ):void
		{
			if ( !game.globalBuffs.hasBuff( gb ) )
				return;
			
			game.globalBuffs.removeBuff( gb );
		}
		
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
		
		// GETTERS & SETTERS - HISTORY & FAQ
		
		public function get history():CardHistory 
		{ return _history }
		
		public function get faq():CardFAQ 
		{ return _faq }
		
		// GETTERS & SETTERS - TYPE
		
		public function get isCreature():Boolean
		{ return props is CreatureCardProperties }
		
		public function get isTrap():Boolean
		{ return props is TrapCardProperties }
		
		// GETTERS & SETTERS - 1
		
		public function set lot( value:CardListBase ):void 
		{ 
			if ( _lot == value )
				return;
			if ( lot is IndexedField )
				history.lastIndexedField = lot as IndexedField;
			game.cardEvents.dispatchEventWith( CardEvents.LEAVE_LOT, this, _lot );
			_lot = value;
			if ( _lot != null )
				_controller = _lot.owner;
			game.cardEvents.dispatchEventWith( CardEvents.ENTER_LOT, this, _lot );
			 sprite.onLotEntered( _lot );
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
		{ return _controller }
		
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
		
		public function get id():int 
		{ return primalData.id }
		
		public function get slug():String 
		{ return primalData.slug }
		
		public function get name():String 
		{ return primalData.name }
		
		public function get description():String 
		{ return primalData.prettyDescription }
		
		//
		public function toString():String 
		{
			return "\"" + name + "\"";
		}
		
		CONFIG::heavytest
		public function heavyTest():void
		{
			status.heavyTest();
		}
	}
}