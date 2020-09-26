vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO erikd/libsndfile
    REF v1.0.30
    SHA512 2714dfbe923450a1f6f6d2a53ae0e88163170a5e0ce436bee27c1c41fc9b5526d6bc38e58918132248a9044f5b05fa29cd483c06c75ed67e6d83c961e30aaac9
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_find_acquire_program(PYTHON3)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES external-libs ENABLE_EXTERNAL_LIBS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_REGTEST=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_BOW_DOCS=OFF
        -DBUILD_PROGRAMS=OFF
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
