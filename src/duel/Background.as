package duel 
{
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Background extends Image 
	{
		public var onClickedCallback:Function;
		
		public function Background(texture:Texture) 
		{
			super(texture);
			this.width = App.W;
			this.height = App.H;
			this.touchable = true;
			
			addEventListener( TouchEvent.TOUCH, onTouch );
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var t:Touch = e.getTouch( this );
			
			if ( t == null ) return;
			
			if ( t.phase == TouchPhase.ENDED ) {
				if ( onClickedCallback ) {
					onClickedCallback();
				}
			} 
		}
		
	}

}