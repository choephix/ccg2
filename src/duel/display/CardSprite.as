package duel.display {
	import chimichanga.common.display.Sprite;
	import chimichanga.global.utils.Colors;
	import duel.cards.Card;
	import duel.cards.CardType;
	import duel.G;
	import duel.GameSprite;
	import starling.animation.IAnimatable;
	import starling.animation.Transitions;
	import starling.animation.Tween;
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
		public var exhaustClock:Image;
		
		private var front:Sprite;
		private var back:Image;
		private var pad:Image;
		private var tfDescr:TextField;
		private var tfTitle:TextField;
		private var tfAttak:TextField;
		
		///
		private var _flippedness:Number = .0;
		private var _flipTween:Tween;
		
		private var __attackSprite:Quad;
		
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
			
			exhaustClock = assets.generateImage( "exhaustClock", false, true );
			exhaustClock.x = G.CARD_W * 0.25;
			exhaustClock.y = G.CARD_H * 0.00;
			exhaustClock.alpha = 0.0;
			addChild( exhaustClock );
			
			// MAIN - FRONT
			pad = assets.generateImage( "card", true, false );
			pad.color = generateColor();
			front.addChild( pad );
			
			function generateColor():uint 
			{
				if ( card.type.isCreature )
				{
					return !card.behaviour.startFaceDown
							?
							Colors.fromRGB( 1, .7 + Math.random() * 0.15, .4 )
							:
							Colors.fromRGB( 1, .5 + Math.random() * 0.10, .3 )
							;
				}
				if ( card.type.isTrap ) 		
					//return Colors.fromRGB( 1, .3, .3+Math.random()*0.2 );
					return Colors.fromRGB( .7+Math.random()*0.2, .4, .5+Math.random()*0.3 );
				return 0xFFFFFF;
			}
			
			tfTitle = new TextField( 500, G.CARD_H, card.name, "Arial Black", 24, 0x53001B );
			tfTitle.touchable = false;
			tfTitle.hAlign = "center";
			tfTitle.vAlign = "top";
			tfTitle.bold = true;
			tfTitle.color = 0x330011;
			tfTitle.pivotX = tfTitle.width * .5;
			tfTitle.x = G.CARD_W * .5;
			tfTitle.scaleX = Number.min( 1.0, G.CARD_W / tfTitle.textBounds.width - .05 );
			front.addChild( tfTitle );
			
			tfDescr = new TextField( G.CARD_W, G.CARD_H, "", "Verdana", 10, 0x330011 );
			tfDescr.touchable = false;
			tfDescr.autoScale = true;
			front.addChild( tfDescr );
			
			tfAttak = new TextField( G.CARD_W, G.CARD_H, "", "", 16, 0x330011 );
			tfAttak.touchable = false;
			front.addChild( tfAttak );
			
			switch( card.type )
			{
				case CardType.CREATURE:
					tfDescr.bold = true;
					tfDescr.hAlign = "right";
					tfDescr.vAlign = "center";
					tfDescr.fontSize = 14;
					tfAttak.fontName = "Impact";
					tfAttak.hAlign = "left";
					tfAttak.fontSize = 64;
					break;
				case CardType.TRAP:
					tfDescr.text = card.descr == null ? "?" : card.descr;
					tfDescr.fontSize = 14;
			}
			
			// ..
			
			// ..
			addEventListener( TouchEvent.TOUCH, onTouch );
			
			updateData();
			setFaceDown( card.faceDown, false );
		}
		
		public function advanceTime(time:Number):void 
		{
			//if ( !_flipTween.isComplete )
				//_flipTween.advanceTime( time );
			
			updateData();
		}
		
		internal function updateData():void 
		{
			if ( card.type.isCreature && !card.faceDown ) {
				tfAttak.text = card.behaviourC.attack + "";
				tfDescr.text = card.behaviourC.toString();
			}
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var t:Touch = e.getTouch( this );
			
			if ( t == null ) return;
			
			if ( t.phase == TouchPhase.ENDED ) {
				game.onCardClicked( card );
			} 
		}
		
		//
		public function peekIn():void 
		{
			if ( !isFaceDown ) return;
			back.alpha = 0.3
			front.visible = true;
			front.scaleX = 1.0;
			//juggler.xtween( back, 0.250, { delay : 0.100, alpha : 0.3 } );
		}
		
		public function peekOut():void 
		{
			if ( !isFaceDown ) return;
			back.alpha = 1.0;
			front.visible = false;
			//juggler.xtween( back, 0.100, { alpha : 1.0 } );
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
			jugglerStrict.tween( __attackSprite, .240,
				{
					transition : Transitions.EASE_IN,
					y : __attackSprite.y + 200 * ( isTopSide ? 1.0 : -1.0 ), 
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
			jugglerStrict.tween( q, .400,
				{ 
					alpha: .0, 
					scaleX: 5,
					scaleY: 5,
					onComplete : q.removeFromParent,
					onCompleteArgs : [true]
				} );
		}
		
		animation function animDie():void 
		{
			var q:Quad = new Quad( G.CARD_W, G.CARD_H, 0xFF0000 );
			addChild( q );
			q.alignPivot();
			q.alpha = .50;
			jugglerStrict.tween( q, .200,
				{ 
					alpha: .0, 
					onComplete : q.removeFromParent,
					onCompleteArgs : [true]
				} );
			
			destroyAnimAttackSprite();
		}
		
		animation function animFlipEffect():void
		{
			var q:Quad = new Quad( G.CARD_W, G.CARD_H, 0xFFFFFF );
			addChild( q );
			q.alignPivot();
			q.alpha = .999;
			jugglerStrict.tween( q, .500,
				{ 
					alpha: .0, 
					onComplete : q.removeFromParent,
					onCompleteArgs : [true]
				} );
		}
		
		animation function animTrapEffect():void
		{
			var q:Quad = new Quad( G.CARD_W, G.CARD_H, 0xFFFFFF );
			addChild( q );
			q.alignPivot();
			q.alpha = .999;
			jugglerStrict.tween( q, .500,
				{ 
					alpha: .0, 
					onComplete : q.removeFromParent,
					onCompleteArgs : [true]
				} );
		}
		
		// FLIPPING
		public function setFaceDown( faceDown:Boolean, strict:Boolean = false ):void 
		{
			_flipTween.reset( this, .500, Transitions.EASE_OUT );
			_flipTween.animate( "flippedness", faceDown ? -1.0 : 1.0 );
			( strict ? jugglerStrict : juggler ).add( _flipTween );
		}
		
		public function get isFaceDown():Boolean
		{
			return _flippedness < .0;
		}
		
		public function get flippedness():Number 
		{
			return _flippedness;
		}
		
		public function set flippedness(value:Number):void 
		{
			if ( _flippedness == value ) return;
			_flippedness = value;
			
			front.visible	= value > .0;
			back.visible	= value < .0;
			
			if ( front.visible )
				front.scaleX = Math.abs( value );
				
			if ( back.visible )
				back.scaleX = Math.abs( value );
			
			auraContainer.scaleX = .25 + .75 * Math.abs( value );
		}
		
		public function get isTopSide():Boolean
		{
			return card.controller == game.p2;
		}
		
	}

}