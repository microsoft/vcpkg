vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unicorn-engine/unicorn
    REF "${VERSION}"
    SHA512 49aa53cd981e88857cf579010e3e86a6808fbfc9723fbf73c3d5bcebf945c5d78ffcdf426a4bbcd06b13337a3a0ce76bce8815497e3521023ae432a053d3e4bb
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-msvc-shared.patch
)

if(VCPKG_TARGET_IS_ANDROID)
    vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
        "-lpthread"
        " "
    )
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
        "-lpthread -lm"
        " "
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNICORN_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
