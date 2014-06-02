//=============================================================================
// AugClone.
//=============================================================================
class AugClone extends Augmentation;

#exec TEXTURE IMPORT NAME=AugCloneUI 		FILE=textures\UI\AugCloneUI.bmp GROUP=UI
#exec TEXTURE IMPORT NAME=AugCloneUI_Small 	FILE=textures\UI\AugCloneUI_Small.bmp GROUP=UI

var float mpAugValue;
var float mpEnergyDrain;

var Clones M2;

function SetCloneLocation()
{
	local Vector HitNormal, HitLocation, StartTrace, EndTrace;

	if (M2 != None)
	{
		StartTrace = Player.Location;
		StartTrace.Z += Player.BaseEyeHeight;
		EndTrace = StartTrace + LevelValues[CurrentLevel] * Vector(Player.ViewRotation);

		Trace(HitLocation, HitNormal, EndTrace, StartTrace, True);
		if (HitLocation == vect(0,0,0))
			HitLocation = EndTrace;
	}
}

state Active
{
	function Tick(float deltaTime)
	{
		if(M2!=None)
		{
			//Player.Energy = M2.Health;
		}
	super.Tick(deltaTime);
	}
	
	function BeginState()
	{
	local Vector loc;

	loc = (2.0 + class'Clones'.Default.CollisionRadius + Player.CollisionRadius) * Vector(Player.ViewRotation);
	loc.Z = Player.BaseEyeHeight;
        //loc.X = Player.Location.Y-Vector(Player.ViewRotation.X);
	loc += Player.Location;

		Super.BeginState();

		M2 = Spawn(class'Clones', Player,, loc, Player.ViewRotation); //,,, loc, Player.Rotation);//, Player, '', Player.Location);
		if (M2 != None)
		{
			M2.LightHue = 32;
			M2.LightRadius = 4;
			M2.LightSaturation = 140;
			M2.LightBrightness = 192;
		}
	}

Begin:
}

function Deactivate()
{
	Super.Deactivate();

	if(M2!=None)
	M2.SpawnCarcass();
	//M2.Destroy();
	//M2=None;
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		LevelValues[3] = mpAugValue;
		EnergyRate = mpEnergyDrain;
      AugmentationLocation = LOC_Torso;
	}
}

defaultproperties
{
     mpAugValue=2.000000
     mpEnergyDrain=180.000000
     //EnergyRate=40.000000
	 EnergyRate=0.4
     Icon=Texture'RoD.AugCloneUI'
     smallIcon=Texture'RoD.AugCloneUI_Small'
     AugmentationName="Clone"
     Description="Clones.. you.. you get two more JCs. What next JC.. What next?"
     MPInfo="When active, you clone yourself, spawning two JCs.  Energy Drain: Very High"
     LevelValues(0)=1.200000
     LevelValues(1)=1.400000
     LevelValues(2)=1.600000
     LevelValues(3)=1.800000
     AugmentationLocation=LOC_Leg
     MPConflictSlot=5
}
