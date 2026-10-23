set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gbionics/resolve-robotics-uri-cpp
    REF "v${VERSION}"
    SHA512 c78d5441332ce466933957169f80c1ec48ebe9fc7468a4b3399c6ad693a90317d0f39f092670ea5cf0658781beb981232e439db4253fe44d7368683cb08c1654
    HEAD_REF main
)

vcpkg_from_github(
    OUT_SOURCE_PATH YCM_SOURCE_PATH
    REPO robotology/ycm-cmake-modules
    REF v0.18.2
    SHA512 2df4554bf9cd104ddc98ea8437e265fc5098c8da9724d1cab5b850791d53118ae01818d14161093becf88adfded53fddaf0dd3f09a25a3d256794380a6ebccc2
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DRRUC_BUILD_TOOL=OFF
        -DRRUC_INSTALL=ON
        -DRRUP_USE_SYSTEM_YCM=OFF
        -DFETCHCONTENT_FULLY_DISCONNECTED=ON
        "-DFETCHCONTENT_SOURCE_DIR_YCM=${YCM_SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ResolveRoboticsURICpp
    CONFIG_PATH lib/cmake/ResolveRoboticsURICpp
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
