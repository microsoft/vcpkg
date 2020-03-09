vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gsl-lite/gsl-lite
    REF 0190c0e40ca65e7d30dab51bee512ccd29f48bc1
    SHA512 7ae9bb37bcbc83be3667b504271c209fea97e235fe50b754c3d420a7e97bbe2dd1df17a164dca536fb1455a19c26162d0bc27055d7c1ac495fb77956ec0f4e6d
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/gsl-lite")

file(WRITE ${CURRENT_PACKAGES_DIR}/include/gsl-lite.hpp "#ifndef GSL_LITE_HPP_VCPKG_COMPAT_HEADER_INCLUDED
#define GSL_LITE_HPP_VCPKG_COMPAT_HEADER_INCLUDED
#pragma message(\"The header <gsl-lite.hpp> is deprecated and provided only for compatibility; please include <gsl/gsl-lite.hpp> instead.\")
#include <gsl/gsl-lite.hpp>
#endif // GSL_LITE_HPP_VCPKG_COMPAT_HEADER_INCLUDED")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/debug"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
