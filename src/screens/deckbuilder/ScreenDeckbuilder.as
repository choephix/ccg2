package screens.deckbuilder 
{
	import chimichanga.common.display.Sprite;
	import starling.display.Quad;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ScreenDeckbuilder extends Sprite 
	{
		public var bg:Quad;
		
		public function ScreenDeckbuilder() 
		{
			bg = new Quad( 1000, 1000, 0x162534 );
			addChild( bg );
			
			
		}
		
	}

}