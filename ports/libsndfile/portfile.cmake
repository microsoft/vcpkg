vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsndfile/libsndfile
    REF 1.1.0
    SHA512 5e530c33165a2d2be1c22d3a4bd96f0f1817dded3a45d24bad0e3f2c7908ccc1f19327a91d5040c3ea4d591845876019180747a125bf2a6f8bd49a6f67eadacd
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_find_acquire_program(PYTHON3)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        external-libs ENABLE_EXTERNAL_LIBS
        mpeg ENABLE_MPEG
        regtest BUILD_REGTEST
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_BOW_DOCS=OFF
        -DBUILD_PROGRAMS=OFF
        -DBUILD_REGTEST=OFF
        -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON
        -DPYTHON_EXECUTABLE=${PYTHON3}
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

if(WIN32 AND (NOT MINGW) AND (NOT CYGWIN))
    set(CONFIG_PATH cmake)
else()
    set(CONFIG_PATH lib/cmake/SndFile)
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH ${CONFIG_PATH} TARGET_PATH share/SndFile)
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES m)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
