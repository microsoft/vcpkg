string(REPLACE "." "_" graphicsmagick_version "GraphicsMagick-${VERSION}")

vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://foss.heptapod.net/
    REPO graphicsmagick/graphicsmagick
    REF ${graphicsmagick_version}
    SHA512 e64842dbbe2026e7d75b4004f615f32b4e2d57ce8dbd9bc90f87ee6e180d7e2feb61da6c25d404c43ac8d7661f94f7be3bd2882928dbd0e276b5c9040690f6f4
    PATCHES
        dependencies.diff
        magick-types.diff
)

set(options "")
if(VCPKG_TARGET_IS_WINDOWS)
    set(options ac_cv_header_dirent_dirent_h=no)
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        ${options}
        # Before enabling another lib, make sure that the build does not
        # hard-code the library name and dependencies (cf. dependencies.diff).
        --with-heif=no
        --with-fpx=no  ###
        --with-gs=no
        --with-jbig=no
        --with-jp2=no
        --with-jxl=no
        --with-lcms2=no
        --with-libzip=no
        --with-lzma=no
        --with-modules=no
        --with-mpeg2=no
        --with-trio=no
        --with-x=no
        --with-xml=no
        --with-wmf=no
        --with-zstd=no
)
vcpkg_make_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/gm${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")

set(config_scripts
    "GraphicsMagick++-config"
    "GraphicsMagick-config"
    "GraphicsMagickWand-config"
)
string(REGEX REPLACE "^([A-Za-z]):/" "/\\1/" literal_prefix "${CURRENT_INSTALLED_DIR}")
foreach(filename IN LISTS config_scripts)
    set(file "${CURRENT_PACKAGES_DIR}/tools/graphicsmagick/bin/${filename}")
    vcpkg_replace_string("${file}" "${literal_prefix}" "'\"\${prefix}\"'")
    vcpkg_replace_string("${file}" "while test" "prefix=$(CDPATH= cd -- \"$(dirname -- \"$0\")/../../..\" && pwd -P)\n\nwhile test")
    if(NOT VCPKG_BUILD_TYPE)
        set(debug_file "${CURRENT_PACKAGES_DIR}/tools/graphicsmagick/debug/bin/${filename}")
        vcpkg_replace_string("${debug_file}" "${literal_prefix}" "'\"\${prefix}\"'")
        vcpkg_replace_string("${debug_file}" "while test" "prefix=$(CDPATH= cd -- \"$(dirname -- \"$0\")/../../../..\" && pwd -P)\n\nwhile test")
    endif()
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Copyright.txt")
