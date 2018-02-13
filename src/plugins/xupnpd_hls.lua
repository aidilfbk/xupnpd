-- Copyright (C) 2011-2015 Anton Burdinuk
-- clark15b@gmail.com
-- https://tsdemuxer.googlecode.com/svn/trunk/xupnpd

function hls_get_index(url,t)
    local pls_data=plugin_download(url)

    if not pls_data then return nil end

    local fseq=tonumber(string.match(pls_data,"#EXT%-X%-MEDIA%-SEQUENCE:(%d+)\r?\n"))
    t.target_duration = tonumber(string.match(pls_data, "#EXT%-X%-TARGETDURATION:(%d+)\r?\n"))

    if not fseq then return nil end

    local seq=fseq

    for d,u in string.gmatch(pls_data,'#EXTINF:(%d+%.?%d-),.-\r?\n([^#\r\n]+)\r?\n') do

        if string.find(u,"^https?://") == nil then u=string.match(url,'(.+/).+$')..u end

        t[seq]={ duration=tonumber(d), ['url']=u, ['seq']=seq }

        seq=seq+1
    end

    return fseq,seq-1
end

function hls_sendurl(url,range)

    local t={}

    local seq=nil
    local idx_seq=0

    while true do

        if not seq or seq>=idx_seq then
            local fseq

            fseq,idx_seq=hls_get_index(url,t)

            if not fseq then break end

            if not seq or fseq>seq then
                --[[
                Choose a segment to start which is no closer than
                3 times the target duration from the end of the playlist.
                see https://github.com/videolan/vlc/blob/ddba52206f69bb123bea8ed4d4ada07b3cb1223c/modules/stream_filter/httplive.c#L447
                ]]
                seq = idx_seq-1
                local duration = 0
                while seq >= 0 and seq < idx_seq do
                    local segment = t[seq]
                    if segment == nil then
                        seq=fseq
                        break
                    end
                    if segment.duration > t.target_duration and cfg.debug > 0 then
                        print(string.format("EXTINF:%d duration is larger than EXT-X-TARGETDURATION:%d", segment.duration, t.target_duration))
                    end
                    duration = duration + segment.duration
                    if duration >= (3*t.target_duration) then
                        -- Start point found
                        break
                    end
                    seq = seq-1
                end
            end
        end

        local chunk=t[seq]

        if chunk then
            print('Chunk '..seq..': '..chunk.url)

            local t1=os.time()

            http.send('\r\n')

            if http.sendurl(chunk.url,0)~=1 then break end

            local delay=chunk.duration-os.difftime(os.time(),t1)-1

            t[seq]=nil

            seq=seq+1

            if delay>0 then util.sleep(delay) end
        else
            util.sleep(1)
        end

    end

end

plugins['hls']={}
plugins.hls.name="HTTP Live Streaming"
plugins.hls.desc="<i>m3u_url</i>"
plugins.hls.sendurl=hls_sendurl
