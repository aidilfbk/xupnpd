-- Plugin to use ffmpeg features like AES-encrypted HLS streams
-- Copyright (C) 2017 aidilfbk
-- aidilfbk@gmail.com

cfg.ffmpeg_chunksize=32768

function ffmpeg_sendurl(url,range)
	local stderr_redirect, chunk
	if cfg.debug > 0 then
		stderr_redirect = ""
	else
		stderr_redirect = "-nostats -hide_banner -loglevel -8 2>/dev/null"
	end
	
	local customHeaders = split_string(url, '|')
	url = table.remove(customHeaders, 1)
	local customHeadersCfg = ""

	if #customHeaders > 0 then
		for idx, kvs in ipairs(customHeaders) do
			customHeaders[idx] = string.gsub(kvs, "=", ": ", 1)
		end

		customHeadersCfg = string.format('-headers "%s"', table.concat(customHeaders, "\r\n"))
	end

	local cmd = string.format('ffmpeg -user_agent "%s" -multiple_requests 1 %s -i "%s" -c copy -copy_unknown -f mpegts -mpegts_copyts 1 pipe:1 %s', cfg.user_agent, customHeadersCfg, url, stderr_redirect)
	local ffmpeg = io.popen(cmd, "r")
	http.send('\r\n') -- delimit the HTTP headers from the ffmpeg content body
	
	repeat
		chunk = ffmpeg:read(cfg.ffmpeg_chunksize)
		if chunk then
			http.send(chunk)
		end
	until not chunk
	ffmpeg:close()
end

plugins['ffmpeg']={}
plugins.ffmpeg.name="FFMpeg"
plugins.ffmpeg.desc="Use FFMpeg to demux and remux streams. Useful for AES-encrypted HLS streams or other ffmpeg-supported protocols like rtmp/rtp"
plugins.ffmpeg.sendurl=ffmpeg_sendurl

plugins.ffmpeg.ui_config_vars=
{
    { "input",  "ffmpeg_chunksize", "int" },
}
