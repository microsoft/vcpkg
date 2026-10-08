if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aeron-io/aeron
    REF "${VERSION}"
    SHA512 592be81475d19ff5da24dd5c100ddf14da0cee62504c394b5633ac60cbd781279c72c9059e4421862adb3c7162220be7aaa50c783ff05b1f4826870dff346f1c
    HEAD_REF master
    PATCHES
        patches/add-libuuid-vcpkg-support.patch
        patches/fix-static-crt-linkage.patch
        patches/fix-library-linkage.patch
)

# Set archive option based on feature
if("archive" IN_LIST FEATURES)
    set(BUILD_ARCHIVE ON)
else()
    set(BUILD_ARCHIVE OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAERON_INSTALL_TARGETS=ON
        -DAERON_TESTS=OFF
        -DAERON_BUILD_SAMPLES=OFF
        -DBUILD_AERON_ARCHIVE_API=${BUILD_ARCHIVE}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/aeron)

# Aeron installs DLLs into lib; move them to bin
if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(GLOB RELEASE_DLLS "${CURRENT_PACKAGES_DIR}/lib/*.dll")
    file(GLOB DEBUG_DLLS "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
    if(RELEASE_DLLS)
        file(COPY ${RELEASE_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(REMOVE ${RELEASE_DLLS})
    endif()
    if(DEBUG_DLLS)
        file(COPY ${DEBUG_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(REMOVE ${DEBUG_DLLS})
    endif()
endif()

# Copy aeronmd tools
vcpkg_copy_tools(TOOL_NAMES aeronmd aeronmd_s AUTO_CLEAN)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
