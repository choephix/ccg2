package editor 
{
	import chimichanga.common.display.Sprite;
	import other.EditorEvents;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Space extends Sprite 
	{
		public const events:EditorEvents = new EditorEvents();
		
		public function Space() 
		{
			super();
			
			var g1:CardGroup = addGroup();
			g1.addCard( generateNewCard() );
			g1.addCard( generateNewCard() );
			g1.addCard( generateNewCard() );
			g1.addCard( generateNewCard() );
			g1.addCard( generateNewCard() );
			
			var g2:CardGroup = addGroup();
			g2.addCard( generateNewCard() );
			g2.addCard( generateNewCard() );
		}
		
		private function addGroup():CardGroup 
		{
			var g:CardGroup;
			
			g = new CardGroup();
			g.space = this;
			addChild( g );
			
			g.initialize();
			g.tformContracted.x = Math.random() * 800;
			g.tformContracted.y = 100;
			
			return g;
		}
		
		public function generateNewCard():Card
		{
			var c:Card = new Card();
			c.color = Math.random() * 0xffffff;
			addChild( c );
			return c;
		}
		
		//
		
		override public function get width():Number 
		{
			return App.STAGE_W;
		}
		
		override public function set width(value:Number):void 
		{
			throw new Error( "Don't do that!" );
		}
		
		override public function get height():Number 
		{
			return App.STAGE_H;
		}
		
		override public function set height(value:Number):void 
		{
			throw new Error( "Don't do that!" );
		}
	}
}