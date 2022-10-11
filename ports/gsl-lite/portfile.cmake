vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gsl-lite/gsl-lite
    REF 4b5e9ab7474841fc2d7efc2e0064ef81785535d1
    SHA512 d5678743f2aebf9b8311e1484d8d22d995f4920632c55ff2f45e463f435a087d25bbf79749c179cfa2f96e799a55e5ee2e59eb2cc6962b8f5922ea56789e16b1
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
