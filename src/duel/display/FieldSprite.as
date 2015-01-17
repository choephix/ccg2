package duel.display {
	import chimichanga.common.display.Sprite;
	import duel.display.cardlots.DeckStackSprite;
	import duel.display.cardlots.GraveStackSprite;
	import duel.display.cardlots.StackSprite;
	import duel.display.fields.FieldSpriteGuiState;
	import duel.GameSprite;
	import duel.table.Field;
	import duel.table.CardLotType;
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
		public var fieldTipsParent:Sprite;
		private var image:Image;
		private var lockIcon:Image;
		private var aura:CardAura;
		private var overTip:FieldSpriteOverTip;
		
		public var field:Field;
		
		private var _isLocked:Boolean = false;
		private var _showAura:Boolean;
		private var _guiState:FieldSpriteGuiState = FieldSpriteGuiState.NONE;
		
		public function initialize( field:Field, color:uint ):void
		{
			image = assets.generateImage( "field", true, true );
			image.color = color; 
			addChild( image );
			
			aura = new CardAura( "card-sele2" );
			aura.visible = false;
			addChild( aura );
			
			if ( field is IndexedField )
			{
				lockIcon = assets.generateImage( "iconLock", false, true );
				lockIcon.alpha = .0;
				addChild( lockIcon );
			}
			
			var CardStackT:Class = GetCardStackClassForFieldType( field.type );
			cardsContainer = new CardStackT( field );
			
			this.field = field;
			field.sprite = this;
			
			game.juggler.add( this );
		}
		
		public function advanceTime( time:Number ):void 
		{
			if ( lockIcon != null )
				setLockIconVisibility( IndexedField( field ).isLocked );
			
			aura.visible = _showAura && game.interactable;
		}
		
		// VISUALS
		
		public function setGuiState( state:FieldSpriteGuiState ):void
		{
			if ( _guiState == state )
				return;
			
			if ( overTip == null )
			{
				overTip = new FieldSpriteOverTip();
				fieldTipsParent.addChild( overTip );
				overTip.x = x;
				overTip.y = y;
			}
			
			_guiState = state;
			
			overTip.visible = 
			_showAura = state != FieldSpriteGuiState.NONE;
			
			if ( state != FieldSpriteGuiState.NONE )
			{
				switch ( state ) 
				{
					case FieldSpriteGuiState.NORMAL_SUMMON:
						setShit( 0xE7360A, "Summon Here", 0xcc9966 );
						break;
					case FieldSpriteGuiState.TRIBUTE_SUMMON:
						setShit( 0xE7360A, "Tribute Summon!", 0xFFFFFF );
						break;
					case FieldSpriteGuiState.SET_TRAP:
						setShit( 0x6622ff, "Set Here", 0xFF71BF );
						break;
						
					case FieldSpriteGuiState.SAFE_FLIP:
						setShit( 0x000000, "Safe-Flip!", 0xFFFF80 );
						break;
					case FieldSpriteGuiState.RELOCATE_TO:
						setShit( 0x2266DD, "Move Here", 0x65D2FC );
						break;
					case FieldSpriteGuiState.ATTACK_DIRECT:
						setShit( 0xcc0011, "Attack Directly!", 0xFFC600 );
						break;
					case FieldSpriteGuiState.ATTACK_CREATURE:
						setShit( 0xcc0011, "Attack!", 0xFF8000 );
						break;
					default:
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
	}
}