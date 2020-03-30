if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexpat/libexpat
    REF R_2_2_7
    SHA512 11b1f9a135c4501ef0112e17da8381e956366165a11a384daedd4cdef9a00c3112c8f6ff8c8f6d3b5e7b71b9a73041f23beac0f27e9cfafe1ec0266d95870408
    HEAD_REF master)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(EXPAT_LINKAGE ON)
else()
    set(EXPAT_LINKAGE OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/expat
    PREFER_NINJA
    OPTIONS
        -DBUILD_examples=OFF
        -DBUILD_tests=OFF
        -DBUILD_tools=OFF
        -DBUILD_shared=${EXPAT_LINKAGE}
)

vcpkg_install_cmake()
# CMake's FindExpat currently doesn't look for expatd.lib
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/expatd.lib) # should use a wrapper instead!
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/expatd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/expat.lib)
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/expat/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/expat RENAME copyright)

vcpkg_copy_pdbs()

file(READ ${CURRENT_PACKAGES_DIR}/include/expat_external.h EXPAT_EXTERNAL_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "!defined(XML_STATIC)" "/* vcpkg static build !defined(XML_STATIC) */ 0" EXPAT_EXTERNAL_H "${EXPAT_EXTERNAL_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/expat_external.h "${EXPAT_EXTERNAL_H}")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/expat)
