package screens.mainmenu {
	import chimichanga.common.display.Sprite;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	
	public class Screen_MainMenu extends Sprite {
		public var callback_StartSingle:Function;
		public var callback_ShowLobby:Function;
		public var callback_DeckBuilder:Function;
		
		private var bg:Image;
		private var b1:Button;
		private var b2:Button;
		private var b3:Button;
		
		public function initialize():void {
			bg = App.assets.generateImage( "mainbg", false, false );
			bg.blendMode = BlendMode.NONE;
			bg.alpha = .0;
			this.addChild( bg );
			Starling.juggler.tween( bg, .250, { alpha: 2.0 } );
			
			b1 = manufactureButton( "LOCAL", startSingle );
			b2 = manufactureButton( "REMOTE", showLobby );
			b3 = manufactureButton( "MY DECKS", openDeckbuilder );
			
			if ( stage == null )
				addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			else
				onAddedToStage( null );
		}
		
		private function manufactureButton( label:String, eventHandler:Function ):Button {
			var b:Button;
			b = new Button( App.assets.getTexture( "btn" ), label );
			b.alignPivot();
			b.textFormat.size = 30;
			b.textFormat.font = "Impact";
			b.textFormat.color = 0x999999;
			b.addEventListener( Event.TRIGGERED, eventHandler );
			b.alpha = .0;
			this.addChild( b );
			Starling.juggler.tween( b, .330, { delay: .200, alpha: 1.0 } );
			return b;
		}
		
		private function startSingle( e:Event ):void {
			callback_StartSingle();
		}
		
		private function showLobby( e:Event ):void {
			callback_ShowLobby();
		}
		
		private function openDeckbuilder( e:Event ):void {
			callback_DeckBuilder();
		}
		
		private function onAddedToStage( e:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			addEventListener( Event.REMOVED_FROM_STAGE, removedFromStage );
			stage.addEventListener( ResizeEvent.RESIZE, onResize );
			
			onResize( null );
		}
		
		private function removedFromStage( e:Event ):void {
			stage.removeEventListener( ResizeEvent.RESIZE, onResize );
			removeEventListener( Event.ADDED_TO_STAGE, removedFromStage );
		}
		
		private function onResize( e:ResizeEvent ):void {
			bg.width = stage.stageWidth;
			bg.height = stage.stageHeight;
			b1.x = .25 * stage.stageWidth;
			b1.y = .50 * stage.stageHeight;
			b2.x = .50 * stage.stageWidth;
			b2.y = .50 * stage.stageHeight;
			b3.x = .75 * stage.stageWidth;
			b3.y = .50 * stage.stageHeight;
		}
	
	}

}