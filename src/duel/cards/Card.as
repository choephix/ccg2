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
		
		private var _flipped:Boolean = true;
		public function get flipped():Boolean
		{
			return _flipped;
		}
		public function set flipped( value:Boolean ):void
		{
			if ( _flipped == value )
				return;
			_flipped = value;
			sprite.setFlipped( value )
		}
		
		//
		public var sprite:CardSprite;
		
		public function initialize():void
		{
			sprite = new CardSprite();
			sprite.initialize( this );
		}
	}

}