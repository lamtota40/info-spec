#!/bin/bash

if (( $EUID != 0 )); then
    echo "Please run as root"
    echo "You can Try comand 'su root' or 'sudo -i' or 'sudo -'"
    exit 1
fi

clear
tuser="0"
Tssh=$(cat /etc/shadow | cut -d: -f1,8 | sed /:$/d | wc -l)
gmt_info=$(timedatectl | grep "Time zone" | awk -F"[()]" '{print $2}' | awk '{print $2}')
hddinfo=$(df -h --total | grep total)
cpuinfo=$(cat /proc/cpuinfo | grep MHz | awk '{print int($4 + 0.5)}' | sort | uniq -c | awk '{printf "%dx %.1fGHz,", $1, $2/1000}' | sed 's/,$//')
cpuuse=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F. '{print $1}')
raminfo=$(free -m | grep Mem)
ram_total=$(awk '{print $2}' <<< "$raminfo")
ram_usage=$(($(awk '{print $2}' <<< "$raminfo") - $(awk '{print $4}' <<< "$raminfo")))
swapinfo=$(free -m | grep Swap)
swap_total=$(awk '{print $2}' <<< "$swapinfo")
swap_usage=$(awk '{print $3}' <<< "$swapinfo")
if [ "$swap_usage" -eq "0" ]; then
swap_percent="0";
else
swap_percent=$(($swap_usage * 100 / $swap_total));
fi
hdd_usage=$(awk '{print $3}' <<< "$hddinfo")
hdd_total=$(awk '{print $2}' <<< "$hddinfo")
cekip=$(curl -s "http://ip-api.com/json/")
OS_NAME=$(lsb_release -si)
OS_VERSION=$(lsb_release -sr)
OS_CODENAME=$(lsb_release -sc)
ARCHITECTURE=$(uname -m)
prosesor_info=$(cat /proc/cpuinfo | grep 'vendor_id' | uniq)
if [[ $prosesor_info == *"GenuineIntel"* ]]; then
    pinfo="INTEL"
elif [[ $prosesor_info == *"AuthenticAMD"* ]]; then
    pinfo= "AMD"
else
    pinfo="UNKNOWN"
fi

echo -e "╒══════════════════════════════════════════════════╕"
echo -e "                    INFO SERVER                   "
echo -e "╘══════════════════════════════════════════════════╛"
echo -e "Time	 : `date "+%H:%M"` | `date "+%d/%m/%y"` | GMT $gmt_info"
echo -e "Uptime	 : `uptime -p`"
echo -e "OS       : $OS_NAME | $OS_VERSION $OS_CODENAME | $ARCHITECTURE"
echo -e "IP Public : $(jq -r '.query' <<< "$cekip")"
echo -e "ISP	 : $(jq -r '.isp' <<< "$cekip") | $(jq -r '.country' <<< "$cekip")"
echo -e "CPU Speed: $cpuinfo"
echo -e "CPU Info : Usage = $cpuuse% | $pinfo | $(systemd-detect-virt)"
echo -e "RAM	 : Usage = $ram_usage Mb ($(($ram_usage * 100 / $ram_total))%) | Total = $ram_total Mb"
echo -e "SWAP RAM : Usage = $swap_usage Mb ($swap_percent%) | Total = $swap_total Mb"
echo -e "HDD      : Usage = $hdd_usage ($(awk '{print $5}' <<< "$hddinfo")) | Total = $hdd_total"
echo -e "┌──────────────────────────────────────────────────┐"
