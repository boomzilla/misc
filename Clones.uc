//=============================================================================
// Clones.
//=============================================================================

class Clones extends HumanMilitary;

var name OwnerName;
var bool bDoEffectsForKillingTheClonePlease;
var bool bDIF;

simulated function PreBeginPlay()
{
    local pawn p;
    local int i;

    Super.PreBeginPlay();

/*
    if(Owner == none)
      for(p=level.pawnlist;p!=none;p=p.nextpawn)
        if(vSize(p.location-location) < 128)
          setOwner(p);
*/

    if(Owner != none)
    {
        Broadcastmessage("Clones.uc: Owner:"@owner);
        Mesh = Owner.Mesh;
        DrawScale = Owner.Drawscale;
        if(Owner.IsA('Pawn'))
          Fatness=Owner.Fatness+1;
        else
          Fatness=Owner.Fatness+2;
        OwnerName=Owner.Name;
        //AddPlayerInventory();

        SetCollisionSize(Owner.CollisionRadius, Owner.CollisionHeight);

	for(i=0;i<8;i++)
	{
		Multiskins[i]=Owner.Multiskins[i];
	}
    }
}

function bool DeleteInventory2( inventory Item )
{

	// If this item is in our inventory chain, unlink it.
	local actor Link;
/*
	if ( Item == Weapon )
		Weapon = None;
	if ( Item == SelectedItem )
		SelectedItem = None;
	for( Link = Self; Link!=None; Link=Link.Inventory )
	{
		if( Link.Inventory == Item )
		{
			Link.Inventory = Item.Inventory;
			break;
		}
	}
*/
	Item.SetOwner(Owner);

}

function AddPlayerInventory()
{
	local DeusExWeapon aWeapon;
	local int i;
	local Inventory item, nextItem, thisItem;
	//local WeaponNanoSword DT;
	
	//DT = Spawn(Class'WeaponNanoSword');
	//DT.GiveTo(Self);
	
	//AddInventory(class'WeaponNanoSword');
	
	item = DeusExPlayer(Owner).Inventory;
	//item.SpawnCopy(self);
	
	if (DeusExPlayer(Owner).Inventory != None)
	{
		do
		{
			//item = DeusExPlayer(Owner).Inventory;
			nextItem = item.Inventory;
			//DeleteInventory(item);
			//if ((DeusExWeapon(item) != None) && (DeusExWeapon(item).bNativeAttack))
			//	item.Destroy();
			//else
			//AddInventory(item);
			thisItem = item.Spawn(item.Class,Self,,,rot(0,0,0));
			thisItem.GotoState('Sleeping');
			thisItem.GiveTo(Self);
			log("adding inventory item: " $ item);
			item = nextItem;
		}
		until (item == None);
	}

	/*
	for (item=DeusExPlayer(Owner).Inventory; item!=None; item=DeusExPlayer(Owner).Inventory)
	{
		/*
		if(item.isA('DeusExWeapon'))
		{
			forEach allActors(class'DeusExWeapon', aWeapon)
			{
				aWeapon = DeusExWeapon(item);
				item = spawn(class'DeusExWeapon'); //DeusExPlayer(Owner).Inventory);
				item.bHidden=True;
				item.SetOwner(self);
			}
			new(item.Class(item));
			AddInventory2(item);
		}
		//else if(!item.isA('DeusExWeapon'))
		//{
		//	return;
		//}
		*/
			AddInventory2(item);
	}*/
}


// Add Item to this pawn's inventory. 
// Returns true if successfully added, false if not.
function bool AddInventory2( inventory NewItem )
{
	// Skip if already in the inventory.
	local inventory Inv;
	
	// The item should not have been destroyed if we get here.
	if (NewItem ==None )
		log("tried to add none inventory to "$self);

	//for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
	//	if( Inv == NewItem )
	//		return false;
	//for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory ) //Clones ONLY get the weapons. hmmph smh.
	//	if (!inv.isA('DeusExWeapon'))
	//		return false;

	// EPIC LEET COPY PASTE SCRIPTKIDDY CODER ~DJ~
	// NO!!!!!!!!!!!!!!!!! OVERRIDE!
	//----------------------------------
	// DEUS_EX AJY
	// Update the previous owner's inventory chain
	if (NewItem.Owner != None)
		Clones(NewItem.Owner).DeleteInventory2(NewItem);

	// Add to front of inventory chain.
	NewItem.SetOwner(Self);
	NewItem.Inventory = Inventory;
	Inventory = NewItem;


	return true;
}


