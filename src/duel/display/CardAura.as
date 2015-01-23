package duel.display {
	import duel.G;
	import duel.Game;
	import starling.animation.Transitions;
	import starling.display.BlendMode;
	import starling.display.Image;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardAura extends Image 
	{
		
		
		public function CardAura( assetName:String ) 
		{
			super( App.assets.getTexture( assetName ) );
			this.touchable = false;
			this.useHandCursor = false;
			alignPivot();
			
			this.blendMode = BlendMode.ADD;
			
			Game.current.juggler.tween( this, 0.5, {
					scaleX:1.01,
					scaleY:1.02,
					repeatCount:0,
					reverse:true,
					transition:Transitions.EASE_IN
				} );
		}
	}
}