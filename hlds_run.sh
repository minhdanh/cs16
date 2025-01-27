#!/usr/bin/env bash

set -axe

CONFIG_FILE="/opt/hlds/startup.cfg"

if [ -r "${CONFIG_FILE}" ]; then
    # TODO: make config save/restore mechanism more solid
    set +e
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"
    set -e
fi

EXTRA_OPTIONS=( "$@" )

EXECUTABLE="/opt/hlds/hlds_run"
GAME="${GAME:-cstrike}"
MAXPLAYERS="${MAXPLAYERS:-32}"
START_MAP="${START_MAP:-cs_mansion}"
SERVER_NAME="${SERVER_NAME:-Counter-Strike 1.6 Server}"
START_MONEY="${START_MONEY:-800}"
BUY_TIME="${BUY_TIME:-0.25}"
FRIENDLY_FIRE="${FRIENDLY_FIRE:-1}"
TIME_PER_MAP="${TIME_PER_MAP:180}"

OPTIONS=( "-game" "${GAME}" "+maxplayers" "${MAXPLAYERS}" "+map" "${START_MAP}" "+hostname" "\"${SERVER_NAME}\"" "+mp_startmoney" "${START_MONEY}" "+mp_friendlyfire" "${FRIENDLY_FIRE}" "+mp_buytime" "${BUY_TIME}" "+mp_timelimit" "${TIME_PER_MAP}")

if [ -z "${RESTART_ON_FAIL}" ]; then
    OPTIONS+=('-norestart')
fi

if [ -n "${SERVER_PASSWORD}" ]; then
    OPTIONS+=("+sv_password" "${SERVER_PASSWORD}")
fi

if [ -n "${RCON_PASSWORD}" ]; then
    OPTIONS+=("+rcon_password" "${RCON_PASSWORD}")
fi

# if [ -n "${ADMIN_STEAM}" ]; then
#     echo "\"STEAM_${ADMIN_STEAM}\" \"\"  \"abcdefghijklmnopqrstu\" \"ce\"" >> "/opt/hlds/cstrike/addons/amxmodx/configs/users.ini"
# fi

set > "${CONFIG_FILE}"

exec "${EXECUTABLE}" "${OPTIONS[@]}" "${EXTRA_OPTIONS[@]}"
