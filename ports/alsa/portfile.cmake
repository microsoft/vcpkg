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

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alsa-project/alsa-lib
    REF "v${VERSION}"
    SHA512 ae21380c75ab2f318b14d42b1f06e35d2a80b377fe0a12177e7f5c926b189bb242037891e3e7d780d77376e57d6f074abe5701eecd55035ff0498bdbca55e42a
    HEAD_REF master
    PATCHES
        fix-plugin-dir.patch
        libdl.diff
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
