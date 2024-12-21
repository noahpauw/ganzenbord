/// @description Controle object

// Enums
enum GAME_PROGRESS {
	INTRO_CUTSCENE,
	PRE_MENU,
	CREATING_PLAYERS,
	GENERATING_ORDER,
	PICKING_DIE_OR_CARDS,
	ROLLING_DIE,
	DICE_IS_ROLLING,
	WITH_TRADER,
	BATTLING_WITH_WOLF,
	BATTLING_WITH_DRAGON,
	ENDING
};

enum CARD_TYPES {
	SECOND_CHANCE,
	ADD_ONE,
	SWORD,
	SHIELD,
	DOUBLE_DICE,
	TAKE_FEATHERS,
	TAKE_CARD,
	PUNISH_OTHER,
	GO_TO_SHOP,
	HALF_OFF,
	DOUBLE_PRICE,
	GIVE_HEART,
	GIVE_TWO_HEARTS,
	GIVE_DARK_HEARTS,
	REVIVE,
	DECK_SIZE,
}

enum INVENTORY_TYPES {
	DICE,
	CARDS
}

enum ATMOSPHERE {
	CALM,
	WOLVES_PRESENT,
	DRAGON_PRESENT,
	GATE_OPEN,
	IN_SHOP,
	HAGGLING,
}

enum TILE_TYPES {
	STANDARD,
	ONE_COIN,
	MINUS_ONE_COIN,
	BEAR_TRAP,
	CARD,
}

enum DICE_TYPES {
	ONE_TWO_THREE,
	QUICK_DICE,
	CARDS,
	LIVES,
	LENGTH
}

enum PS4_BUTTONS {
	CROSS,
	CIRCLE,
	SQUARE,
	TRIANGLE,
	DPAD_VER,
	DPAD_HOR,
	DPAD_FULL,
	L1,
	R1,
	START,
}
