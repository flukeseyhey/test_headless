extends "res://src/ui/Screen.gd"

var ScoreCounter = preload("res://src/components/modes/ScoreCounter.gd")
var PlayerStatus = preload("res://src/ui/PlayerStatus.tscn")

onready var status_container := $Panel/StatusContainer

var first_rank = [0, "Null"]
var second_rank = [0, "Null"]
var third_rank = [0, "Null"]
var fourth_rank = [0, "Null"]
var fifth_rank = [0, "Null"]
var sixth_rank = [0, "Null"]
var seventh_rank = [0, "Null"]
var eighth_rank = [0, "Null"]
var ninth_rank = [0, "Null"]
var tenth_rank = [0, "Null"]

var scene

func manage_money(username, first_place_money: float, second_place_money: float, third_place_money: float, player_rank_count: int, first: String = "", second: String = "", third: String = "", fourth: String = "", fifth: String = "", sixth: String = "", seventh: String = "", eighth: String = "", ninth: String = "", tenth: String = "") -> void:
	var username_rank_array = [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth]
	var rank_money = (first_place_money + second_place_money + third_place_money) / player_rank_count
	
	for data in username_rank_array:
		if username == data:
			DbSystem.game_is_end = true
			DbSystem.stop_sent_credit = false
			DbSystem.total_offline_bet("END", rank_money)
			DbSystem.stop_sent_credit = true
			print(DbSystem.username, " ได้เงิน : ", "%.2f" % rank_money, " บาท")
			

func get_round_info(first_score, second_score, third_score):
	
	var round_info := JSON.print({
		"rank": {
			"1st": {
				"score": first_score[0],
				"username": first_score[1]
			},
			"2nd": {
				"score": second_score[0],
				"username": second_score[1]
			},
			"3rd": {
				"score": third_score[0],
				"username": third_score[1]
			}
		},
		"bet": DbSystem.CurrentRoomType
	})
	
	return round_info

func get_same_value(a, b):
	if a[0] == b[0]:
		return true
	return false

func cal_money(player_count, room_type):
	var money_pool = player_count * room_type
	var commission = (money_pool * DbSystem.committion) / 100
	var money_for_player = money_pool - commission
	print("หัก ", DbSystem.committion ," % : ", commission, " บาท")
	print("เหลือเงิน : ", money_for_player, " บาท")
	if money_for_player != 0:
		return money_for_player

