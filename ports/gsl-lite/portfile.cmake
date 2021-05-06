vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gsl-lite/gsl-lite
    REF e1c381746c2625a76227255f999ae9f14a062208
    SHA512 36b7ee945e384f1d425287a780953bf979782aa799547d08fb32e05c4671050278de34d857807de4c7e42b215900457014c49e89b7f330d522609f7cc10d47f8
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
#pragma message(\"The header <gsl-lite.hpp> is deprecated and provided by Vcpkg for compatibility only; please include <gsl/gsl-lite.hpp> instead.\")
#include <gsl/gsl-lite.hpp>
#endif // GSL_LITE_HPP_VCPKG_COMPAT_HEADER_INCLUDED")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/debug"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
