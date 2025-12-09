vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alibaba/async_simple
    REF "${VERSION}"
    SHA512 0b4e15169e546b590d2386ff5fa51efb207b759474347445ba7e2fdbd1273b61c0a653af5fecf85c3efbcacf09f5c4391c3bc1257c786eb8b7c837db60a9617f
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS 
        -DASYNC_SIMPLE_ENABLE_TESTS=OFF 
        -DASYNC_SIMPLE_BUILD_DEMO_EXAMPLE=OFF 
        -DASYNC_SIMPLE_ENABLE_ASAN=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Benchmark=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Aio=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME async_simple)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(GLOB LIBS "${CURRENT_PACKAGES_DIR}/debug/lib/*async_simple*")

list(LENGTH LIBS LIB_CNT)
if (LIB_CNT EQUAL 0)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
