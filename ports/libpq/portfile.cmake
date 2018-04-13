include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/postgresql-9.6.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.postgresql.org/pub/source/v9.6.3/postgresql-9.6.3.tar.bz2"
    FILENAME "postgresql-9.6.3.tar.bz2"
    SHA512 97141972e154e6b0e756ee6a4e20f26e82022a9fd4c56305314a3a5567a79ece638e4ac3d513b46138737ae6bd27a098f30013a94767db151181aac9c01290a1
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        "-DPORT_DIR=${CMAKE_CURRENT_LIST_DIR}"
    OPTIONS_DEBUG
        -DINSTALL_INCLUDES=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/libpq RENAME copyright)
