package duel.cards
{
	import duel.cards.behaviour.CardBehaviour;
	import duel.cards.CardListBase;
	import duel.display.CardSprite;
	import duel.GameEntity;
	import duel.GameEvents;
	import duel.Player;
	import duel.table.CreatureField;
	import duel.table.Field;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Card extends GameEntity
	{
		// PERSISTENT
		public var id:int;
		public var name:String;
		public var type:CardType;
		public var behaviour:CardBehaviour;
		
		// BATTLE
		public var owner:Player;
		public var lot:CardListBase;
		
		private var _faceDown:Boolean = true;
		private var _exhausted:Boolean;
		//
		public var sprite:CardSprite;
		
		//
		public function initialize():void
		{
			sprite = new CardSprite();
			sprite.initialize( this );
			
			this.game.addEventListener( GameEvents.TURN_START, onTurnStart );
			this.game.addEventListener( GameEvents.TURN_START, onTurnEnd );
		}
		
		//
		public function onTurnEnd():void
		{
			
		}
		
		public function onTurnStart():void
		{
			if ( game.currentPlayer == controller ) exhausted = false;
		}
		
		//
	
		// GETTERS & SETTERS - 1
		
		public function get field():Field { return lot as Field }
		public function get controller():Player { return lot == null ? null : lot.owner }
		
		public function get isInPlay():Boolean { return lot is CreatureField }
		
		// GETTERS & SETTERS - 2
		public function get faceDown():Boolean{return _faceDown}
		public function set faceDown( value:Boolean ):void
		{
			if ( _faceDown == value )
				return;
			_faceDown = value;
			sprite.setFlipped( value )
		}
		
		public function get exhausted():Boolean {return _exhausted}
		public function set exhausted(value:Boolean):void 
		{
			_exhausted = value;
			game.jugglerMild.xtween( sprite.exhaustClock, .500, { alpha : value ? 1 : 0 } );
		}
		
		// GETTERS & SETTERS - 3
		public function get canAttack():Boolean{ return type.isCreature && isInPlay && !exhausted }
	}
}