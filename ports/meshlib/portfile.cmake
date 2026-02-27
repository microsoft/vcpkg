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
        disable-test.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH LAZ_PERF_SOURCE_PATH
    REPO MeshInspector/laz-perf
    REF 05ea01542e5c4417c05e7222f920e06276c79324
    SHA512 de933635f31fb726b359e1058e3666006b236acc0fa5fc20049288fd19446d6f482b34f926a398cb1760e6cae9a6cbd52c2a2dd6bbf3717145f49e3d04404c0a
    HEAD_REF master
    PATCHES
        lazperf-cpp17.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/thirdparty/laz-perf")
file(COPY "${LAZ_PERF_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/thirdparty/laz-perf")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTING=OFF
        -DMR_CXX_STANDARD=20
        -DMESHLIB_PYTHON_SUPPORT=OFF
        -DMESHLIB_BUILD_MRCUDA=OFF
        -DMESHLIB_BUILD_MESHVIEWER=OFF
        -DMESHLIB_BUILD_MRVIEWER=OFF
        -DMESHLIB_BUILD_PYTHON_MODULES=OFF
        -DMESHLIB_USE_VCPKG=ON
        -DMRMESH_NO_GTEST=ON
        -DMRIOEXTRAS_NO_CTM=ON # API compatibility issue with openctm

)
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/MeshLib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
