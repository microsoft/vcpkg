vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ClickHouse/clickhouse-cpp
    REF 1415b5936a2ac2f084850b09057e05fb5798b2f1    #v1.5.0
    SHA512 222b31b16744af64f0a874ec956568adcecb553e43f8d4a2d16c00d55b31015d917a4dc7bb30d5430a894459b1be5e05b292e2d0918bf6f5609046a60539f80f
    HEAD_REF master
    PATCHES 
        fix-error-c2668.patch
        fix-error-C4996.patch  #fix x64-uwp error:std::uncaught_exception() is deprecated in C++17
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
