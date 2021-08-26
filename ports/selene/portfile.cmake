vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kmhofmann/selene
    REF v0.3.1
    SHA512 7bc57ebe9e2442da2716eb5c1af11f8d610b0b09fe96e3122d1028575732b6045a987c499bbf7de53003edd627b8809d86c80ea4975fc2264a1c61d5891a46c3
    HEAD_REF master
    PATCHES
        disable_x86_intrinsics_on_arm.patch
        tiff-deprecated-typedefs.patch
        trivial-pixel.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "opencv" SELENE_USE_OPENCV
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/selene)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
