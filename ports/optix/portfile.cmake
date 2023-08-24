include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_find_optix.cmake")
vcpkg_find_optix(OUT_OPTIX_ROOT OPTIX_ROOT)

set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/v${VERSION}")
file(COPY "${OPTIX_ROOT}/include/" DESTINATION "${SOURCE_PATH}/include")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-OptiX CONFIG_PATH share/unofficial-OptiX)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${VCPKG_ROOT_DIR}/LICENSE.txt")
