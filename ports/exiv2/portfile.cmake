include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Exiv2/exiv2
    REF 4c093fece194e55d029e0f6474e00bb38c1d3b46
    SHA512 33132eeb51dfe4bd22a0b2bd8a66d017c27ecc9c966d72ce0691f5d01d46d1d7881d9a96c35f0e3fd6165cbcc55a6ddb98d45685be9863f41a41e0af053a89a0
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
