vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CNugteren/CLBlast
    REF 8433985051c0fb9758fd8dfe7d19cc8eaca630e1 # 1.5.1
    SHA512 17eedfc9fff98c9aafc1b47bf2bc0d29fe38e057fa5142cfe534c168b5bafe7ad092cc7fa4db20926101d024caa5ad47cfd2c1d8f18a071195288015f68f12a1
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)

if(VCPKG_TARGET_IS_WINDOWS)
    if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/clblast.dll)
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/clblast.dll ${CURRENT_PACKAGES_DIR}/bin/clblast.dll)
    endif()
    if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/clblast.dll)
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/clblast.dll  ${CURRENT_PACKAGES_DIR}/debug/bin/clblast.dll)
    endif()
    file(GLOB EXE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
    file(GLOB DEBUG_EXE ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
    if(EXE OR DEBUG_EXE)
        file(REMOVE ${EXE} ${DEBUG_EXE})
    endif()
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/clblast)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
