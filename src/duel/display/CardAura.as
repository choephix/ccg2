package duel.display
{
	import duel.Game;
	import starling.animation.Transitions;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardAura extends Image
	{
		public var scale:Number = 1.0;
		
		public function CardAura( assetName:String )
		{
			super( App.assets.getTexture( assetName ) );
			this.touchable = false;
			this.blendMode = BlendMode.ADD;
			alignPivot();
			
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage )
		}
		
		private function onAddedToStage( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			
			scaleX = scale;
			scaleY = scale;
			Game.current.juggler.tween( this, 0.5, {
					scaleX:scale+.03,
					scaleY:scale+.02,
					repeatCount:0,
					reverse:true,
					transition:Transitions.EASE_IN
				} );
		}
	}
}