function sample_custom_dynamic_sendurl(generic_url,range)
    local rc,location

    location=generic_url

    for i=1,5,1 do
        rc,location=http.sendurl(location,1,range)

        if not location then
            break
        else
            if cfg.debug>0 then print('Redirect #'..i..' to: '..location) end
        end
    end
end

plugins['sample_custom_dynamic']={}
plugins.sample_custom_dynamic.name="Dynamic Playlist module example plugin"
plugins.sample_custom_dynamic.desc=""
plugins.sample_custom_dynamic.sendurl=sample_custom_dynamic_sendurl
plugins.sample_custom_dynamic.dynamic_playlist = {
	_elements = function()
		local elements = {
			{
				logo = "http://peach.blender.org/wp-content/uploads/dl_1080p.jpg",
				name = "Big Buck Bunny",
				url = "http://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_1080p_h264.mov"
			},
			{
				name = os.date("%c"),
				url = "http://download.blender.org/peach/bigbuckbunny_movies/big_buck_bunny_1080p_h264.mov"
			}
		}
		return elements
	end,
	name = "My Dynamic Playlist"
}