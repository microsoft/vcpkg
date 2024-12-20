vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orange-cpp/omath
    REF "v${VERSION}"
    SHA512 467b1abbdf5b9a7f49ed50824eaa4641f05d6088e84f40320b5c82a1bdbf685cc8d0f0a4f4ab6be49e3a8ed13103ee3e808dde3b556a00742f7b53c519c183e3
    HEAD_REF master
)

file(READ "${SOURCE_PATH}/cmake/omathConfig.cmake.in" cmake_config)

file(WRITE "${SOURCE_PATH}/cmake/omathConfig.cmake.in"
"${cmake_config}
check_required_components(omath)
")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOMATH_BUILD_TESTS=OFF
        -DOMATH_THREAT_WARNING_AS_ERROR=OFF
        -DOMATH_BUILD_AS_SHARED_LIBRARY=${BUILD_SHARED_LIBS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/omath" PACKAGE_NAME "omath")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
