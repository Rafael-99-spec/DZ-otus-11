#!/bin/bash

Time () {

      utime=$(cat /proc/$1/stat | awk '{print $14}')
      ctime=$(cat /proc/$1/stat | awk '{print $15}')
      tik=$(getconf CLK_TCK)
      let "times=($utime+$ctime)/100"
      echo $times
}

State () {
      state=$(cat /proc/$1/stat | awk '{print $3}')
      echo $state
}


Command () {
      cmd_line=$(cat /proc/$1/cmdline | xargs -0 echo)
      if [[ -z $cmd_line ]]; then
         comm="["$(cat /proc/$1/comm)"]"
       else
         comm=$(cat /proc/$1/cmdline | xargs -0 echo)
       fi
       echo $comm
}

TTY () {
    tty1=$(ls -l /proc/$pid/fd | grep -e "tty\|pts" |  awk '{print $11}' | cut -c 6-)
    if [[ -n $tty1 ]]; then
        tty=$(ls -l /proc/$pid/fd | grep -e "tty\|pts" |  awk '{print $11}' | cut -c 6- | head -n 1)
    else
        tty="?"
    fi
       echo $tty
}

cat /dev/null > .psinfo.ps
printf "%s %9s %6s %7s %-2s %1s\n" PID TTY STAT TIME COMMAND
pid_array=($(ls /proc | grep -E '^[0-9]+$'))

  for  pid in ${pid_array[@]}; do
   if [ -r /proc/$pid/stat ]; then
      pc_time=$(Time $pid)
      state=$(State $pid)
      cmd_command=$(Command $pid)
      tty=$(TTY $pid)
      n_pid=$(echo -n "$pid" | wc -c)
      let "l=10-$n_pid"
      #echo "$pid    $tty      $state     $pc_time     $cmd_command"
      printf "%s %"$l"s %5s %10s %1s %1s\n" $pid $tty $state $pc_time "${cmd_command}" >> .psinfo.ps
      #printf "%s %5s\n" $pid $tty $state $pc_time $cmd_command 
#>> .psinfo.ps
   fi
  done
 
cat .psinfo.ps | sort -n -k1
