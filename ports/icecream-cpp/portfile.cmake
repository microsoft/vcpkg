vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO renatoGarcia/icecream-cpp
    REF "v${VERSION}"
    SHA512 57410045b5dce11da3bba423347a0b7e861a1ce7eaae4317b08e366ff79530985fc300d12ef5ce9388bc44574cc03fd0b3c2a9b80a3949f41620778b18fd9ace
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
