package {
	import chimichanga.common.display.Sprite;
	import duel.Game;
	import duel.GameEvents;
	import duel.GameMeta;
	import flash.ui.Keyboard;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class StarlingMain extends Sprite {
		private var g:Game;
		
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
			App.assets.initialize( null, onLoadingAppComplete );
		}
		
		private function onLoadingAppComplete():void {
			CONFIG::development
			{ stage.addEventListener(KeyboardEvent.KEY_DOWN, onkey); }
			
			var b1:Button = new Button( App.assets.getTexture( "card" ), "LOCAL" );
			b1.alignPivot();
			b1.fontSize = 30;
			b1.fontName = "Impact";
			b1.x = .25 * stage.stageWidth;
			b1.y = .50 * stage.stageHeight;
			b1.addEventListener( Event.TRIGGERED, onB1 );
			addChild( b1 );
			
			var b2:Button = new Button( App.assets.getTexture( "card" ), "REMOTE" );
			b2.alignPivot();
			b2.fontSize = 30;
			b2.fontName = "Impact";
			b2.x = .75 * stage.stageWidth;
			b2.y = .50 * stage.stageHeight;
			b2.addEventListener( Event.TRIGGERED, onB2 );
			addChild( b2 );
			
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
			
			if ( e.keyCode == Keyboard.F ) {
				App.toggleFullScreen();
			}
			if ( e.keyCode == Keyboard.SPACE ) {
				//g.performActionTurnEnd();
				App.toggleFullScreen();
			}
			if ( e.keyCode == Keyboard.ESCAPE ) {
				if ( g == null )
					App.nativeWindow.close();
				else
					g.endGame();
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