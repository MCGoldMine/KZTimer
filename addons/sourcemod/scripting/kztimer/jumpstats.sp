// Credits: LJStats by justshoot, Zipcore
public Function_BlockJump(client)
{
	decl Float:pos[3], Float:origin[3];
	GetAimOrigin(client, pos);
	TraceClientGroundOrigin(client, origin, 100.0);
	decl bool:funclinear;
	funclinear=false;
	//get aim target
	decl String:classname[32];
	new target = TraceClientViewEntity(client);
	if (IsValidEdict(target))
		GetEntityClassname(target, classname, 32);	
	if (StrEqual(classname,"func_movelinear"))
		funclinear=true;
	
	if((FloatAbs(pos[2] - origin[2]) <= 0.002) || (funclinear && FloatAbs(pos[2] - origin[2]) <= 0.6))
	{
		GetBoxFromPoint(origin, g_fOriginBlock[client]);
		GetBoxFromPoint(pos, g_fDestBlock[client]);
		CalculateBlockGap(client, origin, pos);
		g_fBlockHeight[client] = pos[2];
	}
	else
	{
		g_bLJBlock[client] = false;
		PrintToChat(client, "%t", "LJblock1",MOSSGREEN,WHITE,RED);	
	}
}

// Credits: LJStats by justshoot, Zipcore
stock TE_SendBlockPoint(client, const Float:pos1[3], const Float:pos2[3], model)
{
	decl Float:buffer[4][3];
	buffer[2] = pos1;
	buffer[3] = pos2;
	buffer[0] = buffer[2];
	buffer[0][1] = buffer[3][1];
	buffer[1] = buffer[3];
	buffer[1][1] = buffer[2][1];
	decl randco[4];
	randco[0] = GetRandomInt(0, 255);
	randco[1] = GetRandomInt(0, 255);
	randco[2] = GetRandomInt(0, 255);
	randco[3] = GetRandomInt(125, 255);
	TE_SetupBeamPoints(buffer[3], buffer[0], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
	TE_SetupBeamPoints(buffer[0], buffer[2], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
	TE_SetupBeamPoints(buffer[2], buffer[1], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
	TE_SetupBeamPoints(buffer[1], buffer[3], model, 0, 0, 0, 0.13, 2.0, 2.0, 10, 0.0, randco, 0);
	TE_SendToClient(client);
}

// Credits: LJStats by justshoot, Zipcore
GetEdgeOrigin1(client, Float:ground[3], Float:result[3])
{
	result[0] = FloatDiv(g_fEdgeVector[client][0]*ground[0] + g_fEdgeVector[client][1]*g_fEdgePoint1[client][0], g_fEdgeVector[client][0]+g_fEdgeVector[client][1]);
	result[1] = FloatDiv(g_fEdgeVector[client][1]*ground[1] - g_fEdgeVector[client][0]*g_fEdgePoint1[client][1], g_fEdgeVector[client][1]-g_fEdgeVector[client][0]);
	result[2] = ground[2];
}

GetEdgeOrigin2(client, Float:ground[3], Float:result[3])
{
	result[0] = FloatDiv(g_fEdgeVector[client][0]*ground[0] + g_fEdgeVector[client][1]*g_fEdgePoint2[client][0], g_fEdgeVector[client][0]+g_fEdgeVector[client][1]);
	result[1] = FloatDiv(g_fEdgeVector[client][1]*ground[1] - g_fEdgeVector[client][0]*g_fEdgePoint2[client][1], g_fEdgeVector[client][1]-g_fEdgeVector[client][0]);
	result[2] = ground[2];
}

// Credits: LJStats by justshoot, Zipcore
stock TraceWallOrigin(Float:fOrigin[3], Float:vAngles[3], Float:result[3])
{
	new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(trace)) 
	{
		TR_GetEndPosition(result, trace);
		CloseHandle(trace);
		return 1;
	}
	CloseHandle(trace);
	return 0;
}

// Credits: LJStats by justshoot, Zipcore
stock TraceGroundOrigin(Float:fOrigin[3], Float:result[3])
{
	new Float:vAngles[3] = {90.0, 0.0, 0.0};
	new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(trace)) 
	{
		TR_GetEndPosition(result, trace);
		CloseHandle(trace);
		return 1;
	}
	CloseHandle(trace);
	return 0;
}

// Credits: LJStats by justshoot, Zipcore
stock GetBeamEndOrigin(Float:fOrigin[3], Float:vAngles[3], Float:distance, Float:result[3])
{
	decl Float:AngleVector[3];
	GetAngleVectors(vAngles, AngleVector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(AngleVector, AngleVector);
	ScaleVector(AngleVector, distance);	
	AddVectors(fOrigin, AngleVector, result);
}

// Credits: LJStats by justshoot, Zipcore
stock GetBeamHitOrigin(Float:fOrigin[3], Float:vAngles[3], Float:result[3])
{
    new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
    if(TR_DidHit(trace)) 
    {
        TR_GetEndPosition(result, trace);
        CloseHandle(trace);
    }
}

// Credits: LJStats by justshoot, Zipcore
stock GetAimOrigin(client, Float:hOrigin[3]) 
{
    decl Float:vAngles[3], Float:fOrigin[3];
    GetClientEyePosition(client,fOrigin);
    GetClientEyeAngles(client, vAngles);

    new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

    if(TR_DidHit(trace)) 
    {
        TR_GetEndPosition(hOrigin, trace);
        CloseHandle(trace);
        return 1;
    }

    CloseHandle(trace);
    return 0;
}

// Credits: LJStats by justshoot, Zipcore
stock GetBoxFromPoint(Float:origin[3], Float:result[2][3])
{
	decl Float:temp[3];
	temp = origin;
	temp[2] += 1.0;
	new Float:ang[4][3];
	ang[1][1] = 90.0;
	ang[2][1] = 180.0;
	ang[3][1] = -90.0;
	new bool:edgefound[4];
	new Float:dist[4];
	decl Float:tempdist[4], Float:position[3], Float:ground[3], Float:Last[4], Float:Edge[4][3];
	for(new i = 0; i < 4; i++)
	{
		TraceWallOrigin(temp, ang[i], Edge[i]);
		tempdist[i] = GetVectorDistance(temp, Edge[i]);
		Last[i] = origin[2];
		while(dist[i] < tempdist[i])
		{
			if(edgefound[i])
				break;
			GetBeamEndOrigin(temp, ang[i], dist[i], position);
			TraceGroundOrigin(position, ground);
			if((Last[i] != ground[2])&&(Last[i] > ground[2]))
			{
				Edge[i] = ground;
				edgefound[i] = true;
			}
			Last[i] = ground[2];
			dist[i] += 10.0;
		}
		if(!edgefound[i])
		{
			TraceGroundOrigin(Edge[i], Edge[i]);
			edgefound[i] = true;
		}
		else
		{
			ground = Edge[i];
			ground[2] = origin[2];
			MakeVectorFromPoints(ground, origin, position);
			GetVectorAngles(position, ang[i]);
			ground[2] -= 1.0;
			GetBeamHitOrigin(ground, ang[i], Edge[i]);
		}
		Edge[i][2] = origin[2];
	}
	if(edgefound[0]&&edgefound[1]&&edgefound[2]&&edgefound[3])
	{
		result[0][2] = origin[2];
		result[1][2] = origin[2];
		result[0][0] = Edge[0][0];
		result[0][1] = Edge[1][1];
		result[1][0] = Edge[2][0];
		result[1][1] = Edge[3][1];
	}
}

// Credits: LJStats by justshoot, Zipcore
CalculateBlockGap(client, Float:startblock[3], Float:endblock[3])
{
	new Float:distance = GetVectorDistance(startblock, endblock);
	new Float:rad = DegToRad(15.0);
	new Float:newdistance = FloatDiv(distance, Cosine(rad));
	decl Float:eye[3], Float:eyeangle[2][3];
	new Float:temp = 0.0;
	GetClientEyePosition(client, eye);
	GetClientEyeAngles(client, eyeangle[0]);
	eyeangle[0][0] = 0.0;
	eyeangle[1] = eyeangle[0];
	eyeangle[0][1] += 10.0;
	eyeangle[1][1] -= 10.0;
	decl Float:position[3], Float:ground[3], Float:Last[2], Float:Edge[2][3];
	new bool:edgefound[2];
	while(temp < newdistance)
	{
		temp += 10.0;
		for(new i = 0; i < 2 ; i++)
		{
			if(edgefound[i])
				continue;
			GetBeamEndOrigin(eye, eyeangle[i], temp, position);
			TraceGroundOrigin(position, ground);
			if(temp == 10.0)
			{
				Last[i] = ground[2];
			}
			else
			{
				if((Last[i] != ground[2])&&(Last[i] > ground[2]))
				{
					Edge[i] = ground;
					edgefound[i] = true;
				}
				Last[i] = ground[2];
			}
		}
	}
	decl Float:temp2[2][3];
	if(edgefound[0] && edgefound[1])
	{
		for(new i = 0; i < 2 ; i++)
		{
			temp2[i] = Edge[i];
			temp2[i][2] = startblock[2] - 1.0;
			if(eyeangle[i][1] > 0)
			{
				eyeangle[i][1] -= 180.0;
			}
			else
			{
				eyeangle[i][1] += 180.0;
			}
			GetBeamHitOrigin(temp2[i], eyeangle[i], Edge[i]);
		}	
	}
	else
	{
		g_bLJBlock[client] = false;
		PrintToChat(client, "%t", "LJblock2",MOSSGREEN,WHITE,RED);	
		return;
	}
	g_fEdgePoint1[client] = Edge[0];	
	MakeVectorFromPoints(Edge[0], Edge[1], position);
	g_fEdgeVector[client] = position;
	NormalizeVector(g_fEdgeVector[client], g_fEdgeVector[client]);
	CorrectEdgePoint(client);
	GetVectorAngles(position, position);
	position[1] += 90.0;
	GetBeamHitOrigin(Edge[0], position, Edge[1]);
	distance = GetVectorDistance(Edge[0], Edge[1]);
	g_BlockDist[client] = RoundToNearest(distance);
	g_fEdgePoint2[client] = Edge[1];
	
	if (g_fEdgePoint1[client][0] < g_fEdgePoint2[client][0])
		g_fEdgePoint2[client][0] = g_fEdgePoint2[client][0] - 16.0;
	else
		g_fEdgePoint2[client][0] = g_fEdgePoint2[client][0] + 16.0;
	if (g_fEdgePoint1[client][1] < g_fEdgePoint2[client][1])
		g_fEdgePoint2[client][1] = g_fEdgePoint2[client][1] - 16.0;
	else
		g_fEdgePoint2[client][1] = g_fEdgePoint2[client][1] + 16.0;	

	new Float:surface = GetVectorDistance(g_fDestBlock[client][0],g_fDestBlock[client][1]);
	surface *= surface;
	if (surface > 1000000)
	{
		PrintToChat(client, "%t", "LJblock3",MOSSGREEN,WHITE,RED);	
		return;
	}	
	
	
	if(!IsCoordInBlockPoint(Edge[1],g_fDestBlock[client],true))	
	{	
		g_bLJBlock[client] = false;
		PrintToChat(client, "%t", "LJblock4",MOSSGREEN,WHITE,RED);	
		return;		
	}
	TE_SetupBeamPoints(Edge[0], Edge[1], g_Beam[0], 0, 0, 0, 1.0, 1.0, 1.0, 10, 0.0, {0,255,255,155}, 0);
	TE_SendToClient(client);	
	
	if(g_BlockDist[client] > 225 && g_BlockDist[client] <= 300)
	{
		PrintToChat(client, "%t", "LJblock5", MOSSGREEN,WHITE, LIMEGREEN,GREEN, g_BlockDist[client],LIMEGREEN);
		g_bLJBlock[client] = true;
	}
	else
	{
		if (g_BlockDist[client] < 225)
			PrintToChat(client, "%t", "LJblock6", MOSSGREEN,WHITE, RED,DARKRED,g_BlockDist[client],RED);
		else
			if (g_BlockDist[client] > 300)
				PrintToChat(client, "%t", "LJblock7", MOSSGREEN,WHITE, RED,DARKRED,g_BlockDist[client],RED);
	}
}

CorrectEdgePoint(client)
{
	decl Float:vec[3];
	vec[0] = 0.0 - g_fEdgeVector[client][1];
	vec[1] = g_fEdgeVector[client][0];
	vec[2] = 0.0;
	ScaleVector(vec, 16.0);
	AddVectors(g_fEdgePoint1[client], vec, g_fEdgePoint1[client]);
}

// Credits: LJStats by justshoot, Zipcore
stock bool:IsCoordInBlockPoint(const Float:origin[3], const Float:pos[2][3], bool:ignorez)
{
	new bool:bX, bool:bY, bool:bZ;
	decl Float:temp[2][3];
	temp[0] = pos[0];
	temp[1] = pos[1];
	temp[0][0] += 16.0;
	temp[0][1] += 16.0;
	temp[1][0] -= 16.0;
	temp[1][1] -= 16.0;
	if (ignorez)
		bZ=true;	
	
	if(temp[0][0] > temp[1][0])
	{
		if(temp[0][0] >= origin[0] >= temp[1][0])
		{
			bX = true;
		}
	}
	else
	{
		if(temp[1][0] >= origin[0] >= temp[0][0])
		{
			bX = true;
		}
	}
	if(temp[0][1] > temp[1][1])
	{
		if(temp[0][1] >= origin[1] >= temp[1][1])
		{
			bY = true;
		}
	}
	else
	{
		if(temp[1][1] >= origin[1] >= temp[0][1])
		{
			bY = true;
		}
	}
	if(temp[0][2] + 0.002 >= origin[2] >= temp[0][2])
	{
		bZ = true;
	}
	
	if(bX&&bY&&bZ)
	{
		return true;
	}
	else
	{
		return false;
	}
}

public Prethink (client, bool:ladderjump)
{		
	decl Float: flEngineTime;
	flEngineTime = GetEngineTime()
	g_fLastJump[client] = flEngineTime;
	g_fAirTime[client] = flEngineTime;
	
	decl weapon;
	weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if (!client || !IsPlayerAlive(client) || g_bNoClipUsed[client] || weapon == -1 || GetEntProp(client, Prop_Data, "m_nWaterLevel") > 0)
	{	
		g_bNoClipUsed[client] = false;
		return;
	}
	//booster or moving plattform?
	decl Float:flVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", flVelocity);
	if (flVelocity[0] != 0.0 || flVelocity[1] != 0.0 || flVelocity[2] != 0.0)
		g_js_bInvalidGround[client] = true;
	else
		g_js_bInvalidGround[client] = false;		
			
	//reset vars
	g_js_Good_Sync_Frames[client] = 0.0;
	g_js_Sync_Frames[client] = 0.0;
	for( new i = 0; i < 100; i++ )
	{
		g_js_Strafe_Good_Sync[client][i] = 0.0;
		g_js_Strafe_Frames[client][i] = 0.0;
		g_js_Strafe_Gained[client][i] = 0.0;
		g_js_Strafe_Lost[client][i] = 0.0;
		g_js_Strafe_Max_Speed[client][i] = 0.0;
	}	
	
	g_js_fJumpOff_Time[client] = GetEngineTime();
	g_js_fMax_Speed[client] = 0.0;
	g_js_StrafeCount[client] = 0;
	g_js_bDropJump[client] = false;
	g_js_bPlayerJumped[client] = true;
	g_js_Strafing_AW[client] = false;
	g_js_Strafing_SD[client] = false;
	g_js_bFuncMoveLinear[client] = false;
	g_js_fMax_Height[client] = -99999.0;				
	g_js_fLast_Jump_Time[client] = GetEngineTime();
	g_fMovingDirection[client] = 0.0;
	
	decl Float:fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);		
	g_js_fPreStrafe[client] = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0) + Pow(fVelocity[2], 2.0));	
	
	
	g_js_fJumpOff_Speed[client] = -1.0;		
	CreateTimer(0.015, GetJumpOffSpeedTimer, client,TIMER_FLAG_NO_MAPCHANGE);
	GetGroundOrigin(client, g_js_fJump_JumpOff_Pos[client]);	
	if (g_js_fJump_JumpOff_PosLastHeight[client] != -1.012345)
	{	
		decl Float: fGroundDiff ;
		fGroundDiff = g_js_fJump_JumpOff_Pos[client][2] - g_js_fJump_JumpOff_PosLastHeight[client];
		if (fGroundDiff > -0.1 && fGroundDiff < 0.1)
			fGroundDiff = 0.0;		
		if(fGroundDiff <= -1.5)
		{
			g_js_bDropJump[client] = true;
			g_js_fDropped_Units[client] = FloatAbs(fGroundDiff);
		}		
	}	
	
	if (g_js_GroundFrames[client]<11)
		g_js_bBhop[client] = true;
	else
		g_js_bBhop[client] = false;
	
	//ladder jump?
	if (ladderjump)
	{
		g_js_fPreStrafe[client] = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0));
		g_js_fJump_JumpOff_Pos[client] = g_fLastPosition[client];
		g_bLadderJump[client]=true;
		g_js_LadderDirectionCounter[client] = 0;
		g_js_fLadderDirection[client] = 0.0;
		g_bBeam[client] = true;
	}
	else
	{
		if (g_js_fPreStrafe[client] < 249.0)
			g_bBeam[client] = false;
		g_bLadderJump[client]=false;
	}

	//last InitialLastHeight
	g_js_fJump_JumpOff_PosLastHeight[client] = g_js_fJump_JumpOff_Pos[client][2];
}

