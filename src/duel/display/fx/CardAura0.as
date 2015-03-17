package duel.display.fx
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
	public class CardAura0 extends CardAura
	{
		public var scale:Number = 1.0;
		private var _tween:Tween;
		private var img:Image;
		
		public function CardAura0( assetName:String = "card-aura" )
		{
			img = App.assets.generateImage( assetName, false, true );
			addChild( img );
			
			this.touchable = false;
			//this.blendMode = BlendMode.ADD;
			
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
		
		override public function advanceTime( time:Number ):void 
		{
			super.advanceTime( time );
			visible = alpha > .03;
			if ( !visible ) return;
			_tween.advanceTime( time );
		}
		
		public function get color():uint { return img.color }
		public function set color(value:uint):void { img.color = value }
	}
}