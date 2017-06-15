include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cylix/cpp_redis
    REF 3.5.1
    SHA512  2c50cf777d5955f7bcb94a55514fac444d0dcacc2df343dd89969889be7653a793620dbaac9d6dd0f444eee7f0664c4eb96a1d83477d207143660764afeea129
    HEAD_REF master
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DUSE_CUSTOM_TCP_CLIENT=TRUE
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
file(GLOB HEADERS "${SOURCE_PATH}/includes/cpp_redis/*.hpp" "${SOURCE_PATH}/includes/cpp_redis/*.hpp")
if(DLLS)
    file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()
file(INSTALL ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
if(DEBUG_DLLS)
    file(INSTALL ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(INSTALL ${DEBUG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/cpp_redis)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cpp-redis RENAME copyright)

vcpkg_copy_pdbs()
