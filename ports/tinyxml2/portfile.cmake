include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO leethomason/tinyxml2
    REF 5.0.1
    SHA512 a51ec5843774df0482620c549fb6c61d30a6db5025be26ff6d25b3c53533a27a57f00b026bd9fbca78e9e30084b3f5f6fbff9dba315d078419da084b57f518ba
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  set(BUILD_STATIC_LIBS 1)
else()
  set(BUILD_STATIC_LIBS 0)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
      -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/tinyxml2")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyxml2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tinyxml2/readme.md ${CURRENT_PACKAGES_DIR}/share/tinyxml2/copyright)
