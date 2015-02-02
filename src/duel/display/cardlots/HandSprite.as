package duel.display.cardlots
{
	import duel.cards.Card;
	import duel.display.CardSprite;
	import duel.G;
	import duel.gui.GuiEvents;
	import duel.table.Hand;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class HandSprite extends CardsContainer
	{
		static public const SEL_SPACE:Number = 100;
		
		public var maxWidth:Number = 800;
		public var topSide:Boolean = false;
		
		public var selectedCard:Card = null;
		
		private var _tipSprite:TipBox;
		private var _active:Boolean = false;
		private var hand:Hand;
		
		public function HandSprite( hand:Hand )
		{
			this.hand = hand;
			setTargetList( hand );
			
			_tipSprite = new TipBox();
			
			game.guiEvents.addEventListener( GuiEvents.CARD_CLICK, arrange );
			game.guiEvents.addEventListener( GuiEvents.CARD_FOCUS, onCardFocus );
			game.guiEvents.addEventListener( GuiEvents.CARD_UNFOCUS, onCardUnfocus );
		}
		
		override public function advanceTime( time:Number ):void
		{
			arrange();
			
			var o:CardSprite;
			var i:int = list.cardsCount;
			while ( --i >= 0 )
			{
				o = list.getCardAt( i ).sprite;
				
				o.x = lerp( o.x, o.targetProps.x, .15 );
				o.y = lerp( o.y, o.targetProps.y, .30 );
				o.scaleX = lerp( o.scaleX, o.targetProps.scale, .20 );
				o.scaleY = lerp( o.scaleY, o.targetProps.scale, .20 );
				o.rotation = lerp( o.rotation, o.targetProps.rotation, .25 );
			}
		}
		
		override protected function arrangeAll():void
		{
			arrange();
		}
		
		override protected function tweenToPlace( cs:CardSprite ):void
		{
			arrange();
		}
		
		public function arrange():void
		{
			/** /
			   if ( selectedIndex >= 0 )
			   {
			   const A:Array = [];
			   var j:int = 0;
			   var m1:int = selectedIndex;
			   var m2:int = cardsCount - selectedIndex;
			   var n:Number;
			   for ( j = 0; j < cardsCount; j++ )
			   {
			   n = 1.0 - ( Math.abs( j - selectedIndex ) / ( j < selectedIndex ? m1 : m2 ) );
			   A.push( n );
			   }
			   const A_TOTAL:Number = MathF.sum( A );
			   }
			/**/
			
			/** /
			const POR:Number = .100;
			var YY:Number
			
			if ( _active )
			{
				YY = App.mouseXY.y / App.WINDOW_H;
				YY = Math.max( 0, YY - 1.0 + POR );
				YY = YY * 1 / POR;
				YY = 1 - YY;
				
				YY = App.mouseXY.y / App.WINDOW_H > 1.0 - POR ? 0.0 : 1.0;
			}
			else
				YY = 1.0;
			/**/
			
			const W:Number = maxWidth - G.CARD_W;
			
			var x:Number = G.CARD_W * .5;
			var y:Number = 0.0;
			
			var o:CardSprite;
			var i:int = list.cardsCount;
			var jj:int = 0;
			var sideDir:Number = topSide ? 1.0 : -1.0;
			while ( --i >= 0 )
			{
				o = list.getCardAt( i ).sprite;
				
				/// X
				x = x + theD( W );
				o.targetProps.x = this.x + x;
				
				/// Y
				if ( _active )
					if ( selectedCard == null )
						if ( o.isFocused )
							y = sideDir * G.CARD_H * .5;
						else
						if ( o.isSelectable )
							y = G.CARD_H * -.03;
						else
							y = G.CARD_H * .0;
					else
						if ( o == selectedCard.sprite )
							y = sideDir * G.CARD_H * .88;
						else
							y = sideDir * G.CARD_H * -.4;
				else
					y = sideDir * G.CARD_H * -.4;
					
				o.targetProps.y = this.y + y;
				
				if ( o.isSelected )
				{
					o.targetProps.x = .0;
					o.targetProps.y = -.2 * App.H;
				}
				
				/// Z
				o.targetProps.scale = z;
				
				/// ROTATION
				o.targetProps.rotation = topSide ? Math.PI : .0;
				
				/// Index
				if ( topSide )
					o.parent.setChildIndex( o, 0 );
				else
					o.parent.setChildIndex( o, o.parent.numChildren - 1 );
				
				cardsParent.addChild( o );
				
				jj++;
			}
		}
		
		private function theD( W:Number ):Number
		{
			var d:Number;
			
			/** /
			   if ( selectedIndex == -1 || selectedIndex == cardsCount - 1 )
			   {
			   d = Math.min( W / cardsCount, G.CARD_W );
			   }
			   else
			   {
			   d = Math.min( i == selectedIndex + 1 ? Number.MAX_VALUE : ( W - SEL_SPACE ) / cardsCount, G.CARD_W );
			   }
			   /** /
			   if ( selectedIndex == -1 )
			   {
			   d = Math.min( W / hand.count, G.CARD_W );
			   }
			   else
			   {
			   d = ( W - SEL_SPACE ) * A[i] / A_TOTAL;
			   if ( i == selectedIndex + 1 ) d = SEL_SPACE;
			   }
			   /** /
			   if ( selectedIndex == -1 || selectedIndex == cardsCount - 1 )
			   {
			   d = Math.min( W / cardsCount, G.CARD_W );
			   }
			   else
			   {
			   if ( i <= selectedIndex )
			   d = Math.min( W / cardsCount, G.CARD_W );
			   else
			   if ( i == selectedIndex + 1 )
			   d = G.CARD_W;
			   else
			   d = Math.min( W / cardsCount, G.CARD_W );
			   }
			 /**/
			d = Math.min(( W - G.CARD_W * .5 ) / cardsCount, G.CARD_W );
			/**/
			
			return d;
		}
		
		private function lerp( a:Number, b:Number, r:Number ):Number
		{ return a + r * ( b - a ) }
		
		// EVENT HANDLERS
		
		private function onCardFocus(e:Event):void 
		{
			var c:Card = e.data as Card;
			
			if ( !c.sprite.isSelectable && !c.sprite.isSelected )
				return;
			
			if ( !hand.containsCard( c ) )
				return;
				
			c.sprite.addChild( _tipSprite );
			
			if ( c.sprite.isSelected )
				_tipSprite.text = "Cancel?";
			else
			if ( c.type.isTrap )
				_tipSprite.text = "Set Me?";
			else
			if ( c.type.isCreature )
				if ( c.propsC.flippable )
					_tipSprite.text = "Summon Me Face-Down?";
				else
				if ( c.statusC.needTribute )
					_tipSprite.text = "Tribute-Summon Me?";
				else
					_tipSprite.text = "Summon Me?";
					
			_tipSprite.fadeIn();
		}
		
		private function onCardUnfocus(e:Event):void 
		{
			if ( Card( e.data ).sprite.contains( _tipSprite ) )
				_tipSprite.removeFromParent( false );
		}
		
		override protected function onCardAdded( e:Event ):void
		{
			super.onCardAdded( e );
		}
		
		override protected function onCardRemoved( e:Event ):void
		{
			super.onCardRemoved( e );
			
			var c:Card = e.data as Card;
			jugglerGui.removeTweens( c.sprite );
			
			if ( selectedCard == c )
				selectedCard = null;
			
			arrange();
		}
		
		//private function onCardSelected( e:Event ):void
		//{
			//var c:Card = e.data as Card;
			//if ( c == null )
				//return;
			//if ( hand.containsCard( c ) )
				//show( c );
		//}
		//private function onCardDeselected( e:Event ):void
		//{
			//var c:Card = e.data as Card;
			//if ( c == null )
				//return;
			//if ( hand.containsCard( c ) )
				//unshow( c );
		//}
		
		//
		public function get active():Boolean
		{
			return _active;
		}
		
		public function set active( value:Boolean ):void
		{
			_active = value;
			arrange();
		}
	
	}
	
}

