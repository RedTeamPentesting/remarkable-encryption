# Enabling cloud sync with cryptodaemon

Warning: files are only encrypted on the local device and at rest on the
reMarkable Cloud. If you wish to use cloud sync with cryptodaemon, then ennsure
this suits your use case and threat model.

## Setup

* Ensure `xochitl.service` and `sync.service` are masked.
* Copy `sync-crypto.service` to `/etc/systemd/system`.
  * e.g. `scp contrib/sync/sync-crypto.service root@remarkable.local:/etc/systemd/system/`
* Add `Wants=sync-crypto.service` to `/etc/systemd/system/cryptodaemon.service`
* `systemctl daemon-reload`
* `systemctl enable sync-crypto --now`