func update_and_add_credit(player_count, player_score_array):
	var check_rank
	var money_pool = cal_money(player_count, DbSystem.CurrentRoomType)
	
	if player_count >= 7:
		
		var first_place_money = (money_pool * 50) / 100
		var second_place_money = (money_pool * 30) / 100
		var third_place_money = (money_pool * 20) / 100
		
		print("เงินรางวัลที่ 1 : ", first_place_money)
		print("เงินรางวัลที่ 2 : ", second_place_money)
		print("เงินรางวัลที่ 3 : ", third_place_money)
		
		first_rank = player_score_array[0]
		second_rank = player_score_array[1]
		third_rank = player_score_array[2]
		fourth_rank = player_score_array[3]
		fifth_rank = player_score_array[4]
		sixth_rank = player_score_array[5]
		
		if player_count == 7:
			seventh_rank = player_score_array[6]
		elif player_count == 8:
			seventh_rank = player_score_array[6]
			eighth_rank = player_score_array[7]
		elif player_count == 9:
			seventh_rank = player_score_array[6]
			eighth_rank = player_score_array[7]
			ninth_rank = player_score_array[8]
		else:
			seventh_rank = player_score_array[6]
			eighth_rank = player_score_array[7]
			ninth_rank = player_score_array[8]
			tenth_rank = player_score_array[9]
		
		DbSystem.CurrentResultMatch = get_round_info(first_rank, second_rank, third_rank)

		
		# =========================================================================================== เช็คที่ 1 ร่วม
		check_rank = get_same_value(first_rank, second_rank)
		if check_rank:
			check_rank = get_same_value(first_rank, third_rank)
			if check_rank:
				check_rank = get_same_value(first_rank, fourth_rank)
				if check_rank:
					check_rank = get_same_value(first_rank, fifth_rank)
					if check_rank:
						check_rank = get_same_value(first_rank, sixth_rank)
						if check_rank:
							check_rank = get_same_value(first_rank, seventh_rank)
							if check_rank:
								check_rank = get_same_value(first_rank, eighth_rank)
								if check_rank:
									check_rank = get_same_value(first_rank, ninth_rank)
									if check_rank:
										check_rank = get_same_value(first_rank, tenth_rank)
										if check_rank:
											print ("ที่ 1 ร่วม 10 คน")
											manage_money(DbSystem.username, first_place_money, second_place_money, third_place_money, 10, first_rank[1], second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1], eighth_rank[1], ninth_rank[1], tenth_rank[1])
										else:
											if DbSystem.username == first_rank[1] || DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1] || DbSystem.username == seventh_rank[1] || DbSystem.username == eighth_rank[1] || DbSystem.username == ninth_rank[1]:
												print ("ที่ 1 ร่วม 9 คน")
												manage_money(DbSystem.username, first_place_money, second_place_money, third_place_money, 9, first_rank[1], second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1], eighth_rank[1], ninth_rank[1])
											else:
												print ("ไม่มีเงินสำหรับผู้แพ้")
												manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
									else:
										if DbSystem.username == first_rank[1] || DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1] || DbSystem.username == seventh_rank[1] || DbSystem.username == eighth_rank[1]:
											print ("ที่ 1 ร่วม 8 คน")
											manage_money(DbSystem.username, first_place_money, second_place_money, third_place_money, 8, first_rank[1], second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1], eighth_rank[1])
										else:
											print ("ไม่มีเงินสำหรับผู้แพ้")
											manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
								else:
									if DbSystem.username == first_rank[1] || DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1] || DbSystem.username == seventh_rank[1]:
										print ("ที่ 1 ร่วม 7 คน")
										manage_money(DbSystem.username, first_place_money, second_place_money, third_place_money, 7, first_rank[1], second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1])
									else:
										print ("ไม่มีเงินสำหรับผู้แพ้")
										manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
							else:
								if DbSystem.username == first_rank[1] || DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1]:
									print ("ที่ 1 ร่วม 6 คน")
									manage_money(DbSystem.username, first_place_money, second_place_money, third_place_money, 6, first_rank[1], second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1])
								else:
									print ("ไม่มีเงินสำหรับผู้แพ้")
									manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
						else:
							if DbSystem.username == first_rank[1] || DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1]:
								print ("ที่ 1 ร่วม 5 คน")
								manage_money(DbSystem.username, first_place_money, second_place_money, third_place_money, 5, first_rank[1], second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1])
							else:
								print ("ไม่มีเงินสำหรับผู้แพ้")
								manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
					else:
						if DbSystem.username == first_rank[1] || DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1]:
							print ("ที่ 1 ร่วม 4 คน")
							manage_money(DbSystem.username, first_place_money, second_place_money, third_place_money, 4, first_rank[1], second_rank[1], third_rank[1], fourth_rank[1])
						else:
							print ("ไม่มีเงินสำหรับผู้แพ้")
							manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
				else:
					if DbSystem.username == first_rank[1] || DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1]:
						print ("ที่ 1 ร่วม 3 คน")
						manage_money(DbSystem.username, first_place_money, second_place_money, third_place_money, 3, first_rank[1], second_rank[1], third_rank[1])
					else:
						print ("ไม่มีเงินสำหรับผู้แพ้")
						manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
			else:
				if DbSystem.username == first_rank[1] || DbSystem.username == second_rank[1]:
					print ("ที่ 1 ร่วม 2 คน")
					manage_money(DbSystem.username, first_place_money, second_place_money, 0.0, 2, first_rank[1], second_rank[1])
