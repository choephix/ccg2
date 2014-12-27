package duel.display.cardlots
{
	import duel.cards.CardListBase;
	import duel.GameSprite;
	import starling.animation.IAnimatable;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardsContainer extends GameSprite implements IAnimatable
	{
		protected var list:CardListBase;
		protected var dirty:Boolean;
		
		public function advanceTime( time:Number ):void
		{
			if ( dirty )
			{
				dirty = false;
				arrange();
			}
		}
		
		public function arrange():void{}
		
		public function setTargetList( target:CardListBase ):void
		{
			if ( list )
			{
				list.removeEventListener( Event.CHANGE, onCardsChanged );
				list.removeEventListener( Event.ADDED, onCardAdded );
				list.removeEventListener( Event.REMOVED, onCardRemoved );
			}
			
			list = target;
			dirty = true;
			
			if ( list )
			{
				list.addEventListener( Event.CHANGE, onCardsChanged );
				list.addEventListener( Event.ADDED, onCardAdded );
				list.addEventListener( Event.REMOVED, onCardRemoved );
			}
		}
		
		protected function onCardsChanged( e:Event ):void
		{
			dirty = true;
		}
		
		protected function onCardAdded( e:Event ):void {}
		
		protected function onCardRemoved( e:Event ):void {}
	
	}

}