public Postthink(client)
{	
	if (!IsValidClient(client))
		return;
		
	decl ground_frames;
	ground_frames = g_js_GroundFrames[client];
	decl strafes;
	strafes = g_js_StrafeCount[client];
	g_js_GroundFrames[client] = 0;	
	g_js_fMax_Speed_Final[client] = g_js_fMax_Speed[client];
	decl String:szName[128];	
	GetClientName(client, szName, 128);		
	
	//get landing position & calc distance
	g_js_fJump_DistanceX[client] = g_js_fJump_Landing_Pos[client][0] - g_js_fJump_JumpOff_Pos[client][0];
	if(g_js_fJump_DistanceX[client] < 0)
		g_js_fJump_DistanceX[client] = -g_js_fJump_DistanceX[client];
	g_js_fJump_DistanceZ[client] = g_js_fJump_Landing_Pos[client][1] - g_js_fJump_JumpOff_Pos[client][1];
	if(g_js_fJump_DistanceZ[client] < 0)
		g_js_fJump_DistanceZ[client] = -g_js_fJump_DistanceZ[client];
	g_js_fJump_Distance[client] = SquareRoot(Pow(g_js_fJump_DistanceX[client], 2.0) + Pow(g_js_fJump_DistanceZ[client], 2.0));	
	
	g_js_fJump_Distance[client] = g_js_fJump_Distance[client] + 32.0;
	
	//ground diff
	decl Float: fGroundDiff;
	fGroundDiff = g_js_fJump_Landing_Pos[client][2] - g_js_fJump_JumpOff_Pos[client][2];
	decl Float: fJump_Height;
	if (fGroundDiff > -0.1 && fGroundDiff < 0.1)
		fGroundDiff = 0.0;
	//workaround
	if (g_js_bFuncMoveLinear[client] && fGroundDiff < 0.6 && fGroundDiff > -0.6)
		fGroundDiff = 0.0;
	
	//ground diff 2
	decl Float: groundpos[3];
	GetClientAbsOrigin(client, groundpos);
	decl Float: fGroundDiff2;
	fGroundDiff2 = groundpos[2] - g_fLastPositionOnGround[client][2];
		
	//GetHeight
	if (FloatAbs(g_js_fJump_JumpOff_Pos[client][2]) > FloatAbs(g_js_fMax_Height[client]))
		fJump_Height =  FloatAbs(g_js_fJump_JumpOff_Pos[client][2]) - FloatAbs(g_js_fMax_Height[client]);
	else
		fJump_Height =  FloatAbs(g_js_fMax_Height[client]) - FloatAbs(g_js_fJump_JumpOff_Pos[client][2]);
	g_flastHeight[client] = fJump_Height;
	
	//sync/strafes
	decl sync;
	sync = RoundToNearest(g_js_Good_Sync_Frames[client] / g_js_Sync_Frames[client] * 100.0);
	g_js_Strafes_Final[client] = strafes;
	g_js_Sync_Final[client] = sync;
	
	//Calc & format strafe sync for chat output
	decl String:szStrafeSync[255];
	decl String:szStrafeSync2[255];
	decl strafe_sync;
	if (g_bStrafeSync[client] && strafes > 1)
	{
		for (new i = 0; i < strafes; i++)
		{
			if (i==0)
				Format(szStrafeSync, 255, "[%cKZ%c] %cSync:",MOSSGREEN,WHITE,GRAY);
			if (g_js_Strafe_Frames[client][i] == 0.0 || g_js_Strafe_Good_Sync[client][i] == 0.0) 
				strafe_sync = 0;
			else
				strafe_sync = RoundToNearest(g_js_Strafe_Good_Sync[client][i] / g_js_Strafe_Frames[client][i] * 100.0);
			if (i==0)	
				Format(szStrafeSync2, 255, " %c%i.%c %i%c",GRAY, (i+1),LIMEGREEN,strafe_sync,PERCENT);
			else
				Format(szStrafeSync2, 255, "%c - %i.%c %i%c",GRAY, (i+1),LIMEGREEN,strafe_sync,PERCENT);
			StrCat(szStrafeSync, sizeof(szStrafeSync), szStrafeSync2);
			if ((i+1) == strafes)
			{
				Format(szStrafeSync2, 255, " %c[%c%i%c%c]",GRAY,PURPLE, sync,PERCENT,GRAY);
				StrCat(szStrafeSync, sizeof(szStrafeSync), szStrafeSync2);
			}
		}	
	}
	else
		Format(szStrafeSync,255, "");
		
	decl String:szStrafeStats[1024];
	decl String:szGained[16];
	decl String:szLost[16];
	//Format StrafeStats Console
	if(strafes > 1)
	{
		Format(szStrafeStats,1024, " #. Sync        Gained      Lost        MaxSpeed\n");
		for( new i = 0; i < strafes; i++ )
		{
			decl sync2;
			sync2 = RoundToNearest(g_js_Strafe_Good_Sync[client][i] / g_js_Strafe_Frames[client][i] * 100.0);
			if (sync2 < 0)
				sync2 = 0;
			if (g_js_Strafe_Gained[client][i] < 10.0)
				Format(szGained,16, "%.3f ", g_js_Strafe_Gained[client][i]);
			else
				Format(szGained,16, "%.3f", g_js_Strafe_Gained[client][i]);
			if (g_js_Strafe_Lost[client][i] < 10.0)
				Format(szLost,16, "%.3f ", g_js_Strafe_Lost[client][i]);
			else
				Format(szLost,16, "%.3f", g_js_Strafe_Lost[client][i]);				
			Format(szStrafeStats,1024, "%s%2i. %3i%s        %s      %s      %3.3f\n",\
			szStrafeStats,\
			i + 1,\
			sync2,\
			PERCENT,\
			szGained,\
			szLost,\
			g_js_Strafe_Max_Speed[client][i]);
		}
	}
	else
		Format(szStrafeStats,1024, "");


					
	//ladderjump
	if (g_bLadderJump[client])
	{
		new Float: fHeightOffset = (g_js_fJump_JumpOff_Pos[client][2] - g_js_fJump_Landing_Pos[client][2]);
		if (fHeightOffset <= 10.0)
		{
			g_js_fJump_JumpOff_Pos[client][2] = g_js_fJump_Landing_Pos[client][2];
			fGroundDiff = 0.0;
			fGroundDiff2 = 0.0;	
			g_js_fJump_Distance[client] = GetVectorDistance(g_js_fJump_JumpOff_Pos[client], g_js_fJump_Landing_Pos[client]);			
		}	
		new Float: fSumLadderDir = g_js_fLadderDirection[client] / float(g_js_LadderDirectionCounter[client]);	
		new Float: max;
		if (g_js_fJump_Distance[client] < 80.0)
			max = 0.3;
		else
			max = 0.5;
		if (fSumLadderDir < max)
		{
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
			PostThinkPost(client, ground_frames);
			return;		
		}
		
	}
	
	decl Float:maxdiff,Float:maxdiff2;
	//vertical jump/failstats
	if (IsFakeClient(client))
	{
		maxdiff = 2.0;
		maxdiff2 = maxdiff * -1;
	}
	else
	{
		maxdiff = 1.82;
		maxdiff2 = maxdiff * -1;
	}
	if (fGroundDiff2 > maxdiff || fGroundDiff2 < maxdiff2 || fGroundDiff != 0.0)
	{		
		if (g_js_block_lj_valid[client])
		{
			decl String:sBlock[32];	
			Format(sBlock, 32, "%T", "LjBlock", client, GRAY,YELLOW,g_BlockDist[client],GRAY);	
			decl Float:fFailedDistance;
			fFailedDistance = GetVectorDistance(g_js_fJump_JumpOff_Pos[client], g_fFailedLandingPos[client]) + 32.0;		
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>Failed (%.3f)</font>", fFailedDistance);
			PrintToConsole(client, "[FailStats] Block %i - Distance: %.4f, Pre %.3f, Max %.3f, Height %.1f, Sync %i%c, JumpOff Edge %.3f", g_BlockDist[client],fFailedDistance,g_js_fPreStrafe[client],g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fEdgeDistJumpOff[client]);
			PrintToConsole(client, "%s", szStrafeStats);
			PrintToChat(client, "%t", "ClientLongJumpBlockFailstats", MOSSGREEN,WHITE,GRAY,GRAY,LIGHTBLUE,fFailedDistance,GRAY,LIGHTBLUE,strafes,GRAY, LIGHTBLUE,g_js_fPreStrafe[client], GRAY,LIGHTBLUE,g_js_fMax_Speed_Final[client],GRAY,LIGHTBLUE,fJump_Height,GRAY,LIGHTBLUE,sync,PERCENT,GRAY,LIGHTBLUE,g_fEdgeDistJumpOff[client],GRAY,sBlock);				
			PostThinkPost(client, ground_frames);
			return;
		}
		Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>vertical</font>");
		PostThinkPost(client, ground_frames);
		return;
	}	

	decl String:sDirection[32];
	//Get jump direction
	if (g_fMovingDirection[client] > 3.0)
		Format(sDirection, 32, "");
	else
	if (g_fMovingDirection[client] < -3.0)
		Format(sDirection, 32, " (bw)");	
	else
		Format(sDirection, 32, " (sw)");
		
	//t00-b4d
	if((g_js_fJump_Distance[client] < 150.0 && !g_bLadderJump[client]) || (g_bLadderJump[client] && g_js_fJump_Distance[client] < 40.0))
	{
		//multibhop count proforma
		if (g_js_Last_Ground_Frames[client] < 11 && ground_frames < 11 && fGroundDiff == 0.0  && fJump_Height <= 67.0 && !g_js_bDropJump[client])
			g_js_MultiBhop_Count[client]++;
		else
			g_js_MultiBhop_Count[client]=1;
		if (fGroundDiff==0.0)
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>%.3f units%s</font>", g_js_fJump_Distance[client],sDirection);
		else
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>vertical</font>");
		PostThinkPost(client, ground_frames);
		return;
	}
	
	//change BotName (szName) for jumpstats output
	if (client == g_ProBot)
		Format(szName,sizeof(szName), "%s (Pro Replay)", g_szReplayName);		
	if (client == g_TpBot)
		Format(szName,sizeof(szName), "%s (TP Replay)", g_szReplayNameTp);	
	
	
	//invalid jump
	if (g_fAirTime[client] > 0.83 && !IsFakeClient(client))
	{
		Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
		PostThinkPost(client, ground_frames);
		return;		
	}
	
	decl bool: ValidJump;
	ValidJump=false;
	
	//LadderJump
	if (g_bLadderJump[client] && fGroundDiff == 0.0 && fJump_Height <= 75.0)
	{						
		//block invalid bot distances (has something to do with the ground-detection of the replay bot) WORKAROUND
		if ((IsFakeClient(client) && g_js_fJump_Distance[client] > (g_dist_leet_ladder * 1.05)) || strafes > 20)
		{
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
			PostThinkPost(client, ground_frames);
			return;
		}
		
		Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>%.3f units%s</font>", g_js_fJump_Distance[client],sDirection);
		//good
		if (g_js_fJump_Distance[client] >= g_dist_good_ladder && g_js_fJump_Distance[client] < g_dist_pro_ladder)	
		{
			ValidJump = true;
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#676060'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
			g_js_LeetJump_Count[client]=0;	
			PrintToChat(client, "%t", "ClientLadderJump1",MOSSGREEN,WHITE, GRAY,g_js_fJump_Distance[client],LIMEGREEN, strafes, GRAY, LIMEGREEN, g_js_fPreStrafe[client], GRAY, LIMEGREEN,fJump_Height,GRAY, LIMEGREEN,sync,PERCENT,GRAY);	
			PrintToConsole(client, "        ");
			PrintToConsole(client, "[KZ] %s jumped %0.4f units with a LadderJump%s [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync| %.3fs AirTime]",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client]);						
			PrintToConsole(client, "%s", szStrafeStats);
		}	
		else
			//pro
			if (g_js_fJump_Distance[client] >= g_dist_pro_ladder && g_js_fJump_Distance[client] < g_dist_leet_ladder)
			{		
				ValidJump = true;
				g_js_LeetJump_Count[client]=0;
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#21982a'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
				PrintToConsole(client, "        ");
				PrintToChat(client, "%t", "ClientLadderJump2",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN,g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY);
				PrintToConsole(client, "[KZ] %s jumped %0.4f units with a LadderJump%s [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync| %.3fs AirTime]",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client]);						
				PrintToConsole(client, "%s", szStrafeStats);
				decl String:buffer[255];
				Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH); 
				if (g_bEnableQuakeSounds[client])
					ClientCommand(client, buffer); 
				PlayQuakeSound_Spec(client,buffer);	
				//all
				if (!IsFakeClient(client))
					for (new i = 1; i <= MaxClients; i++)
					{
						if (IsValidClient(i))
						{
							if (g_bColorChat[i]==true && i != client)
								PrintToChat(i, "%t", "Jumpstats_LadderJumpAll",MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_js_fJump_Distance[client],MOSSGREEN,GREEN,sDirection);
						}
					}
			}
			//leet
			else
				if (g_js_fJump_Distance[client] >= g_dist_leet_ladder)	
				{				
					// strafe hack protection					
					if (strafes == 0)
					{
						Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
						PostThinkPost(client, ground_frames);
						return;
					}
					ValidJump = true;
					Format(g_js_szLastJumpDistance[client], 256, "<font color='#9a0909'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);		
					g_js_LeetJump_Count[client]++;
					//Client
					PrintToConsole(client, "        ");
					PrintToChat(client, "%t", "ClientLadderJump2",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN,fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);	
					PrintToConsole(client, "[KZ] %s jumped %0.4f units with a LadderJump%s [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync| %.3fs AirTime]",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client]);
					PrintToConsole(client, "%s", szStrafeStats);
					if (g_js_LeetJump_Count[client]==3)
						PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
					else
						if (g_js_LeetJump_Count[client]==5)
							PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
							
					//all
					if (!IsFakeClient(client))
						for (new i = 1; i <= MaxClients; i++)
						{
							if (IsValidClient(i))
							{
								if (g_bColorChat[i]==true && i != client)
								{
									PrintToChat(i, "%t", "Jumpstats_LadderJumpAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_js_fJump_Distance[client], RED,DARKRED,sDirection);
									if (g_js_LeetJump_Count[client]==3)
											PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
									else
										if (g_js_LeetJump_Count[client]==5)
											PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
								}
							}	
						}
					PlayLeetJumpSound(client);	
					if (g_js_LeetJump_Count[client] != 3 && g_js_LeetJump_Count[client] != 5)
					{
						decl String:buffer[255];
						Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH); 	
						PlayQuakeSound_Spec(client,buffer);
					}
				}		
				else
					g_js_LeetJump_Count[client]=0;
		
		//strafesync chat
		if (g_bStrafeSync[client] && g_js_fJump_Distance[client] >= g_dist_good_ladder)
			PrintToChat(client,"%s", szStrafeSync);	
		
		//new best
		if (g_js_fPersonal_LadderJump_Record[client] < g_js_fJump_Distance[client]  &&  !IsFakeClient(client) && ValidJump)
		{
			if (g_js_fPersonal_LadderJump_Record[client] > 0.0)
				PrintToChat(client, "%t", "Jumpstats_BeatLadderJumpBest",MOSSGREEN,WHITE,YELLOW, g_js_fJump_Distance[client]);
			g_js_fPersonal_LadderJump_Record[client] = g_js_fJump_Distance[client];
			db_updateLadderJumpRecord(client);
		}				
	}
	
	//Chat Output
	//LongJump
	if (!g_bLadderJump[client] && ground_frames > 11 && fGroundDiff == 0.0 && fJump_Height <= 67.0 && g_js_fJump_Distance[client] < 300.0 && g_js_fMax_Speed_Final[client] > 200.0) 
	{	
		//strafe hack block (aimware is pretty smart :/) (1/2)
		if (g_bPreStrafe && !IsFakeClient(client))
		{
			if ((g_Server_Tickrate == 64 && strafes < 4 && g_js_fJump_Distance[client] > 265.0) || (g_Server_Tickrate == 102 && strafes < 4 && g_js_fJump_Distance[client] > 270.0) || (g_Server_Tickrate == 128 && strafes < 4 && g_js_fJump_Distance[client] > 275.0)) 
			{
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
				PostThinkPost(client, ground_frames);
				return;
			}				
		}
		else
		{
			if ((g_Server_Tickrate == 64 && strafes < 4 && g_js_fJump_Distance[client] > 250.0) || (g_Server_Tickrate == 102 && strafes < 4 && g_js_fJump_Distance[client] > 255.0) || (g_Server_Tickrate == 128 && strafes < 4 && g_js_fJump_Distance[client] > 260.0)) 
			{
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
				PostThinkPost(client, ground_frames);
				return;
			}
		}
		if (strafes > 20 && !IsFakeClient(client))
		{
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
			PostThinkPost(client, ground_frames);
			return;
		}			
		///
		//block invalid bot distances (has something to do with the ground-detection of the replay bot) WORKAROUND
		if (IsFakeClient(client) && g_js_fJump_Distance[client] > (g_dist_leet_lj * 1.025))
		{
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
			PostThinkPost(client, ground_frames);
			return;
		}
		
		//prestrafe on/off
		decl String:szVr[16];
		decl bool: prestrafe;
		if (!g_bPreStrafe)	
		{
			g_js_fPreStrafe[client] = g_js_fJumpOff_Speed[client];
			Format(szVr, 16, "JumpOff");
			prestrafe = false;
		}
		else
		{
			prestrafe = true;
			Format(szVr, 16, "Pre");		
		}
		//strafe hack block (aimware is pretty smart :/) (2/2)
		if (g_js_fPreStrafe[client] > 278.0 || g_js_fPreStrafe[client] < 200.0)
		{
			if (g_js_fPreStrafe[client] < 200.0)
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>%.3f units%s</font>", g_js_fJump_Distance[client],sDirection);
			PostThinkPost(client, ground_frames);
			return;
		}			
		decl Float:temp[3];
		decl bool:ljblock;
		ljblock=false;	
		decl Float:LandingEdge;
		decl String:sBlockDist[32];	
		Format(sBlockDist, 32, "");	
		decl String:sBlockDistCon[32];	
		Format(sBlockDistCon, 32, "");		
		if(g_bLJBlock[client] && g_BlockDist[client] > 225 && g_js_fJump_Distance[client] >= float(g_BlockDist[client]))
		{
			if (g_js_block_lj_valid[client])
			{
				if (g_js_block_lj_jumpoff_pos[client])
				{
					if (IsCoordInBlockPoint(g_js_fJump_Landing_Pos[client],g_fOriginBlock[client],true))
					{
						GetEdgeOrigin1(client, g_fLastPosition[client], temp);
						LandingEdge = GetVectorDistance(temp, g_fLastPosition[client]);
						Format(sBlockDist, 32, "%T", "LjBlock", client,GRAY,YELLOW,g_BlockDist[client],GRAY);	
						Format(sBlockDistCon, 32, " [%i block]", g_BlockDist[client]);	
						ljblock=true;
					}
				}
				else
				{
					if (IsCoordInBlockPoint(g_js_fJump_Landing_Pos[client],g_fDestBlock[client],true))
					{
						GetEdgeOrigin2(client, g_fLastPosition[client], temp);
						LandingEdge = GetVectorDistance(temp, g_fLastPosition[client]);
						Format(sBlockDist, 32, "%T", "LjBlock", client,GRAY,YELLOW,g_BlockDist[client],GRAY);	
						Format(sBlockDistCon, 32, " [%i block]", g_BlockDist[client]);	
						ljblock=true;			
					}
				}
			}
		}
		Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>%.3f units%s</font>", g_js_fJump_Distance[client],sDirection);
		//good?
		if (g_js_fJump_Distance[client] >= g_dist_good_lj && g_js_fJump_Distance[client] < g_dist_pro_lj)	
		{		
			ValidJump=true;
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#676060'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
			CreateTimer(0.1, BhopCheck, client,TIMER_FLAG_NO_MAPCHANGE);
			if (prestrafe)
				PrintToChat(client, "%t", "ClientLongJump1", MOSSGREEN,WHITE,GRAY, g_js_fJump_Distance[client],LIMEGREEN,strafes,GRAY, LIMEGREEN, g_js_fPreStrafe[client], GRAY,LIMEGREEN,g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);			
			else
				PrintToChat(client, "%t", "ClientLongJump2",MOSSGREEN,WHITE,GRAY, g_js_fJump_Distance[client],LIMEGREEN,strafes,GRAY, LIMEGREEN, g_js_fPreStrafe[client], GRAY,LIMEGREEN,g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);			
				
			PrintToConsole(client, "        ");
			if (ljblock)
				PrintToConsole(client, "[KZ] %s jumped %0.4f units with a LongJump%s [%i Strafes | %.3f %s | %.0f Max | Height %.1f | %i%c Sync | AirTime %.3fs | JumpOff Edge %.3f | Landing Edge %.3f]%s",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], szVr,g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client], g_fEdgeDistJumpOff[client],LandingEdge,sBlockDistCon);
			else
				PrintToConsole(client, "[KZ] %s jumped %0.4f units with a LongJump%s [%i Strafes | %.3f %s | %.0f Max | Height %.1f | %i%c Sync | AirTime %.3fs]%s",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], szVr,g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client], sBlockDistCon);			
			PrintToConsole(client, "%s", szStrafeStats);
			}
		else
			//pro?
			if (g_js_fJump_Distance[client] >= g_dist_pro_lj && g_js_fJump_Distance[client] < g_dist_leet_lj)	
			{
				ValidJump=true;
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#21982a'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
				CreateTimer(0.1, BhopCheck, client,TIMER_FLAG_NO_MAPCHANGE);
				//chat & sound client		
				PrintToConsole(client, "        ");
				if (ljblock)
					PrintToConsole(client, "[KZ] %s jumped %0.4f units with a LongJump%s [%i Strafes | %.3f %s | %.0f Max | Height %.1f | %i%c Sync | AirTime %.3fs | JumpOff Edge %.3f | Landing Edge %.3f]%s",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], szVr,g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client], g_fEdgeDistJumpOff[client],LandingEdge,sBlockDistCon);
				else
					PrintToConsole(client, "[KZ] %s jumped %0.4f units with a LongJump%s [%i Strafes | %.3f %s | %.0f Max | Height %.1f | %i%c Sync | AirTime %.3fs]%s",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], szVr,g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client], sBlockDistCon);			
				PrintToConsole(client, "%s", szStrafeStats);	
				if (prestrafe)
					PrintToChat(client, "%t", "ClientLongJump3",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN,g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);
				else
					PrintToChat(client, "%t", "ClientLongJump4",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN,g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);
					
				decl String:buffer[255];
				Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH); 			
				if (g_bEnableQuakeSounds[client])
					ClientCommand(client, buffer); 						
				PlayQuakeSound_Spec(client,buffer);		
				//chat all
				if (!IsFakeClient(client))
					for (new i = 1; i <= MaxClients; i++)
					{
						if (IsValidClient(i) && i != client)
						{				 					
							if (g_bColorChat[i])
								PrintToChat(i, "%t", "Jumpstats_LjAll",MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_js_fJump_Distance[client],MOSSGREEN,GREEN,sDirection,sBlockDist);
						}
					}				
			}	
			//leet?
			else		
			{			
				if (g_js_fJump_Distance[client] >= g_dist_leet_lj && g_js_fMax_Speed_Final[client] > 275.0)	
				{
					// strafe hack protection					
					if (strafes == 0)
					{
						Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
						PostThinkPost(client, ground_frames);
						return;
					}
					ValidJump=true;
					Format(g_js_szLastJumpDistance[client], 256, "<font color='#9a0909'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
					g_js_LeetJump_Count[client]++;
					//client		
					PrintToConsole(client, "        ");
					if (ljblock)
							PrintToConsole(client, "[KZ] %s jumped %0.4f units with a LongJump%s [%i Strafes | %.3f %s | %.0f Max | Height %.1f | %i%c Sync | AirTime %.3fs | JumpOff Edge %.3f | Landing Edge %.3f]%s",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], szVr,g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client], g_fEdgeDistJumpOff[client],LandingEdge,sBlockDistCon);
					else
						PrintToConsole(client, "[KZ] %s jumped %0.4f units with a LongJump%s [%i Strafes | %.3f %s | %.0f Max | Height %.1f | %i%c Sync | AirTime %.3fs]%s",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], szVr,g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client], sBlockDistCon);			
					PrintToConsole(client, "%s", szStrafeStats);		
					if (prestrafe)					
						PrintToChat(client, "%t", "ClientLongJump3",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);
					else
						PrintToChat(client, "%t", "ClientLongJump4",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY,LIMEGREEN, sync,PERCENT,GRAY,sBlockDist);			
					if (g_js_LeetJump_Count[client]==3)
						PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
					else
						if (g_js_LeetJump_Count[client]==5)
							PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
					
					//all
					if (!IsFakeClient(client))
						for (new i = 1; i <= MaxClients; i++)
						{
							if (IsValidClient(i))
							{						
								if (g_bColorChat[i] && i != client)
								{
									PrintToChat(i, "%t", "Jumpstats_LjAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_js_fJump_Distance[client],RED,DARKRED,sDirection,sBlockDist);
									if (g_js_LeetJump_Count[client]==3)
										PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
									else
										if (g_js_LeetJump_Count[client]==5)
											PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
								}
							}
						}
					PlayLeetJumpSound(client);
					if (g_js_LeetJump_Count[client] != 3 && g_js_LeetJump_Count[client] != 5)
					{
						decl String:buffer[255];
						Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH); 	
						PlayQuakeSound_Spec(client,buffer);
					}
				}
				else
					CreateTimer(0.1, BhopCheck, client,TIMER_FLAG_NO_MAPCHANGE);
					
			}
	
		//strafe sync chat
		if (g_bStrafeSync[client] && g_js_fJump_Distance[client] >= g_dist_good_lj)
			PrintToChat(client,"%s", szStrafeSync);		
				
		//new best
		if (((g_js_fPersonal_Lj_Record[client] < g_js_fJump_Distance[client]) || (ljblock && g_js_Personal_LjBlock_Record[client] < g_BlockDist[client]) || (ljblock && g_js_Personal_LjBlock_Record[client] == g_BlockDist[client] && g_js_fPersonal_LjBlockRecord_Dist[client] < g_js_fJump_Distance[client])) && !IsFakeClient(client))
		{		
			if (ValidJump)
			{
				if (g_js_fPersonal_Lj_Record[client] > 0.0 && g_js_fPersonal_Lj_Record[client] < g_js_fJump_Distance[client])
					PrintToChat(client, "%t", "Jumpstats_BeatLjBest",MOSSGREEN,WHITE,YELLOW, g_js_fJump_Distance[client]);
				if (ljblock && g_js_Personal_LjBlock_Record[client] > 0 && ((g_js_Personal_LjBlock_Record[client] < g_BlockDist[client]) || (g_js_Personal_LjBlock_Record[client] == g_BlockDist[client] && g_js_fPersonal_LjBlockRecord_Dist[client] < g_js_fJump_Distance[client])))
					PrintToChat(client, "%t", "Jumpstats_BeatLjBlockBest",MOSSGREEN,WHITE,YELLOW, g_BlockDist[client],g_js_fJump_Distance[client]);
				if (g_js_fPersonal_Lj_Record[client] < g_js_fJump_Distance[client])
				{	
					g_js_fPersonal_Lj_Record[client] = g_js_fJump_Distance[client];
					db_updateLjRecord(client);
				}
				if (g_js_Personal_LjBlock_Record[client] < g_BlockDist[client] && ljblock || (ljblock && g_js_Personal_LjBlock_Record[client] == g_BlockDist[client] && g_js_fPersonal_LjBlockRecord_Dist[client] < g_js_fJump_Distance[client]))
				{
					g_js_Personal_LjBlock_Record[client] = g_BlockDist[client];
					g_js_fPersonal_LjBlockRecord_Dist[client] = g_js_fJump_Distance[client];
					db_updateLjBlockRecord(client);
				}
			}			
		}
	}
	//Multi Bhop
	if (!g_bLadderJump[client] && g_js_Last_Ground_Frames[client] < 11 && ground_frames < 11 && fGroundDiff == 0.0  && fJump_Height <= 68.0 && !g_js_bDropJump[client])
	{		
		
		g_js_MultiBhop_Count[client]++;	
		//strafe hack block 
		new Float: SpeedCapAdv = g_fBhopSpeedCap + 0.5;
		if ((g_js_fPreStrafe[client] > SpeedCapAdv) || ((g_js_MultiBhop_Count[client] == 1 && g_js_fPreStrafe[client] > 350.0) || strafes > 20) || (g_fBhopSpeedCap == 380.0 && g_js_fJump_Distance[client] > 365.0))
		{
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
			PostThinkPost(client, ground_frames);
			return;		
		}

		//block invalid bot distances (has something to do with the ground-detection of the replay bot) WORKAROUND
		if (IsFakeClient(client) && g_js_fJump_Distance[client] > (g_dist_leet_multibhop * 1.025))
		{
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
			PostThinkPost(client, ground_frames);
			return;
		}
			
		
		//format bhop count
		decl String:szBhopCount[255];
		Format(szBhopCount, sizeof(szBhopCount), "%i", g_js_MultiBhop_Count[client]);
		if (g_js_MultiBhop_Count[client] > 8)
			Format(szBhopCount, sizeof(szBhopCount), "> 8");
		
		Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>%.3f units%s</font>", g_js_fJump_Distance[client],sDirection);
		//good?	
		if (g_js_fJump_Distance[client] >= g_dist_good_multibhop && g_js_fJump_Distance[client] < g_dist_pro_multibhop)	
		{
			ValidJump=true;
			Format(g_js_szLastJumpDistance[client], 256, "<font color='#676060'><b>%.1f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
			g_js_LeetJump_Count[client]=0;
			PrintToChat(client, "%t", "ClientMultiBhop1",MOSSGREEN,WHITE, GRAY, g_js_fJump_Distance[client],LIMEGREEN, strafes, GRAY, LIMEGREEN, g_js_fPreStrafe[client], GRAY, LIMEGREEN, sync,PERCENT,GRAY);	
			PrintToConsole(client, "        ");
			PrintToConsole(client, "[KZ] %s jumped %0.4f units with a MultiBhop%s [%i Strafes | %3.f Pre | %3.f Max | Height %.1f | %s Bhops | %i%c Sync| %.3fs AirTime]",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], fJump_Height,szBhopCount,sync,PERCENT,g_fAirTime[client]);				
			PrintToConsole(client, "%s", szStrafeStats);
		}	
		else
			//pro?
			if (g_js_fJump_Distance[client] >= g_dist_pro_multibhop && g_js_fJump_Distance[client] < g_dist_leet_multibhop)
			{	
				ValidJump=true;
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#21982a'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
				g_js_LeetJump_Count[client]=0;
				//Client
				PrintToConsole(client, "        ");
				PrintToConsole(client, "[KZ] %s jumped %0.4f units with a MultiBhop%s [%i Strafes | %.3f Pre | %.3f Max |  Height %.1f | %s Bhops | %i%c Sync| %.3fs AirTime]",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], fJump_Height,szBhopCount,sync,PERCENT,g_fAirTime[client]);				
				PrintToConsole(client, "%s", szStrafeStats);					
				PrintToChat(client, "%t", "ClientMultiBhop2",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN,g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN,szBhopCount,GRAY,LIMEGREEN, sync,PERCENT,GRAY);
				
				decl String:buffer[255];
				Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH); 
				if (g_bEnableQuakeSounds[client])
					ClientCommand(client, buffer); 
				PlayQuakeSound_Spec(client,buffer);				
				//all
				if (!IsFakeClient(client))
					for (new i = 1; i <= MaxClients; i++)
					{
						if (IsValidClient(i))
						{
							if (g_bColorChat[i] && i != client)					
								PrintToChat(i, "%t", "Jumpstats_MultiBhopAll",MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_js_fJump_Distance[client],MOSSGREEN,GREEN,sDirection);
						}
					}
			}
			//leet?
			else
			if (g_js_fJump_Distance[client] >= g_dist_leet_multibhop)	
			{
				// strafe hack protection					
				if (strafes == 0 || g_js_fPreStrafe[client] < 270.0)
				{
					Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
					PostThinkPost(client, ground_frames);
					return;
				}
				ValidJump=true;
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#9a0909'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
				g_js_LeetJump_Count[client]++;
				//Client
				PrintToConsole(client, "        ");
				PrintToConsole(client, "[KZ] %s jumped %0.4f units with a MultiBhop%s [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %s Bhops | %i%c Sync| %.3fs AirTime]",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client], fJump_Height,szBhopCount,sync,PERCENT,g_fAirTime[client]);
				PrintToConsole(client, "%s", szStrafeStats);
				PrintToChat(client, "%t", "ClientMultiBhop2",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN,g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN,szBhopCount,GRAY,LIMEGREEN, sync,PERCENT,GRAY);
				if (g_js_LeetJump_Count[client]==3)
					PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
				else
				if (g_js_LeetJump_Count[client]==5)
					PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);						
			
				//all
				if (!IsFakeClient(client))
					for (new i = 1; i <= MaxClients; i++)
					{
						if (IsValidClient(i))
						{
							if (g_bColorChat[i] && i != client)
							{
								PrintToChat(i, "%t", "Jumpstats_MultiBhopAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_js_fJump_Distance[client],RED,DARKRED,sDirection);
								if (g_js_LeetJump_Count[client]==3)
										PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
									else
									if (g_js_LeetJump_Count[client]==5)
										PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
							}
						}
					}
				PlayLeetJumpSound(client);	
				if (g_js_LeetJump_Count[client] != 3 && g_js_LeetJump_Count[client] != 5)
				{
					decl String:buffer[255];
					Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH); 	
					PlayQuakeSound_Spec(client,buffer);
				}
			}	
			else
				g_js_LeetJump_Count[client]=0;
		
		//strafe sync chat
		if (g_bStrafeSync[client] && g_js_fJump_Distance[client] >= g_dist_good_multibhop)
			PrintToChat(client,"%s", szStrafeSync);		
		
		//new best
		if (g_js_fPersonal_MultiBhop_Record[client] < g_js_fJump_Distance[client] &&  !IsFakeClient(client) && ValidJump)
		{
			if (g_js_fPersonal_MultiBhop_Record[client] > 0.0)
				PrintToChat(client, "%t", "Jumpstats_BeatMultiBhopBest",MOSSGREEN,WHITE,YELLOW, g_js_fJump_Distance[client]);
			g_js_fPersonal_MultiBhop_Record[client] = g_js_fJump_Distance[client];
			db_updateMultiBhopRecord(client);
		}
	}
	else
		g_js_MultiBhop_Count[client] = 1;	

	//dropbhop
	if (!g_bLadderJump[client] && ground_frames < 11 && g_js_Last_Ground_Frames[client] > 11 && g_bLastButtonJump[client] && fGroundDiff == 0.0 && fJump_Height <= 67.0 && g_js_bDropJump[client])
	{		
		if (g_js_fDropped_Units[client] > 132.0)
		{
			if (g_js_fDropped_Units[client] < 300.0)
				PrintToChat(client, "%t", "DropBhop1",MOSSGREEN,WHITE,RED,g_js_fDropped_Units[client],WHITE,GREEN,WHITE,GRAY,WHITE);
		}
		else
		{
			if (g_js_fPreStrafe[client] > g_fMaxBhopPreSpeed)
				PrintToChat(client, "%t", "DropBhop2",MOSSGREEN,WHITE,RED,g_js_fPreStrafe[client],WHITE,GREEN,g_fMaxBhopPreSpeed,WHITE,GRAY,WHITE);
			else
			{
				
				//block invalid bot distances (has something to do with the ground-detection of the replay bot) WORKAROUND
				if ((IsFakeClient(client) && g_js_fJump_Distance[client] > (g_dist_leet_dropbhop * 1.05)) || strafes > 20)
				{
					Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
					PostThinkPost(client, ground_frames);
					return;
				}
				
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>%.3f units%s</font>", g_js_fJump_Distance[client],sDirection);
				//good
				if (g_js_fJump_Distance[client] >= g_dist_good_dropbhop && g_js_fJump_Distance[client] < g_dist_pro_dropbhop)	
				{
					ValidJump = true;
					Format(g_js_szLastJumpDistance[client], 256, "<font color='#676060'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
					g_js_LeetJump_Count[client]=0;	
					PrintToChat(client, "%t", "ClientDropBhop1",MOSSGREEN,WHITE, GRAY,g_js_fJump_Distance[client],LIMEGREEN, strafes, GRAY, LIMEGREEN, g_js_fPreStrafe[client], GRAY, LIMEGREEN,fJump_Height,GRAY, LIMEGREEN,sync,PERCENT,GRAY);	
					PrintToConsole(client, "        ");
					PrintToConsole(client, "[KZ] %s jumped %0.4f units with a DropBhop%s [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync| %.3fs AirTime]",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client]);						
					PrintToConsole(client, "%s", szStrafeStats);
				}	
				else
					//pro
					if (g_js_fJump_Distance[client] >= g_dist_pro_dropbhop && g_js_fJump_Distance[client] < g_dist_leet_dropbhop)
					{		
						ValidJump = true;
						g_js_LeetJump_Count[client]=0;
						Format(g_js_szLastJumpDistance[client], 256, "<font color='#21982a'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
						PrintToConsole(client, "        ");
						PrintToChat(client, "%t", "ClientDropBhop2",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN,sync,PERCENT,GRAY);	
						PrintToConsole(client, "[KZ] %s jumped %0.4f units with a DropBhop%s [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync| %.3fs AirTime]",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client]);						
						PrintToConsole(client, "%s", szStrafeStats);
						decl String:buffer[255];
						Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH); 
						if (g_bEnableQuakeSounds[client])
							ClientCommand(client, buffer); 
						PlayQuakeSound_Spec(client,buffer);	
						//all
						if (!IsFakeClient(client))
							for (new i = 1; i <= MaxClients; i++)
							{
								if (IsValidClient(i))
								{
									if (g_bColorChat[i]==true && i != client)
										PrintToChat(i, "%t", "Jumpstats_DropBhopAll",MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_js_fJump_Distance[client],MOSSGREEN,GREEN,sDirection);
								}
							}
					}
					//leet
					else
						if (g_js_fJump_Distance[client] >= g_dist_leet_dropbhop  && g_js_fMax_Speed_Final[client] > 330.0)	
						{				
							// strafe hack protection					
							if (strafes == 0 || g_js_fPreStrafe[client] < 270.0)
							{
								Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
								PostThinkPost(client, ground_frames);
								return;
							}
							ValidJump = true;
							Format(g_js_szLastJumpDistance[client], 256, "<font color='#9a0909'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);		
							g_js_LeetJump_Count[client]++;
							//Client
							PrintToConsole(client, "        ");
							PrintToChat(client, "%t", "ClientDropBhop2",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN,fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);	
							PrintToConsole(client, "[KZ] %s jumped %0.4f units with a DropBhop%s [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync| %.3fs AirTime]",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client]);
							PrintToConsole(client, "%s", szStrafeStats);
							if (g_js_LeetJump_Count[client]==3)
								PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
							else
								if (g_js_LeetJump_Count[client]==5)
									PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
									
							//all
							if (!IsFakeClient(client))
								for (new i = 1; i <= MaxClients; i++)
								{
									if (IsValidClient(i))
									{
										if (g_bColorChat[i]==true && i != client)
										{
											PrintToChat(i, "%t", "Jumpstats_DropBhopAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_js_fJump_Distance[client], RED,DARKRED,sDirection);
											if (g_js_LeetJump_Count[client]==3)
													PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
											else
												if (g_js_LeetJump_Count[client]==5)
													PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
										}
									}	
								}
							PlayLeetJumpSound(client);	
							if (g_js_LeetJump_Count[client] != 3 && g_js_LeetJump_Count[client] != 5)
							{
								decl String:buffer[255];
								Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH); 	
								PlayQuakeSound_Spec(client,buffer);
							}
						}		
						else
							g_js_LeetJump_Count[client]=0;
				
				//strafesync chat
				if (g_bStrafeSync[client] && g_js_fJump_Distance[client] >= g_dist_good_dropbhop)
					PrintToChat(client,"%s", szStrafeSync);	
				
				//new best
				if (g_js_fPersonal_DropBhop_Record[client] < g_js_fJump_Distance[client]  &&  !IsFakeClient(client) && ValidJump)
				{
					if (g_js_fPersonal_DropBhop_Record[client] > 0.0)
						PrintToChat(client, "%t", "Jumpstats_BeatDropBhopBest",MOSSGREEN,WHITE,YELLOW, g_js_fJump_Distance[client]);
					g_js_fPersonal_DropBhop_Record[client] = g_js_fJump_Distance[client];
					db_updateDropBhopRecord(client);
				}				
			}
		}
	}
	// WeirdJump
	if (!g_bLadderJump[client] && ground_frames < 11 && !g_bLastButtonJump[client] && fGroundDiff == 0.0 && fJump_Height <= 67.0 && g_js_bDropJump[client])
	{						
			if (g_js_fDropped_Units[client] > 132.0)
			{
				if (g_js_fDropped_Units[client] < 300.0)
					PrintToChat(client, "%t", "Wj1",MOSSGREEN,WHITE,RED,g_js_fDropped_Units[client],WHITE,GREEN,WHITE,GRAY,WHITE);
			}
			else
			{
				if (g_js_fPreStrafe[client] > 300)
					PrintToChat(client, "%t", "Wj2",MOSSGREEN,WHITE,RED,g_js_fPreStrafe[client],WHITE,GREEN,WHITE,GRAY,WHITE);
				else
				{
					//block invalid bot distances (has something to do with the ground-detection of the replay bot) WORKAROUND
					if ((IsFakeClient(client) && g_js_fJump_Distance[client] > (g_dist_leet_weird * 1.05)) || strafes > 20)
					{
						Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
						PostThinkPost(client, ground_frames);
						return;
					}					
						

					Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>%.3f units%s</font>", g_js_fJump_Distance[client],sDirection);
					//good?
					if (g_js_fJump_Distance[client] >= g_dist_good_weird && g_js_fJump_Distance[client] < g_dist_pro_weird)	
					{
						ValidJump = true;
						Format(g_js_szLastJumpDistance[client], 256, "<font color='#676060'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
						g_js_LeetJump_Count[client]=0;
						PrintToChat(client, "%t", "ClientWeirdJump1",MOSSGREEN,WHITE, GRAY,g_js_fJump_Distance[client],LIMEGREEN, strafes, GRAY, LIMEGREEN, g_js_fPreStrafe[client], GRAY, LIMEGREEN,fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);	
						PrintToConsole(client, "        ");
						PrintToConsole(client, "[KZ] %s jumped %0.4f units with a WeirdJump%s [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync| %.3fs AirTime]",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client]);						
						PrintToConsole(client, "%s", szStrafeStats);	
					}	
					//pro?
					else
						if (g_js_fJump_Distance[client] >= g_dist_pro_weird && g_js_fJump_Distance[client] < g_dist_leet_weird)
						{
							ValidJump = true;
							Format(g_js_szLastJumpDistance[client], 256, "<font color='#21982a'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
							g_js_LeetJump_Count[client]=0;
							//Client
							PrintToConsole(client, "        ");
							PrintToChat(client, "%t", "ClientWeirdJump2",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN,fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
							PrintToConsole(client, "[KZ] %s jumped %0.4f units with a WeirdJump%s [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync| %.3fs AirTime]",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client]);						
							PrintToConsole(client, "%s", szStrafeStats);
							decl String:buffer[255];
							Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH); 
							if (g_bEnableQuakeSounds[client])
								ClientCommand(client, buffer); 
							PlayQuakeSound_Spec(client,buffer);	
							//all
							if (!IsFakeClient(client))
								for (new i = 1; i <= MaxClients; i++)
								{
									if (IsValidClient(i))
									{
										if (g_bColorChat[i]==true && i != client)
											PrintToChat(i, "%t", "Jumpstats_WeirdAll",MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_js_fJump_Distance[client],MOSSGREEN,GREEN,sDirection);
									}
								}
						}
						//leet?
						else
							if (g_js_fJump_Distance[client] >= g_dist_leet_weird)	
							{
								// strafe hack protection					
								if (strafes == 0 || g_js_fPreStrafe[client] < 255.0)
								{
									Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
									PostThinkPost(client, ground_frames);
									return;
								}
								ValidJump = true;
								Format(g_js_szLastJumpDistance[client], 256, "<font color='#9a0909'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
								g_js_LeetJump_Count[client]++;
								//Client
								PrintToConsole(client, "        ");
								PrintToChat(client, "%t", "ClientWeirdJump2",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN,fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
								PrintToConsole(client, "[KZ] %s jumped %0.4f units with a WeirdJump%s [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync| %.3fs AirTime]",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client]);
								PrintToConsole(client, "%s", szStrafeStats);
								if (g_js_LeetJump_Count[client]==3)
									PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
								else
									if (g_js_LeetJump_Count[client]==5)
										PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
													
								//all
								if (!IsFakeClient(client))
									for (new i = 1; i <= MaxClients; i++)
									{
										if (IsValidClient(i))
										{
											if (g_bColorChat[i]==true && i != client)
											{
												PrintToChat(i, "%t", "Jumpstats_WeirdAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_js_fJump_Distance[client],RED,DARKRED,sDirection);
												if (g_js_LeetJump_Count[client]==3)
														PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
													else
													if (g_js_LeetJump_Count[client]==5)
														PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
											}
										}
									}
								PlayLeetJumpSound(client);
								if (g_js_LeetJump_Count[client] != 3 && g_js_LeetJump_Count[client] != 5)
								{
									decl String:buffer[255];
									Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH); 	
									PlayQuakeSound_Spec(client,buffer);
								}								
							}		
							else
								g_js_LeetJump_Count[client]=0;		
					
					//strafesync chat
					if (g_bStrafeSync[client]  && g_js_fJump_Distance[client] >= g_dist_good_weird)
						PrintToChat(client,"%s", szStrafeSync);	
						
					//new best
					if (g_js_fPersonal_Wj_Record[client] < g_js_fJump_Distance[client]  &&  !IsFakeClient(client) && ValidJump)
					{
						if (g_js_fPersonal_Wj_Record[client] > 0.0)
							PrintToChat(client, "%t", "Jumpstats_BeatWjBest",MOSSGREEN,WHITE,YELLOW, g_js_fJump_Distance[client]);
						g_js_fPersonal_Wj_Record[client] = g_js_fJump_Distance[client];
						db_updateWjRecord(client);
					}
				}
			}
	}
	//BunnyHop
	if (!g_bLadderJump[client] && ground_frames < 11 && g_js_Last_Ground_Frames[client] > 10 && fGroundDiff == 0.0 && fJump_Height <= 67.0 && !g_js_bDropJump[client] && g_js_fPreStrafe[client] > 200.0)
	{
			//block invalid bot distances (has something to do with the ground-detection of the replay bot) WORKAROUND
			if (((IsFakeClient(client) && g_js_fJump_Distance[client] > (g_dist_leet_bhop * 1.025)) || g_js_fJump_Distance[client] > 400.0) || strafes > 20)
			{
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
				PostThinkPost(client, ground_frames);
				return;
			}
			
			if (g_js_fPreStrafe[client]> g_fMaxBhopPreSpeed)
					PrintToChat(client, "%t", "Bhop1",MOSSGREEN,WHITE,RED,g_js_fPreStrafe[client],WHITE,GREEN,g_fMaxBhopPreSpeed,WHITE,GRAY,WHITE);
			else
			{	
				Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>%.3f units%s</font>", g_js_fJump_Distance[client],sDirection);
				//good?
				if (g_js_fJump_Distance[client] >= g_dist_good_bhop && g_js_fJump_Distance[client] < g_dist_pro_bhop)	
				{
					ValidJump=true;
					Format(g_js_szLastJumpDistance[client], 256, "<font color='#676060'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
					g_js_LeetJump_Count[client]=0;
					PrintToChat(client, "%t", "ClientBunnyhop1",MOSSGREEN,WHITE,GRAY, g_js_fJump_Distance[client],LIMEGREEN, strafes, GRAY, LIMEGREEN, g_js_fPreStrafe[client], GRAY, LIMEGREEN, fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);	
					PrintToConsole(client, "        ");
					PrintToConsole(client, "[KZ] %s jumped %0.4f units with a Bhop%s [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync| %.3fs AirTime]",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height,sync,PERCENT,g_fAirTime[client]);						
					PrintToConsole(client, "%s", szStrafeStats);
				}	
				else
					//pro?
					if (g_js_fJump_Distance[client] >= g_dist_pro_bhop && g_js_fJump_Distance[client] < g_dist_leet_bhop)
					{
						ValidJump=true;
						Format(g_js_szLastJumpDistance[client], 256, "<font color='#21982a'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
						g_js_LeetJump_Count[client]=0;
						PrintToConsole(client, "        ");
						PrintToChat(client, "%t", "ClientBunnyhop2",MOSSGREEN,WHITE,GREEN,GRAY,GREEN,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
						PrintToConsole(client, "[KZ] %s jumped %0.4f units with a Bhop%s [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync| %.3fs AirTime]",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height, sync,PERCENT,g_fAirTime[client]);						
						PrintToConsole(client, "%s", szStrafeStats);
						decl String:buffer[255];
						Format(buffer, sizeof(buffer), "play %s", PROJUMP_RELATIVE_SOUND_PATH); 
						if (g_bEnableQuakeSounds[client])
							ClientCommand(client, buffer); 
						PlayQuakeSound_Spec(client,buffer);	
						//all
						if (!IsFakeClient(client))
							for (new i = 1; i <= MaxClients; i++)
							{
								if (IsValidClient(i))
								{
									if (g_bColorChat[i]==true && i != client)
										PrintToChat(i, "%t", "Jumpstats_BhopAll",	MOSSGREEN,WHITE,GREEN,szName, MOSSGREEN,GREEN, g_js_fJump_Distance[client],MOSSGREEN,GREEN,sDirection);
								}
							}
					}
					else
					{
						//leet?
						if (g_js_fJump_Distance[client] >= g_dist_leet_bhop && g_js_fMax_Speed_Final[client] > 330.0)	
						{
							ValidJump=true;
							// strafe hack protection					
							if (strafes == 0 || g_js_fPreStrafe[client] < 270.0)
							{
								Format(g_js_szLastJumpDistance[client], 256, "<font color='#948d8d'>invalid</font>");
								PostThinkPost(client, ground_frames);
								return;
							}
							Format(g_js_szLastJumpDistance[client], 256, "<font color='#9a0909'><b>%.3f units%s</b></font>", g_js_fJump_Distance[client],sDirection);
							g_js_LeetJump_Count[client]++;
							//Client
							PrintToConsole(client, "        ");
							PrintToChat(client, "%t", "ClientBunnyhop2",MOSSGREEN,WHITE,DARKRED,GRAY,DARKRED,g_js_fJump_Distance[client],GRAY,LIMEGREEN,strafes,GRAY,LIMEGREEN,g_js_fPreStrafe[client],GRAY,LIMEGREEN, g_js_fMax_Speed_Final[client],GRAY,LIMEGREEN, fJump_Height,GRAY, LIMEGREEN, sync,PERCENT,GRAY);
							PrintToConsole(client, "[KZ] %s jumped %0.4f units with a Bhop%s [%i Strafes | %.3f Pre | %.3f Max | Height %.1f | %i%c Sync| %.3fs AirTime]",szName, g_js_fJump_Distance[client],sDirection,strafes, g_js_fPreStrafe[client], g_js_fMax_Speed_Final[client],fJump_Height, sync,PERCENT,g_fAirTime[client]);
							PrintToConsole(client, "%s", szStrafeStats);
							if (g_js_LeetJump_Count[client]==3)
								PrintToChat(client, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
							else
							if (g_js_LeetJump_Count[client]==5)
										PrintToChat(client, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
											
							//all
							if (!IsFakeClient(client))
								for (new i = 1; i <= MaxClients; i++)
								{
									if (IsValidClient(i))
									{
										if (g_bColorChat[i]==true && i != client)
										{
											PrintToChat(i, "%t", "Jumpstats_BhopAll",MOSSGREEN,WHITE,DARKRED,szName, RED,DARKRED, g_js_fJump_Distance[client],RED,DARKRED,sDirection);
											if (g_js_LeetJump_Count[client]==3)
												PrintToChat(i, "%t", "Jumpstats_OnRampage",MOSSGREEN,WHITE,YELLOW,szName);
											else
												if (g_js_LeetJump_Count[client]==5)
													PrintToChat(i, "%t", "Jumpstats_IsDominating",MOSSGREEN,WHITE,YELLOW,szName);
										}
									}
								}
							PlayLeetJumpSound(client);
							if (g_js_LeetJump_Count[client] != 3 && g_js_LeetJump_Count[client] != 5)
							{
								decl String:buffer[255];
								Format(buffer, sizeof(buffer), "play %s", LEETJUMP_RELATIVE_SOUND_PATH); 	
								PlayQuakeSound_Spec(client,buffer);
							}						
						}		
						else
						{
							g_js_LeetJump_Count[client]=0;
						}
					}
							
				//strafe sync chat
				if (g_bStrafeSync[client] && g_js_fJump_Distance[client] >= g_dist_good_bhop)
						PrintToChat(client,"%s", szStrafeSync);		
				
				//new best
				if (g_js_fPersonal_Bhop_Record[client] < g_js_fJump_Distance[client]  &&  !IsFakeClient(client) && ValidJump)
				{
					if (g_js_fPersonal_Bhop_Record[client] > 0.0)
						PrintToChat(client, "%t", "Jumpstats_BeatBhopBest",MOSSGREEN,WHITE,YELLOW, g_js_fJump_Distance[client]);
					g_js_fPersonal_Bhop_Record[client] = g_js_fJump_Distance[client];
					db_updateBhopRecord(client);
				}
			}
	}
	if (!ValidJump)
		g_js_LeetJump_Count[client]=0;
	PostThinkPost(client, ground_frames);						
}

public PostThinkPost(client, ground_frames)
{
	g_js_bPlayerJumped[client] = false;
	g_js_Last_Ground_Frames[client] = ground_frames;		
}