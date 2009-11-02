#!/bin/sh
# Filename:      core.sh
# Purpose:       core functionality for determining grml specific options.
# Authors:       grml-team (grml.org)
# Bug-Reports:   see http://grml.org/bugs/
# License:       This file is licensed under the GPL v2.
################################################################################

# {{{ variable setupt
# old linuxrc version:
[ -d /cdrom ]      && export LIVECD_PATH=/cdrom
# new initramfs layout:
[ -d /live/image ] && export LIVECD_PATH=/live/image

# zsh stuff
iszsh(){
if [ -n "$ZSH_VERSION" ] ; then
  return 0
else
  return 1
fi
}
# avoid 'no matches found: ...'
iszsh && setopt no_nomatch # || echo "Warning: not running under zsh!"
# }}}

# {{{ Read in boot parameters
if [ -z "$CMDLINE" ]; then
  # if CMDLINE was set from the outside, we're debugging.
  # otherwise, take CMDLINE from Kernel and config files.
  CMDLINE="$(cat /proc/cmdline)"
  [ -d /cdrom/bootparams/ ]      && CMDLINE="$CMDLINE $(cat /cdrom/bootparams/* | tr '\n' ' ')"
  [ -d /live/image/bootparams/ ] && CMDLINE="$CMDLINE $(cat /live/image/bootparams/* | tr '\n' ' ')"
fi
# }}}

### {{{ Utility Functions

# Get a bootoption's parameter: read boot command line and either
# echo last parameter's argument or return false.
getbootparam(){
  local line
  local ws
  ws='   '
  line=" $CMDLINE "
  case "$line" in
    *[${ws}]"$1="*)
      result="${line##*[$ws]$1=}"
      result="${result%%[$ws]*}"
      echo "$result"
      return 0 ;;
    *) # no match?
      return 1 ;;
  esac
}

# Check boot commandline for specified option
checkbootparam(){
  [ -n "$1" ] || ( echo "Error: missing argument to checkbootparam()" ; return 1 )
  local line
  local ws
  ws='   '
  line=" $CMDLINE "
  case "$line" in
    *[${ws}]"$1"=*|*[${ws}]"$1"[${ws}]*)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

# Check if currently using a framebuffer
hasfb() {
    [ -e /dev/fb0 ] && return 0 || return 1
}

# Check wheter a configuration variable (like $CONFIG_TOHD) is
# enabled or not
checkvalue(){
  case "$1" in
    [yY][eE][sS])     return 0 ;; # it's set to 'yes'
    [tT][rR][uU][eE]) return 0 ;; # it's set to 'true'
                   *) return 1 ;; # default
  esac
}

# Are we using grml-small?
checkgrmlsmall(){
  grep -q small /etc/grml_version 2>/dev/null && return 0 || return 1
}

###}}}
