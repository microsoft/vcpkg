include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fribidi/fribidi
    REF v1.0.5
    SHA512 c51b67cc3e7610bef9a66f2456f7602fe010164c2c01e7d91026cefa4a08fdce5165b6eb3814e76cd89e766356fb71adc08bf75d9b2f5802f71c18b5d0476887
HEAD_REF master)

vcpkg_configure_meson(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Ddocs=false
        --backend=ninja)

vcpkg_install_meson()
vcpkg_copy_pdbs()

file(GLOB EXE_FILES
    "${CURRENT_PACKAGES_DIR}/bin/*.exe"
    "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe"
)
if (EXE_FILES)
    file(REMOVE ${EXE_FILES})
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/fribidi RENAME copyright)