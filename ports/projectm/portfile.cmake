vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO projectM-visualizer/projectm
    REF "v${VERSION}"
    SHA512 "dbb3088c5a0db9eaabd4d2c3232df2dd939a4b1ce5928916a63e7b10cd4321b749d779a5e39a883a12318c613f91f3b4241973958edf52291d53e1b3dc348c77"
    HEAD_REF master
    PATCHES
        macos-pkgconfig.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "boost-filesystem" ENABLE_BOOST_FILESYSTEM
)

if (NOT ENABLE_BOOST_FILESYSTEM)
    message(STATUS
        "If your current vcpkg target triplet or toolchain does not support C++17 or lacks std::filesystem support, "
        "please enable the \"boost-filesystem\" feature.")
endif ()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}

        # Use projectm-eval and GLM from ports as well
        -DENABLE_SYSTEM_PROJECTM_EVAL=ON
        -DENABLE_SYSTEM_GLM=ON

        # Enforce additional build flags
        -DENABLE_PLAYLIST=ON
        -DENABLE_SDL_UI=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "projectM4"
    CONFIG_PATH "lib/cmake/projectM4"
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "projectM4Playlist"
    CONFIG_PATH "lib/cmake/projectM4Playlist"
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    COMMENT "The bundled SOIL2 sources include MIT-0 code, Apache-2.0-licensed ETC1 code, and MIT-licensed PowerVR code, but upstream does not provide their complete license texts as separate files."
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.txt"
        "${SOURCE_PATH}/vendor/hlslparser/LICENSE"
)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
