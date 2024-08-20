vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO shibatch/sleef
    REF 3.5.1
    SHA512 e8e4e5028db52998c6b82bd462622c08d670e4e85273327f1c3bdbd900827dd7793b217c2876ca1229b6f672493bb96f40140e14366390cccea0e6780689e128
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_LIBM=ON
        -DBUILD_DFT=ON
        -DBUILD_QUAD=ON
        -DBUILD_GNUABI_LIBS=${VCPKG_TARGET_IS_LINUX}
        -DBUILD_TESTS=OFF
        -DBUILD_INLINE_HEADERS=OFF
)
vcpkg_cmake_install()
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
