set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Simple-Robotics/proxsuite
    REF "v${VERSION}"
    SHA512 5c356826c24d26c1f51a0b78fee3cb9adef9406911e4862470bfaf050a18b1aa818e7aeda64c489da319c80fe10edf7ae077f31d350bed9e2129910aec637436
    HEAD_REF devel
)

vcpkg_from_github(
    OUT_SOURCE_PATH JRL_SOURCE_PATH
    REPO jrl-umi3218/jrl-cmakemodules
    REF a6e58193daf46c80ea40dd8006ff014dba590dcd
    SHA512 fcea798fd6ded6ef85385f180147cfddc358294ec6e15a879b76056a30cd3b9ba96dca30e5a75d7a8a1f0b7b56e3765a2ee59264c4ff530dc95e0a5a0fc680e1
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_BENCHMARK=OFF
        -DBUILD_WITH_VECTORIZATION_SUPPORT=OFF
        -DBUILD_PYTHON_INTERFACE=OFF
        -DPROXSUITE_BUILD_WITH_SERIALIZATION=OFF
        -DPROXSUITE_BUILD_WITH_SERIALIZATION=OFF
        -DBUILD_WITH_OPENMP_SUPPORT=OFF
        "-DJRL_CMAKEMODULES_SOURCE_DIR=${JRL_SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
