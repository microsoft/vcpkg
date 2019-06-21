include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO leethomason/tinyxml2
    REF 7.0.1
    SHA512 623cd7eff542d20b434a67111ac98110101c95a18767318bf906e5e56d8cc25622269f740f50477fe907a4c52d875b614cb6167f4760d42ab18dc55b9d4bf380
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/tinyxml2)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY
  ${SOURCE_PATH}/readme.md
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyxml2
)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tinyxml2/readme.md ${CURRENT_PACKAGES_DIR}/share/tinyxml2/copyright)
