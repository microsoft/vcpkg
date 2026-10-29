vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsndfile/libsndfile
    REF ${VERSION}
    SHA512 fb8b4d367240a8ac9d55be6f053cb19419890691c56a8552d1600d666257992b6e8e41a413a444c9f2d6c5d71406013222c92a3bfa67228944a26475444240a1
    HEAD_REF master
    PATCHES
        001-avoid-installing-find-modules.patch
        mp3lame.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        external-libs   ENABLE_EXTERNAL_LIBS
        mpeg            ENABLE_MPEG
        regtest         BUILD_REGTEST
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND OPTIONS "-DPYTHON_EXECUTABLE=${PYTHON3}")
endif()

if(VCPKG_TARGET_IS_UWP)
    set(VCPKG_C_FLAGS "/sdl- ${VCPKG_C_FLAGS}")
    set(VCPKG_CXX_FLAGS "/sdl- ${VCPKG_CXX_FLAGS}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_BOW_DOCS=OFF
        -DBUILD_PROGRAMS=OFF
        -DBUILD_REGTEST=OFF
        -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON
        ${OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    set(CONFIG_PATH cmake)
else()
    set(CONFIG_PATH lib/cmake/SndFile)
endif()
vcpkg_cmake_config_fixup(PACKAGE_NAME SndFile CONFIG_PATH "${CONFIG_PATH}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
