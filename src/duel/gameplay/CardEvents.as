package duel.gameplay
{
	import duel.cards.Card;
	import flash.utils.Dictionary;
	
	[Event( name="leaveLot",type="duel.gameplay.CardEvents" )]
	[Event( name="enterLot",type="duel.gameplay.CardEvents" )]
	
	public class CardEvents
	{
		static public const LEAVE_LOT:String = "leaveLot";
		static public const ENTER_LOT:String = "enterLot";
		
		private var mEventListeners:Dictionary;
		private var mBusy:Boolean;
		
		public var card:Card;
		public var data:Object;
		
		/** Registers an event listener at a certain object. */
		public function addEventListener( type:String, listener:Function ):void
		{
			if ( mEventListeners == null )
				mEventListeners = new Dictionary();
			
			var listeners:Vector.<Function> = mEventListeners[ type ] as Vector.<Function>;
			if ( listeners == null )
				mEventListeners[ type ] = new <Function>[ listener ];
			else if ( listeners.indexOf( listener ) == -1 ) // check for duplicates
				listeners.push( listener );
		}
		
		/** Removes an event listener from the object. */
		public function removeEventListener( type:String, listener:Function ):void
		{
			if ( mEventListeners == null )
				return;
			
			var listeners:Vector.<Function> = mEventListeners[ type ] as Vector.<Function>;
			var numListeners:int = listeners ? listeners.length : 0;
			
			if ( numListeners > 0 )
			{
				// we must not modify the original vector, but work on a copy.
				// (see comment in 'invokeEvent')
				
				var index:int = 0;
				var restListeners:Vector.<Function> = new Vector.<Function>( numListeners - 1 );
				
				for ( var i:int = 0; i < numListeners; ++i )
				{
					var otherListener:Function = listeners[ i ];
					if ( otherListener != listener )
						restListeners[ int( index++ ) ] = otherListener;
				}
				
				mEventListeners[ type ] = restListeners;
			}
		}
		
		/** Removes all event listeners with a certain type, or all of them if type is null.
		 *  Be careful when removing all event listeners: you never know who else was listening. */
		public function removeEventListeners( type:String = null ):void
		{
			if ( type && mEventListeners )
				delete mEventListeners[ type ];
			else
				mEventListeners = null;
		}
		
		/** Dispatches an event with the given parameters to all objects that have registered
		 *  listeners for the given type. The method uses an internal pool of event objects to
		 *  avoid allocations. */
		public function dispatchEventWith( type:String, card:Card, data:Object = null ):void
		{
			if ( mBusy )
			{
				CONFIG::development
				{ throw new Error( "Card Event Distpatcher is already busy!" ) }
				return;
			}
			
			if ( !hasEventListener( type ) )
				return;
			
			var listeners:Vector.<Function> = mEventListeners ? mEventListeners[ type ] as Vector.<Function> : null;
			var numListeners:int = listeners == null ? 0 : listeners.length;
			
			if ( numListeners < 1 )
				return;
			
			this.card = card;
			this.data = data;
			
			// we can enumerate directly over the vector, because:
			// when somebody modifies the list while we're looping, "addEventListener" is not
			// problematic, and "removeEventListener" will create a new Vector, anyway.
			
			mBusy = true;
			for ( var i:int = 0; i < numListeners; ++i )
			{
				var listener:Function = listeners[ i ] as Function;
				
				if ( listener.length == 0 )
					listener();
				else
					listener( this );
			}
			mBusy = false;

			this.card = null;
			this.data = null;
		}
		
		/** Returns if there are listeners registered for a certain event type. */
		public function hasEventListener( type:String ):Boolean
		{
			var listeners:Vector.<Function> = mEventListeners ? mEventListeners[ type ] : null;
			return listeners ? listeners.length != 0 : false;
		}
	
	}

}