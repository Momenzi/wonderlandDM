#if defined wl_script
													OLD BUILD !
<pawn>
\**--------------------------------------------------------------------------**/
							        Wonderland
								    Deathmatch
									----------
									09.10.2019
									----------
	~               Scripting by Momenzi a.k.a Amel Gerovic		  		 ~
	~                                                      		  		 ~
	~                               072 build                    		 ~
\**--------------------------------------------------------------------------**/
						     --                      --
							 alpha version gamemode 0.1
						     --                      --
\**--------------------------------------------------------------------------**/
~ Duel system    														[ 100 %]
~ UCP system        													[ 100 %]
~ Deathmatch arene  													[ 100 %]
~ Admin system      													[ 77  %]
~ Player system     													[ 100 %]
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
~ Aim sync          													[ 100 %] with Pawn.Raknet
~ Anticheat         													[ 100 %] with nex-ac
~ Textdraw          													[ 100 %]
~ Ghost Town barijera													[ 100 %] hvala .mumitza
~ Sredjen MySQL                                                         [ 100 %] hvala .mumitza
~ Spawn map                                                             [ 100 %] forum sa-mp
\**--------------------------------------------------------------------------**/
</pawn>
#endif
// --- > default include
#include 							< a_samp >

#undef MAX_PLAYERS
const MAX_PLAYERS =                 (50);

// ---> other includes
#include 							< crashdetect >
#include 							< nex-ac >
#include 							< a_mysql >
#include 							< foreach >
#include 							< sscanf2 >
#include                            < DataConvert >
#include                            < streamer >
#include 							< timerfix >
#include 							< Pawn.CMD >
#include 							< Pawn.RakNet >
#include 							< weapon-config >

// --- > server setup
#define GAMEMODE_UPDATE 			"09/10/2018"
#define WL_VER 						"0.1"
#define WL_LINK 					"weburl www.google.com"
#define WL_NAME         			"hostname Wonderland Community [ Deathmatch ]"
#define WL_LANGUAGE 				"language Balkan"
#define MAP_NAME 					"mapname Los Angeles"
#define NAME_DD 					10.0
#define WL_ACHIEVEMENTS				"server_achievements"

// --- > GivePlayerScore
#define GivePlayerScore(%0,%1)                  SetPlayerScore(%0,GetPlayerScore(%0)+%1)

enum AchievementInfo
{
	Username[24],
	Ach1,
	Ach2,
	Ach3,
	Ach4,
	AchsCompleted
};
new AInfo[MAX_PLAYERS][AchievementInfo], gQuery[520];

// --- > defines
#define ObrisiChat(%0,%1)    	 	for(new n=0; n<%1; n++)SendClientMessage(%0,-1," ")

// --- > raknet
const ID_PLAYER_SYNC =				116;
const AIM_SYNC = 					203;
const BULLET_SYNC = 				206;
const PLAYER_SYNC = 				207;

enum
{
	RNM_INT8,
	RNM_INT16,
	RNM_INT32,
	RNM_UINT8,
	RNM_UINT16,
	RNM_UINT32,
	RNM_FLOAT,
	RNM_BOOL,
	RNM_STRING,
	RNM_CINT8,
	RNM_CINT16,
	RNM_CINT32,
	RNM_CUINT8,
	RNM_CUINT16,
	RNM_CUINT32,
	RNM_CFLOAT,
	RNM_CBOOL,
}

enum PacketPriority
{
	SYSTEM_PRIORITY,
	HIGH_PRIORITY,
	MEDIUM_PRIORITY,
	LOW_PRIORITY,
	NUMBER_OF_PRIORITIES
}

enum PacketReliability
{
	UNRELIABLE = 6,
	UNRELIABLE_SEQUENCED,
	RELIABLE,
	RELIABLE_ORDERED,
	RELIABLE_SEQUENCED
}

forward OnPlayerReceivedPacket(player_id, packet_id, BitStream:bs);
forward OnPlayerReceivedRPC(player_id, rpc_id, BitStream:bs);
forward OnServerSendPacket(player_id, packet_id, BitStream:bs);
forward OnServerSendRPC(player_id, rpc_id, BitStream:bs);
// --- > afk
#define MAX_AFK_TIME                    30
#define LABEL_DRAW_DISTANCE     		50.0
new Text3D:AFKLabel[MAX_PLAYERS];
new playerupdate[MAX_PLAYERS];

// --- > textdraw
new PlayerText:wldm_PTD[MAX_PLAYERS][37];

// --- > host setup
const MYSQL_STATE = 				(0);

#if MYSQL_STATE == 0

	static const MYSQL_HOST[10] =	"localhost";
	static const MYSQL_USER[5] =	"root";
	static const MYSQL_PASS[1] =	"";
	static const MYSQL_DB[10] =		"wl_dmtest";

#else

	static const MYSQL_HOST[1] =	"";
	static const MYSQL_USER[1] =	"";
	static const MYSQL_DB[1] =		"";
	static const MYSQL_PASS[1] =	"";

#endif

// ---> reconnect
new ReconnectIP[MAX_PLAYERS][32];
new bool: Reconnecting[MAX_PLAYERS];
#define MAX_IP_SIZE 32

new handler;

// --- > register & login
enum
{
	DIALOG_REGISTER = 1,
	DIALOG_LOGIN,
	DIALOG_DM,
	DIALOG_UCP,
	DIALOG_UCP_SKIN,
	DIALOG_BANNED,
	DIALOG_AKOMANDE,
	DIALOG_CCOLOR_TD,
	DIALOG_AFKLIST,
	DIALOG_ACH
};

// --- > dm zone

new dm_ghosttown,
	dm_interior,
	dm_policedep,
	dm_warehouse,
	dm_fysnow,
	dm_check[MAX_PLAYERS];
	
// --- > actor

new actor[4];

// --- > timer

new ServerTimer[1];

// --- > dm zone

new Float:RandomPosDM_1[10][3] =
{
    { -382.7271, 2274.1548, 41.5471 }, { -394.9037, 2257.2969, 42.2798 },
    { -396.4926, 2230.7151, 43.1595 }, { -414.2215, 2221.9216, 42.4297 },
    { -436.2568, 2243.3733, 42.4297 }, { -457.3188, 2231.3545, 44.5985 },
    { -396.8878, 2192.7390, 42.4176 }, { -361.7321, 2202.5627, 42.4844 },
    { -325.0925, 2215.3992, 44.0645 }, { -355.6452, 2220.9185, 49.2862 }
};
new Float:RandomPosDM_2[10][3] =
{
    { -1017.5864, 1023.8005, 1344.0002 }, { -1081.1769, 1031.9286, 1342.5839 },
    { -1055.7483, 1085.7426, 1342.8928 }, { -1113.5754, 1097.6229, 1341.8541 },
    { -1009.9137, 1097.1517, 1341.8168 }, { -987.2532, 1019.9183, 1342.0123 },
    { -1028.2401, 1053.4443,1342.9016 }, { -1079.2889, 1048.1654, 1343.7308 },
	{ -1065.0492, 1077.8513, 1341.3787 }, { -1133.4927, 1022.2709, 1345.7579 }
};
new Float:RandomPosDM_3[10][3] =
{
    { 288.5902, 169.6105, 1007.1719 }, { 300.3592, 191.0937, 1007.1719 },
    { 267.8962, 185.5105, 1008.1719 }, { 245.7332, 185.2352, 1008.1719 },
    { 236.9773, 196.1277, 1008.1719 }, { 252.6445, 171.0971, 1003.0234 },
    { 241.5962, 140.0076, 1003.0234 }, { 209.4879, 141.9602, 1003.0234 },
    { 206.9386, 168.7783, 1003.0234 }, { 229.7856, 181.9823, 1003.0313 }
};
new Float:RandomPosDM_4[8][3] =
{
	{ 1090.9049,2116.3442,15.3504 }, { 1090.5963,2090.7861,15.3504 },
    { 1090.1383,2082.2014,10.8203 }, { 1090.7106,2115.6223,10.8203 },
    { 1068.8969,2138.4287,10.8203 }, { 1058.6650,2114.4983,10.8203 },
    { 1059.6334,2099.3545,10.8203 }, { 1066.9928,2087.2590,10.8203 }
};
new Float:RandomPosDM_5[6][3] =
{
	{ 1333.9225,2530.6890,453.5955 }, { 1333.9891,2542.3845,453.5955 },
    { 1297.4382,2541.3503,453.5955 }, { 1298.0652,2529.4790,453.5955 },
    { 1315.7715,2540.7585,453.5955 }, { 1315.8239,2530.2966,453.5955 }
};
// --- > forwards
forward CheckPlayerAccount(playerid);
forward OnPlayerRegister(playerid);
forward OnPlayerRegistered(playerid);
forward OnAccountLoad(playerid);
forward KickEx(playerid);

// --- > main
main()
{
	printf("\n\n=============================\n  -------------------------\n >  Wonderland DeathMatch  <\n >       Version %s       <\n  -------------------------\n=============================\n\n", WL_VER);
}

// --- > players
enum ENUM_PLAYER_DATA
{
    ID,
    Password[65],
    bool:Registered,

    Kills,
    Deaths,

    Score,
    Cash,

	Skin,
	Admin,
	Banovan,

    PasswordFails,
    bool:IsLogged,
    
    readpm,
    Last,
    PM,
    NoPM
}
new pInfo[MAX_PLAYERS][ENUM_PLAYER_DATA];

// --- > inlobby
enum ENUM_LOBBY
{
	InLobby,
	InSpec,
	ShowedTextdraw,
	Report,
	ShotDebug,
	AllowCheck
}
new Server[MAX_PLAYERS][ENUM_LOBBY];

// --- > duel sys
enum wl_duelsys
{
	playername[25],
 	induel,
  	weapname[45],
   	weapid
}
new wl_duelinfo[MAX_PLAYERS][wl_duelsys];

enum sWeaponInfo
{
    Name[60],
    Valid,
    Slot
}

new WeaponInfo[][sWeaponInfo] =
{
    {"Fist",1,0},
    {"Brass Knuckles",1,0},
    {"Golf Club",1,1},
    {"Nightstick",1,1},
    {"Knife",1,1},
    {"Baseball Bat",1,1},
    {"Shovel",1,1},
    {"Pool cue",1,1},
    {"Katana",1,1},
    {"Chainsaw",1,1},
    {"Double-ended Dildo",1,10},
    {"Dildo",1,10},
    {"Vibrator",1,10},
    {"Silver Vibrator",1,10},
    {"Flowers",1,10},
    {"Cane",1,10},
    {"Grenade",1,8},
    {"Tear Gas",1,8},
    {"Molotov Cocktail",1,8},
    {"",0},
    {"",0},
    {"",0},
    {"9mm Pistol",1,2},
    {"Silenced 9mm",1,2},
    {"Deagle",1,2},
    {"Shotgun",1,3},
    {"Sawnoff Shotgun",1,3},
    {"Combat Shotgun",1,3},
    {"Micro SMG",1,4},
    {"MP5",1,4},
    {"AK-47",1,5},
    {"M4",1,5},
    {"Tec-9",1,4},
    {"Country Rifle",1,6},
    {"Sniper Rifle",1,6},
    {"RPG",1,7},
    {"HS Rocket",1,7},
    {"Flamethrower",1,7},
    {"Minigun",1,7},
    {"Sachel Charge",1,8},
    {"Detonator",1,12},
    {"Spray Can",1,9},
    {"Fire Extinguisher",1,9},
    {"Camera",1,9},
    {"Night Vision Goggles",0,11},
    {"Thermal Goggles",0,11},
    {"Parachute",1,11}
};

new invite[MAX_PLAYERS],
    inviter[MAX_PLAYERS],
    DuelSender[MAX_PLAYERS],
    DuelReciever[MAX_PLAYERS];

// --- > stocks
stock SetPlayerMoney(playerid, cash)
{
	ResetPlayerMoney(playerid);
	return GivePlayerMoney(playerid, cash);
}

stock CheckPausing(playerid)
{
   if(GetTickCount() > ( GetPVarInt(playerid,"LastUpdate") + 3000 ) && GetPlayerState(playerid) != PLAYER_STATE_PASSENGER)
   {
      return 1;
   }
   return 0;
}

stock wl_sql_connect()
{
	handler = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PASS, 3306, true, 4);
	if(mysql_errno(handler) != 0)
	{
		return printf("mysql.connect: Neuspjesna konekcija sa databazom %s.",MYSQL_DB);
	}
	else
	{
        return printf("mysql.connect: Konekcija uspjesna sa databazom '%s'.Databaza ucitana za (%d ms)", MYSQL_DB, GetTickCount());
	}
}

