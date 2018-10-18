class CAEventListener_StrategyListener extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateListenerTemplate());

	return Templates;
}

static function CAEventListenerTemplate CreateListenerTemplate()
{
	local CAEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CannonAnimationRedux.CAEventListenerTemplate', Template, 'CannonAnimationReduxDummy');
	Template.RegisterInTactical = true;

	`log("Register Event CannonAnimationReduxDummy", class'X2DownloadableContentInfo_CannonAnimationRedux'.default.bLog, name("CannonAnimationRedux" @ default.Class.name));

	return Template;
}
