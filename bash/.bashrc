#This file is executed for interactive non-login shells

if [ -n "$DISPLAY" -a "$TERM" == "xterm" ]; then
  export TERM="xterm-256color"
fi

export CLICOLOR=1
PS1='\[\e[0;33m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ '

alias ls="ls -G"
alias ll="ls -G -l -a"

function calc {
    echo "scale=6; $@" | bc
}

function is_prime {
  local n=$1
  if [ $n -eq 1 ]; then
    echo "No"
    return 0
  fi

  if [ $n -eq 2 -o $n -eq 3 -o $n -eq 5 -o $n -eq 7 ]; then
    echo "Yes"
    return 1
  fi

  if [ `expr $n % 2` -eq 0 -o `expr $n % 3` -eq 0 -o `expr $n % 5` -eq 0 -o `expr $n % 7` -eq 0 ]; then
    echo "No"
    return 0
  fi

  p=11
  while [ `expr $p \* $p` -le $n ]
  do
    if [ `expr $n % $p` -eq 0 ]; then
      echo "No"
      return 0
    fi

    p=`expr $p + 2`
  done

  echo "Yes"
  return 1
}

function next_prime {
  local n=$1
  while [ `is_prime $n` = "No" ]
  do
    n=`expr $n + 1`
  done

  echo $n
  return $n
}

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
