package duel.display.cardlots
{
	import duel.cards.CardListBase;
	import duel.display.CardSprite;
	import duel.GameEntity;
	import starling.animation.IAnimatable;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardsContainer extends GameEntity implements IAnimatable
	{
		public var cardsParent:DisplayObjectContainer;
		
		protected var list:CardListBase;
		
		public function advanceTime( time:Number ):void {}
		
		public function setTargetList( target:CardListBase ):void
		{
			if ( list )
			{
				list.removeEventListener( Event.CHANGE, onCardsReordered );
				list.removeEventListener( Event.ADDED, onCardAdded );
				list.removeEventListener( Event.REMOVED, onCardRemoved );
			}
			
			list = target;
			
			if ( list )
			{
				list.addEventListener( Event.CHANGE, onCardsReordered );
				list.addEventListener( Event.ADDED, onCardAdded );
				list.addEventListener( Event.REMOVED, onCardRemoved );
			}
			
			arrangeAll();
		}
		
		protected function onCardsReordered( e:Event ):void
		{ arrangeAll() }
		
		/// empty method
		protected function onCardAdded( e:Event ):void
		{ 
			var cs:CardSprite = e.data.sprite;
			cs.selectable = false;
			tweenToPlace( cs );
		}
		
		/// empty method
		protected function onCardRemoved( e:Event ):void
		{ 
			CardSprite( e.data.sprite ).selectable = false;
			arrangeAll();
		}
		
		protected function arrangeAll():void {}
		protected function tweenToPlace( o:CardSprite ):void {}
		
		//
		
		public var x:Number;
		public var y:Number;
		
		//
		public function get cardsCount():int { return list.cardsCount }
	}
}