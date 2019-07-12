if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexpat/libexpat
    REF d3b78b42a2dcdea98e22625cfff67a49d47e6025
    SHA512 9bb598766091b6d362bb2fb6a486894760524d6a3591d09a597fb695ae0d628adece5bd7ffe08c13ed53393d8e73d7d883055ae60e891e71f74ae36facce5557
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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(INSTALL ${SOURCE_PATH}/expat/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/expat RENAME copyright)

vcpkg_copy_pdbs()

# CMake's FindExpat currently doesn't look for expatd.lib
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/expatd.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/expatd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/expat.lib)
endif()

file(READ ${CURRENT_PACKAGES_DIR}/include/expat_external.h EXPAT_EXTERNAL_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "!defined(XML_STATIC)" "/* vcpkg static build !defined(XML_STATIC) */ 0" EXPAT_EXTERNAL_H "${EXPAT_EXTERNAL_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/expat_external.h "${EXPAT_EXTERNAL_H}")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/expat)
