# Post-Installation Guide — mido postmarketOS

## First Boot

After flashing, the device will boot to the chosen UI. First boot takes ~60–90 seconds.

Connect USB cable and wait for the USB network interface to appear on your host.

## SSH Access

```bash
ssh pmos@172.16.42.1
# Password: pmos1234
```

> Change the password immediately after first login: `passwd`

## Update the system

```bash
sudo apk update && sudo apk upgrade
```

---

## Container Support

### Podman (recommended on pmOS)

```bash
sudo apk add podman
sudo modprobe overlay          # usually automatic
sudo podman run --rm hello-world
```

### Docker

```bash
sudo apk add docker
sudo rc-update add docker default
sudo service docker start
sudo docker run --rm hello-world
```

---

## Developer Setup

### Flutter

The developer image (`phosh_dev_sparse.img`) includes Flutter pre-installed.

```bash
flutter doctor
flutter create myapp && cd myapp && flutter run
```

### Frappe / Bench

```bash
sudo apk add mariadb redis nodejs npm yarn python3 py3-pip
pip3 install frappe-bench
bench init frappe-bench --frappe-branch version-15
```

### VS Code (VSCodium)

VSCodium is pre-installed in the dev image. Launch from the application menu or:

```bash
codium &
```

---

## Tips

- **Performance:** Disable animations in GNOME/Phosh settings → Accessibility
- **RAM:** The mainline kernel uses cgroups v2; all container runtimes should work
- **Screen always on:** `gsettings set org.gnome.desktop.session idle-delay 0`
- **Wi-Fi:** Use `nmcli` or the network applet in the shell
