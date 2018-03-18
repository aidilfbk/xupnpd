if reload_playlists ~= nil then
	function dynamic_reload_playlists()
		print("called")
		native_reload_playlists()
		after_reload_playlists()
	end
	function after_reload_playlists()
		pls_folder=playlist_new_folder(playlist_data,'Dynamic')		
	end
	if reload_playlists ~= dynamic_reload_playlists then
		native_reload_playlists = reload_playlists
		reload_playlists = dynamic_reload_playlists
		print("monkeypatched")
		
		after_reload_playlists()
	end
else
	print("Error on dynamic playlists. Could not patch reload_playlists() function, is the lua file in "..cfg.config_path.."postinit/ ?")
end