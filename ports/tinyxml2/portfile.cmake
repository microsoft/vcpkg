include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO leethomason/tinyxml2
    REF 6.0.0
    SHA512 30c68f491830187738b01ca5db1a96e7b4907cf8fa09a533c90ea084ab5e73f798dff6305cfc4edccc8989926e91c0482677bb5796799113c839dbd0528c8ad5
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

file(COPY
  ${SOURCE_PATH}/readme.md
  ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyxml2
)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tinyxml2/readme.md ${CURRENT_PACKAGES_DIR}/share/tinyxml2/copyright)
