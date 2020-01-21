if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexpat/libexpat
    REF R_2_2_9
    SHA512 e274fa7f30630450cb3ca681b266d765dbb7f5d00d1275ff9d9b2e2f6e1095893b8af4e3f4172ae6297c7a8a831a0a6becd484fe4bcdca09c37922f630780ef0
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

vcpkg_copy_pdbs()

# CMake's FindExpat currently doesn't look for expatd.lib
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/expatd.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/expatd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/expat.lib)
endif()

file(READ ${CURRENT_PACKAGES_DIR}/include/expat_external.h EXPAT_EXTERNAL_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "!defined(XML_STATIC)" "/* vcpkg static build !defined(XML_STATIC) */ 0" EXPAT_EXTERNAL_H "${EXPAT_EXTERNAL_H}")
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

if(VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/xmlwf.exe)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/expat/)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/xmlwf.exe ${CURRENT_PACKAGES_DIR}/tools/expat/xmlwf.exe)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(WRITE ${CURRENT_PACKAGES_DIR}/include/expat_external.h "${EXPAT_EXTERNAL_H}")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/expat)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(INSTALL ${SOURCE_PATH}/expat/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/expat RENAME copyright)