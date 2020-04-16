#!/system/bin/sh
# =======================================================#
# Codename: Universal_Kernel_Tweaks
# Author: 	enweazudaniel @ XDA
# Device: 	Multi-device
# Version : 1
# Last Update: 14.APRIL.2020
# =======================================================#
# Credits : Project WIPE contributors 
# @yc9559 @Fdss45 @yy688go (好像不见了) @Jouiz @lpc3123191239
# @小方叔叔 @星辰紫光 @ℳ๓叶落情殇 @屁屁痒 @发热不卡算我输# @予北
# @選擇遺忘 @想飞的小伙 @白而出清 @AshLight @微风阵阵 @半阳半
# @AhZHI @悲欢余生有人听 @YaomiHwang @花生味 @胡同口卖菜的
# @gce8980 @vesakam @q1006237211 @Runds @lmentor
# @萝莉控の胜利 @iMeaCore @Dfift半島鐵盒 @wenjiahong @星空未来
# @水瓶 @瓜瓜皮 @默认用户名8 @影灬无神 @橘猫520 @此用户名已存在
# @ピロちゃん @Jaceﮥ @黑白颠倒的年华0 @九日不能贱 @fineable
# @哑剧 @zokkkk @永恒的丶齿轮 @L风云 @Immature_H @揪你鸡儿
# @xujiyuan723 @Ace蒙奇 @ちぃ @木子茶i同学 @HEX_Stan
# @_暗香浮动月黄昏 @子喜 @ft1858336 @xxxxuanran @Scorpiring
# @猫见 @僞裝灬 @请叫我芦柑 @吃瓜子的小白 @HELISIGN @鹰雏
# @贫家boy有何贵干 @Yoooooo @korom42
# =======================================================#
# Give proper credits when using this in your work
# =======================================================#
MODDIR=${0%/*}
SCRIPT_DIR="$MODDIR/script"

if [ "$(cat $SCRIPT_DIR/pathinfo.sh | grep "$PATH")" == "" ]; then
    echo "" >> $SCRIPT_DIR/pathinfo.sh
    echo "# prefer to use busybox provided by magisk" >> $SCRIPT_DIR/pathinfo.sh
    echo "PATH=$PATH" >> $SCRIPT_DIR/pathinfo.sh
fi

write() {
    echo -n $2 > $1
}
mutate() 
{
    if [ -f ${2} ]; then
        chmod 0666 ${2}
        echo ${1} > ${2}
    fi
}
copy() {
    if [ "$4" == "" ];then
	if [ -e "$1" ]; then
    cat $1 > $2
	fi
	else
	src1=$(cat $1 | tr -d '\n')
	src2=$(cat $2 | tr -d '\n')
	if [ -e "$1" ] && [ -e "$2" ]; then
	write "$3" "${src1} $4 ${src2}"
	fi
	fi
}
round() {
  printf "%.$2f" "$1"
}
min()
{
    local m="$1"
    for n in "$@"
    do
        [ "$n" -lt "$m" ] && m="$n"
    done
    echo "$m"
}
max()
{
    local m="$1"
    for n in "$@"
    do
        [ "$n" -gt "$m" ] && m="$n"
    done
    echo "$m"
}
lock_val() {
	if [ -f ${2} ]; then
		chmod 0666 ${2}
		echo ${1} > ${2}
		chmod 0444 ${2}
	fi
}

is_int() { return $(test "$@" -eq "$@" > /dev/null 2>&1); }
    cores=$(awk '{ if ($0~/^physical id/) { p=$NF }; if ($0~/^core id/) { cores[p$NF]=p$NF }; if ($0~/processor/) { cpu++ } } END { for (key in cores) { n++ } } END { if (n) {print n} else {print cpu} }' /proc/cpuinfo)
    coresmax=$(cat /sys/devices/system/cpu/kernel_max) 2>/dev/null

    if [ -d "/sys/devices/system/cpu/cpufreq/policy2" ];then
    bcores="2"
    elif [ -d "/sys/devices/system/cpu/cpufreq/policy6" ];then
    bcores="4"
    pcores="6"
    else
    bcores="4"
    fi
	
	if [ -z ${cores} ] || [ ${cores} -eq ${bcores} ];then
	cores=$(( ${coresmax} + 1 ))
	fi	
	

set_boost() {
	#Tune Input Boost
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_ms" ]; then
	lock_val $1 /sys/module/cpu_boost/parameters/input_boost_ms
	fi
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_ms_s2" ]; then
	lock_val 0 /sys/module/cpu_boost/parameters/input_boost_ms_s2
	fi
	if [ -e /sys/module/cpu_boost/parameters/input_boost_enabled ]; then
	lock_val 1 /sys/module/cpu_boost/parameters/input_boost_enabled
	fi
	if [ -e /sys/module/cpu_boost/parameters/sched_boost_on_input ]; then
	lock_val "N" /sys/module/cpu_boost/parameters/sched_boost_on_input
	fi
	if [ -e "/sys/kernel/cpu_input_boost/enabled" ]; then
	lock_val 1 /sys/kernel/cpu_input_boost/enabled
	lock_val $1 /sys/kernel/cpu_input_boost/ib_duration_ms
	fi
	#Disable Touch Boost
	if [ -e "/sys/module/msm_performance/parameters/touchboost" ]; then
	lock_val 0 /sys/module/msm_performance/parameters/touchboost
	fi
	if [ -e /sys/power/pnpmgr/touch_boost ]; then
	lock_val 0 /sys/power/pnpmgr/touch_boost
	fi
	#Disable CPU Boost
	if [ -e "/sys/module/cpu_boost/parameters/boost_ms" ]; then
	lock_val 0 /sys/module/cpu_boost/parameters/boost_ms
	fi

}
set_boost_freq() {
    cpu_l=$(echo $1 | awk '{split($0,a); print a[1]}') 2>/dev/null
    cpu_b=$(echo $1 | awk '{split($0,a); print a[2]}') 2>/dev/null
    cpu_l_f=$(echo $cpu_l | awk -F: '{ print($NF) }') 2>/dev/null
	cpu_b_f=$(echo $cpu_b | awk -F: '{ print($NF) }') 2>/dev/null
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_freq" ]; then
	freq="0:$cpu_l_f"
	i=1
	while [ $i -lt $bcores ]
	do
	freq="$i:$cpu_l_f $freq"
	i=$(( $i + 1 ))
	done
	i=$bcores
	while [ $i -lt $cores ]
	do
	freq="$i:$cpu_b_f $freq"
	i=$(( $i + 1 ))
	done	
	freq=$(echo $freq | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
	lock_val "$freq" /sys/module/cpu_boost/parameters/input_boost_freq
	if [ -e "/sys/kernel/cpu_input_boost/ib_freqs" ]; then
	lock_val "0" /sys/kernel/cpu_input_boost/ib_freqs
	fi
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_freq_s2" ]; then
	freq="0:0"
	i=1
	while [ $i -lt $cores ]
	do
	freq="$i:0 $freq"
	i=$(( $i + 1 ))
	done
	freq=$(echo $freq | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
	lock_val "$freq" /sys/module/cpu_boost/parameters/input_boost_freq_s2
	fi
	else
	if [ -e "/sys/kernel/cpu_input_boost/ib_freqs" ]; then
	freq="$cpu_l_f $cpu_b_f"
	lock_val "$freq" /sys/kernel/cpu_input_boost/ib_freqs
	fi
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_freq_s2" ]; then
	freq="0:$cpu_l_f"
	i=1
	while [ $i -lt $cores ]
	do
	freq="$i:$cpu_b_f $freq"
	i=$(( $i + 1 ))
	done
	freq=$(echo $freq | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
	lock_val "$freq" /sys/module/cpu_boost/parameters/input_boost_freq_s2
	fi
	fi
	if [ -e "/sys/module/cpu_boost/parameters/sync_threshold" ]; then
	lock_val 0 /sys/module/cpu_boost/parameters/sync_threshold
	lock_val 0 /sys/devices/system/cpu/cpufreq/interactive/sync_freq
	lock_val 0 /sys/devices/system/cpu*/cpufreq/interactive/sync_freq
	fi
}
backup_boost() {
copy "/sys/module/cpu_boost/parameters/input_boost_freq" "/sys/module/cpu_boost/parameters/input_boost_ms" "/data/adb/boost1.txt" "#"
copy "/sys/kernel/cpu_input_boost/ib_freqs" "/sys/kernel/cpu_input_boost/ib_duration_ms" "/data/adb/boost2.txt" "#"
copy "/sys/module/cpu_boost/parameters/input_boost_freq_s2" "/sys/module/cpu_boost/parameters/input_boost_ms_s2" "/data/adb/boost3.txt" "#"
copy "/sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load" "/data/adb/go_hispeed.txt"
copy "/sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load" "/data/adb/go_hispeed_l.txt"
copy "/sys/devices/system/cpu/cpu$bcores/cpufreq/interactive/go_hispeed_load" "/data/adb/go_hispeed_b.txt"
}
restore_boost() {
	if [ -e "/data/adb/boost1.txt" ]; then
	FREQ_FILE="/data/adb/boost1.txt"
	FREQ=$(awk -F# '{ print tolower($1) }' $FREQ_FILE)
	BOOSTMS=$(awk -F# '{ print tolower($2) }' $FREQ_FILE)
	lock_val "$FREQ" /sys/module/cpu_boost/parameters/input_boost_freq
	lock_val $BOOSTMS /sys/module/cpu_boost/parameters/input_boost_ms
	fi
	if [ -e "/data/adb/boost2.txt" ]; then
	FREQ_FILE="/data/adb/boost2.txt"
	FREQ=$(awk -F# '{ print tolower($1) }' $FREQ_FILE)
	BOOSTMS=$(awk -F# '{ print tolower($2) }' $FREQ_FILE)
	lock_val "$FREQ" /sys/kernel/cpu_input_boost/ib_freqs
	lock_val $BOOSTMS /sys/kernel/cpu_input_boost/ib_duration_ms
	fi
	if [ -e "/data/adb/boost3.txt" ]; then
	FREQ_FILE="/data/adb/boost3.txt"
	FREQ=$(awk -F# '{ print tolower($1) }' $FREQ_FILE)
	BOOSTMS=$(awk -F# '{ print tolower($2) }' $FREQ_FILE)
	lock_val "$FREQ" /sys/module/cpu_boost/parameters/input_boost_freq_s2
	lock_val $BOOSTMS /sys/module/cpu_boost/parameters/input_boost_ms_s2
	fi
	if [ -e "/data/adb/go_hispeed" ]; then
	$GO_HIS=$(cat /data/adb/go_hispeed.txt)
	lock_val $GO_HIS /sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load
	fi
	if [ -e "/data/adb/go_hispeed_l" ]; then
	$GO_HIS=$(cat /data/adb/go_hispeed_l.txt)
	lock_val $GO_HIS /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
	fi
	if [ -e "/data/adb/go_hispeed_b" ]; then
	$GO_HIS=$(cat /data/adb/go_hispeed_b.txt)
	lock_val $GO_HIS /sys/devices/system/cpu/cpu$bcores/cpufreq/interactive/go_hispeed_load
	fi
}
backup_eas() {
copy "/dev/stune/top-app/schedtune.boost" "/data/adb/top-app.txt"
copy "/dev/stune/foreground/schedtune.boost" "/data/adb/foreground.txt"
copy "/dev/stune/background/schedtune.boost" "/data/adb/background.txt"
copy "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "/data/adb/dynamic_stune_boost.txt"
}
backup_gpu() {
if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
GPU_DIR="/sys/class/kgsl/kgsl-3d0"
else
GPU_DIR="/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
fi

for i in ${GPU_DIR}/*
do
chmod 0666 $i
done

copy "$GPU_DIR/deep_nap_timer" "/data/adb/deep_nap_timer.txt"
copy "$GPU_DIR/idle_timer" "/data/adb/idle_timer.txt"
}

# stop before updating cfg
stop_qti_perfd()
{
    #stop perfd
    stop perf-hal-1-0
}

# start after updating cfg
start_qti_perfd()
{
    #start perfd
    start perf-hal-1-0
	
}

module_dir=/data/adb/modules/Universal_Kernel_Tweaks
# $1:mode(such as balance)
update_qti_perfd()
{
rm -rf /data/vendor/perfd/*
cp ${module_dir}/system/vendor/etc/perf/perfd_profiles/${1}/targetconfig.xml "${module_dir}/system/vendor/etc/perf/targetconfig.xml"
cp ${module_dir}/system/vendor/etc/perf/perfd_profiles/${1}/perfboostsconfig.xml "${module_dir}/system/vendor/etc/perf/perfboostsconfig.xml"
for i in ${module_dir}/system/vendor/etc/perf/*
do
chmod 0664 $i
done
}

###############################
# Abbreviations
###############################

SCHED="/proc/sys/kernel"
CPU="/sys/devices/system/cpu"
CPU_BOOST="/sys/module/cpu_boost/parameters"
KSGL="/sys/class/kgsl/kgsl-3d0"
DEVFREQ="/sys/class/devfreq"
LPM="/sys/module/lpm_levels/parameters"
MSM_PERF="/sys/module/msm_performance/parameters"
ST_TOP="/dev/stune/top-app"
ST_FORE="/dev/stune/foreground"
ST_BACK="/dev/stune/background"
SDA_Q="/sys/block/sda/queue"

###############################
# Powermodes helper functions
###############################

# $1:keyword $2:nr_max_matched
get_package_name_by_keyword()
{
    echo "$(pm list package | grep "$1" | head -n "$2" | cut -d: -f2)"
}

# $1:"0:576000 4:710400 7:825600"
set_cpufreq_min()
{
    mutate "$1" $MSM_PERF/cpu_min_freq
    local key
    local val
    for kv in $1; do
        key=${kv%:*}
        val=${kv#*:}
        mutate "$val" $CPU/cpu$key/cpufreq/scaling_min_freq
    done
}

# $1:"0:576000 4:710400 7:825600"
set_cpufreq_max()
{
    mutate "$1" $MSM_PERF/cpu_max_freq
}

# $1:"0:576000 4:710400 7:825600"
set_cpufreq_dyn_max()
{
    local key
    local val
    for kv in $1; do
        key=${kv%:*}
        val=${kv#*:}
        mutate "$val" $CPU/cpu$key/cpufreq/scaling_max_freq
    done
}

# $1:"schedutil/pl" $2:"0:4 4:3 7:1"
set_governor_param()
{
    local key
    local val
    for kv in $2; do
        key=${kv%:*}
        val=${kv#*:}
        mutate "$val" $CPU/cpu$key/cpufreq/$1
    done
}

# $1:"min_cpus" $2:"0:4 4:3 7:1"
set_corectl_param()
{
    local key
    local val
    for kv in $2; do
        key=${kv%:*}
        val=${kv#*:}
        mutate "$val" $CPU/cpu$key/core_ctl/$1
    done
}

# $1:upmigrate $2:downmigrate $3:group_upmigrate $4:group_downmigrate
set_sched_migrate()
{
    mutate "$2" $SCHED/sched_downmigrate
    mutate "$1" $SCHED/sched_upmigrate
    mutate "$2" $SCHED/sched_downmigrate
    mutate "$4" $SCHED/sched_group_downmigrate
    mutate "$3" $SCHED/sched_group_upmigrate
    mutate "$4" $SCHED/sched_group_downmigrate
}

set_param() {
 if [ $1 = "cpu0" ];then
	if [ -d "/sys/devices/system/cpu/cpufreq/interactive" ]; then
	write /sys/devices/system/cpu/cpufreq/interactive/$2 "$3"
    else
	i=0
	t_cores=${bcores}
	while [ $i -lt $t_cores ]
	do
	CPU_DIR="/sys/devices/system/cpu/cpu$i"
	write ${CPU_DIR}/cpufreq/interactive/$2 "$3"
	i=$(( $i + 1 ))
	done
	fi
fi
if [ $1 = "cpu${bcores}" ];then
	i=${bcores}
	t_cores=${cores}
	while [ $i -lt $t_cores ]
	do
	CPU_DIR="/sys/devices/system/cpu/cpu$i"
	write ${CPU_DIR}/cpufreq/interactive/$2 "$3"
	i=$(( $i + 1 ))
	done			
fi

}
set_param_all() 
{
	set_param cpu0 $1 $2
	${is_big_little} && set_param cpu${bcores} $1 $2
}
change_task_cgroup()
{
    # avoid matching grep itself
    # ps -Ao pid,args | grep kswapd
    # 150 [kswapd0]
    # 16490 grep kswapd
    local ps_ret
    ps_ret="$(ps -Ao pid,args)"
    for temp_pid in $(echo "$ps_ret" | grep "$1" | awk '{print $1}'); do
        for temp_tid in $(ls "/proc/$temp_pid/task/"); do
            echo "$temp_tid" > "/dev/$3/$2/tasks"
        done
    done
}

# $1:task_name $2:hex_mask(0x00000003 is CPU0 and CPU1)
change_task_affinity()
{
    # avoid matching grep itself
    # ps -Ao pid,args | grep kswapd
    # 150 [kswapd0]
    # 16490 grep kswapd
    local ps_ret
    ps_ret="$(ps -Ao pid,args)"
    for temp_pid in $(echo "$ps_ret" | grep "$1" | awk '{print $1}'); do
        for temp_tid in $(ls "/proc/$temp_pid/task/"); do
            taskset -p "$2" "$temp_tid"
        done
    done
}

HAS_BAK=0
LOG="/data/Universal_Kernel_Tweaks.prop"
RETRY_INTERVAL=10 #in seconds
MAX_RETRY=30
retry=${MAX_RETRY}
#wait for boot completed
A=$(getprop sys.boot_completed | tr -d '\r')


if [ -e $LOG ]; then
  rm $LOG;
fi;
PARAM_BAK_FILE="/data/adb/.Universal_Kernel_Tweaks_param_bak"
if [ "$1" == "" ];then
if [ -e "/data/adb/boost1.txt" ]; then
rm "/data/adb/boost1.txt"
fi;
if [ -e "/data/adb/boost2.txt" ]; then
rm "/data/adb/boost2.txt"
fi;
if [ -e "/data/adb/boost3.txt" ]; then
rm "/data/adb/boost3.txt"
fi;
if [ -e "/data/adb/background.txt" ]; then
rm "/data/adb/background.txt"
fi;
if [ -e "/data/adb/foreground.txt" ]; then
rm "/data/adb/foreground.txt"
fi;
if [ -e "/data/adb/top-app.txt" ]; then
rm "/data/adb/top-app.txt"
fi;
if [ -e "/data/adb/dynamic_stune_boost.txt" ]; then
rm "/data/adb/dynamic_stune_boost.txt"
fi;
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
backup_boost
backup_eas
backup_gpu
fi;

    if [ "$2" == "" ];then
    PROFILE="<PROFILEMODE>"
    if [ -e "/data/adb/.Universal_Kernel_Tweaks_cur_level" ]; then
	PROFILE=$(cat /data/adb/.Universal_Kernel_Tweaks_cur_level | tr -d '\n')
	else
	echo $PROFILE > "/data/adb/.Universal_Kernel_Tweaks_cur_level"
	fi
	else
    PROFILE=$1
	rm "/data/adb/.Universal_Kernel_Tweaks_cur_level"
	if [ ! -f "/data/adb/.Universal_Kernel_Tweaks_cur_level" ]; then
	echo $1 > "/data/adb/.Universal_Kernel_Tweaks_cur_level"
    fi
	fi
    if [ -z $2 ];then
    bootdelay=90
    else
    bootdelay=$2
    fi
sleep ${bootdelay}
    export TZ=$(getprop persist.sys.timezone);
    #MOD Variable
    V="<VER>"
    dt=$(date '+%d/%m/%Y %H:%M:%S');
    sbusybox=`busybox | awk 'NR==1{print $2}'` 2>/dev/null
    # RAM variables
    TOTAL_RAM=$(awk '/^MemTotal:/{print $2}' /proc/meminfo) 2>/dev/null
    if [ $TOTAL_RAM -ge 1000000 ] && [ $TOTAL_RAM -lt 1500000 ]; then
    memg=$(awk -v x=$TOTAL_RAM 'BEGIN{print x/1000000}')
    memg=$(round ${memg} 1)
	else
    memg=$(awk -v x=$TOTAL_RAM 'BEGIN{printf("%.f\n", (x/1000000)+0.5)}')
    memg=$(round ${memg} 0)
    fi
    if [ ${memg} -gt 32 ];then
    memg=$(awk -v x=$memg 'BEGIN{printf("%.f\n", (x/1000)+0.5)}')
    fi
    # CPU variables
    arch_type=`uname -m` 2>/dev/null
    # Device infos
    BATT_LEV=`cat /sys/class/power_supply/battery/capacity | tr -d '\n'` 2>/dev/null
    BATT_TECH=`cat /sys/class/power_supply/battery/technology | tr -d '\n'` 2>/dev/null
    BATT_HLTH=`cat /sys/class/power_supply/battery/health | tr -d '\n'` 2>/dev/null
    BATT_TEMP=`cat /sys/class/power_supply/battery/temp | tr -d '\n'` 2>/dev/null
    BATT_VOLT=`cat /sys/class/power_supply/battery/batt_vol | tr -d '\n'` 2>/dev/null
    if [ "$BATT_LEV" == "" ];then
    BATT_LEV=`dumpsys battery | grep level | awk '{print $2}'` 2>/dev/null
    elif [ "$BATT_LEV" == "" ];then
    BATT_LEV=$(awk -F ': |;' '$1=="Percentage(%)" {print $2}' /sys/class/power_supply/battery/batt_attr_text) 2>/dev/null
    fi
    if [ "$BATT_TECH" == "" ];then
    BATT_TECH=`dumpsys battery | grep technology | awk '{print $2}'` 2>/dev/null
    fi
    if [ "$BATT_VOLT" == "" ];then
    BATT_VOLT=`dumpsys battery | awk '/^ +voltage:/ && $NF!=0{print $NF}'` 2>/dev/null
    elif [ "$BATT_VOLT" == "" ];then
    BATT_VOLT=$(awk -F ': |;' '$1=="VBAT(mV)" {print $2}' /sys/class/power_supply/battery/batt_attr_text) 2>/dev/null
    fi
    if [ "$BATT_TEMP" == "" ];then
    BATT_TEMP=`dumpsys battery | grep temperature | awk '{print $2}'` 2>/dev/null
    elif [ "$BATT_TEMP" == "" ];then
    BATT_TEMP=$(awk -F ': |;' '$1=="BATT_TEMP" {print $2}' /sys/class/power_supply/battery/batt_attr_text) 2>/dev/null
    fi
    if [ "$BATT_HLTH" == "" ];then
    BATT_HLTH=`dumpsys battery | grep health | awk '{print $2}'` 2>/dev/null
    if [ $BATT_HLTH -eq "2" ];then
    BATT_HLTH="Excellent"
    elif [ $BATT_HLTH -eq "3" ];then
    BATT_HLTH="Good"
    elif [ $BATT_HLTH -eq "4" ];then
    BATT_HLTH="Poor"
    elif [ $BATT_HLTH -eq "5" ];then
    BATT_HLTH="Bad"
    else
    BATT_HLTH="Unknown"
    fi
    elif [ "$BATT_HLTH" == "" ];then
    BATT_HLTH=$(awk -F ': |;' '$1=="HEALTH" {print $2}' /sys/class/power_supply/battery/batt_attr_text) 2>/dev/null
    if [ $BATT_HLTH -eq "1" ];then
    BATT_HLTH="Excellent"
    else
    BATT_HLTH="Unknown"
    fi
    fi
    BATT_TEMP=$(awk -v x=$BATT_TEMP 'BEGIN{print x/10}')
    BATT_VOLT=$(awk -v x=$BATT_VOLT 'BEGIN{print x/1000}')
    BATT_VOLT=$(round ${BATT_VOLT} 1) 
    VENDOR=`getprop ro.product.brand | tr '[:lower:]' '[:upper:]'`
    KERNEL="$(uname -r)"
    OS=`getprop ro.build.version.release`
    APP=`getprop ro.product.model`
    SOC=$(awk '/^Hardware/{print tolower($NF)}' /proc/cpuinfo | tr -d '\n') 2>/dev/null
    SOC0=`cat /sys/devices/soc0/machine  | tr -d '\n' | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC1=`cat /sys/devices/soc0/soc_id  | tr -d '\n' | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC2=`getprop ro.product.board | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC3=`getprop ro.product.platform | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC4=`getprop ro.board.platform | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC5=`getprop ro.chipname | tr '[:upper:]' '[:lower:]'` 2>/dev/null
    SOC6=`getprop ro.hardware | tr '[:upper:]' '[:lower:]'` 2>/dev/null
	soc_id=$(cat /sys/devices/soc0/id) 2>/dev/null
	soc_revision=$(cat /sys/devices/soc0/revision) 2>/dev/null
	adreno=0
	if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/class/kgsl/kgsl-3d0"
	adreno=1
	elif [ -d "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0"
	adreno=1
	elif [ -d "/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
	adreno=1
	elif [ -d "/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0" ]; then
	GPU_DIR="/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
	adreno=1
	elif [ -d "/sys/devices/platform/*.gpu/devfreq/*.gpu" ]; then
	GPU_DIR="/sys/devices/platform/*.gpu/devfreq/*.gpu"	
	adreno=0
	elif [ -d "/sys/devices/platform/gpusysfs" ]; then
	GPU_DIR="/sys/devices/platform/gpusysfs"
	adreno=0
	elif [ -d "/sys/devices/*.mali" ]; then
	GPU_DIR="/sys/devices/*.mali"
	adreno=0
	elif [ -d "/sys/devices/*.gpu" ]; then
	GPU_DIR="/sys/devices/*.gpu"
	adreno=0
	elif [ -d "/sys/devices/platform/mali.0" ]; then
	GPU_DIR="/sys/devices/platform/mali.0"
	adreno=0
	elif [ -d "/sys/devices/platform/mali-*.0" ]; then
	GPU_DIR="/sys/devices/platform/mali-*.0"
	adreno=0
	elif [ -d "/sys/module/mali/parameters" ]; then
	GPU_DIR="/sys/module/mali/parameters"
	adreno=0
	elif [ -d "/sys/class/misc/mali0" ]; then
	GPU_DIR="/sys/class/misc/mali0"
	adreno=0
	elif [ -d "/sys/kernel/gpu" ]; then
	GPU_DIR="/sys/kernel/gpu"
	adreno=0
	fi
	if [ -e "$GPU_DIR/devfreq/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/devfreq/available_frequencies) 2>/dev/null
	elif [ -d "$GPU_DIR/devfreq/*.mali/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/devfreq/*.mali/available_frequencies) 2>/dev/null
	elif [ -d "$GPU_DIR/device/devfreq/*.gpu/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/device/devfreq/*.gpu/available_frequencies) 2>/dev/null
	elif [ -d "$GPU_DIR/device/available_frequencies" ]; then
	GPU_FREQS=$(cat $GPU_DIR/device/available_frequencies) 2>/dev/null
	fi

	if [ -e "$GPU_DIR/devfreq/available_governors" ]; then
	GPU_GOV=$(cat $GPU_DIR/devfreq/available_governors) 2>/dev/null
	elif [ -d "$GPU_DIR/devfreq/*.mali/available_governors" ]; then
	GPU_GOV=$(cat $GPU_DIR/devfreq/*.mali/available_governors) 2>/dev/null
	elif [ -d "$GPU_DIR/device/devfreq/*.gpu/available_governors" ]; then
	GPU_GOV=$(cat $GPU_DIR/device/devfreq/*.gpu/available_governors) 2>/dev/null
	elif [ -d "$GPU_DIR/device/available_governors" ]; then
	GPU_GOV=$(cat $GPU_DIR/device/available_governors) 2>/dev/null
	fi

	if [ -e "$GPU_DIR/gpu_model" ]; then
	GPU_MODEL=$(cat $GPU_DIR/gpu_model) 2>/dev/null
	elif [ -d "$GPU_DIR/*.mali/gpu_model" ]; then
	GPU_MODEL=$(cat $GPU_DIR/*.mali/gpu_model) 2>/dev/null
	elif [ -d "$GPU_DIR/device/*.gpu/gpu_model" ]; then
	GPU_MODEL=$(cat $GPU_DIR/device/*.gpu/gpu_model) 2>/dev/null
	elif [ -d "$GPU_DIR/device/gpu_model" ]; then
	GPU_MODEL=$(cat $GPU_DIR/device/gpu_model) 2>/dev/null
	fi
    fstorage=$(cat proc/scsi/scsi | grep -m1 Vendor | awk '{print $4}') 2>/dev/null
	
 	case "${fstorage}" in
 	"KLUCG2K1EA-B0C1") UFS=210;;
 	"KLUCG4J1ED-B0C1") UFS=210;;
 	"KLUDG8V1EE-B0C1") UFS=210;;
 	"KLUEG8U1EM-B0C1") UFS=210;;
 	"KLUDG4U1EA-B0C1") UFS=210;;
 	"THGAF4G8N2LBAIR") UFS=210;;
 	"THGAF8T0T43BAIR") UFS=210;;
 	"H28U62301AMR") UFS=210;;
 	"H28S6D302BMR") UFS=210;;
 	"H28U74301AMR") UFS=210;;
 	"H28S7Q302BMR") UFS=210;;
 	"H28U88301AMR") UFS=210;;
 	"H28S8Q302CMR") UFS=210;;
 	"H28S9O302BMR") UFS=210;;
 	"THGBF7G8K4LBATR") UFS=200;;
 	"THGBF7G9L4LBATR") UFS=200;;
 	"THGBF7T0L8LBATA") UFS=200;;
 	"KLUBG4G1CE-B0B1") UFS=200;;
 	"KLUCG4J1CB-B0B1") UFS=200;;
 	"KLUDG8J1CB-B0B1") UFS=200;;
	*) UFS=100;;
	esac
    CPU_FILE="/data/soc.txt"
    error=0
    support=0
    snapdragon=0
    chip=0
	EAS=0
	HMP=0
	shared=1
	MSG=0
    LOGDATA() {
        echo $1 |  tee -a $LOG;
    }
    if [ -e /sys/devices/system/cpu/cpu0/cpufreq ]; then
    GOV_PATH_L=/sys/devices/system/cpu/cpu0/cpufreq
    fi
    if [ -e "/sys/devices/system/cpu/cpu${bcores}/cpufreq" ]; then
    GOV_PATH_B="/sys/devices/system/cpu/cpu${bcores}/cpufreq"
    fi
	available_governors=$(cat ${GOV_PATH_L}/scaling_available_governors)
    is_big_little=true
    if [ -z ${SOC} ];then
	error=1
    SOC=${SOC0}
	else
    #LOGDATA "|		SORRY COULDN'T DETECT SOC. TRYING ALTERNATIVES"
	case ${SOC} in msm* | sm* | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC0}
    fi
    ;;
	*)
	error=2
    SOC=${SOC0}
    ;;
	esac
    fi
    if [ -z ${SOC} ];then
	error=1
	SOC=${SOC1}
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "|		SORRY COULDN'T DETECT SOC USING METHOD(0). TRYING ALTERNATIVES"
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC1}
    fi
    ;;
	*)
	error=2
	SOC=${SOC1}
    ;;
	esac
    fi
    fi
    if [ -z ${SOC} ];then
	error=1
	SOC=${SOC2}
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "|		SORRY COULDN'T DETECT SOC USING METHOD(1). TRYING ALTERNATIVES"
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC2}
    fi
    ;;
	*)
	error=2
	SOC=${SOC2}
    ;;
	esac
    fi
    fi
    if [ -z ${SOC} ];then
	error=1
	SOC=${SOC3}
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "|		SORRY COULDN'T DETECT SOC USING METHOD(2). TRYING ALTERNATIVES"
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC3}
    fi
    ;;
	*)
	error=2
 	SOC=${SOC3}
    ;;
	esac
    fi
    fi
    if [ -z ${SOC} ];then
	error=1
	SOC=${SOC4}
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "|		SORRY COULDN'T DETECT SOC USING METHOD(3). TRYING ALTERNATIVES"
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC4}
    fi
     ;;
	*)
	error=2
    SOC=${SOC4}
    ;;
	esac
    fi
    fi
    if [ -z ${SOC} ];then
	error=1
	SOC=${SOC5}
	else
    if [ $error -ne 0 ]; then
    #LOGDATA "|		SORRY COULDN'T DETECT SOC USING METHOD(4). TRYING ALTERNATIVES"
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
    if [[ ! -n ${SOC//[a-z]} ]] && [ "$SOC" != "moorefield" ]; then
	error=2
    SOC=${SOC5}
    fi
     ;;
	*)
	error=2
    SOC=${SOC5}
    ;;
	esac
    fi
    fi
    if [ -z ${SOC} ];then
    LOGDATA "|		SORRY COULDN'T DETECT SOC. USING MANUAL METHOD"
    if [ -e $CPU_FILE ]; then
    if grep -q 'CPU=' $CPU_FILE
    then
    SOC7=$(awk -F= '{ print tolower($2) }' $CPU_FILE) 2>/dev/null
    else
    SOC7=$(cat $CPU_FILE | tr '[:upper:]' '[:lower:]') 2>/dev/null
    fi	
    SOC=${SOC7}
    if [ -z ${SOC} ];then
    error=3
    LOGDATA "|		SORRY COULDN'T DETECT SOC MANUALLY"
    LOGDATA "| 		$CPU_FILE IS EMPTY"
    LOGDATA "|		PLEASE EDIT $CPU_FILE FILE WITH YOUR SOC MODEL NUMBER THEN REBOOT"
    exit 0
    fi
    case ${SOC} in msm* | sm* | "8cx" | apq* | sdm* | sda* | exynos* | universal* | kirin* | hi* | moorefield* | mt*)
	error=0
	;;
	*)
    LOGDATA "|		SORRY COULDN'T DETECT SOC MANUALLY"
    LOGDATA "|		$CPU_FILE DOES NOT CONTAIN A VALID CPU MODEL NUMBER"
    LOGDATA "|		PLEASE EDIT $CPU_FILE FILE WITH YOUR CORRECT SOC MODEL NUMBER THEN REBOOT"
    exit 0
	;;
	esac
    else
    LOGDATA "|		SORRY COULDN'T DETECT SOC "
    LOGDATA "|  "
    LOGDATA "|		1) USING A ROOT FILE EXPLORER"
    LOGDATA "|  "
    LOGDATA "|		2) GO TO $CPU_FILE AND EDIT IT WITH YOUR CPU MODEL"
    LOGDATA "|  "
    LOGDATA "|    EXAMPLE (HUAWEI KIRIN 970)       CPU=KIRIN970"
    LOGDATA "|    EXAMPLE (SNAPDRAGON 845)         CPU=SDM845"
    LOGDATA "|    EXAMPLE (SNAPDRAGON 820 OR 821)  CPU=MSM8996"
    LOGDATA "|    EXAMPLE (GALAXY S7 EXYNOS8890)   CPU=EXYNOS8890"
    LOGDATA "|    EXAMPLE (GALAXY S8 EXYNOS8890)   CPU=EXYNOS8895"
    LOGDATA "|  "
    LOGDATA '    PRECEEDING THE CPU MODEL NUMBER WITH "CPU=" IS NOT REQUIRED '
    LOGDATA "|    YOU CAN ALSO WRITE ONLY YOUR CPU MODEL IN SOC.TXT FILE "
    LOGDATA "|  "
    LOGDATA "| 3) SAVE CHANGES & REBOOT"
    LOGDATA "|  "
    LOGDATA "|  "
    LOGDATA "|  "
    LOGDATA "|  "
    LOGDATA "| TIP: USE CPU-Z APP OR FIND YOUR CORRECT CPU MODEL NUMBER ON THIS PAGE"
    LOGDATA "|  "
    LOGDATA "| https://en.wikipedia.org/wiki/List_of_Qualcomm_Snapdragon_systems-on-chip"
    write $CPU_FILE "CPU="
    exit 0
    fi	
    fi
     SOC="${SOC//[[:space:]]/}"
    SOC=`echo $SOC | tr -d -c '[:alnum:]'`
	freqs_list0=$(cat $GOV_PATH_L/scaling_available_frequencies) 2>/dev/null
    freqs_list4=$(cat $GOV_PATH_B/scaling_available_frequencies) 2>/dev/null
	
	freqs_list0_alt=$(cat $GOV_PATH_L_alt/scaling_available_frequencies) 2>/dev/null
    freqs_list4_alt=$(cat $GOV_PATH_B_alt/scaling_available_frequencies) 2>/dev/null
	
	maxfreq_l="$(max $freqs_list0)"
	maxfreq_b="$(max $freqs_list4)"
	minfreq_l="$(min $freqs_list0)"
	minfreq_b="$(min $freqs_list4)"
	
    if [ -z ${maxfreq_b} ] || [ ${maxfreq_b} == "" ] || [ ${maxfreq_b} -eq 0 ]; then
	maxfreq_l="$(max $freqs_list0_alt)"
	maxfreq_b="$(max $freqs_list4_alt)"
	minfreq_l="$(min $freqs_list0_alt)"
	minfreq_b="$(min $freqs_list4_alt)"
    fi
	
	freqs_list0=$(cat $GOV_PATH_L/stats/time_in_state) 2>/dev/null
    freqs_list4=$(cat $GOV_PATH_B/stats/time_in_state) 2>/dev/null

	if [ ! -f ${GOV_PATH_L}/scaling_available_frequencies ]  || [ ! -f ${GOV_PATH_L_alt}/scaling_available_frequencies ] || [ -z ${maxfreq_b} ] || [ ${maxfreq_b} == "" ] || [ ${maxfreq_b} -eq 0 ]; then
	maxfreq_l=$(cat "$GOV_PATH_L/cpuinfo_max_freq") 2>/dev/null	
    maxfreq_b=$(cat "$GOV_PATH_B/cpuinfo_max_freq") 2>/dev/null
	minfreq_l=$(cat "$GOV_PATH_L/cpuinfo_min_freq") 2>/dev/null	
    minfreq_b=$(cat "$GOV_PATH_B/cpuinfo_min_freq") 2>/dev/null
	
	if [ -z ${maxfreq_b} ] || [ ${maxfreq_b} == "" ] || [ ${maxfreq_b} -eq 0 ]; then
	maxfreq_l=$(cat "$GOV_PATH_L_alt/cpuinfo_max_freq") 2>/dev/null	
    maxfreq_b=$(cat "$GOV_PATH_B_alt/cpuinfo_max_freq") 2>/dev/null
	minfreq_l=$(cat "$GOV_PATH_L_alt/cpuinfo_min_freq") 2>/dev/null	
    minfreq_b=$(cat "$GOV_PATH_B_alt/cpuinfo_min_freq") 2>/dev/null
    fi
    fi
	
	if [ ! -e "${GOV_PATH_L}/scaling_available_frequencies" ] && [ ! -e "${GOV_PATH_L}/cpuinfo_max_freq" ]; then
	maxfreq_l=$(cat "/sys/devices/system/cpu/cpufreq/cpuinfo_max_freq") 2>/dev/null	
    maxfreq_b=${maxfreq_l}
	minfreq_l=$(cat "/sys/devices/system/cpu/cpufreq/cpuinfo_max_freq") 2>/dev/null	
    minfreq_b=${minfreq_l}
    fi

	GPU_MIN="$(min $GPU_FREQS)"
	GPU_MAX="$(max $GPU_FREQS)"
	
	if [ ! -e ${GPU_FREQS} ]; then
	GPU_MIN=$(cat "$GPU_DIR/devfreq/min_freq") 2>/dev/null	
	GPU_MAX=$(cat "$GPU_DIR/devfreq/max_freq") 2>/dev/null	
	fi

	if [ ! -e ${GPU_DIR}/devfreq/max_freq ] && [ ! -e ${GPU_DIR}/devfreq/max_freq ]; then
	GPU_MIN=$(cat "$GPU_DIR/gpuclk") 2>/dev/null	
	GPU_MAX=$(cat "$GPU_DIR/max_gpuclk") 2>/dev/null	
    fi

    before_modify()
{
for i in ${GOV_PATH_L}/interactive/*
do
chmod 0666 $i
done
for i in ${GOV_PATH_B}/interactive/*
do
chmod 0666 $i
done
if [ -d "/sys/devices/system/cpu/cpufreq/interactive" ]; then
for i in /sys/devices/system/cpu/cpufreq/interactive/*
do
chmod 0666 $i
done
fi
}
    after_modify()
{
for i in ${GOV_PATH_L}/interactive/*
do
chmod 0444 $i
done
for i in ${GOV_PATH_B}/interactive/*
do
chmod 0444 $i
done
if [ -d "/sys/devices/system/cpu/cpufreq/interactive" ]; then
for i in /sys/devices/system/cpu/cpufreq/interactive/*
do
chmod 0444 $i
done
fi
}
    before_modify_eas()
{
for i in ${GOV_PATH_L}/$1/*
do
chown 0.0 $i
chmod 0666 $i
done
for i in ${GOV_PATH_B}/$1/*
do
chown 0.0 $i
chmod 0666 $i
done	
}
    after_modify_eas()
{
for i in ${GOV_PATH_L}/$1/*
do
chmod 0444 $i
done
for i in ${GOV_PATH_B}/$1/*
do
chmod 0444 $i
done	
}
C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpu0/cpufreq/interactive"
C1_GOVERNOR_DIR="/sys/devices/system/cpu/cpu${bcores}/cpufreq/interactive"
C0_CPUFREQ_DIR="/sys/devices/system/cpu/cpu0/cpufreq"
C1_CPUFREQ_DIR="/sys/devices/system/cpu/cpu${bcores}/cpufreq"
if ! ${is_big_little} ; then
	C0_GOVERNOR_DIR="/sys/devices/system/cpu/cpufreq/interactive"
	C1_GOVERNOR_DIR=""
	C0_CPUFREQ_DIR="/sys/devices/system/cpu/cpu0/cpufreq"
	C1_CPUFREQ_DIR=""
fi

update_clock_speed() {
 if [ $2 = "little" ];then
	i=0
  	lock_val "${i}:${1}" "/sys/module/msm_performance/parameters/cpu_${3}_freq"
	#chmod 0644 "/sys/module/msm_performance/parameters/cpu_${3}_freq"
	while [ ${i} -lt ${bcores} ]
	do
if [ ! -e sys/devices/system/cpu/cpu${i}/cpufreq/ ];then
CPUFREQ_DIR=sys/devices/system/cpu/cpufreq/policy${i}
else
CPUFREQ_DIR=/sys/devices/system/cpu/cpu${i}/cpufreq
fi
	lock_val "${1}" "${CPUFREQ_DIR}/scaling_${3}_freq"
	#chmod 0644 "${1}" "${CPUFREQ_DIR}/scaling_${3}_freq"
	i=$(( ${i} + 1 ))
	done		
fi
if [ $2 = "big" ];then
if [ -d "/sys/devices/system/cpu/cpufreq/policy6" ];then
	t_cores=${pcores}
  	lock_val "4:${1} 5:${1}" "/sys/module/msm_performance/parameters/cpu_${3}_freq"
	#chmod 0644 "/sys/module/msm_performance/parameters/cpu_${3}_freq"
else
	t_cores=${cores}
fi

	i=${bcores}

	while [ ${i} -lt ${t_cores} ]
	do

if [ ! -e sys/devices/system/cpu/cpu${i}/cpufreq/ ];then
CPUFREQ_DIR=sys/devices/system/cpu/cpufreq/policy${i}
else
CPUFREQ_DIR=/sys/devices/system/cpu/cpu${i}/cpufreq
fi
	lock_val "${1}" "${CPUFREQ_DIR}/scaling_${3}_freq"
	#chmod 0644 "${1}" "${CPUFREQ_DIR}/scaling_${3}_freq"
	i=$(( ${i} + 1 ))
	done			
fi
if [ $2 = "prime" ];then
if [ ! -e sys/devices/system/cpu/cpu6/cpufreq/ ];then
CPUFREQ_DIR=sys/devices/system/cpu/cpufreq/policy6
else
CPUFREQ_DIR=/sys/devices/system/cpu/cpu6/cpufreq
fi
  	lock_val "6:${1} 7:${1}" "/sys/module/msm_performance/parameters/cpu_${3}_freq"
	#chmod 0644 "/sys/module/msm_performance/parameters/cpu_${3}_freq"
	
    lock_val "${1}" "${CPUFREQ_DIR}/scaling_${3}_freq"
	#chmod 0644 "${1}" "${CPUFREQ_DIR}/scaling_${3}_freq"
fi

if [ -f  "/proc/cpufreq/cpufreq_limited_$3_freq_by_user"  ]; then
	lock_val ${1} "/proc/cpufreq/cpufreq_limited_$3_freq_by_user"
	#chmod 0644 "/proc/cpufreq/cpufreq_limited_$3_freq_by_user"
fi
}
set_io() {

	if [ -f $2/queue/scheduler ]; then
		if [ `grep -c $1 $2/queue/scheduler` = 1 ]; then
			write $2/queue/scheduler $1
			if [[ "$1" == "cfq" ]];then
			# lower read_ahead_kb to reduce random access overhead
			write $2/queue/read_ahead_kb 128
			for i in /sys/block/*/queue/iosched; do
			  write $i/low_latency 0;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/group_idle 8;
			done;
			if [ $UFS -ge 200 ]; then
		    	# UFS 2.0+ hardware queue depth is 32
		    	for i in /sys/block/*/queue/iosched; do
		    	    write $i/quantum 16;
		    	done;
			fi
			# slice_idle = 0 means CFQ IOP mode, https://lore.kernel.org/patchwork/patch/944972/
			for i in /sys/block/*/queue/iosched; do
			  write $i/slice_idle 0;
			done;
			# Flash doesn't have back seek problem, so penalty is as low as possible
			for i in /sys/block/*/queue/iosched; do
			  write $i/back_seek_penalty 1;
			done;
				elif [[ "$1" == "maple" ]];then
			for i in /sys/block/*/queue/iosched; do
			  write $i/async_read_expire 666;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/async_write_expire 1666;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/fifo_batch 16;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/sleep_latency_multiple 5;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/sync_read_expire 333;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/sync_write_expire 1166;
			done;
			for i in /sys/block/*/queue/iosched; do
			  write $i/writes_starved 3;
			done;
			else
			write $2/queue/read_ahead_kb 128
			fi
  		fi
	fi
	
}
    # Manually add infos that are not found/ inaccurate for some devices
	case ${SOC} in sm8150* | msmnile* ) #sd855
    support=1
PLATFORM_NAME="sdm855"
BWMON_CPU_LLC="soc:qcom,cpu-cpu-llcc-bw"
BWMON_LLC_DDR="soc:qcom,cpu-llcc-ddr-bw"
BIG_L3_LAT="soc:qcom,cpu4-cpu-l3-lat"
BIG_DDR_LAT="soc:qcom,cpu4-llcc-ddr-lat"
STUNE_BG_CPUS="0-3"
STUNE_FG_CPUS="0-6"
	esac
	case ${SOC} in sdm845* | sda845* ) #sd845
    support=1
PLATFORM_NAME="sdm845"
BWMON_CPU_LLC="soc:qcom,cpubw"
BWMON_LLC_DDR="soc:qcom,llccbw"
BIG_L3_LAT="soc:qcom,l3-cpu4"
BIG_DDR_LAT="soc:qcom,memlat-cpu4"
STUNE_BG_CPUS="0-3"
STUNE_FG_CPUS="0-6"
	esac
	case ${SOC} in msm8998* | apq8098*) #sd835
    support=1
PLATFORM_NAME="msm8998"
BWMON_CPU_LLC="soc:qcom,cpubw"
BWMON_LLC_DDR="soc:qcom,llccbw"
BIG_L3_LAT=""
BIG_DDR_LAT="soc:qcom,memlat-cpu4"
STUNE_BG_CPUS="0-3"
STUNE_FG_CPUS="0-6"
	esac
    case ${SOC} in msm8996* | apq8096*) #sd820
    support=1
PLATFORM_NAME="msm8996"
BWMON_CPU_LLC="soc:qcom,cpubw"
BWMON_LLC_DDR="soc:qcom,llccbw"
BIG_L3_LAT=""
BIG_DDR_LAT="soc:qcom,memlat-cpu2"
STUNE_BG_CPUS="0-1"
STUNE_FG_CPUS="0-3"
	esac

	case ${SOC} in sm6150*) #sd675/730
    support=1
BWMON_CPU_LLC="soc:qcom,cpu-cpu-llcc-bw"
BWMON_LLC_DDR="soc:qcom,cpu-llcc-ddr-bw"
BIG_L3_LAT="soc:qcom,cpu6-cpu-l3-lat"
BIG_DDR_LAT="soc:qcom,cpu6-llcc-ddr-lat"
STUNE_BG_CPUS="0-5"
STUNE_FG_CPUS="0-7"
	esac
	
	case ${SOC} in sdm710*) #sd710
PLATFORM_NAME="sdm710"
BWMON_CPU_LLC="soc:qcom,cpubw"
BWMON_LLC_DDR="soc:qcom,cpubw"
BIG_L3_LAT="soc:qcom,l3-cpu6"
BIG_DDR_LAT="soc:qcom,memlat-cpu6"
STUNE_BG_CPUS="0-5"
STUNE_FG_CPUS="0-7"
	esac

	case ${SOC} in msm8994*) #sd810
    support=1
	cores=8
	bcores=4
	esac
	case ${SOC} in msm8992*) #sd808
    support=1
	cores=6
	bcores=4
	esac
	case ${SOC} in apq8074* | apq8084* | msm8074* | msm8084* | msm8274* | msm8674*| msm8974*)  #sd800-801-805
	is_big_little=false
    support=1
	esac
	case ${SOC} in sdm660* | sda660*) #sd660
    support=1
	esac
	case ${SOC} in msm8956* | msm8976* | apq8076*)  #sd650/652/653
    support=1
	esac
	case ${SOC} in sdm636* | sda636*) #sd636
    support=1
	esac
	case ${SOC} in msm8953* | sdm630* | sda630* )  #sd625/626/630
    support=1
	esac

	case ${SOC} in universal8895* | exynos8895*)  #EXYNOS8895 (S8)
    support=1
	cores=8
	bcores=4
	esac
	case ${SOC} in universal8890* | exynos8890*)  #EXYNOS8890 (S7)
    support=1
	cores=8
	bcores=4
	esac
	case ${SOC} in universal7420* | exynos7420*) #EXYNOS7420 (S6)
    support=1
	esac
	case ${SOC} in kirin970* | hi3670*)  # Huawei Kirin 970
    support=1
	esac
	case ${SOC} in kirin960* | hi3660*)  # Huawei Kirin 960
    support=1
	esac
	case ${SOC} in kirin950* | hi3650* | kirin955* | hi3655*) # Huawei Kirin 950
    support=1
	esac
	case ${SOC} in mt6797*) #Helio X25 / X20	 
    support=1
	esac
	case ${SOC} in mt6795*) #Helio X10
    support=1
	esac
	case ${SOC} in moorefield*) # Intel Atom
    support=1
	esac
	case ${SOC} in msm8939* | msm8952*)  #sd615/616/617 by@ 橘猫520
    support=2
	cores=8
	bcores=4
	MSG=1
    esac
    case ${SOC} in kirin650* | kirin655* | kirin658* | kirin659* | hi625*)  #KIRIN650 by @橘猫520
    support=2
	MSG=1
    esac
    case ${SOC} in apq8026* | apq8028* | apq8030* | msm8226* | msm8228* | msm8230* | msm8626* | msm8628* | msm8630* | msm8926* | msm8928* | msm8930*)  #sd400 series by @cjybyjk
	is_big_little=false
    support=2
	cores=4
	bcores=2
	MSG=1
    esac
	case ${SOC} in apq8016* | msm8916* | msm8216* | msm8917* | msm8217*)  #sd410/sd425 series by @cjybyjk
	is_big_little=false
    support=2
	cores=4
	bcores=2
	MSG=2
    esac
	case ${SOC} in msm8937*)  #sd430 series by @cjybyjk
    support=2
	cores=8
	bcores=4
	MSG=1
    esac
	case ${SOC} in msm8940*)  #sd435 series by @cjybyjk
	is_big_little=false
    support=2
	cores=8
	bcores=4
	MSG=1
    esac
	case ${SOC} in sdm450*)  #sd450 series by @cjybyjk
    support=2
	cores=8
	bcores=4
	MSG=1
    esac
	case ${SOC} in mt6755*)  #P10 
    support=2
	MSG=1
    esac
	
	case ${available_governors} in
 	*util*) EAS=1;;
 	*sched*) EAS=1;;
 	*elect*) EAS=1;;
    esac
	
	if [ -d "/sys/devices/system/cpu/cpu0/cpufreq/schedutil" ] || [ -d "/sys/devices/system/cpu/cpu0/cpufreq/sched" ]; then
	EAS=1
	fi
	if [ -d "/sys/devices/system/cpu/cpufreq/schedutil" ] || [ -d "/sys/devices/system/cpu/cpufreq/sched" ]; then
	EAS=1
	fi
	
	if [ ${EAS} -eq 1 ];then
	support=1
	else
case ${MSG} in
		"1")
    if [ ${PROFILE} -ne 1 ]; then
	PROFILE=1
	else
	MSG=0
	fi
		;;
		"2")
    if [ ${PROFILE} -eq 0 ] || [ ${PROFILE} -eq 3 ]; then
	PROFILE=1
	else
	MSG=0
	fi
		;;
esac
	fi
	
	if [ ${PROFILE} -eq 0 ];then
	PROFILE_B="Power save"
	PROFILE_P="powersave"
	elif [ ${PROFILE} -eq 1 ];then
	PROFILE_B="Balance"
	PROFILE_P="balance"
	fi

	if [ ${PROFILE} -eq 0 ];then
	PROFILE_M="Power save "
	elif [ ${PROFILE} -eq 1 ];then
	PROFILE_M="Balance"
	fi
    maxfreq=$(awk -v x=$maxfreq_b 'BEGIN{print x/1000000}')
    maxfreq=$(round ${maxfreq} 2)
    GPU_MAX_MHz=$(awk -v x=$GPU_MAX 'BEGIN{print x/1000000}')
    GPU_MAX_MHz=$(round ${GPU_MAX_MHz} 0)
	LOGDATA "|						INFO:						  "
	LOGDATA "|		Universal Kernel Tweaks by enweazudaniel @XDA " 
    LOGDATA "|		START : $(date +"%d-%m-%Y %r")				  " 
    LOGDATA "|________________________________________________" 
	LOGDATA "| 					SYSTEM INFO:                   "
    LOGDATA "|		VENDOR : $VENDOR" 
    LOGDATA "|		DEVICE : $APP" 
if [ ${GPU_MAX} -ne 0 ] || [ ! -z ${GPU_MODEL} ] ;then
    LOGDATA "|		GPU : $GPU_MODEL @ $GPU_MAX_MHz MHz       "
fi
if [ ${maxfreq} -ne 0 ] || [ ! -z ${maxfreq} ] ;then
    LOGDATA "|		CPU : $SOC @ $maxfreq GHz ($cores x cores)"
	else
    LOGDATA "|		CPU : $SOC"
fi
    LOGDATA "|		RAM : $memg GB  "
    LOGDATA "|________________________________________________"  
	LOGDATA "|				OTHER INFO:						   "
	LOGDATA "|		ANDROID : $OS" 
    LOGDATA "|		KERNEL : $KERNEL" 
    LOGDATA "|		BUSYBOX  : $sbusybox" 
    LOGDATA "|________________________________________________" 
    if [ -z ${sbusybox} ]; then
	LOGDATA "|		BUSYBOX NOT FOUND"
	fi
case ${MSG} in
		"1")
	LOGDATA "|		${PROFILE_B} PROFILE ISN'T AVAILABLE FOR YOUR DEVICE"
	LOGDATA "|		Universal_Kernel_Tweaks IS SWITCHED TO BALANCE PROFILE"
		;;
		"2")
	LOGDATA "|		ONLY BALANCED & POWER SAVE PROFILES ARE AVAILABLE FOR YOUR DEVICE"
	LOGDATA "|		Universal_Kernel_Tweaks IS SWITCHED TO BALANCE PROFILE"
		;;
esac
    if [ "$SOC" != "${SOC/sm/}" ] || [ "$SOC" != "${SOC/sda/}" ] || [ "$SOC" != "${SOC/sdm/}" ] || [ "$SOC" != "${SOC/apq/}" ];     then
    snapdragon=1
    else
    snapdragon=0
    fi

cputuning() {
    mutate 0 /sys/kernel/intelli_plug/intelli_plug_active
    mutate 0 /sys/module/blu_plug/parameters/enabled
    mutate 0 /sys/devices/virtual/misc/mako_hotplug_control/enabled
    mutate 0 /sys/module/autosmp/parameters/enabled
    mutate 0 /sys/kernel/zen_decision/enabled
	
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n disable > $mode
    done
    for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
    do
        bcl_hotplug_mask=`cat $hotplug_mask`
        write $hotplug_mask 0
    done
    for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
    do
        bcl_soc_hotplug_mask=`cat $hotplug_soc_mask`
        write $hotplug_soc_mask 0
    done
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n enable > $mode
    done

	if [ -e /data/system/perfd/default_values ]; then
	rm /data/system/perfd/default_values
	fi
	sleep "0.001"
	# Bring all cores online
	num=0
	while [ $num -le $coresmax ]
	do
	write "/sys/devices/system/cpu/cpu${num}/online" 1
	num=$(( $num + 1 ))
	done
	write "/sys/devices/system/cpu/online" "0-$coresmax"
	string1="${GOV_PATH_L}/scaling_available_governors";
	string2="${GOV_PATH_B}/scaling_available_governors";
	if [ ${PROFILE} -eq 0 ];then
	if [ -e "/sys/module/lazyplug" ]; then
	write "/sys/module/lazyplug/parameters/cpu_nr_run_theshold" '1250'
	write "/sys/module/lazyplug/parameters/cpu_nr_hysteresis" '5'
	write "/sys/module/lazyplug/parameters/nr_run_profile_sel" '0'
	fi
	fi
	# Enable power efficient work_queue mode
	if [ -e /sys/module/workqueue/parameters/power_efficient ]; then
	lock_val "Y" "/sys/module/workqueue/parameters/power_efficient"
	LOGDATA "|		TWEAKING YOUR DEVICE           " 
	fi

if [ ${EAS} -eq 1 ];then
	EAS=1
	LOGDATA "|		EAS KERNEL DETECTED"

# i=0
# while [ $i -lt $cores ]
# do
# dir="/sys/devices/system/cpu/cpu$i/cpufreq"
# lock_val ${EASGOV} ${dir}/scaling_governor
# i=$(( $i + 1 ))
# done
	
EASGOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
govn=${EASGOV}
stop_qti_perfd
	
# before_modify_eas ${govn}
  LOGDATA "|"
		
# treat crtc_commit as background, avoid display preemption on big
change_task_cgroup "crtc_commit" "background" "cpuset"

# fix laggy bilibili feed scrolling
change_task_cgroup "servicemanager" "top-app" "cpuset"
change_task_cgroup "servicemanager" "foreground" "stune"
change_task_cgroup "android.phone" "top-app" "cpuset"
change_task_cgroup "android.phone" "foreground" "stune"

# fix laggy home gesture
change_task_cgroup "system_server" "top-app" "cpuset"
change_task_cgroup "system_server" "foreground" "stune"

# reduce render thread waiting time
change_task_cgroup "surfaceflinger" "top-app" "cpuset"
change_task_cgroup "surfaceflinger" "foreground" "stune"

# reduce big cluster wakeup, eg. android.hardware.sensors@1.0-service
change_task_affinity ".hardware." "0f"

# prefer to use prev cpu, decrease jitter from 0.5ms to 0.3ms with lpm settings
lock_val "15000000" $SCHED/sched_migration_cost_ns

# OnePlus opchain pins UX threads on the big cluster
lock_val "0" /sys/module/opchain/parameters/chain_on

# unify schedtune misc
	LOGDATA "|		ADJUSTING SCHEDTUNE PARAMETERS" 

# android 10 doesn't have schedtune.sched_boost_enabled exposed, default = true
lock_val "0" $ST_BACK/schedtune.sched_boost_enabled
lock_val "0" $ST_BACK/schedtune.sched_boost_no_override
lock_val "0" $ST_BACK/schedtune.boost
lock_val "0" $ST_BACK/schedtune.prefer_idle
lock_val "0" $ST_FORE/schedtune.sched_boost_enabled
lock_val "0" $ST_FORE/schedtune.sched_boost_no_override
lock_val "0" $ST_FORE/schedtune.boost
lock_val "1" $ST_FORE/schedtune.prefer_idle
lock_val "0" $ST_TOP/schedtune.sched_boost_no_override


	dynstune=$(cat /data/adb/dynamic_stune_boost.txt | tr -d '\n')	
	if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]];then
	LOGDATA "|		ADJUSTING DYNAMIC STUNE" 

	if [ ${PROFILE} -eq 0 ];then
	dynstune=$(awk -v x=$dynstune 'BEGIN{print x/1.8}')
	dynstune=$(round ${dynstune} 0)
	write /sys/module/cpu_boost/parameters/dynamic_stune_boost ${dynstune}
	elif [ ${PROFILE} -eq 1 ]; then
	dynstune=$(awk -v x=$dynstune 'BEGIN{print x*0.8}')
	dynstune=$(round ${dynstune} 0)
	write /sys/module/cpu_boost/parameters/dynamic_stune_boost ${dynstune}
	fi
	else
	if [ ${PROFILE} -eq 0 ];then
	#mutate "0" /dev/stune/top-app/schedtune.prefer_idle
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "0" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/foreground/schedtune.boost
	elif [ ${PROFILE} -eq 1 ]; then
	#mutate "0" /dev/stune/top-app/schedtune.prefer_idle
    mutate "0" /dev/stune/top-app/schedtune.sched_boost_enabled
    mutate "10" /dev/stune/top-app/schedtune.boost
    mutate "0" /dev/stune/foreground/schedtune.boost
	fi
	fi

	sleep 2
	
	
	case ${SOC} in 	sdm845* )
    set_governor_param "scaling_governor" "0:schedutil 4:schedutil"
    set_governor_param "schedutil/hispeed_load" "0:90 4:90"
    set_governor_param "schedutil/hispeed_freq" "0:1132800 4:1612800"
    set_cpufreq_max "0:9999000 4:9999000"
    set_cpufreq_dyn_max "0:9999000 4:9999000"
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_CPU_LLC/governor
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_LLC_DDR/governor
    mutate "0" $DEVFREQ/$BWMON_CPU_LLC/min_freq
    mutate "0" $DEVFREQ/$BWMON_LLC_DDR/min_freq
    lock_val "8000" $DEVFREQ/$BIG_L3_LAT/mem_latency/ratio_ceil
    lock_val "800" $DEVFREQ/$BIG_DDR_LAT/mem_latency/ratio_ceil
    mutate "0" $LPM/lpm_prediction
    mutate "0" $LPM/sleep_disabled
    mutate "$STUNE_FG_CPUS" /dev/cpuset/foreground/cpus
    lock_val "$STUNE_BG_CPUS" /dev/cpuset/restricted/cpus
    lock_val "$STUNE_BG_CPUS" /dev/cpuset/display/cpus
    set_corectl_param "enable" "0:1 4:1"
    set_corectl_param "busy_down_thres" "0:20 4:20"
    set_corectl_param "busy_up_thres" "0:40 4:40"
    set_corectl_param "offline_delay_ms" "0:100 4:100"
	if [ ${PROFILE} -eq 0 ]; then
    set_cpufreq_min "0:300000 4:300000"
    set_cpufreq_max "0:1766400 4:1996800"
    set_sched_migrate "95" "95" "140" "100"
    set_corectl_param "min_cpus" "0:4 4:1"
    set_governor_param "schedutil/pl" "0:0 4:0"
    lock_val "0:1132800 4:1286400" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "9500" $DEVFREQ/$BWMON_CPU_LLC/max_freq
    mutate "6000" $DEVFREQ/$BWMON_LLC_DDR/max_freq
    mutate "25" $LPM/bias_hyst
	elif [ ${PROFILE} -eq 1 ]; then
	    set_cpufreq_min "0:576000 4:825600"
    set_cpufreq_max "0:1766400 4:2476800"
    set_sched_migrate "95" "95" "140" "100"
    set_corectl_param "min_cpus" "0:4 4:2"
    set_governor_param "schedutil/pl" "0:0 4:0"
    lock_val "0:1132800 4:1286400" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "9500" $DEVFREQ/$BWMON_CPU_LLC/max_freq
    mutate "6000" $DEVFREQ/$BWMON_LLC_DDR/max_freq
    mutate "25" $LPM/bias_hyst
	fi
		update_qti_perfd ${PROFILE_P}

	;;
	sm8150* | msmnile* ) #sd855
	
    lock_val "15" $SCHED/sched_min_task_util_for_boost
    lock_val "1000" $SCHED/sched_min_task_util_for_colocation
    lock_val "700000" $SCHED/sched_little_cluster_coloc_fmin_khz
    set_governor_param "scaling_governor" "0:schedutil 4:schedutil 7:schedutil"
    set_governor_param "schedutil/hispeed_load" "0:90 4:90 7:80"
    set_governor_param "schedutil/hispeed_freq" "0:1113600 4:1286400 7:1612800"
    set_cpufreq_max "0:9999000 4:9999000 7:9999000"
    set_cpufreq_dyn_max "0:9999000 4:9999000 7:9999000"
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_CPU_LLC/governor
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_LLC_DDR/governor
    mutate "0" $DEVFREQ/$BWMON_CPU_LLC/min_freq
    mutate "0" $DEVFREQ/$BWMON_LLC_DDR/min_freq
    lock_val "8000" $DEVFREQ/$BIG_L3_LAT/mem_latency/ratio_ceil
    lock_val "800" $DEVFREQ/$BIG_DDR_LAT/mem_latency/ratio_ceil
    mutate "0" $LPM/lpm_prediction
    mutate "0" $LPM/sleep_disabled

    mutate "$STUNE_FG_CPUS" /dev/cpuset/foreground/cpus
    lock_val "$STUNE_BG_CPUS" /dev/cpuset/restricted/cpus
    lock_val "$STUNE_BG_CPUS" /dev/cpuset/display/cpus
    set_corectl_param "enable" "0:1 4:1 7:1"
    set_corectl_param "busy_down_thres" "0:20 4:20 7:20"
    set_corectl_param "busy_up_thres" "0:40 4:40 7:40"
    set_corectl_param "offline_delay_ms" "0:100 4:100 7:100"
	
	if [ ${PROFILE} -eq 0 ];then
    set_cpufreq_min "0:300000 4:710400 7:825600"
    set_cpufreq_max "0:1785600 4:1612800 7:2419200"
    set_sched_migrate "95 85" "95 60" "140" "100"
    set_corectl_param "min_cpus" "0:4 4:1 7:0"
    set_governor_param "schedutil/pl" "0:0 4:0 7:0"
    lock_val "0:1113600 4:1056000 7:0" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "15000" $DEVFREQ/$BWMON_CPU_LLC/max_freq
    mutate "6000" $DEVFREQ/$BWMON_LLC_DDR/max_freq
    mutate "25" $LPM/bias_hyst
	elif [ ${PROFILE} -eq 1 ]; then
    set_cpufreq_min "0:576000 4:710400 7:825600"
    set_cpufreq_max "0:1785600 4:2016000 7:2649600"
    set_sched_migrate "95 85" "95 60" "140" "100"
    set_corectl_param "min_cpus" "0:4 4:2 7:0"
    set_governor_param "schedutil/pl" "0:0 4:0 7:0"
    lock_val "0:1113600 4:1056000 7:0" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "15000" $DEVFREQ/$BWMON_CPU_LLC/max_freq
    mutate "6000" $DEVFREQ/$BWMON_LLC_DDR/max_freq
    mutate "25" $LPM/bias_hyst
	fi
	update_qti_perfd ${PROFILE_P}
	;;

	sm6150* ) #sd675/730
[ -f /sys/devices/soc0/soc_id ] && SOC_ID="$(cat /sys/devices/soc0/soc_id)"
[ -f /sys/devices/system/soc/soc0/id ] && SOC_ID="$(cat /sys/devices/system/soc/soc0/id)"

case "$SOC_ID" in
    365|366) PLATFORM_NAME="sdm730" ;;
    355|369) PLATFORM_NAME="sdm675" ;;
esac

    set_governor_param "scaling_governor" "0:schedutil 6:schedutil"
    set_governor_param "schedutil/hispeed_load" "0:90 6:90"
    set_governor_param "schedutil/hispeed_freq" "0:1000000 6:1200000"
    set_cpufreq_max "0:9999000 6:9999000"
    set_cpufreq_dyn_max "0:9999000 6:9999000"
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_CPU_LLC/governor
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_LLC_DDR/governor
    mutate "0" $DEVFREQ/$BWMON_CPU_LLC/min_freq
    mutate "0" $DEVFREQ/$BWMON_LLC_DDR/min_freq
    lock_val "8000" $DEVFREQ/$BIG_L3_LAT/mem_latency/ratio_ceil
    lock_val "800" $DEVFREQ/$BIG_DDR_LAT/mem_latency/ratio_ceil
    mutate "0" $LPM/lpm_prediction
    mutate "0" $LPM/sleep_disabled
	
    mutate "$STUNE_FG_CPUS" /dev/cpuset/foreground/cpus
    lock_val "$STUNE_BG_CPUS" /dev/cpuset/restricted/cpus
    lock_val "$STUNE_BG_CPUS" /dev/cpuset/display/cpus
    set_corectl_param "enable" "0:1 6:1"
    set_corectl_param "busy_down_thres" "0:20 6:20"
    set_corectl_param "busy_up_thres" "0:40 6:40"
    set_corectl_param "offline_delay_ms" "0:100 6:100"
	
	if [ ${PROFILE} -eq 0 ]; then
     set_cpufreq_min "0:300000 6:300000"
    case "$PLATFORM_NAME" in
        sdm730) set_cpufreq_max "0:1708800 6:1555200" ;;
        sdm675) set_cpufreq_max "0:1708800 6:1516800" ;;
    esac
    set_sched_migrate "95" "95" "140" "100"
    set_corectl_param "min_cpus" "0:4 6:1"
    set_governor_param "schedutil/pl" "0:0 6:0"
    lock_val "0:1000000 6:1000000" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "13000" $DEVFREQ/$BWMON_CPU_LLC/max_freq
    mutate "6000" $DEVFREQ/$BWMON_LLC_DDR/max_freq
    mutate "25" $LPM/bias_hyst
	elif [ ${PROFILE} -eq 1 ]; then
    set_cpufreq_min "0:576000 6:652800"
    case "$SOC_ID" in
        sdm730) set_cpufreq_max "0:1708800 6:1939200" ;;
        sdm675) set_cpufreq_max "0:1708800 6:1708800" ;;
    esac
    set_sched_migrate "95" "95" "140" "100"
    set_corectl_param "min_cpus" "0:4 6:2"
    set_governor_param "schedutil/pl" "0:0 6:0"
    lock_val "0:1000000 6:1000000" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "13000" $DEVFREQ/$BWMON_CPU_LLC/max_freq
    mutate "6000" $DEVFREQ/$BWMON_LLC_DDR/max_freq
    mutate "25" $LPM/bias_hyst
	fi
	update_qti_perfd ${PROFILE_P}
;;
	sdm710* ) #sd710
	
    set_governor_param "scaling_governor" "0:schedutil 6:schedutil"
    set_governor_param "schedutil/hispeed_load" "0:90 6:90"
    set_governor_param "schedutil/hispeed_freq" "0:998400 6:1536000"
    set_cpufreq_max "0:9999000 6:9999000"
    set_cpufreq_dyn_max "0:9999000 6:9999000"
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_CPU_LLC/governor
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_LLC_DDR/governor
    mutate "0" $DEVFREQ/$BWMON_CPU_LLC/min_freq
    mutate "0" $DEVFREQ/$BWMON_LLC_DDR/min_freq
    lock_val "8000" $DEVFREQ/$BIG_L3_LAT/mem_latency/ratio_ceil
    lock_val "800" $DEVFREQ/$BIG_DDR_LAT/mem_latency/ratio_ceil
    mutate "0" $LPM/lpm_prediction
    mutate "0" $LPM/sleep_disabled
	
    mutate "$STUNE_FG_CPUS" /dev/cpuset/foreground/cpus
    lock_val "$STUNE_BG_CPUS" /dev/cpuset/restricted/cpus
    lock_val "$STUNE_BG_CPUS" /dev/cpuset/display/cpus
    set_corectl_param "enable" "0:1 6:1"
    set_corectl_param "busy_down_thres" "0:20 6:20"
    set_corectl_param "busy_up_thres" "0:40 6:40"
    set_corectl_param "offline_delay_ms" "0:100 6:100"
	if [ ${PROFILE} -eq 0 ];then
    set_cpufreq_min "0:300000 6:300000"
    set_cpufreq_max "0:1708800 6:1843200"
    set_sched_migrate "95" "95" "140" "100"
    set_corectl_param "min_cpus" "0:4 6:1"
    set_governor_param "schedutil/pl" "0:0 6:0"
    lock_val "0:998400 6:1132800" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "6000" $DEVFREQ/$BWMON_CPU_LLC/max_freq
    mutate "6000" $DEVFREQ/$BWMON_LLC_DDR/max_freq
    mutate "25" $LPM/bias_hyst
	elif [ ${PROFILE} -eq 1 ]; then
    set_cpufreq_min "0:576000 6:652800"
    set_cpufreq_max "0:1708800 6:2016000"
    set_sched_migrate "95" "95" "140" "100"
    set_corectl_param "min_cpus" "0:4 6:2"
    set_governor_param "schedutil/pl" "0:0 6:0"
    lock_val "0:998400 6:1132800" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "6000" $DEVFREQ/$BWMON_CPU_LLC/max_freq
    mutate "6000" $DEVFREQ/$BWMON_LLC_DDR/max_freq
    mutate "25" $LPM/bias_hyst
	fi
	update_qti_perfd ${PROFILE_P}

	;;
	msm8998* )
    set_governor_param "scaling_governor" "0:schedutil 4:schedutil"
    set_governor_param "schedutil/hispeed_load" "0:90 4:90"
    set_governor_param "schedutil/hispeed_freq" "0:1132800 4:1497600"
    set_cpufreq_max "0:9999000 4:9999000"
    set_cpufreq_dyn_max "0:9999000 4:9999000"
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_CPU_LLC/governor
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_LLC_DDR/governor
    mutate "0" $DEVFREQ/$BWMON_CPU_LLC/min_freq
    mutate "0" $DEVFREQ/$BWMON_LLC_DDR/min_freq
    lock_val "8000" $DEVFREQ/$BIG_L3_LAT/mem_latency/ratio_ceil
    lock_val "800" $DEVFREQ/$BIG_DDR_LAT/mem_latency/ratio_ceil
    mutate "0" $LPM/lpm_prediction
    mutate "0" $LPM/sleep_disabled
    mutate "$STUNE_FG_CPUS" /dev/cpuset/foreground/cpus
    lock_val "$STUNE_BG_CPUS" /dev/cpuset/restricted/cpus
    lock_val "$STUNE_BG_CPUS" /dev/cpuset/display/cpus
    set_corectl_param "enable" "0:1 4:1"
    set_corectl_param "busy_down_thres" "0:20 4:20"
    set_corectl_param "busy_up_thres" "0:40 4:40"
    set_corectl_param "offline_delay_ms" "0:100 4:100"
	if [ ${PROFILE} -eq 0 ]; then
    set_cpufreq_min "0:300000 4:300000"
    set_cpufreq_max "0:1747200 4:1728000"
    set_sched_migrate "95" "95" "140" "100"
    set_corectl_param "min_cpus" "0:4 4:1"
    set_governor_param "schedutil/pl" "0:0 4:0"
    lock_val "0:1132800 4:1132800" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "9500" $DEVFREQ/$BWMON_CPU_LLC/max_freq
    mutate "6000" $DEVFREQ/$BWMON_LLC_DDR/max_freq
    mutate "25" $LPM/bias_hyst
	elif [ ${PROFILE} -eq 1 ]; then
	    set_cpufreq_min "0:300000 4:300000"
    set_cpufreq_max "0:1900800 4:2112000"
    set_sched_migrate "95" "95" "140" "100"
    set_corectl_param "min_cpus" "0:4 4:2"
    set_governor_param "schedutil/pl" "0:0 4:0"
    lock_val "0:1132800 4:1132800" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "9500" $DEVFREQ/$BWMON_CPU_LLC/max_freq
    mutate "6000" $DEVFREQ/$BWMON_LLC_DDR/max_freq
    mutate "25" $LPM/bias_hyst
	fi
		update_qti_perfd ${PROFILE_P}

	;;
	msm8996* | apq8096* )
    set_governor_param "scaling_governor" "0:schedutil 2:schedutil"
    set_governor_param "schedutil/hispeed_load" "0:90 2:90"
    set_governor_param "schedutil/hispeed_freq" "0:1036800 2:1324800"
    set_cpufreq_max "0:9999000 2:9999000"
    set_cpufreq_dyn_max "0:9999000 2:9999000"
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_CPU_LLC/governor
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_LLC_DDR/governor
    mutate "0" $DEVFREQ/$BWMON_CPU_LLC/min_freq
    mutate "0" $DEVFREQ/$BWMON_LLC_DDR/min_freq
    lock_val "8000" $DEVFREQ/$BIG_L3_LAT/mem_latency/ratio_ceil
    lock_val "800" $DEVFREQ/$BIG_DDR_LAT/mem_latency/ratio_ceil
    mutate "0" $LPM/lpm_prediction
    mutate "0" $LPM/sleep_disabled
    mutate "$STUNE_FG_CPUS" /dev/cpuset/foreground/cpus
    lock_val "$STUNE_BG_CPUS" /dev/cpuset/restricted/cpus
    lock_val "$STUNE_BG_CPUS" /dev/cpuset/display/cpus
    set_corectl_param "enable" "0:1 2:1"
    set_corectl_param "busy_down_thres" "0:20 2:20"
    set_corectl_param "busy_up_thres" "0:40 2:40"
    set_corectl_param "offline_delay_ms" "0:100 2:100"
	if [ ${PROFILE} -eq 0 ]; then
    set_cpufreq_min "0:307200 2:307200"
    set_cpufreq_max "0:1593600 2:1555200"
    set_sched_migrate "95" "95" "140" "100"
    set_corectl_param "min_cpus" "0:2 2:1"
    set_governor_param "schedutil/pl" "0:0 2:0"
    lock_val "0:1036800 2:1036800" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "9500" $DEVFREQ/$BWMON_CPU_LLC/max_freq
    mutate "6000" $DEVFREQ/$BWMON_LLC_DDR/max_freq
    mutate "25" $LPM/bias_hyst
	elif [ ${PROFILE} -eq 1 ]; then
    set_cpufreq_min "0:307200 2:307200"
    set_cpufreq_max "0:1593600 2:1824000"
    set_sched_migrate "95" "95" "140" "100"
    set_corectl_param "min_cpus" "0:2 2:1"
    set_governor_param "schedutil/pl" "0:0 2:0"
    lock_val "0:1036800 2:1113600" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "9500" $DEVFREQ/$BWMON_CPU_LLC/max_freq
    mutate "6000" $DEVFREQ/$BWMON_LLC_DDR/max_freq
    mutate "25" $LPM/bias_hyst
	fi
		update_qti_perfd ${PROFILE_P}

	;;
	*)
	bc=$(( ${bcores} - 1 ))
	hf=$(( ${bcores} % 2 ))
	FREQ_FILE="/data/adb/boost1.txt"
	IBOOST_FREQ_L=$(awk -F ' 1' '{ print($1) }' $FREQ_FILE)
	IBOOST_FREQ_L=$(echo $IBOOST_FREQ_L |awk -F '0:' '{ print($2) }')
	IBOOST_FREQ_B=$(awk -F ' 5' '{ print($1) }' $FREQ_FILE)
	IBOOST_FREQ_B=$(echo $IBOOST_FREQ_B |awk -F '4:' '{ print($2) }')
	IBOOST_FREQ_P=$(awk -F ' 7' '{ print($1) }' $FREQ_FILE)
	IBOOST_FREQ_P=$(echo $IBOOST_FREQ_P |awk -F '6:' '{ print($2) }')
	if [ ${IBOOST_FREQ_B} -eq 0 ]; then
	IBOOST_FREQ_B=${IBOOST_FREQ_L}
	fi
BWMON_CPU_LLC="soc:qcom,cpu-cpu-llcc-bw"
BWMON_LLC_DDR="soc:qcom,cpu-llcc-ddr-bw"
BIG_L3_LAT="soc:qcom,cpu4-cpu-l3-lat"
BIG_DDR_LAT="soc:qcom,cpu4-llcc-ddr-lat"
BWMON_CPU_LLC1="soc:qcom,cpubw"
BWMON_LLC_DDR1="soc:qcom,llccbw"
BIG_L3_LAT1="soc:qcom,l3-cpu4"
BIG_DDR_LAT1="soc:qcom,memlat-cpu4"


freqtest=$(cat sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq)
rel=$(cat sys/devices/system/cpu/cpu0/cpufreq/related_cpus)
if [[ $rel == *"5"* ]]; then
midrange=1
fi

if [ $maxfreq_b -gt $freqtest ]; then
primecore=1
fi
	
    lock_val "15" $SCHED/sched_min_task_util_for_boost
    lock_val "1000" $SCHED/sched_min_task_util_for_colocation
    lock_val "700000" $SCHED/sched_little_cluster_coloc_fmin_khz
    set_governor_param "scaling_governor" "0:schedutil 4:schedutil 7:schedutil"
    set_governor_param "schedutil/hispeed_load" "0:90 4:90 7:80"
    set_governor_param "schedutil/hispeed_freq" "0:1180000 4:1280000 7:1580000"
    set_cpufreq_max "0:9999000 4:9999000 7:9999000"
    set_cpufreq_dyn_max "0:9999000 4:9999000 7:9999000"
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_CPU_LLC/governor
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_LLC_DDR/governor
    mutate "0" $DEVFREQ/$BWMON_CPU_LLC/min_freq
    mutate "0" $DEVFREQ/$BWMON_LLC_DDR/min_freq
	
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_CPU_LLC1/governor
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_LLC_DDR1/governor
    mutate "0" $DEVFREQ/$BWMON_CPU_LLC1/min_freq
    mutate "0" $DEVFREQ/$BWMON_LLC_DDR1/min_freq
	
    lock_val "8000" $DEVFREQ/$BIG_L3_LAT/mem_latency/ratio_ceil
    lock_val "800" $DEVFREQ/$BIG_DDR_LAT/mem_latency/ratio_ceil
    lock_val "8000" $DEVFREQ/$BIG_L3_LAT1/mem_latency/ratio_ceil
    lock_val "800" $DEVFREQ/$BIG_DDR_LAT1/mem_latency/ratio_ceil
    mutate "0" $LPM/lpm_prediction
    mutate "0" $LPM/sleep_disabled

    set_corectl_param "enable" "0:1 4:1 7:1"
    set_corectl_param "busy_down_thres" "0:20 4:20 7:20"
    set_corectl_param "busy_up_thres" "0:40 4:40 7:40"
    set_corectl_param "offline_delay_ms" "0:100 4:100 7:100"
	
	if [ $primecore -eq 1 ] ;then
    mutate "0-6" /dev/cpuset/foreground/cpus
    lock_val "0-3" /dev/cpuset/restricted/cpus
    lock_val "0-3" /dev/cpuset/display/cpus
	if [ ${PROFILE} -eq 0 ];then
	maxfreq_b=$(awk -v x=$maxfreq_b 'BEGIN{print x*0.6652892561983471}')
    maxfreq_b=$(round ${maxfreq_b} 0)
	maxfreq_p=$(awk -v x=$maxfreq_p 'BEGIN{print x*0.8485915492957746}')
    maxfreq_p=$(round ${maxfreq_p} 0)	
    set_cpufreq_min "0:300000 4:300000 7:300000"
    set_cpufreq_max "0:$maxfreq_l 4:$maxfreq_b 7:$maxfreq_p"
    set_sched_migrate "95 85" "95 60" "140" "100"
    set_corectl_param "min_cpus" "0:4 4:1 7:0"
    set_governor_param "schedutil/pl" "0:0 4:0 7:0"
    lock_val "0:1180000 4:1080000 7:0" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "25" $LPM/bias_hyst
	elif [ ${PROFILE} -eq 1 ]; then
	maxfreq_b=$(awk -v x=$maxfreq_b 'BEGIN{print x*0.8298755186721992}')
    maxfreq_b=$(round ${maxfreq_b} 0)
	maxfreq_p=$(awk -v x=$maxfreq_p 'BEGIN{print x*0.9295774647887324}')
    maxfreq_p=$(round ${maxfreq_p} 0)	
    set_cpufreq_min "0:300000 4:300000 7:300000"
    set_cpufreq_max "0:$maxfreq_l 4:$maxfreq_b 7:$maxfreq_p"
    set_sched_migrate "95 85" "95 60" "140" "100"
    set_corectl_param "min_cpus" "0:4 4:2 7:0"
    set_governor_param "schedutil/pl" "0:0 4:0 7:0"
    lock_val "0:1180000 4:1080000 7:0" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "25" $LPM/bias_hyst
	fi
    elif [ $midrange -eq 1 ] ;then
    mutate "0-7" /dev/cpuset/foreground/cpus
    lock_val "0-5" /dev/cpuset/restricted/cpus
    lock_val "0-5" /dev/cpuset/display/cpus
	if [ ${PROFILE} -eq 0 ];then
	maxfreq_b=$(awk -v x=$maxfreq_b 'BEGIN{print x*0.7523809523809524}')
    maxfreq_b=$(round ${maxfreq_b} 0)
	maxfreq_l=$(awk -v x=$maxfreq_l 'BEGIN{print x*0.9468085106382979}')
    maxfreq_l=$(round ${maxfreq_l} 0)	
    set_cpufreq_min "0:300000 6:300000"
    set_cpufreq_max "0:$maxfreq_l 6:$maxfreq_b"
    set_sched_migrate "95" "95" "140" "100"
    set_corectl_param "min_cpus" "0:4 6:1"
    set_governor_param "schedutil/pl" "0:0 6:0"
    lock_val "0:1000000 6:1000000" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "25" $LPM/bias_hyst
	elif [ ${PROFILE} -eq 1 ]; then
	maxfreq_b=$(awk -v x=$maxfreq_b 'BEGIN{print x*0.8591304347826087}')
    maxfreq_b=$(round ${maxfreq_b} 0)
	maxfreq_l=$(awk -v x=$maxfreq_l 'BEGIN{print x*0.9468085106382979}')
    maxfreq_l=$(round ${maxfreq_l} 0)	
    set_cpufreq_min "0:300000 6:300000"
    set_cpufreq_max "0:$maxfreq_l 6:$maxfreq_b"
    set_sched_migrate "95" "95" "140" "100"
    set_corectl_param "min_cpus" "0:4 6:2"
    set_governor_param "schedutil/pl" "0:0 6:0"
    lock_val "0:1000000 6:1000000" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "25" $LPM/bias_hyst
	fi
    else
    mutate "0-7" /dev/cpuset/foreground/cpus
    lock_val "0-4" /dev/cpuset/restricted/cpus
    lock_val "0-4" /dev/cpuset/display/cpus
 	highspeed_b=$(awk -v x=$highspeed_b 'BEGIN{print x*0.5590277777777778}')
    highspeed_b=$(round ${highspeed_b} 0)

	set_governor_param "scaling_governor" "0:schedutil 4:schedutil"
    set_governor_param "schedutil/hispeed_load" "0:90 4:90"
    set_governor_param "schedutil/hispeed_freq" "0:1180000 4:$highspeed_b"
    set_cpufreq_max "0:9999000 4:9999000"
    set_cpufreq_dyn_max "0:9999000 4:9999000"
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_CPU_LLC/governor
    lock_val "bw_hwmon" $DEVFREQ/$BWMON_LLC_DDR/governor
    mutate "0" $DEVFREQ/$BWMON_CPU_LLC/min_freq
    mutate "0" $DEVFREQ/$BWMON_LLC_DDR/min_freq
    lock_val "8000" $DEVFREQ/$BIG_L3_LAT/mem_latency/ratio_ceil
    lock_val "800" $DEVFREQ/$BIG_DDR_LAT/mem_latency/ratio_ceil
    mutate "0" $LPM/lpm_prediction
    mutate "0" $LPM/sleep_disabled
    mutate "$STUNE_FG_CPUS" /dev/cpuset/foreground/cpus
    lock_val "$STUNE_BG_CPUS" /dev/cpuset/restricted/cpus
    lock_val "$STUNE_BG_CPUS" /dev/cpuset/display/cpus
    set_corectl_param "enable" "0:1 4:1"
    set_corectl_param "busy_down_thres" "0:20 4:20"
    set_corectl_param "busy_up_thres" "0:40 4:40"
    set_corectl_param "offline_delay_ms" "0:100 4:100"
	if [ ${PROFILE} -eq 0 ]; then
 	maxfreq_b=$(awk -v x=$maxfreq_b 'BEGIN{print x*0.6930555555555556}')
    maxfreq_b=$(round ${maxfreq_b} 0)
    set_cpufreq_min "0:300000 4:300000"
    set_cpufreq_max "0:9999000 4:$maxfreq_b"
    set_sched_migrate "95" "95" "140" "100"
    set_corectl_param "min_cpus" "0:4 4:1"
    set_governor_param "schedutil/pl" "0:0 4:0"
    lock_val "0:1180000 4:1280000" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "9500" $DEVFREQ/$BWMON_CPU_LLC/max_freq
    mutate "6000" $DEVFREQ/$BWMON_LLC_DDR/max_freq
    mutate "25" $LPM/bias_hyst
	elif [ ${PROFILE} -eq 1 ]; then
 	maxfreq_b=$(awk -v x=$maxfreq_b 'BEGIN{print x*0.8402777777777778}')
    maxfreq_b=$(round ${maxfreq_b} 0)
    set_cpufreq_min "0:300000 4:300000"
    set_cpufreq_max "0:9999000 4:$maxfreq_b"
    set_sched_migrate "95" "95" "140" "100"
    set_corectl_param "min_cpus" "0:4 4:2"
    set_governor_param "schedutil/pl" "0:0 4:0"
    lock_val "0:1180000 4:1280000" $CPU_BOOST/input_boost_freq
    lock_val "800" $CPU_BOOST/input_boost_ms
    lock_val "2" $CPU_BOOST/sched_boost_on_input
    mutate "1" $ST_TOP/schedtune.sched_boost_enabled
    mutate "0" $ST_TOP/schedtune.boost
    mutate "1" $ST_TOP/schedtune.prefer_idle
    mutate "9500" $DEVFREQ/$BWMON_CPU_LLC/max_freq
    mutate "6000" $DEVFREQ/$BWMON_LLC_DDR/max_freq
    mutate "25" $LPM/bias_hyst
	fi
	fi
	
	;;
	esac

	after_modify_eas ${govn}
	start_qti_perfd
fi
## INTERACTIVE
if [ ${EAS} -eq 0 ];then
    HMP=1
    i=0
	while [ $i -lt $cores ]
	do
	dir="/sys/devices/system/cpu/cpu$i/cpufreq"
	lock_val "interactive" ${dir}/scaling_governor
	i=$(( $i + 1 ))
	done
	lock_val "interactive" "/sys/devices/system/cpu/cpufreq/scaling_governor"
	LOGDATA "|		UNIVERSAL					"
	before_modify
	if [ ${MSG} -eq 0 ]; then
	update_clock_speed ${maxfreq_l} little max
	update_clock_speed ${maxfreq_b} big max
	fi
	if [ ${PROFILE} -eq 3 ];then
	restore_boost
	fi
	if [ ${PROFILE} -eq 0 ];then
	set_param cpu0 powersave_bias 1
	else
	set_param cpu0 powersave_bias 0
	fi
	set_param cpu0 enable_prediction 0	
	set_param cpu0 ignore_hispeed_on_notif 0
	set_param cpu${bcores} enable_prediction 0	
	set_param cpu${bcores} ignore_hispeed_on_notif 0
	if [ ${shared} -eq 1 ]; then
	set_boost 2500
	fi
	sleep 2
	case ${SOC} in msm8998* | apq8098*) #sd835
	update_clock_speed 280000 little min
	update_clock_speed 280000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	# lock_val 85 /proc/sys/kernel/sched_downmigrate
	# lock_val 95 /proc/sys/kernel/sched_upmigrate
	set_param cpu0 use_sched_load 1
	set_param cpu${bcores} use_sched_load 1
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0
	if [ ${PROFILE} -eq 0 ];then
	set_boost_freq "0:380000 4:380000"
	set_param cpu0 above_hispeed_delay "18000 1380000:58000 1480000:18000 1580000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 380000:59 480000:51 580000:29 780000:92 880000:76 1180000:90 1280000:98 1380000:84 1480000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1480000:58000 1580000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 380000:45 480000:36 580000:41 680000:65 780000:88 1080000:92 1280000:98 1380000:90 1580000:97"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_boost_freq "0:380000 4:380000"
	set_param cpu0 above_hispeed_delay "18000 1580000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 380000:30 480000:41 580000:29 680000:4 780000:60 1180000:88 1280000:70 1380000:78 1480000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1380000:78000 1480000:18000 1580000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 380000:39 580000:58 780000:63 980000:81 1080000:92 1180000:77 1280000:98 1380000:86 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
fi
esac
case ${SOC} in msm8996* | apq8096*) #sd820
	update_clock_speed 280000 little min
	update_clock_speed 280000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" 1
	write "/dev/cpuset/system-background/cpus" "0-1"
	write "/dev/cpuset/foreground/cpus" "0-1,2-3"
	write "/dev/cpuset/top-app/cpus" "0-1,2-3"
	lock_val 25 /proc/sys/kernel/sched_downmigrate
	lock_val 45 /proc/sys/kernel/sched_upmigrate
	set_param cpu0 use_sched_load 1
	set_param cpu${bcores} use_sched_load 1
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0
	if [ ${PROFILE} -eq 0 ];then
	set_boost_freq "0:380000 2:380000"
	set_param cpu0 above_hispeed_delay "18000 1180000:78000 1280000:98000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 380000:5 580000:42 680000:60 780000:70 880000:83 980000:92 1180000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1280000:98000 1380000:58000 1480000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 380000:53 480000:38 580000:63 780000:69 880000:85 1080000:93 1380000:72 1480000:98"
	set_param cpu${bcores} min_sample_time 18000
	set_param cpu2 min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_boost_freq "0:380000 2:380000"
	set_param cpu0 above_hispeed_delay "58000 1280000:98000 1580000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 380000:9 580000:36 780000:62 880000:71 980000:87 1080000:75 1180000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "38000 1480000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 380000:39 480000:35 680000:29 780000:63 880000:71 1180000:91 1380000:83 1480000:98"
	set_param cpu${bcores} min_sample_time 18000
fi
esac
case ${SOC} in msm8994* | msm8992*) #sd810/808
	update_clock_speed 380000 little min
	update_clock_speed 380000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-5"
	write "/dev/cpuset/top-app/cpus" "0-3,4-5"
	lock_val 85 /proc/sys/kernel/sched_downmigrate
	lock_val 99 /proc/sys/kernel/sched_upmigrate
	lock_val 0 /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	lock_val 2 /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
	update_clock_speed 1344000 little max
	update_clock_speed 1440000 big max
	set_param cpu0 use_sched_load 1
	set_param cpu${bcores} use_sched_load 1
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0
	if [ ${PROFILE} -eq 0 ];then
	set_boost_freq "0:580000 4:480000"
	set_param cpu0 above_hispeed_delay "98000 1280000:38000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 580000:27 680000:48 780000:68 880000:82 1180000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1180000:98000 1380000:18000"
	set_param cpu${bcores} hispeed_freq 880000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 580000:49 680000:40 780000:58 880000:94 1180000:98"
	set_param cpu${bcores} min_sample_time 38000
	elif [ ${PROFILE} -eq 1 ];then
	set_boost_freq "0:580000 4:480000"
	set_param cpu0 above_hispeed_delay "98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 580000:59 680000:54 780000:63 880000:85 1180000:98 1280000:94"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "18000 1180000:98000"
	set_param cpu${bcores} hispeed_freq 880000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 580000:64 680000:58 780000:19 880000:97"
	set_param cpu${bcores} min_sample_time 78000
fi
esac
case ${SOC} in apq8074* | apq8084* | msm8074* | msm8084* | msm8274* | msm8674* | msm8974*)  #sd800-801-805
	setprop ro.qualcomm.perf.cores_online 2
	update_clock_speed 280000 little min
	update_clock_speed 280000 big min
	set_boost_freq "0:380000 2:380000"
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0
	if [ ${PROFILE} -eq 0 ];then
	diff=$(awk -v x=$maxfreq_l -v y=1760000 'BEGIN{print (x/y)*85}')
    diff=$(round ${diff} 0)	
	maxfreq_l=$((${maxfreq_l}-${diff}))
	diff=$(awk -v x=$maxfreq_b -v y=2800000 'BEGIN{print (x/y)*1000}')
    diff=$(round ${diff} 0)	
	maxfreq_b=$((${maxfreq_b}-${diff}))
	update_clock_speed ${maxfreq_l} little max
	update_clock_speed ${maxfreq_b} big max
	set_param cpu0 above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 380000:6 580000:25 680000:43 880000:61 980000:86 1180000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 97
	set_param cpu${bcores} target_loads "80 380000:6 580000:25 680000:43 880000:61 980000:86 1180000:97"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	diff=$(awk -v x=$maxfreq_l -v y=1760000 'BEGIN{print (x/y)*85}')
    diff=$(round ${diff} 0)	
	maxfreq_l=$((${maxfreq_l}-${diff}))
	diff=$(awk -v x=$maxfreq_b -v y=2800000 'BEGIN{print (x/y)*520}')
    diff=$(round ${diff} 0)	
	maxfreq_b=$((${maxfreq_b}-${diff}))
	update_clock_speed ${maxfreq_l} little max
	update_clock_speed ${maxfreq_b} big max
	set_param cpu0 above_hispeed_delay "38000 1480000:78000 1680000:98000 1880000:138000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 380000:32 580000:47 680000:82 880000:32 980000:39 1180000:83 1480000:79 1680000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "38000 1480000:78000 1680000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 97
	set_param cpu${bcores} target_loads "80 380000:32 580000:47 680000:82 880000:32 980000:39 1180000:83 1480000:79 1680000:98"
	set_param cpu${bcores} min_sample_time 18000
fi
esac
case ${SOC} in sdm660* | sda660*) #sd660
	update_clock_speed 580000 little min
	update_clock_speed 1080000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	# lock_val 85 /proc/sys/kernel/sched_downmigrate
	# lock_val 95 /proc/sys/kernel/sched_upmigrate
	set_param cpu0 use_sched_load 1
	set_param cpu${bcores} use_sched_load 1
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0
	if [ ${PROFILE} -eq 0 ];then
	set_boost_freq "0:633000 4:902000"
	set_param cpu0 above_hispeed_delay "38000 902000:98000"
	set_param cpu0 hispeed_freq 902000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 633000:45 902000:64 1113000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1401000:98000 1536000:138000"
	set_param cpu${bcores} hispeed_freq 902000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 1401000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_boost_freq "0:880000 4:1380000"
	set_param cpu0 above_hispeed_delay "98000"
	set_param cpu0 hispeed_freq 1480000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 880000:59 1080000:90 1380000:78 1480000:98"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1080000
	set_param cpu${bcores} go_hispeed_load 83
	set_param cpu${bcores} target_loads "80 1380000:70 1680000:98"
	set_param cpu${bcores} min_sample_time 18000
fi
esac
case ${SOC} in msm8956* | msm8976*)  #sd652/650
	update_clock_speed 380000 little min
	update_clock_speed 380000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	# lock_val 85 /proc/sys/kernel/sched_downmigrate
	# lock_val 95 /proc/sys/kernel/sched_upmigrate
	set_param cpu0 use_sched_load 1
	set_param cpu${bcores} use_sched_load 1
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0
	if [ ${PROFILE} -eq 0 ];then
	set_boost_freq "0:680000 4:880000"
	set_param cpu0 above_hispeed_delay "98000 1380000:78000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 95
	set_param cpu0 target_loads "80 680000:58 980000:68 1280000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1280000:38000 1380000:18000 1580000:98000"
	set_param cpu${bcores} hispeed_freq 1080000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 880000:51 980000:69 1080000:90 1280000:72 1380000:94 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_boost_freq "0:680000 4:880000"
	set_param cpu0 above_hispeed_delay "98000 1380000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 680000:68 780000:60 980000:97 1180000:63 1280000:97 1380000:84"
	set_param cpu0 min_sample_time 58000
	set_param cpu${bcores} above_hispeed_delay "18000 1580000:98000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 880000:47 980000:68 1280000:74 1380000:92 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
fi
esac
case ${SOC} in sdm636* | sda636*) #sd636
	update_clock_speed 580000 little min
	update_clock_speed 1080000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	# lock_val 85 /proc/sys/kernel/sched_downmigrate
	# lock_val 95 /proc/sys/kernel/sched_upmigrate
	set_param cpu0 use_sched_load 1
	set_param cpu${bcores} use_sched_load 1
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0
	if [ ${PROFILE} -eq 0 ];then
	set_boost_freq "0:880000 4:1380000"
	set_param cpu0 above_hispeed_delay "18000 1380000:78000 1480000:98000 1580000:38000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 880000:62 1080000:98 1380000:84 1480000:97"
	set_param cpu0 min_sample_time 58000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000"
	set_param cpu${bcores} hispeed_freq 1080000
	set_param cpu${bcores} go_hispeed_load 86
	set_param cpu${bcores} target_loads "80 1380000:84 1680000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_boost_freq "0:880000 4:1380000"
	set_param cpu0 above_hispeed_delay "18000 1380000:78000 1480000:98000 1580000:78000"
	set_param cpu0 hispeed_freq 1080000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 880000:62 1080000:94 1380000:75 1480000:96"
	set_param cpu0 min_sample_time 58000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000"
	set_param cpu${bcores} hispeed_freq 1080000
	set_param cpu${bcores} go_hispeed_load 81
	set_param cpu${bcores} target_loads "80 1380000:70 1680000:98"
	set_param cpu${bcores} min_sample_time 18000
fi
esac
case ${SOC} in msm8953* | sdm630* | sda630* )  #sd625/626/630
	update_clock_speed 580000 little min
	update_clock_speed 580000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	lock_val 25 /proc/sys/kernel/sched_downmigrate
	lock_val 45 /proc/sys/kernel/sched_upmigrate
	set_param cpu0 use_sched_load 1
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0
	if [ ${PROFILE} -eq 0 ];then
	set_boost_freq "0:980000 4:0"
	set_param cpu0 above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 94
	set_param cpu0 target_loads "80 980000:66 1380000:96"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} go_hispeed_load 94
	set_param cpu${bcores} target_loads "80 980000:66 1380000:96"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_boost_freq "0:980000 4:0"
	set_param cpu0 above_hispeed_delay "98000 1880000:138000"
	set_param cpu0 hispeed_freq 1680000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:63 1380000:72 1680000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1680000
	set_param cpu${bcores} go_hispeed_load 97
	set_param cpu${bcores} target_loads "80 980000:63 1380000:72 1680000:97"
	set_param cpu${bcores} min_sample_time 18000
fi
esac
case ${SOC} in universal8895* | exynos8895*)  #EXYNOS8895 (S8)
	update_clock_speed 580000 little min
	update_clock_speed 680000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0
	if [ ${PROFILE} -eq 0 ];then
	set_param cpu0 above_hispeed_delay "38000 1380000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 82
	set_param cpu0 target_loads "80 680000:27 780000:39 880000:61 980000:68 1380000:98 1680000:94"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 780000:73 880000:79 980000:55 1080000:69 1180000:84 1380000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 above_hispeed_delay "38000 1380000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:53 880000:70 980000:50 1180000:71 1380000:97 1680000:92"
	set_param cpu0 min_sample_time 58000
	set_param cpu${bcores} above_hispeed_delay "18000 1680000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 780000:40 880000:34 980000:66 1080000:31 1180000:72 1380000:86 1680000:98"
	set_param cpu${bcores} min_sample_time 18000
fi
esac
case ${SOC} in universal8890* | exynos8890*)  #EXYNOS8890 (S7)
	update_clock_speed 380000 little min
	update_clock_speed 680000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0
	if [ ${PROFILE} -eq 0 ];then
	set_param cpu0 above_hispeed_delay "38000 1280000:18000 1480000:98000 1580000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 96
	set_param cpu0 target_loads "80 480000:51 680000:28 780000:56 880000:63 1080000:71 1180000:75 1280000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1480000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 780000:4 880000:77 980000:14 1080000:90 1180000:68 1280000:92 1480000:96"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 above_hispeed_delay "18000 1280000:38000 1480000:98000 1580000:18000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 480000:49 680000:34 780000:61 880000:33 980000:63 1080000:69 1180000:77 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1580000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} go_hispeed_load 93
	set_param cpu${bcores} target_loads "80 780000:33 880000:67 980000:42 1080000:75 1180000:65 1280000:74 1480000:97"
	set_param cpu${bcores} min_sample_time 18000
fi
esac
case ${SOC} in universal7420* | exynos7420*) #EXYNOS7420 (S6)
	update_clock_speed 380000 little min
	update_clock_speed 780000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0
	if [ ${PROFILE} -eq 0 ];then
	set_param cpu0 above_hispeed_delay "38000 1280000:78000 1380000:98000 1480000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 96
	set_param cpu0 target_loads "80 480000:28 580000:19 680000:37 780000:51 880000:61 1080000:83 1180000:66 1280000:91 1380000:96"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1480000
	set_param cpu${bcores} go_hispeed_load 97
	set_param cpu${bcores} target_loads "80 880000:74 980000:56 1080000:80 1180000:92 1380000:85 1480000:93 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 above_hispeed_delay "58000 1280000:18000 1380000:98000 1480000:58000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 480000:29 580000:12 680000:69 780000:22 880000:36 1080000:80 1180000:89 1480000:63"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "18000 1480000:78000 1580000:98000 1880000:138000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} go_hispeed_load 96
	set_param cpu${bcores} target_loads "80 880000:27 980000:44 1080000:71 1180000:32 1280000:64 1380000:78 1480000:87 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
fi
esac
case ${SOC} in kirin970* | hi3670*)  # Huawei Kirin 970
	update_clock_speed 480000 little min
	update_clock_speed 680000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0	
	if [ ${PROFILE} -eq 0 ];then
	set_param cpu0 above_hispeed_delay "18000 1380000:38000 1480000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 980000:60 1180000:87 1380000:70 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1580000:98000 1780000:138000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 1280000:98 1480000:91 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 above_hispeed_delay "18000 1480000:38000 1680000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:61 1180000:88 1380000:70 1480000:96"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "18000 1580000:98000 1780000:138000"
	set_param cpu${bcores} hispeed_freq 1280000
	set_param cpu${bcores} go_hispeed_load 94
	set_param cpu${bcores} target_loads "80 980000:72 1280000:77 1580000:98"
	set_param cpu${bcores} min_sample_time 18000
fi
esac
case ${SOC} in kirin960* | hi3660*)  # Huawei Kirin 960
	update_clock_speed 480000 little min
	update_clock_speed 880000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0	
	if [ ${PROFILE} -eq 0 ];then
	set_param cpu0 above_hispeed_delay "38000 1680000:98000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:93 1380000:97"
	set_param cpu0 min_sample_time 58000
	set_param cpu${bcores} above_hispeed_delay "18000 1780000:138000"
	set_param cpu${bcores} hispeed_freq 880000
	set_param cpu${bcores} go_hispeed_load 84
	set_param cpu${bcores} target_loads "80 1380000:98"
	set_param cpu${bcores} min_sample_time 38000
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 above_hispeed_delay "38000 1680000:98000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 980000:97 1380000:78 1680000:98"
	set_param cpu0 min_sample_time 78000
	set_param cpu${bcores} above_hispeed_delay "18000 1380000:98000 1780000:138000"
	set_param cpu${bcores} hispeed_freq 880000
	set_param cpu${bcores} go_hispeed_load 95
	set_param cpu${bcores} target_loads "80 1380000:59 1780000:98"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in kirin950* | hi3650* | kirin955* | hi3655*) # Huawei Kirin 950
	update_clock_speed 480000 little min
	update_clock_speed 780000 big min
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0
	if [ ${PROFILE} -eq 0 ];then
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:62 980000:71 1280000:77 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1480000:98000 1780000:138000"
	set_param cpu${bcores} hispeed_freq 780000
	set_param cpu${bcores} go_hispeed_load 80
	set_param cpu${bcores} target_loads "80 1180000:89 1480000:98"
	set_param cpu${bcores} min_sample_time 38000
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1280000
	set_param cpu0 go_hispeed_load 97
	set_param cpu0 target_loads "80 780000:69 980000:76 1280000:80 1480000:96"
	set_param cpu0 min_sample_time 58000
	set_param cpu${bcores} above_hispeed_delay "18000 1780000:138000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 80
	set_param cpu${bcores} target_loads "80 1180000:75 1480000:93 1780000:98"
	set_param cpu${bcores} min_sample_time 38000
fi
esac
case ${SOC} in mt6797*) #Helio X25 / X20
	setprop ro.mtk_perfservice_support 0
	lock_val 0 "/proc/sys/kernel/sched_tunable_scaling"
	lock_val 0 "/proc/ppm/policy/hica_is_limit_big_freq"
	lock_val 10000 "/dev/cpuctl/bg_non_interactive/cpu.rt_runtime_us"
	update_clock_speed 280000 little min
	update_clock_speed 280000 big min
	# CORE CONTROL
	lock_val 40 /proc/hps/down_threshold
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7,8"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7,8"
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0
	if [ ${PROFILE} -eq 0 ];then
	lock_val 90 /proc/hps/up_threshold
	lock_val "2 2 0" /proc/hps/num_base_perf_serv
	set_param cpu0 above_hispeed_delay "18000 1380000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 94
	set_param cpu0 target_loads "80 380000:15 480000:25 780000:36 880000:80 980000:66 1180000:91 1280000:96"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1380000:98000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 94
	set_param cpu${bcores} target_loads "80 380000:15 480000:25 780000:36 880000:80 980000:66 1180000:91 1280000:96"
	set_param cpu${bcores} min_sample_time 18000	
	elif [ ${PROFILE} -eq 1 ];then
	lock_val 80 /proc/hps/up_threshold
	lock_val "3 3 0" /proc/hps/num_base_perf_serv
	set_param cpu0 above_hispeed_delay "18000 1380000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 93
	set_param cpu0 target_loads "80 380000:8 580000:14 680000:9 780000:41 880000:56 1080000:65 1180000:92 1380000:85 1480000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1380000:98000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 93
	set_param cpu${bcores} target_loads "80 380000:8 580000:14 680000:9 780000:41 880000:56 1080000:65 1180000:92 1380000:85 1480000:97"
	set_param cpu${bcores} min_sample_time 18000
fi
esac
case ${SOC} in mt6795*) #Helio X10
	setprop ro.mtk_perfservice_support 0
	lock_val 0 "/proc/sys/kernel/sched_tunable_scaling"
	lock_val 0 "/proc/ppm/policy/hica_is_limit_big_freq"
	lock_val 10000 "/dev/cpuctl/bg_non_interactive/cpu.rt_runtime_us"
	update_clock_speed 380000 little min
	update_clock_speed 380000 big min
	# CORE CONTROL
	lock_val 40 /proc/hps/down_threshold
	# avoid permission problem, do not set 0444
	write "/dev/cpuset/background/cpus" "2-3"
	write "/dev/cpuset/system-background/cpus" "0-3"
	write "/dev/cpuset/foreground/cpus" "0-3,4-7"
	write "/dev/cpuset/top-app/cpus" "0-3,4-7"
	if [ ${PROFILE} -eq 0 ];then
	lock_val 90 /proc/hps/up_threshold
	lock_val 2 /proc/hps/num_base_perf_serv
	set_param cpu0 above_hispeed_delay "38000 1280000:18000 1480000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:51 1180000:65 1280000:83 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "38000 1280000:18000 1480000:98000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 780000:51 1180000:65 1280000:83 1480000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	lock_val 80 /proc/hps/up_threshold
	lock_val 3 /proc/hps/num_base_perf_serv
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 780000:60 1180000:86 1280000:79 1480000:97"
	set_param cpu0 min_sample_time 38000
	set_param cpu${bcores} above_hispeed_delay "18000 1480000:98000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 780000:60 1180000:86 1280000:79 1480000:97"
	set_param cpu${bcores} min_sample_time 38000
	fi
	esac
    case ${SOC} in moorefield*) # Intel Atom
	update_clock_speed 480000 little min
	update_clock_speed 480000 big min
	# shared interactive parameters
	set_param cpu0 timer_rate 20000
	set_param cpu0 timer_slack 180000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} timer_slack 180000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 0
	if [ ${PROFILE} -eq 0 ];then
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1180000
	set_param cpu0 go_hispeed_load 95
	set_param cpu0 target_loads "80 580000:56 680000:44 780000:33 880000:48 980000:62 1080000:74 1280000:89 1480000:98"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1480000:98000"
	set_param cpu${bcores} hispeed_freq 1180000
	set_param cpu${bcores} go_hispeed_load 95
	set_param cpu${bcores} target_loads "80 580000:56 680000:44 780000:33 880000:48 980000:62 1080000:74 1280000:89 1480000:98"
	set_param cpu${bcores} min_sample_time 18000
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 above_hispeed_delay "18000 1480000:98000"
	set_param cpu0 hispeed_freq 1380000
	set_param cpu0 go_hispeed_load 98
	set_param cpu0 target_loads "80 580000:53 680000:38 880000:49 980000:60 1180000:65 1280000:82 1380000:63 1480000:97"
	set_param cpu0 min_sample_time 18000
	set_param cpu${bcores} above_hispeed_delay "18000 1480000:98000"
	set_param cpu${bcores} hispeed_freq 1380000
	set_param cpu${bcores} go_hispeed_load 98
	set_param cpu${bcores} target_loads "80 580000:53 680000:38 880000:49 980000:60 1180000:65 1280000:82 1380000:63 1480000:97"
	set_param cpu${bcores} min_sample_time 18000
fi
esac
case ${SOC} in msm8939* | msm8952*)  #sd615/616/617 by@ 橘猫520

	if [ ${soc_revision} == "3.0" ] ;then
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu${bcores} go_hispeed_load 110
	set_param cpu${bcores} above_hispeed_delay 20000
	set_param cpu${bcores} timer_rate 60000
	set_param cpu${bcores} hispeed_freq 998000
	set_param cpu${bcores} timer_slack 380000
	set_param cpu${bcores} target_loads "85 800000:70 998000:82 1113000:84 1209000:82"
	set_param cpu${bcores} min_sample_time 0
	set_param cpu${bcores} ignore_hispeed_on_notif 0
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} fast_ramp_down 0
	set_param cpu${bcores} align_windows 0
	set_param cpu${bcores} use_migration_notif 1
	set_param cpu${bcores} use_sched_load 1
	set_param cpu${bcores} max_freq_hysteresis 0
	set_param cpu${bcores} boostpulse_duration 0
	set_param cpu0 go_hispeed_load 110
	set_param cpu0 above_hispeed_delay 20000
	set_param cpu0 timer_rate 60000
	set_param cpu0 hispeed_freq 1130000
	set_param cpu0 timer_slack 380000
	set_param cpu0 target_loads "85 960000:70 1130000:82 1340000:84 1459000:82"
	set_param cpu0 min_sample_time 0
	set_param cpu0 ignore_hispeed_on_notif 0
	set_param cpu0 boost 0
	set_param cpu0 fast_ramp_down 0
	set_param cpu0 align_windows 0
	set_param cpu0 use_migration_notif 1
	set_param cpu0 use_sched_load 1
	set_param cpu0 max_freq_hysteresis 0
	set_param cpu0 boostpulse_duration 0
	fi
	else
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu${bcores} hispeed_freq 400000
	set_param cpu0 hispeed_freq 883000
	set_param cpu${bcores} target_loads "98 40000:40 499000:80 533000:95 800000:75 998000:99"
	set_param cpu0 target_loads "98 883000:40 1036000:80 1113000:95 1267000:99"
	set_param cpu${bcores} above_hispeed_delay "20000 499000:60000 533000:150000"
	set_param cpu0 above_hispeed_delay "20000 1036000:60000 1130000:150000"
	set_param cpu0 min_sample_time 40000
	set_param cpu${bcores} min_sample_time 10000
	set_param cpu${bcores} go_hispeed_load 99
	set_param cpu0 go_hispeed_load 99
	set_param cpu${bcores} boostpulse_duration 80000
	set_param cpu0 boostpulse_duration 80000
	set_param cpu${bcores} use_sched_load 1
	set_param cpu0 use_sched_load 1
	set_param cpu${bcores} use_migration_notif 1
	set_param cpu0 use_migration_notif 1
	set_param cpu${bcores} boost 0
	set_param cpu0 boost 0
	fi
	fi

	esac
    case ${SOC} in kirin650* | kirin655* | kirin658* | kirin659* | hi625*)  #KIRIN650 by @橘猫520
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 hispeed_freq 807000
	set_param cpu${bcores} hispeed_freq 1402000
	set_param cpu0 target_loads "98 480000:75 807000:95 1306000:99"
	set_param cpu${bcores} target_loads "98 1402000:95"
	set_param cpu0 above_hispeed_delay "20000 480000:60000 807000:150000"
	set_param cpu${bcores} above_hispeed_delay "20000 1402000:160000"
	set_param cpu${bcores} min_sample_time 50000
	set_param cpu0 min_sample_time 50000
	set_param cpu${bcores} boost 0
	set_param cpu0 boost 0
	set_param cpu${bcores} go_hispeed_load 99
	set_param cpu0 go_hispeed_load 99
	set_param cpu${bcores} boostpulse_duration 80000
	set_param cpu0 boostpulse_duration 80000
	set_param cpu${bcores} use_sched_load 1
	set_param cpu0 use_sched_load 1
	set_param cpu${bcores} use_migration_notif 1
	set_param cpu0 use_migration_notif 1
	fi
	esac
    case ${SOC} in universal9810* | exynos9810*) # S9 exynos_9810 by @橘猫520
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 boostpulse_duration 4000
	set_param cpu${bcores} boostpulse_duration 4000
	set_param cpu0 boost 1
	set_param cpu${bcores} boost 1
	set_param cpu0 timer_rate 20000
	set_param cpu${bcores} timer_rate 20000
	set_param cpu0 timer_slack 10000
	set_param cpu${bcores} timer_slack 10000
	set_param cpu0 min_sample_time 12000
	set_param cpu${bcores} min_sample_time 12000
	set_param cpu0 io_is_busy 0
	set_param cpu${bcores} io_is_busy 0
	set_param cpu0 ignore_hispeed_on_notif 0
	set_param cpu${bcores} ignore_hispeed_on_notif 0
	set_param cpu${bcores} go_hispeed_load 73
	set_param cpu0 go_hispeed_load 65
	set_param cpu${bcores} hispeed_freq 1066000
	set_param cpu0 hispeed_freq 715000
	set_param cpu${bcores} above_hispeed_delay "4000 741000:77000 962000:99000 1170000:110000 1469000:130000 1807000:140000 2002000:1500000 2314000:160000 2496000:171000 2652000:184000 2704000:195000"
	set_param cpu0 above_hispeed_delay "4000 455000:77000 715000:95000 1053000:110000 1456000:130000 1690000:1500000 1794000:163000"
	set_param cpu${bcores} target_loads "55 741000:44 962000:51 1170000:58 1469000:66 1807000:73 2002000:82 2314000:89 2496000:93 2652000:97 2704000:100"
	set_param cpu0 target_loads "45 455000:48 715000:68 949000:71 1248000:86 1690000:91 1794000:100"
fi
esac
case ${SOC} in apq8026* | apq8028* | apq8030* | msm8226* | msm8228* | msm8230* | msm8626* | msm8628* | msm8630* | msm8926* | msm8928* | msm8930*)  #sd400 series by @cjybyjk
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param_all go_hispeed_load 99
	set_param_all above_hispeed_delay "20000 600000:60000 787000:150000"
	set_param_all timer_rate 20000
	set_param_all hispeed_freq 600000
	set_param_all timer_slack 80000
	set_param_all target_loads "98 384000:75 600000:95 787000:40 998000:80 1094000:99"
	set_param_all min_sample_time 50000
	set_param_all boost 0
fi
esac
case ${SOC} in apq8016* | msm8916* | msm8216* | msm8917* | msm8217*)  #sd410/sd425 series by @cjybyjk
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param_all go_hispeed_load 99
	set_param_all above_hispeed_delay "0 998000:25000 1152000:41000 1209000:55000"
	set_param_all timer_rate 60000
	set_param_all hispeed_freq 800000
	set_param_all timer_slack 480000
	set_param_all target_loads "98 400000:68 553000:82 800000:72 998000:92 1094000:83 1152000:99 1209000:100"
	set_param_all min_sample_time 0
	set_param_all ignore_hispeed_on_notif 0
	set_param_all boost 0
	set_param_all fast_ramp_down 0
	set_param_all align_windows 0
	set_param_all use_migration_notif 1
	set_param_all use_sched_load 0
	set_param_all max_freq_hysteresis 0
	set_param_all boostpulse_duration 0
fi
esac
case ${SOC} in msm8937*)  #sd430 series by @cjybyjk
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 go_hispeed_load 99
	set_param cpu0 above_hispeed_delay "20000 960000:50000 1094000:150000"
	set_param cpu0 timer_rate 20000
	set_param cpu0 hispeed_freq 960000
	set_param cpu0 timer_slack 80000
	set_param cpu0 target_loads "98 768000:75 960000:95 1094000:40 1209000:80 1344000:99"
	set_param cpu0 min_sample_time 50000
	set_param cpu0 boost 0
	set_param cpu0 boostpulse_duration 80000
	set_param cpu${bcores} go_hispeed_load 99
	set_param cpu${bcores} above_hispeed_delay "20000 998000:60000 1094000:150000"
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} hispeed_freq 998000
	set_param cpu${bcores} timer_slack 80000
	set_param cpu${bcores} target_loads "98 902000:75 998000:95 1094000:99"
	set_param cpu${bcores} min_sample_time 50000
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} boostpulse_duration 80000
fi
esac
case ${SOC} in msm8940*)  #sd435 series by @cjybyjk
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 go_hispeed_load 110
	set_param cpu0 above_hispeed_delay 20000
	set_param cpu0 timer_rate 60000
	set_param cpu0 hispeed_freq 902000
	set_param cpu0 timer_slack 380000
	set_param cpu0 target_loads "85 768000:70 902000:82 998000:84 1094000:82"
	set_param cpu0 min_sample_time 0
	set_param cpu0 ignore_hispeed_on_notif 0
	set_param cpu0 boost 0
	set_param cpu0 fast_ramp_down 0
	set_param cpu0 align_windows 0
	set_param cpu0 use_migration_notif 1
	set_param cpu0 use_sched_load 1
	set_param cpu0 max_freq_hysteresis 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu${bcores} go_hispeed_load 110
	set_param cpu${bcores} above_hispeed_delay 20000
	set_param cpu${bcores} timer_rate 60000
	set_param cpu${bcores} hispeed_freq 1094000
	set_param cpu${bcores} timer_slack 380000
	set_param cpu${bcores} target_loads "85 960000:70 1094000:82 1209000:84 1248000:82"
	set_param cpu${bcores} min_sample_time 0
	set_param cpu${bcores} ignore_hispeed_on_notif 0
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} fast_ramp_down 0
	set_param cpu${bcores} align_windows 0
	set_param cpu${bcores} use_migration_notif 1
	set_param cpu${bcores} use_sched_load 1
	set_param cpu${bcores} max_freq_hysteresis 0
	set_param cpu${bcores} boostpulse_duration 0
fi
esac
case ${SOC} in sdm450*)  #sd450 series by @cjybyjk
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu${bcores} hispeed_freq 1401000
	set_param cpu0 hispeed_freq 1036000
	set_param cpu${bcores} above_hispeed_delay "20000 1401000:60000 1689000:150000"
	set_param cpu0 above_hispeed_delay "20000 1036000:60000 1401000:150000"
	set_param cpu${bcores} target_loads "98 1036000:80 1209000:95 1401000:99"
	set_param cpu0 target_loads "98 652000:80 1036000:95 1401000:99"
	set_param_all min_sample_time 24000
	set_param_all use_sched_load 1
	set_param_all use_migration_notif 1
	set_param_all go_hispeed_load 99
fi
esac
case ${SOC} in mt6755*)  #mtk6755 series by @cjybyjk
	setprop ro.mtk_perfservice_support 0
	lock_val 0 "/proc/sys/kernel/sched_tunable_scaling"
	lock_val 0 "/proc/ppm/policy/hica_is_limit_big_freq"
	lock_val 10000 "/dev/cpuctl/bg_non_interactive/cpu.rt_runtime_us"
	if [ ${PROFILE} -eq 0 ];then
	MSG=1
	elif [ ${PROFILE} -eq 1 ];then
	set_param cpu0 go_hispeed_load 99
	set_param cpu0 above_hispeed_delay "0 689000:61000 871000:65000 1014000:71000 1144000:75000"
	set_param cpu0 timer_rate 60000
	set_param cpu0 hispeed_freq 689000
	set_param cpu0 timer_slack 480000
	set_param cpu0 target_loads "98 338000:68 494000:82 598000:72 689000:92 871000:83 1014000:99 1144000:100"
	set_param cpu0 min_sample_time 0
	set_param cpu0 ignore_hispeed_on_notif 0
	set_param cpu0 boost 0
	set_param cpu0 fast_ramp_down 0
	set_param cpu0 align_windows 0
	set_param cpu0 use_migration_notif 1
	set_param cpu0 use_sched_load 0
	set_param cpu0 max_freq_hysteresis 0
	set_param cpu0 boostpulse_duration 0
	set_param cpu0 io_is_busy 0
	set_param cpu${bcores} go_hispeed_load 99
	set_param cpu${bcores} above_hispeed_delay "20000 1027000:60000 1196000:150000"
	set_param cpu${bcores} timer_rate 20000
	set_param cpu${bcores} hispeed_freq 663000
	set_param cpu${bcores} timer_slack 80000
	set_param cpu${bcores} target_loads "98 663000:40 1027000:80 1196000:95 1573000:75 1755000:99 1950000:100"
	set_param cpu${bcores} min_sample_time 50000
	set_param cpu${bcores} ignore_hispeed_on_notif 0
	set_param cpu${bcores} boost 0
	set_param cpu${bcores} fast_ramp_down 0
	set_param cpu${bcores} align_windows 0
	set_param cpu${bcores} use_migration_notif 1
	set_param cpu${bcores} use_sched_load 0
	set_param cpu${bcores} max_freq_hysteresis 0
	set_param cpu${bcores} boostpulse_duration 80000
	set_param cpu${bcores} io_is_busy 0
   	fi
   	esac
	after_modify

fi

    # Enable thermal & BCL core_control now
	if [[ -e "/sys/module/msm_thermal/core_control/enabled" ]];then
    mutate 1 /sys/module/msm_thermal/core_control/enabled
	else
	mutate 'Y' /sys/module/msm_thermal/parameters/enabled
	fi
	if [[ -e "/sys/power/cpuhotplug/enabled" ]];then
    mutate 1 "/sys/power/cpuhotplug/enabled"
	fi
	if [[ -e "/sys/power/cpuhotplug/enabled" ]];then
    mutate 1 "/sys/devices/system/cpu/cpuhotplug/enabled"
	fi

    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n disable > $mode
    done
    for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
    do
        echo $bcl_hotplug_mask > $hotplug_mask
    done
    for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
    do
        echo $bcl_soc_hotplug_mask > $hotplug_soc_mask
    done
    for mode in /sys/devices/soc.0/qcom,bcl.*/mode
    do
        echo -n enable > $mode
    done
	
    # Enable all low power modes
    # write /sys/module/lpm_levels/parameters/sleep_disabled "N" 2>/dev/null  # pass not causing lag

}

# =========
# CPU Governor Tuning
# =========
stop "thermald"
stop "thermal-engine"
stop "thermal-hal-1-0"
stop "mpdecision"
if [ $support -eq 1 ];then
    LOGDATA "|		SoC check successful...CPU Tuning"
    cputuning
elif [ $support -eq 2 ];then
    LOGDATA "|		This device is Supported by Universal Kernel Tweaks"
    LOGDATA "|		This device is Partially Supported by Universal Kernel Tweaks"
    cputuning
else
    LOGDATA "|		[×] SOC CHECK FAILED"
    LOGDATA "|		SOME FEATURES MIGHT NOT WORK ON THIS DEVICE"
fi
start "thermald"
start "thermal-engine"
stop "thermal-hal-1-0"
stop "perfd"
stop "mpdecision"
# Disable KSM to save CPU cycles
if [ -e '/sys/kernel/mm/uksm/run' ]; then
LOGDATA "|		DISABLING uKSM"
write '/sys/kernel/mm/uksm/run' 0;
setprop ro.config.uksm.support false;
elif [ -e '/sys/kernel/mm/ksm/run' ]; then
LOGDATA "|		DISABLING KSM"
write '/sys/kernel/mm/ksm/run' 0;
setprop ro.config.ksm.support false;
fi;
if [ -e '/sys/kernel/fp_boost/enabled' ]; then
write '/sys/kernel/fp_boost/enabled' 1;
LOGDATA "|		ENABLING FINGER PRINT BOOST"
fi;
# =========
# GPU Tweaks
# =========
if [ -e "/sys/module/adreno_idler" ]; then

	if [ ${PROFILE} -eq 0 ];then
	LOGDATA "| ENABLING GPU ADRENO IDLER " 
	write /sys/module/adreno_idler/parameters/adreno_idler_active "Y"
	write /sys/module/adreno_idler/parameters/adreno_idler_idleworkload "10000"
	write /sys/module/adreno_idler/parameters/adreno_idler_downdifferential '40'
	write /sys/module/adreno_idler/parameters/adreno_idler_idlewait '24'
	else
	LOGDATA "| ENABLING GPU ADRENO IDLER " 
	write /sys/module/adreno_idler/parameters/adreno_idler_active "Y"
	write /sys/module/adreno_idler/parameters/adreno_idler_idleworkload "6000"
	write /sys/module/adreno_idler/parameters/adreno_idler_downdifferential '15'
	write /sys/module/adreno_idler/parameters/adreno_idler_idlewait '15'
	fi
	
fi
# Various GPU enhancements
if [ ${GPU_MAX} -eq 0 ] || [ -z ${GPU_MODEL} ] ;then
GPU_PWR=$(cat $GPU_DIR/num_pwrlevels) 2>/dev/null
GPU_PWR=$(($GPU_PWR-1))
GPU_BATT=$(awk -v x=$GPU_PWR 'BEGIN{print((x/2)-0.5)}')
GPU_BATT=$(round ${GPU_BATT} 0)
GPU_TURBO=$(awk -v x=$GPU_PWR 'BEGIN{print((x/2)+0.5)}')
GPU_TURBO=$(round ${GPU_TURBO} 0)
gpu_idle=$(cat /data/adb/idle_timer.txt) 2>/dev/null
idle_batt=$(awk -v x=$gpu_idle 'BEGIN{print x*2}')
idle_balc=$(awk -v x=$gpu_idle 'BEGIN{print (x*3)/4}')
idle_perf=$(awk -v x=$gpu_idle 'BEGIN{print x/2}')
gpu_nap=$(cat /data/adb/deep_nap_timer.txt) 2>/dev/null
nap_batt=$(awk -v x=$gpu_nap 'BEGIN{print x*2}')
nap_balc=$(awk -v x=$gpu_nap 'BEGIN{print (x*3)/4}')
nap_perf=$(awk -v x=$gpu_nap 'BEGIN{print x/2}')
idle_batt=$(round ${idle_batt} 0)
idle_balc=$(round ${idle_balc} 0)
idle_perf=$(round ${idle_perf} 0)
nap_batt=$(round ${nap_batt} 0)
nap_balc=$(round ${nap_balc} 0)
nap_perf=$(round ${nap_perf} 0)
#if [[ "$GPU_GOV" == *"simple_ondemand"* ]]; then
write "$GPU_DIR/devfreq/governor" "simple_ondemand"
#fi
lock_val $GPU_MAX "$GPU_DIR/max_gpuclk"
lock_val $GPU_MAX "$GPU_DIR/devfreq/max_freq" 
lock_val $GPU_MIN "$GPU_DIR/devfreq/min_freq" 
lock_val $GPU_MIN "$GPU_DIR/devfreq/target_freq" 

lock_val 0 "$GPU_DIR/throttling"
lock_val 0 "$GPU_DIR/force_no_nap"
lock_val 1 "$GPU_DIR/bus_split"
lock_val 0 "$GPU_DIR/force_bus_on"
lock_val 0 "$GPU_DIR/force_clk_on"
lock_val 0 "$GPU_DIR/force_rail_on"
write "/proc/gpufreq/gpufreq_limited_thermal_ignore" 1
write "/proc/mali/dvfs_enable" 1

	if [ ${PROFILE} -eq 0 ];then
lock_val $GPU_BATT "$GPU_DIR/max_pwrlevel"
lock_val $GPU_PWR "$GPU_DIR/min_pwrlevel"
lock_val 0 "$GPU_DIR/force_no_nap"
#lock_val $nap_batt "$GPU_DIR/deep_nap_timer"
#lock_val $idle_batt "$GPU_DIR/idle_timer"
#chmod 0644 "/sys/devices/14ac0000.mali/dvfs"
#chmod 0644 "/sys/devices/14ac0000.mali/dvfs_max_lock"
#chmod 0644 "/sys/devices/14ac0000.mali/dvfs_min_lock"
	elif [ ${PROFILE} -eq 1 ];then
lock_val 0 "$GPU_DIR/max_pwrlevel"
lock_val $GPU_PWR "$GPU_DIR/min_pwrlevel"
lock_val 0 "$GPU_DIR/force_no_nap"
#lock_val $idle_balc "$GPU_DIR/deep_nap_timer"
#lock_val $nap_balc "$GPU_DIR/idle_timer"
	fi
	
for i in ${GPU_DIR}/devfreq/*
do
chmod 0644 $i
done
for i in ${GPU_DIR}/*
do
chmod 0644 $i
done
fi

# =========
# RAM TWEAKS
# =========
if [[ $3 == "" ]];then
LOGDATA "|		APPLYING MEMORY OPTIMIZATIONS" 
sh $SCRIPT_DIR/mem_opt_main.sh
else
LOGDATA "|		KERNEL						" 
fi

# =========
# I/O TWEAKS
# =========
if [ -d /sys/block/dm-0 ] || [ -d /sys/devices/virtual/block/dm-0 ]; then
if [ -e /sys/devices/virtual/block/dm-0/queue/scheduler ]; then
    DM_PATH=/sys/devices/virtual/block/dm-0/queue
fi
if [ -e /sys/block/dm-0/queue/scheduler ]; then
    DM_PATH=/sys/block/dm-0/queue
fi
sch=$(</sys/devices/virtual/block/dm-0/queue/scheduler);
if [[ $sch == *"maple"* ]]; then
   if [ -e $DM_PATH/scheduler_hard ]; then
   write $DM_PATH/scheduler_hard "maple"
   fi
   write $DM_PATH/scheduler "maple"
   sleep 2
   write $DM_PATH/iosched/async_read_expire 666;
   write $DM_PATH/iosched/async_write_expire 1666;
   write $DM_PATH/iosched/fifo_batch 16;
   write $DM_PATH/iosched/sleep_latency_multiple 5;
   write $DM_PATH/iosched/sync_read_expire 333;
   write $DM_PATH/iosched/sync_write_expire 1166;
   write $DM_PATH/iosched/writes_starved 3;
   write $DM_PATH/iosched/read_ahead_kb 128;
if [ -e "/sys/devices/virtual/block/dm-0/bdi/read_ahead_kb" ]; then
   if [ ${PROFILE} -ge 2 ];then
   write /sys/devices/virtual/block/dm-0/bdi/read_ahead_kb 2048
   else
   write /sys/devices/virtual/block/dm-0/bdi/read_ahead_kb 128
   fi
fi

if [ -e "/sys/block/sda/bdi/read_ahead_kb" ]; then
   if [ ${PROFILE} -ge 2 ];then
   write /sys/block/sda/bdi/read_ahead_kb 2048
   else
   write /sys/block/sda/bdi/read_ahead_kb 128
   fi
fi
else
if [[ $sch == *"cfq"* ]]; then
   if [ -e $DM_PATH/scheduler_hard ]; then
   write $DM_PATH/scheduler_hard "cfq"
   fi
   write $DM_PATH/scheduler "cfq"
   write $DM_PATH/iosched/low_latency 0;
   write $DM_PATH/iosched/slice_idle 0;
   write $DM_PATH/iosched/group_idle 8;
   
if [ -e "/sys/devices/virtual/block/dm-0/bdi/read_ahead_kb" ]; then
   if [ ${PROFILE} -ge 2 ];then
   write /sys/devices/virtual/block/dm-0/bdi/read_ahead_kb 512
   else
   write /sys/devices/virtual/block/dm-0/bdi/read_ahead_kb 128
   fi
fi

if [ -e "/sys/block/sda/bdi/read_ahead_kb" ]; then
   if [ ${PROFILE} -ge 2 ];then
   write /sys/block/sda/bdi/read_ahead_kb 512
   else
   write /sys/block/sda/bdi/read_ahead_kb 128
   fi
fi
fi
fi
	write $DM_PATH/add_random 0
	write $DM_PATH/iostats 0
   	write $DM_PATH/nomerges 2
   	write $DM_PATH/rotational 0
   	write $DM_PATH/rq_affinity 1
fi
sch=$(</sys/block/sda/queue/scheduler);
if [[ $sch == *"maple"* ]]; then
	for i in /sys/block/*; do
	    set_io maple $i;
	done;
	set_io maple /sys/block/mmcblk0
	set_io maple /sys/block/sda
	else
	if [[ $sch == *"cfq"* ]]; then
	for i in /sys/block/*; do
	    set_io cfq $i;
	done;
	set_io cfq /sys/block/mmcblk0
	set_io cfq /sys/block/sda
	fi
fi
for i in /sys/block/*; do
	write $i/queue/add_random 0
	write $i/queue/iostats 0
   	write $i/queue/nomerges 2
   	write $i/queue/rotational 0
   	write $i/queue/rq_affinity 1
done;

# =========
# REDUCE DEBUGGING
# =========
LOGDATA "|		TWEAKS 				" 
write "/sys/module/wakelock/parameters/debug_mask" 0
write "/sys/module/userwakelock/parameters/debug_mask" 0
write "/sys/module/earlysuspend/parameters/debug_mask" 0
write "/sys/module/alarm/parameters/debug_mask" 0
write "/sys/module/alarm_dev/parameters/debug_mask" 0
write "/sys/module/binder/parameters/debug_mask" 0
write "/sys/devices/system/edac/cpu/log_ce" 0
write "/sys/devices/system/edac/cpu/log_ue" 0
write "/sys/module/binder/parameters/debug_mask" 0
write "/sys/module/bluetooth/parameters/disable_ertm" "Y"
write "/sys/module/bluetooth/parameters/disable_esco" "Y"
write "/sys/module/debug/parameters/enable_event_log" 0
write "/sys/module/dwc3/parameters/ep_addr_rxdbg_mask" 0 
write "/sys/module/dwc3/parameters/ep_addr_txdbg_mask" 0
write "/sys/module/edac_core/parameters/edac_mc_log_ce" 0
write "/sys/module/edac_core/parameters/edac_mc_log_ue" 0
write "/sys/module/glink/parameters/debug_mask" 0
write "/sys/module/hid_apple/parameters/fnmode" 0
write "/sys/module/hid_magicmouse/parameters/emulate_3button" "N"
write "/sys/module/hid_magicmouse/parameters/emulate_scroll_wheel" "N"
write "/sys/module/ip6_tunnel/parameters/log_ecn_error" "N"
write "/sys/module/lowmemorykiller/parameters/debug_level" 0
write "/sys/module/mdss_fb/parameters/backlight_dimmer" "N"
write "/sys/module/msm_show_resume_irq/parameters/debug_mask" 0
write "/sys/module/msm_smd/parameters/debug_mask" 0
write "/sys/module/msm_smem/parameters/debug_mask" 0 
write "/sys/module/otg_wakelock/parameters/enabled" "N" 
write "/sys/module/service_locator/parameters/enable" 0 
write "/sys/module/sit/parameters/log_ecn_error" "N"
write "/sys/module/smem_log/parameters/log_enable" 0
write "/sys/module/smp2p/parameters/debug_mask" 0
write "/sys/module/sync/parameters/fsync_enabled" "N"
write "/sys/module/touch_core_base/parameters/debug_mask" 0
write "/sys/module/usb_bam/parameters/enable_event_log" 0
write "/sys/module/printk/parameters/console_suspend" "Y"
write "/proc/sys/debug/exception-trace" 0
write "/proc/sys/kernel/printk" "0 0 0 0"
write "/proc/sys/kernel/compat-log" "0"
sysctl -e -w kernel.panic_on_oops=0
sysctl -e -w kernel.panic=0
if [ -e /sys/module/logger/parameters/log_mode ]; then
 write /sys/module/logger/parameters/log_mode 2
fi;
if [ -e /sys/module/printk/parameters/console_suspend ]; then
 write /sys/module/printk/parameters/console_suspend 'Y'
fi;
for i in $(find /sys/ -name debug_mask); do
 write $i 0;
done
for i in $(find /sys/ -name debug_level); do
 write $i 0;
done
for i in $(find /sys/ -name edac_mc_log_ce); do
 write $i 0;
done
for i in $(find /sys/ -name edac_mc_log_ue); do
 write $i 0;
done
for i in $(find /sys/ -name enable_event_log); do
 write $i 0;
done
for i in $(find /sys/ -name log_ecn_error); do
 write $i 0;
done
for i in $(find /sys/ -name snapshot_crashdumper); do
 write $i 0;
done
# =========
# FIX DEEPSLEEP
# =========
for i in $(ls /sys/class/scsi_disk/); do
 lock_val 'temporary none' '/sys/class/scsi_disk/$i/cache_type';
done;
# =========
# TCP TWEAKS
# =========
algos=$(</proc/sys/net/ipv4/tcp_available_congestion_control);
if [[ $algos == *"westwood"* ]]
then
write /proc/sys/net/ipv4/tcp_congestion_control "westwood"
LOGDATA "|		ENABLING WESTWOOD TCP ALGORITHM  " 
else
write /proc/sys/net/ipv4/tcp_congestion_control "cubic"
fi
# Increase WI-FI scan delay
#sqlite=/system/xbin/sqlite3 wifi_idle_wait=36000 
# =========
# Blocking Wakelocks
# =========
WK=0
if [ -e "/sys/module/bcmdhd/parameters/wlrx_divide" ]; then
write /sys/module/bcmdhd/parameters/wlrx_divide "8"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/bcmdhd/parameters/wlctrl_divide" ]; then
write /sys/module/bcmdhd/parameters/wlctrl_divide "8"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluetooth_timer" ]; then
write /sys/module/wakeup/parameters/enable_bluetooth_timer "Y"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ipa_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_ipa_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_pno_wl_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_pno_wl_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws" ]; then
write /sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/wlan_wake" ]; then
write /sys/module/wakeup/parameters/wlan_wake "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/wlan_ctrl_wake" ]; then
write /sys/module/wakeup/parameters/wlan_ctrl_wake "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/wlan_rx_wake" ]; then
write /sys/module/wakeup/parameters/wlan_rx_wake "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_msm_hsic_ws" ]; then
write /sys/module/wakeup/parameters/enable_msm_hsic_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
write /sys/module/wakeup/parameters/enable_si_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
write /sys/module/wakeup/parameters/enable_si_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluedroid_timer_ws" ]; then
write /sys/module/wakeup/parameters/enable_bluedroid_timer_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_ipa_ws" ]; then
write /sys/module/wakeup/parameters/enable_ipa_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_netlink_ws" ]; then
write /sys/module/wakeup/parameters/enable_netlink_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_netmgr_wl_ws" ]; then
write /sys/module/wakeup/parameters/enable_netmgr_wl_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws" ]; then
write /sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_timerfd_ws" ]; then
write /sys/module/wakeup/parameters/enable_timerfd_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_rx_wake_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_rx_wake_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_wake_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_wake_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_wow_wl_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_wow_wl_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ctrl_wake_ws" ]; then
write /sys/module/wakeup/parameters/enable_wlan_ctrl_wake_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/smb135x_charger/parameters/use_wlock" ]; then
write /sys/module/smb135x_charger/parameters/use_wlock "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_smb135x_wake_ws" ]; then
write /sys/module/wakeup/parameters/enable_smb135x_wake_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
write /sys/module/wakeup/parameters/enable_si_wsk "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluesleep_ws" ]; then
write /sys/module/wakeup/parameters/enable_bluesleep_ws "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/bcmdhd/parameters/wlrx_divide" ]; then
write /sys/module/bcmdhd/parameters/wlrx_divide "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/bcmdhd/parameters/wlctrl_divide" ]; then
write /sys/module/bcmdhd/parameters/wlctrl_divide "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/xhci_hcd/parameters/wl_divide" ]; then
write /sys/module/xhci_hcd/parameters/wl_divide "N"
WK=$(( ${WK} + 1 ))
fi
if [ -e "/sys/module/smb135x_charger/parameters/use_wlock" ]; then
write /sys/module/smb135x_charger/parameters/use_wlock "N"
WK=$(( ${WK} + 1 ))
fi
if [ ${WK} -gt 0 ] ;then
LOGDATA "|		BLOCKING ${WK} DETECTED KERNEL WAKELOCKS"
fi
if [ -e "/sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker" ]; then
LOGDATA "|		ENABLING BOEFFLA WAKELOCK BLOCKER "
write /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;[timerfd];hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;NETLINK"
fi
# =========
# Google Services Drain fix by @Alcolawl @Oreganoian
# =========
LOGDATA "|          DEALING WITH GMS BATTERY DRAIN           "
su -c pm enable com.google.android.gms/.update.SystemUpdateActivity 
su -c pm enable com.google.android.gms/.update.SystemUpdateService
su -c pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver 
su -c pm enable com.google.android.gms/.update.SystemUpdateService$Receiver 
su -c pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver 
su -c pm enable com.google.android.gsf/.update.SystemUpdateActivity 
su -c pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity 
su -c pm enable com.google.android.gsf/.update.SystemUpdateService 
su -c pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver 
su -c pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver
# FS-TRIM
fstrim -v /cache
fstrim -v /data
fstrim -v /system
LOGDATA "|                  DONE!!!                       "
# =========
# Battery Check
# =========
LOGDATA "|________________________________________________" 
LOGDATA "|			BATTERY INFO		                  "
LOGDATA "|		BATTERY LEVEL: $BATT_LEV %                "
LOGDATA "|		BATTERY TECHNOLOGY: $BATT_TECH            "
LOGDATA "|		BATTERY HEALTH: $BATT_HLTH                "
LOGDATA "|		BATTERY TEMP: $BATT_TEMP °C               "
LOGDATA "|		BATTERY VOLTAGE: $BATT_VOLT VOLTS         "
LOGDATA "|________________________________________________" 
LOGDATA "|			 	 STATUS		                  "
LOGDATA "|      LAST RUN : $(date +"%d-%m-%Y %r")         "
LOGDATA "|________________________________________________" 

