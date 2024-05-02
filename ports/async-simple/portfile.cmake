vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alibaba/async_simple
    REF "v${VERSION}"
    SHA512 7686d8c98e5e87cf88c24488e4c0b528b29011ef48c25156c57695208dab75ee2f28b6f36e2612db2bf4644b50f4c1d4a7ebc54f16bc035cb106239d5b335c77
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
