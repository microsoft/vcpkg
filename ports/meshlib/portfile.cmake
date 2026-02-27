vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MeshInspector/MeshLib
    REF v${VERSION}
    SHA512 ec4eb605c3fb1dcddc6d2219baa6eb9402bf57b1840d601bcc92b82b9b48a4d8bd8221b2589cc0677eef9185977a0afdde1464d74dccd964c4ff2dc5a1742be9
    HEAD_REF master
    PATCHES
        fix-msvc-lazperf-build.patch
        fix-linux-openvdb-blosc-link.patch
        fix-cassert.patch
        fix-e57format.patch
        fix-exported-include-dirs.patch
        fix-jpeg-link.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH LAZ_PERF_SOURCE_PATH
    REPO MeshInspector/laz-perf
    REF 8d0a813a3b125fbc21ef214cf79609a1636cc9e4
    SHA512 56df3dce943c4e6865dcfb18b32f184d260867069f6f4bffe8f2478c813c13d618fcea3b121e9632aa008e09fbc6899858caaadcd45fb8f8e2e5793f34f1e2b2
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/thirdparty/laz-perf")
file(COPY "${LAZ_PERF_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/thirdparty/laz-perf")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTING=OFF
        -DMESHLIB_PYTHON_SUPPORT=OFF
        -DMESHLIB_BUILD_MRCUDA=OFF
        -DMESHLIB_BUILD_MESHVIEWER=OFF
        -DMESHLIB_BUILD_MRVIEWER=OFF
        -DMESHLIB_BUILD_PYTHON_MODULES=OFF
        -DMESHLIB_USE_VCPKG=ON
        -DMRIOEXTRAS_NO_CTM=ON # API compatibility issue with openctm

)
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/MeshLib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
