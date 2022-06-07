vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ClickHouse/clickhouse-cpp
    REF a85a9827792bb91642e0e4511e8083677f0c1b1e    #v2.1.0
    SHA512 ecdf8af8fa49c2ebaae7d4a345c8df1a5ab86a9f39b3a4c4e27ef962807d5b62cb0aec57ae246fdc1a47e02f4224c7c4c999fafb53a5208e8008b0e2e4349cb5
    HEAD_REF master
    PATCHES 
        fix-error-C2664.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
