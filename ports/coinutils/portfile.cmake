vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/CoinUtils
    REF 014be1f1724c074401d9d9c27bcce35baa9dca45 # I don't trust the release tags. They seem to point to a different fork with an outdates file structure?
    SHA512 c5b706ca070b9f0997f9cdf532eb97c4d6ef6c6219d5d247c486048daf94a31151711ad96a32a0f0e701024d7759f07abc867591249d6c19b2b1c153257b794a
    PATCHES coinutils.patch coinutils2.patch
)

file(COPY "${CURRENT_INSTALLED_DIR}/share/coin-or-buildtools/" DESTINATION "${SOURCE_PATH}")

set(ENV{ACLOCAL} "aclocal -I \"${SOURCE_PATH}/BuildTools\"")

#--enable-msvc
set(options "")
if("glpk" IN_LIST FEATURES)
    list(APPEND options "--with-glpk")
else()
    list(APPEND options "--without-glpk")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${options}
        --with-lapack
        --without-netlib
        --without-sample
        --without-asl
        #--enable-coinutils-threads  # only with -lrt
        #--enable-coinutils-bigindex  # only for x64
        --enable-relocatable
        --disable-readline
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/coin-or/CoinMpsIO.hpp" "\"glpk.h\"" "\"../glpk.h\"")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/coinutils" RENAME copyright)

file(COPY "${SOURCE_PATH}/m4" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
