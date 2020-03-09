include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros/console_bridge
    REF 3b5b110c224502acdfae621e790caca565173e91 # 0.4.4
    SHA512 fd6439d3cd428d76b6ec34c9a5301fd06b5dcb9c5cafcd86c927e990ba75ebcde7aceca5d3ad1d0334e4fc48b825b6dc4a15116e4934a783dc16776540b4a90c
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
