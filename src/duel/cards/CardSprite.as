package duel.cards
{
	import chimichanga.common.display.Sprite;
	import chimichanga.global.utils.Colors;
	import duel.cards.behaviour.CreatureCardBehaviour;
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
		private var tf:TextField;
		private var title:TextField;
		
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
			
			
			
			title = new TextField( G.CARD_W, G.CARD_H, owner.name, "Calibri", 24, 0x53001B );
			title.touchable = false;
			title.autoScale = true;
			title.vAlign = "top";
			title.bold = true;
			title.color = 0x330011;
			addChild( title );
			
			tf = new TextField( G.CARD_W, G.CARD_H, "", "", 16, 0x330011 );
			tf.touchable = false;
			addChild( tf );
			
			switch( owner.type )
			{
				case CardType.CREATURE:
					tf.text = CreatureCardBehaviour( owner.behaviour ).attack + "";
					if ( CreatureCardBehaviour( owner.behaviour ).startFaceDown )
					{
						//tf.color = 0x771133;
					}
					tf.fontName = "Impact";
					tf.hAlign = "left";
					tf.fontSize = 64;
					break;
				case CardType.TRAP:
					tf.text = "Very important trap set here like for trapping niggas and shit...";
					tf.fontName = "Gabriola";
					tf.fontSize = 15;
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
			exhaustClock.x = G.CARD_W * 0.5;
			exhaustClock.y = G.CARD_H * 0.5;
			exhaustClock.visible = false;
			addChild( exhaustClock );
			
			// ..
			addEventListener( TouchEvent.TOUCH, onTouch );
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
			return;
			game.jugglerMild.xtween( back, 0.500, { delay : 0.500, alpha : 0.3 } );
		}
		
		public function peekOut():void 
		{
			return;
			game.jugglerMild.xtween( back, 0.250, { alpha : 1.0 } );
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var t:Touch = e.getTouch( this );
			
			if ( t == null ) {
				if ( pointerOver ) {
					pointerOver = false;
					game.onCardRollOut( owner );
				}
				return;
			}
			
			if ( t.phase == TouchPhase.HOVER ) {
				if ( !pointerOver ) {
					pointerOver = true;
					game.onCardRollOver( owner );
				}
			} 
			else
			if ( t.phase == TouchPhase.ENDED ) {
				game.onCardClicked( owner );
			} 
		}
		
		// FLIPPING
		internal function setFlipped( faceDown:Boolean ):void 
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
			
			pad.visible = !back.visible;
			tf.visible = !back.visible;
			title.visible = !back.visible;
		}
		
	}

}