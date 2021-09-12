#!/usr/bin/env bash

if [ -n "$(pgrep "obs")" ]; then
  pkill -SIGINT obs
else
	env QT_QPA_PLATFORM=xcb obs
fi

# https://shibumi.dev/posts/wayland-in-2021/