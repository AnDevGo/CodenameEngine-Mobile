package funkin.menus.credits;

import flixel.util.FlxColor;
import funkin.backend.assets.AssetSource;
import funkin.backend.system.github.GitHubContributor.CreditsGitHubContributor;
import funkin.options.OptionsScreen;
import funkin.options.TreeMenu;
import funkin.options.type.*;
import haxe.xml.Access;

class CreditsMain extends TreeMenu {
	var bg:FlxSprite;
	var items:Array<OptionType> = [];

	public override function create() {
		bg = new FlxSprite(-80).loadAnimatedGraphic(Paths.image('menus/menuBGBlue'));
		// bg.scrollFactor.set();
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.antialiasing = true;
		add(bg);

		for (i in funkin.backend.assets.ModsFolder.getLoadedMods()) {
			var xmlPath = Paths.xml('config/credits/LIB_$i');

			if (Paths.assetsTree.existsSpecific(xmlPath, "TEXT")) {
				var access:Access = null;
				try access = new Access(Xml.parse(Paths.assetsTree.getSpecificAsset(xmlPath, "TEXT")))
				catch(e) Logs.trace('[CreditsMain] Error while parsing credits.xml: ${Std.string(e)}', ERROR);
				if (access != null) for (c in parseCreditsFromXML(access)) items.push(c);
			}
		}

		items.push(new TextOption("Codename Engine >", TU.translate("credits.selectCodename"), function() {
			optionsTree.add(Type.createInstance(CreditsCodename, []));
		}));
		items.push(new TextOption("Friday Night Funkin'", TU.translate("credits.selectBase"), function() {
			CoolUtil.openURL(Flags.URL_FNF_ITCH);
		}));

		main = new OptionsScreen(TU.translate("credits.name"), TU.translate("credits.madePossible"), items);
		super.create();

		DiscordUtil.call("onMenuLoaded", ["Credits Menu"]);
	}

	/**
	 * XML STUFF
	 */
	public function parseCreditsFromXML(xml:Access, source:AssetSource = BOTH):Array<OptionType> {
		var credsMenus:Array<OptionType> = [];

		for(node in xml.elements) {
			var desc = node.getAtt("desc").getDefault("No Description");

			if (node.name == "github") {
				if (!node.has.user) {
					Logs.warn("A github node requires a user attribute.", "CreditsMain");
					continue;
				}

				var username = node.getAtt("user");
				var user:CreditsGitHubContributor = {  // Kind of forcing
					login: username,
					html_url: 'https://github.com/$username',
					avatar_url: 'https://github.com/$username.png'
				};
				var opt:GithubIconOption = new GithubIconOption(user, desc, null,
					node.has.customName ? node.att.customName : null,
					node.has.size ? Std.parseInt(node.att.size) : 96,
					node.has.portrait ? node.att.portrait.toLowerCase() == "false" ? false : true : true
				);
				if (node.has.color)
					@:privateAccess opt.__text.color = FlxColor.fromString(node.att.color);
				credsMenus.push(opt);
			} else {
				if (!node.has.name) {
					Logs.warn("A credit node requires a name attribute.", "CreditsMain");
					continue;
				}
				var name = node.getAtt("name");

				switch(node.name) {
					case "credit":
						var opt:PortraitOption = new PortraitOption(name, desc, function() if(node.has.url) CoolUtil.openURL(node.att.url),
							node.has.icon && Paths.assetsTree.existsSpecific(Paths.image('credits/${node.att.icon}'), "IMAGE", source) ?
							FlxG.bitmap.add(Paths.image('credits/${node.att.icon}')) : null, node.has.size ? Std.parseInt(node.att.size) : 96,
							node.has.portrait ? node.att.portrait.toLowerCase() == "false" ? false : true : true
						);
						if (node.has.color)
							@:privateAccess opt.__text.color = FlxColor.fromString(node.att.color);
						credsMenus.push(opt);

					case "menu":
						credsMenus.push(new TextOption(name + " >", desc, function() {
							optionsTree.add(new OptionsScreen(name, desc, parseCreditsFromXML(node, source)));
						}));
				}
			}
		}

		return credsMenus;
	}
}
