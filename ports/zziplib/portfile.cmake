vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gdraheim/zziplib
    REF v0.13.72
    SHA512 4bb089e74813c6fac9657cd96e44e4a6469bf86aba3980d885c4573e8db45e74fd07bbdfcec9f36297c72227c8c0b2c37dab1bc4326cef8529960e482fe501c8
    PATCHES
        no-release-postfix.patch
        export-targets.patch
)

string(COMPARE EQUAL VCPKG_CRT_LINKAGE "static" MSVC_STATIC_RUNTIME)
string(COMPARE EQUAL VCPKG_LIBRARY_LINKAGE "static" BUILD_STATIC_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DMSVC_STATIC_RUNTIME=${MSVC_STATIC_RUNTIME}
        -DZZIPMMAPPED=OFF
        -DZZIPFSEEKO=OFF
        -DZZIPWRAP=OFF
        -DZZIPSDL=OFF
        -DZZIPBINS=OFF
        -DZZIPTEST=OFF
        -DZZIPDOCS=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-zziplib)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/zzipfseeko.pc"
    "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/zzipmmapped.pc"
    "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/zzipfseeko.pc"
    "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/zzipmmapped.pc"
)

vcpkg_fixup_pkgconfig()

file(READ "${SOURCE_PATH}/docs/COPYING.LIB" lgpl)
file(READ "${SOURCE_PATH}/docs/COPYING.MPL" mpl)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright"
"${PORT} is shipping under a dual MPL / LGPL license where each of them
is separate and restrictions apply alternatively.

---

${lgpl}

---

${mpl}
")
