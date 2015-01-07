package {
	import chimichanga.common.display.Sprite;
	import duel.Game;
	import duel.GameEvents;
	import flash.filesystem.File;
	import flash.ui.Keyboard;
	import starling.core.Starling;
	import starling.display.BlendMode;
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
			Starling.juggler.delayCall( startLoadingApp, .25 );
		}
		
		private function startLoadingApp():void {
			App.assets.enqueue( File.applicationDirectory.resolvePath( "assets/" ) );
			App.assets.initialize( null, onLoadingAppComplete );
		}
		
		private function onLoadingAppComplete():void {
			CONFIG::development
			{ stage.addEventListener(KeyboardEvent.KEY_DOWN, onkey); }
			
			startGame();
		}
		
		private function startGame():void {
			trace( "Will start new game" );
			g = new Game();
			addChild( g );
			g.addEventListener( GameEvents.DESTROY, onGameDestroyed );
		}
		
		private function onGameDestroyed():void {
			g.removeEventListener( GameEvents.DESTROY, onGameDestroyed );
			Starling.juggler.delayCall( startGame, .250 );
		}
		
		CONFIG::development
		private function onkey( e:KeyboardEvent ):void {
			if ( !g.interactable )
				return;
			
			if ( e.keyCode == Keyboard.ESCAPE ) {
				g.endGame();
			}
			if ( e.keyCode == Keyboard.SPACE ) {
				g.performActionTurnEnd();
			}
			if ( e.keyCode == Keyboard.CAPS_LOCK ) {
				Game.GODMODE = !Game.GODMODE;
			}
		}
	}
}