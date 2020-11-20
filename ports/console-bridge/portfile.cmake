vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros/console_bridge
    REF 0a6c16ed68750837c32ed1cedee9fca7d61d4364 # 1.0.1
    SHA512 8b856bf8c0eec7d7f3f87e10c4de2b99369bd35cab5f9dd5ea3813fdd5a3fd4e7cd31b2336746920e093a515ad1175fd5af79f9d2f6a4648b1814b3131a1ef03
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake TARGET_PATH share/console_bridge)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/console_bridge/cmake TARGET_PATH share/console_bridge)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/console_bridge)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/console_bridge)
endif()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(READ ${SOURCE_PATH}/src/console.cpp _contents)
string(SUBSTRING "${_contents}" 0 2000 license)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/console-bridge)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/console-bridge/copyright "${license}")

file(READ ${CURRENT_PACKAGES_DIR}/include/console_bridge_export.h _contents)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "ifdef CONSOLE_BRIDGE_STATIC_DEFINE" "if 1" _contents "${_contents}")
else()
    string(REPLACE "ifdef CONSOLE_BRIDGE_STATIC_DEFINE" "if 0" _contents "${_contents}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/console_bridge_export.h "${_contents}")
