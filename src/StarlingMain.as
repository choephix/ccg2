package {
	import chimichanga.common.display.Sprite;
	import dev.AuraModel;
	import dev.Temp;
	import duel.controllers.PlayerAction;
	import duel.controllers.PlayerActionType;
	import duel.Game;
	import duel.GameEvents;
	import duel.GameMeta;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import screens.lobby.Lobby;
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
	
	CONFIG::air
	{
	import flash.filesystem.File;
	}
	/**
	 * ...
	 * @author choephix
	 */
	public class StarlingMain extends Sprite {
		private var g:Game;
		private var loadingText:TextField;
		private var gameMeta:GameMeta;
		private var lobby:Lobby;
		private var menuContainer:Sprite;
		
		public function StarlingMain() {
			blendMode = BlendMode.NORMAL;
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}
		
		private function onAddedToStage( e:Event = null ):void {
			removeEventListeners( Event.ADDED_TO_STAGE );
			App.initialize( this );
			
			enqueueAssets();
			Starling.juggler.delayCall( startLoadingAssets, .25 );
			
			stage.addEventListener( TouchEvent.TOUCH, onTouch );
		}
		
		private function onTouch( e:TouchEvent ):void {
			var t:Touch = e.getTouch( stage );
			
			if ( t == null ) return;
			
			t.getLocation( stage, App.globalPointerLocation );
			//if ( t.phase == TouchPhase.ENDED )
				//if ( t.tapCount == 2 ) 
					//App.toggleFullScreen();
		}
		
		private function enqueueAssets():void {
			
			CONFIG::air
			{ 
				App.assets.enqueue( "assets/" ); 
				return; 
			}
			
			App.assets.enqueue( "assets/font1.fnt" )
			App.assets.enqueue( "assets/font2.fnt" )
			App.assets.enqueue( "assets/font3.fnt" )
			App.assets.enqueue( "assets/bg.jpg" )
			App.assets.enqueue( "assets/mainbg.jpg" )
			App.assets.enqueue( "assets/ring1.jpg" )
			App.assets.enqueue( "assets/ring2.jpg" )
			App.assets.enqueue( "assets/main-rgb.atf" )
			App.assets.enqueue( "assets/main-rgb.xml" )
			App.assets.enqueue( "assets/main-rgba.atf" )
			App.assets.enqueue( "assets/main-rgba.xml" )
		}
		
		private function startLoadingAssets():void {
			
			loadingText = new TextField(
				stage.stageWidth, stage.stageHeight,
				"...", "Arial Black", 80, 0x304050, true );
			addChild( loadingText );
			
			App.assets.initialize( onLoadingAppProgress, onLoadingAppComplete );
		}
		
		private function onLoadingAppProgress( progress:Number ):void {
			loadingText.text = int ( progress * 100 ) + "%";
			loadingText.width = stage.stageWidth;
			loadingText.height = stage.stageHeight;
		}
		
		private function onLoadingAppComplete():void {
			CONFIG::development
			{ stage.addEventListener(KeyboardEvent.KEY_DOWN, onkey); }
			
			loadingText.removeFromParent( true );
			loadingText = null;
			
			/// META
			const UID:String = new Date().time.toString( 36 );
			
			gameMeta = new GameMeta();
			gameMeta.myUserColor = Math.random() * 0xFFFFFF;
			gameMeta.myUserName = "User_" + UID;
			CONFIG::air { gameMeta.myUserName = File.userDirectory.name }
			CONFIG::mobile { gameMeta.myUserName = Capabilities.cpuArchitecture+"_"+UID }
			
			/// MENU
			//CONFIG::desktop { Temp.tweenAppSize( App.WINDOW_W, App.WINDOW_H, showMenu ); return; }
			
			App.cardsData.load( onLoadingCardsComplete );
		}
		
		private function onLoadingCardsComplete():void {
			
			CONFIG::quickplay { 
				startGame( gameMeta );
				//showLobby();
				return;
			}
			
			showMenu();
		}
		
		private function showMenu():void {
			
			if ( menuContainer == null )
			{
				menuContainer = new Sprite();
				addChild( menuContainer );
				var bg:Image = App.assets.generateImage( "mainbg", false, false );
				bg.blendMode = BlendMode.NONE;
				menuContainer.addChild( bg );
				
				bg.alpha = .0;
				Starling.juggler.tween( bg, .250, { alpha : 2.0 } );
				
				var b1:Button = new Button( App.assets.getTexture( "btn" ), "LOCAL" );
				b1.alignPivot();
				b1.fontSize = 30;
				b1.fontName = "Impact";
				b1.fontColor = 0x999999;
				b1.addEventListener( Event.TRIGGERED, startSingle );
				menuContainer.addChild( b1 );
				
				b1.alpha = .0;
				Starling.juggler.tween( b1, .330, { delay : .200, alpha : 1.0 } );
				
				var b2:Button = new Button( App.assets.getTexture( "btn" ), "REMOTE" );
				b2.alignPivot();
				b2.fontSize = 30;
				b2.fontName = "Impact";
				b2.fontColor = 0x999999;
				b2.addEventListener( Event.TRIGGERED, showLobby );
				menuContainer.addChild( b2 );
				
				b2.alpha = .0;
				Starling.juggler.tween( b2, .330, { delay : .200, alpha : 2.0 } );
				
				//
				
				var oo:Sprite = new Sprite();
				oo.scaleX = 1.5;
				menuContainer.addChild( oo );
				var o:Image;
				o = App.assets.generateImage( "ring1", false, true );
				o.blendMode = BlendMode.ADD;
				o.color = 0xFF0000;
				Starling.juggler.tween( o, 14, { rotation : 2.0 * Math.PI, repeatCount : 0 } );
				oo.addChild( o );
				o = App.assets.generateImage( "ring2", false, true );
				o.blendMode = BlendMode.ADD;
				o.color = 0xFF0000;
				Starling.juggler.tween( o, 17, { rotation :-2.0 * Math.PI, repeatCount : 0 } );
				oo.addChild( o );
				
				var oo2:Sprite = new Sprite();
				oo2.scaleX = 1.486;
				addChild( oo2 );
				o = App.assets.generateImage( "ring1", false, true );
				o.blendMode = BlendMode.ADD;
				o.color = 0x00FFFF;
				Starling.juggler.tween( o, 14, { rotation : 2.0 * Math.PI, repeatCount : 0 } );
				oo2.addChild( o );
				o = App.assets.generateImage( "ring2", false, true );
				o.blendMode = BlendMode.ADD;
				o.color = 0x00FFFF;
				Starling.juggler.tween( o, 17, { rotation :-2.0 * Math.PI, repeatCount : 0 } );
				oo2.addChild( o );
				
				//oo.alpha = .0; oo.scaleX = .5; oo.scaleY = .5;
				//Starling.juggler.tween( oo, .300, { alpha : 1.0, scaleX : 1.0 , scaleY : 1.0 } );
				
				//addChild( new AuraModel() );
				
				//
				
				stage.addEventListener( ResizeEvent.RESIZE, onResize );
				function onResize( e:ResizeEvent ):void 
				{
					b1.x = .25 * stage.stageWidth;
					b1.y = .50 * stage.stageHeight;
					b2.x = .75 * stage.stageWidth;
					b2.y = .50 * stage.stageHeight;
					bg.width = stage.stageWidth;
					bg.height = stage.stageHeight;
					oo.x = .50 * stage.stageWidth;
					oo.y = .13 * stage.stageHeight;
					oo2.x = .50 * stage.stageWidth;
					oo2.y = .13 * stage.stageHeight;
				}
				onResize( null );
			}
			else
			{
				menuContainer.visible = true;
			}
		}
		
		private function hideMenu():void {
			if ( menuContainer == null )
				return;
			menuContainer.visible = false;
		}
		
		private function showLobby():void {
			trace( "Opening Lobby" );
			lobby = new Lobby();
			lobby.readyCallback = startMulti;
			addChild( lobby );
			lobby.initialize( gameMeta );
		}
		
		private function startSingle():void {
			gameMeta.isMultiplayer = false;
			startGame( gameMeta );
		}
		
		private function startMulti( room:String, enemy:String ):void {
			trace( "Starting remote game", room, enemy );
			
			gameMeta.isMultiplayer = true;
			gameMeta.roomName = room;
			startGame( gameMeta );
		}
		
		private function startGame( meta:GameMeta ):void {
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
		
		private function onGameDestroyed():void {
			g.removeEventListener( GameEvents.DESTROY, onGameDestroyed );
			g = null;
			
			showMenu();
		}
		
		CONFIG::development
		private function onkey( e:KeyboardEvent ):void {
			
			if ( e.keyCode == Keyboard.ESCAPE ) {
				//if ( g != null )
					//g.endGame();
				if ( Game.current && Game.current.currentPlayer && Game.current.currentPlayer.controllable )
					Game.current.currentPlayer.performAction(
						new PlayerAction().setTo( PlayerActionType.END_TURN ) );
			}
			
			if ( e.keyCode == Keyboard.BACK ) {
				e.preventDefault();
				e.stopImmediatePropagation();
				if ( g != null ) g.endGame();
			}
			
			CONFIG::desktop
			{
				if ( e.keyCode == Keyboard.NUMBER_2 ) {
					Temp.tweenAppSize( Math.random() * 2000, Math.random() * 1000 );
				}
				if ( e.keyCode == Keyboard.F ) {
					App.toggleFullScreen();
				}
				if ( e.keyCode == Keyboard.SPACE ) {
					//g.performActionTurnEnd();
					App.toggleFullScreen();
				}
				if ( e.keyCode == Keyboard.ESCAPE ) {
					App.nativeWindow.close();
				}
				if ( e.keyCode == Keyboard.NUMPAD_ADD ) {
					root.scaleX *= 2.0;
					root.scaleY *= 2.0;
				}
				if ( e.keyCode == Keyboard.NUMPAD_SUBTRACT ) {
					root.scaleX *= .5;
					root.scaleY *= .5;
				}
			}
			
			if ( e.keyCode == Keyboard.CAPS_LOCK ) {
				Game.GODMODE = !Game.GODMODE;
			}
			
			if ( g == null || !g.interactable )
				return;
			
			if ( e.keyCode == Keyboard.NUMBER_1 ) {
				g.currentPlayer.mana.raiseCap();
				g.currentPlayer.mana.refill();
				g.gui.updateData();
			}
		}
	}
}