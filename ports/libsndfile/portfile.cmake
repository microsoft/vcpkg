vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO erikd/libsndfile
    REF v1.0.29
    SHA512 ff19e8cea629af9dea51c79f3446f7a63520525c8578c56b8b4b7a6f0ce07d2458ca488f0be9daeaf9ea3a1124b1fa7cac9a3b313b1ae1f43c76de852a10eed5
    HEAD_REF master
    PATCHES 0001-Improve-UWP-support.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" CRT_LIB_STATIC)

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
        -DENABLE_STATIC_RUNTIME=${CRT_LIB_STATIC}
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

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
