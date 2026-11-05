vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jemalloc/jemalloc
    REF ${VERSION}
    SHA512 b94281ae172c5743bfddd459e3c8ba5cc1cf95d826cdcf9f54ae04181ff88a0c8a0f3937c41831713b452a1d1831d11e244e487211a14df8cdbcf70fd4c03d9c
    HEAD_REF master
    PATCHES
        fix-configure-ac.patch
        preprocessor.patch
)
if(VCPKG_TARGET_IS_WINDOWS)
    set(opts "ac_cv_search_log=none required" "--without-private-namespace")
endif()

vcpkg_make_configure(
    AUTORECONF
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_MSVC_WRAPPERS
    DISABLE_MSVC_TRANSFORMATIONS
    OPTIONS ${opts}
)

vcpkg_make_install()

if(VCPKG_TARGET_IS_WINDOWS)
    file(COPY "${SOURCE_PATH}/include/msvc_compat/strings.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/jemalloc/msvc_compat")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/jemalloc/jemalloc.h" "<strings.h>" "\"msvc_compat/strings.h\"")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/jemalloc.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/jemalloc.dll" "${CURRENT_PACKAGES_DIR}/bin/jemalloc.dll")
    endif()
    if(NOT VCPKG_BUILD_TYPE)
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/jemalloc.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/jemalloc.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/jemalloc.dll")
        endif()
    endif()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/jemalloc.pc" "install_suffix=" "install_suffix=_s")
        if(NOT VCPKG_BUILD_TYPE)
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/jemalloc.pc" "install_suffix=" "install_suffix=_s")
        endif()
    endif()
endif()

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
