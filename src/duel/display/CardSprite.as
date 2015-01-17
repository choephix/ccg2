package duel.display {
	import chimichanga.common.display.Sprite;
	import chimichanga.global.utils.Colors;
	import dev.Temp;
	import duel.cards.Card;
	import duel.cards.CardType;
	import duel.display.utils.ColorScheme;
	import duel.G;
	import duel.GameSprite;
	import duel.gui.AnimatedTextField;
	import starling.animation.IAnimatable;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardSprite extends GameSprite implements IAnimatable
	{
		public var auraContainer:Sprite;
		private var exhaustClock:Image;
		public var selectableAura:Image;
		public var selectedAura:Image;
		
		private var front:Sprite;
		private var back:Image;
		private var pad:Image;
		private var tfDescr:TextField;
		private var tfTitle:TextField;
		private var tfAttak:AnimatedTextField;
		private var tfDebug:TextField;
		
		///
		private var _isSelectable:Boolean = false;
		private var _exhaustClockVisible:Boolean = false;
		private var _isFaceDown:Boolean = true;
		private var _flippedness:Number = .0;
		private var _flipTween:Tween;
		private var _peekThrough:Boolean;
		public var backTranslucency:Number = .0;
		
		private var __attackSprite:Quad;
		private var __bloodSprite:Quad;
		
		//
		private var card:Card;
		
		public function initialize( card:Card ):void
		{
			this.card = card;
			this._flipTween = new Tween( this, 0 );
			
			juggler.add( this );
			
			// MAIN
			front = new Sprite();
			front.pivotX = G.CARD_W * 0.5;
			front.pivotY = G.CARD_H * 0.5;
			addChild( front );
			
			back = assets.generateImage( "card-back", true, true );
			addChild( back );
			
			auraContainer = new Sprite();
			addChild( auraContainer );
			
			selectableAura = new CardAura();
			selectableAura.visible = false;
			selectableAura.color = 0x669BEA;
			//selectableAura.color = 0xFFE064;
			//selectableAura.color = Temp.getColorForCard( card );
			selectableAura.blendMode = "add";
			auraContainer.addChild( selectableAura );
			
			selectedAura = assets.generateImage( "card-selectable", false, true );
			selectedAura.visible = false;
			selectedAura.color = Temp.getColorForCard( card );
			selectedAura.blendMode = "add";
			auraContainer.addChild( selectedAura );
			
			exhaustClock = assets.generateImage( "exhaustClock", false, true );
			exhaustClock.x = G.CARD_W * 0.25;
			exhaustClock.y = G.CARD_H * 0.00;
			exhaustClock.alpha = 0.0;
			auraContainer.addChild( exhaustClock );
			
			// MAIN - FRONT
			pad = assets.generateImage( "card", true, false );
			pad.color = Temp.getColorForCard( card );
			front.addChild( pad );
			
			tfTitle = new TextField( 500, G.CARD_H, card.name, "Arial Black", 24, 0x53001B );
			tfTitle.touchable = false;
			tfTitle.hAlign = "center";
			tfTitle.vAlign = "top";
			tfTitle.bold = true;
			tfTitle.color = 0x330011;
			tfTitle.pivotX = tfTitle.width * .5;
			tfTitle.x = G.CARD_W * .5;
			tfTitle.scaleX = Math.min( 1.0, G.CARD_W / tfTitle.textBounds.width - .05 );
			front.addChild( tfTitle );
			
			tfDebug = new TextField( 480, 40, ""+card.uid+".", "Lucida Console", 12, 0x0054A8 );
			tfDebug.touchable = false;
			tfDebug.alignPivot();
			tfDebug.hAlign = "center";
			tfDebug.vAlign = "center";
			tfDebug.bold = true;
			tfDebug.x = G.CARD_W * .5;
			tfDebug.y = - 10;
			front.addChild( tfDebug );
			
			tfDescr = new TextField( G.CARD_W, G.CARD_H, "", "Verdana", 10, 0x330011 );
			tfDescr.touchable = false;
			tfDescr.autoScale = true;
			front.addChild( tfDescr );
			
			switch( card.type )
			{
				case CardType.CREATURE:
					tfDescr.bold = true;
					tfDescr.hAlign = "right";
					tfDescr.vAlign = "center";
					tfDescr.fontSize = 10;
					tfDescr.text = card.descr == null ? "" : card.descr;
					tfDescr.x = 50;
					tfDescr.y = 40;
					tfDescr.width  = G.CARD_W - tfDescr.x;
					tfDescr.height = G.CARD_H - tfDescr.y;
			
					tfAttak = new AnimatedTextField( 
									G.CARD_W, G.CARD_H,
									AnimatedTextField.DEFAULT_MARKER,
									"Impact", 72, 0x330011 );
					tfAttak.touchable = false;
					tfAttak.hAlign = "left";
					tfAttak.duration = .450;
					tfAttak.currentValue = card.statusC.currentPowerValue;
					front.addChild( tfAttak );
					break;
				case CardType.TRAP:
					tfDescr.text = card.descr == null ? "?" : card.descr;
					tfDescr.fontSize = 12;
					tfDescr.x = 0;
					tfDescr.y = 30;
					tfDescr.width  = G.CARD_W - tfDescr.x;
					tfDescr.height = G.CARD_H - tfDescr.y;
			}
			
			// ..
			
			// ..
			alpha = .0;
			
			updateData();
			setFaceDown( card.faceDown, false );
		}
		
		public function advanceTime(time:Number):void 
		{
			if ( _isFaceDown != card.faceDown )
				setFaceDown( card.faceDown, false );
			
			front.visible	= _flippedness > .0 || backTranslucency > .0;
			back.visible	= _flippedness < .0;
			
			auraContainer.scaleX = .25 + .75 * Math.abs( _flippedness );
			selectableAura.visible = _isSelectable && ( !selectedAura.visible || !card.isInPlay );
			
			if ( selectedAura.visible )
			{
				selectedAura.rotation = y > 100 ? .0 : Math.PI;
			}
			
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
				back.alpha = game.interactable ? 1.0 - backTranslucency : 1.0;
			}
		}
		
		internal function updateData():void 
		{
			if ( card.type.isCreature )
			{
				if ( !card.faceDown ) {
					tfAttak.targetValue = card.statusC.currentAttackValue;
					//tfDescr.text = card.statusC.toString();
				}
				
				setExhaustClockVisible( card.isInPlay && card.exhausted );
			}
		}
		
		private function setExhaustClockVisible( value:Boolean ):void 
		{
			if ( _exhaustClockVisible == value ) return;
			_exhaustClockVisible = value;
			juggler.xtween( exhaustClock, .500, { alpha : value ? 1.0 : .0 } );
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
			
			__bloodSprite = assets.generateImage( "card-blood" );
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
		
		/// Plays ste standard flip-up animation, but in a way that pauses gameplay processes during it
		animation function animSpecialFlip():void
		{
			setFaceDown( false, true );
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
			var q:Quad = assets.generateImage( "card-glow" );
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
		
		// FLIPPING
		protected function setFaceDown( faceDown:Boolean, strict:Boolean = false ):void 
		{
			_isFaceDown = faceDown;
			_flipTween.reset( this, .500, Transitions.EASE_OUT );
			_flipTween.animate( "flippedness", faceDown ? -1.0 : 1.0 );
			( strict ? jugglerStrict : juggler ).add( _flipTween );
			
			_peekThrough = false;
			backTranslucency = .0;
		}
		
		protected function get isFaceDown():Boolean
		{ return _isFaceDown }
		
		public function get flippedness():Number 
		{ return _flippedness }
		
		public function set flippedness(value:Number):void 
		{
			if ( _flippedness == value ) return;
			_flippedness = value;
		}
		
		// PEEKING
		public function get peekThrough():Boolean 
		{ return _peekThrough }
		
		public function set peekThrough( value:Boolean ):void 
		{
			if ( _peekThrough == value ) return;
			_peekThrough = value;
			juggler.tween( this, .330,
				{ 
					backTranslucency : value ? .9 : .0,
					transition : Transitions.EASE_OUT
				} );
		}
		
		// OTHER
		public function get isTopSide():Boolean
		{
			return card.controller == game.p2;
		}
		
		//
		public function get selectable():Boolean 
		{ return _isSelectable }
		
		public function set selectable(value:Boolean):void 
		{ _isSelectable = value }
		
	}

}