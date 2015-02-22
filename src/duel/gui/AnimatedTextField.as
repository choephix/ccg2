package duel.gui
{
	import starling.animation.IAnimatable;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class AnimatedTextField extends TextField implements IAnimatable
	{
		public static const DEFAULT_MARKER:String = "%%VALUE%%";
		
		public var durationPerOne:Number;
		public var duration:Number = .350;
		public var markerString:String = DEFAULT_MARKER;
		private var rawText:String = markerString;
		private var _currentValue:Number = 0.0;
		private var _targetValue:Number = 0.0;
		private var _valueTween:Tween;
		
		public function AnimatedTextField( width:int, height:int, text:String, fontName:String = "Verdana", fontSize:Number = 12, color:uint = 0, bold:Boolean = false )
		{
			super( width, height, text, fontName, fontSize, color, bold );
			rawText = text;
			update();
			
			_valueTween = new Tween( this, duration, Transitions.LINEAR );
		}
		
		public function advanceTime( time:Number ):void
		{
			if ( _valueTween.isComplete ) return;
			_valueTween.advanceTime( time );
		}
		
		private function update():void
		{
			super.text = rawText.replace( markerString, currentValue );
		}
		
		//
		override public function get text():String
		{
			///return super.text;
			return rawText;
		}
		
		override public function set text( value:String ):void
		{
			if ( rawText == value )
				return;
				
			rawText = value;
			update();
		}
		
		//
		public function get targetValue():Number
		{
			return _targetValue;
		}
		
		public function set targetValue( value:Number ):void
		{
			if ( _targetValue == value )
				return;
			
			_targetValue = value;
			
			if ( !isNaN( durationPerOne ) )
				duration = Math.abs( _currentValue - _targetValue ) * durationPerOne;
			
			_valueTween.reset( this, duration, Transitions.LINEAR );
			_valueTween.animate( "currentValue", value );
			_valueTween.roundToInt = true;
		}
		
		public function get currentValue():Number
		{
			return _currentValue;
		}
		
		public function set currentValue( value:Number ):void
		{
			_currentValue = value;
			update();
		}
		
	}
	
}