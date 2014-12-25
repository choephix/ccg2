package chimichanga.common.display {
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.animation.IAnimatable;
	import starling.animation.Juggler;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.MovieClip;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class MultiStateDisplayObject extends DisplayObjectContainer {
		
		/// Automativally play MovieClip type states when you switch to them. If false you will have to call playCurrentState() to play it
		public var autoplay:Boolean = true;
		/// If true, when the state changes and the old state was a MovieClip, it will be rewinded to its first frame. If false, when you revert back to it, it will continue the loop from where you left it.
		public var autorewind:Boolean = true;
		
		private var mJuggler:Juggler;
        private var mCurrentStateIndex:int = 0;
        private var mDefaultStateIndex:int = 0;
        private var mDelayedCall:IAnimatable;
		
		private var hAlign:String = null;
		private var vAlign:String = null;
		
		private var mColor:uint = 0xFfFfFf;
		
		public function MultiStateDisplayObject( juggler:Juggler=null )
		{
			this.mJuggler = juggler != null ? juggler : Starling.juggler;
		}
        
		public function addState( child:DisplayObject ):int
		{
			super.addChildAt( child, numStates );
			if ( child is MovieClip )
			{
				mJuggler.add( child as MovieClip );
				if ( autoplay && numStates == 1 )
					MovieClip( child ).play();
				else
					MovieClip( child ).stop();
			}
			return numStates - 1;
		}
        
		private function setCurrentState( index:int ):void
		{
			clearTempStateShit();
			mCurrentStateIndex = index;
			if ( autoplay && currentState is MovieClip )
			{
				if ( autorewind )
				{
					MovieClip( currentState ).stop();
				}
				MovieClip( currentState ).play();
			}
			if ( hAlign != null ) 
			{
				currentState.alignPivot( hAlign, vAlign );
				//alignPivot( hAlign, vAlign );
			}
			tryToUpdateStateColor();
		}
		
		public function setDefaultState( index:int, setAsCurrent:Boolean=false ):void
		{
			mDefaultStateIndex = index;
			if ( setAsCurrent )
			{
				setCurrentState( index );
			}
		}
		
		public function setTempState( index:int, time:Number ):void 
		{
			setCurrentState( index );
			mDelayedCall = mJuggler.delayCall( setCurrentState, time, mDefaultStateIndex );
		}
		
		public function playStateOnce( index:int ):void 
		{
			setCurrentState( index );
			var mc:MovieClip = currentState as MovieClip;
			if ( mc ) 
			{
				mc.stop();
				mc.play();
				mc.addEventListener( Event.COMPLETE, onTempMovieComplete );
			} else 
			{
				throw new TypeError( "state " + currentState + " is not of type MovieClip" );
				setCurrentState( mDefaultStateIndex );
			}
		}
		
		private function onTempMovieComplete( e:Event ):void
		{
			dispatchEventWith( Event.COMPLETE );
			setCurrentState( mDefaultStateIndex );
		}
		
		private function clearTempStateShit():void 
		{
			if ( currentState is MovieClip ) 
			{
				MovieClip( currentState ).pause();
				MovieClip( currentState ).removeEventListener( Event.COMPLETE, onTempMovieComplete );
			}
			if ( mDelayedCall != null ) 
			{
				mJuggler.remove( mDelayedCall );
				mDelayedCall = null;
			}
		}
		
		// overrides
		
        /** Don't. */ 
		override public function addChild(child:DisplayObject):DisplayObject 
		{
			throw new Error( "You cannot use addChild() on this class. Please use addState() if you wish to add a new state." );
		}
		
        /** Don't. Seriously, go away! */ 
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject 
		{
			throw new Error( "You cannot use addChildAt() on this class. Please use addState() if you wish to add a new state." );
		}
		
        /** @inheritDoc */ 
        public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
        {
            return currentState.getBounds( targetSpace, resultRect );
        }
		
        /** @inheritDoc */
        public override function render(support:RenderSupport, parentAlpha:Number):void
        {
			support.transformMatrix(currentState);
			return currentState.render( support, parentAlpha * alpha );
        }
		
        /** @inheritDoc */
        public override function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
        {
            return currentState.hitTest(localPoint, forTouch);
        }
		
        /** @inheritDoc */ 
		override public function get hasVisibleArea():Boolean 
		{
			return currentState.hasVisibleArea;
		}
		
        /** @inheritDoc */
		override public function alignPivot(hAlign:String = "center", vAlign:String = "center"):void 
		{
            this.vAlign = vAlign;
			this.hAlign = hAlign;
			currentState.alignPivot(hAlign, vAlign);
		}
		
		//
		
        public function get currentState():DisplayObject { return getChildAt( mCurrentStateIndex ); }
        public function get currentStateIndex():int { return mCurrentStateIndex; }
        public function get defaultStateIndex():int { return mDefaultStateIndex; }
        public function get numStates():int { return numChildren; }
		
        public override function get pivotX(): Number { return currentState.pivotX; }
        public override function set pivotX(value:Number):void { throw Error( "You cannot directly set pivotX to this type of object" ); }
        public override function get pivotY(): Number { return currentState.pivotY; }
        public override function set pivotY(value:Number):void { throw Error( "You cannot directly set pivotY to this type of object" ); }
		
		public function get color():uint 
		{
			return mColor;
		}
		
		public function set color(value:uint):void 
		{
			mColor = value;
			tryToUpdateStateColor();
		}
		
		private function tryToUpdateStateColor():void 
		{
			if ( currentState.hasOwnProperty( "color" ) ) {
				currentState["color"] = mColor;
			}
		}
		
	}
}