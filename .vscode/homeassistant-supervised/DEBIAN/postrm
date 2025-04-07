#!/usr/bin/env bash
set -e
function info { echo -e "\e[32m[info] $*\e[39m"; }
function warn  { echo -e "\e[33m[warn] $*\e[39m"; }
function error { echo -e "\e[31m[error] $*\e[39m"; exit 1; }


# Undo diversions
function undo_divert () {
  dpkg-divert --package homeassistant-supervised --remove --rename \
    --divert /etc/NetworkManager/NetworkManager.conf.real /etc/NetworkManager/NetworkManager.conf

  dpkg-divert --package homeassistant-supervised --remove --rename \
    --divert /etc/NetworkManager/system-connections/default.real /etc/NetworkManager/system-connections/default

  dpkg-divert --package homeassistant-supervised --remove --rename \
    --divert /etc/docker/daemon.json.real /etc/docker/daemon.json

  dpkg-divert --package homeassistant-supervised --remove --rename \
    --divert /etc/network/interfaces.real /etc/network/interfaces
}

function reset_debconf_selections () {
  info "Resetting debconf selections"
  echo PURGE | debconf-communicate homeassistant-supervised >/dev/null
}

case "$1" in
remove|abort-install|disappear)
	  info Undo divert on "$@"
          undo_divert
          reset_debconf_selections
          info "Removal complete, due to the complexity of this installation method,"
          info "you will need to manually remove the containers created by the supervisor"
        ;;
esac
