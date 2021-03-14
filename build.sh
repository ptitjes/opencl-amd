prefix='amdgpu-pro-'
postfix='-ubuntu-20.04'
major='20.45'
minor='1188099'
amdver='2.4.100'
shared="opt/amdgpu-pro/lib/x86_64-linux-gnu"
shared2="opt/amdgpu/lib/x86_64-linux-gnu"
tarname="${prefix}${major}-${minor}${postfix}"

builddir="$(pwd)"
srcdir="${builddir}/source"
pkgdir="${builddir}/package"

mkdir -p "${srcdir}"
mkdir -p "${pkgdir}"

downloadSource() {
  cd "${srcdir}"

  wget --referer https://www.amd.com/en/support/kb/release-notes/rn-amdgpu-unified-linux-20-45 -N "https://drivers.amd.com/drivers/linux/$tarname.tar.xz"
  tar xf "$tarname.tar.xz"
}

package() {
	mkdir -p "${srcdir}/opencl"
	cd "${srcdir}/opencl"

	# roc*
	ar x "${srcdir}/$tarname/opencl-rocr-amdgpu-pro_${major}-${minor}_amd64.deb"
	tar xJf data.tar.xz
	ar x "${srcdir}/$tarname/rocm-device-libs-amdgpu-pro_1.0.0-${minor}_amd64.deb"
	tar xJf data.tar.xz
	ar x "${srcdir}/$tarname/hsa-runtime-rocr-amdgpu_1.2.0-${minor}_amd64.deb"
	tar xJf data.tar.xz
	ar x "${srcdir}/$tarname/hsakmt-roct-amdgpu_1.0.9-${minor}_amd64.deb"
	tar xJf data.tar.xz
	ar x "${srcdir}/$tarname/hip-rocr-amdgpu-pro_${major}-${minor}_amd64.deb"
	tar xJf data.tar.xz

	# comgr
	ar x "${srcdir}/$tarname/comgr-amdgpu-pro_1.7.0-${minor}_amd64.deb"
	tar xJf data.tar.xz

	# orca
	ar x "${srcdir}/$tarname/opencl-orca-amdgpu-pro-icd_${major}-${minor}_amd64.deb"
	tar xJf data.tar.xz

	cd ${shared}
	sed -i "s|libdrm_amdgpu|libdrm_amdgpo|g" libamdocl-orca64.so

	mkdir -p "${srcdir}/libdrm"
	cd "${srcdir}/libdrm"
	ar x "${srcdir}/$tarname/libdrm-amdgpu-amdgpu1_${amdver}-${minor}_amd64.deb"
	tar xJf data.tar.xz
	cd ${shared2}
	rm "libdrm_amdgpu.so.1"
	sed -i "s|libdrm_amdgpu|libdrm_amdgpo|g" libdrm_amdgpu.so.1.0.0
	mv "libdrm_amdgpu.so.1.0.0" "libdrm_amdgpo.so.1.0.0"
	ln -s "libdrm_amdgpo.so.1.0.0" "libdrm_amdgpo.so.1"

	mv "${srcdir}/opencl/etc" "${pkgdir}/"
	mkdir -p ${pkgdir}/usr/lib
	# roc*
	mv "${srcdir}/opencl/${shared}/libamdocl64.so" "${pkgdir}/usr/lib/"
	mv "${srcdir}/opencl/${shared}/libamd_comgr.so.1.7.0" "${pkgdir}/usr/lib"
	mv "${srcdir}/opencl/${shared}/libamdhip64.so.1.5.19245" "${pkgdir}/usr/lib"
	mv "${srcdir}/opencl/${shared}/libamdhip64.so" "${pkgdir}/usr/lib"
	mv "${srcdir}/opencl/${shared}/libamdhip64.so.1" "${pkgdir}/usr/lib"
	mv "${srcdir}/opencl/${shared}/libhsa-runtime64.so.1.2.0" "${pkgdir}/usr/lib"
	mv "${srcdir}/opencl/${shared}/libhsa-runtime64.so.1" "${pkgdir}/usr/lib"
	mv "${srcdir}/opencl/${shared2}/libhsakmt.so.1.0.6" "${pkgdir}/usr/lib"
	mv "${srcdir}/opencl/${shared2}/libhsakmt.so.1" "${pkgdir}/usr/lib"

	# comgr
	cd ${srcdir}/opencl/${shared}
	ln -s "libamd_comgr.so.1.7.0" "libamd_comgr.so"
	mv "${srcdir}/opencl/${shared}/libamd_comgr.so" "${pkgdir}/usr/lib/"
	mv "${srcdir}/opencl/${shared}/libamd_comgr.so.1" "${pkgdir}/usr/lib/libamd_comgr.so"

	# orca
	mv "${srcdir}/opencl/${shared}/libamdocl-orca64.so" "${pkgdir}/usr/lib/"
	mv "${srcdir}/opencl/${shared}/libamdocl12cl64.so" "${pkgdir}/usr/lib/"
	mv "${srcdir}/libdrm/${shared2}/libdrm_amdgpo.so.1.0.0" "${pkgdir}/usr/lib/"
	mv "${srcdir}/libdrm/${shared2}/libdrm_amdgpo.so.1" "${pkgdir}/usr/lib/"

	mkdir -p "${pkgdir}/opt/amdgpu/share/libdrm"
	cd "${pkgdir}/opt/amdgpu/share/libdrm"
	ln -s /usr/share/libdrm/amdgpu.ids amdgpu.ids
}

