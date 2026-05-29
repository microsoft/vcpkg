vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coveooss/hareflow
    REF "v${VERSION}"
    SHA512 c66bdbbe457960c9f493039f39d1aeade33917daf5238a6707e667b40831e10d65c394eb81d854550d896f662e9d0d1bd31ac2935c533e5ec2eda58b5e5b6482
    HEAD_REF main
)

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    set(rpath "@loader_path")
else()
    set(rpath "\$ORIGIN")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_INSTALL_RPATH=${rpath}"
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
