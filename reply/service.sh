#!/bin/bash

wd=$(dirname $0)
cd $wd/../
wd=$(pwd)

dir_pending="./pending"
dir_processed="./processed"
dir_failed="./failed"
dir_invalid="./invalid"
dir_reply="./reply"
dir_post="./post"
dir_nodes="./nodes"
dir_tmp="./tmp"

# API endpoint URL in the .env file
# shellcheck source=/dev/null
url=$(cat $dir_reply/.env | grep url | awk '{print $3}')


t_last=0

while true ; do
    sleep 1

    if [ -f stop-reply.flag ] ; then
        echo "Stopping reply service"
        rm stop-reply.flag
        exit
    fi

    #id=$(ls $dir_pending | shuf -n 1)
    id=$(ls $dir_pending | head -n 1)

    # Debug print
    printf '%s' "$id"
    printf "\n"

    if [ ! -z $id ] ; then
        username=$(cat $dir_pending/$id/username)


        depth=$(cat $dir_pending/$id/depth)
        frames=$(cat $dir_pending/$id/frames)
        frames_cur=$(cat $dir_pending/$id/frames_cur)
        command_play=$(cat $dir_pending/$id/command_play)

        $wd/parse-history $dir_pending/$id/input-all.txt 350 35 $dir_pending/$id/command_parsed 0 1

        for k in $(seq 0 9) ; do
            idx=$k

            ts_m=$(( 1000*($idx    ) ))
            te_m=$(( 1000*($idx + 1) ))

            ts_s=$(printf "%02d" $(( $ts_m/1000 )) )
            ts_m=$(printf "%03d" $(( $ts_m - ($ts_m/1000)*1000 )) )
            te_s=$(printf "%02d" $(( $te_m/1000 )) )
            te_m=$(printf "%03d" $(( $te_m - ($te_m/1000)*1000 )) )

            cmd=$(cat $dir_pending/$id/command_parsed | head -n $(($k + 1)) | tail -n 1)

            echo "$(( $idx + 1 ))" >> $dir_pending/$id/subs.srt
            echo "00:00:$ts_s,$ts_m --> 00:00:$te_s,$te_m" >> $dir_pending/$id/subs.srt
            echo "$cmd" >> $dir_pending/$id/subs.srt
            echo "" >> $dir_pending/$id/subs.srt
        done

        # Send the video to the Discord using webhook

        # Video file to upload
        video_file="$dir_pending/$id/record.mp4"

        # JSON payload (optional)
        payload_json='{"username": "Doomer", 
                       "content": "Video for user '$username'", 
                       "avatar_url": "https://wallpapercave.com/wp/wp6540958.jpg"}'

        # Construct the request
        curl -X POST "$url" \
        -F "files[0]=@${video_file};type=video/mp4" \
        -F "payload_json=${payload_json}"

        # Check the response
        if [ $? -eq 0 ]; then
            echo "Video uploaded successfully."
            else
            echo "Failed to upload video."
        fi
        
        echo "{\"id_str\": \"$id\"}" > "$dir_pending/$id/result.json"

        
        success=0
        node_id=$(cat $dir_pending/$id/result.json | jq -r .id_str) || success=$?

        # Debug print
        printf '%s' "$node_id"
        printf "Debug\n"

        if [ "$success" -eq 0 ] ; then
            echo -n "$node_id" > $dir_pending/$id/child_id
            t_last="$t_cur"

            mkdir $dir_tmp/node_new
            cp -v $dir_pending/$id/input-all.txt $dir_tmp/node_new/history.txt
            cp -v $dir_pending/$id/depth $dir_tmp/node_new/depth
            cp -v $dir_pending/$id/frames $dir_tmp/node_new/frames
            echo -n "$id" > $dir_tmp/node_new/parent_id
            mv -v "$dir_tmp/node_new" "$dir_nodes/$node_id"

            mv -v $dir_pending/$id $dir_processed/$id
        else
            # TODO : retry limit
            mv -v $dir_pending/$id $dir_failed/$id
        fi
    fi
done
