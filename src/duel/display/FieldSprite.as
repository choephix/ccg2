package duel.display {
	import chimichanga.common.display.Sprite;
	import duel.display.cardlots.DeckStackSprite;
	import duel.display.cardlots.GraveStackSprite;
	import duel.display.cardlots.StackSprite;
	import duel.display.fields.FieldSpriteGuiState;
	import duel.display.fields.IndexedFieldOverlay;
	import duel.G;
	import duel.GameSprite;
	import duel.gui.GuiEvents;
	import duel.table.CardLotType;
	import duel.table.Field;
	import duel.table.IndexedField;
	import starling.animation.IAnimatable;
	import starling.display.Image;
	import starling.display.Quad;
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
		public var fieldOverlayParent:Sprite;
		private var quad:Quad;
		private var image:Image;
		private var overlaySprite:IndexedFieldOverlay;
		
		public var field:Field;
		
		private var _guiState:FieldSpriteGuiState = FieldSpriteGuiState.NONE;
		private var _z:Number;
		
		public function initialize( field:Field, color:uint, cardsParent:Sprite ):void
		{
			image = assets.generateImage( "field", false, true );
			image.blendMode = "add";
			image.color = color; 
			addChild( image );
			
			if ( field is IndexedField )
			{
				overlaySprite = new IndexedFieldOverlay();
				overlaySprite.initialize( field as IndexedField );
				fieldOverlayParent.addChild( overlaySprite );
			}
			
			var CardStackT:Class = GetCardStackClassForFieldType( field.type );
			cardsContainer = new CardStackT( field );
			cardsContainer.cardsParent = cardsParent;
			
			quad = new Quad( G.CARD_W, G.CARD_H, 0xFF0000 );
			quad.alpha = .0;
			quad.alignPivot();
			addChild( quad );
			
			this.field = field;
			field.sprite = this;
			
			game.juggler.add( this );
			
			addEventListener( TouchEvent.TOUCH, onTouch );
			touchable = true;
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var t:Touch = e.getTouch( quad );
			
			if ( t == null )
			{
				return;
			}
			
			switch ( t.phase )
			{
				case TouchPhase.HOVER:
					break;
				case TouchPhase.ENDED:
					guiEvents.dispatchEventWith( GuiEvents.FIELD_CLICK, false, field );
					break;
			}
		}
		
		public function advanceTime( time:Number ):void 
		{
			useHandCursor = _guiState != FieldSpriteGuiState.NONE;
		}
		
		// VISUALS
		
		public function setGuiState( state:FieldSpriteGuiState ):void
		{
			if ( _guiState == state )
				return;
			
			_guiState = state;
			
			overlaySprite.setGuiState( state );
		}
		
		//
		private static function GetCardStackClassForFieldType( type:CardLotType ):Class
		{
			if ( type.isGraveyard ) return GraveStackSprite;
			if ( type.isDeck ) return DeckStackSprite;
			return StackSprite;
		}
		
		//
		
		override public function set x(value:Number):void 
		{
			super.x = value;
			cardsContainer.x = x;
			if ( overlaySprite )
				overlaySprite.x = x;
		}
		
		override public function set y(value:Number):void 
		{
			super.y = value;
			cardsContainer.y = y;
			if ( overlaySprite )
				overlaySprite.y = y;
		}
		
		public function get z():Number 
		{
			return _z;
		}
		
		public function set z(value:Number):void 
		{
			_z = value;
			scaleX = _z;
			scaleY = _z;
			cardsContainer.z = z;
			if ( overlaySprite )
				overlaySprite.z = z;
		}
	}
}