writeSpec() {
  cat <<EOT >> "${builddir}/opencl-amd.spec"
Name:      opencl-amd
Version:   ${major}.${minor}
Release:   3%{?dist}
BuildArch: x86_64
Summary:   OpenCL userspace driver as provided in the amdgpu-pro driver stack
URL:       http://www.amd.com
License:   custom:AMD
Requires:  libdrm,ocl-icd,libgcc,numactl-libs
Source0:   package

%description
OpenCL userspace driver as provided in the amdgpu-pro driver stack.
This package is intended to work along with the free amdgpu stack.

%install
mkdir -p %{buildroot}/%{_libdir}
cp -a %{SOURCE0}/usr/lib/* %{buildroot}/%{_libdir}

mkdir -p %{buildroot}/etc/OpenCL/vendors
cp -a %{SOURCE0}/etc/OpenCL/vendors/* %{buildroot}/etc/OpenCL/vendors

mkdir -p %{buildroot}/opt/amdgpu/share/libdrm
cd %{buildroot}/opt/amdgpu/share/libdrm
ln -s ../../../../usr/share/libdrm/amdgpu.ids amdgpu.ids

%files
/etc/OpenCL/vendors/amdocl-orca64.icd
/etc/OpenCL/vendors/amdocl64.icd
/opt/amdgpu/share/libdrm/amdgpu.ids
/%{_libdir}/libamd_comgr.so
/%{_libdir}/libamd_comgr.so.1
/%{_libdir}/libamd_comgr.so.1.7.0
/%{_libdir}/libamdhip64.so
/%{_libdir}/libamdhip64.so.1
/%{_libdir}/libamdhip64.so.1.5.19245
/%{_libdir}/libamdocl-orca64.so
/%{_libdir}/libamdocl12cl64.so
/%{_libdir}/libamdocl64.so
/%{_libdir}/libdrm_amdgpo.so.1
/%{_libdir}/libdrm_amdgpo.so.1.0.0
/%{_libdir}/libhsa-runtime64.so.1
/%{_libdir}/libhsa-runtime64.so.1.2.0
/%{_libdir}/libhsakmt.so.1
/%{_libdir}/libhsakmt.so.1.0.6

%changelog
EOT
}

cleanup() {
  rm -rf "${srcdir}"
}

downloadSource && package && writeSpec && cleanup
