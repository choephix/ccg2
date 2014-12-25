package duel.gui {
	import duel.GameSprite;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Gui extends GameSprite
	{
		private var t:TextField;
		
		public function Gui()
		{
			t = new TextField( 0, 0, "", "Impact", 50 );
			addChild( t );
			t.width = App.W;
			t.height = App.H;
			t.color = 0xFFEE22;
			t.hAlign = "right";
			t.vAlign = "top";
			t.touchable = false;
		}
		
		public function advanceTime(time:Number):void 
		{
			t.text = 
				game.p2.name + ": " + game.p2.lp +
				"\n" +
				game.p1.name + ": " + game.p1.lp;
		}
	}

}