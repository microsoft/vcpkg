vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thestk/rtaudio
    REF ${VERSION}
    SHA512 085feb2673185460717ba45fc87254961e477823759e11281092c1ba13301303de1cd36aa9efeba0710cbf2c70f2e2f7f9e41173cf372ded528c41612b19acd5
    HEAD_REF master
    PATCHES
        fix-pulse.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" RTAUDIO_STATIC_MSVCRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        asio  RTAUDIO_API_ASIO
        alsa  RTAUDIO_API_ALSA
        pulse RTAUDIO_API_PULSE
)
set(PKG_OPT "")
if("pulse" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PKGCONFIG)
    set(PKG_OPT "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRTAUDIO_STATIC_MSVCRT=${RTAUDIO_STATIC_MSVCRT}
        -DRTAUDIO_API_JACK=OFF
        ${FEATURE_OPTIONS}
        ${PKG_OPT}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
