package duel.display.fields 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class FieldSpriteGuiState 
	{
		public static const NONE:FieldSpriteGuiState			= new FieldSpriteGuiState();
		public static const SELECTABLE:FieldSpriteGuiState		= new FieldSpriteGuiState();
		
		public static const NORMAL_SUMMON:FieldSpriteGuiState	= new FieldSpriteGuiState();
		public static const TRIBUTE_SUMMON:FieldSpriteGuiState	= new FieldSpriteGuiState();
		public static const SET_TRAP:FieldSpriteGuiState		= new FieldSpriteGuiState();
		public static const REPLACE_TRAP:FieldSpriteGuiState	= new FieldSpriteGuiState();
		public static const SAFE_FLIP:FieldSpriteGuiState		= new FieldSpriteGuiState();
		public static const RELOCATE_TO:FieldSpriteGuiState		= new FieldSpriteGuiState();
		public static const ATTACK_DIRECT:FieldSpriteGuiState	= new FieldSpriteGuiState();
		public static const ATTACK_CREATURE:FieldSpriteGuiState	= new FieldSpriteGuiState();
	}
}