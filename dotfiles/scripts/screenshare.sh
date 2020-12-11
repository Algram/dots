#!/usr/bin/env bash
set -x 
if ! lsmod | grep v4l2loopback > /dev/null; then
	echo "Adding v42loopback module to kernel"
	sudo modprobe v4l2loopback video_nr=11
fi

geometry(){
	windowGeometries=$(
		# `height - 1` is there because of: https://github.com/ammen99/wf-recorder/pull/56 (I could remove it if it's merged, maybe)
		swaymsg -t get_workspaces -r | jq -r '.[] | select(.focused) | .rect | "\(.x),\(.y) \(.width)x\(.height - 1)"'; \
		swaymsg -t get_outputs -r | jq -r '.[] | select(.active) | .rect | "\(.x),\(.y) \(.width)x\(.height)"'
	)
	geometry=$(slurp -b "#45858820" -c "#45858880" -w 3 -d <<< "$windowGeometries") || exit $?
	echo $geometry
}

{
if pgrep wf-recorder > /dev/null && pgrep mpv > /dev/null
then
	if pgrep mpv > /dev/null; then
		pkill mpv > /dev/null
	fi
	if pgrep wf-recorder > /dev/null; then
		pkill wf-recorder > /dev/null
	fi
	notify-send -t 2000 "Wayland recording has been stopped"
else
	if ! pgrep wf-recorder > /dev/null; then
		geometry=$(geometry) || exit $?
		wf-recorder --muxer=v4l2 --codec=rawvideo --file=/dev/video2 --geometry="$geometry" &
	fi
	if ! pgrep mpv; then
		swaymsg assign [class=mpv] workspace 11

		unset SDL_VIDEODRIVER
		mpv /dev/video11 &
		sleep 0.5
		# a hack so FPS is not dropping
		#waymsg [class=mpv] floating enable
		# swaymsg [class=mpv] move position 1900 1000
		# swaymsg focus tiling
	fi
	notify-send -t 2000 "Wayland recording has been started"
fi
} > ~/.wayland-share-screen.log 2>&1
