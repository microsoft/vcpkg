include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Matroska-Org/libebml
    REF release-1.3.7
    SHA512 754dee128db2eb6f0ba09962312ddda79f3178238464dd6161cce50bd08fd4193490a48bb537c4e2a388dc339951909a8857617cb30500d76d5689da4f855b47
    HEAD_REF master
    PATCHES export-endofstreamx.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DDISABLE_PKGCONFIG=1
)

vcpkg_install_cmake()

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else ()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ebml)
endif ()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.LGPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/ebml RENAME copyright)
