include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yaml/libyaml
    REF dist-0.2.2
    SHA512 0728c89ba43af3cdec22bccaf18c9ad7b07e13cdebed9d8919e2c62cf90bb5e23d2c746fd250320b2827dfcd9f1ce442d3bf8a3fe18b61f9a8d1d7770561e610
    HEAD_REF master
    PATCHES fix-build-error.patch
)

file(COPY "${CURRENT_PORT_DIR}/yamlConfig.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/include/config.h)

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/libyaml/copyright COPYONLY)
