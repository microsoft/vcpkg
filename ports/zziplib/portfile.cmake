vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gdraheim/zziplib
    REF "v${VERSION}"
    SHA512 bed63fa7d430bd197bb70084f28ae6edc4c4120655b882bc8367f968b32c03340bb6d9bf1b14a5fcc5a1160d91ccf00e7b1131a4123da5d52233a84840ba8b7e
    PATCHES
        no-release-postfix.patch
        revert-pkgconfig-path.patch
)

string(COMPARE EQUAL VCPKG_CRT_LINKAGE "static" MSVC_STATIC_RUNTIME)
string(COMPARE EQUAL VCPKG_LIBRARY_LINKAGE "static" BUILD_STATIC_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -DMSVC_STATIC_RUNTIME=${MSVC_STATIC_RUNTIME}
        -DZZIP_COMPAT=OFF
        -DZZIP_LIBLATEST=OFF
        -DZZIP_LIBTOOL=OFF
        -DZZIP_TESTCVE=OFF
        -DZZIPBINS=OFF
        -DZZIPDOCS=OFF
        -DZZIPFSEEKO=OFF
        -DZZIPMMAPPED=OFF
        -DZZIPSDL=OFF
        -DZZIPTEST=OFF
        -DZZIPWRAP=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/zziplib")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/zzipfseeko.pc"
    "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/zzipmmapped.pc"
    "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/zzipfseeko.pc"
    "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/zzipmmapped.pc"
)

file(STRINGS "${CURRENT_PACKAGES_DIR}/include/zzip/_config.h" have_stdint_h REGEX "^#define ZZIP_HAVE_STDINT_H 1")
if(have_stdint_h)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/include/zzip/stdint.h")
endif()

vcpkg_install_copyright(COMMENT [[
zziplib is shipping under a dual MPL / LGPL license where each of them
is separate and restrictions apply alternatively.
]]
    FILE_LIST
        "${SOURCE_PATH}/docs/COPYING.LIB"
        "${SOURCE_PATH}/docs/COPYING.MPL"
)
