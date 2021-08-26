vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JuliaLang/utf8proc
    REF 3203baa7374d67132384e2830b2183c92351bffc # v2.6.1
    SHA512 582831c4c2d118f1c6f9e6de812878b96428d8fa1b9a2bbca32633a3853cb1981c917c724d2a8db51282ed13fd1654ca45f5d227731f5b90b17e7fc3acc93b07
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

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
