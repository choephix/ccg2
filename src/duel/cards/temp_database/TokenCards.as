package duel.cards.temp_database 
{
	import duel.cards.Card;
	import duel.cards.properties.cardprops;
	import duel.processes.gameprocessgetter;
	
	use namespace cardprops;
	
	public class TokenCards 
	{
		
		static public function setToTokenCreature(c:Card):void 
		{
			TempDatabaseUtils.setToCreature( c );
			c.propsC.basePower = 0;
			c.propsC.isToken = true;
		}
		
	}

}