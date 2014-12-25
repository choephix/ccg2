package duel.gui
{
	import duel.GameSprite;
	import duel.Player;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Gui extends GameSprite
	{
		private var t1:AnimatedTextField;
		private var t2:AnimatedTextField;
		
		public function Gui()
		{
			const INSET:Number = 10;
			
			t1 = new AnimatedTextField( 0, 0, ( game.p1.name + ": " + AnimatedTextField.DEFAULT_MARKER ), "Impact", 50 );
			addChild( t1 );
			t1.x = INSET;
			t1.width = App.W - INSET * 2.0;
			t1.height = App.H;
			t1.color = 0xFFEE22;
			t1.hAlign = "right";
			t1.vAlign = "bottom";
			t1.touchable = false;
			
			
			t2 = new AnimatedTextField( 0, 0, ( game.p2.name + ": " + AnimatedTextField.DEFAULT_MARKER ), "Impact", 50 );
			addChild( t2 );
			t2.x = INSET;
			t2.width = App.W - INSET * 2.0;
			t2.height = App.H;
			t2.color = 0xFFEE22;
			t2.hAlign = "left";
			t2.vAlign = "top";
			t2.touchable = false;
		}
		
		public function advanceTime( time:Number ):void
		{
			updateTf( t1, game.p1, time );
			updateTf( t2, game.p2, time );
		}
		
		private function updateTf( t:AnimatedTextField, p:Player, time:Number ):void
		{
			t.targetValue = p.lp;
			t.color = p == game.currentPlayer ? 0xFFEE22 : 0xF37618;
			t.advanceTime( time );
		}
	}

}