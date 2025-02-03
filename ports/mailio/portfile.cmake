vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO karastojko/mailio
    REF "${VERSION}"
    SHA512 f343ac56f4235bb4ab164630be78d1db112d5ad853dc9a41b55fee5b9755bc8215cc4a6e5d1dd65099b538d792e75d782932173533398d9e48b691a8e9f3182c
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMAILIO_BUILD_DOCUMENTATION=OFF
        -DMAILIO_BUILD_EXAMPLES=OFF
        -DMAILIO_BUILD_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
     CONFIG_PATH share/mailio/cmake
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
