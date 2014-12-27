package duel.display.cardlots
{
	import duel.cards.CardListBase;
	import duel.display.CardSprite;
	import duel.GameSprite;
	import starling.animation.IAnimatable;
	import starling.display.DisplayObject;
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
		
		/// empty method
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
		
		/// empty method
		protected function onCardAdded( e:Event ):void {}
		
		/// empty method
		protected function onCardRemoved( e:Event ):void {}
		
		//
		protected function addCardChild( child:CardSprite ):void
		{
			super.addChild( child );
		}
		
		override public function addChild( child:DisplayObject ):DisplayObject 
		{
			throw new Error( "NEVER USE ADDCHILD ON STACK" );
		}
		
		//
		public function get cardsCount():int { return list.cardsCount }
	}
}