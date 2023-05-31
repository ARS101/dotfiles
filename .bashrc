# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

PS1='\[\033[48;2;105;121;16;38;2;255;255;255m\] \u \[\033[48;2;0;135;175;38;2;105;121;16m\]\[\033[48;2;0;135;175;38;2;255;255;255m\] \h \[\033[48;2;83;85;85;38;2;0;135;175m\]\[\033[48;2;83;85;85;38;2;255;255;255m\] \w \[\033[49;38;2;83;85;85m\]\[\033[00m\] '

# Put your fun stuff here.
alias ls='ls --color=auto'
alias grep='grep --colour=auto'
# Enable color for "ls" and "grep" commands.

alias rm='trash'
# Trashing files instead of permanently deleting them.

alias cp="cp -i"
# confirm before overwriting something

alias df='df -h'
# human-readable sizes

alias free='free -m'
# show sizes in MB

alias powersave="sudo cpupower frequency-set -u 1.1GHz"
# Setting low cpu frequency
alias powernormal="sudo cpupower frequency-set -u 3.8GHz"
# Setting balanced cpu frequency
alias powermax="sudo cpupower frequency-set -u 4.5GHz"
# Setting maximum cpu frequency

alias nvon="sudo sh -c 'echo 0 > /sys/devices/platform/asus-nb-wmi/dgpu_disable'"
# Turn on NVIDIA dgpu after reboot
alias nvoff="sudo sh -c 'echo 1 > /sys/devices/platform/asus-nb-wmi/dgpu_disable'"
# Turn off NVIDIA dgpu after reboot

alias hyperfan-turbo="sudo sh -c 'echo 1 > /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy'"
# Set ASUS Hyperfan profile to Turbo (Max fan speed)
alias hyperfan-performance="sudo sh -c 'echo 0 > /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy'"
# Set ASUS Hyperfan profile to Performance (Normal fan speed)
alias hyperfan-silent="sudo sh -c 'echo 2 > /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy'"
# Set ASUS Hyperfan profile to Silent (Minimum fan speed)

alias kexec-reboot="sudo sh -c 'kexec -l /boot/vmlinuz-$(uname -r) --initrd=/boot/initramfs-$(uname -r).img --reuse-cmdline && reboot'"
# Fast Kernel reboot

export RANGER_LOAD_DEFAULT_RC=false
export EDITOR=nvim
export PATH="$HOME/.local/bin:$PATH"
