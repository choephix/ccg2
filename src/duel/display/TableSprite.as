package duel.display 
{
	import chimichanga.common.display.Sprite;
	import duel.GameSprite;
	
	
	public class TableSprite extends GameSprite 
	{
		public var surface:Sprite;
		public var cardsParent:Sprite;
		public var fieldTipsParent:Sprite;
		public var cardsParentTop:Sprite;
		
		public function TableSprite() 
		{
			surface = new Sprite();
			addChild( surface );
			
			cardsParent = new Sprite();
			addChild( cardsParent );
			
			fieldTipsParent = new Sprite();
			addChild( fieldTipsParent );
			
			cardsParentTop = new Sprite();
			addChild( cardsParentTop );
		}
		
	}

}