# =========================================================================================== เช็คที่ 3 ร่วม ที่เหลือจาก ที่ 1 ร่วม
				else:
					check_rank = get_same_value(third_rank, fourth_rank)
					if check_rank:
						check_rank = get_same_value(third_rank, fifth_rank)
						if check_rank:
							check_rank = get_same_value(third_rank, sixth_rank)
							if check_rank:
								check_rank = get_same_value(third_rank, seventh_rank)
								if check_rank:
									check_rank = get_same_value(third_rank, eighth_rank)
									if check_rank:
										check_rank = get_same_value(third_rank, ninth_rank)
										if check_rank:
											check_rank = get_same_value(third_rank, tenth_rank)
											if check_rank:
												print ("ที่ 3 ร่วม 8 คน")
												manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 8, third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1], eighth_rank[1], ninth_rank[1], tenth_rank[1])
											else:
												if DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1] || DbSystem.username == seventh_rank[1] || DbSystem.username == eighth_rank[1] || DbSystem.username == ninth_rank[1]:
													print ("ที่ 3 ร่วม 7 คน")
													manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 7, third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1], eighth_rank[1], ninth_rank[1])
												else:
													print ("ไม่มีเงินสำหรับผู้แพ้")
													manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
										else:
											if DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1] || DbSystem.username == seventh_rank[1] || DbSystem.username == eighth_rank[1]:
												print ("ที่ 3 ร่วม 6 คน")
												manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 6, third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1], eighth_rank[1])
											else:
												print ("ไม่มีเงินสำหรับผู้แพ้")
												manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
									else:
										if DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1] || DbSystem.username == seventh_rank[1]:
											print ("ที่ 3 ร่วม 5 คน")
											manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 5, third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1])
										else:
											print ("ไม่มีเงินสำหรับผู้แพ้")
											manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
								else:
									if DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1]:
										print ("ที่ 3 ร่วม 4 คน")
										manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 4, third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1])
									else:
										print ("ไม่มีเงินสำหรับผู้แพ้")
										manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
							else:
								if DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1]:
									print ("ที่ 3 ร่วม 3 คน")
									manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 3, third_rank[1], fourth_rank[1], fifth_rank[1])
								else:
									print ("ไม่มีเงินสำหรับผู้แพ้")
									manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
						else:
							if DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1]:
								print ("ที่ 3 ร่วม 2 คน")
								manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 2, third_rank[1], fourth_rank[1])
							else:
								print ("ไม่มีเงินสำหรับผู้แพ้")
								manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
					else:
						if DbSystem.username == third_rank[1]:
							print ("ที่ 3")
							manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 1, third_rank[1])
						else:
							print ("ไม่มีเงินสำหรับผู้แพ้")
							manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
		# กรณีที่ ที่1 และ ที่2 แต้มไม่เท่ากัน
		else:
			if DbSystem.username == first_rank[1]:
				print ("ที่ 1")
				manage_money(DbSystem.username, first_place_money, 0.0, 0.0, 1, first_rank[1])
			# กรณีแต้มไม่ใช่ที่ 1
			else:
# =========================================================================================== เช็คที่ 2 ร่วม
				check_rank = get_same_value(second_rank, third_rank)
				if check_rank:
					check_rank = get_same_value(second_rank, fourth_rank)
					if check_rank:
						check_rank = get_same_value(second_rank, fifth_rank)
						if check_rank:
							check_rank = get_same_value(second_rank, sixth_rank)
							if check_rank:
								check_rank = get_same_value(second_rank, seventh_rank)
								if check_rank:
									check_rank = get_same_value(second_rank, eighth_rank)
									if check_rank:
										check_rank = get_same_value(second_rank, ninth_rank)
										if check_rank:
											check_rank = get_same_value(second_rank, tenth_rank)
											if check_rank:
												print ("ที่ 2 ร่วม 9 คน")
												manage_money(DbSystem.username, 0.0, second_place_money, third_place_money, 9, second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1], eighth_rank[1], ninth_rank[1], tenth_rank[1])
											else:
												if DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1] || DbSystem.username == seventh_rank[1] || DbSystem.username == eighth_rank[1] || DbSystem.username == ninth_rank[1]:
													print ("ที่ 2 ร่วม 8 คน")
													manage_money(DbSystem.username, 0.0, second_place_money, third_place_money, 8, second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1], eighth_rank[1], ninth_rank[1])
												else:
													print ("ไม่มีเงินสำหรับผู้แพ้")
													manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
										else:
											if DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1] || DbSystem.username == seventh_rank[1] || DbSystem.username == eighth_rank[1]:
												print ("ที่ 2 ร่วม 7 คน")
												manage_money(DbSystem.username, 0.0, second_place_money, third_place_money, 7, second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1], eighth_rank[1])
											else:
												print ("ไม่มีเงินสำหรับผู้แพ้")
												manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
									else:
										if DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1] || DbSystem.username == seventh_rank[1]:
											print ("ที่ 2 ร่วม 6 คน")
											manage_money(DbSystem.username, 0.0, second_place_money, third_place_money, 6, second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1])
										else:
											print ("ไม่มีเงินสำหรับผู้แพ้")
											manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
								else:
									if DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1]:
										print ("ที่ 2 ร่วม 5 คน")
										manage_money(DbSystem.username, 0.0, second_place_money, third_place_money, 5, second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1])
									else:
										print ("ไม่มีเงินสำหรับผู้แพ้")
										manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
							else:
								if DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1]:
									print ("ที่ 2 ร่วม 4 คน")
									manage_money(DbSystem.username, 0.0, second_place_money, third_place_money, 4, second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1])
								else:
									print ("ไม่มีเงินสำหรับผู้แพ้")
									manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
						else:
							if DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1]:
								print ("ที่ 2 ร่วม 3 คน")
								manage_money(DbSystem.username, 0.0, second_place_money, third_place_money, 3, second_rank[1], third_rank[1], fourth_rank[1])
							else:
								print ("ไม่มีเงินสำหรับผู้แพ้")
								manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
					else:
						if DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1]:
							print ("ที่ 2 ร่วม 2 คน")
							manage_money(DbSystem.username, 0.0, second_place_money, third_place_money, 2, second_rank[1], third_rank[1])
						else:
							print ("ไม่มีเงินสำหรับผู้แพ้")
							manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
				# กรณีที่ ที่1 ที่2 และ ที่3 แต้มไม่เท่ากัน
				else:
					if DbSystem.username == second_rank[1]:
						print ("ที่ 2")
						manage_money(DbSystem.username, 0.0, second_place_money, 0.0, 1, second_rank[1])
					# กรณีแต้มไม่ใช่ที่ 2
					else:
