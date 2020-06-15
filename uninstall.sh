#!/bin/bash
if [ -e "/data/Universal_Kernel_Tweaks.prop" ]; then
    rm -f "/data/Universal_Kernel_Tweaks.prop"
fi
if [ -e "/data/soc.txt" ]; then
    rm -f "/data/soc.txt"
fi
if [ -e "/data/adb/Universal_Kernel_Tweaksprofile.txt" ]; then
    rm "/data/adb/Universal_Kernel_Tweaksprofile.txt"
fi
if [ -e "/data/adb/dynamic_stune_boost.txt" ]; then
    rm "/data/adb/dynamic_stune_boost.txt"
fi;
if [ -e "/data/adb/background.txt" ]; then
    rm "/data/adb/background.txt"
fi
if [ -e "/data/adb/foreground.txt" ]; then
    rm "/data/adb/foreground.txt"
fi
if [ -e "/data/adb/top-app.txt" ]; then  
    rm "/data/adb/top-app.txt"
fi
if [ -e "/data/adb/boost1.txt" ]; then
    rm "/data/adb/boost1.txt"
fi
if [ -e "/data/adb/boost2.txt" ]; then
    rm "/data/adb/boost2.txt"
fi
if [ -e "/data/adb/boost3.txt" ]; then
    rm "/data/adb/boost3.txt"
fi
if [ -e "/data/adb/go_hispeed.txt" ]; then
    rm "/data/adb/go_hispeed.txt"
fi;
if [ -e "/data/adb/go_hispeed_l.txt" ]; then
    rm "/data/adb/go_hispeed_l.txt"
fi;
if [ -e "/data/adb/go_hispeed_b.txt" ]; then
    rm "/data/adb/go_hispeed_b.txt"
fi;
if [ -e "/data/adb/idle_timer.txt" ]; then
    rm "/data/adb/idle_timer.txt"
fi;
if [ -e "/data/adb/deep_nap_timer.txt" ]; then
    rm "/data/adb/deep_nap_timer.txt"
fi;
if [ -e "/data/adb/.Universal_Kernel_Tweaks_param_bak" ]; then
    rm "/data/adb/.Universal_Kernel_Tweaks_param_bak"
fi;
if [ -e "/data/adb/.Universal_Kernel_Tweaks_cur_level" ]; then
    rm "/data/adb/.Universal_Kernel_Tweaks_cur_level"
fi;

# Don't modify anything after this
if [ -f $INFO ]; then
  while read LINE; do
    if [ "$(echo -n $LINE | tail -c 1)" == "~" ]; then
      continue
    elif [ -f "$LINE~" ]; then
      mv -f $LINE~ $LINE
    else
      rm -f $LINE
      while true; do
        LINE=$(dirname $LINE)
        [ "$(ls -A $LINE 2>/dev/null)" ] && break 1 || rm -rf $LINE
      done
    fi
  done < $INFO
  rm -f $INFO
fi
