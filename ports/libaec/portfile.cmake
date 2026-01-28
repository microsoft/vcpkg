vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.dkrz.de
    REPO k202009/libaec
    REF "v${VERSION}"
    SHA512 320060f59f29d0f2124c79e60ab6205fed31d96101b654393e4ba3154c55903247ef844e1d4f658094b76e19fe950437e9ecbbcd04dfe53a8b570fe9a17b5f87
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
    "if(TARGET libaec::aec OR TARGET libaec::sz)\nelseif(\"${BUILD_STATIC}\") # forced by vcpkg"
)
# Compatibility with user's CMake < 3.18 (vcpkg claims support for >= 3.16):
# Make imported targets global so that libaec-config.cmake can create ALIAS targets.
file(READ "${CURRENT_PACKAGES_DIR}/share/libaec/libaec-targets.cmake" libaec_targets)
string(REGEX REPLACE " (SHARED|STATIC) IMPORTED" " \\1 IMPORTED \${libaec_maybe_global}" libaec_targets "${libaec_targets}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/libaec/libaec-targets.cmake" "set(libaec_maybe_global \"\")
if(CMAKE_VERSION VERSION_LESS 3.18)
    set(libaec_maybe_global \"GLOBAL\")
endif()
${libaec_targets}
"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