# =========================================================================================== เช็คที่ 3 ร่วม
						check_rank = get_same_value(third_rank, fourth_rank)
						if check_rank:
							check_rank = get_same_value(third_rank, fifth_rank)
							if check_rank:
								check_rank = get_same_value(third_rank, sixth_rank)
								if check_rank:
									check_rank = get_same_value(third_rank, seventh_rank)
									if check_rank:
										check_rank = get_same_value(third_rank, eighth_rank)
										if check_rank:
											check_rank = get_same_value(third_rank, ninth_rank)
											if check_rank:
												check_rank = get_same_value(third_rank, tenth_rank)
												if check_rank:
													print ("ที่ 3 ร่วม 8 คน")
													manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 8, third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1], eighth_rank[1], ninth_rank[1], tenth_rank[1])
												else:
													if DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1] || DbSystem.username == seventh_rank[1] || DbSystem.username == eighth_rank[1] || DbSystem.username == ninth_rank[1]:
														print ("ที่ 3 ร่วม 7 คน")
														manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 7, third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1], eighth_rank[1], ninth_rank[1])
													else:
														print ("ไม่มีเงินสำหรับผู้แพ้")
														manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
											else:
												if DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1] || DbSystem.username == seventh_rank[1] || DbSystem.username == eighth_rank[1]:
													print ("ที่ 3 ร่วม 6 คน")
													manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 6, third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1], eighth_rank[1])
												else:
													print ("ไม่มีเงินสำหรับผู้แพ้")
													manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
										else:
											if DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1] || DbSystem.username == seventh_rank[1]:
												print ("ที่ 3 ร่วม 5 คน")
												manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 8, third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1], seventh_rank[1])
											else:
												print ("ไม่มีเงินสำหรับผู้แพ้")
												manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
									else:
										if DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1] || DbSystem.username == sixth_rank[1]:
											print ("ที่ 3 ร่วม 4 คน")
											manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 4, third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1])
										else:
											print ("ไม่มีเงินสำหรับผู้แพ้")
											manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
								else:
									if DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1]:
										print ("ที่ 3 ร่วม 3 คน")
										manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 3, third_rank[1], fourth_rank[1], fifth_rank[1])
									else:
										print ("ไม่มีเงินสำหรับผู้แพ้")
										manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
							else:
								if DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1]:
									print ("ที่ 3 ร่วม 2 คน")
									manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 2, third_rank[1], fourth_rank[1])
								else:
									print ("ไม่มีเงินสำหรับผู้แพ้")
									manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
						# กรณีที่ ที่1 ที่2 และ ที่3 ที่ 4 แต้มไม่เท่ากัน
						else:
							if DbSystem.username == third_rank[1]:
								print ("ที่ 3")
								manage_money(DbSystem.username, 0.0, 0.0, third_place_money, 1, third_rank[1])
							else:
								print ("ไม่มีเงินสำหรับผู้แพ้")
								manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
			
	elif player_count >= 4 && player_count <= 6:
		
		var first_place_money = (money_pool * 60) / 100
		var second_place_money = (money_pool * 40) / 100
		
		print("เงินรางวัลที่ 1 : ", first_place_money)
		print("เงินรางวัลที่ 2 : ", second_place_money)
		
		first_rank = player_score_array[0]
		second_rank = player_score_array[1]
		third_rank = player_score_array[2]
		
		if player_count == 4:
			fourth_rank = player_score_array[3]
		elif player_count == 5:
			fourth_rank = player_score_array[3]
			fifth_rank = player_score_array[4]
		else:
			fourth_rank = player_score_array[3]
			fifth_rank = player_score_array[4]
			sixth_rank = player_score_array[5]
		
		DbSystem.CurrentResultMatch = get_round_info(first_rank, second_rank, third_rank)

		
		# =========================================================================================== เช็คที่ 1 ร่วม
		check_rank = get_same_value(first_rank, second_rank)
		if check_rank:
			check_rank = get_same_value(first_rank, third_rank)
			if check_rank:
				check_rank = get_same_value(first_rank, fourth_rank)
				if check_rank:
					check_rank = get_same_value(first_rank, fifth_rank)
					if check_rank:
						check_rank = get_same_value(first_rank, sixth_rank)
						if check_rank:
							print ("ที่ 1 ร่วม 6 คน")
							manage_money(DbSystem.username, first_place_money, second_place_money, 0.0, 6, first_rank[1], second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1])
						else:
							if DbSystem.username == first_rank[1] || DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1]:
								print ("ที่ 1 ร่วม 5 คน")
								manage_money(DbSystem.username, first_place_money, second_place_money, 0.0, 5, first_rank[1], second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1])
							else:
								print ("ไม่มีเงินสำหรับผู้แพ้")
								manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
					else:
						if DbSystem.username == first_rank[1] || DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1]:
							print ("ที่ 1 ร่วม 4 คน")
							manage_money(DbSystem.username, first_place_money, second_place_money, 0.0, 4, first_rank[1], second_rank[1], third_rank[1], fourth_rank[1])
						else:
							print ("ไม่มีเงินสำหรับผู้แพ้")
							manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
				else:
					if DbSystem.username == first_rank[1] || DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1]:
						print ("ที่ 1 ร่วม 3 คน")
						manage_money(DbSystem.username, first_place_money, second_place_money, 0.0, 3, first_rank[1], second_rank[1], third_rank[1])
					else:
						print ("ไม่มีเงินสำหรับผู้แพ้")
						manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
			else:
				if DbSystem.username == first_rank[1] || DbSystem.username == second_rank[1]:
					print ("ที่ 1 ร่วม 2 คน")
					manage_money(DbSystem.username, first_place_money, second_place_money, 0.0, 2, first_rank[1], second_rank[1])
				else:
					print ("ไม่มีเงินสำหรับผู้แพ้")
					manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
		# กรณีที่ ที่1 และ ที่2 แต้มไม่เท่ากัน
		else:
			if DbSystem.username == first_rank[1]:
				print ("ที่ 1")
				manage_money(DbSystem.username, first_place_money, 0.0, 0.0, 1, first_rank[1])
			# กรณีแต้มไม่ใช่ที่ 1
			else:
