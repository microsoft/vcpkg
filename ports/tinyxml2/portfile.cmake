include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO leethomason/tinyxml2
    REF 6.2.0
    SHA512 ef784240aeb090ab04aad659352ad4b224c431feecf485f33aca7936bcaa0ef4ab9d0a2e0692d3cf6036ac3e8012019d65665e780a920bbad3d4820f736445b1
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
