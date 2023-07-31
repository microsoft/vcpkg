set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DeveloperPaul123/thread-pool
    # REF ${VERSION}
    REF 4051c9cc722c2c95c68f35c0e761e2d3dcb65bf7
    SHA512 9273297fb642710285889f45f8aa96ecfe8b3b6948e6be3838204b6dbb90acab904ef146a103d894173d063bf315046c61e8033b13264e6ca93cf50e1212ecfd
    HEAD_REF master
)

set(PACKAGE_PROJECT_CMAKE_LOCATION "${SOURCE_PATH}/3rdparty/PackageProject.cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTP_BUILD_TESTS=OFF
        -DTP_BUILD_EXAMPLES=OFF
        -DTP_BUILD_BENCHMARKS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME threadpool
    CONFIG_PATH lib/cmake/ThreadPool-${VERSION}
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