# =========================================================================================== เช็คที่ 2 ร่วม
				check_rank = get_same_value(second_rank, third_rank)
				if check_rank:
					check_rank = get_same_value(second_rank, fourth_rank)
					if check_rank:
						check_rank = get_same_value(second_rank, fifth_rank)
						if check_rank:
							check_rank = get_same_value(second_rank, sixth_rank)
							if check_rank:
								print ("ที่ 2 ร่วม 5 คน")
								manage_money(DbSystem.username, 0.0, second_place_money, 0.0, 5, second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1], sixth_rank[1])
							else:
								if DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1] || DbSystem.username == fifth_rank[1]:
									print ("ที่ 2 ร่วม 4 คน")
									manage_money(DbSystem.username, 0.0, second_place_money, 0.0, 4, second_rank[1], third_rank[1], fourth_rank[1], fifth_rank[1])
								else:
									print ("ไม่มีเงินสำหรับผู้แพ้")
									manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
						else:
							if DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1] || DbSystem.username == fourth_rank[1]:
								print ("ที่ 2 ร่วม 3 คน")
								manage_money(DbSystem.username, 0.0, second_place_money, 0.0, 3, second_rank[1], third_rank[1], fourth_rank[1])
							else:
								print ("ไม่มีเงินสำหรับผู้แพ้")
								manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
					else:
						if DbSystem.username == second_rank[1] || DbSystem.username == third_rank[1]:
							print ("ที่ 2 ร่วม 2 คน")
							manage_money(DbSystem.username, 0.0, second_place_money, 0.0, 2, second_rank[1], third_rank[1])
						else:
							print ("ไม่มีเงินสำหรับผู้แพ้")
							manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
				# กรณีที่ ที่1 ที่2 และ ที่3 แต้มไม่เท่ากัน
				else:
					if DbSystem.username == second_rank[1]:
						print ("ที่ 2")
						manage_money(DbSystem.username, 0.0, second_place_money, 0.0, 1, second_rank[1])
					# กรณีแต้มไม่ใช่ที่ 2
					else:
						print ("ไม่มีเงินสำหรับผู้แพ้")
						manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
		
	else:
		var first_place_money = money_pool
		
		print("เงินรางวัลที่ 1 : ", first_place_money)
		
		first_rank = player_score_array[0]
		second_rank = player_score_array[1]
		
		if player_count == 3:
			third_rank = player_score_array[2]
		
		DbSystem.CurrentResultMatch = get_round_info(first_rank, second_rank, third_rank)

		
		# =========================================================================================== เช็คที่ 1 ร่วม
		check_rank = get_same_value(first_rank, second_rank)
		if check_rank:
			check_rank = get_same_value(first_rank, third_rank)
			if check_rank:
				print ("ที่ 1 ร่วม 3 คน")
				manage_money(DbSystem.username, first_place_money, 0.0, 0.0, 3, first_rank[1], second_rank[1], third_rank[1])
			else:
				if DbSystem.username == first_rank[1] || DbSystem.username == second_rank[1]:
					print ("ที่ 1 ร่วม 2 คน")
					manage_money(DbSystem.username, first_place_money, 0.0, 0.0, 2, first_rank[1], second_rank[1])
				else:
					print ("ไม่มีเงินสำหรับผู้แพ้")
					manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
		# กรณีที่ ที่1 และ ที่2 แต้มไม่เท่ากัน
		else:
			if DbSystem.username == first_rank[1]:
				print ("ที่ 1")
				manage_money(DbSystem.username, first_place_money, 0.0, 0.0, 1, first_rank[1])
			# กรณีแต้มไม่ใช่ที่ 1
			else:
				print ("ไม่มีเงินสำหรับผู้แพ้")
				manage_money(DbSystem.username, 0.0, 0.0, 0.0, 1)
				
	OnlineMatch._on_END("finish")

