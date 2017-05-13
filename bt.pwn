/*********************************************************************************
*			(c) Copyright SVR 2017				         *
*			  Created by: SVR				 	 *
*********************************************************************************/
/* Includes, defines, enums and functions. */
#include <a_samp>
#include <zcmd>
#include <streamer>

#define	    forward %1(%2)     \
            public %1(%2)

#undef MAX_PLAYERS
#define MAX_PLAYERS 100

#define PlayerLoop(%1) for(new %1 = 0; %1 < MAX_PLAYERS; %1++) if(IsPlayerConnected(%1) && !IsPlayerNPC(%1))

enum stats
{
	Shots,
	ShotsHit,
	bool:Bttrace,
	Bttraceby,
	Bt
}
new 
	pStat[MAX_PLAYERS][stats];

forward RemoveObject(objectid);

new 
	global[128];

stock PlayerName(playerid)
{
	new 
		name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}
/* END */

/* START */
CMD:bt(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "Error: {e0e0e0}You are not allowed to use this command!");
	new 
		id;
	if(sscanf(params, "u", id)) return SendClientMessage(playerid, -1, "Usage: {e0e0e0}/bt <PartOfName/playerid>"));
	if(id == -1)
	{
		PlayerLoop(i)
		{
			if(pStat[i][Bttraceby] == playerid)
			{
				pStat[i][Bttraceby] = -1;
				pStat[i][Bttrace] = true;
				break;
			}
		}
	}
	pStat[id][Bttraceby] = playerid;
	pStat[id][Bttrace] = true;
	pStat[playerid][bt] = id;
	format(global, sizeof global, "[/bt]: {e0e0e0}You are now tracing bullets of %s (ID: %d).", PlayerName(id), id);
	SendClientMessage(playerid, -1, global);
	return 1;
}
CMD:checkbt(playerid, params[]);
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "Error: {e0e0e0}You are not allowed to use this command!");
	new 
		id;
	if(sscanf(params, "u", id)) return SendClientMessage(playerid, "Usage: {e0e0e0}/checkbt <PartOfName/playerid>");
	format(global, sizeof global, "[/bt]: {e0e0e0}Checking %s (ID: %d)!", PlayerName(id), id);
	SendClientMessage(playerid, -1, global);
	format(global, sizeof global, " Shots Missed: {ff0000}%i {e0e0e0}| {ffffff}Shots Hit: {ff0000}%i", pStat[id][Shots], pStat[id][ShotsHit]);
	SendClientMessage(playerid, -1, global);
	return 1;
}
public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(hittype == 1)
	{
		pStat[playerid][Shots]++;
		pStat[playerid][ShotsHit]++;
	}
	else
	{
		pStat[playerid][Shots]++;
	}
	PlayerLoop(i)
	{
		if(pStat[i][Bt] == playerid)
		{
			if(hittype == 1)
			{
				format(global, sizeof global, "[/bt]: {ff0000}%s(%d) HIT_PLAYER %s(%d) (%i/%i)", PlayerName(playerid), playerid, PlayerName(hitid), hitid, pStat[playerid][ShotsHit], pStat[playerid][Shots]);
				SendClientMessage(i, -1, global);
			}
			if(hittype == 2)
			{
				format(global, sizeof global, "[/bt]: {ff0000}%s(%d) HIT_VEHICLE (%i/%i)", PlayerName(playerid), playerid);
				SendClientMessage(i, -1, global);
			}
			else
			{
				format(global, sizeof global, "[/bt]: {ff0000}%s(%d) MISS (%i/%i)", PlayerName(playerid), playerid);
				SendClientMessage(i, -1, global);
			}
		}
	}
	if(pStat[playerid][Bttrace])
	{
		new 
			objectid = CreateDynamicObject(19836, fX, fY, fZ, 0, 90, 0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), pStat[playerid][Bttraceby], 150);
		SetTimerEx("RemoveObject", 3500, false, "i", objectid);
	}
	return 1;
}
public OnPlayerConnect(playerid)
{
	pStat[playerid][Shots] = 0;
	pStat[playerid][ShotsHit] = 0;
	pStat[playerid][Bttrace] = false;
	pStat[playerid][Bttraceby] = -1;
	pStat[playerid][Bt] = -1;
	return 1;
}
public OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid, bodypart)
{
	if(pStat[playerid][Bttrace])
	{
            new 
		Float:f1, Float:f2, Float:f3,
            	Float:f4, Float:f5, Float:f6;
            GetPlayerLastShotVectors(playerid, f1, f2, f3, f4, f5, f6);
	    new 
			objectid = CreateDynamicObject(19836, f4, f5, f6, 0, 90, 0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), pStat[playerid][Bttraceby], 150);
	    SetTimerEx("RemoveObject", 3500, false, "i", objectid);
	}
	return 1;
}
public RemoveObject(objectid)
{
	DestroyDynamicObject(objectid);
	return 1;
}	

/* END */