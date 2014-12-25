package duel
{
	import chimichanga.common.assets.AdvancedAssetManager;
	import duel.cards.behaviour.CreatureCardBehaviour;
	import duel.cards.Card;
	import duel.cards.CardFactory;
	import duel.gui.Gui;
	import duel.gui.GuiJuggler;
	import duel.gui.HandContainer;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Game extends DisplayObjectContainer implements IAnimatable
	{
		public static var current:Game;
		
		public var jugglerStrict:GuiJuggler;
		public var jugglerMild:GuiJuggler;
		
		public var gui:Gui;
		public var selection:Selection;
		
		public var p1:Player;
		public var p2:Player;
		
		public var bg:Background;
		public var p1side:PlayerSide;
		public var p2side:PlayerSide;
		
		//
		private var p1hand:HandContainer;
		
		public function Game()
		{
			current = this;
			
			//
			Starling.juggler.add( this );
			
			jugglerStrict = new GuiJuggler();
			jugglerMild = new GuiJuggler();
			
			//
			p1 = generatePlayer( "player1" );
			p2 = generatePlayer( "player2" );
			
			// VISUALS
			bg = new Background( assets.getTexture( "bg" ) );
			bg.onClickedCallback = onBgClicked;
			addChild( bg );
			
			const CHAR_SCALE:Number = 0.5;
			const CHAR_MARGIN_Y:Number = 40;
			
			var char1:Image = assets.generateImage( "char1" );
			char1.alignPivot( "right", "bottom" );
			char1.x = App.W;
			char1.y = App.H - CHAR_MARGIN_Y;
			char1.scaleX = CHAR_SCALE;
			char1.scaleY = CHAR_SCALE;
			addChild( char1 );
			
			var char2:Image = assets.generateImage( "char2" );
			char2.alignPivot( "right", "top" );
			char2.x = 0;
			char2.y = CHAR_MARGIN_Y;
			char2.scaleX = -CHAR_SCALE;
			char2.scaleY =  CHAR_SCALE;
			addChild( char2 );
			
			p2side = new PlayerSide( true );
			addChild( p2side );
			p2side.x = App.W * 0.50;
			p2side.y = App.H * 0.30;
			
			p1side = new PlayerSide( false );
			addChild( p1side );
			p1side.x = App.W * 0.50;
			p1side.y = App.H * 0.70;
			
			// GUI AND STUFF
			gui = new Gui();
			addChild( gui );
			
			selection = new Selection();
			
			p1hand = new HandContainer( p1.hand );
			p1hand.x = ( App.W - p1hand.maxWidth ) * 0.5;
			p1hand.y = App.H;
			addChild( p1hand );
			
			var c:Card;
			var i:int;
			for ( i = 0; i < 40; i++ ) 
			{
				c = CardFactory.produceCard( 0 );
				c.player = p1;
				c.flipped = true;
				jugglerStrict.delayCall( p1side.fieldDeck.cards.add, .4 + i * .010, c );
				//jugglerStrict.delayCall( p1side.addCardTo, .4 + i * .010, c, p1side.fieldDeck, true );
			}
			for ( i = 0; i < 25; i++ ) 
			{
				c = CardFactory.produceCard( 0 );
				c.player = p2;
				c.flipped = true;
				jugglerStrict.delayCall( p2side.fieldDeck.cards.add, .6 + i * .010, c );
				//jugglerStrict.delayCall( p2side.addCardTo, .4 + i * .010, c, p2side.fieldDeck, true );
			}
			
		}
		
		public function destroy():void 
		{
			Starling.juggler.remove( this );
			removeFromParent( true );
		}
		
		// INTERACTION
		
		public function onFieldClicked( field:Field ):void
		{
			if ( selectedCard )
			{
				var c:Card = selectedCard;
				selectCard( null );
				
				//if ( selectedCard.field != null && !side1.containsField( field ) )
				if ( c.field != null )
				{
					if ( c.type.isCreature )
						performCardAttack( c );
				}
				else
				{
					if ( canPlayHere( c, field ) )
					{
						var flipped:Boolean = c.behaviour.startFaceDown;
						field.container.addCardTo( c, field, flipped );
					}
				}
			}
		}
		
		public function onCardClicked( card:Card ):void
		{
			if ( card.field != null )
			{
				if ( card.field.isDeckStack )
				{
					trace( "DRAW" );
					p1.hand.add( card );
					return;
				}
			}
			//if ( card.field != null ){card.flipped = !card.flipped;return;}
			selectCard( selectedCard == card ? null : card );
		}
		
		public function onCardRollOver( card:Card ):void
		{
			if ( !interactable ) return;
			if ( card.flipped && card.player == p1 ) {
				card.sprite.peekIn();
			}
		}
		
		public function onCardRollOut( card:Card ):void
		{
			if ( !interactable ) return;
			if ( card.flipped && card.player == p1 ) {
				card.sprite.peekOut();
			}
		}
		
		private function onBgClicked():void
		{
			selectCard( null );
		}
		
		// GAMEPLAY
		
		public function endTurn():void
		{
			
		}
		
		public function performCardAttack( card:Card ):void
		{
			card.flipped = false;
			damagePlayer( card.player == p1 ? p2 : p1, CreatureCardBehaviour( card.behaviour ).attack );
		}
		
		public function damagePlayer( player:Player, amount:int ):void
		{
			player.lp -= amount;
		}
		
		//
		
		private function selectCard( card:Card ):void {
			if ( selectedCard != null && p1hand.contains( selectedCard.sprite ) )
			{
				p1hand.unshow( selectedCard );
			}
			
			selection.selectedCard = card;
			
			if ( selectedCard != null && p1hand.contains( selectedCard.sprite ) )
			{
				p1hand.show( selectedCard );
			}
		}
		
		public function get selectedCard():Card { return selection.selectedCard }
		
		//
		
		private function generatePlayer( name:String ):Player
		{
			var p:Player = new Player();
			p.name = name;
			p.lp = 60;
			
			var c:Card;
			while ( p.hand.count < 12 )
			{
				c = CardFactory.produceCard( 0 );
				c.player = p;
				p.hand.add( c );
				c.flipped = false;
			}
			
			return p;
		}
		
		public function advanceTime( time:Number ):void
		{
			jugglerStrict.advanceTime( time );
			jugglerMild.advanceTime( time );
			
			gui.advanceTime( time );
			p1hand.advanceTime( time );
		}
		
		public function get interactable():Boolean
		{
			return jugglerStrict.isIdle;
		}
		
		// QUESTIONS
		
		public function canPlayHere( card:Card, field:Field ):Boolean
		{
			//if ( !side1.contains( field ) )
				//return false;
			if ( field.allowedCardType != card.type )
				return false;
			return true;
		}
		
		//
		protected function get assets():AdvancedAssetManager
		{
			return App.assets
		}
	}
}