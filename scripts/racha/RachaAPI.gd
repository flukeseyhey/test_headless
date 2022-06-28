extends Control

# about nakama connection
var user
var thread
var roundtoken = "roundtoken"
var api_username = "username"
var api_money = 0.0
var api_uid = "uid"
var api_iden = "identoken"
var api_agent = "agenttoken"
var api_appid = "appid"
var master_server = "url_master"
var report_server = "url_report"
var agent_server = ""
var agent_state = "state"
var agent_message = "message"
var agent_valid_state = "state"
var agent_valid_message = "message"
var ISAGENT = false
var current_scene
const agent_key = "Rachapasswodgood"
const pass_main = "Impassphrasegood"

onready var socket := Nakama.create_socket_from(Online.nakama_client)
onready var http_request := $HTTPRequest
onready var http_request_bet := $HTTPRequestBET
onready var http_request_bet_res := $HTTPRequestBET_RES
onready var http_request_master := $HTTPRequestMaster
onready var http_request_agentvaild := $HTTPRequestMaster_AG
onready var http_request_api := $HTTPRequestAPI
onready var http_request_api_report := $HTTPRequestAPI_REPORT
onready var http_request_match_making := $HTTPRequestMatchMaking
onready var aes := $AES
onready var str_to_json := $str2json
onready var API_Timer := $APITimer

var is_test_demo = true  #ปิดตอน build
#var is_test_demo = false #เปิดตอน build
var is_show_debug = true
#var is_show_debug = false
#var is_test_json = true
var is_test_json = false
var test_data_url

# AMB2 data
var data_urlx = "data=U2FsdGVkX18t4fjFUpzXFO3rj9h86RliUcxZ%2B62kgR3lqYv9XRT7tPDBjODHSn%2FBq1WpNb%2FK5fe2i67G0UPogZaNzHohl%2BLg6J1PR4sD1siYQyk%2FAJ7t0qXqVwXcjBPS67qcuyWmEhfG2aicS42H72wJpEhSW%2FjZtLZjUAwT8ntgFQ8nZTgPu7DqkXgHB4jMDIUsHySFMyuDT9mZow8hBasTB4%2FIaO8dSi7ybcF1DqT0FZs8uh5pzAs82bbPXfvaVcAMZengdYxWSR93hXZO4tWzjm%2BePvmG%2BGNqFuQp5uICmu1ybYH3Ekl4OLNJ9o8ff2a9lNvIaGxlmKS%2Bsjp%2F19K%2FTcqVZoTt9XBgcdmhqnwwnwoAKom9ZOHS8z6mgSZYbaHAPyWX57GmSnvU1RNAZiG1ITIgjOks4vUA2vEKG3w%3D"

# AMB12 data
var data_url2 = "U2FsdGVkX1%2F9f65WU%2FiaUFnzjjlnubyHVhtXfmobKLJlwfD2LwXmOShmepay7CWtnVXj7Cno52Z%2Bi4ZZ708ftQBptD2ZoXXfws22KTIrNDQcA7kX6JTANVT85FEV13E9A3BOp4jkmEweHyzTyLZqmIP9FS6bneFaX2Khjvh4ZveShySfOMUYrO01qs6WZzQZrIUDYjGQraUjOEDwz8m%2BMY4WLnb0YGjVIzs2xJxf3xmVzCWq76Y5dGFnI48Bfo7eu1dl2sHtc0SHSL5NRYBrzvoAO5o29gOtIzCq7F1x061WI2Bc0gC%2FBgi8mEjAHeEteYu5XQZcVDaJ2g%2FGb3AYrw9izTK89pS%2FN3COlQt39xC9z3Kq2OfeF7Dfj%2BFjo1Y3%2FcpEoyunoEupEMxsAvJPOHFZqcqaSnVwhdabYb8aK0ZgoYWA9pfnD65KXhaFOXunHip0ABUKzR%2FeJFxSKrEr5g%3D%3D"

# AMB13 data
var data_url3 = "U2FsdGVkX1%2FNtOAK4rtr%2BqD6l7U9KIU9hEwSqEe10oROtj%2FqhgPteoalfRViqQiuyfGYa7PT8nJzcV4PwX7C9LwxnkC7lsuR1IxOY6x%2B6l%2B%2FYZNFh0PUeXp9dsyAlBUb0t7FkQKuuxKKTseITvbbv%2FZw2%2FKQ5TPidyxGpOn7vBvBgf5M7AZnaPKPxNGj3JUV%2FEggFNpc8dVvLGcJZO2gnCbpcGCyqzLyQsm83LR1wKhw0PyCqbBRxQoLmqJDUjGYWEJYwPZx7WI6%2Bzsm3hfaYbIxBqWPZAvUMygm79Z%2FVSeBrpiDSRAq7yv1neo7qpRs5yxb0jHlpU0KG8EE%2FFME7E7bxuagW5vxrbin3XyHhdE8ac5ejiCc9Xv%2BTwp6vdsF77E8mnUI6qrR%2BEPktcg0IqAGtkmsrQfLohea5jBhIWz3LK0m9huy3toykxf3XVOGIXMjUA5gQwPJhzdXaCDM1A%3D%3D"

