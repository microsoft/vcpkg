if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/Release-0.9.3.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/vczh-libraries/Release/archive/0.9.3.1.tar.gz"
    FILENAME "GacUI-0.9.3.1.tar.gz"
    SHA512 f284d3c78f8ae54102457b2cdc4fcee4b8da9a72d13bb325c7c7269261c5b0789eeb7340b0409b2b37294d68edb558503be131948aea3cb53582900339d26b54
)
vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DSKIP_HEADERS=1
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Tools
file(INSTALL ${SOURCE_PATH}/Tools/CppMerge.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/vlpp RENAME copyright)
