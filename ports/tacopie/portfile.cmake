include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cylix/tacopie
    REF 2.4.1
    SHA512 a1579080412114d3899492cd9559bb0eadd6048c1f84ac66ec8ca47bd6fbb35306f0d203d789bd1b7ed0a0a5ab27434dfe6583a1c67873c85bca4b6e2a186d77
    HEAD_REF master
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_build_cmake()

file(GLOB DLLS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.dll"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/*.dll"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/Release/*.dll"
)
file(GLOB LIBS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/lib/*.lib"
)
file(GLOB DEBUG_DLLS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.dll"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/*.dll"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*/Debug/*.dll"
)
file(GLOB DEBUG_LIBS
"${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*/lib/*.lib"
)
file(GLOB HEADERS "${SOURCE_PATH}/includes/tacopie/*.hpp" "${SOURCE_PATH}/includes/tacopie/*.hpp")
if(DLLS)
    file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()
file(INSTALL ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
if(DEBUG_DLLS)
    file(INSTALL ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(INSTALL ${DEBUG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/tacopie)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tacopie RENAME copyright)

vcpkg_copy_pdbs()
