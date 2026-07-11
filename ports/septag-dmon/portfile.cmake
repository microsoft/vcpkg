set(VCPKG_BUILD_TYPE release)  # heaader-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            septag/dmon
    REF             98364a4d1964d603075e5e2657cfbc6c3496c9c1
    SHA512          338930c205c2cde90dfd8d743841ba9084f5eeb60eb3772ccdcfc0b117be9c3fbe85f7318affa31e3877e5e47913a8ffc964b6b3d84778f7ab9776dbe80071ed
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTS=OFF"
)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
