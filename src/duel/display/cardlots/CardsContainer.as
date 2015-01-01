package duel.display.cardlots
{
	import duel.cards.CardListBase;
	import duel.display.CardSprite;
	import duel.GameSprite;
	import starling.animation.IAnimatable;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardsContainer extends GameSprite implements IAnimatable
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
		{ tweenToPlace( e.data.sprite as CardSprite ) }
		
		/// empty method
		protected function onCardRemoved( e:Event ):void
		{ arrangeAll() }
		
		protected function arrangeAll():void {}
		protected function tweenToPlace( o:CardSprite ):void {}
		
		//
		
		override public function addChild( child:DisplayObject ):DisplayObject 
		{ throw new Error( "NEVER USE addChild() ON STACK" ); }
		
		override public function removeChild( child:DisplayObject, dispose:Boolean=false ):DisplayObject 
		{ throw new Error( "NEVER USE removeChild() ON STACK" ); }
		
		override public function removeChildren( beginIndex:int=0, endIndex:int=-1, dispose:Boolean=false ):void
		{ throw new Error( "NEVER USE removeChildren() ON STACK" ); }
		
		//
		public function get cardsCount():int { return list.cardsCount }
	}
}