function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;

	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	//log(self@"take damage in state"@GetStateName());	
	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if (Physics == PHYS_Walking)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;
	AddVelocity( momentum ); 

	actualDamage = Level.Game.ReduceDamage(Damage, DamageType, self, instigatedBy);
	if ( bIsPlayer )
	{
		if (ReducedDamageType == 'All') //God mode
			actualDamage = 0;
		else if (Inventory != None) //then check if carrying armor
			actualDamage = Inventory.ReduceDamage(actualDamage, DamageType, HitLocation);
		else
			actualDamage = Damage;
	}
	else if ( (InstigatedBy != None) &&
				(InstigatedBy.IsA(Class.Name) || self.IsA(InstigatedBy.Class.Name)) )
		ActualDamage = ActualDamage * FMin(1 - ReducedDamagePct, 0.35); 
	else if ( (ReducedDamageType == 'All') || 
		((ReducedDamageType != '') && (ReducedDamageType == damageType)) )
		actualDamage = float(actualDamage) * (1 - ReducedDamagePct);
	
	if ( Level.Game.DamageMutator != None )
		Level.Game.DamageMutator.MutatorTakeDamage( ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType );
	Health -= actualDamage;
	if (CarriedDecoration != None)
		DropDecoration();
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if (Health > 0)
	{
		if ( (instigatedBy != None) && (instigatedBy != Self) )
			damageAttitudeTo(instigatedBy);
		PlayHit(actualDamage, hitLocation, damageType, Momentum);
	}
	else if ( !bAlreadyDead )
	{
		//log(self$" died");
		NextState = '';
		PlayDeathHit(actualDamage, hitLocation, damageType, Momentum);
		if ( actualDamage > mass )
			Health = -1 * actualDamage;
		if ( (instigatedBy != None) && (instigatedBy != Self) )
			damageAttitudeTo(instigatedBy);
		Died(instigatedBy, damageType, HitLocation);
	}
	else
	{
		//Warn(self$" took regular damage "$damagetype$" from "$instigator$" while already dead");
		// SpawnGibbedCarcass();
		if ( bIsPlayer )
		{
			HidePlayer();
			GotoState('Dying');
		}
		else
			SpawnCarcass();
	}
	MakeNoise(1.0); 
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	local pawn OtherPawn;
	local actor A;

	if ( bDeleteMe )
		return; //already destroyed
	Health = Min(0, Health);
	for ( OtherPawn=Level.PawnList; OtherPawn!=None; OtherPawn=OtherPawn.nextPawn )
		OtherPawn.Killed(Killer, self, damageType);
	if ( CarriedDecoration != None )
		DropDecoration();
	level.game.Killed(Killer, self, damageType);
	//log(class$" dying");
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, Killer );
	Level.Game.DiscardInventory(self);
	Velocity.Z *= 1.3;
   if ( Gibbed(damageType) )
   {
      SpawnGibbedCarcass();
      if ( bIsPlayer )
         HidePlayer();
      else
         SpawnCarcass();
   }
	PlayDying(DamageType, HitLocation);
	if ( Level.Game.bGameEnded )
		return;
	if ( RemoteRole == ROLE_AutonomousProxy )
		ClientDying(DamageType, HitLocation);
	GotoState('Dying');
}

State Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		if ( bDeleteMe )
			return;
		Health = Health - Damage;
		Momentum = Momentum/Mass;
		AddVelocity( momentum ); 
		if ( !bHidden && Gibbed(damageType) )
		{
			bHidden = true;
			SpawnGibbedCarcass();
			if ( bIsPlayer )
				HidePlayer();
			else
				SpawnCarcass();
		}
	}

	function Timer()
	{
		if ( !bHidden )
		{
			bHidden = true;
			SpawnCarcass();
			if ( bIsPlayer )
				HidePlayer();
			else
				SpawnCarcass();
		}
	}

	event Landed(vector HitNormal)
	{
		SetPhysics(PHYS_None);
	}

	function BeginState()
	{
		SetTimer(0.3, false);
	}
}


function SpawnGibbedCarcass()
{
SpawnCarcass();
}

function Carcass SpawnCarcass()
{
	bDoEffectsForKillingTheClonePlease = True;
	bDIF = True;
}

function PlayDying(name damageType, vector hitLoc)
{
	SpawnCarcass();
}

function PlayDyingSound()
{
/*
	SetDistressTimer();
	PlaySound(Die, SLOT_Pain,,,, RandomPitch());
	AISendEvent('LoudNoise', EAITYPE_Audio);
	if (bEmitDistress)
		AISendEvent('Distress', EAITYPE_Audio);
*/
}

