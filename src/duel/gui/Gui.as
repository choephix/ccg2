package duel.gui {
	import duel.GameSprite;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Gui extends GameSprite
	{
		private var t1:TextField;
		private var t2:TextField;
		
		public function Gui()
		{
			const INSET:Number = 10;
			
			t1 = new TextField( 0, 0, "", "Impact", 50 );
			addChild( t1 );
			t1.x = INSET;
			t1.width = App.W - INSET * 2.0;
			t1.height = App.H;
			t1.color = 0xFFEE22;
			t1.hAlign = "right";
			t1.vAlign = "bottom";
			t1.touchable = false;
			
			t2 = new TextField( 0, 0, "", "Impact", 50 );
			addChild( t2 );
			t2.x = INSET;
			t2.width = App.W - INSET * 2.0;
			t2.height = App.H;
			t2.color = 0xFFEE22;
			t2.hAlign = "left";
			t2.vAlign = "top";
			t2.touchable = false;
		}
		
		public function advanceTime(time:Number):void 
		{
			t1.text = game.p1.name + ": " + game.p1.lp;
			t2.text = game.p2.name + ": " + game.p2.lp;
		}
	}

}