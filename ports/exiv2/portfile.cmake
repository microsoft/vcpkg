include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Exiv2/exiv2
    REF 8ba9422ba3cb326092b269f2752eb5ce88836115
    SHA512 08883aeb0ff6619ba28c457e11307d1f577c6a73dc09e3bd0463d46b45a7d5391445ff40a235869d3dabda824b6667bb11089c8bb48967672867ab493093d322
    HEAD_REF master
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/iconv.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "share/exiv2/cmake")

vcpkg_copy_pdbs()

# Clean
file(GLOB EXE ${CURRENT_PACKAGES_DIR}/bin/*.exe ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${EXE} ${DEBUG_EXE})

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright 
file(COPY ${SOURCE_PATH}/ABOUT-NLS DESTINATION ${CURRENT_PACKAGES_DIR}/share/exiv2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/exiv2/ABOUT-NLS ${CURRENT_PACKAGES_DIR}/share/exiv2/copyright)
