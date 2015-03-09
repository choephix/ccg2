package duel.display.cards
{
	import duel.Game;
	import starling.animation.IAnimatable;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardAura extends Image implements IAnimatable
	{
		public var scale:Number = 1.0;
		private var _tween:Tween;
		
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
			
			_tween = new Tween( this, .500, Transitions.EASE_IN );
			_tween.repeatCount = 0;
			_tween.reverse = true;
			_tween.animate( "scaleX", scale + .03 );
			_tween.animate( "scaleY", scale + .02 );
		}
		
		public function advanceTime( time:Number ):void 
		{
			visible = alpha > .03;
			if ( !visible ) return;
			_tween.advanceTime( time );
		}
	}
}