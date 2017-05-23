include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/brotli
    REF v0.6.0
    SHA512 36caa277790efeb5bff0fdc090cdcf00fd9995c4e81a60ed31d36af2e13848ec1afe5d84e6926eebbee013525191e9404e112cb7fbede16097221c5bc3dfb5d5
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
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/Release/*.lib"
)
file(GLOB DEBUG_DLLS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.dll"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/*.dll"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*/Debug/*.dll"
)
file(GLOB DEBUG_LIBS
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/*.lib"
    "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*/Debug/*.lib"
)
file(GLOB HEADERS "${SOURCE_PATH}/c/include/brotli/*.h" "${SOURCE_PATH}/include/brotli/*.h")
if(DLLS)
    file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()
file(INSTALL ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
if(DEBUG_DLLS)
    file(INSTALL ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(INSTALL ${DEBUG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/brotli)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/brotli RENAME copyright)

vcpkg_copy_pdbs()