function Tick(float deltaTime)
{
	Super.Tick(deltaTime);

	if(bDoEffectsForKillingTheClonePlease)
	{
		if(bDIF)
		{
			ScaleGlow = 3;
			bDIF = False;
		}
		ScaleGlow -=deltaTime;
		 if(ScaleGlow<0.3)
		  Style=STY_Modulated;
	}

	if( (ScaleGlow<0)||(ScaleGlow==0) )
	 Destroy();
}

/*
simulated function Tick(float DeltaTime)
{
    local int IdealFatness;
    local DeusExCarcass dxc;

    //broadcastmessage("owner:"@owner@"  claseglow is:"@ScaleGlow@"  lifespan is:"@lifespan);

    //if(level.NetMode != NM_Client)
    if(Owner == none)
    {
        if(OwnerName != '')
        {

            //broadcastmessage("ownername:"@ownername);
            foreach AllActors(class'DeusExCarcass',dxc)
            {
                if(dxc != none)
                  if(dxc.CarcassName == OwnerName)
                  {
                      setOwner(dxc);
                      Mesh=dxc.Mesh;
                      //broadcastmessage("owner died.. carcass found:"@dxc);
                      OwnerName='';
                      break;
                  }
            }
        }
    }
    //if(Owner == none)
    //  destroy();

        if(ScaleGlow > 0)
        {
          //broadcastmessage("tick - netmode:"@level.NetMode);
          ScaleGlow -= Deltatime;
          //if(numHits == 3)
            Owner.ScaleGlow -= Deltatime*3;
          //AmbientGlow-=deltatime*8;
        }
        else if(!bHidden)
          bHidden=true;

/*	if ( (Level.NetMode == NM_DedicatedServer) || (Owner == None) )
		return;

	IdealFatness = Owner.Fatness; // Convert to int for safety.
	IdealFatness += FatnessOffset;

	if ( Fatness > IdealFatness )
		Fatness = Max(IdealFatness, Fatness - 130 * DeltaTime);
	else
		Fatness = Min(IdealFatness, 255);

     */
}
*/

defaultproperties
{
	bEmitDistress=False
	bKeepWeaponDrawn=True
	Alliance=JCsClone
	InitialAlliances(0)=(AllianceName=Player,AllianceLevel=1,bPermanent=True)
	CarcassType=Class'DeusEx.JCDentonMaleCarcass'
	WalkingSpeed=0.296000
	walkAnimMult=0.750000
	GroundSpeed=250.000000
	Mesh=LodMesh'DeusExCharacters.GM_Trench'
	//MultiSkins(0)=Texture'DeusExCharacters.Skins.JCDentonTex0'
	//MultiSkins(1)=Texture'DeusExCharacters.Skins.JCDentonTex2'
	//MultiSkins(2)=Texture'DeusExCharacters.Skins.JCDentonTex3'
	//MultiSkins(3)=Texture'DeusExCharacters.Skins.JCDentonTex0'
	//MultiSkins(4)=Texture'DeusExCharacters.Skins.JCDentonTex1'
	//MultiSkins(5)=Texture'DeusExCharacters.Skins.JCDentonTex2'
	//MultiSkins(6)=Texture'DeusExCharacters.Skins.FramesTex4'
	//MultiSkins(7)=Texture'DeusExCharacters.Skins.LensesTex5'
	//InitialInventory(0)=(Inventory=Class'DeusEx.WeaponAssaultGun')
	//InitialInventory(1)=(Inventory=Class'DeusEx.Ammo762mm',Count=12)
	//InitialInventory(2)=(Inventory=Class'DeusEx.WeaponCombatKnife')
	//InitialInventory(3)=(Inventory=Class'DeusEx.WeaponFlamethrower')
	//InitialInventory(4)=(Inventory=Class'DeusEx.AmmoNapalm',Count=2)
	CollisionRadius=20.000000
	CollisionHeight=47.500000
	BindName="JCsClone"
	FamiliarName="JC's Clone"
	UnfamiliarName="JC's Clone"
	RaiseAlarm=RAISEALARM_Never
	Orders=Following
	bAvoidAim=False
	bHateHacking=True
	bHateWeapon=True
	bHateIndirectInjury=True
	bHateCarcass=True
	bHateDistress=True
	bReactFutz=True
	bReactLoudNoise=True
	bReactAlarm=True
	bReactShot=True
	bReactCarcass=True
	bReactDistress=True
	bReactPresence=True
	bFearHacking=False
	bFearWeapon=False
	bFearShot=False
	bFearInjury=False
	bFearIndirectInjury=False
	bFearCarcass=False
	bFearDistress=False
	bFearAlarm=False
	bFearProjectiles=False
	AttitudeToPlayer=ATTITUDE_Follow
	Intelligence=BRAINS_HUMAN
	MaxProvocations=0
}
