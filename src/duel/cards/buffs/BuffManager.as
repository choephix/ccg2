package duel.cards.buffs 
{
	import duel.cards.Card;
	/**
	 * ...
	 * @author choephix
	 */
	public class BuffManager 
	{
		public var buffsHead:Buff;
		public var buffsTail:Buff;
		
		public var card:Card;
		
		public function getSUM( buffName:String ):Number
		{
			var r:Number = .0;
			for ( var o:Buff = buffsHead; o != null; o = o.next ) 
				if ( o.name == buffName )
					r += Number( o.value is Function ? o.value( card ) : o.value );
			return r;
		}
		
		public function getAND( buffName:String ):Boolean
		{
			var r:Boolean = true;
			for ( var o:Buff = buffsHead; o != null; o = o.next ) 
				if ( o.name == buffName )
					r &&= Boolean( o.value is Function ? o.value( card ) : o.value );
			return r;
		}
		
		public function getOR( buffName:String ):Boolean
		{
			var r:Boolean = false;
			for ( var o:Buff = buffsHead; o != null; o = o.next ) 
				if ( o.name == buffName )
					r ||= Boolean( o.value is Function ? o.value( card ) : o.value );
			return r;
		}
		
		public function purgeNonSticky():void
		{
			for ( var o:Buff = buffsHead; o != null; o = o.next )
				if ( !o.sticky ) 
					removeBuff( o );
		}
		
		//{ OBJECTS MANAGEMENT
		
		public function addBuff( o:Buff ):void 
		{
			if ( buffsHead == null )
				buffsHead = o;
			else
				buffsTail.next = o;
			o.prev = buffsTail;
			buffsTail = o;
			//o.onAdded();
		}
		
		public function removeBuff( o:Buff ):void
		{
			if ( buffsHead == o )
				buffsHead = o.next;
			if ( buffsTail == o )
				buffsTail = o.prev;
			if ( o.prev )
				o.prev.next = o.next;
			if ( o.next )
				o.next.prev = o.prev;
			//o.onRemoved();
		}
		
		//}
		
	}

}