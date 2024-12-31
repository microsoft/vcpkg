vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO shibatch/sleef
    REF ${VERSION}
    SHA512 0f42c4132523f87c9e214bd9eb965e77b84c80e9a63588ed854796fccd2b9affb849a74e5f95f7b0161ba6281ca7ff509d510b42950dc38a6b8175cf6745ab07
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSLEEF_BUILD_LIBM=ON
        -DSLEEF_BUILD_DFT=ON
        -DSLEEF_BUILD_QUAD=ON
        -DSLEEF_BUILD_GNUABI_LIBS=${VCPKG_TARGET_IS_LINUX}
        -DSLEEF_BUILD_TESTS=OFF
        -DSLEEF_BUILD_INLINE_HEADERS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sleef)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Install DLL and PDB files
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        if(VCPKG_TARGET_IS_WINDOWS)
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/sleef.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/sleef.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/sleefdft.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/sleefdft.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/sleefquad.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/sleefquad.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        endif()
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        if(VCPKG_TARGET_IS_WINDOWS)
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/sleef.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/sleef.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/sleefdft.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/sleefdft.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/sleefquad.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/sleefquad.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        endif()
    endif()
endif()
