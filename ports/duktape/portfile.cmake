vcpkg_download_distfile(
    ARCHIVE
    URLS https://github.com/svaarala/duktape/releases/download/v2.7.0/duktape-2.7.0.tar.xz
    FILENAME duktape-2.7.0.tar.xz
    SHA512 8ff5465c9c335ea08ebb0d4a06569c991b9dc4661b63e10da6b123b882e7375e82291d6b883c2644902d68071a29ccc880dae8229447cebe710c910b54496c1d
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/duktapeConfig.cmake.in" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(DUK_CONFIG_H_PATH "${SOURCE_PATH}/src/duk_config.h")
  file(READ "${DUK_CONFIG_H_PATH}" CONTENT)
  string(REPLACE "#undef DUK_F_DLL_BUILD" "#define DUK_F_DLL_BUILD" CONTENT "${CONTENT}")
  file(WRITE "${DUK_CONFIG_H_PATH}" "${CONTENT}")
else()
  set(DUK_CONFIG_H_PATH "${SOURCE_PATH}/src/duk_config.h")
  file(READ "${DUK_CONFIG_H_PATH}" CONTENT)
  string(REPLACE "#define DUK_F_DLL_BUILD" "#undef DUK_F_DLL_BUILD" CONTENT "${CONTENT}")
  file(WRITE "${DUK_CONFIG_H_PATH}" "${CONTENT}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