# AMB14 data
var data_url4 = "U2FsdGVkX1%2Fqzm9Xcos1NRDZ%2Fl45RWvbkDeJRdqay52bJSze%2BGXF8piruvXHAqoGMzDkQEZeFSk6NyQYfTwJ7rJ0y1Hc77p8x6WzDE9VkdsdrwuDT%2FHQt9qr1Tzgz8MNv%2FqvmWfnkuD%2BIg8mvm1v6IYg8CWk733%2F3D1wDF%2F0lPROMYk0h5NEsFIHW%2BtQ%2F2RyOdqyvyAPeK8LUx2fUEcAcCFS%2FF9lz9f6w7d%2BRPTRufciGYml1nkaeSPJdpo%2FQLfHitZAavs0CTlDx0GgKb2Vm6YuhSUWJYm2sVAGPCMSEX7WA75ibqg3beWbHjSpFs1l4vp%2BAAJQDu0MC47VqEzb5nw63RWTJtN6N2e4OsSRPZ2w9nK6LWyMG8MIROaMjiG755vnPq6yIKWzp7mBdtwV5XUsz8YY%2B8OeuD1UJFBwhHQbCwGSrDs%2B8BuqsCVK7k3DqIQ82XexYrYr2vql7TOygw%3D%3D"

# AMB15 data
var data_url5 = "U2FsdGVkX1%2BwZ1n2j4TF%2FkAsdGDd7TWRjj9KePXzeLrBRlZZjhOJ264qINuXCFnfaMn3964VLoz3diQ%2FgCB3%2Bu%2Brr7ZsYQzr9uV1UG%2BiBt0LrYxwvB6H%2BdBCna8ZqJpJa5nH5rEgTts1gGSe%2BqqsvwmKhhypg0lwEFCQi9r%2BlIFO9o4qWrtOjX58H%2FaZQPZTaTvbv%2BWWPUVpMnT7ApkzRCXx%2B%2BzSWADSdeM87GCLX6Y1Ov8neLUHmg9zAl%2FIODWTzMKKdd6RgykX4RCKIrJAP1pq4aOLpHaz2FKMktLFfM9ERBSakD%2BsVusTW%2BKMRNesbHPIW%2FfPtW6%2BvPRTBpvmGUVn5WNlTIHIBRg8%2BP2wB6X0e4niExDMObpWbaI7rncg1ocRGK4Yf%2Bpk%2FQ8TEwvgVizF5h%2FaJ8P%2FOJG7x63uD%2BjtqWbuhWc5Bd4JSk9TXjzWNtkUXRBDh0Rf8S0fFdzyZw%3D%3D"

# AMB16 data
var data_url6 = "U2FsdGVkX18JasZhRFwNAJxVaZrugJQ1azM6%2FCs48d7O1p3hixoncmwSVfN8YZ4VIIYUzEvbNXVdWwM%2Fn0b81UUX17ZEGTO9G4KAWGDYbnFJraddZ%2BktTsgdhHLeA35tcE7ufm3Bxwh6XINxsanJLpWAKcPMBx6CSD5nIlXK8gLzarEq7%2Bn7ZeeqDEpAk8jypp0IKpSlx9P5WWkQLid6Q8Flcd%2B6Tlq8OMFGsZkDel%2BKn2Mw0aFu%2B2LjUqH6tsf1Gb0PQoEPAdt0RTY3lg3Ppe5L8vp75dGr3kNWl1TUAh9cU3vO2CwMNFwMiXJaV%2BaSO%2FIJx%2Bq3SypUxFPYdOJZnt%2FDE2zJ5vsdQ4P%2B2cB28OhQBBjT6BBFw3XVKoPmuQdzJUTdKBKyXQOL9Qn9m0G%2B%2FIuFkofGupCBj5SHTVMtF5dYGJudwM%2FbEQP2r%2FwXmYGym6hHiGeGs3UVbRgNE2lkdA%3D%3D"

