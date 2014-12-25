package duel.table 
{
	import duel.Field;
	import duel.G;
	import duel.Game;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class FieldSprite extends Image 
	{
		private var owner:Field;
		
		public function FieldSprite( owner:Field, color:uint ) 
		{
			this.owner = owner;
			
			super( App.assets.getTexture( "field" ) );
			this.width = G.CARD_W;
			this.height = G.CARD_H;
			this.color = color; 
			//this.alpha = 0.5;
			this.touchable = true;
			this.useHandCursor = true;
			alignPivot();
			
			addEventListener( TouchEvent.TOUCH, onTouch );
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var t:Touch = e.getTouch( this );
			
			if ( t == null ) return;
			
			if ( t.phase == TouchPhase.ENDED ) {
				Game.current.onFieldClicked( owner );
			} 
		}
		
	}

}