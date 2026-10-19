vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO erincatto/Box2D
    REF v${VERSION}
    SHA512 874bde300e7e33e950152f1d86cb4e2989cd7e30b2d89ac29d9596d9251b514972285eaba19b2d2941870f6d0e446265bf22e4d2a6df287f2c9807e0a82c8ed1
    HEAD_REF main
    PATCHES
        libm.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBOX2D_SAMPLES=OFF
        -DBOX2D_BENCHMARKS=OFF
        -DBOX2D_DOCS=OFF
        -DBOX2D_PROFILE=OFF
        -DBOX2D_VALIDATE=OFF
        -DBOX2D_UNIT_TESTS=OFF
        -DBOX2D_COMPILE_WARNING_AS_ERROR=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/box2d)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/box2d/base.h" "defined( BOX2D_DLL )" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
