include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros/console_bridge
    REF 0.3.2
    SHA512 41fa5340d7ba79c887ef73eb4fda7b438ed91febd224934ae4658697e4c9e43357207e1b3e191ecce3c97cb9a87b0556372832735a268261bc798cc7683aa207
    HEAD_REF master
  )

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH "CMake")
file(RENAME ${CURRENT_PACKAGES_DIR}/share/console-bridge ${CURRENT_PACKAGES_DIR}/share/console_bridge)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/console-bridge RENAME copyright)
