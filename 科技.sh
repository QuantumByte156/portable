Id_Path=/data/system/users/999
rm -rf $Id_Path/registered_services $Id_Path/app_idle_stats.xml

Id_File=$Id_Path/settings_ssaid.xml
abx2xml -i $Id_File

View_id() { grep $1 $Id_File | awk -F '"' '{print $6}' ;}

Random_Id_1() { cat /proc/sys/kernel/random/uuid ;}

Amend_Id() { sed -i "s#$1#$2#g" $Id_File ;}

Amend_Id `View_id userkey` $(echo `Random_Id_1``Random_Id_1` | tr -d - | tr a-z A-Z)
Userkey_Uid=`View_id userkey`
Amend_Id `View_id com.tencent.tmgp.dfm` `Random_Id_1 | tr -d - | head -c 16`
Pkg_Aid=`View_id com.tencent.tmgp.dfm`

xml2abx -i $Id_File

Random_Id_2() {
  Min=$1
  Max=$(($2 - $Min + 1))
  Num=`cat /dev/urandom | head | cksum | awk -F ' ' '{print $1}'`
  echo $(($Num % $Max + $Min))
}

Tmp=/sys/devices/virtual/kgsl/kgsl/full_cache_threshold
Random_Id_2 1100000000 2000000000 > $Tmp

mount | grep -q /sys/devices/soc0/serial_number && umount /sys/devices/soc0/serial_number
mount --bind $Tmp /sys/devices/soc0/serial_number

IFS=$'\n'
for i in `getprop | grep imei | awk -F '[][]' '{print $2}'`
do
  Imei=`getprop $i`
  [ `echo $Imei | wc -c` -lt 16 ] && continue
  let a++
  resetprop $i `echo $((RANDOM % 80000 + 8610000))00000000`
done

echo `Random_Id_1 | tr -d - | head -c 16` > /data/system/oaid_persistence_0
echo `Random_Id_1 | tr -d - | head -c 16` > /data/system/vaid_persistence_platform
resetprop ro.serialno `Random_Id_1 | head -c 8`
settings put secure android_id `Random_Id_1 | tr -d - | head -c 16`
settings put secure bluetooth_address `Random_Id_1 | sed 's/-//g ;s/../&:/g' | head -c 17 | tr a-z A-Z`

resetprop ro.build.id UKQ1.$((RANDOM % 20000 + 30000)).001
resetprop ro.boot.cpuid 0x00000`Random_Id_1 | tr -d - | head -c 11`
resetprop ro.ril.oem.meid 9900$((RANDOM % 8000000000 + 1000000000))

settings put global ad_aaid `Random_Id_1`
settings put global extm_uuid `Random_Id_1`
settings put system key_mqs_uuid `Random_Id_1`

Sum=`getprop ro.build.fingerprint`
for i in $(seq 1 `echo "$Sum" | grep -o [0-9] | wc -l`)
do
  Sum=`echo "$Sum" | sed "s/[0-9]/$(($RANDOM % 10))/$i"`
done

resetprop ro.build.fingerprint "$Sum"

mount | grep -q /sys/class/net/wlan0/address && umount /sys/class/net/wlan0/address
svc wifi disable
ifconfig wlan0 down

Mac=`Random_Id_1 | sed 's/-//g ;s/../&:/g' | head -c 17`
ifconfig wlan0 hw ether $Mac

for Wlan_Path in `find /sys/devices -name wlan0`
do
  [ -f "$Wlan_Path/address" ] && {
    chmod 644 "$Wlan_Path/address"
    echo $Mac > "$Wlan_Path/address"
  }
done

chmod 0755 /sys/class/net/wlan0/address
echo $Mac > /sys/class/net/wlan0/address

for Wlan_Path in `find /sys/devices -name '*,wcnss-wlan'`
do
  [ -f "$Wlan_Path/wcnss_mac_addr" ] && {
    chmod 644 "$Wlan_Path/wcnss_mac_addr"
    echo $Mac > "$Wlan_Path/wcnss_mac_addr"
  }
done

echo $Mac > /data/local/tmp/Mac_File
mount --bind /data/local/tmp/Mac_File /sys/class/net/wlan0/address
ifconfig wlan0 up
svc wifi enable

until ping -c 1 13.107.21.200 &>/dev/null
do
done

echo $((`cat Ping` + 1)) > Ping

