vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO log4cpp/log4cpp-1.1.x%20%28new%29
    REF log4cpp-1.1
    FILENAME "log4cpp-${VERSION}.tar.gz"
    SHA512 c12d9128499bc8b2ab39d3c7979b81ac5c2f033ddfb942bdcd70e5d06f8a78da0258f2295e716417d0dd7680fde983720ffb55851755297ff03cbf5ca7acdff8
    PATCHES
        cmake_fix.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
    string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -DLOG4CPP_BUILD_SHARED=${BUILD_SHARED}
            -DLOG4CPP_BUILD_STATIC=${BUILD_STATIC}
    )
    vcpkg_cmake_install()
    vcpkg_copy_pdbs()

    set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
elseif(VCPKG_TARGET_IS_LINUX)
    # The CMake build does not work under Linux because it depends on a config.h
    # file that is currently only derived from config.h.in via configure.h.

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(SHARED_STATIC --enable-static --disable-shared)
    else()
        set(SHARED_STATIC --disable-static --enable-shared)
    endif()

    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTORECONF
        OPTIONS
            ${SHARED_STATIC}
            "--prefix=${CURRENT_PACKAGES_DIR}"
            "--with-sysroot=${CURRENT_INSTALLED_DIR}"
    )
    vcpkg_make_install()
    vcpkg_fixup_pkgconfig()

    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/tools"
        "${CURRENT_PACKAGES_DIR}/debug/share"
    )
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
