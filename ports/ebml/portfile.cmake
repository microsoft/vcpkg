include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Matroska-Org/libebml
    REF 6145c5700d894312c4dd47ba6c1ace72075b0692 # release-1.4.0
    SHA512 74132d4605ec8b75e72fa58ca4c04c5aa980aae4b028032d34fde14eff406c814518168ae7bfec5cdaf026d914a019b1fcac1458c40537c4964a46989c1283d0
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DDISABLE_PKGCONFIG=1
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/EBML)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.LGPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