# AMB17 data
var data_url7 = "U2FsdGVkX18NznHVG2I004eemi6EPJ1NpWby1wNvdVlRtEkSd5BwfJ1QT1EL4afJgPc2F4TfyQf9g5TqWjgwXn5FPXAhnIJhSSKx%2BJ%2B8gPiT%2B%2FeZBG2JvLi40AQ2yTNXhqIurRrm14B6Pd5Ev8izEGxTqRrL%2F%2BOYFZh6x3W%2F9TJOR4k7m57njhw07pIMeqQ3jtbjOPmtzsrZfWQbsRDhoUyeE9BgSo%2F1G2jgvqYCxY5cmr5Sx5PLti%2BTcWfkJhazVrPjJ%2BCnGQp1s02TFovLSy%2BhgDU%2Bhac78Dd2plsFXFTTiXalL8x%2F3prcR50nNh6Lt%2BZLqW21J9%2FMEGR88pZIKxIgslHhTeXMD7jSKCLu9REyxV3r7ol0I84fxZoOktqI5Ak5ETZCjaf1wawsQ0USRPAtvZmVs316IxW44x9OFiZvQpFzlmtp5SEm8XVsuPfuxt%2FJMjyYg3D%2F2AJtrXkiEA%3D%3D"

# AMB18 data
var data_url8 = "U2FsdGVkX1%2BN8pP2xBLxMgJJ4IzFf6jEa5H9BDB9mPnLMaFr%2Ba8r4%2BU9Yv5whjh9DY0LNzQ3VcEGYyCASavZGVp3ink4exMe%2B78ifDNd66cQC1jehHEHzQtA%2FHAipWH%2FhLmtDFsZ1JIzQV%2FChXVdpHcpvTkN8D9PtgXLByyOX7J638xaRb7z0cttox2pv3%2BmcjEDZxZlCsyQtqMc6DCPDwmAb4qOL6gwL5E81SgceC6gCi3943IaDRUAaN9w%2BD3GkC1c30VuoOjRFUDFtIJgQ7rniTlbjWR2Uwa5UAmQI3k9LEiiTnk0G2gS2gOpPcH1gkoPRsg1FxS97J4mm3RDXVOe1QuHfTltjrYczM5Jh%2F2OMEdSAYLbQcQfbSwgnibEA94cEOcsmcDZQoaM906EdMh5kpYrqszoMo80hosYiPQ%3D"

# AMB19 data
var data_url9 = "U2FsdGVkX1%2BmEoQc0K%2Bp5IHmeMo%2F51pPZqWIEuXMZ6pQkV1ZK20qBp6IaUufw2KBI7WaR05NOasFUaajIt20dIbX%2BfNtblZtoUsQAvFTXExIGYlgI6y4hE0SdkpkQf2jijARH%2Fn6aXomwmDK02CbDBasn9chy%2FSddMHVEDWNJzK8tSqZ6Kmot%2F5VCqrpdbl8hoRmqu%2Fs%2B2r%2FT4LLHUUFh9Y6lTu28kfg0w7%2BGknNLzkArMmjwZjsG%2F5Wp2nA3RunoC%2FMidz3x2Xc%2Bg9yGATprOJRBz5G5O0epHYkQjCUF3IABGARgldN9K2MXiI8bRYHYvd%2FrnZGmfC51HwtZUdBSWoohvoaEwgudfT0VONyOZbCo9tgR4aqLuqiPgKzWDytW1vPI5el99rWOVibpvi0NVtrjLNAsqOb3bNhotVogEQ%3D"

# AMB20 data
var data_url10 = "U2FsdGVkX19f0y3MrjPavCcidcxw9%2FfdR6ui49YYib7UOeo0I73QW0FQ2wOFVYXPNRgHHqlb8OhxemYGwpxERmznbEqg494zLo1nkgJOYSJ6hdNUhal7hS6FlNiAPKx4WfbQMBaSh5qCW2vIkPzCd3eE8XXav0XM%2FED5iWWEeEhHuoYmXPbF7aFvUC%2FIsVcu0oUYY7Mtb%2BbKqwrSLbzHBeBlovoW%2BChjNzoLReLOFqI%2FtwkpvIS813X4CjeQzQW8t1pmbwJTOZtkrAguXX3CQELl3XtMzrrX16n7RYpa5Gi%2FDuRP7K9EFrxOn1G8PuBS2LjthFUIXQG4iuQefkGhigMhvLZ9PiCPq%2BKVBrCIwTWUTqWIOmJ6iPMT4AFaotkUGkRJI16ieeRfZwSHqMUyumAc5qAl9onelH52EXStPLnpTtSJ4o6%2BGEvMF5EbIf%2FppKXmurQIUXSf9%2BEVIy4uYQ%3D%3D"

