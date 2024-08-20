vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # port needs work

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ortclib/udns
    REF udns_0_4
    SHA512 4df8def718c75872536d42a757237d6c8e0afce8a53aedd7fea73814dc5cf8b5d6c9ae8f01a8cfc76864aa8293c172f08953a6750a66749ba19a3721bb4cf2ec
    HEAD_REF master
    PATCHES
        configure.patch
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    COPY_SOURCE
)

vcpkg_build_make(BUILD_TARGET staticlib)
vcpkg_fixup_pkgconfig()
# Install
if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libudns.a DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()
if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libudns.a DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
endif()

file(INSTALL ${SOURCE_PATH}/udns.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.LGPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
