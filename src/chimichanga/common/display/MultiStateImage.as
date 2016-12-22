package chimichanga.common.display {
	import starling.animation.IAnimatable;
	import starling.animation.Juggler;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;
	
	
	
	/// Dispatched just before a state is changed. Passes the new state as event.data (don't forget to type-cast it as int).
	[Event(name="change", type="starling.events.Event")] 
	public class MultiStateImage extends Image {
		
		private var _juggler:Juggler;
		private var _textures:Vector.<Texture>;
		private var _texturesLen:int;
		private var _currentState:int = 0;
		private var _defaultState:int = 0;
		private var _delayedCallID:uint;
		
		/// Expects a list of arguments of type Texture, or a single argument of type Vector.<Texture>
		public function MultiStateImage( ...tex ) 
		{
			this._juggler = Starling.juggler;
			if ( tex[ 0 ] is Vector.<Texture> ) 
			{
				this._textures = Vector.<Texture>( tex[ 0 ] ).concat();
			} 
			else 
			{
				this._textures = new Vector.<Texture>();
				for each ( var o:Object in tex ) 
					if ( o is Texture )
						this._textures.push( o as Texture );
			}
			this._texturesLen = _textures.length;
			super( _textures[0] );
		}
		
		override public function dispose():void 
		{
			clearDelayedCall();
			_textures.length = 0;
			_textures = null;
			_juggler = null;
			super.dispose();
		}
		
		protected function setCurrentState( state:int ):void 
		{
			if ( state == _currentState )
				return;
			dispatchEventWith( Event.CHANGE, false, state );
			this._currentState = state;
			this.texture = _textures[ state ];
			this.readjustSize();
		}
		
		/// Sets both current and default state, ending any temporary state in progress
		public function setState( state:int ):void 
		{
			clearDelayedCall();
			setCurrentState( state );
			setDefaultState( state );
		}
		
		/// Will not end any temporary state in progress
		public function setDefaultState( state:int ):void 
		{
			this._defaultState = state;
		}
		
		/// Sets a new current state for a specified period of time, then reverts to default state
		public function setTempState( state:int, time:Number ):void 
		{
			clearDelayedCall();
			setCurrentState( state );
			_delayedCallID = _juggler.delayCall( setCurrentState, time, _defaultState );
		}
		
		private function clearDelayedCall():void 
		{
			_juggler.removeByID( _delayedCallID );
		}
		
		//
		
		public function get currentState():int 
		{
			return _currentState;
		}
		
		public function get defaultState():int 
		{
			return _defaultState;
		}
		
		public function get atDefaultState():Boolean 
		{
			return _currentState == _defaultState;
		}
		
		public function get juggler():Juggler 
		{
			return _juggler;
		}
		
		public function set juggler(value:Juggler):void 
		{
			_juggler = value;
		}
		
		public function get numStates():int 
		{
			return _texturesLen;
		}
		
	}

}