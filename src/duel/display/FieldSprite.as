package duel.display {
	import duel.display.cardlots.DeckStackSprite;
	import duel.display.cardlots.GraveStackSprite;
	import duel.display.cardlots.StackSprite;
	import duel.GameSprite;
	import duel.table.Field;
	import duel.table.FieldType;
	import duel.table.IndexedField;
	import starling.animation.IAnimatable;
	import starling.animation.Transitions;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class FieldSprite extends GameSprite implements IAnimatable
	{
		public var cardsContainer:StackSprite;
		public var image:Image;
		public var lockIcon:Image;
		
		public var field:Field;
		
		private var _isLocked:Boolean = false;
		private var _pointerIsOver:Boolean = false;
		
		public function initialize( field:Field, color:uint ):void
		{
			image = assets.generateImage( "field", true, true );
			image.color = color; 
			addChild( image );
			
			if ( field is IndexedField )
			{
				lockIcon = assets.generateImage( "iconLock", false, true );
				lockIcon.alpha = .0;
				addChild( lockIcon );
			}
			
			var CardStackT:Class = GetCardStackClassForFieldType( field.type );
			cardsContainer = new CardStackT( field );
			cardsContainer.touchable = false;
			
			this.field = field;
			field.sprite = this;
			
			game.juggler.add( this );
			
			addEventListener( TouchEvent.TOUCH, onTouch );
		}
		
		/* INTERFACE starling.animation.IAnimatable */
		
		public function advanceTime( time:Number ):void 
		{
			if ( lockIcon != null )
				setLockIconVisibility( IndexedField( field ).isLocked );
		}
		
		private function setLockIconVisibility( value:Boolean ):void 
		{
			if ( value == _isLocked )
				return;
			
			_isLocked = value;
			
			if ( value )
			{
				lockIcon.alpha = .0;
				lockIcon.scaleX = .20;
				lockIcon.scaleY = .20;
				juggler.xtween( lockIcon, .330,
					{
						alpha : 1.0,
						scaleX : 1.0,
						scaleY : 1.0,
						transition : Transitions.EASE_OUT_BACK
					} );
			}
			else
			{
				lockIcon.alpha = 1.0;
				juggler.xtween( lockIcon, .220,
					{
						alpha : .0,
						scaleX : 1.50,
						scaleY : 1.50,
						transition : Transitions.EASE_OUT
						//  EASE_OUT  EASE_IN_BACK
					} );
			}
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var t:Touch = e.getTouch( this );
			
			if ( t == null ) {
				if ( _pointerIsOver ) {
					_pointerIsOver = false;
					if ( !field.isEmpty )
						game.onCardRollOut( field.getCardAt( 0 ) );
				}
				return;
			}
			else
			if ( t.phase == TouchPhase.HOVER ) {
				if ( !_pointerIsOver ) {
					_pointerIsOver = true;
					if ( !field.isEmpty )
						game.onCardRollOver( field.getCardAt( 0 ) );
				}
			}
			else
			if ( t.phase == TouchPhase.ENDED ) {
				game.onFieldClicked( field );
			} 
		}
		
		//
		private static function GetCardStackClassForFieldType( type:FieldType ):Class
		{
			if ( type.isGraveyard ) return GraveStackSprite;
			if ( type.isDeck ) return DeckStackSprite;
			return StackSprite;
		}
		
	}

}