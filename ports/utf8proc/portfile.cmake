include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JuliaLang/utf8proc
    REF 0890a538bf8238cded9be0c81171f57e43f2c755 # v2.5.0
    SHA512 5daca349dc9ba6575efbd93d7a4e072202a2e1c2e55233d2e52be20586bb5fb26455654a77ec53336e9cdf59806457d1c31d1a926f7ef5bdd56b0232d96190dc
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
