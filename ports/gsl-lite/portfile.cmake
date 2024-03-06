vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gsl-lite/gsl-lite
    REF 755ba124b54914e672737acace6a9314f59e8d6f
    SHA512 d0b8397afc7704c5c9510fb62ce01f35faf9cc1cfd05ac3853bdc4b9fc4874aaa85aa70e93ff37867dc263b97926b15af2316e49a5787b246984fa086bf85563
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
