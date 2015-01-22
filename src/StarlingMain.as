package {
	import chimichanga.common.display.Sprite;
	import dev.Temp;
	import duel.Game;
	import duel.GameEvents;
	import duel.GameMeta;
	import flash.ui.Keyboard;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class StarlingMain extends Sprite {
		private var g:Game;
		private var loadingText:TextField;
		
		public function StarlingMain() {
			blendMode = BlendMode.NORMAL;
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}
		
		private function onAddedToStage( e:Event = null ):void {
			removeEventListeners( Event.ADDED_TO_STAGE );
			App.initialize( this );
			
			enqueueAssets();
			Starling.juggler.delayCall( startLoadingAssets, .25 );
		}
		
		private function enqueueAssets():void {
			
			CONFIG::air
			{ 
				App.assets.enqueue( "assets/" ); 
				return; 
			}
			
			App.assets.enqueue( "assets/bg.jpg" )
			App.assets.enqueue( "assets/mainbg.jpg" )
			App.assets.enqueue( "assets/btn.png" )
			App.assets.enqueue( "assets/card.png" )
			App.assets.enqueue( "assets/card-aura.jpg" )
			App.assets.enqueue( "assets/card-back.png" )
			App.assets.enqueue( "assets/card-blood.jpg" )
			App.assets.enqueue( "assets/card-glow.png" )
			App.assets.enqueue( "assets/card-sele2.png" )
			App.assets.enqueue( "assets/card-selectable.png" )
			App.assets.enqueue( "assets/exhaustClock.png" )
			App.assets.enqueue( "assets/field.png" )
			App.assets.enqueue( "assets/hadouken.png" )
			App.assets.enqueue( "assets/iconLock.png" )
			App.assets.enqueue( "assets/ring.png" )
			App.assets.enqueue( "assets/characters/char1.png" )
			App.assets.enqueue( "assets/characters/char2.png" )
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
			
			CONFIG::air
			{ Temp.tweenAppSize( App.W, App.H, showMenu ); return; }
			
			showMenu();
		}
		
		private function showMenu():void {
			
			var bg:Image = App.assets.generateImage( "mainbg", false, false );
			bg.width = App.W;
			bg.height = App.H;
			addChild( bg );
			
			bg.alpha = .0;
			Starling.juggler.tween( bg, .250, { alpha : 2.0 } );
			
			var b1:Button = new Button( App.assets.getTexture( "card" ), "LOCAL" );
			b1.alignPivot();
			b1.fontSize = 30;
			b1.fontName = "Impact";
			b1.x = .25 * stage.stageWidth;
			b1.y = .50 * stage.stageHeight;
			b1.addEventListener( Event.TRIGGERED, onB1 );
			addChild( b1 );
			
			b1.alpha = .0;
			Starling.juggler.tween( b1, .330, { delay : .200, alpha : 1.0 } );
			
			var b2:Button = new Button( App.assets.getTexture( "card" ), "REMOTE" );
			b2.alignPivot();
			b2.fontSize = 30;
			b2.fontName = "Impact";
			b2.x = .75 * stage.stageWidth;
			b2.y = .50 * stage.stageHeight;
			b2.addEventListener( Event.TRIGGERED, onB2 );
			addChild( b2 );
			
			b2.alpha = .0;
			Starling.juggler.tween( b2, .330, { delay : .200, alpha : 2.0 } );
			
			var gameMeta:GameMeta = new GameMeta();
			
			function onB1():void
			{
				gameMeta.isMultiplayer = false;
				startGame( gameMeta );
			}
			function onB2():void
			{
				gameMeta.isMultiplayer = true;
				startGame( gameMeta );
			}
		}
		
		private function startGame( meta:GameMeta ):void {
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
		}
		
		CONFIG::development
		private function onkey( e:KeyboardEvent ):void {
			
			if ( e.keyCode == Keyboard.ESCAPE ) {
				if ( g != null )
					g.endGame();
			}
			
			CONFIG::air
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