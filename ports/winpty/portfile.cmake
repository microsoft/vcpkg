vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rprichard/winpty
    REF antivirus
    SHA512 8f5539c1af2a1127219278446c1d028079867cecdeb03c4f208c7d8176e8802e8075ce1b6992e0ef73db34c69e58f73d3828698d865deb35cb883821ee245e4d
    HEAD_REF master
    PATCHES 
        build-with-cmake.patch
        allow-build-static.patch
	)

set(OPTIONS "")
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_TYPE SHARED)
    list(APPEND OPTIONS -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=TRUE)
else()
    set(BUILD_TYPE STATIC)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TYPE=${BUILD_TYPE}
        ${OPTIONS}
    )
	
vcpkg_cmake_install()

# cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# license
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/winpty)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/winpty/LICENSE ${CURRENT_PACKAGES_DIR}/share/winpty/copyright)

#copy tools
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*")
    list(FILTER BINARY_TOOLS EXCLUDE REGEX "\\.dll\$")
    file(INSTALL ${BINARY_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/winpty)
    file(REMOVE ${BINARY_TOOLS})
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*")
    list(FILTER BINARY_TOOLS EXCLUDE REGEX "\\.dll\$")
    file(REMOVE ${BINARY_TOOLS})
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/winpty)
