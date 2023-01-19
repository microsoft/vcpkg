vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pipewire/pipewire
    REF ${VERSION}
    SHA512 94d23a3660f76624abc18a1716519b4d18258a0a4c3047438df231f813df760f21f65b80c174f34b4de111da28b49ae3a46de961637e89828d67ecf614b17ba2
    HEAD_REF master # branch name
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dalsa=disabled
        -Daudioconvert=disabled
        -Daudiomixer=disabled
        -Daudiotestsrc=disabled
        -Davahi=disabled
        -Dbluez5-backend-hfp-native=disabled
        -Dbluez5-backend-hsp-native=disabled
        -Dbluez5-backend-hsphfpd=disabled
        -Dbluez5-backend-ofono=disabled
        -Dbluez5-codec-aac=disabled
        -Dbluez5-codec-aptx=disabled
        -Dbluez5-codec-lc3plus=disabled
        -Dbluez5-codec-ldac=disabled
        -Dbluez5=disabled
        -Dcontrol=disabled
        -Ddbus=disabled
        -Ddocs=disabled
        -Decho-cancel-webrtc=disabled
        -Devl=disabled
        -Dexamples=disabled
        -Dffmpeg=disabled
        -Dgstreamer-device-provider=disabled
        -Dgstreamer=disabled
        -Dinstalled_tests=disabled
        -Djack-devel=false
        -Djack=disabled
        -Dlegacy-rtkit=false
        -Dlibcamera=disabled
        -Dlibcanberra=disabled
        -Dlibpulse=disabled
        -Dlibusb=disabled
        -Dlv2=disabled
        -Dman=disabled
        -Dpipewire-alsa=disabled
        -Dpipewire-jack=disabled
        -Dpipewire-v4l2=disabled
        -Dpw-cat=disabled
        -Draop=disabled
        -Droc=disabled
        -Dsdl2=disabled
        -Dsndfile=disabled
        -Dspa-plugins=enabled # This one must be enabled or the resulting build won't be able to connect to pipewire daemon
        -Dsupport=enabled # This one must be enabled or the resulting build won't be able to connect to pipewire daemon
        -Dsystemd-system-service=disabled
        -Dsystemd-system-unit-dir=disabled
        -Dsystemd-user-service=disabled
        -Dsystemd-user-unit-dir=disabled
        -Dsystemd=disabled
        -Dtest=disabled
        -Dtests=disabled
        -Dudev=disabled
        -Dudevrulesdir=disabled
        -Dv4l2=disabled
        -Dvideoconvert=disabled
        -Dvideotestsrc=disabled
        -Dvolume=disabled
        -Dvulkan=disabled
        -Dx11-xfixes=disabled
        -Dx11=disabled
        -Dsession-managers=[]
)
vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# remove absolute paths
file(GLOB config_files "${CURRENT_PACKAGES_DIR}/share/${PORT}/*.conf")
foreach(file ${config_files})
    vcpkg_replace_string("${file}" "in ${CURRENT_PACKAGES_DIR}/etc/pipewire for system-wide changes\n# or" "")
    cmake_path(GET file FILENAME filename)
    vcpkg_replace_string("${file}" "# ${CURRENT_PACKAGES_DIR}/etc/pipewire/${filename}.d/ for system-wide changes or in" "")
endforeach()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/pipewire/pipewire.conf" "${CURRENT_PACKAGES_DIR}/bin" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/pipewire/minimal.conf" "${CURRENT_PACKAGES_DIR}/bin" "")