# AMB21 data
var data_url11 = "U2FsdGVkX18WYeh%2Fr7BrbQR1JnoX3jGmhrvSqze%2FuGL2sJZH9%2FQ1DdJ71Sa2PYI%2F01h1VWiNrCvFfDAt4Lnd%2Fa7Tk7T0T5ujfTGQJ%2F%2Fl7juFBdqCXJCM6AmVnR6a9cdjDbb1QULhU5g4m7xLGglboyhC%2FxT8Sa6Mw8%2B1yP8O%2FMNzx82Vgd6bBH%2FNWlh4%2F%2F0PuzPzV6%2Bpl6GUOAsmmhwzkIv5nH3esOaPSRkwD5v2PGB6kbNR1HLjkqWEVZ07%2BPlAmOeiCP5sCCrVU2%2BlKHh1%2BeKGQzibEJ9F5qOMMX3LP6QrRIPo%2Fj34xQZGF2g5F8293lo5Cx%2FF1GWXyvrnTlYFRX%2F8k4yOeLFWTOLI7rb0tpkiqP2s786IlO5HuaRgaYdJl%2FpG48upeQeFqEJnYRRu5k7vexop06hUs%2FA8S3CU23WC82GROl2Pr7ec9IxA2ZEJM11%2F9XthDabymEV4gbS2bw%3D%3D"

enum RequestComplete{
	INCOMPLETE = 0,
	COMPLETE = 1,
}
var request_complete_ret: int = RequestComplete.INCOMPLETE setget _set_readonly_variable, get_request_complete_ret
var request_complete_check_agent: int = RequestComplete.INCOMPLETE setget _set_readonly_variable, get_request_complete_check_agent
var request_complete_check_agent_valid: int = RequestComplete.INCOMPLETE setget _set_readonly_variable, get_request_complete_check_agent_valid
var request_complete_bet: int = RequestComplete.INCOMPLETE setget _set_readonly_variable, get_request_complete_bet
var request_complete_bet_res: int = RequestComplete.INCOMPLETE setget _set_readonly_variable, get_request_complete_bet_res
var request_complete_game_data_res: int = RequestComplete.INCOMPLETE setget _set_readonly_variable, get_request_complete_game_data_res

func get_request_complete_ret() -> int:
	return request_complete_ret

func get_request_complete_check_agent() -> int:
	return request_complete_check_agent

func get_request_complete_check_agent_valid() -> int:
	return request_complete_check_agent_valid

func get_request_complete_bet() -> int:
	return request_complete_bet

func get_request_complete_bet_res() -> int:
	return request_complete_bet_res

func get_request_complete_game_data_res() -> int:
	return request_complete_game_data_res

func _set_readonly_variable(_value) -> void:
	pass

signal bet_success ()
signal bet_res_success ()

signal get_game_data(state)
signal agent(state)
signal agent_valid(state)
signal ret_success()
signal logged_in ()
signal connection_message (message)

func _ready():
	test_data_url = data_url11
	thread = Thread.new()
	socket.connect("received_status_presence", self, "_on_status_presence")

func debug_json(game_func, api_func, json_data, cmd):
	print("\nSTART================GameFunc : ", game_func)
	if cmd == "start":
		print("START================PostMain : ", api_func)
	else:
		print("RESULT================PostMain : ", api_func)
	print(json_data)
	print("END================PostMain : ", api_func, "\n")

func check_agent_valid_loopback():
	while true:
		if DbSystem.game_is_playing:
			return
		else:
			_on_CHECKAGENTVALID()
			yield(get_tree().create_timer(1.0), "timeout")
			if agent_valid_state != "success":
				current_scene = get_tree().change_scene("res://src/main/title/MenuScreen.tscn")
		
		yield(get_tree().create_timer(14.0), "timeout")

func call_for_master(string, data):
	#get_node("/root/RachaAPI/HTTPRequestMaster").request(master_server + string, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, data)
	http_request_master.request(master_server + string, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, data)

func call_for_master_agentvalid(string, data):
	http_request_agentvaild.request(master_server + string, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, data)
#	get_node("/root/RachaAPI/HTTPRequestMaster_AG").request(master_server + string, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, data)

func call_for_API(string, data, olddata):
#	http_request_api.connect("request_completed", self, "request_API")
	if ISAGENT == true:
		http_request_api.request(agent_server,["Content-Type: application/json"], true, HTTPClient.METHOD_POST,data)
	else:
		http_request_api.request(master_server + string, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, data)
		
	if(string=="/SHBET" || string=="/SHRESULT")	:
		if report_server.length() > 1:
			http_request_api_report.request(report_server+string,["Content-Type: application/json"], true, HTTPClient.METHOD_POST,olddata)