import duel.G;
import duel.GameSprite;
import starling.animation.IAnimatable;
import starling.display.Quad;
import starling.text.TextField;

class TipBox extends GameSprite 
{
	private var q:Quad;
	private var t:TextField;
	
	private var _visible:Boolean;
	
	public function TipBox()
	{
		super();
		
		q = new Quad( G.CARD_W, 32, 0x0 );
		q.alignPivot();
		q.alpha = .0;
		addChild( q );
		
		t = new TextField( G.CARD_W, 32, "?", "Calibri", 24, 0xFFFFFF, true );
		t.alignPivot();
		t.autoScale = true;
		addChild( t );
		
		touchable = false;
	}
	
	public function fadeIn():void
	{
		y = -.5 * G.CARD_H;
		alpha = .0;
		juggler.xtween( this, .150, 
			{ 
				y : -.6 * G.CARD_H,
				alpha : 1.0 
			} );
	}
	
	public function get color():uint
	{
		return q.color;
	}
	
	public function set color( value:uint ):void
	{
		q.color = value;
	}
	
	public function get textColor():uint
	{
		return t.color;
	}
	
	public function set textColor( value:uint ):void
	{
		t.color = value;
	}
	
	public function get text():String
	{
		return t.text;
	}
	
	public function set text( value:String ):void
	{
		t.text = value;
	}
}