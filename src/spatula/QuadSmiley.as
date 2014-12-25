package spatula
{
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class QuadSmiley extends DisplayObjectContainer
	{
		
		public function QuadSmiley()
		{
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}
		
		private function onAddedToStage( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			
			addQuad( 0, 0, 10, 10, 0x171f09 );
			
			const CLR:uint = 0xCCFF00;
			addQuad( 3, 1, 4, 3, CLR );
			addQuad( 6, 1, 7, 3, CLR );
			addQuad( 3, 4, 4, 6, CLR );
			addQuad( 4, 4, 6, 5, CLR );
			addQuad( 6, 4, 7, 6, CLR );
			addQuad( 1, 6, 2, 9, CLR );
			addQuad( 2, 8, 8, 9, CLR );
			addQuad( 8, 6, 9, 9, CLR );
		}
		
		private function addQuad( x1:Number, y1:Number, x2:Number, y2:Number, color:uint ):void
		{
			var q:Quad;
			q = new Quad( x2 - x1, y2 - y1, color );
			q.x = x1;
			q.y = y1;
			addChild( q );
		}
	
	}

}