package duel.display.fields 
{
	import chimichanga.debug.logging.error;
	import duel.cards.Card;
	import duel.display.CardAura;
	import duel.display.FieldSpriteOverTip;
	import duel.G;
	import duel.GameSprite;
	import duel.table.CreatureField;
	import duel.table.IndexedField;
	import starling.animation.IAnimatable;
	import starling.animation.Transitions;
	import starling.display.Image;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class IndexedFieldOverlay extends GameSprite implements IAnimatable
	{
		private var field:IndexedField;
		private var _z:Number = 1.0;
		
		private var _isLocked:Boolean = false;
		private var _isCardExhausted:Boolean = false;
		private var _showAura:Boolean;
		private var _showTip:Boolean;
		
		private var aura:CardAura;
		private var overTip:FieldSpriteOverTip;
		private var lockIcon:Image;
		private var exhaustClock:Image;
		
		public function initialize( field:IndexedField ):void
		{
			this.field = field;
			
			juggler.add( this );
			
			aura = new CardAura( "card-aura-field" );
			aura.touchable = false;
			aura.alpha = 0.0;
			aura.x = x;
			aura.y = y;
			aura.scale = _z;
			addChild( aura );
			
			exhaustClock = assets.generateImage( "exhaustClock", false, true );
			exhaustClock.x = G.CARD_W * 0.25;
			exhaustClock.y = G.CARD_H * 0.00;
			exhaustClock.alpha = 0.0;
			exhaustClock.touchable = false;
			addChild( exhaustClock );
			
			lockIcon = assets.generateImage( "iconLock", false, true );
			lockIcon.alpha = .0;
			addChild( lockIcon );
			
			overTip = new FieldSpriteOverTip();
			overTip.touchable = false;
			overTip.alpha = 0.0;
			overTip.x = x;
			overTip.y = y;
			overTip.scaleX = 1.5;
			overTip.scaleY = 1.5;
			addChild( overTip );
		}
		
		public function advanceTime(time:Number):void 
		{
			// FIELD LOCK
			if (  _isLocked != field.isLocked )
			{
				_isLocked = field.isLocked;
				setLockIconVisibility( _isLocked );
			}
			
			// CREATURE EXHAUSTED
			_isCardExhausted = !field.isEmpty && field.topCard.type.isCreature && field.topCard.exhausted;
			exhaustClock.alpha = lerp( exhaustClock.alpha, 
				( _isCardExhausted ? 1.0 : 0.0 ), .1 );
			
			aura.alpha = lerp ( aura.alpha, game.interactable && _showAura ? 1.0 : 0.0, .1 );
			if ( game.interactable && _showTip && overTip.alpha < .1 )
			{
				overTip.alpha = .1;
				overTip.scaleX = 1;
				overTip.scaleY = 1;
				juggler.xtween( overTip, .690, { scaleX: 1.5, scaleY: 1.5, transition : Transitions.EASE_OUT_ELASTIC } );
			}
			overTip.alpha = game.interactable && _showTip ? 1.0 : 0.0;
			
			//
			return; //////////////////////////////////////
			
			if ( field.topCard )
			{
				aura.x = field.topCard.sprite.x - G.CARD_W * .5;
				aura.y = field.topCard.sprite.y - G.CARD_H * .5;
				aura.rotation = field.topCard.sprite.rotation;
			}
			else
			{
				aura.x = .0;
				aura.y = .0;
				aura.rotation = .0;
			}
		}
		
		public function setLockIconVisibility( value:Boolean ):void 
		{
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
		
		public function setGuiState( state:FieldSpriteGuiState ):void
		{
			switch ( state ) 
			{
				case FieldSpriteGuiState.NONE:
					setShit( 0, "", 0 );
					break;
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
		}
		
		public function setShit( auraColor:uint, tipText:String, tipTextColor:uint ):void
		{
			_showAura = auraColor > 0;
			if ( _showAura ) 
				aura.color = auraColor;
			
			overTip.text = tipText;
			_showTip = tipTextColor > 0;
			if ( _showTip )
				overTip.color = tipTextColor;
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
			//aura.scale = _z;
		}
	}
}