SendClientMessageF(playerid, color, const text[], {Float,_}:...)
{
	static args,str[192];
	if((args = numargs()) <= 3)
	{
		SendClientMessage(playerid, color, text);
	}
	else
	{
		while(--args >= 3)
		{
			#emit LCTRL 	5
			#emit LOAD.alt 	args
			#emit SHL.C.alt 2
			#emit ADD.C 	12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S 		text
		#emit PUSH.C 		192
		#emit PUSH.C 		str
		#emit LOAD.S.pri 	8
		#emit ADD.C 		4
		#emit PUSH.pri
		#emit SYSREQ.C 		format
		#emit LCTRL 		5
		#emit SCTRL 		4

		SendClientMessage(playerid, color, str);

		#emit RETN
	}
	return 1;
}

SendAdminMessageF(slvl, color, text[])
{
	foreach(new i : Player)
	{
	    if(pInfo[i][Admin] >= slvl) SendClientMessage(i, color, text);
	}
	return 1;
}

SendClientMessageToAllF(color, const text[], {Float,_}:...)
{
	static args,str[192];
	if((args = numargs()) <= 2)
	{
		SendClientMessageToAll(color, text);
	}
	else
	{
		while(--args >= 2)
		{
			#emit LCTRL 	5
			#emit LOAD.alt 	args
			#emit SHL.C.alt 2
			#emit ADD.C 	12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S 		text
		#emit PUSH.C 		192
		#emit PUSH.C 		str
		#emit LOAD.S.pri 	8
		#emit ADD.C 		4
		#emit PUSH.pri
		#emit SYSREQ.C 		format
		#emit LCTRL 		5
		#emit SCTRL 		4

		SendClientMessageToAll(color, str);

		#emit RETN
	}
	return 1;
}

forward [MAX_PLAYER_NAME + 1]GetPlayerNameF(playerid);
stock GetPlayerNameF(playerid)
{
    #assert MAX_PLAYER_NAME + 1 == 25
    #emit PUSH.C 25
    #emit PUSH.S 16
    #emit PUSH.S playerid
    #emit PUSH.C 12
    #emit SYSREQ.C GetPlayerName
    #emit STACK 16
    #emit RETN
}
CreateServerMaps()
{

	//Spawn_interior
	new tmpobjid;
	tmpobjid = CreateObject(19377,2776.470,-80.839,1317.753,0.000,90.000,89.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 14771, "int_brothelint3", "GB_nastybar12", 0);
	tmpobjid = CreateObject(19377,2776.471,-70.341,1317.753,0.000,90.000,89.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 14771, "int_brothelint3", "GB_nastybar12", 0);
	tmpobjid = CreateObject(19446,2781.199,-74.134,1319.588,0.000,0.000,179.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(1557,2779.658,-65.199,1317.854,0.000,0.000,180.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_wood_doors2", 0);
	SetObjectMaterial(tmpobjid, 1, 14534, "ab_wooziea", "CJ_WOODDOOR5", 0);
	tmpobjid = CreateObject(19446,2776.616,-86.023,1319.588,0.000,0.000,269.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19446,2776.444,-65.112,1319.588,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(1557,2776.635,-65.198,1317.854,0.000,0.000,359.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_wood_doors2", 0);
	tmpobjid = CreateObject(19446,2775.069,-65.198,1319.588,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2780.625,-65.680,1319.588,0.000,0.000,45.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2775.658,-65.680,1319.588,0.000,0.000,315.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19384,2775.069,-71.616,1319.588,0.000,0.000,179.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19377,2766.840,-70.341,1317.753,0.000,90.000,89.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 14771, "int_brothelint3", "GB_nastybar12", 0);
	tmpobjid = CreateObject(19446,2769.211,-74.260,1319.588,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19377,2766.840,-80.839,1317.753,0.000,90.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14771, "int_brothelint3", "GB_nastybar12", 0);
	tmpobjid = CreateObject(19427,2774.530,-73.721,1319.588,0.000,0.000,315.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2774.510,-65.686,1319.588,0.000,0.000,45.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19384,2781.199,-67.718,1319.588,0.000,0.000,179.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19377,2786.099,-70.341,1317.753,0.000,90.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14771, "int_brothelint3", "GB_nastybar12", 0);
	tmpobjid = CreateObject(19446,2790.330,-75.554,1319.588,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19400,2783.908,-75.554,1319.588,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2781.770,-75.022,1319.588,0.000,0.000,45.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19446,2790.907,-70.708,1319.588,0.000,0.000,359.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19446,2790.751,-69.815,1319.588,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2782.054,-69.815,1319.588,0.000,0.000,269.991,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19446,2786.085,-65.129,1319.588,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2781.770,-65.680,1319.588,0.000,0.000,315.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2790.323,-65.709,1319.588,0.000,0.000,45.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2790.327,-69.250,1319.588,0.000,0.000,315.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19474,2771.356,-69.543,1318.199,0.000,0.000,180.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14714, "vghss1int2", "HS1_2Floor1", 0);
	SetObjectMaterial(tmpobjid, 2, 14500, "imm_roomss", "Bow_bar_top", 0);
	SetObjectMaterial(tmpobjid, 3, 14500, "imm_roomss", "Bow_bar_top", 0);
	SetObjectMaterial(tmpobjid, 4, 14500, "imm_roomss", "Bow_bar_top", 0);
	SetObjectMaterial(tmpobjid, 5, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(2206,2777.000,-83.466,1317.750,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(2297,2790.356,-66.833,1317.838,0.000,0.000,228.000,300.000);
	SetObjectMaterial(tmpobjid, 1, 14500, "imm_roomss", "Bow_bar_top", 0);
	SetObjectMaterial(tmpobjid, 2, 14500, "imm_roomss", "Bow_bar_top", 0);
	SetObjectMaterial(tmpobjid, 3, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(1763,2786.729,-68.666,1317.838,0.000,0.000,96.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14760, "sfhosemed2", "carp19S", 0);
	SetObjectMaterial(tmpobjid, 1, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(1759,2787.634,-65.759,1317.838,0.000,0.000,348.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14760, "sfhosemed2", "carp19S", 0);
	SetObjectMaterial(tmpobjid, 1, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(14455,2781.085,-74.727,1319.510,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14500, "imm_roomss", "motel_wall2", 0);
	tmpobjid = CreateObject(1742,2783.839,-65.239,1317.838,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 2, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(19446,2767.666,-69.446,1319.588,0.000,0.000,359.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19446,2766.813,-65.112,1319.588,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2768.237,-73.667,1319.588,0.000,0.000,44.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2768.253,-65.713,1319.588,0.000,0.000,315.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(1742,2768.543,-73.717,1317.838,0.000,0.000,134.000,300.000);
	SetObjectMaterial(tmpobjid, 2, 14500, "imm_roomss", "Bow_bar_top", 0);
	SetObjectMaterial(tmpobjid, 3, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(18762,2769.940,-65.199,1320.338,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14533, "pleas_dome", "ab_velvor", 0);
	tmpobjid = CreateObject(18762,2772.915,-65.197,1320.338,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14533, "pleas_dome", "ab_velvor", 0);
	tmpobjid = CreateObject(18762,2770.934,-65.199,1316.300,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14533, "pleas_dome", "ab_velvor", 0);
	tmpobjid = CreateObject(18762,2771.925,-65.197,1316.300,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14533, "pleas_dome", "ab_velvor", 0);
	tmpobjid = CreateObject(18762,2771.924,-65.197,1322.500,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14533, "pleas_dome", "ab_velvor", 0);
	tmpobjid = CreateObject(18762,2770.933,-65.199,1322.500,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14533, "pleas_dome", "ab_velvor", 0);
	tmpobjid = CreateObject(19446,2781.199,-83.755,1319.588,0.000,0.000,179.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19446,2771.574,-77.609,1319.588,0.000,0.000,270.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(2099,2786.209,-65.220,1317.838,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 3, 14500, "imm_roomss", "Bow_bar_top", 0);
	SetObjectMaterial(tmpobjid, 6, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(2117,2777.961,-82.500,1317.838,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(19446,2774.528,-82.372,1319.588,0.000,0.000,359.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2775.081,-85.440,1319.588,0.000,0.000,44.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2780.633,-85.449,1319.588,0.000,0.000,315.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2780.615,-78.184,1319.588,0.000,0.000,44.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19384,2777.987,-77.609,1319.588,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2775.094,-78.189,1319.588,0.000,0.000,315.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19354,2781.195,-77.609,1319.588,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2780.635,-77.027,1319.588,0.000,0.000,315.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19384,2767.292,-75.926,1319.588,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19384,2765.157,-77.609,1319.588,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19446,2763.590,-82.388,1319.588,0.000,0.000,359.983,300.000);
	SetObjectMaterial(tmpobjid, 0, 8486, "ballys02", "walltiles_128", 0);
	tmpobjid = CreateObject(19446,2764.441,-83.136,1319.588,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 8486, "ballys02", "walltiles_128", 0);
	tmpobjid = CreateObject(19384,2765.157,-77.698,1319.588,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 8486, "ballys02", "walltiles_128", 0);
	tmpobjid = CreateObject(19446,2766.729,-82.376,1319.588,0.000,0.000,359.983,300.000);
	SetObjectMaterial(tmpobjid, 0, 8486, "ballys02", "walltiles_128", 0);
	tmpobjid = CreateObject(19427,2763.595,-74.260,1319.588,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19384,2763.529,-75.930,1319.588,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(1494,2777.207,-77.626,1317.838,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14653, "ab_trukstpb", "mustard", 0);
	SetObjectMaterial(tmpobjid, 1, 18028, "cj_bar2", "GB_nastybar01", 0);
	tmpobjid = CreateObject(1494,2775.062,-72.398,1317.838,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14653, "ab_trukstpb", "mustard", 0);
	SetObjectMaterial(tmpobjid, 1, 18028, "cj_bar2", "GB_nastybar01", 0);
	tmpobjid = CreateObject(1494,2764.377,-77.641,1317.850,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14653, "ab_trukstpb", "mustard", 0);
	SetObjectMaterial(tmpobjid, 1, 18028, "cj_bar2", "GB_nastybar01", 0);
	tmpobjid = CreateObject(19427,2763.677,-80.037,1319.588,0.000,0.000,269.991,300.000);
	SetObjectMaterial(tmpobjid, 0, 8486, "ballys02", "walltiles_128", 0);
	tmpobjid = CreateObject(2297,2779.281,-78.045,1317.838,0.000,0.000,280.000,300.000);
	SetObjectMaterial(tmpobjid, 2, 14500, "imm_roomss", "Bow_bar_top", 0);
	SetObjectMaterial(tmpobjid, 3, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(1553,2784.097,-75.440,1319.800,0.000,0.000,180.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 15034, "genhotelsave", "AH_windows", 0);
	tmpobjid = CreateObject(1553,2777.854,-85.900,1319.821,0.000,0.000,180.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 15034, "genhotelsave", "AH_windows", 0);
	tmpobjid = CreateObject(1553,2770.972,-77.509,1319.936,0.000,0.000,179.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 15034, "genhotelsave", "AH_windows", 0);
	tmpobjid = CreateObject(1763,2775.496,-76.950,1317.838,0.000,0.000,180.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14760, "sfhosemed2", "carp19S", 0);
	SetObjectMaterial(tmpobjid, 1, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(1763,2772.083,-73.632,1317.838,0.000,0.000,179.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 14760, "sfhosemed2", "carp19S", 0);
	SetObjectMaterial(tmpobjid, 1, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(14455,2772.854,-74.483,1319.510,0.000,0.000,180.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14500, "imm_roomss", "motel_wall2", 0);
	tmpobjid = CreateObject(19427,2762.812,-77.581,1319.588,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19427,2762.823,-74.346,1319.588,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 14387, "dr_gsnew", "mp_gs_wall", 0);
	tmpobjid = CreateObject(19377,2752.898,-73.000,1311.517,0.000,90.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0);
	tmpobjid = CreateObject(19446,2752.885,-77.581,1313.354,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 4556, "laland1_lan2", "gm_labuld2_a", 0);
	tmpobjid = CreateObject(19446,2756.202,-74.346,1313.354,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 4556, "laland1_lan2", "gm_labuld2_a", 0);
	tmpobjid = CreateObject(19446,2757.631,-69.587,1313.354,0.000,0.000,359.983,300.000);
	SetObjectMaterial(tmpobjid, 0, 4556, "laland1_lan2", "gm_labuld2_a", 0);
	tmpobjid = CreateObject(19446,2752.876,-67.894,1313.354,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 4556, "laland1_lan2", "gm_labuld2_a", 0);
	tmpobjid = CreateObject(19446,2748.141,-72.684,1313.354,0.000,0.000,359.983,300.000);
	SetObjectMaterial(tmpobjid, 0, 4556, "laland1_lan2", "gm_labuld2_a", 0);
	tmpobjid = CreateObject(19446,2757.331,-77.581,1316.854,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 4556, "laland1_lan2", "gm_labuld2_a", 0);
	tmpobjid = CreateObject(19384,2749.788,-74.346,1313.354,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 4556, "laland1_lan2", "gm_labuld2_a", 0);
	tmpobjid = CreateObject(19446,2757.331,-74.346,1316.854,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 4556, "laland1_lan2", "gm_labuld2_a", 0);
	tmpobjid = CreateObject(19446,2757.331,-74.346,1320.354,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 4556, "laland1_lan2", "gm_labuld2_a", 0);
	tmpobjid = CreateObject(19446,2757.331,-77.581,1320.354,0.000,0.000,269.989,300.000);
	SetObjectMaterial(tmpobjid, 0, 4556, "laland1_lan2", "gm_labuld2_a", 0);
	tmpobjid = CreateObject(14414,2754.321,-76.290,1318.262,0.000,180.000,269.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0);
	SetObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0);
	tmpobjid = CreateObject(2708,2775.514,-69.163,1317.838,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 1, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(19377,2761.519,-82.447,1317.765,0.000,-90.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 15041, "bigsfsave", "AH_flroortile5", 0);
	tmpobjid = CreateObject(2191,2774.449,-68.866,1317.838,0.000,0.000,270.000,300.000);
	SetObjectMaterial(tmpobjid, 1, 14500, "imm_roomss", "Bow_bar_top", 0);
	SetObjectMaterial(tmpobjid, 2, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(2078,2775.914,-85.399,1317.838,0.000,0.000,140.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(1821,2779.656,-66.113,1317.838,0.000,0.000,316.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(1744,2787.680,-65.216,1319.650,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14500, "imm_roomss", "Bow_bar_top", 0);
	tmpobjid = CreateObject(2287,2786.199,-65.699,1320.000,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 1, 14420, "dr_gsbits", "mp_apt1_pic7", 0);
	tmpobjid = CreateObject(2287,2771.354,-73.699,1319.989,0.000,0.000,180.000,300.000);
	SetObjectMaterial(tmpobjid, 1, 14420, "dr_gsbits", "mp_apt1_pic8", 0);
	tmpobjid = CreateObject(2286,2774.699,-82.291,1320.370,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14420, "dr_gsbits", "mp_apt1_pic5", 0);
	tmpobjid = CreateObject(2286,2774.812,-77.500,1320.400,0.000,0.000,180.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14420, "dr_gsbits", "mp_apt1_pic6", 0);
	tmpobjid = CreateObject(19377,2776.471,-70.341,1321.400,0.000,90.000,89.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0);
	tmpobjid = CreateObject(19377,2786.099,-70.341,1321.400,0.000,90.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0);
	tmpobjid = CreateObject(19377,2776.471,-80.839,1321.400,0.000,90.000,89.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0);
	tmpobjid = CreateObject(19377,2766.839,-70.341,1321.400,0.000,90.000,89.994,300.000);
	SetObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0);
	tmpobjid = CreateObject(19377,2766.839,-80.839,1321.400,0.000,90.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0);
	tmpobjid = CreateObject(19377,2752.898,-69.099,1315.189,0.000,90.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0);
	tmpobjid = CreateObject(1494,2763.541,-76.675,1317.838,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14653, "ab_trukstpb", "mustard", 0);
	SetObjectMaterial(tmpobjid, 1, 18028, "cj_bar2", "GB_nastybar01", 0);
	tmpobjid = CreateObject(19377,2757.248,-76.064,1321.009,0.000,85.499,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0);
	tmpobjid = CreateObject(19377,2767.803,-82.583,1321.375,0.000,-90.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0);
	tmpobjid = CreateObject(19427,2771.414,-65.134,1319.295,89.799,90.099,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 10053, "slapart01sfe", "sl_hirisewhite1", 0);
	tmpobjid = CreateObject(19893,2777.116,-83.609,1318.668,0.000,0.000,40.399,300.000);
	SetObjectMaterial(tmpobjid, 1, 14571, "chinese_furn", "ab_tv_tricas1", 0);
	tmpobjid = CreateObject(14535,2786.641,-72.674,1319.862,0.000,0.000,90.000,300.000);
	tmpobjid = CreateObject(2964,2749.562,-68.794,1311.604,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(1670,2783.718,-72.777,1318.689,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(14705,2790.331,-67.024,1319.791,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(2118,2788.012,-68.447,1317.599,0.000,0.000,96.000,300.000);
	tmpobjid = CreateObject(1670,2787.684,-67.968,1318.410,0.000,0.000,100.000,300.000);
	tmpobjid = CreateObject(948,2781.743,-69.239,1317.838,0.000,0.000,16.000,300.000);
	tmpobjid = CreateObject(2194,2790.200,-67.664,1319.873,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(19823,2787.803,-69.662,1319.708,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(2251,2789.594,-65.958,1318.682,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(2120,2773.327,-70.025,1318.477,0.000,0.000,353.998,300.000);
	tmpobjid = CreateObject(2120,2773.227,-68.629,1318.477,0.000,0.000,13.995,300.000);
	tmpobjid = CreateObject(2120,2772.812,-71.698,1318.477,0.000,0.000,313.991,300.000);
	tmpobjid = CreateObject(2120,2771.165,-72.155,1318.477,0.000,0.000,261.989,300.000);
	tmpobjid = CreateObject(2120,2769.769,-71.453,1318.477,0.000,0.000,215.995,300.000);
	tmpobjid = CreateObject(2120,2769.319,-70.047,1318.477,0.000,0.000,183.991,300.000);
	tmpobjid = CreateObject(2120,2769.270,-68.760,1318.477,0.000,0.000,171.990,300.000);
	tmpobjid = CreateObject(11707,2766.581,-81.017,1319.259,0.000,0.000,-89.999,300.000);
	tmpobjid = CreateObject(2241,2768.724,-66.154,1318.343,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(2241,2780.314,-66.000,1318.839,0.000,0.000,346.000,300.000);
	tmpobjid = CreateObject(2253,2787.801,-70.322,1319.043,0.000,0.000,22.000,300.000);
	tmpobjid = CreateObject(2811,2774.166,-73.300,1317.838,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(2811,2782.639,-65.831,1317.838,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(15038,2774.197,-66.221,1318.456,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(1714,2777.749,-85.013,1317.838,0.000,0.000,172.000,300.000);
	tmpobjid = CreateObject(14455,2780.966,-83.952,1319.510,0.000,0.000,90.000,300.000);
	tmpobjid = CreateObject(1726,2775.196,-81.057,1317.838,0.000,0.000,90.000,300.000);
	tmpobjid = CreateObject(1811,2779.322,-81.462,1318.464,0.000,0.000,40.000,300.000);
	tmpobjid = CreateObject(1811,2776.367,-81.543,1318.464,0.000,0.000,161.990,300.000);
	tmpobjid = CreateObject(1811,2777.940,-79.941,1318.464,0.000,0.000,87.995,300.000);
	tmpobjid = CreateObject(1727,2780.470,-76.237,1317.838,0.000,0.000,225.540,300.000);
	tmpobjid = CreateObject(2811,2776.179,-78.150,1317.838,0.000,0.000,344.000,300.000);
	tmpobjid = CreateObject(2528,2764.179,-78.894,1317.838,0.000,0.000,90.000,300.000);
	tmpobjid = CreateObject(2523,2766.134,-78.313,1317.838,0.000,0.000,270.000,300.000);
	tmpobjid = CreateObject(2828,2777.906,-83.170,1318.687,0.000,0.000,164.000,300.000);
	tmpobjid = CreateObject(2820,2790.471,-71.432,1318.764,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(2812,2790.406,-74.053,1318.764,0.000,0.000,280.000,300.000);
	tmpobjid = CreateObject(2852,2787.945,-67.513,1318.391,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(2853,2783.635,-71.806,1318.646,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(2522,2766.170,-82.531,1317.838,0.000,0.000,180.000,300.000);
	tmpobjid = CreateObject(2332,2780.208,-85.204,1318.302,0.000,0.000,224.000,300.000);
	tmpobjid = CreateObject(14414,2760.000,-76.290,1314.640,0.000,0.000,89.994,300.000);
	tmpobjid = CreateObject(2948,2749.604,-67.980,1314.500,90.000,180.000,270.000,300.000);
	tmpobjid = CreateObject(2948,2753.729,-67.981,1314.500,90.000,179.994,269.994,300.000);
	tmpobjid = CreateObject(2948,2757.544,-69.586,1314.500,90.000,179.994,179.994,300.000);
	tmpobjid = CreateObject(2609,2774.728,-67.292,1318.571,0.000,0.000,270.000,300.000);
	tmpobjid = CreateObject(2046,2787.600,-69.584,1320.000,0.000,0.000,180.000,300.000);
	tmpobjid = CreateObject(2063,2751.998,-73.954,1312.512,0.000,0.000,180.000,300.000);
	tmpobjid = CreateObject(2063,2755.443,-73.942,1312.512,0.000,0.000,181.994,300.000);
	tmpobjid = CreateObject(2065,2756.970,-73.063,1311.604,0.000,0.000,266.000,300.000);
	tmpobjid = CreateObject(1744,2757.544,-70.421,1313.141,0.000,0.000,270.000,300.000);
	tmpobjid = CreateObject(941,2756.814,-70.416,1312.078,0.000,0.000,270.000,300.000);
	tmpobjid = CreateObject(2069,2782.100,-74.635,1317.838,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(2114,2754.122,-74.025,1311.750,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(2284,2768.229,-69.393,1320.099,0.000,0.000,90.000,300.000);
	tmpobjid = CreateObject(2894,2777.876,-83.588,1318.687,0.000,0.000,350.000,300.000);
	tmpobjid = CreateObject(3017,2751.672,-73.949,1312.884,0.000,0.000,180.000,300.000);
	tmpobjid = CreateObject(1747,2757.002,-68.061,1311.604,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(1748,2756.929,-67.982,1312.036,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(1752,2756.020,-68.260,1311.604,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(1789,2754.693,-68.378,1312.160,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(1738,2752.523,-68.233,1312.259,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(1738,2765.391,-74.496,1318.494,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(1738,2763.909,-81.175,1318.494,0.000,0.000,90.000,300.000);
	tmpobjid = CreateObject(1738,2767.960,-71.056,1318.494,0.000,0.000,90.000,300.000);
	tmpobjid = CreateObject(1738,2781.519,-72.222,1318.494,0.000,0.000,90.000,300.000);
	tmpobjid = CreateObject(1736,2771.441,-65.999,1320.699,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(1481,2751.287,-68.388,1312.307,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(1668,2778.379,-83.473,1318.853,0.000,0.000,30.000,300.000);
	tmpobjid = CreateObject(1667,2778.310,-83.738,1318.775,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(1665,2777.412,-83.718,1318.697,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(2394,2775.689,-68.375,1319.577,0.000,0.000,90.000,300.000);
	tmpobjid = CreateObject(3354,2748.228,-71.114,1312.901,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(11712,2777.932,-77.714,1320.649,0.000,0.000,89.299,300.000);
	tmpobjid = CreateObject(19787,2771.391,-65.184,1319.419,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(19828,2779.904,-65.215,1318.849,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(19828,2776.471,-77.512,1318.239,0.000,0.000,-179.099,300.000);
	tmpobjid = CreateObject(16779,2778.081,-82.192,1321.360,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(19814,2778.914,-77.708,1318.279,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(19814,2774.610,-81.783,1318.199,0.000,0.000,90.000,300.000);
	tmpobjid = CreateObject(19814,2753.572,-74.261,1311.833,0.000,0.000,179.600,300.000);
	tmpobjid = CreateObject(19814,2774.337,-74.038,1318.279,0.000,0.000,44.900,300.000);
	tmpobjid = CreateObject(19806,2778.059,-71.548,1321.059,0.000,0.000,0.000,300.000);
	tmpobjid = CreateObject(19814,2786.844,-75.453,1318.199,0.000,0.000,178.199,300.000);
	tmpobjid = CreateObject(19461,2776.645,-63.518,1315.691,90.299,0.000,0.000,300.000);
	tmpobjid = CreateObject(19461,2779.702,-63.541,1315.681,89.800,0.000,0.000,300.000);
	tmpobjid = CreateObject(19415,2778.157,-63.550,1320.487,0.000,-92.600,90.199,300.000);
	tmpobjid = CreateObject(19824,2787.445,-69.664,1319.709,0.000,0.000,0.000,300.000);
	print("-> Spawn loaded");
	// fy_snow
	new g_Object[131];
	g_Object[0] = CreateObject(18981, 1300.7271, 2540.1767, 452.0955, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[0], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[1] = CreateObject(18981, 1325.7065, 2540.1767, 452.0955, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[1], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[2] = CreateObject(19464, 1318.2603, 2542.0900, 454.8498, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[2], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[3] = CreateObject(19464, 1321.1606, 2544.9509, 454.8498, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[3], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[4] = CreateObject(19464, 1324.0404, 2542.0900, 454.8498, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[4], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[5] = CreateObject(19430, 1318.8509, 2538.7644, 455.6600, 0.0000, 0.0000, 56.9000); //
	SetObjectMaterial(g_Object[5], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[6] = CreateObject(19430, 1318.8509, 2538.7651, 453.7001, 0.0000, 0.0000, 56.9000); //
	SetObjectMaterial(g_Object[6], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[7] = CreateObject(19430, 1320.2810, 2538.3400, 455.6600, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[7], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[8] = CreateObject(19430, 1321.8708, 2538.3400, 455.6600, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[8], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[9] = CreateObject(19430, 1323.3414, 2538.3395, 455.6600, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[9], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[10] = CreateObject(19430, 1320.2810, 2538.3410, 453.7001, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[10], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[11] = CreateObject(19430, 1321.8708, 2538.3410, 453.7001, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[11], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[12] = CreateObject(19430, 1323.3404, 2538.3410, 453.7001, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[12], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[13] = CreateObject(19464, 1324.0410, 2541.2309, 454.8493, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[13], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[14] = CreateObject(19464, 1313.2708, 2542.0900, 454.8498, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[14], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[15] = CreateObject(19464, 1310.4108, 2544.9509, 454.8498, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[15], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[16] = CreateObject(19464, 1307.5494, 2542.0900, 454.8498, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[16], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[17] = CreateObject(19464, 1307.5450, 2541.2309, 454.8493, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[17], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[18] = CreateObject(19430, 1312.6700, 2538.7685, 453.7001, 0.0000, 0.0000, -56.9000); //
	SetObjectMaterial(g_Object[18], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[19] = CreateObject(19430, 1312.6700, 2538.7680, 455.6600, 0.0000, 0.0000, -56.9000); //
	SetObjectMaterial(g_Object[19], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[20] = CreateObject(19430, 1311.2512, 2538.3410, 453.7001, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[20], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[21] = CreateObject(19430, 1309.6507, 2538.3410, 453.7001, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[21], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[22] = CreateObject(19430, 1308.2297, 2538.3415, 453.7005, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[22], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[23] = CreateObject(19430, 1311.2512, 2538.3405, 455.6600, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[23], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[24] = CreateObject(19430, 1309.6507, 2538.3405, 455.6604, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[24], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[25] = CreateObject(19430, 1308.2297, 2538.3410, 455.6600, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[25], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[26] = CreateObject(19430, 1312.6772, 2532.7736, 453.7001, 0.0000, 0.0000, 56.9000); //
	SetObjectMaterial(g_Object[26], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[27] = CreateObject(19430, 1312.6777, 2532.7741, 455.6600, 0.0000, 0.0000, 56.9000); //
	SetObjectMaterial(g_Object[27], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[28] = CreateObject(18981, 1300.7271, 2515.1860, 452.0955, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[28], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[29] = CreateObject(18981, 1325.7065, 2515.1882, 452.0955, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[29], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[30] = CreateObject(19430, 1311.2512, 2533.1984, 453.7001, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[30], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[31] = CreateObject(19430, 1309.7015, 2533.1979, 453.7001, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[31], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[32] = CreateObject(19430, 1308.2211, 2533.1989, 453.7001, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[32], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[33] = CreateObject(19464, 1307.5450, 2530.3110, 454.8493, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[33], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[34] = CreateObject(19464, 1313.2747, 2529.4409, 454.8493, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[34], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[35] = CreateObject(19464, 1307.5429, 2529.4450, 454.8497, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[35], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[36] = CreateObject(19430, 1311.2512, 2533.1994, 455.6600, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[36], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[37] = CreateObject(19430, 1309.7015, 2533.1984, 455.6600, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[37], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[38] = CreateObject(19430, 1308.2211, 2533.1994, 455.6600, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[38], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[39] = CreateObject(19464, 1310.4108, 2526.6000, 454.8498, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[39], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[40] = CreateObject(19464, 1324.0410, 2529.4450, 454.8497, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[40], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[41] = CreateObject(19464, 1324.0415, 2530.3110, 454.8497, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[41], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[42] = CreateObject(19464, 1321.1811, 2526.6000, 454.8498, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[42], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[43] = CreateObject(19464, 1318.3247, 2529.4409, 454.8493, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[43], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[44] = CreateObject(19430, 1318.9376, 2532.7807, 453.7001, 0.0000, 0.0000, -56.9000); //
	SetObjectMaterial(g_Object[44], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[45] = CreateObject(19430, 1318.9376, 2532.7812, 455.6600, 0.0000, 0.0000, -56.9000); //
	SetObjectMaterial(g_Object[45], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[46] = CreateObject(19430, 1320.3612, 2533.1984, 453.7001, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[46], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[47] = CreateObject(19430, 1321.9516, 2533.1979, 453.7005, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[47], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[48] = CreateObject(19430, 1323.3613, 2533.1984, 453.7001, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[48], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[49] = CreateObject(19430, 1323.3613, 2533.1989, 455.6600, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[49], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[50] = CreateObject(19430, 1321.9516, 2533.1984, 455.6600, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[50], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[51] = CreateObject(19430, 1320.3612, 2533.1992, 455.6600, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[51], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[52] = CreateObject(18981, 1298.0867, 2552.6374, 445.8054, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[52], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[53] = CreateObject(18981, 1323.0849, 2552.6374, 445.8053, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[53], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[54] = CreateObject(18981, 1323.0849, 2519.6433, 445.8053, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[54], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[55] = CreateObject(18981, 1298.1154, 2519.6433, 445.8053, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[55], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[56] = CreateObject(18981, 1291.4252, 2532.3017, 445.8053, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[56], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[57] = CreateObject(18981, 1291.4252, 2557.2707, 445.8053, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[57], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[58] = CreateObject(18981, 1341.4453, 2557.2707, 445.8053, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[58], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[59] = CreateObject(18981, 1335.2263, 2540.1767, 452.0945, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[59], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[60] = CreateObject(18981, 1335.2263, 2515.1870, 452.0945, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[60], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[61] = CreateObject(18981, 1341.4453, 2532.2834, 445.8053, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[61], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[62] = CreateObject(18981, 1348.0245, 2519.6433, 445.8053, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[62], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[63] = CreateObject(18981, 1348.0654, 2552.6374, 445.8053, 0.0000, 0.0000, 90.0000); //
	SetObjectMaterial(g_Object[63], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[64] = CreateObject(18980, 1340.9670, 2551.3842, 445.8053, 0.0000, 0.0000, 48.2000); //
	SetObjectMaterial(g_Object[64], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[65] = CreateObject(18980, 1339.9685, 2552.2773, 445.8053, 0.0000, 0.0000, 48.2000); //
	SetObjectMaterial(g_Object[65], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[66] = CreateObject(18980, 1340.4898, 2551.8120, 445.8053, 0.0000, 0.0000, 48.2000); //
	SetObjectMaterial(g_Object[66], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[67] = CreateObject(18980, 1292.8721, 2520.0991, 445.8053, 0.0000, 0.0000, 48.2000); //
	SetObjectMaterial(g_Object[67], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[68] = CreateObject(18980, 1291.9328, 2520.9389, 445.8053, 0.0000, 0.0000, 48.2000); //
	SetObjectMaterial(g_Object[68], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[69] = CreateObject(18980, 1292.3874, 2520.5312, 445.8053, 0.0000, 0.0000, 48.2000); //
	SetObjectMaterial(g_Object[69], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[70] = CreateObject(18980, 1293.3641, 2552.2075, 445.8053, 0.0000, 0.0000, -48.2000); //
	SetObjectMaterial(g_Object[70], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[71] = CreateObject(18980, 1291.9556, 2550.9462, 445.8053, 0.0000, 0.0000, -48.2000); //
	SetObjectMaterial(g_Object[71], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[72] = CreateObject(18980, 1292.6634, 2551.5808, 445.8053, 0.0000, 0.0000, -48.2000); //
	SetObjectMaterial(g_Object[72], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[73] = CreateObject(18980, 1339.8061, 2520.0998, 445.8053, 0.0000, 0.0000, -48.2000); //
	SetObjectMaterial(g_Object[73], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[74] = CreateObject(18980, 1340.9241, 2521.1000, 445.8053, 0.0000, 0.0000, -48.2000); //
	SetObjectMaterial(g_Object[74], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[75] = CreateObject(18980, 1340.3950, 2520.6276, 445.8053, 0.0000, 0.0000, -48.2000); //
	SetObjectMaterial(g_Object[75], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[76] = CreateObject(18980, 1340.6064, 2536.0996, 443.4805, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[76], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[77] = CreateObject(18980, 1339.6365, 2536.0996, 443.4805, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[77], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[78] = CreateObject(18980, 1338.6466, 2536.0996, 443.4805, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[78], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[79] = CreateObject(18980, 1338.2011, 2536.0925, 443.4815, 0.0000, 0.0000, 45.0000); //
	SetObjectMaterial(g_Object[79], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[80] = CreateObject(18980, 1292.3559, 2536.0996, 443.4805, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[80], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[81] = CreateObject(18980, 1293.3359, 2536.0996, 443.4805, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[81], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[82] = CreateObject(18980, 1294.3256, 2536.0996, 443.4805, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[82], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[83] = CreateObject(18980, 1294.7078, 2536.0993, 443.4815, 0.0000, 0.0000, 45.0000); //
	SetObjectMaterial(g_Object[83], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[84] = CreateObject(4724, 1310.3361, 2554.6108, 453.8780, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[84], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[85] = CreateObject(19464, 1324.0218, 2526.7268, 451.2266, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[85], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[86] = CreateObject(19464, 1307.5623, 2526.7268, 451.2266, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[86], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[87] = CreateObject(4724, 1321.1571, 2517.6289, 453.8780, 0.0000, 0.0000, 180.0000); //
	SetObjectMaterial(g_Object[87], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[88] = CreateObject(19789, 1314.8453, 2531.8857, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[88], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[89] = CreateObject(19789, 1313.8452, 2531.8857, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[89], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[90] = CreateObject(19789, 1315.8355, 2531.8857, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[90], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[91] = CreateObject(19789, 1316.8356, 2531.8857, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[91], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[92] = CreateObject(19789, 1317.8359, 2531.8857, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[92], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[93] = CreateObject(19789, 1317.8359, 2539.6557, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[93], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[94] = CreateObject(19789, 1316.8354, 2539.6557, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[94], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[95] = CreateObject(19789, 1315.8353, 2539.6557, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[95], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[96] = CreateObject(19789, 1314.8449, 2539.6557, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[96], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[97] = CreateObject(19789, 1313.8344, 2539.6557, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[97], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[98] = CreateObject(19464, 1324.0218, 2544.6682, 451.2266, 0.0000, 0.0000, 180.0000); //
	SetObjectMaterial(g_Object[98], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[99] = CreateObject(19464, 1307.5614, 2544.6682, 451.2266, 0.0000, 0.0000, 180.0000); //
	SetObjectMaterial(g_Object[99], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[100] = CreateObject(19789, 1311.5142, 2537.8056, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[100], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[101] = CreateObject(19789, 1311.5142, 2536.8056, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[101], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[102] = CreateObject(19789, 1311.5142, 2535.8059, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[102], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[103] = CreateObject(19789, 1311.5142, 2534.8063, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[103], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[104] = CreateObject(19789, 1311.5142, 2533.8056, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[104], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[105] = CreateObject(19789, 1311.5142, 2532.8146, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[105], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[106] = CreateObject(19789, 1320.0541, 2533.7355, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[106], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[107] = CreateObject(19789, 1320.0541, 2534.7460, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[107], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[108] = CreateObject(19789, 1320.0541, 2535.7470, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[108], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[109] = CreateObject(19789, 1320.0541, 2536.7480, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[109], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[110] = CreateObject(19789, 1320.0541, 2537.7490, 456.3827, 0.0000, 0.0000, 0.0000); //
	SetObjectMaterial(g_Object[110], 0, 2624, "cj_urb", "cj_bricks", 0xFFFFFFFF);
	g_Object[111] = CreateObject(19464, 1320.7111, 2542.0900, 457.3098, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[111], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[112] = CreateObject(19464, 1321.5915, 2542.0905, 457.3092, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[112], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[113] = CreateObject(19464, 1310.8212, 2542.0905, 457.3092, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[113], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[114] = CreateObject(19464, 1310.8212, 2529.4299, 457.3092, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[114], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[115] = CreateObject(19464, 1320.7717, 2529.4299, 457.3092, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[115], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[116] = CreateObject(19464, 1310.0015, 2542.0905, 457.3098, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[116], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[117] = CreateObject(19464, 1310.0015, 2529.4208, 457.3098, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[117], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[118] = CreateObject(19464, 1321.5921, 2529.4208, 457.3098, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[118], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[119] = CreateObject(19430, 1322.3978, 2532.4411, 457.3305, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[119], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[120] = CreateObject(19430, 1321.3074, 2532.4416, 457.3315, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[120], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[121] = CreateObject(19430, 1319.8405, 2531.3403, 457.3309, 0.0000, 90.0000, -56.9000); //
	SetObjectMaterial(g_Object[121], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[122] = CreateObject(19430, 1321.3074, 2539.0617, 457.3315, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[122], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[123] = CreateObject(19430, 1322.3880, 2539.0612, 457.3309, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[123], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[124] = CreateObject(19430, 1309.1976, 2539.0612, 457.3309, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[124], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[125] = CreateObject(19430, 1310.2971, 2539.0617, 457.3304, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[125], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[126] = CreateObject(19430, 1310.2971, 2532.4711, 457.3304, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[126], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[127] = CreateObject(19430, 1309.1872, 2532.4716, 457.3309, 0.0000, 90.0000, 0.0000); //
	SetObjectMaterial(g_Object[127], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[128] = CreateObject(19430, 1311.7525, 2540.1755, 457.3298, 0.0000, 90.0000, -56.9000); //
	SetObjectMaterial(g_Object[128], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[129] = CreateObject(19430, 1319.7790, 2540.1889, 457.3400, 0.0000, 90.0000, 56.9000); //
	SetObjectMaterial(g_Object[129], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	g_Object[130] = CreateObject(19430, 1311.7491, 2531.3500, 457.3399, 0.0000, 90.0000, 56.9000); //
	SetObjectMaterial(g_Object[130], 0, 3922, "bistro", "mp_snow", 0xFFFFFFFF);
	CreateDynamicObject(3115, 1302.38574, 2546.28394, 458.29758,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3115, 1302.39575, 2527.52881, 458.29758,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3115, 1323.51050, 2527.54590, 458.29758,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3115, 1323.46167, 2546.26855, 458.29758,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3115, 1344.53625, 2527.51123, 458.29758,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3115, 1344.51697, 2546.26855, 458.29758,   0.00000, 0.00000, 0.00000);
	print("-> fy_snow loaded");
}
/*CreateServerGlobalTextdraw(playerid, bool:show)
{
	if(show == true)
	{
		wldm_TD[0] = TextDrawCreate(-33.447395, 422.749847, "");
		TextDrawLetterSize(wldm_TD[0], 0.000000, 0.000000);
		TextDrawTextSize(wldm_TD[0], 145.000000, 32.000000);
		TextDrawAlignment(wldm_TD[0], 1);
		TextDrawColor(wldm_TD[0], 119);
		TextDrawSetShadow(wldm_TD[0], 0);
		TextDrawSetOutline(wldm_TD[0], 0);
		TextDrawBackgroundColor(wldm_TD[0], 0);
		TextDrawFont(wldm_TD[0], 5);
		TextDrawSetProportional(wldm_TD[0], 0);
		TextDrawSetShadow(wldm_TD[0], 0);
		TextDrawSetPreviewModel(wldm_TD[0], 2729);
		TextDrawSetPreviewRot(wldm_TD[0], 0.000000, 90.000000, 180.000000, 1.158357);

		wldm_TD[1] = TextDrawCreate(38.404136, 431.500030, "Wonderland_Deathmatch");
		TextDrawLetterSize(wldm_TD[1], 0.163396, 0.800831);
		TextDrawAlignment(wldm_TD[1], 2);
		TextDrawColor(wldm_TD[1], -1631584649);
		TextDrawSetShadow(wldm_TD[1], 0);
		TextDrawSetOutline(wldm_TD[1], 0);
		TextDrawBackgroundColor(wldm_TD[1], 799);
		TextDrawFont(wldm_TD[1], 1);
		TextDrawSetProportional(wldm_TD[1], 1);
		TextDrawSetShadow(wldm_TD[1], 0);

		wldm_TD[2] = TextDrawCreate(6.545156, 436.749908, "In_development");
		TextDrawLetterSize(wldm_TD[2], 0.159648, 0.754166);
		TextDrawAlignment(wldm_TD[2], 1);
		TextDrawColor(wldm_TD[2], -137);
		TextDrawSetShadow(wldm_TD[2], 0);
		TextDrawSetOutline(wldm_TD[2], 0);
		TextDrawBackgroundColor(wldm_TD[2], 799);
		TextDrawFont(wldm_TD[2], 1);
		TextDrawSetProportional(wldm_TD[2], 1);
		TextDrawSetShadow(wldm_TD[2], 0);

		wldm_TD[3] = TextDrawCreate(70.732559, 436.749908, "0.0.1");
		TextDrawLetterSize(wldm_TD[3], 0.159648, 0.754166);
		TextDrawAlignment(wldm_TD[3], 3);
		TextDrawColor(wldm_TD[3], -137);
		TextDrawSetShadow(wldm_TD[3], 0);
		TextDrawSetOutline(wldm_TD[3], 0);
		TextDrawBackgroundColor(wldm_TD[3], 799);
		TextDrawFont(wldm_TD[3], 1);
		TextDrawSetProportional(wldm_TD[3], 1);
		TextDrawSetShadow(wldm_TD[3], 0);
		for( new i = 0; i < 4; i ++ ) {
			TextDrawShowForPlayer(playerid, wldm_TD[i]);
		}
	}
	else if( show == false ) {
	for( new i = 0; i < 4; i ++) {
			TextDrawDestroy(wldm_TD[i]);
		}
	}
}*/

CreatePlayerWLTextdraw(playerid, bool:show)
{
	if(show == true)
	{
		wldm_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 573.923950, 383.083343, "box");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][0], 0.000000, 0.816985);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][0], 696.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][0], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][0], -1);
		PlayerTextDrawUseBox(playerid, wldm_PTD[playerid][0], 1);
		PlayerTextDrawBoxColor(playerid, wldm_PTD[playerid][0], -86);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][0], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][0], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][0], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][0], 1);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][0], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][0], 0);

		wldm_PTD[playerid][1] = CreatePlayerTextDraw(playerid, 573.924194, 395.133331, "box");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][1], 0.000000, 0.816985);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][1], 637.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][1], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][1], -1);
		PlayerTextDrawUseBox(playerid, wldm_PTD[playerid][1], 1);
		PlayerTextDrawBoxColor(playerid, wldm_PTD[playerid][1], -188);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][1], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][1], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][1], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][1], 1);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][1], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][1], 0);

		wldm_PTD[playerid][2] = CreatePlayerTextDraw(playerid, 573.924194, 407.183441, "box");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][2], 0.000000, 0.816985);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][2], 637.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][2], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][2], -1);
		PlayerTextDrawUseBox(playerid, wldm_PTD[playerid][2], 1);
		PlayerTextDrawBoxColor(playerid, wldm_PTD[playerid][2], -86);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][2], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][2], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][2], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][2], 1);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][2], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][2], 0);

		wldm_PTD[playerid][3] = CreatePlayerTextDraw(playerid, 573.924194, 419.233306, "box");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][3], 0.000000, 0.816985);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][3], 637.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][3], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][3], -1);
		PlayerTextDrawUseBox(playerid, wldm_PTD[playerid][3], 1);
		PlayerTextDrawBoxColor(playerid, wldm_PTD[playerid][3], -188);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][3], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][3], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][3], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][3], 1);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][3], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][3], 0);

		wldm_PTD[playerid][4] = CreatePlayerTextDraw(playerid, 573.924194, 431.100189, "box");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][4], 0.000000, 0.816985);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][4], 637.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][4], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][4], -1);
		PlayerTextDrawUseBox(playerid, wldm_PTD[playerid][4], 1);
		PlayerTextDrawBoxColor(playerid, wldm_PTD[playerid][4], -86);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][4], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][4], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][4], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][4], 1);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][4], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][4], 0);

		wldm_PTD[playerid][5] = CreatePlayerTextDraw(playerid, 505.988067, 395.116729, "box");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][5], 0.000000, 0.816985);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][5], 571.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][5], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][5], -1);
		PlayerTextDrawUseBox(playerid, wldm_PTD[playerid][5], 1);
		PlayerTextDrawBoxColor(playerid, wldm_PTD[playerid][5], -86);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][5], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][5], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][5], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][5], 1);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][5], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][5], 0);

		wldm_PTD[playerid][6] = CreatePlayerTextDraw(playerid, 505.988067, 419.033325, "box");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][6], 0.000000, 0.816985);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][6], 571.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][6], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][6], -1);
		PlayerTextDrawUseBox(playerid, wldm_PTD[playerid][6], 1);
		PlayerTextDrawBoxColor(playerid, wldm_PTD[playerid][6], -86);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][6], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][6], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][6], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][6], 1);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][6], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][6], 0);

		wldm_PTD[playerid][7] = CreatePlayerTextDraw(playerid, 505.988067, 383.166656, "box");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][7], 0.000000, 0.816985);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][7], 571.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][7], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][7], -1);
		PlayerTextDrawUseBox(playerid, wldm_PTD[playerid][7], 1);
		PlayerTextDrawBoxColor(playerid, wldm_PTD[playerid][7], -171);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][7], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][7], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][7], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][7], 1);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][7], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][7], 0);

		wldm_PTD[playerid][8] = CreatePlayerTextDraw(playerid, 505.988067, 407.083496, "box");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][8], 0.000000, 0.816985);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][8], 571.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][8], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][8], -1);
		PlayerTextDrawUseBox(playerid, wldm_PTD[playerid][8], 1);
		PlayerTextDrawBoxColor(playerid, wldm_PTD[playerid][8], -171);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][8], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][8], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][8], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][8], 1);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][8], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][8], 0);

		wldm_PTD[playerid][9] = CreatePlayerTextDraw(playerid, 505.988067, 431.000305, "box");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][9], 0.000000, 0.816985);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][9], 571.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][9], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][9], -1);
		PlayerTextDrawUseBox(playerid, wldm_PTD[playerid][9], 1);
		PlayerTextDrawBoxColor(playerid, wldm_PTD[playerid][9], -171);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][9], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][9], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][9], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][9], 1);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][9], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][9], 0);

		wldm_PTD[playerid][10] = CreatePlayerTextDraw(playerid, 503.477294, 380.666656, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][10], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][10], 1.000000, 60.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][10], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][10], 1929423359);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][10], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][10], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][10], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][10], 4);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][10], 0);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][10], 0);

		wldm_PTD[playerid][11] = CreatePlayerTextDraw(playerid, 571.881713, 380.666656, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][11], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][11], 1.000000, 12.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][11], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][11], 1929423359);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][11], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][11], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][11], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][11], 4);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][11], 0);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][11], 0);

		wldm_PTD[playerid][12] = CreatePlayerTextDraw(playerid, 571.881713, 404.866790, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][12], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][12], 1.000000, 12.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][12], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][12], 1929423359);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][12], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][12], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][12], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][12], 4);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][12], 0);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][12], 0);

		wldm_PTD[playerid][13] = CreatePlayerTextDraw(playerid, 571.881713, 428.783508, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][13], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][13], 1.000000, 12.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][13], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][13], 1929423359);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][13], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][13], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][13], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][13], 4);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][13], 0);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][13], 0);

		wldm_PTD[playerid][14] = CreatePlayerTextDraw(playerid, 524.092590, 362.866821, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][14], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][14], 1.000000, 12.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][14], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][14], 1929423359);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][14], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][14], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][14], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][14], 4);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][14], 0);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][14], 0);

		wldm_PTD[playerid][15] = CreatePlayerTextDraw(playerid, 526.603454, 365.183258, "box");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][15], 0.000000, 0.816985);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][15], 582.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][15], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][15], -1);
		PlayerTextDrawUseBox(playerid, wldm_PTD[playerid][15], 1);
		PlayerTextDrawBoxColor(playerid, wldm_PTD[playerid][15], -188);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][15], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][15], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][15], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][15], 1);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][15], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][15], 0);

		wldm_PTD[playerid][16] = CreatePlayerTextDraw(playerid, 585.637084, 365.183319, "box");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][16], 0.000000, 0.816985);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][16], 628.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][16], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][16], -1);
		PlayerTextDrawUseBox(playerid, wldm_PTD[playerid][16], 1);
		PlayerTextDrawBoxColor(playerid, wldm_PTD[playerid][16], -86);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][16], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][16], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][16], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][16], 1);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][16], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][16], 0);

		wldm_PTD[playerid][17] = CreatePlayerTextDraw(playerid, 553.309265, 364.416595, "Shawn_Lewis");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][17], 0.129663, 0.847499);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][17], 2);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][17], 255);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][17], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][17], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][17], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][17], 2);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][17], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][17], 0);

		wldm_PTD[playerid][18] = CreatePlayerTextDraw(playerid, 607.189331, 364.416595, "127.0.0.1");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][18], 0.129663, 0.847499);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][18], 2);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][18], 255);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][18], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][18], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][18], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][18], 2);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][18], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][18], 0);

		wldm_PTD[playerid][19] = CreatePlayerTextDraw(playerid, 508.331115, 382.500061, "FPS:_200");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][19], 0.129663, 0.847499);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][19], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][19], 255);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][19], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][19], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][19], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][19], 2);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][19], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][19], 0);

		wldm_PTD[playerid][20] = CreatePlayerTextDraw(playerid, 577.204223, 382.500061, "Ping:_200");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][20], 0.129663, 0.847499);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][20], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][20], 255);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][20], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][20], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][20], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][20], 2);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][20], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][20], 0);

		wldm_PTD[playerid][21] = CreatePlayerTextDraw(playerid, 508.162597, 394.750091, "player_id:_20");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][21], 0.129663, 0.847499);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][21], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][21], 255);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][21], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][21], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][21], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][21], 2);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][21], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][21], 0);

		wldm_PTD[playerid][22] = CreatePlayerTextDraw(playerid, 576.735351, 394.750091, "packet_loss:_0.00%");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][22], 0.129663, 0.847499);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][22], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][22], 255);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][22], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][22], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][22], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][22], 2);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][22], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][22], 0);

		wldm_PTD[playerid][23] = CreatePlayerTextDraw(playerid, 508.330993, 407.000122, "kills:_200");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][23], 0.129663, 0.847499);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][23], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][23], 255);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][23], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][23], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][23], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][23], 2);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][23], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][23], 0);

		wldm_PTD[playerid][24] = CreatePlayerTextDraw(playerid, 577.203735, 407.000122, "deaths:_200");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][24], 0.129663, 0.847499);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][24], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][24], 255);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][24], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][24], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][24], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][24], 2);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][24], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][24], 0);

		wldm_PTD[playerid][25] = CreatePlayerTextDraw(playerid, 508.330993, 418.666748, "Health:_200");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][25], 0.129663, 0.847499);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][25], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][25], 255);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][25], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][25], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][25], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][25], 2);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][25], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][25], 0);

		wldm_PTD[playerid][26] = CreatePlayerTextDraw(playerid, 577.672180, 418.666748, "armour:_100");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][26], 0.129663, 0.847499);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][26], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][26], 255);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][26], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][26], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][26], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][26], 2);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][26], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][26], 0);

		wldm_PTD[playerid][27] = CreatePlayerTextDraw(playerid, 536.442321, 430.333465, "15:00:00");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][27], 0.129663, 0.847499);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][27], 2);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][27], 255);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][27], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][27], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][27], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][27], 2);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][27], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][27], 0);

		wldm_PTD[playerid][28] = CreatePlayerTextDraw(playerid, 606.720703, 430.916809, "15/02/2019");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][28], 0.129663, 0.847499);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][28], 2);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][28], 255);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][28], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][28], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][28], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][28], 2);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][28], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][28], 0);

		wldm_PTD[playerid][29] = CreatePlayerTextDraw(playerid, 524.561096, 8.200193, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][29], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][29], 1.000000, 12.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][29], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][29], 1929423359);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][29], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][29], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][29], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][29], 4);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][29], 0);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][29], 0);

		wldm_PTD[playerid][30] = CreatePlayerTextDraw(playerid, 526.534423, 10.433305, "box");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][30], 0.000000, 0.816985);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][30], 579.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][30], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][30], -1);
		PlayerTextDrawUseBox(playerid, wldm_PTD[playerid][30], 1);
		PlayerTextDrawBoxColor(playerid, wldm_PTD[playerid][30], -171);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][30], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][30], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][30], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][30], 1);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][30], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][30], 0);

		wldm_PTD[playerid][31] = CreatePlayerTextDraw(playerid, 582.757202, 10.433305, "box");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][31], 0.000000, 0.816985);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][31], 626.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][31], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][31], -1);
		PlayerTextDrawUseBox(playerid, wldm_PTD[playerid][31], 1);
		PlayerTextDrawBoxColor(playerid, wldm_PTD[playerid][31], -86);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][31], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][31], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][31], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][31], 1);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][31], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][31], 0);

		wldm_PTD[playerid][32] = CreatePlayerTextDraw(playerid, 554.714965, 10.333233, "wonderland");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][32], 0.129663, 0.847499);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][32], 2);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][32], 255);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][32], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][32], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][32], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][32], 2);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][32], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][32], 0);

		wldm_PTD[playerid][33] = CreatePlayerTextDraw(playerid, 603.909667, 10.333231, "deathmatch");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][33], 0.129663, 0.847499);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][33], 2);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][33], 255);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][33], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][33], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][33], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][33], 2);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][33], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][33], 0);

		wldm_PTD[playerid][34] = CreatePlayerTextDraw(playerid, 580.783935, 20.450189, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][34], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][34], 1.000000, 12.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][34], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][34], 1929423359);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][34], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][34], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][34], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][34], 4);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][34], 0);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][34], 0);

		wldm_PTD[playerid][35] = CreatePlayerTextDraw(playerid, 583.225585, 22.099979, "box");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][35], 0.000000, 0.816985);
		PlayerTextDrawTextSize(playerid, wldm_PTD[playerid][35], 626.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][35], 1);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][35], -1);
		PlayerTextDrawUseBox(playerid, wldm_PTD[playerid][35], 1);
		PlayerTextDrawBoxColor(playerid, wldm_PTD[playerid][35], -171);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][35], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][35], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][35], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][35], 1);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][35], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][35], 0);

		wldm_PTD[playerid][36] = CreatePlayerTextDraw(playerid, 603.909667, 21.999900, "early_access");
		PlayerTextDrawLetterSize(playerid, wldm_PTD[playerid][36], 0.129663, 0.847499);
		PlayerTextDrawAlignment(playerid, wldm_PTD[playerid][36], 2);
		PlayerTextDrawColor(playerid, wldm_PTD[playerid][36], 255);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][36], 0);
		PlayerTextDrawSetOutline(playerid, wldm_PTD[playerid][36], 0);
		PlayerTextDrawBackgroundColor(playerid, wldm_PTD[playerid][36], 255);
		PlayerTextDrawFont(playerid, wldm_PTD[playerid][36], 2);
		PlayerTextDrawSetProportional(playerid, wldm_PTD[playerid][36], 1);
		PlayerTextDrawSetShadow(playerid, wldm_PTD[playerid][36], 0);
		for( new i = 0; i < 37; i ++ ) {
			PlayerTextDrawShow(playerid, wldm_PTD[playerid][i]);
		}
	}
	else if( show == false )
	{
		for( new i = 0; i < 37; i ++)
		{
		    PlayerTextDrawHide(playerid, wldm_PTD[playerid][i]);
			PlayerTextDrawDestroy(playerid, wldm_PTD[playerid][i]);
			wldm_PTD[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
		}
	}
}

