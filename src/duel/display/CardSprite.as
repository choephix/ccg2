package duel.display {
	import chimichanga.common.display.Sprite;
	import dev.Temp;
	import duel.cards.Card;
	import duel.G;
	import duel.GameSprite;
	import duel.gui.AnimatedTextField;
	import duel.gui.GuiEvents;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import starling.animation.IAnimatable;
	import starling.animation.Transitions;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	
	use namespace animation;
	/**
	 * ...
	 * @author choephix
	 */
	public class CardSprite extends GameSprite implements IAnimatable
	{
		public var auraContainer:Sprite;
		private var selectableAura:Image;
		private var selectedAura:Image;
		
		public var targetProps:TargetProps;
		
		private var quad:Quad;
		private var front:Sprite;
		private var back:Image;
		private var pad:Image;
		private var tfDescr:TextField;
		private var tfTitle:TextField;
		private var tfAttak:AnimatedTextField;
		private var tfDebug:TextField;
		
		///
		private var __attackSprite:Quad;
		private var __bloodSprite:Quad;
		
		private var _peekThrough:Boolean = false;
		private var _backTranslucency:Number = .0;
		private var _flippedness:Number = .0;
		private var _isFocused:Boolean = false;
		public var _isPressed:Boolean = false;
		public var isSelectable:Boolean = false;
		public var isSelected:Boolean = false;
		
		//
		private var card:Card;
		private static var helperRect:Rectangle = new Rectangle();
		
		public function initialize( card:Card ):void
		{
			this.card = card;
			
			juggler.add( this );
			
			// MAIN
			front = new Sprite();
			front.pivotX = G.CARD_W * 0.5;
			front.pivotY = G.CARD_H * 0.5;
			front.touchable = false;
			addChild( front );
			
			back = assets.generateImage( "card-back", true, true );
			back.touchable = false;
			addChild( back );
			
			auraContainer = new Sprite();
			auraContainer.touchable = false;
			addChild( auraContainer );
			
			selectableAura = new CardAura( "card-aura" );
			selectableAura.color = 0x669BEA;
			//selectableAura.color = 0xFFE064;
			//selectableAura.color = Temp.getColorForCard( card );
			selectableAura.blendMode = "add";
			selectableAura.touchable = false;
			selectableAura.alpha = .0;
			auraContainer.addChild( selectableAura );
			
			selectedAura = assets.generateImage( "card-aura-selected", false, true );
			selectedAura.color = Temp.getColorForCard( card );
			selectedAura.blendMode = "add";
			selectedAura.touchable = false;
			selectedAura.alpha = .0;
			auraContainer.addChild( selectedAura );
			
			// MAIN - FRONT
			pad = assets.generateImage( "card-front-bg", true, false );
			pad.color = Temp.getColorForCard( card );
			pad.x = .5 * ( G.CARD_W - pad.width );
			pad.y = .5 * ( G.CARD_H - pad.height );
			front.addChild( pad );
			
			var title:String = CONFIG::sandbox ? card.slug : card.name;
			tfTitle = new TextField( 500, G.CARD_H, title, "Arial Black", 24, 0x53001B );
			tfTitle.touchable = false;
			tfTitle.hAlign = "center";
			tfTitle.vAlign = "top";
			tfTitle.bold = true;
			tfTitle.color = 0x330011;
			tfTitle.pivotX = tfTitle.width * .5;
			tfTitle.x = G.CARD_W * .5;
			tfTitle.scaleX = Math.min( 1.0, G.CARD_W / tfTitle.textBounds.width - .05 );
			front.addChild( tfTitle );
			
			CONFIG::sandbox {
			tfDebug = new TextField( 480, 40, ""+card.uid+".", "Lucida Console", 12, 0x0054A8 );
			tfDebug.touchable = false;
			tfDebug.alignPivot();
			tfDebug.hAlign = "center";
			tfDebug.vAlign = "center";
			tfDebug.bold = true;
			tfDebug.x = G.CARD_W * .5;
			tfDebug.y = - 10;
			//front.addChild( tfDebug );
			}
			
			tfDescr = new TextField( G.CARD_W, G.CARD_H, "", "Verdana", 10, 0x330011 );
			tfDescr.touchable = false;
			tfDescr.autoScale = true;
			front.addChild( tfDescr );
			
			if ( card.isCreature )
			{
					tfDescr.bold = false;
					tfDescr.hAlign = "center";
					tfDescr.vAlign = "center";
					tfDescr.fontSize = 15;
					tfDescr.text = card.description == null ? "" : card.description;
					tfDescr.x = xx( .37 );
					tfDescr.y = yy( .50 );
					tfDescr.width  = xx( .63 );
					tfDescr.height = yy( .50 );
			
					tfAttak = new AnimatedTextField( 
									G.CARD_W, G.CARD_H,
									AnimatedTextField.DEFAULT_MARKER,
									"Impact", 90, 0x330011 );
					tfAttak.touchable = false;
					tfAttak.hAlign = "center";
					tfAttak.vAlign = "center";
					tfAttak.duration = .450;
					tfAttak.currentValue = card.statusC.currentPowerValue;
					front.addChild( tfAttak );
					tfAttak.x = .21 * G.CARD_W;
					tfAttak.y = .75* G.CARD_H;
					tfAttak.alignPivot();
			}
			else
			if ( card.isTrap )
			{
					tfDescr.text = card.description == null ? "?" : card.description;
					tfDescr.fontSize = 18;
					tfDescr.x = 0;
					tfDescr.y = 30;
					tfDescr.x = xx( .00 );
					tfDescr.y = yy( .50 );
					tfDescr.width  = xx( 1.0 );
					tfDescr.height = yy( .50 );
			}
			
			quad = new Quad( G.CARD_W, G.CARD_H, 0x0 );
			quad.alpha = .0;
			quad.alignPivot();
			addChild( quad );
			
			CONFIG::development
			{ quad.alpha = card.unimplemented ? .3 : .0 }
			// ..
			
			targetProps = new TargetProps();
			
			// ..
			alpha = .0;
			
			updateData();
			
			function xx( ratio:Number ):Number { return ratio * G.CARD_W }
			function yy( ratio:Number ):Number { return ratio * G.CARD_H }
			
			quad.addEventListener( TouchEvent.TOUCH, onTouch );
			touchable = true;
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			// UPDATE FOCUS
			
			var t:Touch = e.getTouch( quad );
			
			if ( t == null )
			{
				setIsFocused( false );
				return;
			}
			
			setIsFocused( t.phase != TouchPhase.ENDED );
			
			switch ( t.phase )
			{
				case TouchPhase.BEGAN:
					if ( !isPressed )
						setIsPressed( true );
					break;
				case TouchPhase.MOVED:
					if ( isPressed )
					{
						// reset "isPressed" state when user dragged too far away after pushing
						getBounds( stage, helperRect );
						if (t.globalX < helperRect.x - 10 ||
							t.globalY < helperRect.y - 10 ||
							t.globalX > helperRect.x + helperRect.width + 10 ||
							t.globalY > helperRect.y + helperRect.height + 10)
						{
							setIsPressed( false );
						}
					}
					break;
				case TouchPhase.ENDED:
					if ( isPressed )
					{
						guiEvents.dispatchEventWith( GuiEvents.CARD_CLICK, false, card );
						setIsPressed( false );
					}
					break;
			}
			
		}
		
		public function advanceTime(time:Number):void 
		{
			if ( time > .033 )
				time = .033;
			
			_peekThrough = card.faceDown && isFocused && game.p1.knowsCard( card );
			_backTranslucency = lerp( _backTranslucency, _peekThrough ? .75 : .0, .15 );
			
			_flippedness = lerp( _flippedness, card.faceDown ? -1.0 : 1.0, card.faceDown ? .18 : .27 );
			
			front.visible	= _flippedness > .0 || _backTranslucency > .0;
			back.visible	= _flippedness < .0;
			
			auraContainer.scaleX = .25 + .75 * Math.abs( _flippedness );
			
			selectableAura.visible = true;
			selectableAura.alpha = lerp ( selectableAura.alpha, 
				( game.interactable && isSelectable ? 1.0 : 0.0 ), .08 );
				//game.interactable && isSelectable && ( !isSelected || !card.isInPlay );
				
			selectedAura.alpha = lerp ( selectedAura.alpha, 
				( game.interactable && isSelected ? 1.0 : 0.0 ), .11 );
			selectedAura.rotation = y > 100 ? .0 : Math.PI;
			
			if ( front.visible )
			{
				front.scaleX = Math.abs( _flippedness );
				updateData();
				if ( tfAttak != null )
					tfAttak.advanceTime( time );
			}
			
			if ( back.visible )
			{
				back.scaleX = Math.abs( _flippedness );
				back.alpha = game.interactable ? 1.0 - _backTranslucency : 1.0;
			}
		}
		
		internal function updateData():void 
		{
			if ( card.isCreature )
			{
				if ( !card.faceDown ) {
					tfAttak.targetValue = card.statusC.currentPowerValue;
					//tfDescr.text = card.statusC.toString();
				}
			}
			//flatten();
		}
		
		// ANIMATIONS
		private function assertAnimAttackSpriteExists():void
		{
			if ( __attackSprite != null ) return;
			__attackSprite = assets.generateImage( "hadouken", false, true );
			__attackSprite.alignPivot();
			if ( isTopSide ) {
				__attackSprite.rotation = Math.PI;
			}
			addChild( __attackSprite );
		}
		private function destroyAnimAttackSprite():void
		{
			if ( __attackSprite == null ) return;
			__attackSprite.removeFromParent( true );
			__attackSprite = null;
		}
		animation function animAttackPrepare():void 
		{
			assertAnimAttackSpriteExists();
			__attackSprite.scaleX = .25;
			__attackSprite.scaleY = .25;
			__attackSprite.alpha = .0;
			jugglerStrict.tween( __attackSprite, .240,
				{
					transition : Transitions.EASE_OUT_BACK, // EASE_IN EASE_OUT_BACK
					alpha  : 1.0,
					scaleX : 1.0,
					scaleY : 1.0
				} );
		}
		animation function animAttackPerform():void 
		{
			assertAnimAttackSpriteExists();
			jugglerStrict.tween( __attackSprite, .330,
				{
					transition : Transitions.EASE_IN_BACK, // EASE_IN EASE_IN_BACK
					y : __attackSprite.y + 200 * ( isTopSide ? 1.0 : -1.0 ),
					scaleX : 2.0,
					scaleY : 2.0,
					alpha : .0,
					onComplete : destroyAnimAttackSprite
				} );
		}
		animation function animAttackAbort():void 
		{
			if ( __attackSprite == null ) return;
			jugglerStrict.tween( __attackSprite, .240,
				{
					transition : Transitions.EASE_OUT,
					alpha  : .0,
					scaleX : .9,
					scaleY : .9,
					onComplete : destroyAnimAttackSprite
				} );
		}
		animation function animSummon():void 
		{
			var q:Quad = assets.generateImage( "ring", false, true );
			q.color = 0xCF873F;
			q.alpha = .3;
			card.indexedField.sprite.addChild( q );
			//jugglerStrict.tween( q, .400,
			juggler.tween( q, .400,
				{ 
					alpha: .0, 
					scaleX: 5,
					scaleY: 5,
					onComplete : q.removeFromParent,
					onCompleteArgs : [true]
				} );
		}
		animation function animRelocation():void 
		{
			jugglerStrict.tween( this, .600,
				{ 
					scaleX: 1.2,
					scaleY: 1.2,
					transition : Transitions.EASE_OUT_ELASTIC
				} );
		}
		animation function animRelocationCompleteOrAbort():void 
		{
			this.scaleX = 1.0;
			this.scaleY = 1.0;
			this.alpha = 1.0;
		}
		animation function animFlipEffect():void
		{
			animBlink( true, 0xFF8030 );
		}
		animation function animTrapEffect():void
		{
			animBlink( true, 0x60B0FF );
		}
		animation function animSpecialEffect():void
		{
			animBlink( true, 0xFFD060 );
		}
		animation function animDamageAbort():void
		{
			animBlink( true, 0x104050 );
		}
		animation function animDamageOnly():void
		{
			//animBlink( false, 0xFFAEAE ).blendMode = BlendMode.MULTIPLY;
		}
		animation function animDie():void 
		{
			setAsTopChild();
			
			animBlink( false, 0xB00000 ).blendMode = BlendMode.NORMAL;
			
			__bloodSprite = assets.generateImage( "card-damage" );
			__bloodSprite.alignPivot();
			__bloodSprite.blendMode = BlendMode.MULTIPLY;
			addChild( __bloodSprite );
			juggler.xtween( __bloodSprite, 12.0,
				{ 
					delay: 4.0,
					alpha: .0, 
					onComplete : __bloodSprite.removeFromParent,
					onCompleteArgs : [true]
				} );
			
			jugglerStrict.xtween( this, .240, { 
					y : y - 50 * ( isTopSide ? 1.0 : -1.0 ),
					rotation : Math.random() - .5,
					transition : Transitions.EASE_OUT
				} );
			
			destroyAnimAttackSprite();
		}
		animation function animDie2():void 
		{
			setAsTopChild();
			
			animBlink( false, 0xB00000 ).blendMode = BlendMode.NORMAL;
			
			__bloodSprite = assets.generateImage( "card-damage" );
			__bloodSprite.alignPivot();
			__bloodSprite.blendMode = BlendMode.MULTIPLY;
			addChild( __bloodSprite );
			juggler.xtween( __bloodSprite, 12.0,
				{ 
					delay: 4.0,
					alpha: .0, 
					onComplete : __bloodSprite.removeFromParent,
					onCompleteArgs : [true]
				} );
			destroyAnimAttackSprite();
		}
		
		public function animFadeToNothing( dispose:Boolean ):void 
		{
			juggler.xtween( this, .150, { 
					y : y - 50,
					alpha : .0,
					//transition : Transitions.EASE_IN,
					onComplete : onComplete
				} );
			function onComplete():void
			{
				if ( !dispose )
					return;
				removeFromParent( true );
			}
		}
		animation function resetAnimState():void
		{
			destroyAnimAttackSprite();
			jugglerStrict.removeTweens( this );
			this.scaleX = 1.0;
			this.scaleY = 1.0;
			this.alpha = 1.0;
		}
		private function animBlink( strict:Boolean, color:uint = 0xFFFFFF ):Quad
		{
			var q:Quad = assets.generateImage( "card-blink-glow" );
			addChild( q );
			q.alignPivot();
			q.blendMode = BlendMode.ADD;
			q.color = color;
			q.alpha = .999;
			( strict ? jugglerStrict : juggler ).tween( q, .500,
				{ 
					alpha: .0, 
					onComplete : q.removeFromParent,
					onCompleteArgs : [true]
				} );
			return q;
		}
		public function setAsTopChild():void
		{
			parent.setChildIndex( this, parent.numChildren - 1 );
		}
		
		// OTHER
		public function get isTopSide():Boolean
		{
			return card.controller == game.p2;
		}
		
		public function get isFocused():Boolean 
		{
			return _isFocused;
		}
		
		private function setIsFocused( value:Boolean ):void 
		{
			if ( _isFocused == value )
				return;
			
			_isFocused = value;
			game.guiEvents.dispatchEventWith( value ? GuiEvents.CARD_FOCUS : GuiEvents.CARD_UNFOCUS, false, card );
			Mouse.cursor = value && ( isSelectable || isSelected ) ? MouseCursor.BUTTON : MouseCursor.AUTO;
		}
		public function get isPressed():Boolean 
		{
			return _isPressed;
		}
		
		private function setIsPressed( value:Boolean ):void 
		{
			_isPressed = value;
			quad.alpha = value ? .2 : .0;
		}
		
		//
	}
}

class TargetProps
{
	public var x:Number;
	public var y:Number;
	public var scale:Number;
	public var rotation:Number;
}