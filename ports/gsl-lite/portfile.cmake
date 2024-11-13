vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gsl-lite/gsl-lite
    REF 004a3e61f30e5c94b5964a0b4a2728847579a304
    SHA512 b9ce0c85927352ad05045e7548b6bb700a972aa56b04fb0f9a4f0a0cebb197451dfcc4b82c3c297cee7a10aa946b95364048e21f77d28d3c1e13e5aba866163e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/gsl-lite"
)

file(WRITE ${CURRENT_PACKAGES_DIR}/include/gsl-lite.hpp "#ifndef GSL_LITE_HPP_VCPKG_COMPAT_HEADER_INCLUDED
#define GSL_LITE_HPP_VCPKG_COMPAT_HEADER_INCLUDED
#pragma message(\"The header <gsl-lite.hpp> is deprecated and provided by Vcpkg for compatibility only; please include <gsl/gsl-lite.hpp> instead.\")
#include <gsl/gsl-lite.hpp>
#endif // GSL_LITE_HPP_VCPKG_COMPAT_HEADER_INCLUDED")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/debug"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
