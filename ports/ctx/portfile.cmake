vcpkg_download_distfile(ARCHIVE
    URLS "https://ctx.graphics/ctx-${VERSION}.tar.bz2"
    FILENAME "ctx-${VERSION}.tar.bz2"
    SHA512 4c66ae3287d8e889fd625a39df53f51514e4df1a60ccbb63e6508759e8ba9fa58cca4f4a437475f5b3ffcc0ffe4e4dcd72ac981463f8c3629d5c1f90390a9c24
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-msvc-loose-includes.patch
        fix-ctx-msvc.patch
)

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/meson.build"
    "${CMAKE_CURRENT_LIST_DIR}/meson_options.txt"
    "${CMAKE_CURRENT_LIST_DIR}/ctx-wasm.pc.in"
    "${CMAKE_CURRENT_LIST_DIR}/ctx-wasm-simd.pc.in"
    DESTINATION "${SOURCE_PATH}"
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        babl babl
        harfbuzz harfbuzz
        libcurl libcurl
        sdl sdl
)

string(REPLACE "OFF" "disabled" FEATURE_OPTIONS "${FEATURE_OPTIONS}")
string(REPLACE "ON" "enabled" FEATURE_OPTIONS "${FEATURE_OPTIONS}")

if(VCPKG_TARGET_IS_WINDOWS)
    set(ctx_cli "disabled")
    list(APPEND FEATURE_OPTIONS "-Ddefault_library=static")
else()
    set(ctx_cli "auto")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-Dcli=${ctx_cli}"
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/ctx${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    vcpkg_copy_tools(TOOL_NAMES ctx AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(STRINGS "${SOURCE_PATH}/ctx.h" ctx_header_lines LIMIT_COUNT 32)
set(ctx_copyright "")
set(ctx_in_header_comment OFF)
foreach(line IN LISTS ctx_header_lines)
    if(NOT ctx_in_header_comment)
        if(line STREQUAL "/*")
            set(ctx_in_header_comment ON)
        endif()
    else()
        if(line STREQUAL " */")
            break()
        elseif(line MATCHES "^ \\* ?(.*)$")
            string(APPEND ctx_copyright "${CMAKE_MATCH_1}\n")
        endif()
    endif()
endforeach()

if(ctx_copyright STREQUAL "")
    message(FATAL_ERROR "Failed to extract copyright text from ${SOURCE_PATH}/ctx.h")
endif()

set(ctx_copyright_file "${CURRENT_BUILDTREES_DIR}/ctx-copyright.txt")
file(WRITE "${ctx_copyright_file}" "${ctx_copyright}")
vcpkg_install_copyright(FILE_LIST "${ctx_copyright_file}")