#	get_node("/root/RachaAPI/HTTPRequestAPI").connect("request_completed", self, "request_API")
#	get_node("/root/RachaAPI/HTTPRequestAPI").request(master_server + string, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, data)

func call_for_REPORT(string, data):
#	get_node("/root/RachaAPI/HTTPRequestAPI_REPORT").connect("request_completed", self, "request_API")
#	get_node("/root/RachaAPI/HTTPRequestAPI_REPORT").request(master_server + string, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, data)
	http_request_api_report.connect("request_completed", self, "request_REPORT")
	http_request_api_report.request(report_server + string, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, data)

func check_agent_API(result, response_code, headers, body: PoolByteArray):
	if response_code == 200:
		var data = body.get_string_from_utf8()
		data = aes.call("Decrypt", data.percent_decode(), pass_main)
		
		if is_test_json:
			debug_json("check_agent_API", "CHKAGENT", data, "res")
			
		data = parse_json(data)
		
		if data["state"] == "success":
			agent_state = data["state"]
			agent_message = data["message"]
			
			GlobalSignals.emit_signal("loading_debug_message", "Debug : check agent success.")
			emit_signal("agent", agent_state)
			
			if request_complete_ret != RequestComplete.COMPLETE:
				_on_RET()
				GlobalSignals.emit_signal("loading_debug_message", "Debug : ret user.")
			
		else:
			agent_state = data["state"]
			agent_message = data["message"]
		
		request_complete_check_agent = RequestComplete.COMPLETE
	else:
		print('response_code: ', response_code)
		print('problem on the server')
		request_complete_check_agent = RequestComplete.INCOMPLETE

func check_agent_valid(result, response_code, headers, body: PoolByteArray):
	if response_code == 200:
		var data = body.get_string_from_utf8()
		data = aes.call("Decrypt", data.percent_decode(), pass_main)
		
		if is_test_json:
			debug_json("check_agent_valid", "CHKAGENTVALID", data, "res")
			
		data = parse_json(data)
		
		if data["state"] == "success":
			agent_valid_state = data["state"]
			agent_valid_message = data["message"]
			
			_on_CHECKAGENT()
			GlobalSignals.emit_signal("loading_debug_message", "Debug : check agent valid success.")
			emit_signal("agent_valid", agent_valid_state)
		else:
			agent_valid_state = data["state"]
			agent_valid_message = data["message"]
			GlobalSignals.emit_signal("loading_debug_message", "Debug : check agent valid failed.")
		
		request_complete_check_agent_valid = RequestComplete.COMPLETE
	else:
		GlobalSignals.emit_signal("loading_debug_message", "Debug : check agent valid : problem on the server. response_code:%s" % response_code)
		print('response_code: ', response_code)
		print('problem on the server')

func _on_CHECKAGENT():
#	get_node("/root/RachaAPI/HTTPRequestMaster").connect("request_completed",self,"checkagentAPI")
	if request_complete_check_agent == RequestComplete.INCOMPLETE:
		http_request_master.connect("request_completed", self, "check_agent_API")
	
	var data = str_to_json.GET_CHKAGENT(api_agent)
	
	if is_test_json:
		debug_json("_on_CHECKAGENT", "CHKAGENT", data, "start")
		
	data = aes.call("Encrypt", data, pass_main)
	data = str_to_json.call("LastStep", data)
	var headers: PoolStringArray = []
	call_for_master("/CHKAGENT", data)
	
func _on_CHECKAGENTVALID():
#	get_node("/root/RachaAPI/HTTPRequestMaster_AG").connect("request_completed",self,"checkagentAPI")
	if request_complete_check_agent_valid == RequestComplete.INCOMPLETE:
		http_request_agentvaild.connect("request_completed", self, "check_agent_valid")
	
	var data = str_to_json.GET_CHKAGENT(api_agent)
	
	if is_test_json:
		debug_json("_on_CHECKAGENTVALID", "CHKAGENTVALID", data, "start")
	
	data = aes.call("Encrypt", data, pass_main)
	data = str_to_json.call("LastStep", data)
	var headers: PoolStringArray = []
	call_for_master_agentvalid("/CHKAGENTVALID", data)

