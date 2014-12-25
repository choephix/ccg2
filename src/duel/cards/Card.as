package duel.cards
{
	import chimichanga.common.display.Sprite;
	import chimichanga.global.utils.Colors;
	import duel.Field;
	import duel.cards.behaviour.CardBehaviour;
	import duel.cards.CardData;
	import duel.GameEntity;
	import duel.Player;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
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
		public var player:Player;
		public var field:Field;
		public function get isInPlay():Boolean{return field != null}
		
		private var _faceDown:Boolean = true;
		public function get faceDown():Boolean
		{
			return _faceDown;
		}
		public function set faceDown( value:Boolean ):void
		{
			if ( _faceDown == value )
				return;
			_faceDown = value;
			sprite.setFlipped( value )
		}
		
		private var _exhausted:Boolean;
		public function get exhausted():Boolean 
		{
			return _exhausted;
		}
		public function set exhausted(value:Boolean):void 
		{
			_exhausted = value;
			sprite.exhaustClock.visible = value;
		}
		
		//
		public var sprite:CardSprite;
		
		internal var list:CardList;
		
		public function initialize():void
		{
			sprite = new CardSprite();
			sprite.initialize( this );
		}
		
		public function onTurnEnd():void {
			
		}
	}

}