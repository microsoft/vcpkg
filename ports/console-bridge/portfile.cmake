include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros/console_bridge
    REF f0b423c0c2d02651db1776c96887c0a314908063
    SHA512 f022341f06c4edf564b94305b7ce279a7a2a61d0323a7ccf374598011909d86b0a9c514b4d41fd1d523baecc1c320d16a931a8f0fbb3a3e4950720f84f0472e6
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
