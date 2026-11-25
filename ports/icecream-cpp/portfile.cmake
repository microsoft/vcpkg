vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO renatoGarcia/icecream-cpp
    REF "v${VERSION}"
    SHA512 2347c2db36ed5d3011af19e7b425c4849b4dc42394d38ee1c54783cac007121a92096a195fd76a0199af3cec197ce0bf49ab592831edd07ce44275114c85297b
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
