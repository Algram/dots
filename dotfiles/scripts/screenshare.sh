#!/usr/bin/env bash

if [ -n "$(pgrep "obs")" ]; then
  pkill -SIGINT obs
else

  # exec env QT_QPA_PLATFORM=wayland obs
	exec env QT_QPA_PLATFORM=xcb obs
fi

# https://shibumi.dev/posts/wayland-in-2021/