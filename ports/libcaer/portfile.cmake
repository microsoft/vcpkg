vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com/inivation/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dv/libcaer
    REF "${VERSION}"
    SHA512 29f8ac47f97a7640d8102eb5c693259da7506d918975be0f3e4e970ab7135dfff67f1c48dd17240462bf846bf31745d518a421229b8c453b29410ea26e489aa3
    HEAD_REF master
    PATCHES
        fix-libusb.diff
)

find_program(PKGCONFIG NAMES pkgconf PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/pkgconf" NO_DEFAULT_PATH REQUIRED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        opencv     ENABLE_OPENCV
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # writes to include/libcaer/libcaer.h
    OPTIONS
        ${FEATURE_OPTIONS}
        -DEXAMPLES_INSTALL=OFF
        -DBUILD_CONFIG_VCPKG=ON
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

set(stdatomic_license "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/LICENSE for simple-stdatomic (x86,x64 MSVC)")
file(COPY_FILE "${SOURCE_PATH}/thirdparty/simple-stdatomic/LICENSE" "${stdatomic_license}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${stdatomic_license}")
