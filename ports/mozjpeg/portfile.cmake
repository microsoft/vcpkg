vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mozilla/mozjpeg
    REF 6d95c51adf0c314017f541b6cb07e13cc1bce754
    SHA512 a21c8b3a561b387933a27befaa1d05a8c63b0e203d72d73071a4c9b57c6b7d57b44836f211c4dcb80eee4b01876f0a0fb4c91a60c3ae867e906e5e4e27165627
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_SHARED=${ENABLE_SHARED}
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DWITH_CRT_DLL=${WITH_CRT_DLL}
)

vcpkg_install_cmake()

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

# Remove extra debug files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_tools(TOOL_NAMES cjpeg djpeg jpegtran AUTO_CLEAN)
vcpkg_fixup_pkgconfig()

# Remove empty folders after static build
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
vcpkg_copy_pdbs()