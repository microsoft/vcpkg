vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/ut
    REF bf8388f61103571dee3061a4ef23292a320d9dbf #committed on 2023-07-09
    SHA512 e7f95c71fb094170e0f431af115845f66c53f05748829a547612ae480839339b7794d4a3d8c2ae44ad2536654228f00d9d6b058b3b55c4af3432936efc2f6c2d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBOOST_UT_ALLOW_CPM_USE=OFF
        -DBOOST_UT_BUILD_BENCHMARKS=OFF
        -DBOOST_UT_BUILD_EXAMPLES=OFF
        -DBOOST_UT_BUILD_TESTS=OFF
        -DINCLUDE_INSTALL_DIR=include
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME ut CONFIG_PATH lib/cmake/ut-${VERSION})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
