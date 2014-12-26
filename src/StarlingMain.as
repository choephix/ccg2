package {
	import chimichanga.common.display.Sprite;
	import duel.GameEvents;
	import duel.processes.ProcessManager;
	import ecs.core.World;
	import ecs.entities.Box;
	import ecs.entities.Floor;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import duel.Game;
	import spatula.Trail;
	import spatula.Trail3;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
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
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onkey);
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
		
		private function onkey( e:KeyboardEvent ):void {
			if ( e.keyCode == Keyboard.ESCAPE ) {
				g.endGame();
			}
			if ( e.keyCode == Keyboard.SPACE ) {
				g.endTurn();
			}
			if ( e.keyCode == Keyboard.Q ) {
				g.processes.enqueueProcess( ProcessManager.gen( "test <<" ) );
			}
			if ( e.keyCode == Keyboard.W ) {
				g.processes.interruptCurrentProcess( ProcessManager.gen( "test >>" ) );
			}
			if ( e.keyCode == Keyboard.E ) {
				g.jugglerStrict.delayCall( trace, 1 );
			}
		}
	}
}