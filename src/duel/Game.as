package duel
{
	import chimichanga.common.assets.AdvancedAssetManager;
	import chimichanga.common.display.Sprite;
	import chimichanga.debug.logging.error;
	import com.reyco1.multiuser.data.UserObject;
	import data.decks.DeckBean;
	import dev.ProcessManagementInspector;
	import dev.Temp;
	import duel.cards.buffs.GlobalBuffManager;
	import duel.cards.Card;
	import duel.cards.factory.CardFactory;
	import duel.controllers.PlayerAction;
	import duel.controllers.PlayerActionType;
	import duel.controllers.UserPlayerController;
	import duel.display.cardlots.HandSprite;
	import duel.display.fx.CardAuraManager;
	import duel.display.TableSide;
	import duel.display.TableSprite;
	import duel.gameplay.CardEvents;
	import duel.gui.Gui;
	import duel.gui.GuiEvents;
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
	import duel.table.IndexedField;
	import duel.table.TrapField;
	import flash.geom.Point;
	import global.CardPrimalData;
	import global.StaticVariables;
	import starling.animation.IAnimatable;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.text.TextField;
	import text.FakeData;
	
	use namespace gameprocessing;
	
	[Event( name="destroy",type="duel.GameEvents" )]
	
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
		
		public var guiEvents:GuiEvents;
		public var cardEvents:CardEvents;
		public var processes:GameplayProcessManager;
		public var jugglerStrict:GuiJuggler;
		public var jugglerGui:GuiJuggler;
		public var juggler:GuiJuggler;
		
		public var table:TableSprite;
		public var gui:Gui;
		public var errorBox:TextField;
		
		public var p1:Player;
		public var p2:Player;
		public var currentPlayer:Player;
		public var userPlayer:Player;
		
		public var bg:Background;
		
		public var indexedFields:Vector.<IndexedField>;
		public var cards:Vector.<Card>;
		public var cardsCount:int = 0;
		private var logicComponents:Vector.<GameUpdatable>;
		
		public var globalBuffs:GlobalBuffManager;
		
		public var auras:CardAuraManager;
		public var mouseLocation:Point = new Point();
		
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
			
			globalBuffs = new GlobalBuffManager();
			logicComponents = new Vector.<GameUpdatable>();
			indexedFields = new Vector.<IndexedField>();
			cards = new Vector.<Card>();
			
			guiEvents = new GuiEvents();
			cardEvents = new CardEvents();
			
			p1 = generatePlayer();
			p2 = generatePlayer();
			p1.opponent = p2;
			p2.opponent = p1;
			p1.updateDetails( meta.myUserName, meta.myUserColor );
			
			function generatePlayer():Player
			{ 
				var p:Player = new Player( G.INIT_LP )
				p.addEventListener( PlayerEvent.ACTION, onPlayerActionEvent );
				
				var i:int;
				for ( i = 0; i < p.fieldsC.count; i++ )
					indexedFields.push( p.fieldsC.getAt( i ) );
				for ( i = 0; i < p.fieldsT.count; i++ )
					indexedFields.push( p.fieldsT.getAt( i ) );
				return p;
			}
			
			//}
			
			//{ VISUALS
			
			auras = new CardAuraManager();
			auras.initialize();
			
			bg = new Background( assets );
			bg.blendMode = BlendMode.NONE;
			addChild( bg );
			
			table = new TableSprite();
			table.x = App.W * 0.42;
			table.x = App.W * 0.48;
			table.x = App.W * 0.448;
			table.y = App.H * 0.47;
			addChild( table );
			
			p1.tableSide = new TableSide( p1, table, false );
			p2.tableSide = new TableSide( p2, table, true );
			
			// GUI AND STUFF
			gui = new Gui();
			addChild( gui );
			
			errorBox = new TextField( .3 * App.W, App.H, "" );
			errorBox.format.font = "Consolas";
			errorBox.format.size = 21;
			errorBox.format.color = 0xBB0011;
			errorBox.format.bold = true;
			errorBox.format.verticalAlign = "top";
			errorBox.touchable = false;
			errorBox.batchable = false;
			errorBox.x = .35 * App.W;
			addChild( errorBox );
			
			p1.handSprite = new HandSprite( p1.hand );
			//p1.handSprite.maxWidth = 1200;
			p1.handSprite.x = App.W - table.x;
			p1.handSprite.y = App.H - table.y;
			p1.handSprite.cardsParent = table.cardsParentTop;
			
			p2.handSprite = new HandSprite( p2.hand );
			//p2.handSprite.maxWidth = 1150;
			p2.handSprite.x = App.W - table.x;
			p2.handSprite.y = -table.y;
			p2.handSprite.cardsParent = table.cardsParentTop;
			p2.handSprite.topSide = true;
			//}
			
			if ( !meta.isMultiplayer )
			{
				logicComponents.push( new UserPlayerController( p1 ) );
				logicComponents.push( new UserPlayerController( p2 ) );
				p1.updateDetails( meta.myUserName, meta.myUserColor );
				p2.updateDetails( meta.myUserName + " II", 0xFF0059 ); // "Botko"
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
				remote.initialize( meta );
				remote.onOpponentFoundCallback = startGame;
				remote.onUserObjectRecievedCallback = onRemoteMessageReceived;
				
				//gui.pMsg( "Waiting for opponent...", false );
				gui.pMsg( "Waiting for opponent in room " + meta.roomName, false );
			}
			
			advanceTime(.0);
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
				var p2u:UserObject = remote.oppUser;
				p2.updateDetails( p2u.name, p2u.details.color );
				amFirst = remote.myUser.details.hasFirstTurn;
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
			
			//{ PREPARE GAMEPLAY
			
			var DECK1:DeckBean = meta.deck1;
			var DECK2:DeckBean = meta.deck2;
			
			var time:Number = 0.880;
			var i:int;
			var c:Card;
			var d:CardPrimalData;
			
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
			
			function populatePlayerDeck( p:Player, deck:DeckBean ):void
			{
				for ( i = 0; i < deck.cards.length && i < G.MAX_DECK_SIZE; i++ )
				{
					time += CONFIG::sandbox ? .003 : .033;
					c = produceCard( deck.cards[ i ] );
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
			advanceTime(.0);
		}
		
		public function destroy():void
		{
			if ( state == GameState.DESTROYED )
				return;
			
			state = GameState.DESTROYED;
			
			if ( remote != null )
			{
				remote.destroy();
				remote = null;
			}
			
			p1.handSprite.destroy();
			p2.handSprite.destroy();
			
			globalBuffs.destroy();
			globalBuffs = null;
			
			jugglerStrict.purge();
			jugglerStrict = null;
			jugglerGui.purge();
			jugglerGui = null;
			juggler.purge();
			juggler = null;
			
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
			
			mouseLocation.x = App.globalPointerLocation.x * scaleX;
			mouseLocation.y = App.globalPointerLocation.y * scaleY;
			
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
			catch ( e:Error ) { onError( e ) }
				
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
			
			userPlayer = CONFIG::sandbox ? currentPlayer : p1;
		}
		
		public function produceCard( data:* ):Card
		{ 
			var c:Card;
			c = CardFactory.produceCard( data );
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
			
			try
			{
				playerInspectProcess( currentPlayer.opponent, p );
				playerInspectProcess( currentPlayer, p );
			}
			catch ( e:Error )
			{ onError( e ) }
		}
		
		private function onProcessComplete( e:ProcessEvent ):void
		{
			var p:GameplayProcess = e.process as GameplayProcess;
			
			if ( p == null )
				return;
			
			for ( var i:int = 0, iMax:int = logicComponents.length; i < iMax; i++ ) 
				logicComponents[ i ].onProcessUpdateOrComplete( e.process as GameplayProcess );
			
			try
			{
				playerInspectProcess( currentPlayer.opponent, p );
				playerInspectProcess( currentPlayer, p );
			} 
			catch ( e:Error )
			{ onError( e ) }
			
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
		
		private function onError(e:Error):void 
		{
			errorBox.text += e.name + " --> " + e.message + "\n";
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
			o.touchable = false;
			addChild( o );
			
			var t:TextField = new TextField( 500, 100, text );
			t.format.font = "Impact";
			t.format.size = 36;
			t.format.color = color;
			t.format.bold = false;
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
		
		public function blink( color1:uint, color2:uint ):void
		{
			var q:Quad = new Quad( App.W, App.H );
			q.setVertexColor( 0, color1 );
			q.setVertexColor( 1, color1 );
			q.setVertexColor( 2, color2 );
			q.setVertexColor( 3, color2 );
			q.blendMode = BlendMode.ADD;
			jugglerGui.tween( q, .250,
				{ 
					alpha : .0, 
					transition : Transitions.EASE_OUT,
					onComplete : q.removeFromParent, onCompleteArgs : [ true ]
				} );
			addChild( q );
		}
		
		//
		protected function get assets():AdvancedAssetManager
		{
			return App.assets
		}
	}
}