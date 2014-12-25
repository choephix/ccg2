package duel.cards
{
	import chimichanga.common.display.Sprite;
	import duel.cards.behaviour.CreatureCardBehaviour;
	import duel.G;
	import duel.GameSprite;
	import starling.animation.Transitions;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardSprite extends GameSprite
	{
		public var auraContainer:Sprite;
		
		private var back:Image;
		private var pad:Image;
		private var tf:TextField;
		private var title:TextField;
		
		private var pointerOver:Boolean;
		
		///
		private var _flippedness:Number = .0;
		
		//
		private var owner:Card;
		
		public function initialize( owner:Card ):void
		{
			this.owner = owner;
			
			// MAIN
			pad = assets.generateImage( "card", true, false );
			pad.color = owner.type.color;
			addChild( pad );
			
			title = new TextField( G.CARD_W, G.CARD_H, owner.name, "Franklin Gothic", 16, 0x330011, true );
			title.touchable = false;
			title.vAlign = "top";
			addChild( title );
			
			tf = new TextField( G.CARD_W, G.CARD_H, "", "", 16, 0x330011 );
			tf.touchable = false;
			addChild( tf );
			
			switch( owner.type )
			{
				case CardType.CREATURE:
					tf.text = CreatureCardBehaviour( owner.behaviour ).attack + "A";
					if ( CreatureCardBehaviour( owner.behaviour ).startFaceDown )
					{
						tf.color = 0x771133;
					}
					tf.fontName = "Impact";
					tf.hAlign = "left";
					tf.fontSize = 72;
					break;
				case CardType.TRAP:
					tf.text = "Very important trap set here like for trapping niggas and shit...";
					tf.fontName = "Gabriola";
					tf.fontSize = 15;
			}
			
			if ( owner.type == CardType.CREATURE ) {
				tf.text = CreatureCardBehaviour( owner.behaviour ).attack + "x";
				tf.fontSize = 53;
			}
			
			back = assets.generateImage( "card-back", false, false );
			addChild( back );
			
			alignPivot();
			
			// ..
			auraContainer = new Sprite();
			auraContainer.x = G.CARD_W * 0.5;
			auraContainer.y = G.CARD_H * 0.5;
			addChild( auraContainer );
			
			// ..
			addEventListener( TouchEvent.TOUCH, onTouch );
		}
		
		public function peekIn():void 
		{
			game.jugglerMild.xtween( back, 0.500, { alpha : 0.3 } );
		}
		
		public function peekOut():void 
		{
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
		
		internal function setFlipped( value:Boolean ):void 
		{
			//back.visible = value;
			game.jugglerMild.xtween( this, 0.150, 
				{
					flippedness : value ? -1.0 : 1.0 ,
					transition : Transitions.EASE_OUT
				} );
		}
		
		private function whileFlipping():void
		{
			back.visible = scaleX < 0.0;
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
		}
		
	}

}