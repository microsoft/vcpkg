vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hyperrealm/libconfig
    REF v1.7.3
    SHA512 3749bf9eb29bab0f6b14f4fc759f0c419ed27a843842aaabed1ec1fbe0faa8c93322ff875ca1291d69cb28a39ece86d512aec42c2140d566c38c56dc616734f4
    HEAD_REF master
)

if (NOT VCPKG_USE_HEAD_VERSION)
  message("If you would like to use cmake with the port, use `--head` option with vcpkg install.")
  file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
endif()

if (NOT VCPKG_USE_HEAD_VERSION)
  vcpkg_cmake_configure(
      SOURCE_PATH "${SOURCE_PATH}"
      OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
  )
else()
  vcpkg_cmake_configure(
      SOURCE_PATH "${SOURCE_PATH}"
      OPTIONS
          -DBUILD_EXAMPLES=OFF
          -DBUILD_TESTS=OFF
  )
endif()

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if (VCPKG_USE_HEAD_VERSION)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
  vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libconfig)
endif()

foreach(FILE "${CURRENT_PACKAGES_DIR}/include/libconfig.h++" "${CURRENT_PACKAGES_DIR}/include/libconfig.h")
  file(READ ${FILE} _contents)
  string(REPLACE "defined(LIBCONFIGXX_EXPORTS)" "0" _contents "${_contents}")
  string(REPLACE "defined(LIBCONFIG_EXPORTS)" "0" _contents "${_contents}")

  if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    string(REPLACE "defined(LIBCONFIGXX_STATIC)" "0" _contents "${_contents}")
    string(REPLACE "defined(LIBCONFIG_STATIC)" "0" _contents "${_contents}")
  else()
    string(REPLACE "defined(LIBCONFIGXX_STATIC)" "1" _contents "${_contents}")
    string(REPLACE "defined(LIBCONFIG_STATIC)" "1" _contents "${_contents}")
  endif()
  file(WRITE ${FILE} "${_contents}")
endforeach()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
