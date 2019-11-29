vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexpat/libexpat
    REF a7bc26b69768f7fb24f0c7976fae24b157b85b13 #tag 2.2.9
    SHA512 18842d5c9ff89654c5beeb9daba7ff5a911da318d419735fb14a5acbe0d1b4ac07077822c70cfa5c845892bcec2d72f8f265b9a259fe459092864f4d1754f8dd
    HEAD_REF master
    PATCHES
        fix-find-package-by-cmake.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(EXPAT_LINKAGE ON)
else()
    set(EXPAT_LINKAGE OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/expat
    PREFER_NINJA
    OPTIONS
        -DEXPAT_BUILD_EXAMPLES=OFF
        -DEXPAT_BUILD_TESTS=OFF
        -DEXPAT_BUILD_TOOLS=OFF
        -DEXPAT_SHARED_LIBS=${EXPAT_LINKAGE}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(GLOB EXE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(GLOB DEBUG_EXE ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
if(EXE OR DEBUG_EXE)
    file(REMOVE ${EXE} ${DEBUG_EXE})
endif()

file(READ ${CURRENT_PACKAGES_DIR}/include/expat_external.h EXPAT_EXTERNAL_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "! defined(XML_STATIC)" "/* vcpkg static build ! defined(XML_STATIC) */ 0" EXPAT_EXTERNAL_H "${EXPAT_EXTERNAL_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/expat_external.h "${EXPAT_EXTERNAL_H}")

vcpkg_copy_pdbs()

#Handle copyright
file(INSTALL ${SOURCE_PATH}/expat/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)