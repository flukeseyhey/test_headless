extends Node


signal bullet_fired(bullet, team, position, direction)
signal bullet_impacted(position, direction)

signal shoot()
signal shooted()
signal unit_death()
#signal set_health_unit()

signal update_gain_money()
signal adventure_end()
#signal info_click()

signal set_team(boolean)

# ============================= Online
signal player_cam_zoom_in()
signal player_cam_zoom_out()


signal loading_debug_message(message)

