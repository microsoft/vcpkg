vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JuliaLang/utf8proc
    REF 8ca6144c85c165987cb1c5d8395c7314e13d4cd7 # v2.7.0
    SHA512 a33e2335e9978e7a49bc0ecf9128abd93466d9daffb052f9db88097e771588547df6ba07b6028c77621e60f3b85eab78a368d9b8266ecb97ad7bdfae2b4866fc
    PATCHES
        export-cmake-targets.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DUTF8PROC_ENABLE_TESTING=OFF
        -DUTF8PROC_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-utf8proc CONFIG_PATH share/unofficial-utf8proc)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(READ "${CURRENT_PACKAGES_DIR}/include/utf8proc.h" UTF8PROC_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    string(REPLACE "defined UTF8PROC_SHARED" "0" UTF8PROC_H "${UTF8PROC_H}")
else()
    string(REPLACE "defined UTF8PROC_SHARED" "1" UTF8PROC_H "${UTF8PROC_H}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/utf8proc.h" "${UTF8PROC_H}")

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