stock PreloadAnimLib(playerid, animlib[]) return ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0,1);

SpawnFookinPlayer(playerid)
{
	PreloadAnimLib(playerid,"CRACK"); PreloadAnimLib(playerid,"CARRY");
	PreloadAnimLib(playerid,"SWEET"); PreloadAnimLib(playerid,"PED");
	PreloadAnimLib(playerid,"RAPPING"); PreloadAnimLib(playerid,"COP_AMBIENT");
	PreloadAnimLib(playerid,"DEALER"); PreloadAnimLib(playerid,"BEACH");
	PreloadAnimLib(playerid,"ON_LOOKERS"); PreloadAnimLib(playerid,"SUNBATHE");
	PreloadAnimLib(playerid,"RIOT"); PreloadAnimLib(playerid,"SHOP");
	PreloadAnimLib(playerid,"PARACHUTE"); PreloadAnimLib(playerid,"GHANDS");
	PreloadAnimLib(playerid,"MEDIC"); PreloadAnimLib(playerid,"MISC");
	PreloadAnimLib(playerid,"SWAT"); PreloadAnimLib(playerid,"GANGS");
	PreloadAnimLib(playerid,"BOMBER"); PreloadAnimLib(playerid,"FOOD");
	PreloadAnimLib(playerid,"PARK"); PreloadAnimLib(playerid,"GRAVEYARD");
	PreloadAnimLib(playerid,"KISSING"); PreloadAnimLib(playerid,"KNIFE");
	PreloadAnimLib(playerid,"FINALE"); PreloadAnimLib(playerid,"SMOKING");
	PreloadAnimLib(playerid,"BLOWJOBZ"); PreloadAnimLib(playerid,"SNM");
	PreloadAnimLib(playerid,"LOWRIDER"); PreloadAnimLib(playerid,"DANCING");
	PreloadAnimLib(playerid,"ROB_BANK"); PreloadAnimLib(playerid,"POLICE");
    SetPlayerInterior(playerid, 2);
	SetSpawnInfo(playerid, 0, pInfo[playerid][Skin], 2778.1702,-66.8400,1318.8390, 181.1323, 0, 0, 0, 0, 0, 0);
	SetPlayerVirtualWorld(playerid, 200);
	SpawnPlayer(playerid);
}

