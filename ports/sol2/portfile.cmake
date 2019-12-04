include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF v3.0.3
    SHA512 8c8f36eaedb76863106ecd24543b82c76a2fac15e86bfaf0e724b726e89d4238adf9eea8abefe0add5ee17e45b1a73ee24496f691b79c15dca85e2cfde8762b4
    HEAD_REF develop
    PATCHES fix-namespace.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sol2)

file(
    REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/debug
        ${CURRENT_PACKAGES_DIR}/lib
        ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL ${SOURCE_PATH}/single/include/sol DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