func request_REPORT(_result, response_code, _headers, body: PoolByteArray):
	if response_code == 200:
		var data = body.get_string_from_utf8()
		data = aes.call("Decrypt", data.percent_decode(), agent_key)
		
		if is_test_json:
			debug_json("request_REPORT", "RETUSER", data, "res")
			
		data = parse_json(data)
		
		DbSystem.money = data["credit"]
		api_money = data["credit"]
		
	else:
		print('response_code: ', response_code )
		print('problem on the server')
		
func request_API(_result, response_code, _headers, body: PoolByteArray):
	if response_code == 200:
		var data = body.get_string_from_utf8()
		data = aes.call("Decrypt", data.percent_decode(), agent_key)
		
		if is_test_json:
			debug_json("request_API", "RETUSER", data, "res")
			
		data = parse_json(data)
		
		DbSystem.money = data["credit"]
		api_money = data["credit"]
		thread.start(self, "check_agent_valid_loopback")
		request_complete_ret = RequestComplete.COMPLETE
		emit_signal("ret_success")
		
	else:
		request_complete_ret = RequestComplete.INCOMPLETE
		print('response_code: ', response_code )
		print('problem on the server')

func _on_RET():
	var data = str_to_json.GET_RETUSER("RET",api_agent, api_iden, api_uid, api_username)
	data = aes.call("Encrypt", data, api_appid)
	data = str_to_json.call("LastStep", data)
	
	var _headers: PoolStringArray = []
	
	if request_complete_ret == RequestComplete.INCOMPLETE:
		http_request_api.connect("request_completed", self, "request_API")
		
	call_for_API("/RETUSER", data,"")
	
	if is_test_json:
		debug_json("_on_RET", "RETUSER", data, "start")

func _on_GET_PARAMETER():
	if OS.has_feature('JavaScript'):
		return JavaScript.eval("""
			var url_string = window.location.href;
			var url = new URL(url_string);
			url.searchParams.get("data");
			""")

func _on_GET_URL():
	var data_url = str(_on_GET_PARAMETER()).percent_decode()
	
	# ห้ามเปลี่ยน user ตรงนี้ ให้ไปเปลี่ยนใน func _ready()
	if is_test_demo:
		data_url = test_data_url.percent_decode()
		
	data_url = aes.call("Decrypt", data_url, pass_main)
	data_url = parse_json(data_url)
	
	api_username = data_url["username"]
	api_uid = data_url["uid"]
	api_iden = data_url["identoken"]
	api_agent = data_url["agenttoken"]
	api_appid = data_url["appid"]
	master_server = data_url["url_master"]
	report_server = data_url["url_report"]
	
	DbSystem.username = api_username
	DbSystem.appid = api_appid
	DbSystem.nakama_email = str(api_username + api_uid + api_iden) + "@gmail.com"
	DbSystem.nakama_password = str(api_uid + api_iden)
	
	_on_GET_GAME_DATA("tank_battle")
	GlobalSignals.emit_signal("loading_debug_message", "Debug : get data url.")

# =============================================================== CREATE USER , GO SERVER
func _on_GET_GAME_DATA(_game_name):
	GlobalSignals.emit_signal("loading_debug_message", "Debug : get game data.")
	var data = get_node("/root/RachaAPI/str2json").GET_GAME_DATA(_game_name)
	data = get_node("/root/RachaAPI/AES").call("Encrypt", data, DbSystem.appid)
	data = get_node("/root/RachaAPI/str2json").call("LastStep", data)
#	print(data)
	
#	var http_request = HTTPRequest.new()
#	add_child(http_request)
	if request_complete_game_data_res == RequestComplete.INCOMPLETE:
		http_request_match_making.connect("request_completed", self, "_com_GET_GAME_DATA")

	var error = http_request_match_making.request(DbSystem.go_server_host + "/MTGETGAMEDATA", [], true, HTTPClient.METHOD_POST, data)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	
func _com_GET_GAME_DATA(result, response_code, headers, body):
#	var response = body.get_string_from_utf8()
	if response_code == 200:
		var data = body.get_string_from_utf8()
		data = aes.call("Decrypt", data.percent_decode(), agent_key)
		
		if is_test_json:
			debug_json("_com_GET_GAME_DATA", "MTGETGAMEDATA", data, "res")
		
		data = parse_json(data)
		if RachaAPI.is_show_debug:
			print("get game data state : ", data["state"])
