package duel.display {
	import duel.G;
	import duel.Game;
	import starling.animation.Transitions;
	import starling.display.Image;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardAura extends Image 
	{
		
		public function CardAura() 
		{
			super( App.assets.getTexture( "card-aura" ) );
			this.touchable = false;
			this.useHandCursor = false;
			alignPivot();
			
			Game.current.jugglerMild.tween( this, 0.5, {
					scaleX:1.03,
					scaleY:1.03,
					repeatCount:0,
					reverse:true,
					transition:Transitions.EASE_IN
				} );
		}
	}
}