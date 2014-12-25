package chimichanga.common.input {
	import starling.display.Stage;
	import starling.events.KeyboardEvent;
	
	/** Use this input manager to register named buttons for your game and associate 
	 * multiple actual keyboard keys with that button. Instead of using event listeners
	 * you will be providing custom callback+callbackArgs pairs for notification of
	 * button state change.
	 * 
	 * Chimichanga InputManager also gives you the option to register to keys as
	 * opposing inputs for a named input axis (e.g. "A" and "D" for "move"). When
	 * watching for axis-change you cannot pair arguments with your callback, instead
	 * your callback will be called with the axis's state current state as a parameter
	 * of type Number (-1.0 to 1.0).
	 * 
	 * Lastly make sure you call clearStates() when for example before app is deactivated
	 * so that all axises will reset and all button will revert to "unpressed" states
	 * which will eliminatethe issue where your character has kept moving to the right 
	 * while you Alt+Tabbed for a while or something.
	 * 
	 * @author choephix
	 */
	public class InputManager {
		
		private var mStage:Stage;
		private var mEnabled:Boolean = false;
		private var mCtrl:Boolean;
		private var mAlt:Boolean;
		private var mShift:Boolean;
		private var mButtons:Object;
		private var mAxises:Object;
		
		public function InputManager( stage:Stage = null ) {
			mButtons = new Object();
			mAxises = new Object();
			if ( stage ) {
				initialize( stage );
			}
		}
		
		public function initialize( stage:Stage ):void {
			this.mStage = stage;
			enabled = true;
		}
		
		
		//{ BUTTON/AXIS REGISTRATION
		public function registerButtonKey( name:String, keyCode:uint ):void {
			var b:Button = mButtons[name] == undefined ? registerNewButton( name ) : mButtons[name];
			if ( b.keys.indexOf( keyCode ) >= 0 ) return;
			b.keys.push( keyCode );
		}
		private function registerNewButton( name:String ):Button {
			return mButtons[name] = new Button();
		}
		
		public function deregisterButton( name:String ):void {
			delete mButtons[name];
		}
		
		
		public function registerAxisKeys( name:String, keyCodeNegative:uint, keyCodePositive:uint ):void {
			var b:Axis = mAxises[name] == undefined ? registerNewAxis( name ) : mAxises[name];
			b.keysNeg.push( keyCodeNegative );
			b.keysPos.push( keyCodePositive );
		}
		
		private function registerNewAxis( name:String ):Axis {
			return mAxises[name] = new Axis();
		}
		
		public function deregisterAxis( name:String ):void {
			delete mAxises[name];
		}
		
		//}
		
		//{
		public function getButtonState( name:String ):Boolean {
			return mButtons[name] != undefined && Button(mButtons[name]).getState();
		}
		
		public function getAxisState( name:String ):Number {
			return mAxises[name] == undefined ? NaN : Axis(mAxises[name]).getState();
		}
		
		//}
		
		//{ WATCHERS
		public function addButtonDownWatcher( buttonName:String, callback:Function, callbackArgs:Array = null ):void {
			var b:Button = mButtons[buttonName] as Button;
			if ( b == null ) throw new ArgumentError( "Button " + buttonName + " was never registered." );
			b.onDown.push( callback );
			b.onDownArgs.push( callbackArgs );
		}
		
		public function addButtonUpWatcher( buttonName:String, callback:Function, callbackArgs:Array = null ):void {
			var b:Button = mButtons[buttonName] as Button;
			if ( b == null ) throw new ArgumentError( "Button " + buttonName + " was never registered." );
			b.onUp.push( callback );
			b.onUpArgs.push( callbackArgs );
		}
		
		public function removeButtonDownWatcher( buttonName:String, callback:Function ):void {
			var b:Button = mButtons[buttonName] as Button;
			if ( b == null ) throw new ArgumentError( "Button " + buttonName + " was never registered." );
			var i:int, len:int = b.onDown.length;
			for ( i = 0; i < len; i++ ) {
				if ( b.onDown[ i ] == callback ) {
					b.onDown.splice( i, 1 );
					b.onDownArgs.splice( i, 1 );
					break;
				}
			}
		}
		
		public function removeButtonUpWatcher( buttonName:String, callback:Function ):void {
			var b:Button = mButtons[buttonName] as Button;
			if ( b == null ) throw new ArgumentError( "Button " + buttonName + " was never registered." );
			var i:int, len:int = b.onUp.length;
			for ( i = 0; i < len; i++ ) {
				if ( b.onUp[ i ] == callback ) {
					b.onUp.splice( i, 1 );
					b.onUpArgs.splice( i, 1 );
					break;
				}
			}
		}
		
		public function addAxisChangeWatcher( axisName:String, callback:Function ):void {
			var b:Axis = mAxises[axisName] as Axis;
			if ( b == null ) throw new ArgumentError( "Axis " + axisName + " was never registered." );
			b.onChange.push( callback );
		}
		
		public function removeAxisChangeWatcher( axisName:String, callback:Function ):void {
			var b:Axis = mAxises[axisName] as Axis;
			if ( b == null ) throw new ArgumentError( "Axis " + axisName + " was never registered." );
			var i:int, len:int = b.onChange.length;
			for ( i = 0; i < len; i++ ) {
				if ( b.onChange[ i ] == callback ) {
					b.onChange.splice( i, 1 );
					break;
				}
			}
		}
		//}
		
		//{ BUTTON AND AXIS STATES
		public function clearStates():void {
			var name:String
			for ( name in mButtons )
				Button(mButtons[name]).setState( false );
			for ( name in mAxises )
				Axis(mAxises[name]).reset();
		}
		//}
		
		//{ SIMULATE
		
		/** Forcefully sets specified button as pressed. Useful when you want to use 
		 * the InputManager in conjunction with some on-screen buttons or an input
		 * device unsupported by this class (which currently only supports keyboard
		 * anyhow) **/
		public function simulateButtonDown( buttonName:String ):void {
			mButtons[buttonName].setState( true );
		}
		
		/** Forcefully sets specified button as unpressed. Useful when you want to use 
		 * the InputManager in conjunction with some on-screen buttons or an input
		 * device unsupported by this class (which currently only supports keyboard
		 * anyhow) **/
		public function simulateButtonUp( buttonName:String ):void {
			mButtons[buttonName].setState( false );
		}
		//}
		
		//{ KEYBOARD HANDLERS
		private function onKeyDown( e:KeyboardEvent ):void {
			processKeyboardEvent( e, true );
		}
		
		private function onKeyUp( e:KeyboardEvent ):void {
			processKeyboardEvent( e, false );
		}
		
		private function processKeyboardEvent( e:KeyboardEvent, down:Boolean ):void {
			mCtrl	= e.ctrlKey;
			mAlt	= e.altKey;
			mShift	= e.shiftKey;
			var name:String
			for ( name in mButtons )
				if ( mButtons[name].keys.indexOf( e.keyCode ) >= 0 )
					mButtons[name].setState( down );
			for ( name in mAxises ) {
				var a:Axis = mAxises[name] as Axis;
				if ( a.keysNeg.indexOf( e.keyCode ) >= 0 )
					a.setStateLeft( down ? 1.0 : 0.0 );
				else
				if ( a.keysPos.indexOf( e.keyCode ) >= 0 )
					a.setStateRight( down ? 1.0 : 0.0 );
			}
		}
		//}
		
		//{ GETTERS & SETTERS
		public function get enabled():Boolean {
			return mEnabled;
		}
		
		public function set enabled(value:Boolean):void {
			if ( enabled == value ) {
				return;
			}
			mEnabled = value;
			if ( value ) {
				mStage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
				mStage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
			} else {
				mStage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
				mStage.removeEventListener( KeyboardEvent.KEY_UP, onKeyUp );
				clearStates();
			}
		}
		
		public function get ctrl():Boolean {
			return mCtrl;
		}
		
		public function get alt():Boolean {
			return mAlt;
		}
		
		public function get shift():Boolean {
			return mShift;
		}
		//}
		
	}

}

