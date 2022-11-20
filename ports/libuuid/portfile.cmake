set(LIBUUID_VERSION 1.0.3)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libuuid
    FILENAME "libuuid-${LIBUUID_VERSION}.tar.gz"
    SHA512 77488caccc66503f6f2ded7bdfc4d3bc2c20b24a8dc95b2051633c695e99ec27876ffbafe38269b939826e1fdb06eea328f07b796c9e0aaca12331a787175507
)

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
    ${CMAKE_CURRENT_LIST_DIR}/config.linux.h
    ${CMAKE_CURRENT_LIST_DIR}/unofficial-libuuid-config.cmake.in
    DESTINATION ${SOURCE_PATH}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

set(prefix ${CURRENT_INSTALLED_DIR})
set(exec_prefix \$\{prefix\})
set(libdir \$\{exec_prefix\}/lib)
set(includedir \$\{prefix\}/include)
configure_file(${SOURCE_PATH}/uuid.pc.in ${SOURCE_PATH}/uuid.pc @ONLY)
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(INSTALL ${SOURCE_PATH}/uuid.pc DESTINATION ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(INSTALL ${SOURCE_PATH}/uuid.pc DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/unofficial-libuuid TARGET_PATH share/unofficial-libuuid)
vcpkg_fixup_pkgconfig()

file(INSTALL
    ${SOURCE_PATH}/COPYING
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
