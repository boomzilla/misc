class AugCloneCanister extends AugmentationCannister;

var AugClone AugClone;

auto state Pickup
{
	function Frob(Actor Other, Inventory frobWith)
	{
		local Augmentation aug;
		local int i;
		local int augIndex;
		if(DeusExPlayer(Other) != none)
		{
			for(i=0;i<25;i++)
			if(DeusExPlayer(Other).AugmentationSystem.augClasses[i] == none)
                      		break;
               		if(i<25)
				DeusExPlayer(Other).AugmentationSystem.augClasses[i]=Class'RoD.AugClone';
				broadcastMessage(DeusExPlayer(Other).AugmentationSystem.augClasses[i]);

			for(aug=DeusExPlayer(Other).AugmentationSystem.FirstAug; aug.next != none; aug=aug.next );
				aug.next=spawn(class'RoD.AugClone',DeusExPlayer(Other).AugmentationSystem);
				aug.next.player=DeusExPlayer(Other);
		}
     Super.Frob(Other,frobWith);
	}
}

defaultproperties
{
   AddAugs(0)="AugClone"
}