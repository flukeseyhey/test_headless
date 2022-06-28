extends Node

onready var user_money = $TankHUD/UserInfo/Money
onready var user_money_gain = $TankHUD/UserInfo/MoneyGain/Label

onready var price_skill_boost = $TankHUD/SkillPrice/BoostLabel
onready var price_skill_zap = $TankHUD/SkillPrice/ZapLabel
onready var price_skill_invis = $TankHUD/SkillPrice/InvisibleLabel

onready var skill_boost = $TankHUD/SkillButton/Boost
onready var skill_zap = $TankHUD/SkillButton/Zap
onready var skill_invis = $TankHUD/SkillButton/Invisible

onready var cooldown_skill_boost = $TankHUD/Cooldown/SkillBoost
onready var cooldown_skill_zap = $TankHUD/Cooldown/SkillZap
onready var cooldown_skill_invisible = $TankHUD/Cooldown/SkillInvisible

signal shoot()

signal press_boost_skill()
signal press_zap_skill()
signal press_invis_skill()

func _ready():
	RachaAPI.connect("bet_success", self, "refresh_money")
	
	price_skill_boost.text = "$" + str(float(DbSystem.money_bet * DbSystem.boost_price))
	price_skill_zap.text = "$" + str(float(DbSystem.money_bet * DbSystem.zap_price))
	price_skill_invis.text = "$" + str(float(DbSystem.money_bet * DbSystem.invis_price))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("use_skill_boost") and DbSystem.enable_skill_boost:
		_on_SkillBoost_pressed()
	if event.is_action_pressed("use_skill_zap") and DbSystem.enable_skill_zap:
		_on_SkillZap_pressed()
	if event.is_action_pressed("use_skill_invisible") and DbSystem.enable_skill_invisible:
		_on_SkillInvisible_pressed()
	if event.is_action_pressed("shoot"):
		_on_Shoot_pressed()


func refresh_money() -> void:
	user_money.text = str(RachaAPI.api_money)


func set_skill_cooldown(skill_name_node, skill_cooldown_node, cooldown: float) -> void:
	if not skill_name_node or not skill_cooldown_node:
		return
	
	skill_name_node.visible = false
	skill_cooldown_node.visible = true
	skill_cooldown_node.set_frame(0)
	skill_cooldown_node.play("cooldown")
	yield(get_tree().create_timer(cooldown), "timeout")
#	skill_cooldown_node.emit_signal("animation_finished")
	skill_name_node.visible = true
	skill_cooldown_node.visible = false
	


func _on_SkillBoost_pressed():
	DbSystem.total_online_bet(DbSystem.money_bet * DbSystem.boost_price)
	DbSystem.total_pay = DbSystem.total_pay + (DbSystem.money_bet * DbSystem.boost_price)
	set_skill_cooldown(skill_boost, cooldown_skill_boost, 1.0)
	
	emit_signal("press_boost_skill")


func _on_SkillZap_pressed():
	DbSystem.total_online_bet(DbSystem.money_bet * DbSystem.zap_price)
	DbSystem.total_pay = DbSystem.total_pay + (DbSystem.money_bet * DbSystem.zap_price)
	set_skill_cooldown(skill_zap, cooldown_skill_zap, 2.0)
	
	emit_signal("press_zap_skill")


func _on_SkillInvisible_pressed():
	DbSystem.total_online_bet(DbSystem.money_bet * DbSystem.invis_price)
	DbSystem.total_pay = DbSystem.total_pay + (DbSystem.money_bet * DbSystem.invis_price)
	set_skill_cooldown(skill_invis, cooldown_skill_invisible, 5.0)
	
	emit_signal("press_invis_skill")


func _on_Shoot_pressed():
	emit_signal("shoot")
