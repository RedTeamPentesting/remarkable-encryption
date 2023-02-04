# Remarkable 2 Encryption

This repository contains multiple tools to encrypt the home folder of the
reMarkable 2 epaper tablet using
[`gocryptfs`](https://github.com/rfjakob/gocryptfs). Detailed background
information can be found in the accompanying [blog
post](https://blog.redteam-pentesting.de/2021/remarkable-encryption/).

# Disclaimer

This project is considered experimental and it cannot be guaranteed that the
device will not be bricked as a result of this setup. The project and the
toolchain in this repository were tested on the reMarkable 2 firmware version
`2.13.0.689`. If a different firmware version is used, the commit hash
(`FRAMEBUFFER_COMMIT`) in the `Makefile` has to be updated to a
[remarkable2-framebuffer](https://github.com/ddvk/remarkable2-framebuffer)
commit that supports the chosen firmware version. Otherwise, the toolchain
likely produces a crashing passphrase prompt application. In this case, the
device can be unlocked by providing the passphrase via USB network connection:

```bash
# the actual IP addres may differ
echo 'yourpassphrase' | nc 10.11.99.1 1234
```

# Build

This project is meant to be build using the [toltec v2.x
toolchain](https://github.com/toltec-dev/toolchain/tree/v2.x). However, as this
project contains Qt and Go builds, no single `toltec` Docker image can compile
the whole project. Instead, this project contains a `Dockerfile` which is based
on the `toltec` Qt `Dockerfile` and adds Go 1.16, `git` and `wget`.

```bash
docker build -t remarkable-crypto-toolchain .
docker run --rm -it -u $(id -u):$(id -g) -v $(pwd):/project remarkable-crypto-toolchain make
```

Alternatively, the components of this project can be built separately with the
official `toltec` Docker images and the corresponding `Makefile` targets
(`dist_go` with the `golang` image, `dist_qt` with the `qt` image and
`dist_rest` in any environment with `wget`, `ar`, `tar` and `sha256sum`
installed).

# Deployment

After building the project, the directory structure has to be created on the
reMarkable 2:

```bash
# on reMarkable 2
mkdir -p /home/crypto/bin /home/crypto/fs /home/crypto/lib
```

The contents of the `dist` folder are replicated on the reMarkable:

```bash
# on build system
scp dist/home/crypto/bin/* remarkable:/home/crypto/bin/
scp dist/home/crypto/lib/* remarkable:/home/crypto/lib/
scp dist/etc/systemd/system/cryptodaemon.service remarkable:/etc/systemd/system/
scp dist/etc/systemd/system/framebufferserver.service remarkable:/etc/systemd/system/
```

The setup can then be completed on the reMarkable:

```bash
# on reMarkable 2
chmod u+x /home/crypto/bin/*
PATH=/home/crypto/bin gocryptfs -init /home/crypto/fs
systemctl daemon-reload

# WARNING: after the next step, xochitl (on plaintext home directory)
# won't start by default anymore
systemctl mask xochitl --now

# after this step the screen will become blank
systemctl enable framebufferserver --now

# WARNING: After entering the password, xochitl will start with the
# encrypted filesystem which is still empty. This means that the
# device setup starts again and A NEW SSH PASSPHRASE IS SET.
systemctl enable cryptodaemon --now
```

# Contributions

We are happy to receive contributions in the form of issues or pull requests.
However, the scope of this project remains limited to our usecase. This means
that only new features that suit this usecase are added. For different needs
or if your threat model differs, feel free to fork this project.
