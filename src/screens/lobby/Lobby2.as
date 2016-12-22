package screens.lobby 
{
	import chimichanga.common.display.Sprite;
	import duel.GameMeta;
	import starling.display.Quad;
	
	
	public class Lobby2 extends Sprite 
	{
		/// Must expect tweo args: roomName:String, opponentName:String
		public var readyCallback:Function;
		
		///
		private var background:Quad;
		private var buttons:Sprite;
		
		public function initialize( meta:GameMeta ):void
		{
			var myEnterTime:Number = new Date().time;
			connection.connect( meta.myUserName, new UserDetails( meta.myUserColor, myEnterTime ) );
			////
			
			background = new Quad( 10, 10, 0x110044 );
			background.alpha = .5;
			addChild( background );
			buttons = new Sprite();
			addChild( buttons );
			width = App.STAGE_W;
			height = App.STAGE_H;
			
			addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
			stage.addEventListener( ResizeEvent.RESIZE, onResize );
			onResize( null );
		}
		
		private function onRemovedFromStage(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			stage.removeEventListener( ResizeEvent.RESIZE, onResize );
		}
		
		override public function dispose():void 
		{
			background.removeFromParent( true );
			background = null;
			
			buttons.removeFromParent( true );
			buttons = null;
			
			super.dispose();
		}
		
		private function onResize( e:ResizeEvent ):void 
		{
			x = .5 * stage.stageWidth;
			width = .5 * stage.stageWidth;
			height = stage.stageHeight;
		}
		
		private function onReady( room:String, enemy:String ):void
		{
			trace ( "ready to head to room '" + room + "' to play against " + enemy );
			
			readyCallback( room, enemy );
		}
		
		public function close():void
		{
			removeFromParent( true );
		}
		
		override public function get width():Number 
		{
			return background.width;
		}
		
		override public function set width(value:Number):void 
		{
			background.width = value;
			buttons.x = .5 * background.width;
		}
		
		override public function get height():Number 
		{
			return background.height;
		}
		
		override public function set height(value:Number):void 
		{
			background.height = value;
			buttons.y = 50;
		}
	}
}