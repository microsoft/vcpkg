vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmannett85/arg_router
    REF v${VERSION}
    HEAD_REF main
    SHA512 69448b9343247679a7f288c4b69819df68ba8893d3537b2bdfedf77e2c4f8d39696c68f7716eda108810a7b951f2fec57d329d4113623edf2d28c55e3e68329f
)

set(VCPKG_BUILD_TYPE release) # header-only port
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINSTALLATION_ONLY=ON
)

vcpkg_cmake_install()
vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE"
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

set(CMAKE_FILE_DIR "lib/cmake/arg_router")
if (WIN32)
    set(CMAKE_FILE_DIR "cmake")
elseif (APPLE)
    set(CMAKE_FILE_DIR "arg_router.framework/Resources/CMake")
endif()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME arg_router
    CONFIG_PATH "${CMAKE_FILE_DIR}"
)

string(FIND "${CMAKE_FILE_DIR}" "/" CMAKE_FILE_DIR_SLASH_IDX)
string(SUBSTRING "${CMAKE_FILE_DIR}" 0 ${CMAKE_FILE_DIR_SLASH_IDX} CMAKE_FILE_DIR_ROOT)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/${CMAKE_FILE_DIR_ROOT}")

file(REMOVE "${CURRENT_PACKAGES_DIR}/include/arg_router/LICENSE"
            "${CURRENT_PACKAGES_DIR}/include/arg_router/README.md"
)

