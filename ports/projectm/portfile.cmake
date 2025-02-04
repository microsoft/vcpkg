vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO projectM-visualizer/projectm
    REF "v${VERSION}"
    SHA512 "c59885d1b6c96372f451b436a47a10e72f94e114b0dad913aa91b3ee5b48ce77f8423c011f60786cb2a2577d3875cba8e58f2e70e60116672cbc49b2de695ad4"
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
