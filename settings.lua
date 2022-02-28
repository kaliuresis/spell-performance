dofile("data/scripts/lib/mod_settings.lua") -- see this file for documentation on some of the features.

local mod_id = "spell_performance" -- This should match the name of your mod's folder.
mod_settings_version = 1 -- This is a magic global that can be used to migrate settings to new mod versions. call mod_settings_get_version() before mod_settings_update() to get the old value. 
mod_settings = 
{
	{
		category_id = "cosmetic_particles",
		ui_name = "",
		ui_description = "",
		settings = {
			{
				id = "cosmetics_setting",
				ui_name = "Particle Emitters",
				ui_description = "Maximum copies of each unique cosmetic particle emitter per projectile",
				value_default = "5",
				values = { {"0", "None"}, {"1", "1"}, {"5", "5"}, {"10", "10"}, {"10000", "Uncapped"} },
				scope = MOD_SETTING_SCOPE_RUNTIME,
			},
		},
	},
}


function ModSettingsUpdate( init_scope )
	local old_version = mod_settings_get_version( mod_id ) -- This can be used to migrate some settings between mod versions.
	mod_settings_update( mod_id, mod_settings, init_scope )
end

function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end
