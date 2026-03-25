#extends Node
class_name CharacterActions

func pickpocket(doer, victim) -> int:
	if not doer.data_inventory:
		print("The doer has no inventory!")
		return 0
	if not victim.data_inventory:
		print("The victim has no inventory!")
		return 0
	if not doer.global_position.distance_to(victim.global_position) < 2*TilesInterface.TILE_SIZE:
		print("Victim is to far away!")
		return 0

	var rng = RandomNumberGenerator.new()
	var max_stealable_money = roundi(0.75 * victim.data_inventory.money)
	var amount_stolen_money = rng.randi_range(0, max_stealable_money)
	victim.data_inventory.money -= amount_stolen_money
	return amount_stolen_money
