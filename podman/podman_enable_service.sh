#!/bin/sh
set -eu

if [ "$#" -gt 1 ]; then
  echo "Usage: $0 [service-name]" >&2
  exit 1
fi

service_name="${1:-podman-compose-ggrna}"
case "$service_name" in
  *.service) ;;
  *) service_name="${service_name}.service" ;;
esac

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
compose_file="${script_dir}/podman-compose.yml"
service_dir="${HOME}/.config/systemd/user"
service_file="${service_dir}/${service_name}"
podman_path=$(command -v podman)
podman_compose_path=$(command -v podman-compose)

if [ ! -f "$compose_file" ]; then
  echo "podman-compose.yml not found: $compose_file" >&2
  exit 1
fi

mkdir -p "$service_dir"

cat > "$service_file" <<EOF_SERVICE
[Unit]
Description=Podman Compose ${service_name%.service}
Wants=network-online.target
After=network-online.target
StartLimitIntervalSec=300
StartLimitBurst=20

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=${script_dir}
ExecStartPre=/bin/sh -c 'for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do ${podman_path} info >/dev/null 2>&1 && exit 0; sleep 2; done; exit 1'
ExecStart=${podman_compose_path} --in-pod false up -d
ExecStop=${podman_compose_path} --in-pod false down
TimeoutStartSec=0
Restart=on-failure
RestartSec=15s

[Install]
WantedBy=default.target
EOF_SERVICE

systemctl --user daemon-reload
systemctl --user enable --now "$service_name"

if command -v loginctl >/dev/null 2>&1; then
  if ! loginctl show-user "$USER" -p Linger 2>/dev/null | grep -q '^Linger=yes$'; then
    if loginctl enable-linger "$USER" 2>/dev/null; then
      echo "Enabled lingering for ${USER}; the user service can start after OS boot without an interactive login."
    else
      echo "Warning: lingering is not enabled for ${USER}." >&2
      echo "Run this once if the service must start before login: loginctl enable-linger ${USER}" >&2
    fi
  fi
fi

systemctl --user status "$service_name" --no-pager
