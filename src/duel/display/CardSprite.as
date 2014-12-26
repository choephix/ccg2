package duel.display {
	import chimichanga.common.display.Sprite;
	import chimichanga.global.utils.Colors;
	import duel.cards.behaviour.CardBehaviour;
	import duel.cards.behaviour.CreatureCardBehaviour;
	import duel.cards.Card;
	import duel.cards.CardType;
	import duel.G;
	import duel.GameSprite;
	import starling.animation.IAnimatable;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.display.Image;
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
		
		private var back:Image;
		private var pad:Image;
		private var tfDescr:TextField;
		private var tfTitle:TextField;
		private var tfAttak:TextField;
		
		private var pointerOver:Boolean;
		
		///
		private var _flippedness:Number = .0;
		private var _flipTween:Tween;
		
		//
		private var owner:Card;
		
		public function initialize( owner:Card ):void
		{
			this.owner = owner;
			this._flipTween = new Tween( this, 0 );
			
			game.jugglerMild.add( this );
			
			// MAIN
			pad = assets.generateImage( "card", true, false );
			pad.color = generateColor();
			addChild( pad );
			
			function generateColor():uint 
			{
				if ( owner.type == CardType.CREATURE )
				{
					return !owner.behaviour.startFaceDown
							?
							Colors.fromRGB( 1, .7 + Math.random() * 0.15, .4 )
							:
							Colors.fromRGB( 1, .5 + Math.random() * 0.10, .3 )
							;
				}
				if ( owner.type == CardType.TRAP ) 		
					//return Colors.fromRGB( 1, .3, .3+Math.random()*0.2 );
					return Colors.fromRGB( .7+Math.random()*0.2, .4, .5+Math.random()*0.3 );
				return 0xFFFFFF;
			}
			
			tfTitle = new TextField( G.CARD_W, G.CARD_H, owner.name, "Calibri", 24, 0x53001B );
			tfTitle.touchable = false;
			tfTitle.autoScale = true;
			tfTitle.vAlign = "top";
			tfTitle.bold = true;
			tfTitle.color = 0x330011;
			addChild( tfTitle );
			
			tfDescr = new TextField( G.CARD_W, G.CARD_H, "", "Verdana", 20, 0x330011 );
			tfDescr.touchable = false;
			addChild( tfDescr );
			
			tfAttak = new TextField( G.CARD_W, G.CARD_H, "", "", 16, 0x330011 );
			tfAttak.touchable = false;
			addChild( tfAttak );
			
			switch( owner.type )
			{
				case CardType.CREATURE:
					tfAttak.text = CreatureCardBehaviour( owner.behaviour ).attack + "";
					tfAttak.fontName = "Impact";
					tfAttak.hAlign = "left";
					tfAttak.fontSize = 64;
					
					tfDescr.text = CreatureCardBehaviour( owner.behaviour ).toString();
					tfDescr.bold = true;
					tfDescr.hAlign = "center";
					tfDescr.vAlign = "bottom";
					tfDescr.hAlign = "right";
					tfDescr.vAlign = "center";
					break;
				case CardType.TRAP:
					tfDescr.text = "Very important trap set here like for trapping niggas and shit...";
					tfDescr.fontSize = 14;
			}
			
			back = assets.generateImage( "card-back", true, false );
			addChild( back );
			
			alignPivot();
			
			// ..
			auraContainer = new Sprite();
			auraContainer.x = G.CARD_W * 0.5;
			auraContainer.y = G.CARD_H * 0.5;
			addChild( auraContainer );
			
			exhaustClock = assets.generateImage( "exhaustClock", false, true );
			exhaustClock.x = G.CARD_W * 0.75;
			exhaustClock.y = G.CARD_H * 0.50;
			exhaustClock.alpha = 0.0;
			addChild( exhaustClock );
			
			// ..
			addEventListener( TouchEvent.TOUCH, onTouch );
			
			setFlipped( owner.faceDown );
		}
		
		public function advanceTime(time:Number):void 
		{
			if ( !_flipTween.isComplete ) {
				_flipTween.advanceTime( time );
			}
		}
		
		//
		public function peekIn():void 
		{
			//back.alpha = 0.3; return;
			game.jugglerMild.xtween( back, 0.250, { delay : 0.100, alpha : 0.3 } );
		}
		
		public function peekOut():void 
		{
			//back.alpha = 1.0; return;
			game.jugglerMild.xtween( back, 0.100, { alpha : 1.0 } );
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var t:Touch = e.getTouch( this );
			
			if ( t == null ) {
				if ( pointerOver ) {
					pointerOver = false;
					game.onCardRollOut( owner );
					if ( owner.controller.controllable )
						peekOut();
				}
				return;
			}
			else
			if ( t.phase == TouchPhase.HOVER ) {
				if ( !pointerOver ) {
					pointerOver = true;
					game.onCardRollOver( owner );
					if ( owner.controller.controllable )
						peekIn();
				}
			}
			else
			if ( t.phase == TouchPhase.ENDED ) {
				game.onCardClicked( owner );
			} 
		}
		
		// FLIPPING
		public function setFlipped( faceDown:Boolean ):void 
		{
			_flipTween.reset( this, .150, Transitions.EASE_OUT );
			_flipTween.animate( "flippedness", faceDown ? -1.0 : 1.0 );
		}
		
		public function get flippedness():Number 
		{
			return _flippedness;
		}
		
		public function set flippedness(value:Number):void 
		{
			if ( _flippedness == value ) return;
			_flippedness = value;
			scaleX = Math.abs( value );
			
			back.visible = value < 0.0;
			
			//pad.visible = !back.visible;
			//tf.visible = !back.visible;
			//title.visible = !back.visible;
		}
		
	}

}