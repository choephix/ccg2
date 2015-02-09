package ui
{
	import chimichanga.common.display.Sprite;
	import starling.display.Quad;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class AddCardButton extends Sprite
	{
		private static const CW = .5 * G.CARD_W;
		private static const CH = .5 * G.CARD_H;
		
		private var q1:Quad;
		private var q2:Quad;
		private var q3:Quad;
		private var q4:Quad;
		
		public function AddCardButton()
		{
			super();
			
			q1 = addSubButton( 0xffccaa );
			q1.x = 0;
			q1.y = 0;
			q2 = addSubButton( 0xF8AD81 );
			q2.x = CW;
			q2.y = 0;
			q3 = addSubButton( 0xF2FFAA );
			q3.x = 0;
			q3.y = CH;
			q4 = addSubButton( 0xABADFE );
			q4.x = CW;
			q4.y = CH;
			
			addEventListener( TouchEvent.TOUCH, onTouch );
		}
		
		private function onTouch( e:TouchEvent ):void
		{
			var t:Touch = e.getTouch( this, TouchPhase.ENDED )
			
			//...
		}
		
		private function addSubButton( color:uint ):Quad
		{
			var q:Quad;
			q = new Quad( CW, CH, color, true );
			addChild( q );
			return q;
		}
	}
}