include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros/console_bridge
    REF 0.3.2
    SHA512 41fa5340d7ba79c887ef73eb4fda7b438ed91febd224934ae4658697e4c9e43357207e1b3e191ecce3c97cb9a87b0556372832735a268261bc798cc7683aa207
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/static-macro.patch
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

file(READ ${CURRENT_PACKAGES_DIR}/include/console_bridge/exportdecl.h _contents)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "ifdef CONSOLE_BRIDGE_STATIC" "if 1" _contents "${_contents}")
else()
    string(REPLACE "ifdef CONSOLE_BRIDGE_STATIC" "if 0" _contents "${_contents}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/console_bridge/exportdecl.h "${_contents}")
