package duel
{
	import chimichanga.common.assets.AdvancedAssetManager;
	import chimichanga.common.display.Sprite;
	import dev.ProcessManagementInspector;
	import duel.cards.Card;
	import duel.cards.CardFactory;
	import duel.cards.CommonCardQuestions;
	import duel.cards.temp_database.TempCardsDatabase;
	import duel.display.cardlots.HandSprite;
	import duel.display.TableSide;
	import duel.gui.Gui;
	import duel.gui.GuiJuggler;
	import duel.players.Player;
	import duel.processes.GameplayProcess;
	import duel.processes.GameplayProcessManager;
	import duel.processes.gameprocessing;
	import duel.processes.ProcessEvent;
	import duel.table.CreatureField;
	import duel.table.Field;
	import duel.table.Hand;
	import duel.table.IndexedField;
	import duel.table.TrapField;
	import flash.geom.Point;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.text.TextField;
	
	use namespace gameprocessing;
	
	[Event( name="destroy",type="duel.GameEvents" )]
	/**
	 * ...
	 * @author choephix
	 */
	public class Game extends DisplayObjectContainer implements IAnimatable
	{
		public static var current:Game;
		public static var frameNum:int = 0;
		
		CONFIG::development
		public static var GODMODE:Boolean;
		
		public var processes:GameplayProcessManager;
		public var jugglerStrict:GuiJuggler;
		public var jugglerGui:GuiJuggler;
		public var juggler:GuiJuggler;
		
		public var gui:Gui;
		
		public var p1:Player;
		public var p2:Player;
		public var currentPlayer:Player;
		
		public var bg:Background;
		
		//
		public function Game()
		{
			current = this;
			initialize();
		}
		
		private function initialize():void
		{
			//{ INITIAL SHIT
			Starling.juggler.add( this );
			
			jugglerStrict = new GuiJuggler();
			jugglerGui = new GuiJuggler();
			juggler = new GuiJuggler();
			
			processes = new GameplayProcessManager();
			processes.addEventListener( ProcessEvent.CURRENT_PROCESS, onProcessAdvance );
			processes.addEventListener( ProcessEvent.PROCESS_COMPLETE, onProcessComplete );
			
			p1 = generatePlayer( "player1" );
			p2 = generatePlayer( "player2" );
			p1.opponent = p2;
			p2.opponent = p1;
			
			function generatePlayer( name:String ):Player
			{ return new Player( name, G.INIT_LP ) }
		
			//}
			
			//{ VISUALS
			bg = new Background( assets.getTexture( "bg" ) );
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
			char2.scaleY = CHAR_SCALE;
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
			
			p1.handSprite = new HandSprite( p1.hand );
			p1.handSprite.maxWidth = 1000;
			p1.handSprite.x = -450 + ( App.W - p1.handSprite.maxWidth ) * 0.5;
			p1.handSprite.y = -p1.tableSide.y + App.H;
			
			p2.handSprite = new HandSprite( p2.hand );
			p2.handSprite.maxWidth = 950;
			p2.handSprite.x = -300 + ( App.W - p2.handSprite.maxWidth ) * 0.5;
			p2.handSprite.y = -p2.tableSide.y;
			p2.handSprite.flipped = true;
			//}
			
			//{ START GAME
			setCurrentPlayer( p1 );
			
			CONFIG::development
			{
				//var pmi:ProcessManagementInspector = new ProcessManagementInspector( processes );
				//addChild( pmi );
				//pmi.x = 200;
				//pmi.y = 400;
			/** / ProcessTester.initTest1( processes ); return /**/
			}
			
			//}
			
			//{ PREPARE DECKS
			const DECK1:Array = [];
			const DECK2:Array = [];
			
			var i:int;
			
			i = 0;
			
			do
			{
				DECK1.push( i );
			} while ( TempCardsDatabase.F[ ++i ] != null )
			
			++i
			
			do
			{
				DECK2.push( i );
			} while ( TempCardsDatabase.F[ ++i ] != null )
			
			++i
			
			do
			{
				DECK1.push( i );
				DECK2.push( i );
			} while ( TempCardsDatabase.F[ ++i ] != null )
			//}
			
			//{ PREPARE GAMEPLAY
			const DECK1_SIZE:uint = Math.min( DECK1.length, G.MAX_DECK_SIZE );
			const DECK2_SIZE:uint = Math.min( DECK2.length, G.MAX_DECK_SIZE );
			
			var time:Number = 0.7;
			var c:Card;
			for ( i = 0; i < DECK1_SIZE; i++ )
			{
				time += .010;
				c = CardFactory.produceCard( DECK1[ i ] );
				c.owner = p1;
				c.faceDown = true;
				jugglerStrict.delayCall( p1.deck.addCard, time, c, true );
			}
			
			for ( i = 0; i < DECK2_SIZE; i++ )
			{
				time += .010;
				c = CardFactory.produceCard( DECK2[ i ] );
				c.owner = p2;
				c.faceDown = true;
				jugglerStrict.delayCall( p2.deck.addCard, time, c, true );
			}
			
			jugglerStrict.delayCall( drawCards, time + .360 );
			function drawCards():void
			{
				processes.prepend_Draw( p1, G.INIT_HAND_SIZE );
				processes.prepend_Draw( p2, G.INIT_HAND_SIZE );
			}
			//}
			
		}
		
		public function destroy():void
		{
			dispatchEventWith( GameEvents.DESTROY );
			Starling.juggler.remove( this );
			removeFromParent( true );
		}
		
		public function advanceTime( time:Number ):void
		{
			frameNum++;
			
			jugglerStrict.advanceTime( time );
			jugglerGui.advanceTime( time );
			juggler.advanceTime( time );
			
			if ( jugglerStrict.isIdle )
				processes.advanceTime( time );
				
			gui.advanceTime( time );
			p1.handSprite.advanceTime( time );
			p2.handSprite.advanceTime( time );
			p1.ctrl.advanceTime( time );
			p2.ctrl.advanceTime( time );
			
			//bg.visible = interactable;
			this.touchable = interactable;
		}
		
		public function setCurrentPlayer( p:Player ):void
		{
			if ( currentPlayer )
				currentPlayer.ctrl.active = false;
			
			currentPlayer = p;
			
			if ( currentPlayer )
				currentPlayer.ctrl.active = true;
		}
		
		// PROCESSES
		
		private function onProcessAdvance( e:ProcessEvent ):void
		{
			var p:GameplayProcess = e.process as GameplayProcess;
			
			if ( p == null )
				return;
			
			playerInspectProcess( currentPlayer.opponent, p );
			playerInspectProcess( currentPlayer, p );
			currentPlayer.ctrl.onProcessUpdate();
			gui.updateData();
		}
		
		private function onProcessComplete( e:ProcessEvent ):void
		{
			currentPlayer.ctrl.onProcessUpdate();
			gui.updateData();
		}
		
		private function playerInspectProcess( player:Player, p:GameplayProcess ):void
		{
			var i:int;
			
			if ( p.isInterrupted )
				return;
			
			for ( i = 0; i < player.fieldsT.count; i++ )
			{
				if ( player.fieldsT.getAt( i ).isEmpty )
					continue;
				
				player.fieldsT.getAt( i ).topCard.onGameProcess( p );
				
				if ( p.isInterrupted )
					return;
			}
			
			for ( i = 0; i < player.fieldsC.count; i++ )
			{
				if ( player.fieldsC.getAt( i ).isEmpty )
					continue;
				
				player.fieldsC.getAt( i ).topCard.onGameProcess( p );
				
				if ( p.isInterrupted )
					return;
			}
			
			for ( i = 0; i < player.hand.cardsCount; i++ )
			{
				player.hand.getCardAt( i ).onGameProcess( p );
				
				if ( p.isInterrupted )
					return;
			}
			
			for ( i = 0; i < player.grave.cardsCount; i++ )
			{
				player.grave.getCardAt( i ).onGameProcess( p );
				
				if ( p.isInterrupted )
					return;
			}
		}
		
		// PLAYER ACTIONS
		
		public function performActionSummon( c:Card, field:CreatureField ):void
		{ processes.append_SummonHere( c, field, true ) }
		
		public function performActionTrapSet( c:Card, field:TrapField ):void
		{ processes.append_TrapSet( c, field, true ) }
		
		public function performActionAttack( c:Card ):void
		{ processes.append_Attack( c, false ) }
		
		public function performActionRelocation( c:Card, field:CreatureField ):void
		{ processes.append_Relocation( c, field, false ) }
		
		public function performActionSafeFlip( c:Card ):void
		{ processes.prepend_SafeFlip( c ) }
		
		public function performActionDraw():void 
		{ processes.prepend_Draw( currentPlayer, 1, true ) }
		
		public function performActionTurnEnd():void
		{ processes.append_TurnEnd( currentPlayer ) }
		
		public function performActionSurrender():void
		{ endGame() }
		
		//
		public function endGame():void
		{
			var q:Quad = new Quad( App.W, App.H, 0x0 );
			q.alpha = 0;
			addChild( q );
			touchable = false;
			
			Starling.juggler.remove( this );
			Starling.juggler.tween( q, .440, { alpha: 1.0, onComplete: destroy } );
		}
		
		//
		public function get interactable():Boolean
		{
			return jugglerStrict.isIdle && jugglerGui.isIdle && processes.isIdle;
		}
		
		// FX
		
		public function showFloatyText( p:Point, text:String, color:uint ):void
		{
			var o:Sprite = new Sprite();
			addChild( o );
			
			var t:TextField = new TextField( 500, 100, text, "Impact", 36, color, false );
			t.alignPivot();
			
			var q:Quad = new Quad( t.textBounds.width, t.textBounds.height, 0x0 );
			q.alignPivot();
			q.alpha = .6;
			
			o.addChild( q );
			o.addChild( t );
			o.x = p.x;
			o.y = p.y;
			juggler.tween( o, 2.5,
				{
					delay : .500,
					alpha : .0,
					onComplete : o.removeFromParent,
					onCompleteArgs : [true]
				} );
		}
		
		//
		protected function get assets():AdvancedAssetManager
		{
			return App.assets
		}
	}
}