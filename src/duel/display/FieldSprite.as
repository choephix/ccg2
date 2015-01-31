package duel.display {
	import chimichanga.common.display.Sprite;
	import chimichanga.debug.logging.error;
	import duel.display.cardlots.DeckStackSprite;
	import duel.display.cardlots.GraveStackSprite;
	import duel.display.cardlots.StackSprite;
	import duel.display.fields.CreatureFieldOverlay;
	import duel.display.fields.FieldSpriteGuiState;
	import duel.G;
	import duel.GameSprite;
	import duel.gui.GuiEvents;
	import duel.table.CreatureField;
	import duel.table.Field;
	import duel.table.CardLotType;
	import duel.table.IndexedField;
	import starling.animation.IAnimatable;
	import starling.animation.Transitions;
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
		public var fieldTipsParent:Sprite;
		private var quad:Quad;
		private var image:Image;
		private var lockIcon:Image;
		private var aura:CardAura;
		private var overlayC:CreatureFieldOverlay;
		private var overTip:FieldSpriteOverTip;
		
		public var field:Field;
		
		private var _isLocked:Boolean = false;
		private var _showAura:Boolean;
		private var _guiState:FieldSpriteGuiState = FieldSpriteGuiState.NONE;
		private var _z:Number;
		
		public function initialize( field:Field, color:uint ):void
		{
			image = assets.generateImage( "field", false, true );
			image.blendMode = "add";
			image.color = color; 
			addChild( image );
			
			if ( field is IndexedField )
			{
				lockIcon = assets.generateImage( "iconLock", false, true );
				lockIcon.alpha = .0;
				addChild( lockIcon );
			}
			
			if ( field is CreatureField )
			{
				overlayC = new CreatureFieldOverlay();
				addChild( overlayC );
			}
			
			var CardStackT:Class = GetCardStackClassForFieldType( field.type );
			cardsContainer = new CardStackT( field );
			
			quad = new Quad( G.CARD_W, G.CARD_H, 0xFF0000 );
			quad.alpha = .0;
			//quad.alpha = .1;
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
			
			if ( lockIcon != null )
				setLockIconVisibility( IndexedField( field ).isLocked );
			
			if ( aura != null )
				aura.visible = _showAura && game.interactable;
		}
		
		// VISUALS
		
		public function setGuiState( state:FieldSpriteGuiState ):void
		{
			if ( _guiState == state )
				return;
			
			_guiState = state;
			
			if ( aura == null )
			{
				aura = new CardAura( "card-aura-field" );
				aura.touchable = false;
				aura.visible = false;
				aura.x = x;
				aura.y = y;
				aura.scale = _z;
				fieldTipsParent.addChild( aura );
			}
			if ( overTip == null )
			{
				overTip = new FieldSpriteOverTip();
				overTip.x = x;
				overTip.y = y;
				overTip.scaleX = 1.5;
				overTip.scaleY = 1.5;
				overTip.touchable = false;
				fieldTipsParent.addChild( overTip );
			}
			
			overTip.visible = 
			_showAura = state != FieldSpriteGuiState.NONE;
			
			if ( state != FieldSpriteGuiState.NONE )
			{
				switch ( state ) 
				{
					case FieldSpriteGuiState.SELECTABLE:
						setShit( 0xFFFFFF, "", 0 );
						break;
					
					case FieldSpriteGuiState.NORMAL_SUMMON:
						setShit( 0xE7360A, "Summon\nHere", 0xcc9966 );
						break;
					case FieldSpriteGuiState.TRIBUTE_SUMMON:
						setShit( 0xE7360A, "Tribute\nSummon!", 0xFFFFFF );
						break;
					case FieldSpriteGuiState.SET_TRAP:
						setShit( 0x6622ff, "Set Trap\nHere", 0xFF71BF );
						break;
					case FieldSpriteGuiState.REPLACE_TRAP:
						setShit( 0x6622ff, "Replace\nTrap", 0xFF71BF );
						break;
						
					case FieldSpriteGuiState.SAFE_FLIP:
						setShit( 0x9D9771, "Safe-Flip!", 0xFFFF80 );
						break;
					case FieldSpriteGuiState.RELOCATE_TO:
						setShit( 0x2266DD, "Move\nHere", 0x65D2FC );
						break;
					case FieldSpriteGuiState.ATTACK_DIRECT:
						setShit( 0xcc0011, "Attack\nDirectly!", 0xFFC600 );
						break;
					case FieldSpriteGuiState.ATTACK_CREATURE:
						setShit( 0xcc0011, "Attack!", 0xFFFFFF );
						break;
					default:
						error( "FieldSpriteGuiState = ?" );
				}
				
				if ( field.topCard )
					aura.rotation = field.topCard.sprite.rotation;
				else
					aura.rotation = .0;
			}
			
			function setShit( auraColor:uint, tipText:String, tipTextColor:uint ):void
			{
				aura.color = auraColor;
				aura.visible = auraColor > 0;
				overTip.text = tipText;
				overTip.color = tipTextColor;
				overTip.visible = tipTextColor > 0;
			}
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
		
		//
		private static function GetCardStackClassForFieldType( type:CardLotType ):Class
		{
			if ( type.isGraveyard ) return GraveStackSprite;
			if ( type.isDeck ) return DeckStackSprite;
			return StackSprite;
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
		}
	}
}