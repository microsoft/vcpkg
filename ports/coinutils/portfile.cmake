vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/CoinUtils
    REF aae9b0b807a920c41d7782d7bf2775afb17a12c6 # I don't trust the release tags. They seem to point to a different fork with an outdates file structure?
    SHA512 a515e62846698bcc3df15aabcce89d9052e30dffe2112ab5eb54c0c5def199140bd25435ef17e453c873239ab63fd03dd4cee5e4c4bfae5521f549917e025efe
    PATCHES coinutils.patch coinutils2.patch
)

file(COPY "${CURRENT_INSTALLED_DIR}/share/coin-or-buildtools/" DESTINATION "${SOURCE_PATH}")

set(ENV{ACLOCAL} "aclocal -I \"${SOURCE_PATH}/BuildTools\"")

#--enable-msvc

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --with-glpk
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
