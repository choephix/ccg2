package duel
{
	import chimichanga.common.assets.AdvancedAssetManager;
	import dev.ProcessManagementInspector;
	import duel.cards.behaviour.CardBehaviour;
	import duel.cards.Card;
	import duel.cards.CardFactory;
	import duel.display.cardlots.HandSprite;
	import duel.display.TableSide;
	import duel.gui.Gui;
	import duel.gui.GuiJuggler;
	import duel.processes.GameplayProcessManager;
	import duel.table.CreatureField;
	import duel.table.Field;
	import duel.table.Hand;
	import duel.table.IndexedField;
	import duel.table.TrapField;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	
	[Event(name="turnStart", type="duel.GameEvents")] 
	[Event(name="turnEnd", type="duel.GameEvents")] 
	[Event(name="select", type="duel.GameEvents")] 
	[Event(name="deselect", type="duel.GameEvents")] 
	[Event(name="hover", type="duel.GameEvents")] 
	[Event(name="unhover", type="duel.GameEvents")] 
	[Event(name="destroy", type="duel.GameEvents")] 
	/**
	 * ...
	 * @author choephix
	 */
	public class Game extends DisplayObjectContainer implements IAnimatable
	{
		public static var current:Game;
		
		public var currentPlayer:Player;
		public var processes:GameplayProcessManager;
		
		//
		public var jugglerStrict:GuiJuggler;
		public var jugglerGui:GuiJuggler;
		public var juggler:GuiJuggler;
		
		public var gui:Gui;
		public var selection:Selection;
		
		public var p1:Player;
		public var p2:Player;
		
		public var bg:Background;
		
		// Useless Debug Shit
		public var lastPlayedCreature:Card;
		public var lastPlayedTrap:Card;
		
		//
		public function Game()
		{
			current = this;
			initialize();
		}
		
		private function initialize():void
		{
			Starling.juggler.add( this );
			
			jugglerStrict = new GuiJuggler();
			jugglerGui = new GuiJuggler();
			juggler = new GuiJuggler();
			
			processes = new GameplayProcessManager();
			
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
			p2.handSprite.flipped = true;
			addChild( p2.handSprite );
			
			// START GAME
			currentPlayer	= p1;
			currentPlayer.opponent = p2;
			
			CONFIG::development {
			var pmi:ProcessManagementInspector = new ProcessManagementInspector( processes );
			addChild( pmi );
			pmi.alignPivot();
			pmi.x = App.W * .25;
			pmi.y = App.H * .50;
			}
			
			// PREPARE GAMEPLAY
			const DECK_SIZE_1:uint	= CardFactory.MAX; /// 52 22 16 8 10 128
			const DECK_SIZE_2:uint	= CardFactory.MAX; /// CardFactory.MAX
			const HAND_SIZE:uint	= 8; /// 12 6 5 7 8 2
			
			var time:Number = 0.7;
			var c:Card;
			var i:int;
			for ( i = 0; i < DECK_SIZE_1; i++ ) 
			{
				time += .010;
				c = CardFactory.produceCard( i % CardFactory.MAX );
				c.owner = p1;
				c.faceDown = true;
				jugglerStrict.delayCall( p1.deck.addCard, time, c, true );
			}
			
			for ( i = 0; i < DECK_SIZE_2; i++ ) 
			{
				time += .010;
				c = CardFactory.produceCard( i % CardFactory.MAX );
				c.owner = p2;
				c.faceDown = true;
				jugglerStrict.delayCall( p2.deck.addCard, time, c, true );
			}
			
			for ( i = 0; i < HAND_SIZE; i++ ) 
			{
				time += .030;
				jugglerStrict.delayCall( p1.draw, time );
				jugglerStrict.delayCall( p2.draw, time+0.017 );
			}
		}
		
		public function destroy():void 
		{
			dispatchEventWith( GameEvents.DESTROY );
			Starling.juggler.remove( this );
			removeFromParent( true );
		}
		
		public function advanceTime( time:Number ):void
		{
			jugglerStrict.advanceTime( time );
			jugglerGui.advanceTime( time );
			juggler.advanceTime( time );
			
			gui.advanceTime( time );
			p1.handSprite.advanceTime( time );
			p2.handSprite.advanceTime( time );
			
			if ( jugglerStrict.isIdle )
				processes.advanceTime( time );
			
			if ( selectedCard != null && !canSelect( selectedCard ) )
				selectCard( null );
			
			//bg.visible = interactable;
			this.touchable = interactable;
		}
		
		// INTERACTION
		public function onFieldClicked( field:Field ):void
		{
			if ( selectedCard )
			{
				var c:Card = selectedCard;
				var p:Player = c.controller;
				
				if ( currentPlayer.hand.containsCard( c ) )
				{
					if ( c.type.isCreature && field is CreatureField && canPlayHere( c, field ) )
					{
						performCardSummon( c, field as CreatureField );
						return;
					}
					if ( c.type.isTrap && field is TrapField && canPlayHere( c, field ) )
					{
						performTrapSet( c, field as TrapField );
						return;
					}
				}
				
				selectCard( null );
				
				if ( field.type.isGraveyard && field.owner == p )
				{
					p.discard( c );
					return;
				}
				
				if ( c.type.isCreature && field is CreatureField && c.canRelocate && canPlayHere( c, field ) )
				{
					performRelocation( c, field as CreatureField );
					return;
				}
			}
		}
		
		public function onCardClicked( card:Card ):void
		{
			if ( selectedCard == null )
			{
				if ( card.controller == currentPlayer )
				{
					if ( card.lot is Hand )
					{
						if ( canSelect( card ) ) selectCard( selectedCard == card ? null : card );
						return;
					}
					else
					if ( currentPlayer.deck.containsCard( card ) )
					{
						currentPlayer.draw();
						return;
					}
					else
					if ( currentPlayer.grave.containsCard( card ) )
					{
						trace( "RESURRECT" );
						currentPlayer.grave.removeCard( card );
						currentPlayer.hand.addCard( card );
						card.faceDown = false;
						return;
					}
					else
					if ( canSelect( card ) )
					{
						selectCard( card );
					}
					/// DEV SHIT
					else
					if ( card.isInPlay && card.type.isTrap )
					{
						activateTrap( card )
					}
				}
			}
			else
			{
				var c:Card = selectedCard;
				
				if ( c != card && card.lot is Hand )
				{
					selectCard( card );
					return;
				}
				
				selectCard( null );
				
				// STACK CARDS ?
				/** /
				if ( c.lot != card.lot && card.controller == c.controller )
				{
					if ( !card.lot.isEmpty )
						c.faceDown = card.lot.getFirstCard().faceDown;
					card.lot.addCard( c );
				} /**/
			}
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
		
		public function performCardSummon( c:Card, field:CreatureField ):void
		{
			processes.startChain_Summon( c, field );
			
			processes.addEventListener( Event.COMPLETE, onComplete );
			function onComplete():void {
				if ( c.isInPlay )
				{
					c.exhausted = !c.behaviourC.haste;
					lastPlayedCreature = c;
				}
			}
			
			lastPlayedCreature = c;
		}
		
		public function performRelocation( c:Card, field:CreatureField ):void
		{
			processes.startChain_Relocation( c, field );
			
			processes.addEventListener( Event.COMPLETE, onComplete );
			function onComplete():void {
				if ( c.isInPlay )
					c.exhausted = true;
			}
		}
		
		public function performTrapSet( c:Card, field:TrapField ):void
		{
			processes.startChain_TrapSet( c, field );
			
			//c.sprite.animFaceDownSet();
			
			lastPlayedTrap = c;
		}
		
		public function performCardAttack( c:Card ):void
		{
			processes.startChain_Attack( c );
			
			c.sprite.animAttack();
			
			processes.addEventListener( Event.COMPLETE, onComplete );
			function onComplete():void {
				if ( c.isInPlay )
					c.exhausted = true;
			}
		}
		
		public function activateTrap( c:Card ):void
		{
			processes.performTrapActivation( c );
			
			
			
			
		}
		
		//
		
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
		public function selectCard( card:Card ):void {
			if ( selectedCard != null )
				dispatchEventWith( GameEvents.DESELECT, false, selectedCard );
			
			selection.selectedCard = card;
			
			if ( selectedCard != null )
				dispatchEventWith( GameEvents.SELECT, false, selectedCard );
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
		
		//
		public function get interactable():Boolean
		{
			return jugglerStrict.isIdle && jugglerGui.isIdle && processes.isIdle;
		}
		
		// QUESTIONS
		public function canPlayHere( card:Card, field:Field ):Boolean
		{
			if ( card.controller != field.owner ) return false;
			if ( card.type.isCreature && !field.type.isCreatureField ) return false;
			if ( card.type.isTrap && !field.type.isTrapField ) return false;
			return true;
		}
		
		public function canSelect( card:Card ):Boolean {
			if ( card.controller != currentPlayer ) return false;
			if ( card.type.isTrap && card.isInPlay ) return false;
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