func _ready():
	Music.play("Lobby")
	clear_players()
	DbSystem.game_is_playing = false
	DbSystem.game_is_end = true

	var score = ScoreCounter.new(DbSystem.host_score.get("score", {}))
	var player_score_array := []

	for id in score.entities:
		var entity = score.entities[id]
		add_player(entity.name, entity.score)
		player_score_array.append_array([[entity.score, entity.name]])

	player_score_array.sort_custom(self, "sort_descending")

	var player_count = player_score_array.size()
	update_and_add_credit(player_count, player_score_array)
	DbSystem.host_score = {}

# เรียงตามน้อยไปมาก
func sort_ascending(a, b):
	if a[0] < b[0]:
		return true
	return false

# เรียงตามมากไปน้อย
func sort_descending(a, b):
	if a[0] > b[0]:
		return true
	return false

func clear_players() -> void:
	for child in status_container.get_children():
		status_container.remove_child(child)
		child.queue_free()

func add_player(username: String, score: int) -> void:
	var status = PlayerStatus.instance()
	status_container.add_child(status)
	status.initialize(username, str(score))

func _on_BackButton_released():
#	DbSystem.to_scene = "res://src/main/title/MenuScreen.tscn"
#	get_tree().change_scene("res://src/main/title/LoadingScreen.tscn")
	Music.stop()
	scene = get_tree().change_scene("res://src/main/title/MenuScreen.tscn")
