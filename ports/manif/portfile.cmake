#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO artivis/manif
    REF "${VERSION}"
    SHA512 ab74e6c67641a9bb33bf779fb70d4f79d0758840f28750448c0a26714cd3941376f128cd3936d7329f9c74becc18440fca2a1ff52759f99019fb430287a3a52f
    HEAD_REF devel
    PATCHES
        0001-support-eigen3-5.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/manif/cmake)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
