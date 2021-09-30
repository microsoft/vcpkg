if(EXISTS "${CURRENT_INSTALLED_DIR}/share/libjpeg-turbo/copyright")
    message(FATAL_ERROR "Can't build ${PORT} if libjpeg-turbo is installed. Please remove libjpeg-turbo:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mozilla/mozjpeg
    REF 512a7c3a51071981e4b314c9bc029f1daa3fb72b    #2021-09-27
    SHA512 bdada9757bec5e02533d976a988210e59e37a07aa9dd321d29f18161d4143a1398c004b210d05748aa61a9005411b46e9e0bfa37af2b45570e45020fbc28f551
    HEAD_REF master
    PATCHES
        fix-install-error.patch
)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
vcpkg_add_to_path(${NASM_EXE_PATH})

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" WITH_CRT_DLL)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_SHARED=${ENABLE_SHARED}
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DWITH_CRT_DLL=${WITH_CRT_DLL}
)

vcpkg_cmake_install()

# Rename libraries for static builds
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/jpeg-static.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/jpeg-static.lib" "${CURRENT_PACKAGES_DIR}/lib/jpeg.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/turbojpeg-static.lib" "${CURRENT_PACKAGES_DIR}/lib/turbojpeg.lib")
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/jpeg-static.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/jpeg-static.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/jpeg.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/turbojpeg-static.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/turbojpeg.lib")
    endif()
endif()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mozjpeg)
# Remove extra debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_tools(TOOL_NAMES cjpeg djpeg jpegtran tjbench AUTO_CLEAN)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# Remove empty folders after static build
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
