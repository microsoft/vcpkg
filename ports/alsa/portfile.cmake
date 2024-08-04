message(
"alsa currently requires the following programs from the system package manager:
    autoconf autoheader aclocal automake libtoolize
On Debian and Ubuntu derivatives:
    sudo apt install autoconf libtool
On recent Red Hat and Fedora derivatives:
    sudo dnf install autoconf libtool
On Arch Linux and derivatives:
    sudo pacman -S autoconf automake libtool
On Alpine:
    apk add autoconf automake libtool"
)

vcpkg_download_distfile(ALSA_VERSION_SCRIPT_PATCH
    URLS https://github.com/alsa-project/alsa-lib/commit/2a736a0d2543f206fd2653aaae8a08a4c42eb917.diff?full_index=1
    FILENAME alsa-version-script-2a736a.patch
    SHA512 d3f2c73b8e8fbae36de43c1db6b59489a0a28c1bc7992f13f40e83f64dfcaaee2d6688b7133668f54685e2d92a2cc06ad03b2efdb40c3c1da7f020f9f0a04de7
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alsa-project/alsa-lib
    REF "v${VERSION}"
    SHA512 da9277007dd3b197fcafb748ced4ace89fdb1ab5eafae7596e91935ee9fb410be54fa76aabe86cdd83227e48cd073a7df319e90bdf06fa2da7c97470c085645d
    HEAD_REF master
    PATCHES
        fix-plugin-dir.patch
        libdl.diff
        ${ALSA_VERSION_SCRIPT_PATCH}
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ALSA_PLUGIN_DIR "/usr/lib/x86_64-linux-gnu/alsa-lib")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(ALSA_PLUGIN_DIR "/usr/lib/aarch64-linux-gnu/alsa-lib")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(ALSA_PLUGIN_DIR "/usr/lib/arm-linux-gnueabihf/alsa-lib")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "s390x")
    set(ALSA_PLUGIN_DIR "/usr/lib/s390x-linux-gnu/alsa-lib")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "ppc64le")
    set(ALSA_PLUGIN_DIR "/usr/lib/powerpc64le-linux-gnu/alsa-lib")
else()
    set(ALSA_PLUGIN_DIR "/usr/lib/alsa-lib")
endif()
set(ALSA_CONFIG_DIR "/usr/share/alsa")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${BUILD_OPTS}
        --disable-python
        "--with-configdir=${ALSA_CONFIG_DIR}"
        "--with-plugindir=${ALSA_PLUGIN_DIR}"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/tools/alsa/debug"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
