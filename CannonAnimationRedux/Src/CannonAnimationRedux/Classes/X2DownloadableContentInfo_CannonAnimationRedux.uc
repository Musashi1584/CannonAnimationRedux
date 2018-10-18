//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_CannonAnimationRedux.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_CannonAnimationRedux extends X2DownloadableContentInfo config (Cannon);

struct RotationDegrees
{
	var float Pitch, Yaw, Roll;
};

struct CannonTemplate
{
	var name TemplateName;
	var name SocketName;
	var name BoneName;
	var vector SocketOffset;
	var RotationDegrees SocketRotator;
};

var config array<CannonTemplate> CannonTemplates;

var config bool bLog;

static function UpdateAnimations(out array<AnimSet> CustomAnimSets, XComGameState_Unit UnitState, XComUnitPawn Pawn)
{
	if (!UnitState.IsSoldier())
		return;

	if (default.CannonTemplates.Find('TemplateName', UnitState.GetPrimaryWeapon().GetMyTemplateName()) != INDEX_NONE)
	{
		If (UnitState.kAppearance.iGender == eGender_Female)
		{
			CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("Cannon_Female.Anims.AS_Soldier_Female")));
			//`LOG(default.Class @ GetFuncName() @ "Adding Cannon.Anims.AS_Soldier_Female",, 'CannonAnimationRedux');
		}
		else
		{
			CustomAnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("Cannon_Male.Anims.AS_Soldier")));
			//`LOG(default.Class @ GetFuncName() @ "Adding Cannon.Anims.AS_Soldier",, 'CannonAnimationRedux');
		}
		
	}
}

static function WeaponInitialized(XGWeapon WeaponArchetype, XComWeapon Weapon, optional XComGameState_Item ItemState=none)
{
	Local XComGameState_Item InternalWeaponState;

	InternalWeaponState = ItemState;

	if (InternalWeaponState == none)
	{
		InternalWeaponState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(WeaponArchetype.ObjectID));
	}

	if (default.CannonTemplates.Find('TemplateName', InternalWeaponState.GetMyTemplateName()) != INDEX_NONE)
	{
		Weapon.CustomUnitPawnAnimsets.Length = 0;
		Weapon.CustomUnitPawnAnimsetsFemale.Length = 0;
		
		Weapon.CustomUnitPawnAnimsets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("Cannon_Male.Anims.AS_CustomUnitPawn_Cannon")));
		Weapon.CustomUnitPawnAnimsetsFemale.AddItem(AnimSet(`CONTENT.RequestGameArchetype("Cannon_Female.Anims.AS_CustomUnitPawn_Cannon_F")));

		SkeletalMeshComponent(Weapon.Mesh).AnimSets.Length = 0;
		SkeletalMeshComponent(Weapon.Mesh).AnimSets.AddItem(AnimSet(`CONTENT.RequestGameArchetype("Cannon_Male.Anims.AS_ConvCannon")));


		//SkeletalMeshComponent(Weapon.Mesh).AnimSets[0].TrackBoneNames.RemoveItem('Reargrip');
		//SkeletalMeshComponent(Weapon.Mesh).AnimSets[0].TrackBoneNames.RemoveItem('Foregrip');
	}

}

static function DLCAppendWeaponSockets(out array<SkeletalMeshSocket> NewSockets, XComWeapon Weapon, XComGameState_Item ItemState)
{
    local vector					RelativeLocation;
	local rotator					RelativeRotation;
    local SkeletalMeshSocket		Socket;
	local int						Index;
	local CannonTemplate			Template;

	Index = default.CannonTemplates.Find('TemplateName', ItemState.GetMyTemplateName());
	if (Index != INDEX_NONE)
	{
		Template = default.CannonTemplates[Index];
		// Male working
		if (Template.SocketName != '' && Template.BoneName != '')
		{
			RelativeLocation.X = Template.SocketOffset.X;
			RelativeLocation.Y = Template.SocketOffset.Y;
			RelativeLocation.Z = Template.SocketOffset.Z;
		
			RelativeRotation.Roll = int(Template.SocketRotator.Roll * DegToUnrRot);
			RelativeRotation.Pitch = int(Template.SocketRotator.Pitch * DegToUnrRot);
			RelativeRotation.Yaw = int(Template.SocketRotator.Yaw * DegToUnrRot);

			Socket = new class'SkeletalMeshSocket';
			Socket.SocketName = Template.SocketName;
			Socket.BoneName = Template.BoneName;
			Socket.RelativeLocation = RelativeLocation;
			Socket.RelativeRotation = RelativeRotation;
			NewSockets.AddItem(Socket);

			//`LOG(default.Class @ GetFuncName() @ "Overriding" @ Socket.SocketName @ "socket" @ `showvar(RelativeLocation) @ `showvar(RelativeRotation),, 'CannonAnimationRedux');
		}
	}
}

static function MatineeGetPawnFromSaveData(XComUnitPawn UnitPawn, XComGameState_Unit UnitState, XComGameState SearchState)
{
	class'CAShellMapMatinee'.static.PatchAllLoadedMatinees(UnitPawn, UnitState, SearchState);
}

public static function bool HasCannonEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	return (default.CannonTemplates.Find('TemplateName', UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon, CheckGameState).GetMyTemplateName()) != INDEX_NONE);
}