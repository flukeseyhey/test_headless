using Godot;
using System;
using Newtonsoft.Json;

public class JSON : Control
{
	public static string GET_CHKAGENT(string xagenttoken)//string xkey,
	{
		var Data = new
		{
			agenttoken = xagenttoken,
			idtype = 15,

		};
		string jsonData = JsonConvert.SerializeObject(Data);
		return jsonData;
	}

	public static string GET_RETUSER(string xcmd, string xagenttoken, string xidentoken, string xuid, string xuuser)//string xkey,
	{
		var Data = new
		{
			cmd = xcmd,
			agenttoken = xagenttoken,
			identoken = xidentoken,
			uid = xuid,
			uuser = xuuser

			//			key = xkey.Substring(0, 12),
			//			logtoken = xlogtoken,
			//			uid = xuid,
			//			uuser = xuser
		};
		string jsonData = JsonConvert.SerializeObject(Data);
		return jsonData;
	}

	public static string GET_CREATEMATCH(string xgamename, string xroomid, int xroomtype, int xrmin, int xrmax)
	{
		var Data = new
		{
			cmd = "create",
			gamename = xgamename,
			roomid = xroomid,
			roomtype = xroomtype,
			min = xrmin,
			max = xrmax
		};
		string jsonData = JsonConvert.SerializeObject(Data);
		return jsonData;
	}

	public static string GET_CREATEUSER(string xuuser, string xuid, string xidentoken)
	{
		var Data = new
		{
			uuser = xuuser,
			uid = xuid,
			identoken = xidentoken,
		};
		string jsonData = JsonConvert.SerializeObject(Data);
		return jsonData;
	}

	public static string GET_FINDMATCH(string xgamename, int xroomtype)
	{
		var Data = new
		{
			cmd = "find",
			gamename = xgamename,
			roomtype = xroomtype
		};
		string jsonData = JsonConvert.SerializeObject(Data);
		return jsonData;
	}

	public static string GET_TKSTART(string xroomid)
	{
		var Data = new
		{
			roomid = xroomid
		};
		string jsonData = JsonConvert.SerializeObject(Data);
		return jsonData;
	}

	public static string GET_TKEND(string xcmd, string xroomid, string xresult, string xplayer_session)
	{
		var Data = new
		{
			cmd = xcmd,
			roomid = xroomid,
			result = xresult,
			player_session = xplayer_session
		};
		string jsonData = JsonConvert.SerializeObject(Data);
		return jsonData;
	}

	public static string GET_GETSESSION(string xroomid)
	{
		var Data = new
		{
			roomid = xroomid,
		};
		string jsonData = JsonConvert.SerializeObject(Data);
		return jsonData;
	}

	public static string GET_BET(int xtype, string xuid, string xuname, string xgametype, string xgamename, int xidgame, float xbet, string xroundtoken, string xagenttoken, string xidentoken)
	{
		var Data = new
		{
			cmd = "BET",
			code = "BET",
			type = xtype,
			uid = xuid,
			uuser = xuname,
			gametype = xgametype,
			gamename = xgamename,
			idgame = xidgame,
			bet = xbet,
			roundtoken = xroundtoken,
			agenttoken = xagenttoken,
			identoken = xidentoken

		};
		string jsonData = JsonConvert.SerializeObject(Data);
		return jsonData;
	}

	public static string GET_RESULT(string xcode, string xuid, string xuname, string xgametype, string xgamename, string xidgame, float xcoin, string xroundtoken, string xagenttoken, string xidentoken, float xcoinreserve)
	{
		var Data = new
		{
			cmd = "RESULT",
			code = xcode,
			uid = xuid,
			uuser = xuname,
			gametype = xgametype,
			gamename = xgamename,
			idgame = int.Parse(xidgame),
			coin = xcoin,
			roundtoken = xroundtoken,
			agenttoken = xagenttoken,
			identoken = xidentoken,
			coinreserve = xcoinreserve
		};

		string jsonData = JsonConvert.SerializeObject(Data);
		return jsonData;

	}

	public static string GET_GAME_DATA(string xgamename)
	{
		var Data = new
		{
			cmd = "FIND",
			gamename = xgamename

		};

		string jsonData = JsonConvert.SerializeObject(Data);
		return jsonData;

	}

	public static string TO_JSON(string newtext)
	{
		var Data = new
		{
			newtext
		};

		string jsonData = JsonConvert.SerializeObject(Data);
		return jsonData;
	}


	public static string LastStep(string datatxt)
	{
		var myData2 = new
		{
			datax = datatxt
		};

		string jsonData2 = JsonConvert.SerializeObject(myData2);
		return jsonData2;
	}

}
