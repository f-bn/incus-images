<p><img src="https://discuss.linuxcontainers.org/uploads/default/original/1X/9a2865f528f7b846cda54335dec298dda6109bb3.png" alt="lxc-logo" title="Linux Containers" align="top" height=85 /></p>

*Incus is a next generation system container and virtual machine manager. It offers a unified user experience around full Linux systems running inside containers or virtual machines*

### General informations

This repository contains my personal manifests to build custom Incus container and virtual machine images using Distrobuilder in my homelab. These manifests are based on [Linux Containers project manifests](https://github.com/lxc/lxc-ci/tree/master/images/) they use for their [image server](https://images.linuxcontainers.org/).

**Images**

The following images are known to work using these manifests, other distribution versions may not work.

| Distribution   | Release   | Variants  | Container | Virtual machine |
| :--------------| :---------| :---------| :---------| :---------------|
| Ubuntu         | `jammy`   | `default` | ✅        | ✅              |

#### Requirements

* Incus >= 0.3
* Distrobuilder >= 3.0
* System dependencies
  - *qemu-utils* (qemu-img) 
  - *debootstrap*
  - *btrfs-progs*
  - *rsync*

### How to build these images ?

Firstly, install `distrobuilder` using `snap` :

```shell
snap install distrobuilder --classic [--edge]
```

Then, build the image using `distrobuilder`, you have multiple options :

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

### References

* Linux Containers: https://linuxcontainers.org/ 
* Incus: https://github.com/lxc/incus
* Distrobuilder: https://github.com/lxc/distrobuilder