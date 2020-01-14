include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CNugteren/CLBlast
    REF 1.5.0
    SHA512 4d2ba302b3d1c449a5aaeeae97e3d0c03d8baec55276e66f80398fe87f11047f68cec6196eba1228cbfd2911bff9cf5cf5550df925d3b0f3e6ad91302817655c
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
