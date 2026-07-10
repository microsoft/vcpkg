vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.dkrz.de
    REPO dkrz-sw/libaec
    REF "v${VERSION}"
    SHA512 ede721986c1b7632ee2577964d02438a8ff5ed90481ea638412f6c2128af0bf1911ca3762acdbaf04fdcab75a363652bf5c992c11d9e38d4e5334f089d124617
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_STATIC_LIBS=${BUILD_STATIC}
        -Dlibaec_INSTALL_CMAKEDIR=share/${PORT}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/libaec/libaec-config.cmake"
    "if(libaec_USE_STATIC_LIBS)"
    "if(\"${BUILD_STATIC}\") # forced by vcpkg"
)

# Compatibility with user's CMake < 3.18 (vcpkg claims support for >= 3.16):
# Make imported targets global so that libaec-config.cmake can create ALIAS targets.
set(_target_file "libaec_shared-targets")
if(BUILD_STATIC)
    set(_target_file "libaec_static-targets")
endif()
file(READ "${CURRENT_PACKAGES_DIR}/share/libaec/${_target_file}.cmake" libaec_targets)
string(REGEX REPLACE " (SHARED|STATIC) IMPORTED" " \\1 IMPORTED \${libaec_maybe_global}" libaec_targets "${libaec_targets}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/libaec/${_target_file}.cmake" "set(libaec_maybe_global \"\")
if(CMAKE_VERSION VERSION_LESS 3.18)
    set(libaec_maybe_global \"GLOBAL\")
endif()
${libaec_targets}
"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
