vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aubio/aubio
    REF 0.4.9
    SHA512 a22c7c581ce1f428270021591649273396e6dc222b3c7b3d46f5c4abf94a98be1ab89320cdbf1b6b60d4330eef23976439e3fc9e0f8d3cdd867dac4542fa48c9
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools WITH_DEPENDENCIES
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS ${FEATURE_OPTIONS}
  OPTIONS_RELEASE
    -DTOOLS_INSTALLDIR=tools/aubio
    -DBUILD_TOOLS=ON
  OPTIONS_DEBUG
    -DBUILD_TOOLS=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
