set(ITPP_VERSION 4.3.1)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO itpp/itpp
    REF ${ITPP_VERSION}
    FILENAME "itpp-${ITPP_VERSION}.tar.bz2"
    SHA512 b46d048fa7f33e80d2291a5e38e205c159791ea200f92c70d69e8ad8447ac2f0c847fece566a99af739853a1643cb16e226b4200c8bf115417f324e6d38c66bd
    PATCHES 
        msvc2013.patch
        fix-uwp.patch
        fix-linux.patch
        rename-version.patch
        fix-build.patch
)
file(RENAME "${SOURCE_PATH}/VERSION" "${SOURCE_PATH}/VERSION.txt")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=11 # C++17 does not allow 'register'
        -DCMAKE_DISABLE_FIND_PACKAGE_LAPACK=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_FFT=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_BLAS=ON
)

vcpkg_cmake_install()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_fixup_pkgconfig()
