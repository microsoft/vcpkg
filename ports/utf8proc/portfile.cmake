include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JuliaLang/utf8proc
    REF v2.4.0
    SHA512 2bbd056b488cd30faca26618389d8af84edc39ade9b705e147b676bf39eee65b40239d01c32c46dfc2a289d79e869ed1bb3c347365603dcaab2f69e34427441a
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(READ ${CURRENT_PACKAGES_DIR}/include/utf8proc.h UTF8PROC_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    string(REPLACE "defined UTF8PROC_SHARED" "0" UTF8PROC_H "${UTF8PROC_H}")
else()
    string(REPLACE "defined UTF8PROC_SHARED" "1" UTF8PROC_H "${UTF8PROC_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/utf8proc.h "${UTF8PROC_H}")

file(COPY ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/utf8proc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/utf8proc/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/utf8proc/copyright)