#			print (data)

		DbSystem.go_server_host = data["match_making_domain"]
		DbSystem.rachamaster = data["rachamaster_domain"]
		DbSystem.headless_server = data["headless_domain"]
		DbSystem.nakama_server = data["nakama_domain"]
		DbSystem.nakama_server_key = data["nakama_server_key"]
		
		DbSystem.committion = float(data["online_match_committion"])
		DbSystem.set_enable_online_mode = int(data["online_set_game_mode"])
		DbSystem.battle_royale_count = int(data["online_battle_royale_count"])
		DbSystem.death_match_count = int(data["online_death_match_count"])
		DbSystem.online_player_health = float(data["online_player_health"])
		DbSystem.online_bullet_speed = float(data["online_bullet_speed"])
		DbSystem.TANK_DEFAULT_SPEED = float(data["online_tank_default_speed"])
		DbSystem.TANK_DEFAULT_TURN_SPEED = float(data["online_tank_default_turn_speed"])
		
		DbSystem.player_health = float(data["adventure_player_health"])
		DbSystem.player_speed = float(data["adventure_player_speed"])
		DbSystem.player_default_speed = float(data["adventure_player_default_speed"])
		DbSystem.player_damage = float(data["adventure_player_damage"])
		DbSystem.player_health = float(data["adventure_enemy_health"])
		DbSystem.enemy_speed = float(data["adventure_enemy_speed"])
		DbSystem.player_damage = float(data["adventure_enemy_damage"])
		DbSystem.easy_mode_difficulty_multiple = float(data["adventure_easy_difficulty_multiple"])
		DbSystem.normal_mode_difficulty_multiple = float(data["adventure_normal_difficulty_multiple"])
		DbSystem.hard_mode_difficulty_multiple = float(data["adventure_hard_difficulty_multiple"])
		DbSystem.bullet_speed = float(data["adventure_bullet_speed"])
		DbSystem.tracer_speed = float(data["adventure_tracer_speed"])
		DbSystem.laser_speed = float(data["adventure_laser_speed"])
		DbSystem.easy_match_timer = float(data["adventure_easy_match_timer"])
		DbSystem.normal_match_timer = float(data["adventure_normal_match_timer"])
		DbSystem.hard_match_timer = float(data["adventure_hard_match_timer"])
		DbSystem.boost_price = float(data["adventure_skill_boost_price"])
		DbSystem.zap_price = float(data["adventure_skill_zap_price"])
		DbSystem.invis_price = float(data["adventure_skill_invisible_price"])
		DbSystem.skill_boost_cooldown = float(data["adventure_skill_boost_cooldown"])
		DbSystem.skill_zap_cooldown = float(data["adventure_skill_zap_cooldown"])
		DbSystem.skill_invisible_cooldown = float(data["adventure_skill_invisible_cooldown"])
		DbSystem.enable_skill_boost = true if data["adventure_enable_skill_boost"] == 'true' else false
		DbSystem.enable_skill_zap = true if data["adventure_enable_skill_zap"] == 'true' else false
		DbSystem.enable_skill_invisible = true if data["adventure_enable_skill_invisible"] == 'true' else false
		
		DbSystem.n_coin_drop_min = int(data["coin_min_drop"])
		DbSystem.n_coin_drop_max = int(data["coin_max_drop"])
		DbSystem.money_bronze_coin_value = float(data["coin_bronze_value"])
		DbSystem.money_silver_coin_value = float(data["coin_silver_value"])
		DbSystem.money_gold_coin_value = float(data["coin_gold_value"])
		DbSystem.gold = int(data["coin_bronze_multiple"])
		DbSystem.silver = int(data["coin_silver_multiple"])
		DbSystem.bronze = int(data["coin_gold_multiple"])

		var new_coin_drop_rate = [int(data["coin_bronze_drop_rate"]), int(data["coin_silver_drop_rate"]), int(data["coin_gold_drop_rate"])]
		DbSystem.coin_drop_rate = new_coin_drop_rate

		request_complete_game_data_res = RequestComplete.COMPLETE
			
		_on_CHECKAGENTVALID()
			
		emit_signal("get_game_data", "complete")
		GlobalSignals.emit_signal("loading_debug_message", "Debug : get game data complete.")
			
	else:
		request_complete_game_data_res = RequestComplete.INCOMPLETE
		print('response_code: ', response_code )
		print('problem on the server')

#-------------------------------------------------------- BET VIA GO SERVER
func _on_BET(bet_value):
	roundtoken = aes.call("TOKENGEN")
	var data = str_to_json.GET_BET(1, api_uid, api_username, "multiplayer", "tankbattle", 45, bet_value, roundtoken, api_agent, api_iden)
	
	if is_test_json:
		debug_json("_on_BET", "MTBET", data, "start")
	
	data = aes.call("Encrypt", data, api_appid)
	data = str_to_json.call("LastStep", data)

	if request_complete_bet == RequestComplete.INCOMPLETE :
		http_request_bet.connect("request_completed", self, "_com_BET")
	
	var error = http_request_bet.request(DbSystem.rachamaster + "/MTBET", [], true, HTTPClient.METHOD_POST, data)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		return error

