#!/usr/bin/env sh

# The audio-volume changer via `amixer`.
# https://github.com/owl4ce/dotfiles

export LANG='POSIX'
exec >/dev/null 2>&1
. "${HOME}/.joyfuld"

[ -x "$(command -v amixer)" ] || exec dunstify 'Install `alsa-utils`!' -r 72 -u low

[ -z "$AUDIO_DEVICE" ] || ARGS="-D ${AUDIO_DEVICE}"

case "${1}" in
    +) amixer ${ARGS} sset Master "${AUDIO_VOLUME_STEPS:-5}%+" on -q
    ;;
    -) amixer ${ARGS} sset Master "${AUDIO_VOLUME_STEPS:-5}%-" on -q
    ;;
    0) amixer ${ARGS} sset Master 1+ toggle -q
    ;;
esac

AUDIO_VOLUME="$(amixer ${ARGS} sget Master)"
AUDIO_MUTED="${AUDIO_VOLUME##*\ \[on\]}"
AUDIO_VOLUME="${AUDIO_VOLUME#*\ \[}" \
AUDIO_VOLUME="${AUDIO_VOLUME%%\]\ *}"

if [ "${AUDIO_VOLUME%%%}" -eq 0 -o -n "$AUDIO_MUTED" ]; then
    [ -z "$AUDIO_MUTED" ] || MUTED='Muted'
    ICON='notification-audio-volume-muted'
elif [ "${AUDIO_VOLUME%%%}" -lt 30 ]; then
    ICON='notification-audio-volume-low'
elif [ "${AUDIO_VOLUME%%%}" -lt 70 ]; then
    ICON='notification-audio-volume-medium'
else
    ICON='notification-audio-volume-high'
fi

exec dunstify ${MUTED:-"${AUDIO_VOLUME%%%}" -h "int:value:${AUDIO_VOLUME%%%}"} -i "$ICON" -r 72 -t 1000

exit ${?}