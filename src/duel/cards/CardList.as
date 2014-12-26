package duel.cards {
	import duel.cards.Card;
	import flash.display3D.textures.VideoTexture;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	/**
	 * ...
	 * @author choephix
	 */
	public class CardList extends EventDispatcher
	{
		private const list:Vector.<Card> = new Vector.<Card>();
		private var _count:int;
		
		////
		public function at( index:int ):Card
		{
			return list[ index ];
		}
		
		public function contains( card:Card ):Boolean
		{
			return list.indexOf( card ) >= 0;
		}
		
		public function add( card:Card ):void
		{
			if ( card.list != null ) {
				card.list.remove( card );
			}
			card.list = this;
			
			_count++;
			list.push( card );
			onChange();
		}
		
		public function remove( card:Card ):void
		{
			card.list = null;
			
			_count--;
			list.splice( list.indexOf( card ), 1 );
			onChange();
		}
		
		////
		public function get count():int 
		{
			return _count;
		}
		
		////
		public function indexOf(searchElement:duel.cards.Card, fromIndex:int = 0):int 
		{
			return list.indexOf(searchElement, fromIndex);
		}
		
		public function forEach(callback:Function, thisObject:Object = null):void 
		{
			list.forEach(callback, thisObject);
		}
		
		public function every(callback:Function, thisObject:Object = null):Boolean 
		{
			return list.every(callback, thisObject);
		}
		
		public function some(callback:Function, thisObject:Object = null):Boolean 
		{
			return list.some(callback, thisObject);
		}
		
		public function filter(callback:Function, thisObject:Object = null):Vector.<Card> 
		{
			return list.filter(callback, thisObject);
		}
		
		public function sort(compareFunction:Function):Vector.<duel.cards.Card> 
		{
			return list.sort(compareFunction);
			onChange();
		}
		
		////
		private function onChange():void
		{
			//trace("list  changed" );
			dispatchEventWith( Event.CHANGE );
		}
		
		public function toString():String 
		{
			return list.join(",");
		}
		
	}
}