GetPlayerFPS(playerid)
{
    SetPVarInt(playerid, "DrunkL", GetPlayerDrunkLevel(playerid));
    if(GetPVarInt(playerid, "DrunkL") < 100){SetPlayerDrunkLevel(playerid, 2000);}else
    {
        if(GetPVarInt(playerid, "LDrunkL") != GetPVarInt(playerid, "DrunkL"))
        {
            SetPVarInt(playerid, "FPS", (GetPVarInt(playerid, "LDrunkL") - GetPVarInt(playerid, "DrunkL")));
            SetPVarInt(playerid, "LDrunkL", GetPVarInt(playerid, "DrunkL"));
            if((GetPVarInt(playerid, "FPS") > 0) && (GetPVarInt(playerid, "FPS") < 256))
            {
                return GetPVarInt(playerid, "FPS") - 1;
            }
        }
    }
    return 0;
}

stock ShowPlayerAchievements(playerid, targetid)
{
        new TempStr[620], complete[20], incomplete[20];
        complete = "{05E200}[•]", incomplete = "{FF0000}[•]";
        strcat(TempStr, "%s {FFFFFF}Millionare {FF4500}- {00FFFF}Skupi 5.000.000$!\n");
        strcat(TempStr, "%s {FFFFFF}Score Whore {FF4500}- {00FFFF}Dostigni 2,500 scorea!\n");
        strcat(TempStr, "%s {FFFFFF}Mother of Lag {FF4500}- {00FFFF}Moras imati ping preko 500\n");
        strcat(TempStr, "%s {FFFFFF}First good score {FF4500}- {00FFFF}Dostigni score visi od 30\n\n");
        strcat(TempStr, "%s(%i) je zavrsio/la %i/4 achievementa!\n\n\n");
        strcat(TempStr, "%s {FF4500}- {00FFFF}Otkljucan achievement {FFFFFF} | %s {FF4500}- {00FFFF}Zakljucan achievement");
        format(TempStr, sizeof TempStr, TempStr, (AInfo[targetid][Ach1] == 1) ? (complete) : (incomplete), (AInfo[targetid][Ach2] == 1) ? (complete) : (incomplete),
        (AInfo[targetid][Ach3] == 1) ? (complete) : (incomplete),(AInfo[targetid][Ach4] == 1) ? (complete) : (incomplete), GetPlayerNameF(targetid), targetid, AInfo[targetid][AchsCompleted], complete, incomplete);

        ShowPlayerDialog(playerid, DIALOG_ACH, DIALOG_STYLE_MSGBOX, "{54ff73}wldm {ffffff}achievementi", TempStr, "Uredu", "");
        return 1;
}
forward CheckAchievements(playerid);
public CheckAchievements(playerid)
{
        new rows, fields;
        cache_get_data(rows, fields, handler);
        if(rows)
        {
            cache_get_field_content(0, "Username", AInfo[playerid][Username], handler, 24);
            AInfo[playerid][Ach1] = cache_get_field_content_int(0, "Ach1", handler);
            AInfo[playerid][Ach2] = cache_get_field_content_int(0, "Ach2", handler);
            AInfo[playerid][Ach3] = cache_get_field_content_int(0, "Ach3", handler);
            AInfo[playerid][Ach4] = cache_get_field_content_int(0, "Ach4", handler);
            AInfo[playerid][AchsCompleted] = cache_get_field_content_int(0, "AchsCompleted", handler);
        }
        else
        {
            mysql_format(handler, gQuery, 256, "INSERT INTO `"WL_ACHIEVEMENTS"` (Username, Ach1, Ach2, Ach3, Ach4, AchsCompleted) VALUES ('%s', '0', '0', '0', '0', '0')", GetPlayerNameF(playerid));
            mysql_tquery(handler, gQuery, "", "");
        }
        return 1;
}

