vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rprichard/winpty
    REF antivirus
    SHA512 8f5539c1af2a1127219278446c1d028079867cecdeb03c4f208c7d8176e8802e8075ce1b6992e0ef73db34c69e58f73d3828698d865deb35cb883821ee245e4d
    HEAD_REF master
    PATCHES 
        allow-build-static.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_TYPE SHARED)
else()
    set(BUILD_TYPE STATIC)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TYPE=${BUILD_TYPE}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_tools(TOOL_NAMES winpty-agent winpty-debugserver AUTO_CLEAN)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
