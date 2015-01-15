package {
	import chimichanga.common.display.Sprite;
	import duel.Game;
	import duel.GameEvents;
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
			if ( e.keyCode == Keyboard.NUMBER_1 ) {
				g.currentPlayer.mana.raiseCap();
				g.currentPlayer.mana.refill();
				g.gui.updateData();
			}
		}
	}
}