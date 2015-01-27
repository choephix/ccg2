package duel
{
	import chimichanga.common.assets.AdvancedAssetManager;
	import chimichanga.common.display.Sprite;
	import chimichanga.debug.logging.error;
	import com.reyco1.multiuser.data.UserObject;
	import dev.ProcessManagementInspector;
	import duel.cards.Card;
	import duel.cards.CardFactory;
	import duel.cards.temp_database.TempCardsDatabase;
	import duel.controllers.PlayerAction;
	import duel.controllers.PlayerActionType;
	import duel.controllers.UserPlayerController;
	import duel.display.cardlots.HandSprite;
	import duel.display.TableSprite;
	import duel.display.TableSide;
	import duel.gui.Gui;
	import duel.gui.GuiJuggler;
	import duel.network.RemoteConnectionController;
	import duel.network.RemotePlayerActionReceiver;
	import duel.network.RemotePlayerActionSender;
	import duel.players.Player;
	import duel.players.PlayerEvent;
	import duel.processes.GameplayProcess;
	import duel.processes.GameplayProcessManager;
	import duel.processes.gameprocessing;
	import duel.processes.ProcessEvent;
	import duel.table.CreatureField;
	import duel.table.TrapField;
	import flash.geom.Point;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
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
		public static function log(s:String):void{if(current)current.gui.log(s)}
		
		CONFIG::development
		public static var GODMODE:Boolean;
		
		public var meta:GameMeta;
		public var state:GameState = GameState.WAITING;
		
		public var remote:RemoteConnectionController;
		private var remoteInput:RemotePlayerActionReceiver;
		
		public var processes:GameplayProcessManager;
		public var jugglerStrict:GuiJuggler;
		public var jugglerGui:GuiJuggler;
		public var juggler:GuiJuggler;
		
		public var table:TableSprite;
		public var gui:Gui;
		
		public var p1:Player;
		public var p2:Player;
		public var currentPlayer:Player;
		
		public var bg:Background;
		
		private var logicComponents:Vector.<GameUpdatable>;
		private var cards:Vector.<Card>;
		private var cardsCount:int = 0;
		
		//
		public function Game() { current = this }
		
		public function initialize():void
		{
			//{ INITIAL SHIT
			Starling.juggler.add( this );
			
			jugglerStrict = new GuiJuggler();
			jugglerGui = new GuiJuggler();
			juggler = new GuiJuggler();
			
			processes = new GameplayProcessManager();
			processes.addEventListener( ProcessEvent.CURRENT_PROCESS, onProcessAdvance );
			processes.addEventListener( ProcessEvent.PROCESS_COMPLETE, onProcessComplete );
			
			logicComponents = new Vector.<GameUpdatable>();
			cards = new Vector.<Card>();
			
			p1 = generatePlayer( "?" );
			p2 = generatePlayer( "?" );
			p1.opponent = p2;
			p2.opponent = p1;
			
			function generatePlayer( name:String ):Player
			{ 
				var p:Player = new Player( name, G.INIT_LP )
				p.addEventListener( PlayerEvent.ACTION, onPlayerActionEvent );
				return p;
			}
		
			//}
			
			//{ VISUALS
			bg = new Background( assets.getTexture( "bg" ) );
			addChild( bg );
			
			table = new TableSprite();
			table.x = App.W * 0.50;
			table.y = App.H * 0.50;
			addChild( table );
			
			const CHAR_SCALE:Number = 0.75;
			const CHAR_MARGIN_Y:Number = 60;
			
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
			
			p1.tableSide = new TableSide( p1, table, false );
			p2.tableSide = new TableSide( p2, table, true );
			
			// GUI AND STUFF
			gui = new Gui();
			//gui.visible = false;
			addChild( gui );
			
			p1.handSprite = new HandSprite( p1.hand );
			p1.handSprite.maxWidth = 1000;
			p1.handSprite.x = - p1.handSprite.maxWidth * 0.5;
			p1.handSprite.y =  .5 * App.H;
			p1.handSprite.cardsParent = table.cardsParentTop;
			
			p2.handSprite = new HandSprite( p2.hand );
			p2.handSprite.maxWidth = 950;
			p2.handSprite.x = - p2.handSprite.maxWidth * 0.5;
			p2.handSprite.y = -.5 * App.H;
			p2.handSprite.cardsParent = table.cardsParentTop;
			p2.handSprite.topSide = true;
			//}
			
			if ( !meta.isMultiplayer )
			{
				logicComponents.push( new UserPlayerController( p1 ) );
				logicComponents.push( new UserPlayerController( p2 ) );
				p1.updateDetails( "Player1", 0x33AAFF );
				p2.updateDetails( "Player2", 0xFFAA33 );
				p1.controllable = true;
				p2.controllable = true;
				startGame();
			}
			else
			{
				remoteInput = new RemotePlayerActionReceiver( p2 );
				
				logicComponents.push( new UserPlayerController( p1 ) );
				logicComponents.push( new RemotePlayerActionSender( p1 ) );
				logicComponents.push( remoteInput );
				p1.controllable = true;
			
				remote = new RemoteConnectionController();
				remote.initialize();
				remote.onOpponentFoundCallback = startGame;
				remote.onUserObjectRecievedCallback = onRemoteMessageReceived;
				
				gui.pMsg( "Waiting for opponent...", false );
			}
		}
		
		private function onRemoteMessageReceived( userName:String, data:Object ):void 
		{
			if ( userName != p2.name )
			{
				error( "who?" );
				return;
			}
			
			remoteInput.onMessage( data as String );
		}
		
		public function startGame():void
		{
			var amFirst:Boolean = true;
			
			if ( meta.isMultiplayer )
			{
				var p1u:UserObject = remote.myUser;
				var p2u:UserObject = remote.oppUser;
				
				p1.updateDetails( p1u.name, p1u.details.color );
				p2.updateDetails( p2u.name, p2u.details.color );
				
				amFirst = p1u.details.hasFirstTurn;
			}
			
			//{ START GAME
			setCurrentPlayer( amFirst ? p1 : p2 );
			
			CONFIG::development
			{
				if ( false )
				{
				var pmi:ProcessManagementInspector;
				pmi = new ProcessManagementInspector( processes );
				addChild( pmi );
				pmi.x = 200;
				pmi.y = 400;
				}
			/** / ProcessTester.initTest1( processes ); return /**/
			}
			
			//}
			
			//{ PREPARE DECKS
			var DECK1:Array = [];
			var DECK2:Array = [];
			
			var i:int;
			
			i = 0;
			
			do
				DECK1.push( i );
			while ( TempCardsDatabase.F[ ++i ] != null )
			
			++i
			
			do
				DECK2.push( i );
			while ( TempCardsDatabase.F[ ++i ] != null )
			
			++i
			
			do
			{
				DECK1.push( i );
				DECK2.push( i );
			}
			while ( TempCardsDatabase.F[ ++i ] != null )
			
			//}
			
			//{ PREPARE DECKS AGAIN (double the cards, dowble the fun!) (not really) (whatever, it's proof of concept!)
			var DECK1:Array = [];
			var DECK2:Array = [];
			
			var i:int;
			
			i = 0;
			
			do
				DECK1.push( i );
			while ( TempCardsDatabase.F[ ++i ] != null )
			
			++i
			
			do
				DECK2.push( i );
			while ( TempCardsDatabase.F[ ++i ] != null )
			
			++i
			
			do
			{
				DECK1.push( i );
				DECK2.push( i );
			}
			while ( TempCardsDatabase.F[ ++i ] != null )
			
			//}
			
			//{ PREPARE GAMEPLAY
			
			var time:Number = 0.7;
			var c:Card;
			
			if ( amFirst )
			{
				populatePlayerDeck( p1, DECK1 );
				populatePlayerDeck( p2, DECK2 );
				p2.mana.raiseCap();
			}
			else
			{
				populatePlayerDeck( p2, DECK1 );
				populatePlayerDeck( p1, DECK2 );
				p1.mana.raiseCap();
			}
			
			function populatePlayerDeck( p:Player, cardIds:Array ):void
			{
				for ( i = 0; i < cardIds.length && i < G.MAX_DECK_SIZE; i++ )
				{
					time += .010;
					c = produceCard( cardIds[ i ] );
					c.owner = p;
					c.faceDown = true;
					jugglerStrict.delayCall( p.deck.addCard, time, c, true );
				}
			}
			
			jugglerStrict.delayCall( drawCards, time + .360 );
			function drawCards():void
			{
				processes.prepend_Draw( p1, G.INIT_HAND_SIZE );
				processes.prepend_Draw( p2, G.INIT_HAND_SIZE );
			}
			//}
			
			state = GameState.ONGOING;
			
			gui.visible = true;
			gui.updateData();
		}
		
		public function destroy():void
		{
			dispatchEventWith( GameEvents.DESTROY );
			Starling.juggler.remove( this );
			removeFromParent( true );
			
			if ( current == this )
				current = null;
		}
		
		public function advanceTime( time:Number ):void
		{
			scaleY = stage.stageHeight / App.H;
			scaleX = scaleY;
			x = .5 * ( stage.stageWidth - bg.width * scaleX );
			
			frameNum++;
			
			jugglerStrict.advanceTime( time );
			jugglerGui.advanceTime( time );
			juggler.advanceTime( time );
			
			//if ( state.isWaiting )
				//return;
			
			for ( var i:int = 0, iMax:int = logicComponents.length; i < iMax; i++ ) 
				logicComponents[ i ].advanceTime( time );
			
			try
			{
			if ( jugglerStrict.isIdle )
				processes.advanceTime( time );
			}
			catch ( e:Error ) { log( e.message ) }
				
			gui.advanceTime( time );
			p1.handSprite.advanceTime( time );
			p2.handSprite.advanceTime( time );
			
			//bg.visible = interactable;
			this.touchable = interactable;
			gui.updateData();
			
			if ( !state.isOngoing )
				return;
			
			if ( p1.lifePoints <= 0 )
				endGame();
			else
			if ( p2.lifePoints <= 0 )
				endGame();
		}
		
		public function setCurrentPlayer( p:Player ):void
		{
			if ( currentPlayer )
				currentPlayer.isMyTurn = false;
			
			currentPlayer = p;
			
			if ( meta.isMultiplayer )
				gui.pMsg( p == p1 ? "Your turn" : "Enemy turn" );
			else
				gui.pMsg( currentPlayer.name + "'s turn" );
			
			if ( currentPlayer )
				currentPlayer.isMyTurn = true;
		}
		
		public function produceCard( id:int ):Card
		{ 
			var c:Card;
			c = CardFactory.produceCard( id );
			cardsCount = cards.push( c );
			c.uid = cardsCount;
			return c;
		}
		
		public function findCardByUid( uid:int ):Card
		{ return cards[ uid-1 ] }
		
		// PROCESSES
		
		private function onProcessAdvance( e:ProcessEvent ):void
		{
			var p:GameplayProcess = e.process as GameplayProcess;
			
			if ( p == null )
				return;
			
			for ( var i:int = 0, iMax:int = logicComponents.length; i < iMax; i++ ) 
				logicComponents[ i ].onProcessUpdateOrComplete( p );
			
			playerInspectProcess( currentPlayer.opponent, p );
			playerInspectProcess( currentPlayer, p );
		}
		
		private function onProcessComplete( e:ProcessEvent ):void
		{
			for ( var i:int = 0, iMax:int = logicComponents.length; i < iMax; i++ ) 
				logicComponents[ i ].onProcessUpdateOrComplete( e.process as GameplayProcess );
			
			if ( !meta.isMultiplayer && e.process.name )
				gui.log( e.process.name + " " + e.process.args );
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
		
		public function onPlayerActionEvent( e:PlayerEvent ):void
		{
			if ( currentPlayer != e.currentTarget )
			{ error ( "dafuq" ); return; }
			
			performCurrentPlayerAction( e.data as PlayerAction );
		}
		
		public function performCurrentPlayerAction( a:PlayerAction ):void
		{
			switch ( a.type )
			{
				case PlayerActionType.DRAW:		
					performActionDraw();
					break;
				case PlayerActionType.SUMMON_CREATURE:	
					performActionSummon( a.args[0] as Card, a.args[1] as CreatureField );
					break;
				case PlayerActionType.SET_TRAP:	
					performActionTrapSet( a.args[0] as Card, a.args[1] as TrapField );
					break;
				case PlayerActionType.ATTACK:	
					performActionAttack( a.args[0] as Card );
					break;
				case PlayerActionType.RELOCATE:	
					performActionRelocation( a.args[0] as Card, a.args[1] as CreatureField );
					break;
				case PlayerActionType.SAFEFLIP:	
					performActionSafeFlip( a.args[0] as Card );
					break;
				case PlayerActionType.END_TURN:	
					performActionTurnEnd();
					break;
				case PlayerActionType.SURRENDER: 
					performActionSurrender();
					break;
			}
		}
		
		private function performActionDraw():void 
		{ processes.prepend_Draw( currentPlayer, 1, true ) }
		
		private function performActionSummon( c:Card, field:CreatureField ):void
		{ processes.append_SummonHere( c, field, true ) }
		
		private function performActionTrapSet( c:Card, field:TrapField ):void
		{ processes.append_TrapSet( c, field, true ) }
		
		private function performActionAttack( c:Card ):void
		{ processes.append_Attack( c, false ) }
		
		private function performActionRelocation( c:Card, field:CreatureField ):void
		{ processes.append_Relocation( c, field, false ) }
		
		private function performActionSafeFlip( c:Card ):void
		{ processes.prepend_SafeFlip( c ) }
		
		private function performActionTurnEnd():void
		{ processes.append_TurnEnd( currentPlayer ) }
		
		private function performActionSurrender():void
		{ endGame() }
		
		//
		public function endGame():void
		{
			state = GameState.OVER;
			
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
			return jugglerStrict.isIdle && jugglerGui.isIdle && processes.isIdle && state.isOngoing;
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