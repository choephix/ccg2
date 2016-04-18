package screens.deckbuilder 
{
	import chimichanga.common.display.Sprite;
	import duel.G;
	import starling.display.Quad;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class ListItem_Card extends Sprite 
	{
		
		public function ListItem_Card() 
		{
			var bg:Quad = new Quad( G.CARD_W, G.CARD_H, 0xCC7733 );
			addChild( bg );
			
			
		}
		
		public function commitData( data:Object ):void
		{
			
			
			
		}
		
		override public function get width():Number { return G.CARD_W; }
		override public function set width( value:Number ):void { throw new Error( "Don't do that" ); }
		override public function get height():Number { return G.CARD_W; }
		override public function set height( value:Number ):void { throw new Error( "Don't do that" ); }
		
	}

}