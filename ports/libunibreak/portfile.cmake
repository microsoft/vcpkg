include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO adah1972/libunibreak
  REF 15b579aac410b7c11ba596f4a9abbf405a187e34
  SHA512 a46196ad276134dad19fbc4ad49a2f4a4563137e30657b0f06cee9e6b4dab803723ae270f9682c4b8245c9d10297ce44b7bfb08bfa16894552cdb916fc758c02
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENCE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libunibreak RENAME copyright)