forward CheckAchs(playerid);
public CheckAchs(playerid)
{
	if(AInfo[playerid][Ach1] == 0)
	{
		if(AInfo[playerid][Ach1] == 1) return 1;
		if(GetPlayerMoney(playerid) >= 5000000)     // zavrsio
		{
		    static q[512];
			AInfo[playerid][Ach1] = 1;
			AInfo[playerid][AchsCompleted]++;
			SendClientMessageToAllF(0xA07BD4FF, "[ACHIEVEMENT] {ffffff}%s(%i) je otkljucao 'Millionare' achievement!", GetPlayerNameF(playerid), playerid);
			GivePlayerMoney(playerid, 200000), GivePlayerScore(playerid, 10);
			pInfo[playerid][Cash] += 200000;
			pInfo[playerid][Score] += 10;
			mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Score` = '%d' , `Cash` = '%d' WHERE `ID` = '%d'", pInfo[playerid][Score], pInfo[playerid][Cash], pInfo[playerid][ID]);
			mysql_tquery(handler, q);
/*			mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Cash` = '%d' WHERE `ID` = '%d'", pInfo[playerid][Cash], pInfo[playerid][ID]);
			mysql_tquery(handler, q);*/
			if(AInfo[playerid][AchsCompleted] >= 4)
			{
				GivePlayerMoney(playerid, 1000000), GivePlayerScore(playerid, 2500);
				pInfo[playerid][Score] += 2500;
				pInfo[playerid][Cash] += 1000000;
				mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Score` = '%d' , `Cash` = '%d' WHERE `ID` = '%d'", pInfo[playerid][Score], pInfo[playerid][Cash], pInfo[playerid][ID]);
				mysql_tquery(handler, q);
				SendClientMessageToAllF(0xA07BD4FF, "[ACHIEVEMENT] {ffffff}%s(%i) je otkljucao sve achievemente!", GetPlayerNameF(playerid), playerid);
				return 1;
			}
		}
	}
	if(AInfo[playerid][Ach2] == 0) // zavrsio
	{
		if(AInfo[playerid][Ach2] == 1) return 1;
		if(GetPlayerScore(playerid) >= 2500)
		{
		    static q[512];
			AInfo[playerid][Ach2] = 1;
			AInfo[playerid][AchsCompleted]++;
			SendClientMessageToAllF(0xA07BD4FF, "[ACHIEVEMENT] {ffffff}%s(%i) je otkljucao 'Score Whore' achievement!", GetPlayerNameF(playerid), playerid);
			GivePlayerMoney(playerid, 200000), GivePlayerScore(playerid, 10);
			pInfo[playerid][Cash] += 200000;
			pInfo[playerid][Score] += 10;
			mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Score` = '%d' , `Cash` = '%d' WHERE `ID` = '%d'", pInfo[playerid][Score], pInfo[playerid][Cash], pInfo[playerid][ID]);
			mysql_tquery(handler, q);
			if(AInfo[playerid][AchsCompleted] >= 4)
			{
				GivePlayerMoney(playerid, 1000000), GivePlayerScore(playerid, 2500);
				pInfo[playerid][Score] += 2500;
				pInfo[playerid][Cash] += 1000000;
				mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Score` = '%d' , `Cash` = '%d' WHERE `ID` = '%d'", pInfo[playerid][Score], pInfo[playerid][Cash], pInfo[playerid][ID]);
				mysql_tquery(handler, q);
				SendClientMessageToAllF(0xA07BD4FF, "[ACHIEVEMENT] {ffffff}%s(%i) je otkljucao sve achievemente!", GetPlayerNameF(playerid), playerid);
				return 1;
			}
		}
	}
	if(AInfo[playerid][Ach4] == 0)  // zavrsio
	{
		if(AInfo[playerid][Ach4] == 1) return 1;
		if(GetPlayerScore(playerid) >= 30)
		{
		    static q[512];
			AInfo[playerid][Ach4] = 1;
			AInfo[playerid][AchsCompleted]++;
			SendClientMessageToAllF(0xA07BD4FF, "[ACHIEVEMENT] {ffffff}%s(%i) je otkljucao 'First good score' achievement!", GetPlayerNameF(playerid), playerid);
			GivePlayerMoney(playerid, 200000), GivePlayerScore(playerid, 10);
			pInfo[playerid][Score] += 10;
			pInfo[playerid][Cash] += 200000;
			SetPlayerScore(playerid, pInfo[playerid][Score]);
			mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Score` = '%d' , `Cash` = '%d' WHERE `ID` = '%d'", pInfo[playerid][Score], pInfo[playerid][Cash], pInfo[playerid][ID]);
			mysql_tquery(handler, q);
			if(AInfo[playerid][AchsCompleted] >= 4)
			{
				GivePlayerMoney(playerid, 1000000), GivePlayerScore(playerid, 2500);
				pInfo[playerid][Score] += 2500;
				pInfo[playerid][Cash] += 1000000;
				mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Score` = '%d' , `Cash` = '%d' WHERE `ID` = '%d'", pInfo[playerid][Score], pInfo[playerid][Cash], pInfo[playerid][ID]);
				mysql_tquery(handler, q);
				SendClientMessageToAllF(0xA07BD4FF, "[ACHIEVEMENT] {ffffff}%s(%i) je otkljucao sve achievemente!", GetPlayerNameF(playerid), playerid);
				return 1;
			}
		}
	}
	if(AInfo[playerid][Ach3] == 0)
	{
		if(AInfo[playerid][Ach3] == 1) return 1;
		if(GetPlayerPing(playerid) >= 500)
		{
		    static q[512];
			AInfo[playerid][Ach3] = 1;
			AInfo[playerid][AchsCompleted]++;
			SendClientMessageToAllF(0xA07BD4FF, "[ACHIEVEMENT] {ffffff}%s(%i) je otkljucao 'Mother of Lag' achievement!", GetPlayerNameF(playerid), playerid);
			GivePlayerMoney(playerid, 200000), GivePlayerScore(playerid, 10);
			pInfo[playerid][Cash] += 200000;
			pInfo[playerid][Score] += 10;
			SetPlayerScore(playerid, pInfo[playerid][Score]);
			mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Score` = '%d' , `Cash` = '%d' WHERE `ID` = '%d'", pInfo[playerid][Score], pInfo[playerid][Cash], pInfo[playerid][ID]);
			mysql_tquery(handler, q);
			if(AInfo[playerid][AchsCompleted] >= 4)
			{
				GivePlayerMoney(playerid, 1000000), GivePlayerScore(playerid, 2500);
				pInfo[playerid][Score] += 2500;
				pInfo[playerid][Cash] += 1000000;
				mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Score` = '%d' , `Cash` = '%d' WHERE `ID` = '%d'", pInfo[playerid][Score], pInfo[playerid][Cash], pInfo[playerid][ID]);
				mysql_tquery(handler, q);
				SendClientMessageToAllF(0xA07BD4FF, "[ACHIEVEMENT] {ffffff}%s(%i) je otkljucao sve achievemente!", GetPlayerNameF(playerid), playerid);
				return 1;
			}
		}
	}
	return 1;
}

forward resetreport(playerid);
public resetreport(playerid)
{
	Server[playerid][Report] = 0;
	print("[REPORT]: VARIJABLA RESTARTOVANA");
	return 1;
}

forward realtimeupdate(playerid);
public realtimeupdate(playerid)
{
	new r_string[32], Float:hp, plrIP[16], Float:armor, sat, minut, sekund,
	dan, mjesec, godina;
	GetPlayerIp(playerid, plrIP, sizeof(plrIP));

 	format( r_string, sizeof( r_string ), "%s", GetPlayerNameF( playerid ));
    PlayerTextDrawSetString( playerid, wldm_PTD[ playerid ][ 17 ], r_string );
	
	format( r_string, sizeof( r_string ), "%s",plrIP);
    PlayerTextDrawSetString( playerid, wldm_PTD[ playerid ][ 18 ], r_string );

	format( r_string, sizeof( r_string ), "FPS:_%d",GetPlayerFPS( playerid ));
    PlayerTextDrawSetString( playerid, wldm_PTD[ playerid ][ 19 ], r_string );
    
    format( r_string, sizeof( r_string ), "Ping:_%d", GetPlayerPing( playerid ));
    PlayerTextDrawSetString( playerid, wldm_PTD[ playerid ][ 20 ], r_string );
    
    GetPlayerHealth(playerid, hp );
	format( r_string, sizeof( r_string ), "Health:_%.1f", hp);
    PlayerTextDrawSetString( playerid, wldm_PTD[ playerid ][ 25 ], r_string );

    GetPlayerArmour(playerid, armor );
	format( r_string, sizeof( r_string ), "Armour:_%.1f", armor);
    PlayerTextDrawSetString( playerid, wldm_PTD[ playerid ][ 26 ], r_string );    
    
    format( r_string, sizeof( r_string ), "player_id:_%d", playerid);
    PlayerTextDrawSetString( playerid, wldm_PTD[ playerid ][ 21 ], r_string );
    
    format( r_string, sizeof( r_string ), "kills:_%d", pInfo[playerid][Kills]);
    PlayerTextDrawSetString( playerid, wldm_PTD[ playerid ][ 23 ], r_string );

    format( r_string, sizeof( r_string ), "deaths:_%d", pInfo[playerid][Deaths]);
    PlayerTextDrawSetString( playerid, wldm_PTD[ playerid ][ 24 ], r_string );
    
    format( r_string, sizeof( r_string ), "packet_loss:_%.2f%", NetStats_PacketLossPercent( playerid ));
    PlayerTextDrawSetString( playerid, wldm_PTD[ playerid ][ 22 ], r_string );

	gettime(sat, minut, sekund);
    format( r_string, sizeof( r_string ), "%02d:%02d:%02d", sat, minut, sekund);
    PlayerTextDrawSetString( playerid, wldm_PTD[ playerid ][ 27 ], r_string );

    getdate(godina, mjesec, dan);
    format( r_string, sizeof( r_string ), "%02d/%02d/%02d", dan, mjesec, godina);
    PlayerTextDrawSetString( playerid, wldm_PTD[ playerid ][ 28 ], r_string );
   	foreach(Player,i) // muma ce me zaklat za ovo
	{
		AFKUpdate(i);
	}
}

Reset_pInfo_Vars(playerid)
{
    pInfo[playerid][ID] = 0;
    pInfo[playerid][Registered] = false;
    pInfo[playerid][Kills] = 0;
    pInfo[playerid][Deaths] = 0;
  	pInfo[playerid][Score] = 0;
    pInfo[playerid][Cash] = 0;
    pInfo[playerid][Skin] = 0;
    pInfo[playerid][Admin] = 0;
    pInfo[playerid][PasswordFails] = 0;
    pInfo[playerid][IsLogged] = false;
    dm_check[playerid] = 0;
    strmid(pInfo[playerid][Password], " ", 0, strlen(" "), 2);

    strmid(wl_duelinfo[playerid][playername], " ", 0, strlen(" "), 2);
    strmid(wl_duelinfo[playerid][weapname], " ", 0, strlen(" "), 2);

    wl_duelinfo[playerid][induel] = 0;
    wl_duelinfo[playerid][weapid] = 0;
    Server[playerid][InLobby] = 1;
    Server[playerid][InSpec] = 0;
}

StringNumeric(const str[])
{
    for(new i = 0, ii = strlen(str); i < ii; i++)
    {
        if(str[i] > '9' || str[i] < '0') return 0;
    }
    return 1;
}

CheckWeaponID(name[])
{
    for(new i = 0; i < 46; i++)
    {
        if(strfind(WeaponInfo[i][Name], name, true) != -1)
        {
            if(WeaponInfo[i][Valid] == 0) return -2;
            return i;
        }
    }
    return -1;
}

// --- > callbacks
public CheckPlayerAccount(playerid)
{
    new
		rows,
		fields,
		str[650];
		
	SetPlayerPos(playerid, 1981.3838, -1795.9895, 12.5471);
	InterpolateCameraPos(playerid, 1961.774780, -2059.125000, 18.602640, 1961.908569, -1762.566772, 16.725955, 15000);
	InterpolateCameraLookAt(playerid, 1961.926025, -2054.155029, 18.076572, 1961.796752, -1767.554199, 16.390571, 15000);
	
    cache_get_data(rows, fields, handler);

    if(!rows)
	{
		format(str, sizeof(str), "{FFFFFF}*** Dobrodosli {C680E7}(%s) {FFFFFF}na Wonderland Deathmatch ***\n\
									{FFFFFF}Trenutno se nalazite na registracijskom dijelu\n\
									{C680E7}(!) {FFFFFF}Server ne odgovara za vas account u slucaju kradje.\n\
									{C680E7}(!) {FFFFFF}Prije nego sto se registrujete morate da znate da je strogo zabranjeno koristenje\n\
									- cleo modova\n- asi fajlove\n- s0beita\n\
									{C680E7}- {FFFFFF}Svako krsenje pravila rezultuje banovanjem igraca sa servera.\n\
									{C680E7}- {FFFFFF}Svoje aktivnosti oko servera mozete pregledati preko Web/Mobile UCP panela {C680E7}(in dev)\n\
									{C680E7}[?] Ako ispunjavate ove uvjete molim vas unesite vas zeljeni password", GetPlayerNameF(playerid));

		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{C680E7}wldm {ffffff}- {C680E7}register", str, "Register", "Izlaz");
		str[0] = EOS;
    }
    else
	{
        cache_get_field_content(0, "Password", pInfo[playerid][Password], handler, 65);
        
		pInfo[playerid][ID] = 				cache_get_field_content_int(0, "ID");
		pInfo[playerid][Skin] = 			cache_get_field_content_int(0, "Skin");
		pInfo[playerid][Admin] = 			cache_get_field_content_int(0, "Admin");
		
		pInfo[playerid][Registered] = 		bool:cache_get_field_content_int(0, "Registered");

        if(pInfo[playerid][Registered])
		{
		    format(str, 512, "{FFFFFF}*** Dobrodosli nazad {C680E7}(%s) {FFFFFF}na Wonderland Deathmatch ***\n\
										{FFFFFF}Trenutno se nalazite na login dijelu.\n\
										{C680E7}- {FFFFFF}Svoje aktivnosti oko servera mozete pregledati preko Web/Mobile UCP panela {C680E7}(in dev).\n\
										{C680E7}- {FFFFFF}Zabranjeno je koristenje nedozvoljenih programa/skripti/asi fajlova.\n\
										{C680E7}- {FFFFFF}Svako krsenje pravila rezultuje banovanjem igraca sa servera.\n\
										{FFFFFF}Kako biste nastavili igru na serveru upisite vas password", GetPlayerNameF(playerid));
										
			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{C680E7}wldm {ffffff}- {C680E7}login", str, "Login", "Izlaz");
			str[0] = EOS;
		}
		else
		{
			format(str, sizeof(str), "{FFFFFF}*** Dobrodosli {C680E7}(%s) {FFFFFF}na Wonderland Deathmatch ***\n\
										{FFFFFF}Trenutno se nalazite na registracijskom dijelu\n\
										{C680E7}(!) {FFFFFF}Server ne odgovara za vas account u slucaju kradje.\n\
										{C680E7}(!) {FFFFFF}Prije nego sto se registrujete morate da znate da je strogo zabranjeno koristenje\n\
										- cleo modova\n- asi fajlove\n- s0beita\n\
										{C680E7}- {FFFFFF}Svako krsenje pravila rezultuje banovanjem igraca sa servera.\n\
										{C680E7}- {FFFFFF}Svoje aktivnosti oko servera mozete pregledati preko Web/Mobile UCP panela {C680E7}(in dev)\n\
										{C680E7}[?] Ako ispunjavate ove uvjete molim vas unesite vas zeljeni password", GetPlayerNameF(playerid));

			ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{C680E7}wldm {ffffff}- {C680E7}register", str, "Register", "Izlaz");
			str[0] = EOS;
		}
    }
	return 1;
}

forward PlayerBanCheck(playerid);
public PlayerBanCheck(playerid)
{
	new rows = cache_num_rows();
	if(rows != 0)
	{
	    new player_name[24], adminid[24], reasonban[200], bdate[50];
	    cache_get_field_content(0, "name", player_name);
	    cache_get_field_content(0, "adminbanned", adminid);
	    cache_get_field_content(0, "BanDate", bdate);
	    cache_get_field_content(0, "reason", reasonban);
	    cache_get_field_content(0, "reason", reasonban);
	    new line[300];
		format(line, sizeof(line), "{FF0000}BANOVANI STE\n\n{FFFFFF}-Nick: %s\nAdmin: %s\nBanovani ste sa servera zbog: %s\nDatum bana: %s\n\n\
									Ako mislite da je ovo neka greska\nObratite se na nas forum\nwww.wl-community.xyz/dm/forum", player_name, adminid, reasonban, bdate);
		ShowPlayerDialog(playerid, DIALOG_BANNED, DIALOG_STYLE_MSGBOX, "BANOVANI STE", line, "Exit", "");
   		SetTimerEx("KickEx", 2000, false, "d", playerid);
	}
	else
	{
	    static query[200];
		mysql_format(handler, query, sizeof(query), "SELECT `ID`, `Registered`, `Password`, `Skin`, `Admin` FROM `players` WHERE `Name` = '%s' LIMIT 1", GetPlayerNameF(playerid));
		mysql_pquery(handler, query, "CheckPlayerAccount", "i", playerid);
/*	    new query[200];
		mysql_format(handler, query, sizeof(query), "SELECT * FROM `Users` WHERE `name` = '%e'", GetPlayerNameF(playerid));
        mysql_tquery(handler, query, "AccountExist", "d", playerid);*/
	}
	return 1;
}

public OnPlayerRegister(playerid)
{
    new q[256];
	GetPlayerIp(playerid, q, 22);
	mysql_format(handler, q, sizeof(q), "INSERT INTO `players` (Name, Password, Registered, IsLogged, Skin, IP, RegDate, LastLogin) VALUES('%e', '%s', '1', '1', '%d', '%s', NOW(), NOW())", GetPlayerNameF(playerid), pInfo[playerid][Password], pInfo[playerid][Skin], q);
	mysql_pquery(handler, q, "OnPlayerRegistered", "i", playerid);

	q[0] = EOS;
	return 1;
}

public OnPlayerRegistered(playerid)
{
	pInfo[playerid][ID] = cache_insert_id();
	
	SpawnFookinPlayer(playerid);
	return 1;
}

public OnAccountLoad(playerid)
{
    pInfo[playerid][Kills] = 			cache_get_field_content_int(0, "Kills");
    pInfo[playerid][Deaths] = 			cache_get_field_content_int(0, "Deaths");
    pInfo[playerid][Score] = 			cache_get_field_content_int(0, "Score");
    pInfo[playerid][Cash] = 			cache_get_field_content_int(0, "Cash");
    pInfo[playerid][Admin] = 			cache_get_field_content_int(0, "Admin");

    SpawnFookinPlayer(playerid);
	return 1;
}

public KickEx(playerid)
{
	return Kick(playerid);
}

// --- > natives
public OnGameModeInit()
{
    SetCbugAllowed(false);
    if(mysql_errno())
	{
	    SendRconCommand("hostname "WL_NAME" | *error*");
	    SetGameModeText("wonderland dm | *error*");
	}
	SetGameModeText("wonderland dm | "WL_VER"");
	SendRconCommand(MAP_NAME);
	print("-> MAP_NAME");
	SendRconCommand(WL_LINK);
	print("-> WL_LINK");
	SendRconCommand(WL_NAME);
	print("-> WL_NAME");
	SendRconCommand(WL_LANGUAGE);
	print("-> WL_LANGUAGE");
	SetNameTagDrawDistance(NAME_DD);
	DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);
    ManualVehicleEngineAndLights();
    ShowPlayerMarkers(0);
    CreateServerMaps();
    wl_sql_connect();
    #if MYSQL_STATE == 1
		mysql_log(LOG_ALL);
	#else
		mysql_log(LOG_ERROR | LOG_WARNING);
    #endif
    for(new playerid; playerid < MAX_PLAYERS; playerid++) {
    AFKLabel[playerid] = Create3DTextLabel(" ",0x000000,0.0,0.0,0.0,LABEL_DRAW_DISTANCE,0,1); }
    mysql_tquery(handler, "CREATE TABLE IF NOT EXISTS `"WL_ACHIEVEMENTS"` (" \
                            "`Username` varchar(24) NOT NULL," \
                            "`Ach1` int(5) NOT NULL," \
                            "`Ach2` int(5) NOT NULL," \
                            "`Ach3` int(5) NOT NULL," \
                            "`Ach4` int(5) NOT NULL," \
                            "`AchsCompleted` int(5) NOT NULL," \
                            "PRIMARY KEY (`Username`)" \
                            ") ENGINE=InnoDB DEFAULT CHARSET=latin1;");
    mysql_tquery(handler, "UPDATE `players` SET `IsLogged` = '0'");
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
    	if(IsPlayerConnected(i))
    	{
		    AInfo[i][Ach1] = 0, AInfo[i][Ach2] = 0, AInfo[i][Ach3] = 0, AInfo[i][Ach4] = 0, AInfo[i][AchsCompleted] = 0;
		    mysql_format(handler, gQuery, 256, "SELECT * FROM `"WL_ACHIEVEMENTS"` WHERE Username = '%s' LIMIT 1", GetPlayerNameF(i));
		    mysql_tquery(handler, gQuery, "CheckAchievements", "i", i);
	    }
    }
   	dm_ghosttown = 0,  dm_interior = 0,	dm_policedep = 0, dm_warehouse = 0, dm_fysnow = 0;
    // ---> 3DText
    CreateDynamic3DTextLabel("{C680E7}: {ffffff}Wonderland Deathmatch {C680E7}:\n: Build: {FFFFFF}"WL_VER" {C680E7}:", 0xFFFFFFFF, 2780.7632,-72.7295,1318.8390, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
    CreateDynamic3DTextLabel("{fc0356}[ DEVELOPER ]\n{FFFFFF}Momenzi", 0xFFFFFFFF, 2777.8865,-84.2958,1318.8390, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
    CreateDynamic3DTextLabel("{03a1fc}[ BETA TESTER ]\n{FFFFFF}.mumitza", 0xFFFFFFFF, 2779.7866,-83.4717,1319.8390, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
    CreateDynamic3DTextLabel("{77fc03}[ FIRST MEMBER ]\n{FFFFFF}Kingston", 0xFFFFFFFF, 2776.1475,-83.4782,1319.8390, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
    CreateDynamic3DTextLabel("{C680E7}: {ffffff}Thanks to {C680E7}:\n{C680E7}- {ffffff}.mumitza\n{C680E7}- {ffffff}Danijel Saco\n{C680E7}- {ffffff}Kristijan Crowley\n{C680E7}- {ffffff}.nwn\n\
							  {C680E7}- {ffffff}Milo Djukanovic\n{C680E7}- {ffffff}File Hernandes\n{C680E7}- {ffffff}Jason Remington\n{C680E7}- {ffffff}Gimmyxaz Lehasyezz\n\
							  {C680E7}- {ffffff}Edvin Castellano\n{C680E7}- {ffffff}Jason Castellano\n{C680E7}- {ffffff}Ana Escobar\n{C680E7}- {ffffff}Noke Mercedes", 0xFFFFFFFF,2776.3611,-68.3659,1318.8390, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 10.0);
	// --- > Actori
	actor[0] = CreateActor(189, 2777.8865, -84.2958, 1318.8390, 354.0705); SetActorVirtualWorld(actor[0], 200); // Momenzi
	actor[1] = CreateActor(124, 2779.7866,-83.4717,1318.8390, 357.2271); SetActorVirtualWorld(actor[1], 200); // Muma
	actor[2] = CreateActor(294, 2776.1475,-83.4782,1318.8390, 0); SetActorVirtualWorld(actor[2], 200);
	actor[3] = CreateActor(194, 1214.6742,-15.2606,1000.9219, 0); SetActorVirtualWorld(actor[3], 200);
	ApplyActorAnimation(actor[0], "PED","SEAT_IDLE",4.0, 1, 0, 0, 0, 0); ApplyActorAnimation(actor[1], "DEALER", "DEALER_IDLE", 4.0, 1, 0, 0, 0, 0);
	ApplyActorAnimation(actor[2], "DEALER", "DEALER_IDLE", 4.0, 1, 0, 0, 0, 0);
	return 1;
}

public OnGameModeExit()
{
	dm_ghosttown = 0, dm_interior = 0, dm_policedep = 0, dm_warehouse = 0, dm_fysnow = 0;
	foreach(Player,i)
	{
		Delete3DTextLabel(AFKLabel[i]);
	}
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			mysql_format(handler, gQuery, 256, "UPDATE `"WL_ACHIEVEMENTS"` SET Ach1 = '%i', Ach2 = '%i', Ach3 = '%i', Ach4 = '%i', AchsCompleted = '%i' WHERE Username = '%s'",
			AInfo[i][Ach1], AInfo[i][Ach2], AInfo[i][Ach3], AInfo[i][Ach4], AInfo[i][AchsCompleted], GetPlayerNameF(i));
			mysql_tquery(handler, gQuery, "", "");
			AInfo[i][Ach1] = 0, AInfo[i][Ach2] = 0, AInfo[i][Ach3] = 0, AInfo[i][Ach4] = 0, AInfo[i][AchsCompleted] = 0;
		}
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	// ---> removebuildingforplayer
	RemoveBuildingForPlayer(playerid, 2744, 1721.6172, -1655.6641, 21.6641, 0.25);
	// ---> resetvars
	Reset_pInfo_Vars(playerid);
	//AInfo[playerid][Ach1] = 0, AInfo[playerid][Ach2] = 0, AInfo[playerid][Ach3] = 0, AInfo[playerid][Ach4] = 0, AInfo[playerid][AchsCompleted] = 0;
	// ---> private message
	pInfo[playerid][Last] = -1;
	pInfo[playerid][NoPM] = 0;
	pInfo[playerid][readpm] = -1;
 	Server[playerid][ShowedTextdraw] = 0;
 	Server[playerid][Report] = 0;
 	Server[playerid][ShotDebug] = 0;
 	Server[playerid][AllowCheck] = 1;
	// ---> textdraw
	if(Server[playerid][ShowedTextdraw] == 1) { CreatePlayerWLTextdraw(playerid, false); }
	// ---> duel
	strmid(wl_duelinfo[playerid][playername], GetPlayerNameF(playerid), 0, strlen(GetPlayerNameF(playerid)), 25);
	// ---> register
	static query[200];
	mysql_format(handler, query, sizeof(query), "SELECT * FROM `ServerBans` WHERE `name` = '%e';",GetPlayerNameF(playerid));
	mysql_tquery(handler, query, "PlayerBanCheck", "d", playerid);
	query[0] = EOS;
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	ClearAnimations(playerid);
//	CheckAchs(playerid); CheckAchs(killerid);
	SendDeathMessage(killerid, playerid, reason);
 	Server[playerid][InLobby] = 1;
 	Server[playerid][InSpec] = 0;
  	Server[playerid][ShowedTextdraw] = 0;
    new objectid = CreateObject(18668, 0.0, 0.0, -10.0, 0.0, 0.0, 0.0);
    AttachObjectToPlayer(objectid, playerid, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    SetTimerEx("DeleteEffect", 2500, 0, "i", objectid);
	for( new i = 0; i < 20; i ++)
	{
	    PlayerTextDrawHide(playerid, wldm_PTD[playerid][i]);
		PlayerTextDrawDestroy(playerid, wldm_PTD[playerid][i]);
		wldm_PTD[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
	}
  	CreatePlayerWLTextdraw(playerid, false);
	if(Server[playerid][ShowedTextdraw] == 1) { CreatePlayerWLTextdraw(playerid, false); }
	SetPlayerSkin(playerid, pInfo[playerid][Skin]);
	if(wl_duelinfo[killerid][induel] == 1 && wl_duelinfo[playerid][induel] == 1)
	{
		wl_duelinfo[killerid][induel] = 0;
		wl_duelinfo[playerid][induel] = 0;

		SetPlayerInterior(playerid, 2);
		SetPlayerVirtualWorld(playerid, 200);
		SetPlayerHealth(playerid, 100);
		SetPlayerPos(playerid, 2778.1702,-66.8400,1318.8390);

		SetPlayerInterior(playerid, 2);
		SetPlayerVirtualWorld(playerid, 200);
		SetPlayerInterior(killerid, 2);
		SetPlayerVirtualWorld(killerid, 200);
		SetPlayerHealth(killerid, 100);
		SetPlayerPos(killerid, 2778.1702,-66.8400,1318.8390);

		static q[96];

		pInfo[killerid][Score]++;
		printf("killerid score = %d", pInfo[killerid][Score]);
		SetPlayerScore(killerid, pInfo[killerid][Score]);
		mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Score` = '%d' WHERE `ID` = '%d'", pInfo[killerid][Score], pInfo[killerid][ID]);
		mysql_tquery(handler, q);

		pInfo[playerid][Score]++;
		printf("playerid score = %d", pInfo[playerid][Score]);
		SetPlayerScore(playerid, pInfo[playerid][Score]);
    	mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Score` = '%d' WHERE `ID` = '%d'", pInfo[playerid][Score], pInfo[playerid][ID]);
		mysql_tquery(handler, q);

		new Float:health = GetPlayerHealth(killerid, health);
		SendClientMessageToAllF(-1, "{C680E7}(duel) {ffffff}%s(%d) je pobjedio igraca %s(%d) u duelu (%.2f)", wl_duelinfo[killerid][playername], killerid, wl_duelinfo[playerid][playername], playerid, health);

		q[0] = EOS;
		ResetPlayerWeapons(killerid);
		ResetPlayerWeapons(playerid);
	}
	if(killerid != INVALID_PLAYER_ID)
	{
	    if(dm_check[playerid] != 0)
	    {
    		for(new i = 0; i <= GetPlayerPoolSize(); i++)
	       	{
	        	new string[65];
	       	    if(dm_check[i] == 1)
	       	    {
	       	        format(string, sizeof(string), "{3da6a6}[DM-1] {FFFFFF}%s je ubio %s.", GetPlayerNameF(killerid), GetPlayerNameF(playerid));
	       	        SendClientMessage(i, -1, string);
	       	    }
	       	    else if(dm_check[i] == 2)
	       	    {
	       	        format(string, sizeof(string), "{3d59a6}[DM-2] {FFFFFF} %s je ubio %s.", GetPlayerNameF(killerid), GetPlayerNameF(playerid));
	       	        SendClientMessage(i, -1, string);
	       	    }
	       	    else if(dm_check[i] == 3)
	       	    {
	       	        format(string, sizeof(string), "{7e3da6}[DM-3] {FFFFFF}%s je ubio %s.", GetPlayerNameF(killerid), GetPlayerNameF(playerid));
	       	        SendClientMessage(i, -1, string);
	       	    }
	       	    else if(dm_check[i] == 4)
	       	    {
	       	        format(string, sizeof(string), "{8ca63d}[DM-4] {FFFFFF}%s je ubio %s.", GetPlayerNameF(killerid), GetPlayerNameF(playerid));
	       	        SendClientMessage(i, -1, string);
	       	    }
	       	    else if(dm_check[i] == 5)
	       	    {
	       	        format(string, sizeof(string), "{fcba03}[DM-5] {FFFFFF}%s je ubio %s.", GetPlayerNameF(killerid), GetPlayerNameF(playerid));
	       	        SendClientMessage(i, -1, string);
	       	    }
	       	}
	    }
   		static q[288];
	    pInfo[killerid][Kills]++;
   		mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Kills` = '%d' WHERE `ID` = '%d'", pInfo[killerid][Kills], pInfo[killerid][ID]);
		mysql_tquery(handler, q);
	    pInfo[playerid][Deaths]++;
   		mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Deaths` = '%d' WHERE `ID` = '%d'", pInfo[playerid][Deaths], pInfo[playerid][ID]);
		mysql_tquery(handler, q);
		pInfo[killerid][Score]++;
		SetPlayerScore(killerid, pInfo[killerid][Score]);
		mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Score` = '%d' WHERE `ID` = '%d'", pInfo[killerid][Score], pInfo[killerid][ID]);
		mysql_tquery(handler, q);
		for(new i = 0; i <= GetPlayerPoolSize(); i++)
		{
		    if(pInfo[i][Admin] > 0) SendDeathMessageToPlayer(i, killerid, playerid, reason);
		}
	}
	killerid = INVALID_PLAYER_ID;
	return 1;
}

forward DeleteEffect(objectid);
public DeleteEffect(objectid)
{
	return DestroyObject(objectid);
}

public OnPlayerDisconnect(playerid, reason)
{
	if(Reconnecting[playerid] == true) {
	new string[64];
	format(string, sizeof(string), "unbanip %s", ReconnectIP[playerid]);
	SendRconCommand(string);
 	Reconnecting[playerid] = false; }
	pInfo[playerid][Last] = -1;
	pInfo[playerid][NoPM] = 0;
	pInfo[playerid][readpm] = -1;
	mysql_format(handler, gQuery, 256, "UPDATE `"WL_ACHIEVEMENTS"` SET Ach1 = '%i', Ach2 = '%i', Ach3 = '%i', Ach4 = '%i', AchsCompleted = '%i' WHERE Username = '%s'",
	AInfo[playerid][Ach1], AInfo[playerid][Ach2], AInfo[playerid][Ach3], AInfo[playerid][Ach4], AInfo[playerid][AchsCompleted], GetPlayerNameF(playerid));
	mysql_tquery(handler, gQuery, "", "");
	//AInfo[playerid][Ach1] = 0, AInfo[playerid][Ach2] = 0, AInfo[playerid][Ach3] = 0, AInfo[playerid][Ach4] = 0, AInfo[playerid][AchsCompleted] = 0;
	if(dm_check[playerid] == 1) dm_ghosttown--;
	else if(dm_check[playerid] == 2) dm_interior--;
	else if(dm_check[playerid] == 3) dm_policedep--;
 	else if(dm_check[playerid] == 4) dm_warehouse--;
 	else if(dm_check[playerid] == 5) dm_fysnow--;
	static q[96];
	mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `IsLogged` = '0' WHERE `ID` = '%d'", pInfo[playerid][ID]);
	mysql_tquery(handler, q);
	
    Reset_pInfo_Vars(playerid);
    
    q[0] = EOS;
	return 1;
}

public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    if(!IsPlayerConnected(playerid) || !pInfo[playerid][IsLogged])
	{
		SendClientMessage(playerid, 0xFF0000AA, "[ERROR]: {FFFFFF}Niste ulogovani.");
		return 0;
	}
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
    if(!IsPlayerConnected(playerid) || !pInfo[playerid][IsLogged])
	{
		SendClientMessage(playerid, 0xFF0000AA, "[ERROR]: {FFFFFF}Niste ulogovani.");
	    return 0;
	}

	if(result == -1)
	{
		SendClientMessageF(playerid, 0x72DBDBFF, "[CMD]: {FFFFFF}Upisali ste komandu ({72DBDB}'%s'{FFFFFF}) koja ne postoji u nasoj skripti.", cmd);
		return 0;
	}
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
    if(pInfo[playerid][IsLogged])
	{
		SpawnFookinPlayer(playerid);
	}
    else
	{
		return 0;
	}
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(pInfo[playerid][IsLogged])
	{
		SpawnFookinPlayer(playerid);
	}
    else
	{
		return 0;
	}
	return 1;
}

AFKUpdate(playerid)
{
	new string[128];
	if(GetTickCount() > (GetPVarInt(playerid,"LastUpdate") + 1000) && GetPlayerState(playerid) != PLAYER_STATE_PASSENGER)
	{
		playerupdate[playerid]++;
		if(playerupdate[playerid] > 60)
		{
			new mins,secs;
			mins = playerupdate[playerid] / 60;
			secs = playerupdate[playerid] - (mins * 60);
			if(mins == 1) format(string,sizeof(string),"{ffc233}[ AFK ]\n{ffffff}[%d min %d sec]",mins,secs);
			else format(string,sizeof(string),"{ffc233}[ AFK ]\n{ffffff}[%d min %d sec]",mins,secs);
		}
		else format(string,sizeof(string),"{ffc233}[ AFK ]\n{ffffff}[%d sec]",playerupdate[playerid]);
		Update3DTextLabelText(AFKLabel[playerid], 0x00CDFFFF, string);
	}
	else if(playerupdate[playerid] >= MAX_AFK_TIME*60)
	{
		format(string,sizeof(string),"[ANTI-AFK] {ffffff}Igrac %s je kickovan. [%d min]",GetPlayerNameF(playerid),MAX_AFK_TIME);
		SendClientMessageToAll(0xC680E7FF,string);
		Kick(playerid);
	}
	else
	{
		Update3DTextLabelText(AFKLabel[playerid],0x00000000," ");
	}
}

public OnPlayerSpawn(playerid)
{
    Attach3DTextLabelToPlayer(AFKLabel[playerid], playerid, 0.0, 0.0, 1.0);
    Server[playerid][ShowedTextdraw] = 1;
    Server[playerid][AllowCheck] = 0;
    mysql_format(handler, gQuery, 256, "SELECT * FROM `"WL_ACHIEVEMENTS"` WHERE Username = '%s' LIMIT 1", GetPlayerNameF(playerid));
	mysql_tquery(handler, gQuery, "CheckAchievements", "i", playerid);
	if(Server[playerid][ShowedTextdraw] == 1) { CreatePlayerWLTextdraw(playerid, true); }
	if(!pInfo[playerid][IsLogged] && Server[playerid][InLobby] == 1 && dm_check[playerid] == 0)
	{
		pInfo[playerid][IsLogged] = true;
		static q[96];
		mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `IsLogged` = '1' WHERE `ID` = '%d'", pInfo[playerid][ID]);
		mysql_tquery(handler, q);
		
		SetPlayerScore(playerid, pInfo[playerid][Score]);
		SetPlayerMoney(playerid, pInfo[playerid][Cash]);
		ObrisiChat(playerid, 20);
		SetPlayerInterior(playerid, 2);
		SetPlayerVirtualWorld(playerid, 200);
		SetPlayerColor(playerid, 0xFFFFFFFF);
		
		ServerTimer[0] = SetPlayerTimerEx(playerid, "realtimeupdate", 1000, true, "i", playerid);
		SendClientMessageF(playerid, 0xC680E7FF, "[WBOT] {ffffff}Vas account ({C680E7}%s{ffffff}) je upravo online.", GetPlayerNameF(playerid));
		q[0] = EOS;
	}
	if(dm_check[playerid] == 1)
	{
	    SetPlayerWorldBounds(playerid, -337.0134, -471.5814, 2312.5422, 2174.7092);
		new rokovniktonisamcitao = random(sizeof(RandomPosDM_1));
		SetPlayerPos(playerid, RandomPosDM_1[rokovniktonisamcitao][0], RandomPosDM_1[rokovniktonisamcitao][1], RandomPosDM_1[rokovniktonisamcitao][2]);
		SetPlayerVirtualWorld(playerid, 5);
		SetPlayerInterior(playerid, 0);
		ResetPlayerWeapons(playerid);
		GivePlayerWeapon(playerid, 24, 500);
		GivePlayerWeapon(playerid, 34, 500);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 100);
		Server[playerid][InLobby] = 0;
		Server[playerid][InSpec] = 0;
  		Server[playerid][ShowedTextdraw] = 1;
	}
	else if(dm_check[playerid] == 2)
	{
	    SetPlayerWorldBounds(playerid,20000.0000,-20000.0000,20000.0000,-20000.0000);
		new rokovniktonisamcitao = random(sizeof(RandomPosDM_2));
		SetPlayerPos(playerid, RandomPosDM_2[rokovniktonisamcitao][0], RandomPosDM_2[rokovniktonisamcitao][1], RandomPosDM_2[rokovniktonisamcitao][2]);
		SetPlayerVirtualWorld(playerid, 10);
		SetPlayerInterior(playerid, 10);
		ResetPlayerWeapons(playerid);
		GivePlayerWeapon(playerid, 24, 500);
		GivePlayerWeapon(playerid, 25, 500);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 100);
		Server[playerid][InLobby] = 0;
		Server[playerid][InSpec] = 0;
		Server[playerid][ShowedTextdraw] = 1;
	}
	else if(dm_check[playerid] == 3)
	{
		new rokovniktonisamcitao = random(sizeof(RandomPosDM_3));
		SetPlayerPos(playerid, RandomPosDM_3[rokovniktonisamcitao][0], RandomPosDM_3[rokovniktonisamcitao][1], RandomPosDM_3[rokovniktonisamcitao][2]);
		SetPlayerVirtualWorld(playerid, 15);
		SetPlayerInterior(playerid, 3);
		ResetPlayerWeapons(playerid);
		GivePlayerWeapon(playerid, 24, 500);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 100);
		Server[playerid][InLobby] = 0;
		Server[playerid][InSpec] = 0;
		Server[playerid][ShowedTextdraw] = 1;
	}
	else if(dm_check[playerid] == 4)
	{
	    SetPlayerWorldBounds(playerid,20000.0000,-20000.0000,20000.0000,-20000.0000);
		new rokovniktonisamcitao = random(sizeof(RandomPosDM_4));
		SetPlayerPos(playerid, RandomPosDM_4[rokovniktonisamcitao][0], RandomPosDM_4[rokovniktonisamcitao][1], RandomPosDM_4[rokovniktonisamcitao][2]);
		SetPlayerVirtualWorld(playerid, 20);
		SetPlayerInterior(playerid, 0);
		ResetPlayerWeapons(playerid);
		GivePlayerWeapon(playerid, 24, 500);
		GivePlayerWeapon(playerid, 34, 200);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 100);
		Server[playerid][InLobby] = 0;
		Server[playerid][InSpec] = 0;
		Server[playerid][ShowedTextdraw] = 1;
	}
	else if(dm_check[playerid] == 5)
	{
	    SetPlayerWorldBounds(playerid,20000.0000,-20000.0000,20000.0000,-20000.0000);
		new rokovniktonisamcitao = random(sizeof(RandomPosDM_5));
		SetPlayerPos(playerid, RandomPosDM_5[rokovniktonisamcitao][0], RandomPosDM_5[rokovniktonisamcitao][1], RandomPosDM_5[rokovniktonisamcitao][2]);
		SetPlayerVirtualWorld(playerid, 20);
		SetPlayerInterior(playerid, 0);
		ResetPlayerWeapons(playerid);
		GivePlayerWeapon(playerid, 24, 500);
		GivePlayerWeapon(playerid, 34, 200);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid, 100);
		Server[playerid][InLobby] = 0;
		Server[playerid][InSpec] = 0;
		Server[playerid][ShowedTextdraw] = 1;
	}
	return 1;
}