# 输出修改后的信息
echo "所有修改内容如下："
echo "累计修改次数: $(cat Ping)"
echo "IP地址: $(curl -s ipinfo.io/ip)"
echo "主板ID: $(cat /sys/devices/soc0/serial_number)"
echo "序列号: $(getprop ro.serialno)"
echo "Wifi_Mac地址: $(cat /sys/class/net/wlan0/address)"
echo "设备ID: $(settings get secure android_id)"
echo "OAID: $(cat /data/system/oaid_persistence_0)"
echo "暗区AID: $Pkg_Aid"
echo "IMEI已重置"
echo "蓝牙Mac地址: $(settings get secure bluetooth_address)"
echo "CPU_ID: $(getprop ro.boot.cpuid)"
echo "VAID: $(cat /data/system/vaid_persistence_platform)"
echo "版本ID: $(getprop ro.build.id)"
echo "OEM_ID: $(getprop ro.ril.oem.meid)"
echo "广告ID: $(settings get global ad_aaid)"
echo "UUID: $(settings get global extm_uuid)"
echo "指纹UUID: $(settings get system key_mqs_uuid)"
echo "系统UUID: $Userkey_Uid"

# 之前的代码...

# 将输出修改后的信息重定向到文件A
{
echo "所有修改内容如下："
echo "累计修改次数: $(cat Ping)"
echo "IP地址: $(curl -s ipinfo.io/ip)"
echo "主板ID: $(cat /sys/devices/soc0/serial_number)"
echo "序列号: $(getprop ro.serialno)"
echo "Wifi_Mac地址: $(cat /sys/class/net/wlan0/address)"
echo "设备ID: $(settings get secure android_id)"
echo "OAID: $(cat /data/system/oaid_persistence_0)"
echo "暗区AID: $Pkg_Aid"
echo "IMEI已重置"
echo "蓝牙Mac地址: $(settings get secure bluetooth_address)"
echo "CPU_ID: $(getprop ro.boot.cpuid)"
echo "VAID: $(cat /data/system/vaid_persistence_platform)"
echo "版本ID: $(getprop ro.build.id)"
echo "OEM_ID: $(getprop ro.ril.oem.meid)"
echo "广告ID: $(settings get global ad_aaid)"
echo "UUID: $(settings get global extm_uuid)"
echo "指纹UUID: $(settings get system key_mqs_uuid)"
echo "系统UUID: $Userkey_Uid"
} > IDLog




data_UAM=/data/user/0/com.tencent.tmgp.dfm
sdcard_UAM=/storage/emulated/0/Android/data/com.tencent.tmgp.dfm
uedir_UAM=/storage/emulated/0/Android/data/com.tencent.tmgp.dfm/files/UE4Game/UAGame/UAGame/Saved


