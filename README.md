# Why ?

Following in the footsteps of arch people (thanks a lot to the maintainers of the opencl-amd AUR package!),
I wrapped the OpenCL part of the debian packages of AMDGPU-PRO 20.45 for Ubuntu 20.04.1
in a RPM for Fedora 33.

The rational here is that Ubuntu 20.04.1 has more recent kernels than CentOS 8.

Used in addition with https://github.com/h33p/resolve-amdocl-fix, I now have a fully functionnal DaVinci Resolve 16.2.7 (even the Fairlight page!).

# Build package

```sh
./build.sh
fedpkg --release f33 local
```

# Install package

Due to my not full understanding to RPM packages, the currently generated package tries to pull additional dependencies that are not necessary.
Hence, it is important to use `rpm` directly and add the `--nodeps` flags.

```sh
sudo rpm -Uvh --nodeps ./x86_64/opencl-amd-20.45.1164792-3.fc33.x86_64.rpm
```

# Notes to self

Packages that are installed by `./amdgpu-pro-install --opencl=rocr --headless --no-dkms`:

```
amdgpu-pro-core.noarch                             20.45-1164792.el8                      @amdgpu-pro
clinfo-amdgpu-pro.x86_64                           20.45-1164792.el8                      @amdgpu-pro
comgr-amdgpu-pro.x86_64                            1.7.0-1164792.el8                      @amdgpu-pro
hip-rocr-amdgpu-pro.x86_64                         20.45-1164792.el8                      @amdgpu-pro
hsa-runtime-rocr-amdgpu.x86_64                     1.2.0-1164792.el8                      @amdgpu-pro
hsakmt-roct-amdgpu.x86_64                          1.0.9-1164792.el8                      @amdgpu-pro
libdrm-amdgpu.x86_64                               1:2.4.100-1164792.el8                  @amdgpu-pro
libdrm-amdgpu-common.noarch                        1.0.0-1164792.el8                      @amdgpu-pro
ocl-icd-amdgpu-pro.x86_64                          20.45-1164792.el8                      @amdgpu-pro
opencl-rocr-amdgpu-pro.x86_64                      20.45-1164792.el8                      @amdgpu-pro
```