public OnPlayerDamage(&playerid, &Float:amount, &issuerid, &weapon, &bodypart)
{
	if(Server[playerid][InLobby] == 1) return 0;
	if(Server[playerid][InSpec] == 1) return 0;
	CheckAchs(playerid); CheckAchs(issuerid);
	return 1;
}

public OnPlayerUpdate(playerid)
{
	SetPVarInt(playerid,"LastUpdate",GetTickCount());
	playerupdate[playerid] = 0;
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(!pInfo[playerid][IsLogged]) return 1;
	if(Server[playerid][InSpec] == 1) return 1;
	foreach(new i : Player)
 	{
  		if(GetPlayerVirtualWorld(i))
    	{
    	    if(Server[i][InLobby] == 1)
    	    {
    	        if(strfind(text, "pivosepenijebesemeni", true) != -1) { SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Pije se i meni"); return 0; }
	   			SendClientMessageF(i, 0x7E9DDEFF, "(lobby) {FFFFFF}%s[%d]: %s", GetPlayerNameF(playerid), playerid, text);
   				printf("[LOBBY - CHAT] %s[%d]: %s", GetPlayerNameF(playerid), playerid, text);
   			}
		}
	}
	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case DIALOG_REGISTER:
		{
		    if(!response)
			{
				Kick(playerid);
				return 1;
			}
			else
			{
				if(strlen(inputtext) < 6 || strlen(inputtext) > 20)
				{
				    new str[650];
			    	format(str, sizeof(str), "{FFFFFF}*** Dobrodosli {C680E7}(%s) {FFFFFF}na Wonderland Deathmatch ***\n\
										{FFFFFF}Trenutno se nalazite na registracijskom dijelu\n\
										{C680E7}(!) {FFFFFF}Server ne odgovara za vas account u slucaju kradje.\n\
										{C680E7}(!) {FFFFFF}Prije nego sto se registrujete morate da znate da je strogo zabranjeno koristenje\n\
										- cleo modova\n- asi fajlove\n- s0beita\n\
										{C680E7}- {FFFFFF}Svako krsenje pravila rezultuje banovanjem igraca sa servera.\n\
										{C680E7}- {FFFFFF}Svoje aktivnosti oko servera mozete pregledati preko Web/Mobile UCP panela {C680E7}(in dev)\n\
										{C680E7}[?] Ako ispunjavate ove uvjete molim vas unesite vas zeljeni password", GetPlayerNameF(playerid));

					ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{C680E7}wldm {ffffff}- {C680E7}register", str, "Register", "Izlaz");
					str[0] = EOS;
					return 1;
				}
				else
				{
	                strmid(pInfo[playerid][Password], inputtext, 0, strlen(inputtext), 65);
	                pInfo[playerid][Skin] = random(311)+1;
	                
	                OnPlayerRegister(playerid); 
		    	}
			}
		}
		case DIALOG_DM:
		{
		    if(!response) return 1;
  			switch(listitem)
	    	{
	        	case 0:
	        	{
	         		if(dm_check[playerid] == 1) return SendClientMessage(playerid,0xFF0000FF,"[ERROR]: {FFFFFF}Vec ste nalazite u toj dm zoni.");
	               	else if(dm_check[playerid] == 2) dm_interior--;
	           	  	else if(dm_check[playerid] == 3) dm_policedep--;
	           	  	else if(dm_check[playerid] == 4) dm_warehouse--;
	           	  	else if(dm_check[playerid] == 5) dm_fysnow--;
		            dm_check[playerid] = 1;
		            dm_ghosttown++;
		            // -- //
		            SetPlayerWorldBounds(playerid, -337.0134, -471.5814, 2312.5422, 2174.7092);
		            new rokovniktonisamcitao = random(sizeof(RandomPosDM_1));
		            SetPlayerPos(playerid, RandomPosDM_1[rokovniktonisamcitao][0], RandomPosDM_1[rokovniktonisamcitao][1], RandomPosDM_1[rokovniktonisamcitao][2]);
		            SetPlayerVirtualWorld(playerid, 5);
		            SetPlayerInterior(playerid, 0);
		            ResetPlayerWeapons(playerid);
		            GivePlayerWeapon(playerid, 24, 500);
		            GivePlayerWeapon(playerid, 34, 500);
		            SetPlayerHealth(playerid, 100);
		            SetPlayerArmour(playerid, 100);
		            Server[playerid][InLobby] = 0;
		            Server[playerid][InSpec] = 0;
		        }
		        case 1:
		        {
	         		if(dm_check[playerid] == 1) dm_ghosttown--;
		            else if(dm_check[playerid] == 2) return SendClientMessage(playerid,0xFF0000FF,"[ERROR]: {FFFFFF}Vec ste nalazite u toj dm zoni.");
		            else if(dm_check[playerid] == 3) dm_policedep--;
		            else if(dm_check[playerid] == 4) dm_warehouse--;
		            else if(dm_check[playerid] == 5) dm_fysnow--;
					dm_check[playerid] = 2;
					dm_interior++;
		            // -- //
		            new rokovniktonisamcitao = random(sizeof(RandomPosDM_2));
		            SetPlayerPos(playerid, RandomPosDM_2[rokovniktonisamcitao][0], RandomPosDM_2[rokovniktonisamcitao][1], RandomPosDM_2[rokovniktonisamcitao][2]);
		            SetPlayerVirtualWorld(playerid, 10);
		            SetPlayerInterior(playerid, 10);
		            ResetPlayerWeapons(playerid);
		            GivePlayerWeapon(playerid, 24, 500);
		            GivePlayerWeapon(playerid, 25, 500);
		            SetPlayerHealth(playerid, 100);
		            SetPlayerArmour(playerid, 100);
		            Server[playerid][InLobby] = 0;
		            Server[playerid][InSpec] = 0;
		            SetPlayerWorldBounds(playerid,20000.0000,-20000.0000,20000.0000,-20000.0000);
		        }
		        case 2:
		        {
		            if(dm_check[playerid] == 1) dm_ghosttown--;
	             	else if(dm_check[playerid] == 2) dm_interior--;
	              	else if(dm_check[playerid] == 3) return SendClientMessage(playerid,0xFF0000FF,"[ERROR]: {FFFFFF}Vec ste nalazite u toj dm zoni.");
	              	else if(dm_check[playerid] == 4) dm_warehouse--;
	              	else if(dm_check[playerid] == 5) dm_fysnow--;
	             	dm_policedep++;
	             	dm_check[playerid] = 3;
		            // -- //
		            new rokovniktonisamcitao = random(sizeof(RandomPosDM_1));
		            SetPlayerPos(playerid, RandomPosDM_3[rokovniktonisamcitao][0], RandomPosDM_3[rokovniktonisamcitao][1], RandomPosDM_3[rokovniktonisamcitao][2]);
		            SetPlayerVirtualWorld(playerid, 15);
		            SetPlayerInterior(playerid, 3);
		            ResetPlayerWeapons(playerid);
		            GivePlayerWeapon(playerid, 24, 500);
		            SetPlayerHealth(playerid, 100);
		            SetPlayerArmour(playerid, 100);
		            Server[playerid][InLobby] = 0;
		            Server[playerid][InSpec] = 0;
		            SetPlayerWorldBounds(playerid,20000.0000,-20000.0000,20000.0000,-20000.0000);
		        }
		        case 3:
		        {
		            if(dm_check[playerid] == 1) dm_ghosttown--;
	             	else if(dm_check[playerid] == 2) dm_interior--;
	              	else if(dm_check[playerid] == 3) dm_policedep--;
	              	else if(dm_check[playerid] == 4) return SendClientMessage(playerid,0xFF0000FF,"[ERROR]: {FFFFFF}Vec ste nalazite u toj dm zoni.");
	              	else if(dm_check[playerid] == 5) dm_fysnow--;
	             	dm_warehouse++;
	             	dm_check[playerid] = 4;
		            // -- //
		            new rokovniktonisamcitao = random(sizeof(RandomPosDM_4));
		            SetPlayerPos(playerid, RandomPosDM_4[rokovniktonisamcitao][0], RandomPosDM_4[rokovniktonisamcitao][1], RandomPosDM_4[rokovniktonisamcitao][2]);
		            SetPlayerVirtualWorld(playerid, 20);
		            SetPlayerInterior(playerid, 0);
		            ResetPlayerWeapons(playerid);
		            GivePlayerWeapon(playerid, 24, 500);
		            GivePlayerWeapon(playerid, 34, 200);
		            SetPlayerHealth(playerid, 100);
		            SetPlayerArmour(playerid, 100);
		            Server[playerid][InLobby] = 0;
		            Server[playerid][InSpec] = 0;
		            SetPlayerWorldBounds(playerid,20000.0000,-20000.0000,20000.0000,-20000.0000);
				}
				case 4:
				{
					if(dm_check[playerid] == 1) dm_ghosttown--;
	             	else if(dm_check[playerid] == 2) dm_interior--;
	              	else if(dm_check[playerid] == 3) dm_policedep--;
	              	else if(dm_check[playerid] == 4) dm_warehouse--;
	              	else if(dm_check[playerid] == 5) return SendClientMessage(playerid,0xFF0000FF,"[ERROR]: {FFFFFF}Vec ste nalazite u toj dm zoni.");
	             	dm_fysnow++;
	             	dm_check[playerid] = 5;
		            // -- //
		            new rokovniktonisamcitao = random(sizeof(RandomPosDM_5));
		            SetPlayerPos(playerid, RandomPosDM_5[rokovniktonisamcitao][0], RandomPosDM_5[rokovniktonisamcitao][1], RandomPosDM_5[rokovniktonisamcitao][2]);
		            SetPlayerVirtualWorld(playerid, 20);
		            SetPlayerInterior(playerid, 0);
		            ResetPlayerWeapons(playerid);
		            GivePlayerWeapon(playerid, 24, 500);
		            GivePlayerWeapon(playerid, 30, 500);
		            GivePlayerWeapon(playerid, 34, 200);
		            SetPlayerHealth(playerid, 100);
		            SetPlayerArmour(playerid, 100);
		            Server[playerid][InLobby] = 0;
		            Server[playerid][InSpec] = 0;
		            SetPlayerWorldBounds(playerid,20000.0000,-20000.0000,20000.0000,-20000.0000);
				}
		        case 5:
		        {
		            if(dm_check[playerid] == 0) return SendClientMessage(playerid,0xFF0000FF,"[ERROR]: {FFFFFF}Vec ste nalazite na spawnu.");
	             	else if(dm_check[playerid] == 1) dm_ghosttown--;
	              	else if(dm_check[playerid] == 2) dm_interior--;
	               	else if(dm_check[playerid] == 3) dm_policedep--;
	               	else if(dm_check[playerid] == 4) dm_warehouse--;
	               	else if(dm_check[playerid] == 5) dm_fysnow--;
	             	dm_check[playerid] = 0;
	           		SetPlayerPos(playerid, 2778.1702,-66.8400,1318.8390);
	           		SetPlayerInterior(playerid, 2);
	           		SetPlayerVirtualWorld(playerid, 200);
	      			SetPlayerHealth(playerid, 100);
	         		SetPlayerArmour(playerid, 100);
		            ResetPlayerWeapons(playerid);
		            Server[playerid][InLobby] = 1;
		            Server[playerid][InSpec] = 0;
		            SetPlayerWorldBounds(playerid,20000.0000,-20000.0000,20000.0000,-20000.0000);
		        }
		    }
	    }
	    // --- > dialog_ucp
	    case DIALOG_UCP:
	    {
	        if(!response) return 1;
     		switch(listitem)
	    	{
	        	case 0:
	        	{
					SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Promjena imena trenutno nije dostupna");
	        	}
	        	case 1:
	        	{
					new string[220];
			    	format(string, sizeof(string), "{FFFFFF}*** User Control Panel - {C680E7}Promjena skina\n\
										{FFFFFF}Odabrali ste opciju za promjenu skina vas trenutno skin je {C680E7}%d.\n\
										{FFFFFF}Molim vas unesite novi id skina koji zelite da koristite", pInfo[playerid][Skin]);
					ShowPlayerDialog(playerid, DIALOG_UCP_SKIN, DIALOG_STYLE_INPUT, "{C680E7}wldm {ffffff}Promjena skina", string, "Uredu", "Izlaz");
				}
			}
		}
		// --- dialog_ucp_skin
		case DIALOG_UCP_SKIN:
		{
		    if(!response) return 1;
			new skin;
			skin = strval(inputtext);
			if((skin > 311 || skin < 1) || skin == 74) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Ne mozete koristiti skin id ispod 1, preko 311 i 74.");
			static q[96];
			mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Skin` = '%d' WHERE `ID` = '%d'", skin, pInfo[playerid][ID]);
			mysql_tquery(handler, q);
			q[0] = EOS;
			SetPlayerSkin(playerid, skin);
			pInfo[playerid][Skin] = skin;
			printf("[UCP - %s] Postavlja skin na %d",GetPlayerNameF(playerid), pInfo[playerid][Skin]);
		}
		// --- > dialog_login
		case DIALOG_LOGIN:
		{
		    if(response)
			{
				if(!strcmp(inputtext, pInfo[playerid][Password], false) && !isnull(inputtext))
				{
					new query[128];
                	mysql_format(handler, query, sizeof(query), "SELECT * FROM `players` WHERE `Name` = '%e' LIMIT 1", GetPlayerNameF(playerid));
					mysql_tquery(handler, query, "OnAccountLoad", "i", playerid);

					query[0] = EOS;
					return 1;
				}
				else
				{
			    	if(pInfo[playerid][PasswordFails] >= 3)
					{
				    	SendClientMessageF(playerid, 0xFF0000FF, "[LOGIN]: {FFFFFF}Upisali ste krivu lozinku {FF0000}(%d) {FFFFFF}puta i dobili kick.", pInfo[playerid][PasswordFails]);
				    	SetPlayerTimer(playerid, "KickEx", 50, false);
				    	return 1;
					}
		    		pInfo[playerid][PasswordFails]++;
		    		
					SendClientMessageF(playerid, 0xFF0000FF, "[LOGIN]: {FFFFFF}Pogresna lozinka, iskoristili ste {FF0000}(%d/3) {FFFFFF}pokusaja.", pInfo[playerid][PasswordFails]);
					
					new str[512];
			    	format(str, sizeof(str), "{FFFFFF}*** Dobrodosli nazad {C680E7}(%s) {FFFFFF}na Wonderland Deathmatch ***\n\
										{FFFFFF}Trenutno se nalazite na login dijelu.\n\
										{C680E7}- {FFFFFF}Svoje aktivnosti oko servera mozete pregledati preko Web/Mobile UCP panela {C680E7}(in dev).\n\
										{C680E7}- {FFFFFF}Zabranjeno je koristenje nedozvoljenih programa/skripti/asi fajlova.\n\
										{C680E7}- {FFFFFF}Svako krsenje pravila rezultuje banovanjem igraca sa servera.\n\
										{FFFFFF}Kako biste nastavili igru na serveru upisite vas password", GetPlayerNameF(playerid));

					ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{C680E7}wldm {ffffff}- {C680E7}login", str, "Login", "Izlaz");
					str[0] = EOS;
				}
			}
			else
			{
				Kick(playerid);
			}
			return 1;
		}
	}
	return 1;
}

// --- > raknet
IPacket:AIM_SYNC(playerid, BitStream:bs)
{
    new aimData[PR_AimSync];

    BS_IgnoreBits(bs, 8);
    BS_ReadAimSync(bs, aimData);

    if(aimData[PR_aimZ] != aimData[PR_aimZ])
    {
        aimData[PR_aimZ] = 0.0;

        BS_SetWriteOffset(bs, 8);
        BS_WriteAimSync(bs, aimData);
    }
    return 1;
}
IPacket:PLAYER_SYNC(playerid, BitStream:bs)
{
    new OFD[PR_OnFootSync];
    BS_IgnoreBits(bs, 8);
    BS_ReadOnFootSync(bs, OFD);
    return true;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{ 
    return 1;
}

public OnIncomingPacket(playerid, packetid, BitStream:bs)
{
    if(packetid == BULLET_SYNC)
    {
        new bulletSyncData[PR_BulletSync];
        BS_IgnoreBits(bs, 8);
        BS_ReadBulletSync(bs, bulletSyncData);
        if(Server[playerid][ShotDebug] == 1)
        {
        	SendClientMessageF(playerid, 0xffc31fFF, "hittype: %d, hitid: %d, weapid: %d",bulletSyncData[PR_hitType],
        	bulletSyncData[PR_hitId], bulletSyncData[PR_weaponId]);
        }	
    }    
    if(packetid == ID_PLAYER_SYNC)
    {
		new lrkeys, udkeys, sampkeys,
		Float:pos[3], Float:quaternion[4],
		health, armor, weaponid, specialaction,
		Float:speed[3], Float:surfingoffsets[3],
		surfingvehid, animationid, animflags;

		BS_IgnoreBits(bs, 8);
		BS_ReadValue(bs, RNM_UINT16, lrkeys,
						 RNM_UINT16, udkeys,
						 RNM_UINT16, sampkeys,
						 RNM_FLOAT, pos[0],
						 RNM_FLOAT, pos[1],
						 RNM_FLOAT, pos[2],
						 RNM_FLOAT, quaternion[0],
						 RNM_FLOAT, quaternion[1],
						 RNM_FLOAT, quaternion[2],
						 RNM_FLOAT, quaternion[3],
						 RNM_UINT8, health,
						 RNM_UINT8, armor,
						 RNM_UINT8, weaponid,
						 RNM_UINT8, specialaction,
						 RNM_FLOAT, speed[0],
						 RNM_FLOAT, speed[1],
						 RNM_FLOAT, speed[2],
						 RNM_FLOAT, surfingoffsets[0],
						 RNM_FLOAT, surfingoffsets[1],
						 RNM_FLOAT, surfingoffsets[2],
						 RNM_UINT16, surfingvehid,
						 RNM_INT16, animationid,
						 RNM_INT16, animflags);
						 
		if (weaponid == 38) weaponid = 0; 
		
		BS_Reset(bs);		
		BS_WriteValue(bs, RNM_UINT8, packetid,
						 RNM_UINT16, lrkeys,
						 RNM_UINT16, udkeys,
						 RNM_UINT16, sampkeys,
						 RNM_FLOAT, pos[0],
						 RNM_FLOAT, pos[1],
						 RNM_FLOAT, pos[2],
						 RNM_FLOAT, quaternion[0],
						 RNM_FLOAT, quaternion[1],
						 RNM_FLOAT, quaternion[2],
						 RNM_FLOAT, quaternion[3],
						 RNM_UINT8, health,
						 RNM_UINT8, armor,
						 RNM_UINT8, weaponid,
						 RNM_UINT8, specialaction,
						 RNM_FLOAT, speed[0],
						 RNM_FLOAT, speed[1],
						 RNM_FLOAT, speed[2],
						 RNM_FLOAT, surfingoffsets[0],
						 RNM_FLOAT, surfingoffsets[1],
						 RNM_FLOAT, surfingoffsets[2],
						 RNM_UINT16, surfingvehid,
						 RNM_INT16, animationid,
						 RNM_INT16, animflags);
    }
    return 1;
} 

// --- > animacije
LoopingAnim(playerid, animlib[], animname[], Float:Brzina, looping, lockx, locky, lockz, lp)
{
    ApplyAnimation(playerid, animlib, animname, Float:Brzina, looping, lockx, locky, lockz, lp);
}

// --- > cmds
CMD:hqsp(playerid, const params[])
{
	SetPlayerPos(playerid, 1059.895996,2081.685791,10.820312);
	SetPlayerInterior(playerid, 0);
	return 1;
}

CMD:shotdebug(playerid, const params[])
{
	if(pInfo[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
	if(Server[playerid][ShotDebug] == 1)
	{
		Server[playerid][ShotDebug] = 0;
		SendClientMessage(playerid, 0xB1C8FBFF, "[ShotDebug] {ffffff}Ugasili ste shotdebug");
	}
	else
	{
		Server[playerid][ShotDebug] = 1;
		SendClientMessage(playerid, 0xB1C8FBFF, "[ShotDebug] {ffffff}Upalili ste shotdebug");
	}
	return 1;
}

CMD:report(playerid, const params[])
{
	new text[128], targetid, string[128];
	if(Server[playerid][Report] == 1) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {ffffff}Report mozete koristiti svako 60 sekundi.");
	if(strlen(params) < 40) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {ffffff}Maksimalno 40 karaktera");
	if(pInfo[targetid][Admin] >= 1) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Ne mozete banovati admina.");
	if(targetid == playerid) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Ne mozete reportati sami sebe");
	if(sscanf(params, "ds[128]", targetid, text)) SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {ffffff}/report <playerid> <text>");
	else
	{
		format(string, sizeof(string), "[REPORT: %d] {ffffff}%s(%d) reportuje igraca %s[%d].Razlog: %s",playerid,GetPlayerNameF(playerid), playerid, GetPlayerNameF(targetid), targetid, text);
		SendAdminMessageF(1, 0xB1C8FBFF, string);
		Server[playerid][Report] = 1;	
		SetPlayerTimerEx(playerid, "resetreport", 60000, false, "i", playerid);
		SendClientMessage(playerid, 0xB1C8FBFF,"[Report] {ffffff}Vas report poslan je svim administratorima/helperima.");
	}
	return 1;
}

alias:achievements("ach");
CMD:achievements(playerid, params[])
{
	new id;
	if(!IsPlayerConnected(id)) return  SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {ffffff}Igrac nije ulogovan!");
	if(sscanf(params, "u", id)) return SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {FFFFFF}/ach(ievements) <playerid>!");
	ShowPlayerAchievements(playerid, id);
	return 1;
}

alias:myachievements("myach");
CMD:myachievements(playerid, params[])
{
    ShowPlayerAchievements(playerid, playerid);
	return 1;
}

alias:cmds("help", "komande", "commands");
CMD:cmds(playerid, const params[])
{
	new string[1024];
	strcat(string,"{54ff73}Komande {ffffff}- {54ff73}Help\n\
		           {54ff73}** {ffffff}Trenutno dostupne komande na serveru su:\n\n\
				   {54ff73}/ucp {ffffff}- {54ff73}Pregledavate vas stats accounta\n\
				   {54ff73}/tdhide {ffffff}- {54ff73}Gasite textdraw\n\
				   {54ff73}/tdshow {ffffff}- {54ff73}Palite textdraw\n\
				   {54ff73}/myweather {ffffff}- {54ff73}Mjenjate svoje vrijeme\n\
				   {54ff73}/dm {ffffff}- {54ff73}Ulazite u deathmatcharene\n\
				   {54ff73}/duel {ffffff}- {54ff73}Pozivate igraca na PvP duel [ 1 vs 1 ]\n\
				   {54ff73}/acceptduel {ffffff}- {54ff73}Prihvatate duel [ Ako vam je neko poslao zahtjev ]\n\
				   {54ff73}/declineduel {ffffff}- {54ff73}Odbijate duel [ Ako vam je neko poslao zahtjev ]\n\
				   {54ff73}/stopmusic {ffffff}- {54ff73}Gasite muziku za sebe [ Ako je admin pustio muziku ]\n\n\
			   	   {ffffff}  - wonderland community {54ff73}/ {ffffff}deathmatch {54ff73}- {ffffff}first build {54ff73}09.10.2019");
	ShowPlayerDialog(playerid, DIALOG_AKOMANDE ,DIALOG_STYLE_MSGBOX,"{54ff73}wldm {ffffff}- {C680E7}help", string, "OK","");
	return 1;
}

CMD:ucp(playerid, const params[])
{
	new string[512];
	format(string, sizeof(string), "{C680E7}Naziv\tTrenutno\n{ffffff}Nickname\t{C680E7}[%s]\n{ffffff}Skin ID\t{C680E7}[%d]\n{ffffff}Score\t{C680E7}[%d]\n\
	                                {ffffff}Kills\t{C680E7}[%d]\n{ffffff}Deaths\t{C680E7}[%d]\nPromjena TD boje\t(stable)",
	                                GetPlayerNameF(playerid),pInfo[playerid][Skin],pInfo[playerid][Score],pInfo[playerid][Kills],pInfo[playerid][Deaths]);
	ShowPlayerDialog(playerid, DIALOG_UCP, DIALOG_STYLE_TABLIST_HEADERS, "{C680E7}wldm {ffffff}user control panel", string, "Uredu","Izlaz");
	return 1;
}
CMD:tdhide(playerid, const params[])
{
	if(Server[playerid][ShowedTextdraw] == 0) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Vec imate skriven Textdraw");
	CreatePlayerWLTextdraw(playerid, false);
	Server[playerid][ShowedTextdraw] = 0;
	return 1;
}
CMD:tdshow(playerid, const params[])
{
    if(Server[playerid][ShowedTextdraw] == 1) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Vec imate prikazan Textdraw");
	CreatePlayerWLTextdraw(playerid, true);
	Server[playerid][ShowedTextdraw] = 1;
	return 1;
}
CMD:gmx(playerid, const params[])
{
	if(pInfo[playerid][Admin] < 3) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
	SendRconCommand("gmx");
	return 1;
}

CMD:raa(playerid, const params[])
{
	ApplyActorAnimation(actor[0], "PED","SEAT_IDLE",4.0, 1, 0, 0, 0, 0); ApplyActorAnimation(actor[1], "DEALER", "DEALER_IDLE", 4.0, 1, 0, 0, 0, 0);
	ApplyActorAnimation(actor[2], "DEALER", "DEALER_IDLE", 4.0, 1, 0, 0, 0, 0);
	return 1;
}

CMD:dm(playerid, const params[])
{
	if(inviter[playerid] == 1) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Pozvali ste igraca za duel (/cancelrequest)");
	if(Server[playerid][InSpec] == 1) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Trenutno se nalazite u spec modu.");
	new string[256];
	format(string, sizeof(string), "{C680E7}Lokacija\t{C680E7}Igraca\nDM - Ghost Town\t[{C680E7}%d{ffffff}]\nDM - Mission interior\t[{C680E7}%d{ffffff}]\nDM - LV Interior\t[{C680E7}%d{ffffff}]\nDM - WareHouse\t[{C680E7}%d{ffffff}]\n\
									DM - fy_snow\t[{C680E7}%d{ffffff}]\nSpawn\t(n/a)",
	                                dm_ghosttown, dm_interior, dm_policedep, dm_warehouse, dm_fysnow);
	ShowPlayerDialog(playerid, DIALOG_DM, DIALOG_STYLE_TABLIST_HEADERS, "{C680E7}wldm {ffffff}deathmatch", string, "Odaberi", "Izlaz");
	return 1;
}

CMD:crossarms(playerid, const params[])
{
	LoopingAnim(playerid, "COP_AMBIENT", "Coplook_loop", 4.0, 0, 1, 1, 1, -1);
	return 1;
}

CMD:stopanim(playerid, const params[])
{
	ClearAnimations(playerid);
	return 1;
}

CMD:myweather(playerid, const params[])
{
	new weather;
    if(sscanf(params, "i", weather)) return SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {FFFFFF}/myweather <weatherid>");
	if(weather < 0 || weather > 45) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Vreme ID ne moze biti ispod 0 ili iznad 45.");
	SetPlayerWeather(playerid, weather);
	SendClientMessageF(playerid, 0xCEE872FF, "#WEATHER: {FFFFFF}Promijenili weather na id %d",weather);
	return 1;
}

CMD:stopmusic(playerid, const params[])
{
	StopAudioStreamForPlayer(playerid);
	SendClientMessage(playerid, 0x7e9ddeFF, "[MUSIC] {ffffff}Ugasili ste muziku");
	return 1;
}

CMD:pm(playerid, params[])
{
	new id, text[50], string[70];
	if(sscanf(params, "us[50]", id, text)) return SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {FFFFFF}/pm <id> <text>");
	if(strlen(text) < 5 || strlen(text) > 50) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Ne mozete ispod 5 i preko 50 slova");
	SendClientMessageF(playerid, 0xCEE872FF, "#PM: {FFFFFF}%s: %s", GetPlayerNameF(id), text);
	SendClientMessageF(id, 0xCEE872FF, "#PM: {FFFFFF}%s: %s", GetPlayerNameF(playerid), text);
	format(string, sizeof(string), "#APM: {FFFFFF}%s > %s: %s", GetPlayerNameF(playerid), GetPlayerNameF(id), text);
	SendAdminMessageF(3, 0xffc31fFF, string);
	return 1;
}

// --- > admin command's
CMD:ahelp(playerid, const params[])
{
	if(pInfo[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
	new string[500];
	strcat(string,"{54ff73}Administator level 5\n");
	strcat(string,"{FFFFFF}/setadmin\n");

	strcat(string,"{54ff73}\nAdministator level 4\n");
	strcat(string,"{FFFFFF}\n");

	strcat(string,"{54ff73}\nAdministator level 3\n");
	strcat(string,"{FFFFFF}/unban /unbanip\n");

	strcat(string,"{54ff73}\nAdministator level 2\n");
	strcat(string,"{FFFFFF}/givegun  /ban  /banip  /unmute  /reconnect\n");

	strcat(string,"{54ff73}\nAdministator level 1\n");
	strcat(string,"{FFFFFF}/amusic  /spec  /specoff  /setskin  /gethere\n");
	ShowPlayerDialog(playerid, DIALOG_AKOMANDE ,DIALOG_STYLE_MSGBOX,"{54ff73}wldm {ffffff}- {C680E7}ahelp", string, "OK","");
	return 1;
}
CMD:checkafk(playerid, const params[])
{
	new id,string[128];
	if(pInfo[playerid][Admin] < 2) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
	if(sscanf(params,"i",id)) return SendClientMessage(playerid,0xA07BD4FF,"[COMMAND]: {FFFFFF}/afkcheck <id>");
	if(CheckPausing(id) == 0)
	{
		format(string,sizeof(string),"[AFK]: {ffffff}Igrac %s trenutno nije AFK",GetPlayerNameF(id));
		SendClientMessage(playerid,0xCEE872FF,string);
	}
	else if(CheckPausing(id) == 1)
	{
		format(string,sizeof(string),"[AFK]: {ffffff}Igrac %s je trenutno AFK",GetPlayerNameF(id));
		SendClientMessage(playerid,0xCEE872FF,string);
	}
	return 1;
}
CMD:afklist(playerid, const params[])
{
	new string[128],variable[960],afk;
	if(pInfo[playerid][Admin] < 2) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
	foreach(Player,i)
	{
		if(CheckPausing(i) == 1)
		{
			format(string,sizeof(string),"\nâ€¢ %s",GetPlayerNameF(i));
			strcat(variable,string);
			afk++;
		}
	}
	if(afk == 0) return SendClientMessage(playerid,0xFF0000FF,"[ERROR]: {FFFFFF}Trenutno nema AFK igraca!");
	if(afk == 1)
	{
		format(string,sizeof(string),"%d Igrac je AFK",afk);
	}
	if(afk > 1)
	{
		format(string,sizeof(string),"%d Igraca je AFK",afk);
	}
	ShowPlayerDialog(playerid,DIALOG_AFKLIST,DIALOG_STYLE_MSGBOX,string,variable,"Uredu","");
	return 1;
}
CMD:givegun(playerid, const params[])
{
	new id,
		weapon,
		ammo;
	new const check_ammo = GetPlayerAmmo(playerid);
	if(pInfo[playerid][Admin] < 2) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
	if(sscanf(params, "uii", id, weapon, ammo)) return SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {FFFFFF}/givegun <playerid> <weapon> <ammo>");
	if(ammo > 900) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Maksimalno mozete dati 900 metaka");
	if(check_ammo > 900) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Igrac je dostigao maksimalan broj metaka");
	if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Taj igrac nije ulogovan.");
	GivePlayerWeapon(id, weapon, ammo);
	SendClientMessageF(id, 0xCEE872FF, "#GIVEGUN: {FFFFFF}%s[%d] vam je dodjelio gun id %d[%d]", GetPlayerNameF(playerid), playerid, weapon, ammo);
	SendClientMessageF(playerid, 0xCEE872FF, "#GIVEGUN: {FFFFFF}Dodjelili ste igracu %s[%d] gun id %d[%d]", GetPlayerNameF(id), id, weapon, ammo);
	return 1;
}

CMD:amusic(playerid, const params[])
{
    if(pInfo[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
    new link[300];
    if(sscanf(params, "s[300]", link)) return SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {FFFFFF}/amusic <link>");
    if(strlen(link) < 1 || strlen(link) > 300) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Link ne moÅ¾e biti manji od 1 ili veai od 300 znakova.");
   	foreach(new i : Player) { PlayAudioStreamForPlayer(i, link); }
	SendClientMessageToAllF(0xCEE872FF, "#AMUSIC: {FFFFFF}%s je pustio pjesmu, ukoliko zelite zaustaviti muziku (/stopmusic)",GetPlayerNameF(playerid));
	return 1;
}

CMD:spec(playerid, const params[])
{
    if(pInfo[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
    new id,
		string[120];
	if(sscanf(params, "u", id)) return SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {FFFFFF}/spec <id>");
	if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Taj igrac nije ulogovan.");
	if(pInfo[id][Admin] >= 1) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Taj igrac je clan administracije.");
	TogglePlayerSpectating(playerid, true);
	PlayerSpectatePlayer(playerid, id); 
	SetPlayerInterior(playerid, GetPlayerInterior(id));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(id)); 
	Server[playerid][InSpec] = 1;
	format(string, sizeof(string), "#SPEC: {FFFFFF}Administrator %s[%d] pocinje specanje nad igracem %s[%d]", GetPlayerNameF(playerid),playerid,GetPlayerNameF(id),id);
	SendAdminMessageF(3, 0xffc31fFF, string);
	return 1;
}

CMD:reconnect(playerid, const params[])
{
    new string[64],adminstring[120],playerIP[32], id;
	if(pInfo[playerid][Admin] < 2) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
	if(sscanf(params, "u", id)) return SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {FFFFFF}/reconnect <id>");
	if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Taj igrac nije ulogovan.");
	GetPlayerIp(id, playerIP, sizeof(playerIP));
	format(ReconnectIP[id], MAX_IP_SIZE, "%s", playerIP);
	format(string, sizeof(string), "banip %s", playerIP);
	SendRconCommand(string);
	format(adminstring, sizeof(adminstring), "#RECONNECT: {FFFFFF}Administrator %s[%d] je reconnectovao igraca %s[%d]", GetPlayerNameF(playerid),playerid,GetPlayerNameF(id),id);
	SendAdminMessageF(1, 0xffc31fFF, adminstring);
	ObrisiChat(id, 100);
	SendClientMessage(id, 0x789656FF, "Reconnecting..");
	SetTimerEx("KickEx", 2000, false, "d", id);
	Reconnecting[id] = true;
	return 1;
}

CMD:specoff(playerid, const params[])
{
    if(pInfo[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
	TogglePlayerSpectating(playerid, false);
	Server[playerid][InSpec] = 0;
	SendClientMessage(playerid, 0xCEE872FF,"#SPEC: {FFFFFF}Prestali ste sa specanjem.");
	return 1;
}

CMD:ban(playerid, params[])
{
    if(pInfo[playerid][Admin] < 2) return SendClientMessage(playerid, -0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");

	new ip[17];
    new otherid, reason[200];

	if(sscanf(params, "us[200]", otherid, reason)) return SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {FFFFFF}/ban <playerid> <razlog>");
	if(!IsPlayerConnected(otherid)) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Igrac nije ulogovan");
	if(otherid == playerid) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Al bi se sad zajebo uuu...");
    if(pInfo[otherid][Admin] >= 1) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Ne mozete banovati admina.");
    
	new line2[300], datestr[200];
	new month, day, year;
	new hour, minute, second;
	gettime(hour, minute, second);
	getdate(year, month, day);
	GetPlayerIp(otherid, ip, sizeof(ip));

	format(datestr, 200, "%02d:%02d (%02d/%02d/%d)", hour, minute, month, day, year);
    GameTextForPlayer(otherid, "~r~Banovani ste", 10000, 6);
    SendClientMessageToAllF(0x54ff73FF, "[TBAN] {FFFFFF}Admin {54ff73}%s {525252}| {FFFFFF}Igrac {54ff73}%s",GetPlayerNameF(playerid), GetPlayerNameF(otherid));
	format(line2, sizeof(line2), "{FF0000}BANOVANI STE\n\n{FFFFFF}-Nick: %s\nIP: %s\nAdmin: %s\nBanovani ste sa servera zbog: %s\nBan Date: %s\n\
									Ako mislite da je ovo neka greska\nObratite se na nas forum\nwww.wl-community.xyz/dm/forum",
	GetPlayerNameF(otherid), ip, GetPlayerNameF(playerid), reason, datestr);
	ShowPlayerDialog(otherid, DIALOG_BANNED, DIALOG_STYLE_MSGBOX, "BANOVANI STE", line2, "Exit", "");

	new query[400];
	mysql_format(handler, query, sizeof(query), "INSERT INTO `ServerBans` (`name`, `adminbanned`, `reason`, `banIP`, `BanDate`) VALUES ('%e', '%e', '%e', '%e', '%e')", GetPlayerNameF(otherid), GetPlayerNameF(playerid), reason, ip,datestr);
	mysql_query(handler, query);
	new String[120];
	format(String, sizeof(String), "#TBAN: {FFFFFF}%s[%i] je banovan od strane administatora %s[%i] [Razlog: %s]",GetPlayerNameF(otherid), otherid,GetPlayerNameF(playerid), playerid, reason);
    SendAdminMessageF(1, 0xffc31fFF, String);
    SetTimerEx("KickEx", 2000, false, "d", otherid);
	return 1;
}

CMD:unban(playerid, params[])
{
	if(pInfo[playerid][Admin] <= 3) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
	new name[MAX_PLAYER_NAME] ,rows, String[200];
	static query[200];
	if(sscanf(params, "s[200]", name)) return SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {FFFFFF}/unban <full name>");
	mysql_format(handler, query, sizeof(query), "SELECT * FROM `ServerBans` WHERE `name` = '%e'", name);
	new Cache:result = mysql_query(handler, query);
	cache_get_row_count(rows);
    //if(!rows) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Ime igraca nije pronadjeno u bazi banovanih.");
    mysql_format(handler, query, sizeof(query), "DELETE FROM `Serverbans` WHERE `name` = '%e'", name);
    mysql_tquery(handler, query);
    format(String, sizeof(String), "{54ff73}[UNBAN] {FFFFFF}Admin {54ff73}%s {525252}| {FFFFFF}Igrac {54ff73}%s", GetPlayerNameF(playerid), name);
    SendAdminMessageF(-1, 0xffc31fFF, String);
	cache_delete(result);
	return 1;
}

CMD:banip(playerid, params[])
{
    new type[ 128 ], string[128];
    if(pInfo[playerid][Admin] <= 2) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
    if(sscanf(params, "s[128]", type)) SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {FFFFFF}/banip <ip>");
    else
    {
    	format(string, sizeof(string),"banip %s", type);
        SendRconCommand(string);
        SendRconCommand("reloadbans");
        SendClientMessageF(playerid, 0xFF0000FF, "[BAN-IP] {FFFFFF}Banovali ste IP: %s", type);
    }
    return true;
}

CMD:unbanip(playerid, params[])
{
    new type[ 128 ], string[128];
    if(pInfo[playerid][Admin] <= 3) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
    if(sscanf(params, "s[128]", type)) SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {FFFFFF}/unbanip <ip>");
    else
    {
    	format(string, sizeof(string),"unbanip %s", type);
        SendRconCommand(string);
        SendRconCommand("reloadbans");
        SendClientMessageF(playerid, 0xFF0000FF, "[UNBAN-IP] {FFFFFF}Unbanovali ste IP: %s", type);
    }
    return true;
}

CMD:ip(playerid,params[])
{
    if(pInfo[playerid][Admin] <= 2) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
    new target,pIP[34];
    if(sscanf(params,"u",target)) return SendClientMessage(playerid,0xA07BD4FF, "[COMMAND]: {FFFFFF}/ip <playerid>");
    if(!IsPlayerConnected(target)) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Igrac nije ulogovan");
    GetPlayerIp(target,pIP,34);
    SendClientMessageF(playerid, 0xA07BD4FF, "[IP]: {FFFFFF}Igrac: %s | IP: %s",GetPlayerNameF(target),pIP);
    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
    return 1;
}

CMD:cc(playerid, const params[])
{
	if(pInfo[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
	foreach(new i : Player)
 	{
		ObrisiChat(i, 30);
	}
	new sati, minuta, sekundi, dani, mjeseci, godina, string[64];
	gettime(sati, minuta, sekundi); getdate(godina, mjeseci, dani);
	SendClientMessage(playerid, 0x54ff73FF,"** {FFFFFF}Chat je obrisan od strane Administratora");
	SendClientMessageF(playerid, 0x54ff73FF,"~ {FFFFFF}%02d{54ff73}:{FFFFFF}%02d{54ff73}:{FFFFFF}%02d{54ff73} / {FFFFFF}%02d{54ff73}.{FFFFFF}%02d{54ff73}.{FFFFFF}%d{54ff73} ~",sati,
																							minuta, sekundi, dani, mjeseci, godina);
	format(string, sizeof(string), "[ADMIN] %s je ocistio/la chat", GetPlayerNameF(playerid));
	SendAdminMessageF(1, 0xffc31fFF, string);
	return 1;
}

CMD:setskin(playerid, const params[])
{
	if(pInfo[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
	
	new
		targetid,
		skin;
		
	if(sscanf(params, "ui", targetid, skin)) return SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {FFFFFF}/setskin <id/name> <skin id>");
	if((skin > 311 || skin < 1) || skin == 74) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Ne mozete koristiti skin id ispod 1, preko 311 i 74.");
	if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Taj igrac nije ulogovan.");
	{
		SetPlayerSkin(targetid, skin);
		pInfo[targetid][Skin] = skin;
		static q[96];
		mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Skin` = '%d' WHERE `ID` = '%d'", skin, pInfo[targetid][ID]);
		mysql_tquery(handler, q);
		q[0] = EOS;

		SendClientMessageF(targetid, 0xCEE872FF, "#SETSKIN: {FFFFFF}%s[%d] vam je postavio/la skin id %d.", GetPlayerNameF(playerid), playerid, skin);
		SendClientMessageF(playerid, 0xCEE872FF, "#SETSKIN: {FFFFFF}Postavili ste igracu %s[%d] skin id %d.", GetPlayerNameF(targetid), targetid, skin);
        printf("Admin %s postavlja skin igracu %s [Skin ID: %d]",GetPlayerNameF(playerid), GetPlayerNameF(targetid), skin);
	}
	return 1;
}

CMD:setadmin(playerid, const params[])
{
	if(pInfo[playerid][Admin] < 5) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
	
	new
		targetid,
		level;
		
	if(sscanf(params, "ui", targetid, level)) return SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {FFFFFF}/setadmin <id/name> <level id>");
	if((level > 6 || level < 0)) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Ne mozete setati admina ispod 1, preko 6.");
	if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Taj igrac nije ulogovan.");
	{
		pInfo[targetid][Admin] = level;

		static q[96];
		mysql_format(handler, q, sizeof(q), "UPDATE `players` SET `Admin` = '%d' WHERE `ID` = '%d'", level, pInfo[targetid][ID]);
		mysql_tquery(handler, q);

		q[0] = EOS;

		SendClientMessageF(targetid, 0xCEE872FF, "#SETADMIN: {FFFFFF}%s[%d] vam je postavio/la admin level %d.", GetPlayerNameF(playerid), playerid, level);
		SendClientMessageF(playerid, 0xCEE872FF, "#SETADMIN: {FFFFFF}Postavili ste igracu %s[%d] admin level %d.", GetPlayerNameF(targetid), targetid, level);
	}
	return 1;
}
CMD:gethere(playerid, const params[])
{
    new get_playerid,
		Float:X,
		Float:Y,
		Float:Z;
	if(pInfo[playerid][Admin] < 1) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Nemate ovlastenje za koristenje ove komande");
	if(sscanf(params, "u", get_playerid)) return SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {FFFFFF}/gethere <id/name>");
	if(get_playerid == playerid) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Ne mozete getati sami sebe");
	if(get_playerid == INVALID_PLAYER_ID) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Taj igrac je trenutno offline.");
	GetPlayerPos(playerid, X, Y, Z);
	SetPlayerPos(get_playerid, X+2,Y,Z);
	SendClientMessageF(playerid, 0xCEE872FF, "#GETHERE: {FFFFFF}Teleportovao si %s-a do sebe.",GetPlayerNameF(get_playerid));
	SendClientMessageF(get_playerid, 0xCEE872FF, "#GETHERE: {FFFFFF}Admin %s te teleportovao do sebe.",GetPlayerNameF(playerid));
	return 1;
}
// ---> duel command's
CMD:duel(playerid, const params[])
{
    new user,
		weap[45],
		weaponid = -1;
		
    if(sscanf(params, "us[45]", user, weap)) return SendClientMessage(playerid, 0xA07BD4FF, "[COMMAND]: {FFFFFF}/duel <id/name> <weapon name>");
    if(user == INVALID_PLAYER_ID) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Taj igrac je trenutno offline.");
    if(Server[playerid][InSpec] == 1) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Trenutno se nalazite u spec modu.");
    if(Server[user][InSpec] == 1) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Taj igrac je u spec modu.");
    if(user == playerid) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Ne mozete dodati sami sebe u duel");
    if(wl_duelinfo[playerid][induel] == 1) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Vec se nalazite u duelu");
    if(wl_duelinfo[user][induel] == 1) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Taj igrac vec igra sa drugim igracem duel");
    if(dm_check[user] > 0) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Igrac se nalazi u dm zoni");
    if(invite[user] == 1) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Taj igrac je vec pozvan");
    if(inviter[playerid] == 1) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Vec ste pozvali igraca, sacekajte hoceli taj igrac prihvatiti ili odbiti poziv!");

	if(StringNumeric(weap))
    {
        weaponid = strval(weap);
    }
    else
    {
        weaponid = CheckWeaponID(weap);
    }
    DuelSender[user] = playerid;
    wl_duelinfo[playerid][weapid] = weaponid;
    wl_duelinfo[playerid][weapname] = weap;
    wl_duelinfo[user][weapid] = weaponid;
    wl_duelinfo[user][weapname] = weap;
    invite[user] = 1;
    inviter[playerid] = 1;
    DuelReciever[playerid] = user;
    
    SendClientMessageF(playerid, 0xCEE872FF, "#DUELINVITE: {FFFFFF}Poslali ste poziv za duel igracu %s(%d). [Weapon : %s]", wl_duelinfo[user][playername], user, weap);
    SendClientMessageF(user, 0xCEE872FF, "#DUELINVITE: {FFFFFF}Imate poziv u duel sa igracem %s(%d). [Weapon : %s]", wl_duelinfo[playerid][playername], playerid, weap);
    return 1;
}

CMD:acceptduel(playerid, const params[])
{
    if(dm_check[playerid] > 0) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Ne mozete prihvatiti duel jer ste u dm zoni");
    if(Server[playerid][InSpec] == 1) return SendClientMessage(playerid, 0xFF0000FF,"[ERROR]: {FFFFFF}Ne mozete accept duel jer se nalazite u spec modu");
    if(invite[playerid] == 1)
    {
        new user = DuelSender[playerid];
        ResetPlayerWeapons(user);
        RemovePlayerFromVehicle(user);
        SetPlayerArmour(user, 0);
        SetPlayerHealth(user, 100);
        SetPlayerVirtualWorld(user, 100);
        SetPlayerInterior(user, 0);
        SetPlayerPos(user, 1399.3311, 2789.9409, 10.8203);
        GivePlayerWeapon(user, wl_duelinfo[playerid][weapid], 500);
        wl_duelinfo[user][induel] = 1;
        inviter[user] = 0;
        Server[user][InLobby] = 0;
        Server[user][InSpec] = 0;
        
        ResetPlayerWeapons(playerid);
        RemovePlayerFromVehicle(playerid);
        SetPlayerArmour(playerid, 0);
        SetPlayerHealth(playerid, 100);
        SetPlayerVirtualWorld(playerid, 100);
        SetPlayerInterior(playerid, 0);
        GivePlayerWeapon(playerid, wl_duelinfo[user][weapid], 500);
        SetPlayerPos(playerid, 1358.0012, 2789.6218, 10.8203);
        wl_duelinfo[playerid][induel] = 1;
        invite[playerid] = 0;
        Server[playerid][InLobby] = 0;
        Server[playerid][InSpec] = 0;
    }
    else return SendClientMessage(playerid, 0xCEE872FF, "#DUELINVITE: {FFFFFF}Niste primili ni jedan poziv za duel.");
    return 1;
}

CMD:declineduel(playerid, const params[])
{
    if(dm_check[playerid] > 0) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Ne mozete odbiti duel jer ste u dm zoni");
    if(invite[playerid] == 1)
    {
        new user = DuelSender[playerid];
        invite[playerid] = 0;
        inviter[user] = 0;
        
        SendClientMessageF(playerid, 0xCEE872FF, "#DUELINVITE: {FFFFFF}Odbili ste duel sa igracem %s(%d).", wl_duelinfo[user][playername], user);
        SendClientMessageF(user, 0xCEE872FF, "#DUELINVITE: {FFFFFF}Igrac %s(%d) je odbio vas poziv za duel.", wl_duelinfo[playerid][playername], playerid);
    }
    else return SendClientMessage(playerid, 0xCEE872FF, "#DUELINVITE: {FFFFFF}Niste primili ni jedan poziv za duel.");
    return 1;
}

CMD:cancelrequest(playerid, const params[])
{
	if(dm_check[playerid] > 0) return SendClientMessage(playerid, 0xFF0000FF, "[ERROR]: {FFFFFF}Ne mozete prekinuti poziv za duel jer ste u dm zoni");
    if(inviter[playerid] == 1)
    {
        new user = DuelReciever[playerid];
        inviter[playerid] = 0;
        invite[user] = 0;
        
        SendClientMessageF(playerid, 0xCEE872FF, "#DUELINVITE: {FFFFFF}Ponistili ste zahtjev za duel sa igracem %s(%d).", wl_duelinfo[user][playername], user);
        SendClientMessageF(user, 0xCEE872FF, "#DUELINVITE: {FFFFFF}Igrac %s(%d) je ponistio poziv za duel sa vama.", wl_duelinfo[playerid][playername], playerid);
    }
    else return SendClientMessage(playerid, -1, "{CEE872}#DUELINVITE: {FFFFFF}Niste poslali ni jedan poziv za duel.");
    return 1;
}
#if defined wl_script

							----------------------
							LAST BUILD: 23.10.2019
							----------------------
		                    ~ alpha version  0.1 ~
							----------------------
                      Hvala .mumitza za pomoc oko skripte
                         
#endif
