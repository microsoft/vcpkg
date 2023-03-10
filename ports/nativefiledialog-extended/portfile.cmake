vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO btzy/nativefiledialog-extended
    REF v${VERSION}
    SHA512 3992b4e9ea87fd2f0f85c9e5952fb19b7006f2c9709f1b1c4925de329f3dc1065d2c1af851cba4afbbfa95f0ed764ec36a1f55d7a4720e813563e4e6f533024a
    HEAD_REF master
)

set(NFDE_SHARED OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(NFDE_SHARED ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SHARED_LIBS=${NFDE_SHARED}
        -DNFD_PORTAL=${VCPKG_TARGET_IS_LINUX}
        -DNFD_BUILD_TESTS=OFF
        -DNFD_INSTALL=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
