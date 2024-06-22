#!/bin/sh
notify()
{
    case $1 in 
        charging)
            if  [[ $lstate -ne 3 ]]
            then
                echo 3 > /tmp/batstate 
                pop_report -d 800 -m "<span>Charging</span><font size=\"-1\"> ﮣ</font>$icon" -t battery_charging -o "font-size: 70px" "font-family: Iosevka Curly" "padding-right: 30px"
            fi;       
        ;;
        high)
            echo 2 > /tmp/batstate
        ;;
        mid)
            if  [[ $lstate -gt 1 ]] 
            then
                echo 1 > /tmp/batstate
                dunstify "Warning: $bat_level% Battery left" -i "${HOME}/.config/rice_assets/Icons/battery_mid.png" -t 10000 --replace=550 -u critical
            fi;
        ;;
        low)
            if [[ $lstate -gt 0 ]] 
            then 
                echo 0 > /tmp/batstate
                pop_report -m "Battery is critically low" -d 5000 -t battery_low
            fi;
        ;;
    esac
}

# Set necessary info
eww="eww -c $HOME/.config/eww/"
lstate=`cat /tmp/batstate`
acpi=`acpi -b`
bat_level_all=`echo "$acpi" | grep -v "unavailable" | grep -E -o "[0-9][0-9]?[0-9]?%"`
bat_level=`echo "$bat_level_all" | awk -F"%" 'BEGIN{tot=0;i=0} {i++; tot+=$1} END{printf("%d%%\n", tot/i)}'`
bat_level=`printf ${bat_level%?}`
discharging=`echo "$acpi" | grep -w 0: | grep -c Discharging`
time=`echo "$acpi" | awk '{printf $5}'`
time=${time::-3}

if [[ $discharging -eq 0 ]] 
then
    notify charging > /dev/null
    $eww update battery_image="images/battery_charging.png"
else
    if [[ $bat_level -le 10 ]]
    then
        $eww update battery_image="images/battery_10.png"
        notify low > /dev/null
    elif [[ $bat_level -le 20 ]]
    then
        $eww update battery_image="images/battery_20.png"
        notify mid > /dev/null
    elif [[ $bat_level -le 30 ]]
    then
        $eww update battery_image="images/battery_30.png"
        notify high > /dev/null
    elif [[ $bat_level -le 40 ]]
    then
        $eww update battery_image="images/battery_40.png"
        notify high > /dev/null
    elif [[ $bat_level -le 50 ]]
    then
        $eww update battery_image="images/battery_50.png"
        notify high > /dev/null
    elif [[ $bat_level -le 60 ]]
    then
        $eww update battery_image="images/battery_60.png"
        notify high > /dev/null
    elif [[ $bat_level -le 70 ]]
    then
        $eww update battery_image="images/battery_70.png"
        notify high > /dev/null
    elif [[ $bat_level -le 80 ]]
    then
        $eww update battery_image="images/battery_80.png"
        notify high > /dev/null
    elif [[ $bat_level -le 90 ]]
    then
        $eww update battery_image="images/battery_90.png"
        notify high > /dev/null
    else
        $eww update battery_image="images/battery_100.png"
        notify high > /dev/null
    fi;
fi;

case $1 in
    "--time")
        [[ $time != "" && $time != "discharg" ]] && echo "$time" || echo "00:00"
        ;;
    "--percentage")
        echo "$bat_level" 
        ;;
    *)
        true
        ;;
esac
