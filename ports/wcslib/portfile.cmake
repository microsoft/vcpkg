vcpkg_download_distfile(archive
    URLS "ftp://ftp.atnf.csiro.au/pub/software/wcslib/wcslib-7.12.tar.bz2"
    FILENAME "wcslib-7.12.tar.bz2"
    SHA512 7f38f725992d3c4bd3c1b908d494ac361c17f6b60f091d987fda596211423bb7396b3a5e2f1f6dd6215835016d302083472a7ad0822f17cdfe230c8f556b3e23
)

vcpkg_extract_source_archive(
    src
    ARCHIVE "${archive}"
)

file(COPY ${CURRENT_PORT_DIR}/CMakeLists.txt
     DESTINATION ${src})

vcpkg_cmake_configure(SOURCE_PATH "${src}")
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${src}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
