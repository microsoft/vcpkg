vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thestk/rtaudio
    REF 46b01b5b134f33d8ddc3dab76829d4b1350e0522
    SHA512 f26f64fe77aa18c9adf401a720fc3d929af8655827f2c149539a1b73736efb3757ac2eaf5a6535a3c801df13e5f49728a49b6ffe5c01c2f91ab23e145bad5355
    HEAD_REF master
    PATCHES fix-alsa.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" RTAUDIO_STATIC_MSVCRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        asio  RTAUDIO_API_ASIO
        alsa  RTAUDIO_API_ALSA
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRTAUDIO_STATIC_MSVCRT=${RTAUDIO_STATIC_MSVCRT}
        -DRTAUDIO_API_JACK=OFF
        -DRTAUDIO_API_PULSE=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
