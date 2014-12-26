package duel
{
	import chimichanga.common.assets.AdvancedAssetManager;
	import chimichanga.global.app.Platform;
	import duel.cardlots.Field;
	import duel.cardlots.Hand;
	import duel.cards.behaviour.CreatureCardBehaviour;
	import duel.cards.Card;
	import duel.cards.CardFactory;
	import duel.gui.Gui;
	import duel.gui.GuiJuggler;
	import duel.cards.visual.HandSprite;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Game extends DisplayObjectContainer implements IAnimatable
	{
		public static var current:Game;
		
		public var currentPlayer:Player;
		
		//
		public var jugglerStrict:GuiJuggler;
		public var jugglerMild:GuiJuggler;
		
		public var gui:Gui;
		public var selection:Selection;
		
		public var p1:Player;
		public var p2:Player;
		
		public var bg:Background;
		
		//
		public var cardsAll:Vector.<Card>;
		public var cardsInPlay:Vector.<Card>;
		
		public function Game()
		{
			current = this;
			initialize();
		}
		
		private function initialize():void
		{
			Starling.juggler.add( this );
			
			jugglerStrict = new GuiJuggler();
			jugglerMild = new GuiJuggler();
			
			cardsAll = new Vector.<Card>();
			cardsInPlay = new Vector.<Card>();
			
			//
			p1 = generatePlayer( "player1" );
			p2 = generatePlayer( "player2" );
			p1.opponent = p2;
			p2.opponent = p1;
			
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
			
			p2.tableSide = new TableSide( p2, true );
			p2.tableSide.x = App.W * 0.50;
			p2.tableSide.y = App.H * 0.30;
			addChild( p2.tableSide );
			
			p1.tableSide = new TableSide( p1, false );
			p1.tableSide.x = App.W * 0.50;
			p1.tableSide.y = App.H * 0.70;
			addChild( p1.tableSide );
			
			// GUI AND STUFF
			gui = new Gui();
			addChild( gui );
			
			selection = new Selection();
			
			p1.handSprite = new HandSprite( p1.hand );
			p1.handSprite.x = ( App.W - p1.handSprite.maxWidth ) * 0.5;
			p1.handSprite.y = App.H;
			addChild( p1.handSprite );
			
			p2.handSprite = new HandSprite( p2.hand );
			p2.handSprite.y = 0;
			p2.handSprite.x = ( App.W - p2.handSprite.maxWidth ) * 0.5;
			addChild( p2.handSprite );
			
			// PREPARE GAMEPLAY
			var time:Number = 0.4;
			var c:Card;
			var i:int;
			for ( i = 0; i < 52; i++ ) 
			{
				time += .010;
				c = generateCard();
				c.owner = p1;
				c.faceDown = true;
				jugglerStrict.delayCall( p1.deck.addCard, time, c );
			}
			for ( i = 0; i < 25; i++ ) 
			{
				time += .010;
				c = generateCard();
				c.owner = p2;
				c.faceDown = true;
				jugglerStrict.delayCall( p2.deck.addCard, time, c );
			}
			for ( i = 0; i < 12; i++ ) 
			{
				time += .030;
				jugglerStrict.delayCall( p1.draw, time );
				jugglerStrict.delayCall( p2.draw, time+0.017 );
			}
			
			
			// START GAME
			currentPlayer	= p1;
			currentPlayer.opponent = p2;
		}
		
		public function destroy():void 
		{
			dispatchEventWith( GameEvents.DESTROY );
			Starling.juggler.remove( this );
			removeFromParent( true );
		}
		
		// INTERACTION
		public function onFieldClicked( field:Field ):void
		{
			if ( selectedCard )
			{
				var c:Card = selectedCard;
				var p:Player = c.controller;
				
				selectCard( null );
				
				if ( field.type.isGraveyard && field.owner == p )
				{
					p.discard( c );
					return;
				}
				
				if ( c.isInPlay )
				{
					if ( c.type.isCreature && field.owner == p.opponent )
						performCardAttack( c );
				}
				else
				if ( currentPlayer.hand.containsCard( c ) )
				{
					if ( canPlayHere( c, field ) )
					{
						field.addCard( c );
						var flipped:Boolean = c.behaviour.startFaceDown;
					}
				}
			}
		}
		
		public function onCardClicked( card:Card ):void
		{
			if ( currentPlayer.deck.containsCard( card ) ) {
				currentPlayer.draw();
				return;
			}
			
			if ( currentPlayer.grave.containsCard( card ) ) {
				trace( "RESURRECT" );
				currentPlayer.grave.removeCard( card );
				currentPlayer.hand.addCard( card );
				card.faceDown = false;
				return;
			}
			
			if ( currentPlayer.hand.containsCard( card ) ) {
				if ( canSelect( card ) ) selectCard( selectedCard == card ? null : card );
				return;
			}
			
			//if ( card.field != null ){card.flipped = !card.flipped;return;}
			if ( canSelect( card ) ) selectCard( selectedCard == card ? null : card );
			return;
		}
		
		public function onCardRollOver( card:Card ):void
		{
			if ( !interactable ) return;
			dispatchEventWith( GameEvents.HOVER, false, card );
		}
		
		public function onCardRollOut( card:Card ):void
		{
			if ( !interactable ) return;
			dispatchEventWith( GameEvents.UNHOVER, false, card );
		}
		
		private function onBgClicked():void
		{
			selectCard( null );
		}
		
		// GAMEPLAY
		
		public function endTurn():void
		{
			dispatchEventWith( GameEvents.TURN_END );
			var p:Player = currentPlayer;
			currentPlayer = currentPlayer.opponent;
			currentPlayer.opponent = p;
			p = null;
			dispatchEventWith( GameEvents.TURN_START );
			
			currentPlayer.draw();
		}
		
		public function performCardAttack( card:Card ):void
		{
			card.faceDown = false;
			//finishAttack(); return;
			
			var q:Quad = new Quad( 50, 50, 0xFF0000 );
			card.sprite.parent.parent.addChild( q );
			q.alpha = .50;
			q.x = card.sprite.parent.x;
			q.y = card.sprite.parent.y;
			q.alignPivot();
			jugglerStrict.tween( q, .100, { y : q.y - 400, onComplete : finishAttack } );
			
			function finishAttack():void {
				q.removeFromParent( true );
				
				damagePlayer( card.controller.opponent, CreatureCardBehaviour( card.behaviour ).attack );
				card.exhausted = true;
			}
		}
		
		public function damagePlayer( player:Player, amount:int ):void
		{
			player.lp -= amount;
		}
		
		public function endGame():void
		{
			var q:Quad = new Quad( App.W, App.H, 0x0 );
			q.alpha = 0;
			addChild( q );
			touchable = false;
			
			Starling.juggler.remove( this );
			Starling.juggler.tween( q, .440, { alpha : 1.0, onComplete : destroy } );
		}
		
		//
		private function selectCard( card:Card ):void {
			if ( selectedCard != null )
				dispatchEventWith( GameEvents.SELECT, false, card );
			
			selection.selectedCard = card;
			
			if ( selectedCard != null )
				dispatchEventWith( GameEvents.DESELECT, false, card );
		}
		
		public function get selectedCard():Card { return selection.selectedCard }
		
		//
		private function generatePlayer( name:String ):Player
		{
			var p:Player = new Player();
			p.name = name;
			p.lp = 60;
			return p;
		}
		
		private function generateCard():Card {
			var c:Card = CardFactory.produceCard( 0 );
			cardsAll.push( c );
			return c;
		}
		
		//
		public function advanceTime( time:Number ):void
		{
			jugglerStrict.advanceTime( time );
			jugglerMild.advanceTime( time );
			
			gui.advanceTime( time );
			p1.handSprite.advanceTime( time );
			p2.handSprite.advanceTime( time );
			
			//bg.visible = interactable;
			this.touchable = interactable;
		}
		
		public function get interactable():Boolean
		{
			return jugglerStrict.isIdle;
		}
		
		// QUESTIONS
		public function canPlayHere( card:Card, field:Field ):Boolean
		{
			if ( card.controller != field.owner ) return false;
			return true;
		}
		
		public function canSelect( card:Card ):Boolean {
			if ( card.controller != currentPlayer ) return false;
			if ( card.exhausted ) return false;
			return true;
		}
		
		//
		protected function get assets():AdvancedAssetManager
		{
			return App.assets
		}
	}
}