internal class Button {
	public var keys:Vector.<uint>;
	public var onDown:Vector.<Function>;
	public var onDownArgs:Vector.<Array>;
	public var onUp:Vector.<Function>;
	public var onUpArgs:Vector.<Array>;
	private var isDown:Boolean;
	public function Button() {
		this.keys			= new Vector.<uint>();
		this.isDown		= false;
		this.onDown	= new Vector.<Function>();
		this.onDownArgs= new Vector.<Array>();
		this.onUp 		= new Vector.<Function>();
		this.onUpArgs 	= new Vector.<Array>();
	}
	public function setState( value:Boolean ):void {
		if ( isDown == value )
			return;
		isDown = value;
		var vf:Vector.<Function> = value ? onDown : onUp;
		var va:Vector.<Array> = value ? onDownArgs : onUpArgs;
		for ( var i:int = 0, len:int = vf.length; i < len; i++ )
			vf[i].apply( null, va[i] );
	}
	public function getState():Boolean {
		return isDown;
	}
}

internal class Axis {
	public var keysNeg:Vector.<uint>;
	public var keysPos:Vector.<uint>;
	public var onChange:Vector.<Function>;
	public var val:Number;
	private var valNeg:Number;
	private var valPos:Number;
	public function Axis() {
		this.keysNeg = new Vector.<uint>();
		this.keysPos = new Vector.<uint>();
		this.onChange = new Vector.<Function>();
		this.val = 0.0;
		this.valNeg = 0.0;
		this.valPos = 0.0;
	}
	public function setStateLeft( value:Number ):void {
		if ( valNeg == value )
			return;
		valNeg = value;
		updateState();
	}
	public function setStateRight( value:Number ):void {
		if ( valPos == value )
			return;
		valPos = value;
		updateState();
	}
	private function updateState():void {
		val = valPos - valNeg;
		for ( var i:int = 0, len:int = onChange.length; i < len; i++ )
			onChange[i].apply( null, [val] );
	}
	public function getState():Number {
		return val;
	}
	public function reset():void {
		if ( valNeg == 0.0 && valPos == 0.0 ) return;
		valNeg = 0.0;
		valPos = 0.0;
		updateState();
	}
}













