package screens.mainmenu
{
	import chimichanga.common.display.Sprite;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	
	public class Screen_MainMenu extends Sprite
	{
		public var callback_StartSingle:Function;
		public var callback_ShowLobby:Function;
		
		private var bg:Image;
		private var b1:Button;
		private var b2:Button;
		
		public function initialize():void
		{
			bg = App.assets.generateImage("mainbg", false, false);
			bg.blendMode = BlendMode.NONE;
			bg.alpha = .0;
			this.addChild(bg);
			Starling.juggler.tween(bg, .250, {alpha: 2.0});
			
			b1 = new Button(App.assets.getTexture("btn"), "LOCAL");
			b1.alignPivot();
			b1.textFormat.size = 30;
			b1.textFormat.font = "Impact";
			b1.textFormat.color = 0x999999;
			b1.addEventListener(Event.TRIGGERED, startSingle);
			b1.alpha = .0;
			this.addChild(b1);
			Starling.juggler.tween(b1, .330, {delay: .200, alpha: 1.0});
			
			b2 = new Button(App.assets.getTexture("btn"), "REMOTE");
			b2.alignPivot();
			b2.textFormat.size = 30;
			b2.textFormat.font = "Impact";
			b2.textFormat.color = 0x999999;
			b2.addEventListener(Event.TRIGGERED, showLobby);
			b2.alpha = .0;
			this.addChild(b2);
			Starling.juggler.tween(b2, .330, {delay: .200, alpha: 2.0});
			
			if ( stage == null )
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage );
			else 
				onAddedToStage( null );
		}
		
		private function startSingle(e:Event):void 
		{
			callback_StartSingle();
		}
		
		private function showLobby(e:Event):void 
		{
			callback_ShowLobby();
		}
		
		private function onAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			stage.addEventListener( ResizeEvent.RESIZE, onResize );
			
			onResize( null );
		}
		
		private function removedFromStage(e:Event):void 
		{
			stage.removeEventListener( ResizeEvent.RESIZE, onResize );
			removeEventListener(Event.ADDED_TO_STAGE, removedFromStage);
		}
		
		private function onResize( e:ResizeEvent ):void 
		{
			bg.width = stage.stageWidth;
			bg.height = stage.stageHeight;
			b1.x = .25 * stage.stageWidth;
			b1.y = .50 * stage.stageHeight;
			b2.x = .75 * stage.stageWidth;
			b2.y = .50 * stage.stageHeight;
		}
	
	}

}