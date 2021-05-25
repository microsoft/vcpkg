vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aubio/aubio
    REF 0.4.9
    SHA512 a22c7c581ce1f428270021591649273396e6dc222b3c7b3d46f5c4abf94a98be1ab89320cdbf1b6b60d4330eef23976439e3fc9e0f8d3cdd867dac4542fa48c9
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    tools WITH_DEPENDENCIES
    tools HAVE_SNDFILE
    tools HAVE_WAVWRITE
    tools HAVE_WAVREAD
    tools HAVE_LIBAV
    tools HAVE_SWRESAMPLE
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS ${FEATURE_OPTIONS}
  OPTIONS_RELEASE
    -DTOOLS_INSTALLDIR=tools/aubio
    -DBUILD_TOOLS=ON
  OPTIONS_DEBUG
    -DDISABLE_INSTALL_HEADERS=1
    -DBUILD_TOOLS=OFF
)
vcpkg_install_cmake()

# Handle copyright and credentials
file(COPY
    ${SOURCE_PATH}/COPYING
    ${SOURCE_PATH}/AUTHORS
    ${SOURCE_PATH}/ChangeLog
    ${SOURCE_PATH}/README.md
  DESTINATION
    ${CURRENT_PACKAGES_DIR}/share/aubio)

vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/aubio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/aubio/COPYING ${CURRENT_PACKAGES_DIR}/share/aubio/copyright)