func _com_BET(result, response_code, headers, body):
#	var response = body.get_string_from_utf8()
	var data = body.get_string_from_utf8()
	data = aes.call("Decrypt", data.percent_decode(), agent_key)
	
	if is_test_json:
		debug_json("_com_BET", "MTBET", data, "res")
		
	data = parse_json(data)
	
	if RachaAPI.is_show_debug:
		print("bet state : ", data["state"])
		print("credit after bet : ", data["credit"])
#	print("roundtoken after bet : ", data["roundtoken"])
	api_money = data["credit"]
	DbSystem.money = api_money
	request_complete_bet = RequestComplete.COMPLETE
	emit_signal("bet_success")
	
#-------------------------------------------------------- BET RESULT VIA GO SERVER
func _on_BET_RES(code, add_credit):
	var data = str_to_json.GET_RESULT(code, api_uid, api_username, "multiplayer", "tankbattle", 45, add_credit, roundtoken, api_agent, api_iden, "coin")
	
	if is_test_json:
		debug_json("_on_BET_RES", "MTRESULT", data, "start")
	
	data = aes.call("Encrypt", data, api_appid)
	data = str_to_json.call("LastStep", data)
	
#	var http_request = HTTPRequest.new()
#	add_child(http_request)
	if request_complete_bet_res == RequestComplete.INCOMPLETE :
		http_request_bet_res.connect("request_completed", self, "_com_BET_RES")
		
	var error = http_request_bet_res.request(DbSystem.rachamaster + "/MTRESULT", [], true, HTTPClient.METHOD_POST, data)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	
func _com_BET_RES(result, response_code, headers, body):
#	var response = body.get_string_from_utf8()
	var data = body.get_string_from_utf8()
	data = aes.call("Decrypt", data.percent_decode(), agent_key)
	
	if is_test_json:
		debug_json("_com_BET_RES", "MTRESULT", data, "res")
		
	data = parse_json(data)
	
	if RachaAPI.is_show_debug:
		print("bet res state : ", data["state"])
		print("credit after bet res : ", data["credit"])
		print("roundtoken after bet res : ", data["roundtoken"])
		print("agenttoken after bet res : ", data["agenttoken"])
	api_money = data["credit"]
	DbSystem.money = api_money
	request_complete_bet_res = RequestComplete.COMPLETE
	emit_signal("bet_res_success")


func _on_status_presence(p_presence : NakamaRTAPI.StatusPresenceEvent):
#	push_warning(p_presence.to_string())
	if RachaAPI.is_show_debug:
		print("USER STATUS : ", p_presence.to_string())
#	print(p_presence.to_string())


func _on_connect_nakama_server():
	
	
	var nakama_session : NakamaSession = yield(Online.nakama_client.authenticate_email_async(DbSystem.nakama_email, DbSystem.nakama_password, null, false), "completed")
	if nakama_session.is_exception():
		
		nakama_session = yield(Online.nakama_client.authenticate_email_async(DbSystem.nakama_email, DbSystem.nakama_password, DbSystem.username, true), "completed")
		if nakama_session.is_exception():
			push_error("error at Nakama login: %s" % nakama_session.to_string())
			Online.nakama_session = null
			emit_signal("connection_message", "กำลังปรับปรุงเซิฟเวอร์")
			return
			
	Online.nakama_session = nakama_session
	GlobalSignals.emit_signal("loading_debug_message", "Debug : connecting to nakama server.")

	var account : NakamaAPI.ApiAccount = yield(Online.nakama_client.get_account_async(Online.nakama_session), "completed")
	if account.is_exception():
		push_error("error at akama get account: %s" % account.to_string())
		return
	user = account.user

	
	if user.online:
		emit_signal("connection_message", "พบการเข้าสู่ระบบซ้ำซ้อน")
		return
	
	var connected : NakamaAsyncResult = yield(socket.connect_async(Online.nakama_session), "completed")
	if connected.is_exception():
		push_error("error at Nakama connect: %s" % connected.to_string())
		return
	
	update_status("happy")
	emit_signal("logged_in")


func update_status(status: String) -> void:
	var update : NakamaAsyncResult = yield(socket.update_status_async(JSON.print({"status": "%s"})% status), "completed")
	if update.is_exception():
		push_error("error at Nakama update status: %s" % update.to_string())
		return

	
