include(vcpkg_common_functions)

set(LIB_VERSION 0.8.13)
set(LIB_FILENAME libelf_${LIB_VERSION}.orig.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "http://deb.debian.org/debian/pool/main/libe/libelf/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 ab7966cbb1aaf55fad5693ba2325f1b0586ee05a78e856ed3af5e8d16fcbcde18b8f07522ea1fa66c1c7f39ba8e7c904522d55ebc15ccb0c094c8a9851e9c969
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${LIB_VERSION}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
    DESTINATION ${SOURCE_PATH}/lib)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in
    DESTINATION ${SOURCE_PATH}/lib)
if (WIN32)
    configure_file(
        ${SOURCE_PATH}/lib/config.h.w32
        ${SOURCE_PATH}/lib/config.h
        COPYONLY)
    configure_file(
        ${SOURCE_PATH}/lib/sys_elf.h.w32
        ${SOURCE_PATH}/lib/sys_elf.h
        COPYONLY)
endif()

set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/lib
    PREFER_NINJA
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/libelf" TARGET_PATH "share/libelf")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.LIB
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libelf 
    RENAME copyright
)
