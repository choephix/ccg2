package
{
	import chimichanga.common.display.Sprite;
	import data.decks.DeckBean;
	import dev.AuraModel;
	import dev.Temp;
	import duel.controllers.PlayerAction;
	import duel.controllers.PlayerActionType;
	import duel.Game;
	import duel.GameEvents;
	import duel.GameMeta;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import global.StaticVariables;
	import screens.common.Dialog_ChooseDeck;
	import screens.deckbuilder.ScreenDeckbuilder;
	import screens.lobby.Lobby;
	import screens.mainmenu.Screen_MainMenu;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.ResizeEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import text.FakeData;
	
	CONFIG::air
	{
		import flash.filesystem.File;
	}
	
	/**
	 * ...
	 * @author choephix
	 */
	public class StarlingMain extends Sprite
	{
		private var g:Game;
		private var loadingText:TextField;
		private var gameMeta:GameMeta;
		private var lobby:Lobby;
		private var menuContainer:Screen_MainMenu;
		
		public function StarlingMain()
		{
			blendMode = BlendMode.NORMAL;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event = null):void
		{
			removeEventListeners(Event.ADDED_TO_STAGE);
			App.initialize(this);
			
			enqueueAssets();
			Starling.juggler.delayCall(startLoadingAssets, .25);
			
			stage.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private function onTouch(e:TouchEvent):void
		{
			var t:Touch = e.getTouch(stage);
			
			if (t == null) return;
			
			t.getLocation(stage, App.globalPointerLocation);
		}
		
		private function enqueueAssets():void
		{
			CONFIG::air
			{
				App.assets.enqueue("assets/");
				return;
			}
			
			App.assets.enqueue("assets/font1.fnt")
			App.assets.enqueue("assets/font2.fnt")
			App.assets.enqueue("assets/font3.fnt")
			App.assets.enqueue("assets/bg.jpg")
			App.assets.enqueue("assets/mainbg.jpg")
			App.assets.enqueue("assets/ring1.jpg")
			App.assets.enqueue("assets/ring2.jpg")
			App.assets.enqueue("assets/main-rgb.atf")
			App.assets.enqueue("assets/main-rgb.xml")
			App.assets.enqueue("assets/main-rgba.atf")
			App.assets.enqueue("assets/main-rgba.xml")
		}
		
		private function startLoadingAssets():void
		{
			loadingText = new TextField(stage.stageWidth, stage.stageHeight, ":c]");
			loadingText.format.font = "Arial Black";
			loadingText.format.size = 80;
			loadingText.format.bold = true;
			loadingText.format.color = 0x304050;
			addChild(loadingText);
			
			App.assets.initialize(onLoadingAppProgress, onLoadingAppComplete);
		}
		
		private function onLoadingAppProgress(progress:Number):void
		{
			loadingText.text = int(progress * 100) + "%";
			loadingText.width = stage.stageWidth;
			loadingText.height = stage.stageHeight;
		}
		
		private function onLoadingAppComplete():void
		{
			CONFIG::development
			{
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onkey);
			}
			
			loadingText.removeFromParent(true);
			loadingText = null;
			
			/// META
			const UID:String = new Date().time.toString(36);
			
			gameMeta = new GameMeta();
			gameMeta.myUserColor = Math.random() * 0xFFFFFF;
			gameMeta.myUserName = "User_" + UID;
			CONFIG::air
			{
				gameMeta.myUserName = File.userDirectory.name
			}
			CONFIG::mobile
			{
				gameMeta.myUserName = Capabilities.cpuArchitecture + "_" + UID
			}
			
			/// MENU
			//CONFIG::desktop { Temp.tweenAppSize( App.WINDOW_W, App.WINDOW_H, showMenu ); return; }
			
			App.cardsData.load(onLoadingCardsComplete);
		}
		
		private function onLoadingCardsComplete():void
		{
			CONFIG::quickplay
			{
				showDeckBuilder();
				return;
				
				gameMeta.deck1 = DeckBean.fromJson( FakeData.DECK_TEST_1 );
				gameMeta.deck2 = DeckBean.fromJson( FakeData.DECK_TEST_2 );
				startGame(gameMeta);
				//showLobby();
				return;
			}
			
			showMenu();
		}
		
		private function showMenu():void
		{
			if ( menuContainer == null )
			{
				menuContainer = new Screen_MainMenu();
				menuContainer.callback_StartSingle = startSingle;
				menuContainer.callback_ShowLobby = showLobby;
				menuContainer.callback_DeckBuilder = showDeckBuilder;
				menuContainer.initialize();
				addChild( menuContainer );
			}
			else
			{
				menuContainer.visible = true;
			}
		}
		
		private function hideMenu():void
		{
			if (menuContainer == null)
				return;
			menuContainer.visible = false;
		}
		
		private function showDeckBuilder():void
		{
			trace( "Opening DeckBuilder" );
			
			var scrDecks:ScreenDeckbuilder;
			scrDecks = new ScreenDeckbuilder();
			addChild( scrDecks );
		}
		
		
		private function showLobby():void
		{
			trace( "Opening Lobby" );
			
			lobby = new Lobby();
			lobby.readyCallback = startMulti;
			addChild( lobby );
			lobby.initialize( gameMeta );
		}
		
		private function startSingle():void
		{
			gameMeta.isMultiplayer = false;
			
			hideMenu();
			
			Dialog_ChooseDeck.popOut( stage, onDeckChosen_1, "Player #1,\nPlease choose your deck" );
			
			function onDeckChosen_1( deck:DeckBean ):void
			{ 
				gameMeta.deck1 = deck;
				Dialog_ChooseDeck.popOut( stage, onDeckChosen_2, "Player #2,\nPlease choose your deck" );
			}
			
			function onDeckChosen_2( deck:DeckBean ):void
			{
				gameMeta.deck2 = deck;
				startGame( gameMeta );
			}
		}
		
		private function startMulti( room:String, enemy:String ):void
		{
			trace("Starting remote game", room, enemy);
			
			gameMeta.isMultiplayer = true;
			gameMeta.roomName = room;
			startGame( gameMeta );
		}
		
		private function startGame( meta:GameMeta ):void
		{
			if ( lobby )
			{
				lobby.close();
				lobby = null;
			}
			
			hideMenu();
			
			trace( "Will start new game" );
			
			g = new Game();
			addChild( g );
			g.addEventListener( GameEvents.DESTROY, onGameDestroyed );
			g.meta = meta;
			g.initialize();
		}
		
		private function onGameDestroyed():void
		{
			g.removeEventListener(GameEvents.DESTROY, onGameDestroyed);
			g = null;
			
			showMenu();
		}
		
		CONFIG::development
		private function onkey(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ESCAPE)
			{
				//if ( g != null )
				//g.endGame();
				if (Game.current && Game.current.currentPlayer && Game.current.currentPlayer.controllable)
					Game.current.currentPlayer.performAction(new PlayerAction().setTo(PlayerActionType.END_TURN));
			}
			
			if (e.keyCode == Keyboard.BACK)
			{
				e.preventDefault();
				e.stopImmediatePropagation();
				if (g != null) g.endGame();
			}
			
			CONFIG::desktop
			{
				if (e.keyCode == Keyboard.NUMBER_2)
				{
					Temp.tweenAppSize(Math.random() * 2000, Math.random() * 1000);
				}
				if (e.keyCode == Keyboard.F)
				{
					App.toggleFullScreen();
				}
				if (e.keyCode == Keyboard.SPACE)
				{
					//g.performActionTurnEnd();
					App.toggleFullScreen();
				}
				if (e.keyCode == Keyboard.ESCAPE)
				{
					App.nativeWindow.close();
				}
				if (e.keyCode == Keyboard.NUMPAD_ADD)
				{
					root.scaleX *= 2.0;
					root.scaleY *= 2.0;
				}
				if (e.keyCode == Keyboard.NUMPAD_SUBTRACT)
				{
					root.scaleX *= .5;
					root.scaleY *= .5;
				}
			}
			
			if (e.keyCode == Keyboard.CAPS_LOCK)
				Game.GODMODE = !Game.GODMODE;
			
			if (g == null || !g.interactable)
				return;
			
			if (e.keyCode == Keyboard.NUMBER_1)
			{
				g.currentPlayer.mana.raiseCap();
				g.currentPlayer.mana.refill();
				g.gui.updateData();
			}
		}
	}
}