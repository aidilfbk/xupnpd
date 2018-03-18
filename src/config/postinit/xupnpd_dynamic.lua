if reload_playlists ~= nil then
	immutable_nil_table = setmetatable({}, {__newindex = function() end})
	dynamic_elements = {
		elements = function(t, k)
			local retval = rawget(t, "_elements")
			if type(retval) == "function" then
				retval = retval()
			end
			if type(retval) ~= "table" then
				return immutable_nil_table
			end
			t.elements = retval
			playlist_fix_sub_tree(t)
			t.elements = nil
			return retval
		end,
		size = function(t, k)
			return #t.elements
		end,
		plugin = "dynamic",
		__index = function (t, k)
			local retval = dynamic_elements[k]
			if type(retval) == "function" then
				retval = retval(t, k)
			end
			return retval
		end
	}
	function dynamic_reload_playlists()
		native_reload_playlists()
		after_reload_playlists()
	end
	function after_reload_playlists()
		pls_folder=playlist_new_folder(playlist_data,'Dynamic')		
	end
	if reload_playlists ~= dynamic_reload_playlists then
		native_reload_playlists = reload_playlists
		reload_playlists = dynamic_reload_playlists
		if cfg.debug>0 then print('Dynamic playlists module loaded') end
		after_reload_playlists()
	end
else
	print("Error initialising dynamic playlists module. Could not patch reload_playlists() function, is the module file in "..cfg.config_path.."postinit/ ?")
end