rm -Rf /sdcard/ramdump
rm -Rf /data/user_de/0/com.tencent.tmgp.dfm/code_cache/*


rm -rf /storage/emulated/0/Android/data/org.telegram.messenger.web/*

rm -rf $data_UAM/cache/*
rm -rf $sdcard_UAM/cache/*
rm -rf $sdcard_UAM/files/tbslog/*
rm -rf $sdcard_UAM/files/tencent/*
rm -rf $uedir_UAM/Logs/*

dmesg -c >/dev/null 2>&1
logcat -c -b main -b events -b radio -b system >/dev/null 2>&1

#!/bin/sh

rm -Rf /data/miuilog/stability/scout/app/*

rm -Rf /storage/emulated/0/Android/data/com.tsng.hidemyapplist
rm -Rf /storage/emulated/0/Android/obb/com.tsng.hidemyapplist

data_UAM=/data/user/0/com.tencent.tmgp.dfm
sdcard_UAM=/storage/emulated/0/Android/data/com.tencent.tmgp.dfm
uedir_UAM=/storage/emulated/0/Android/data/com.tencent.tmgp.dfm/files/UE4Game/UAGame/UAGame/Saved



rm -Rf /data/user_de/0/com.tencent.tmgp.dfm/code_cache/*
rm -Rf $data_UAM/*



rm -rf $uedir_UAM/patch/*
rm -rf $sdcard_UAM/cache/*
rm -Rf $sdcard_UAM/files/midas/log
rm -Rf $sdcard_UAM/files/commonlog/*
rm -Rf $sdcard_UAM/files/TGPA
rm -Rf $sdcard_UAM/files/g6_player_prefs.ini
rm -Rf $sdcard_UAM/files/.fff
rm -Rf $sdcard_UAM/files/.system_android_l2
rm -Rf $sdcard_UAM/files/tbslog/*
rm -Rf $sdcard_UAM/files/log/*
rm -Rf $sdcard_UAM/files/tencent
rm -Rf $uedir_UAM/Logs/*
rm -Rf $uedir_UAM/Config/*
rm -Rf $uedir_UAM/TriggerCDTimes.json
rm -Rf $uedir_UAM/TriggerTimes.json
rm -Rf $uedir_UAM/Pandora/*


setenforce 1
dmesg -c >/dev/null 2>&1
logcat -c >/dev/null 2>&1




rm -r /storage/emulated/0/Android/data/com.tencent.tmgp.dfm/files/centauri/*
rm -r /storage/emulated/0/Android/data/com.tencent.tmgp.dfm/files/UE4Game/UAGame/UAGame/Saved/Gamelet/*
回声"CRC Rebuilding ......Success ！"
回声"暗区"
回声"每次上游戏前请严格按照以下步骤："
回声"⒈桌面"
echo "2.执行"
echo "3.上游戏只用运行此sh一次，直到下次上游戏。"
echo "4.奔放"



rm -rf /data/user/0/com.tencent.tmgp.dfm/*

#!/bin/清除规则
iptables -F 
iptables -X 
iptables -Z
ip6tables -F
ip6tables -X
ip6tables -Z


RM-rf/data/miuilog/stability/scout/app/*

RM-rf/storage/emulated/0/Android/data/com.tsng.hidemyapplist
RM-rf/storage/emulated/0/Android/obb/com.tsng.hidemyapplist

data_UAM=/data/user/0/com.tencent.tmgp.dfm
sdcard_UAM=/storage/emulated/0/Android/data/com.Tencent.TMGP.DFM
ueir_UAM=/storage/emulated/0/Android/data/com。Tencent.TMGP.DFM/文件/UE4Game/UAGame/UAGame/Saved

RM-rf/storage/emulated/0/Android/data/com.Tencent.TMGP.DFM/cache

RM-rf/data/user_de/0/com.Tencent.TMGP.DFM/code_cache/*
rm -rf $data_UAM/*

rm -rf/storage/emulated/0/Android/data/com。Tencent.TMGP.DFM/文件/UE4Game/UAGame/NotAllowedUnattendedBugReports

rm -rf/storage/emulated/0/Android/data/com。腾讯.TMGP.DFM/文件/UE4Game/UAGame/Manifest_UFSFiles_Android。文本

回声-e"\033[32m正在遍历内部存储\033[0m"

# 
log_keywords=("日志" "半人马座" "TGPA" "缓存" "日志" "调试" "错误日志" "游戏日志")

# 用于存储被认为是日志文件的文件路径
日志文件(_F)=()
# 用于存储被认为是日志文件夹的文件夹路径
日志文件夹(_F)=()

功能process_directory(){
当地Dir="$1"
    # 判断文件夹
文件夹名称=$(基本名称"$dir")
    is_folder_log=假的
为关键字在……内"${log_keywords[@]}"关键字
如果 [[$folder_name== *$folder_name$关键字"== *
is_folder_log=正确
打破
Fi
已完成

    # 
如果$is_folder_log; 然后
回声-e"""\033[32m该文件夹可能是存储日志的文件夹，继续遍历：$dir\033[0m"
日志文件夹+=(_F)"$dir")
Fi

当地的total_files=$(查找"$dir"-max深度1-类型F|wc-l)
当地的processed_files=0
为文件in"$dir"/*; 做
如果[[-f$file]]; 然后
文件名=文件名=$(基本名称"$file")
is_log=假的
为关键字in"${log_keywords[@]}"关键字
如果 [[$filename== *$filename$关键字"== *
                    is_log=正确=正确
打破
Fi
已完成
如果如果; 然后
回声-e回声-e"$file被判断为可能是残留日志文件\033[0米"
日志文件(_F)+=(日志文件(_F)+=("$file")
其他
回声-e回声-e"$file不太可能是残留日志文件\033[0米"
菲菲
((processed_files++))
进度=$((processed_files*100/total_files))
回声-ne回声-ne"${progress}进度：[%]\r"进度：[%]\r"-ne"
Elif[[-dElif]]；然后Elif[[Elif[[-dElif]]]；然后elif[[]]；然后
回声-e$文件\033[0米"-eecho-e"\0-eecho\033[32m正在遍历子文件夹：\0[32m正在遍历子文件夹：\0"\0""\033[32m正在遍历子文件夹：\0[32m正在遍历子文件夹：\0[32m正在遍历子文件夹：件\0[32m正在遍历子文件夹：件\033[0米[32m正在遍历子文件夹：件\0[32m正在遍历子文件夹：件\033[0米"[32m正在遍历子文件夹：件\0[32m正在遍历子文件夹：件\0"\0-e[0m"[0米"[0米"$文件\033[0米"-eecho-e"\0-eecho\033[32m正在遍历子文件夹：\0[32m正在遍历子文件夹：\0"\0""\033[32m正在遍历子文件夹：\0[32m正在遍历子文件夹：\0[32m正在遍历子文件夹：件\0[32m正在遍历子文件夹：件\033[0米[32m正在遍历子文件夹：件\0[32m正在遍历子文件夹：件\033[0米"[32m正在遍历子文件夹：件\0[32m正在遍历子文件夹：件\0"\0-e[0m"[0米"[0米"
process_directory"$file""$file"$file""$file"
菲菲
已完成done
回声-e-e"回声-E-E"\n进度：[100%]"\n进度：[100%]""\n进度：[100%]"
}

process_directoryprocess_directory"/storage/emulated/0/Android/data/com.腾讯TMGP.DFM"进程目录进程目录"/storage/emulated/0/Android/data/com.腾讯TMGP.DFM"/storage/emulated/0/Android/data/com.腾讯TMGP.DFM""/storage/emulated/0/Android/data/com.腾讯TMGP.DFM"进程目录进程目录"进程目录进程目录"/storage/emulated/0/Android/data/com.腾讯TMGP.DFM"

# 
回声-e-e回声-e-e"回声-e-e回声-e-e"回声-E-E"\n\0"[33m以下是过滤后的文件，可能是残留日志文件：\033[0m"[33m以下是过滤后的文件，可能是残留日志文件：\0"[33m以下是过滤后的文件，可能是残留日志文件：\0-e[0m""\n\0""\n\0""\n\0""\n\0""\n\0""\n\0""\n\0""\n\0"[0m""\n\0""\n\0"[33m以下是过滤后的文件，可能是残留日志文件：\033[0m"[33m以下是过滤后的文件，可能是残留日志文件：\0-e[0m"
forfile在...内为文件${log_files[@]}${log_files[@]}"；做${log_files[@]}${log_files[@]}"; 做
回显“$file$file$file
已完成

# 
echo-e"echo-e"回声-e[33m以下是过滤后的文件夹，可能是存储日志的文件夹：\0"\n\0"[0m"\n\033[33m以下是过滤后的文件夹，可能是存储日志的文件夹：\0"-e""\n\0""-e""\n\0""\n\0""\n\0""\n\0"[0m"[33m以下是过滤后的文件夹，可能是存储日志的文件夹：\0"[33m以下是过滤后的文件夹，可能是存储日志的文件夹：\0-e[0m"[0m"-e""\n\0""\n\0"[0m"\n\033[33m以下是过滤后的文件夹，可能是存储日志的文件夹：\033[0m"[33m以下是过滤后的文件夹，可能是存储日志的文件夹：\0"[33m以下是过滤后的文件夹，可能是存储日志的文件夹：\0-e[0m"[0m"-e"
为for文件夹在...内"中的文件夹；执行为for文件夹在...内”中的文件夹；执行"文件夹文件夹"中的文件夹；执行为for文件夹在...内”中的文件夹；执行"文件夹文件夹
回声$文件夹”$文件夹$文件夹件夹"$文件夹”$文件夹$文件夹件夹"
已完成

# 
回声回声"是否确认删除这些可能是残留日志的文件和文件夹？(y/n)""是否确认删除这些可能是残留日志的文件和文件夹？(y/n)"
读取确认

如果如果[[如果如果[[如果[[
"\n\033[33m开始删除标记为残留日志的文件和文件夹...\033[0m"\n\033[33m开始删除标记为残留日志的文件和文件夹...\033[0m"
对于"${log_files[@]}${log_files[@]}"”中的文件；执行for file在……内”中的文件；执行for file在……内
如果rm-f$file$file$file"；然后
回声"回声"已删除：件$文已删除: 件已删除: 件已删除: 件已删除: 件""已删除:已删除:已删除:已删除:
其他其他
回声"回声"删除失败：件删除失败: 件删除失败: 件""删除失败:删除失败:删除失败:删除失败：件删除失败: 件删除失败: 件"删除失败:删除失败: 删除失败:删除失败：件删除失败: 件删除失败: 件"删除失败:删除失败:删除失败:
菲菲
已完成done
对于“为文件夹在…… 内"${log_folders[@]}"；做
如果rm-rf如果如果rm-rf如果如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果件夹件夹"rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf-rf如果rm-rfacturm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果件夹件夹""如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf-rf如果rm-rf F如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果r m-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果件夹件夹"如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf"如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rfF如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rF如果rm-rf m-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf m-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf m-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果"如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf m-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-r"如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf m-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf m-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果"如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf m-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf m-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果"如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果件夹件夹如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果件夹件夹如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf m-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf m-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果"如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果件夹件夹如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果rm-rf如果件夹件夹
回声回声"$文件夹件夹""已删除:件夹"已删除:件夹"
其他其他
回声"删除失败：回声"件夹""删除失败:件夹件夹"件夹"删除失败:件夹件夹"件夹"
菲菲
已完成done
echo-eecho-e"
其他
回声-回声-回声-回声-回声-回声-回声-E回声-回声-回声-回声-回声-回声-回声-回声-E"-e\necho-eecho-e"-e\necho-eecho-e"-e\necho-eecho-e""未执行删除操作.""未执行删除操作."""""""-e\necho-eecho-e"\necho-eecho-e"-e\necho-eecho-e"-e\necho-eecho-e"\necho-eecho-e"未执行删除操作.""未执行删除操作.""
Fi
