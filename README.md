<p><img src="https://discuss.linuxcontainers.org/uploads/default/original/1X/9a2865f528f7b846cda54335dec298dda6109bb3.png" alt="lxc-logo" title="Linux Containers" align="top" height=85 /></p>

*Incus is a next generation system container and virtual machine manager. It offers a unified user experience around full Linux systems running inside containers or virtual machines*

### General informations

This repository contains my personal manifests to build custom Incus container and virtual machine images using Distrobuilder in my homelab. These manifests are based on [Linux Containers project manifests](https://github.com/lxc/lxc-ci/tree/master/images/) they use for their [image server](https://images.linuxcontainers.org/).

**Images**

The following images are known to work using these manifests, other distribution versions may not work.

| Distribution   | Release   | Variants  | Container | Virtual machine |
| :--------------| :---------| :---------| :---------| :---------------|
| Ubuntu         | `noble`   | `default` | ✅        | ✅              |
| Ubuntu         | `jammy`   | `default` | ✅        | ✅              |
| Talos Linux    | -         | `default` | ❌        | ✅              |

#### Requirements

* Incus >= 6.0
* Distrobuilder >= 3.0 (`edge` version is recommended)
* System dependencies
  - `qemu-img`
  - `debootstrap`
  - `btrfs-progs`
  - `rsync`
  - `tar`
  - `xz`

### How to build these images ?

Firstly, install `distrobuilder`:

```shell
$ snap install distrobuilder --classic [--edge]
```

If you don't want to use snap, I also have created an [OCI image](https://github.com/f-bn/containers-images/tree/main/distrobuilder) for running Distrobuilder inside a container (Docker or **rootful** Podman):

```shell
$ docker pull ghcr.io/f-bn/distrobuilder:edge
$ alias distrobuilder="docker run -ti --rm --net=host --privileged -v $PWD:/build --tmpfs /var/cache:rw,exec,dev ghcr.io/f-bn/distrobuilder:edge"
```

*Note: above system packages requirements doesn't apply when using distrobuilder in a container as everything is bundled in the image*

Once distrobuilder is installed, you can build the image:

* **Container image**

  ```shell
  distrobuilder build-incus ubuntu.yml [options]
  ```

* **Virtual machine image**

  You need to add a `--vm` flag in order to build a virtual machine image :

  ```shell
  distrobuilder build-incus ubuntu.yml --vm [options]
  ```

* **Choose a distribution release version**

  ```shell
  # Ubuntu
  distrobuilder build-incus ubuntu.yml -o image.release=jammy [options]
  ```

* **Use a tmpfs for build cache**

  It can be interesting to use a tmpfs to speed up the build and preserve SSDs if a lot of image builds are planned :

  ```shell
  mkdir -p /var/cache/distrobuilder/build
  mount -t tmpfs -o rw,size=4G,uid=0,gid=0,mode=1755 tmpfs /var/cache/distrobuilder/build
  ```

  Build the image by specifying the tmpfs cache directory :

  ```shell
  distrobuilder build-incus ubuntu.yml --cache-dir=/var/cache/distrobuilder/build
  ```

### How to build a Talos Linux image ?

In order to build an Incus-compatible [Talos Linux](https://www.talos.dev/) image (unified tarball format), a script is available to automate the build steps from official Talos Linux `nocloud` raw images.

```shell
$ ./bin/build-talos-image.sh
* Downloading Talos Linux image (1.8.1)...
* Extracting image...
* Convert image to QCOW2 format...
    (100.00/100%)
* Create Incus unified tarball...
* Cleaning up...
```

You can also specify the Talos Linux version (using GitHub tag):

```shell
$ ./bin/build-talos-image.sh v1.9.0-alpha.0
```

Once the build is done, you can find a `talos-<version>.tar.zst` archive in the `output/` directory that you can import into Incus:
```shell
$ ls -lh output/
total 99M
-rw-r--r-- 1 f-bn f-bn 99M Oct 21 15:50 talos-v1.8.1.tar.zst

$ incus image import output/talos-v1.8.1.tar.zst --alias talos/1.8.1
$ incus image info talos/1.8.1
Fingerprint: <fingerpint>
Size: 98.32MiB
Architecture: x86_64
Type: virtual-machine
Public: no
Timestamps:
    Created: 2024/10/21 01:51 UTC
    Uploaded: 2024/10/21 01:51 UTC
    Expires: never
    Last used: 0001/01/01 00:00 UTC
Properties:
    description: Talos Linux 1.8.1
    os: Talos Linux
    release: 1.8.1
Aliases:
    - talos/1.8.1
Cached: no
Auto update: disabled
Profiles:
    - default
$ incus launch talos/1.8.1 v1 --vm -c security.secureboot=false --console
...
EFI stub: Loaded initrd from LINUX_EFI_INITRD_MEDIA_GUID device path
[    0.000000] Linux version 6.6.54-talos (@buildkitsandbox) (gcc (GCC) 13.3.0, GNU ld (GNU Binutils) 2.43.1) #1 SMP Mon Oct  7 18:53:44 UTC 2024
[    0.000000] Command line: BOOT_IMAGE=/A/vmlinuz talos.platform=nocloud console=tty1 console=ttyS0 net.ifnames=0 init_on_alloc=1 slab_nomerge pti=on consoleblank=0 nvme_core.io_timeout=4294967295 printk.devkmsg=on ima_templat
e=ima-ng ima_appraise=fix ima_hash=sha512
```


### References

* Linux Containers: https://linuxcontainers.org/ 
* Incus: https://github.com/lxc/incus
* Distrobuilder: https://github.com/lxc/distrobuilder
* Talos Linux: https://www.talos.dev/