class CAEventListenerTemplate extends X2EventListenerTemplate;

// Hack in here to start the actor as early as possible in tactical game
function RegisterForEvents()
{
	`log("Spawn CannonAnimationRedux.DropShipMatinee_Actor", class'X2DownloadableContentInfo_CannonAnimationRedux'.default.bLog, name("CannonAnimationRedux" @ default.Class.name));
	`XCOMGAME.Spawn(class'CannonAnimationRedux.DropShipMatinee_Actor');
}