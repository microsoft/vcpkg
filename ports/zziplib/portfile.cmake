vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gdraheim/zziplib
    REF "v${VERSION}"
    SHA512 1560b9b6851247ef07e64c689551e191eb26e2756f7ba32bdd1a7ed345a76b444050474b2fdd5f6308ca2ff1e9a55a55c8961eefaf8db0c6674c6a2f1c368a68
    PATCHES
        no-release-postfix.patch
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
