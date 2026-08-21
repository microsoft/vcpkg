# ImageMagick vcpkg port
# Uses autotools on all platforms (including Windows via MSYS2).
# On Windows/MSVC: cl_wrapper.sh translates GCC-style flags to MSVC for libtool.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ImageMagick/ImageMagick
    REF 7.1.2-18
    SHA512 168326e62c2ca5608a660e030b9777c7200458f9eb128854867e9bf20e1aa3d603a819aa3095fb3cf13133ceb9a9c9859374b7ce872bebb179c3afdf943ec831
    HEAD_REF main
    PATCHES
        patches/0001-fix-zstd-pkgconfig-prefix.patch
        patches/0002-fix-fallthrough-msvc-c-mode.patch
        patches/0003-fix-cppflags-crt-conflict.patch
        patches/0004-fix-uhdr-cpp-compat.patch
        patches/0005-fix-warning-directive-msvc.patch
        patches/0006-fix-winpathscript-init-order.patch
)

# ── Feature → configure flag mapping ──────────────────────────────────────────
macro(_im_feature_flag _feature _flag)
    if("${_feature}" IN_LIST FEATURES)
        list(APPEND _configure_args "--with-${_flag}=yes")
    else()
        list(APPEND _configure_args "--with-${_flag}=no")
    endif()
endmacro()

set(_configure_args "")

# HDRI and quantum depth
if("hdri" IN_LIST FEATURES)
    list(APPEND _configure_args "--enable-hdri=yes")
    set(_im_hdri ON)
    set(_im_hdri_val 1)
else()
    list(APPEND _configure_args "--enable-hdri=no")
    set(_im_hdri OFF)
    set(_im_hdri_val 0)
endif()

# Quantum depth — mutually exclusive (q8, q16, q32)
set(_im_q_count 0)
foreach(_q q8 q16 q32)
    if("${_q}" IN_LIST FEATURES)
        math(EXPR _im_q_count "${_im_q_count} + 1")
    endif()
endforeach()
if(_im_q_count GREATER 1)
    message(FATAL_ERROR "Features q8, q16 and q32 are mutually exclusive — select at most one.")
endif()

if("q32" IN_LIST FEATURES)
    set(_im_qdepth 32)
elseif("q8" IN_LIST FEATURES)
    set(_im_qdepth 8)
else()
    set(_im_qdepth 16)
endif()
list(APPEND _configure_args "--with-quantum-depth=${_im_qdepth}")

# Build the lib suffix: e.g. Q16HDRI, Q8, Q32HDRI
set(_im_qsuffix "Q${_im_qdepth}")
if(_im_hdri)
    string(APPEND _im_qsuffix "HDRI")
endif()

# Shared/static
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND _configure_args "--enable-shared=yes" "--enable-static=no")
else()
    list(APPEND _configure_args "--enable-shared=no" "--enable-static=yes")
endif()

# Delegate libraries
list(APPEND _configure_args "--with-zlib=yes")  # always on (base dependency)
_im_feature_flag(bzip2      bzlib)
_im_feature_flag(lzma       lzma)
_im_feature_flag(zstd       zstd)
_im_feature_flag(png        png)
_im_feature_flag(jpeg       jpeg)
_im_feature_flag(tiff       tiff)
_im_feature_flag(webp       webp)
_im_feature_flag(freetype   freetype)
_im_feature_flag(xml2       xml)
_im_feature_flag(lcms       lcms)
_im_feature_flag(openexr    openexr)
_im_feature_flag(heif       heic)
_im_feature_flag(openjp2    openjp2)
_im_feature_flag(jxl        jxl)
_im_feature_flag(raw        raw)
_im_feature_flag(uhdr       uhdr)
_im_feature_flag(fontconfig fontconfig)
_im_feature_flag(fftw       fftw)
_im_feature_flag(pango      pango)
_im_feature_flag(zip        zip)
_im_feature_flag(jbig       jbig)
_im_feature_flag(raqm       raqm)
_im_feature_flag(rsvg       rsvg)
_im_feature_flag(gvc        gvc)

# X11 — only meaningful on Unix
if("x11" IN_LIST FEATURES)
    list(APPEND _configure_args "--with-x=yes")
else()
    list(APPEND _configure_args "--without-x")
endif()

# OpenMP — available on MSVC and GCC; Clang (all platforms) lacks it by default
if("openmp" IN_LIST FEATURES)
    list(APPEND _configure_args "--enable-openmp=yes")
else()
    list(APPEND _configure_args "--enable-openmp=no")
endif()

# Zero-configuration: embed config in binary, no external XML files needed
if("zero-configuration" IN_LIST FEATURES)
    list(APPEND _configure_args "--enable-zero-configuration")
else()
    list(APPEND _configure_args "--disable-zero-configuration")
endif()

# Always-disabled delegates (no vcpkg port exists)
list(APPEND _configure_args
    "--without-perl"
    "--with-magick-plus-plus=yes"
    "--with-modules=no"
    "--disable-docs"
    "--disable-installed"
    "--with-utilities=no"
    "--without-djvu"
    "--without-lqr"
    "--without-wmf"
    "--without-autotrace"
    "--without-flif"
    "--without-fpx"
    "--without-dps"
    "--without-gslib"
    "--without-dmr"
)

# Windows-specific libtool workaround: skip file_magic format checks
# (MSVC .lib are MS-COFF, not ELF/PE)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND _configure_args "lt_cv_deplibs_check_method=pass_all")
endif()

# ── MSVC/clang-cl-specific setup ──────────────────────────────────────────────
if(VCPKG_TARGET_IS_WINDOWS)
    # Install cl/lib wrapper scripts for libtool MSVC mode
    set(_wrapper_dir "${CURRENT_BUILDTREES_DIR}/cl_wrappers")
    file(REMOVE_RECURSE "${_wrapper_dir}")
    file(MAKE_DIRECTORY "${_wrapper_dir}")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/cl_wrapper.sh" DESTINATION "${_wrapper_dir}")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/lib_wrapper.sh" DESTINATION "${_wrapper_dir}")
    file(RENAME "${_wrapper_dir}/cl_wrapper.sh" "${_wrapper_dir}/cl")
    file(RENAME "${_wrapper_dir}/lib_wrapper.sh" "${_wrapper_dir}/lib")

    # Make wrappers executable (needed by MSYS2 bash)
    execute_process(COMMAND chmod +x "${_wrapper_dir}/cl" "${_wrapper_dir}/lib"
                    ERROR_QUIET)

    # Convert Windows paths to MSYS2 /drive/... format for configure
    string(REGEX REPLACE "^([A-Za-z]):" "/\\1" _msys_wrapper_dir "${_wrapper_dir}")
    string(REPLACE "\\" "/" _msys_wrapper_dir "${_msys_wrapper_dir}")

    list(APPEND _configure_args
        "CC=${_msys_wrapper_dir}/cl"
        "CXX=${_msys_wrapper_dir}/cl"
    )

    # Detect compiler: clang-cl vs MSVC cl.exe
    if(VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "clang-cl")
        set(_real_cc "clang-cl.exe")
        set(_real_lib "llvm-lib.exe")
    else()
        set(_real_cc "cl.exe")
        set(_real_lib "lib.exe")
    endif()

    # CXXCPP needs -nologo to suppress banner that confuses configure sanity check
    list(APPEND _configure_args "CXXCPP=${_real_cc} -nologo -E")

    set(ENV{CXXFLAGS} "$ENV{CXXFLAGS} -EHsc")

    # Tell wrappers where to find the real compiler/archiver
    set(ENV{REAL_CC} "${_real_cc}")
    set(ENV{REAL_LIB} "${_real_lib}")

    # Pre-seed configure cache to avoid failing AC_CHECK_LIB tests
    if("bzip2" IN_LIST FEATURES)
        list(APPEND _configure_args "ac_cv_lib_bz2_BZ2_bzDecompress=yes")
    endif()
    if("jpeg" IN_LIST FEATURES)
        list(APPEND _configure_args "ac_cv_lib_jpeg_jpeg_read_header=yes")
    endif()

    # Tell configure the compiler understands -c -o together.
    # Our cl_wrapper.sh translates -o → -Fo/-Fe, so config/compile is not needed.
    # This prevents automake from inserting config/compile into the build chain,
    # which has incomplete library resolution (misses lib-prefixed .lib, debug
    # suffixes, and versioned names).  All -l/-L flags now go through cl_wrapper.sh.
    list(APPEND _configure_args "am_cv_prog_cc_c_o=yes")

    # Windows system libraries (cl wrapper translates -lfoo → foo.lib)
    set(ENV{LDFLAGS} "$ENV{LDFLAGS} -ladvapi32 -lgdi32 -luser32 -lole32 -loleaut32")
endif()

# ── Autotools configure + build ──────────────────────────────────────────────
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${_configure_args}
)

# Post-configure fixup: patch config/compile for MSVC library name resolution.
# Must be applied AFTER vcpkg_configure_make (which runs autoreconf and regenerates config/compile)
# but BEFORE vcpkg_build_make.  The automake compile script's func_cl_dashl() misses:
#   - lib-prefixed .lib files  (e.g. libde265.lib  for -lde265)
#   - debug-suffixed .lib files (e.g. bz2d.lib     for -lbz2)
#   - versioned .lib files      (e.g. openjph.0.27d.lib for -lopenjph)
# NOTE: This is now bypassed by am_cv_prog_cc_c_o=yes which prevents config/compile
#       from being inserted.  Kept as fallback in case the approach is reverted.
if(FALSE AND VCPKG_TARGET_IS_WINDOWS)
    set(_compile_script "${SOURCE_PATH}/config/compile")
    if(EXISTS "${_compile_script}")
        file(READ "${_compile_script}" _compile_content)
        # Inject additional candidates after the "$lib.lib" block, before "lib$lib.a"
        string(REPLACE
[[    if test -f "$dir/lib$lib.a"; then]]
[[    if test -f "$dir/lib$lib.lib"; then
      found=yes
      lib=$dir/lib$lib.lib
      break
    fi
    # Debug-suffix candidates (e.g. bz2d.lib for -lbz2, raw_rd.lib for -lraw_r)
    if test -f "$dir/${lib}d.lib"; then
      found=yes
      lib=$dir/${lib}d.lib
      break
    fi
    if test -f "$dir/lib${lib}d.lib"; then
      found=yes
      lib=$dir/lib${lib}d.lib
      break
    fi
    # Versioned candidates (e.g. openjph.0.27d.lib for -lopenjph).
    # Only accept when exactly one file matches the glob.
    set -- "$dir/$lib".*.lib
    if test $# -eq 1 && test -f "$1"; then
      found=yes
      lib=$1
      break
    fi
    set -- "$dir/lib$lib".*.lib
    if test $# -eq 1 && test -f "$1"; then
      found=yes
      lib=$1
      break
    fi
    if test -f "$dir/lib$lib.a"; then]]
            _compile_content "${_compile_content}"
        )
        file(WRITE "${_compile_script}" "${_compile_content}")
    endif()
endif()

# Post-configure Makefile fixups (Windows only)
if(VCPKG_TARGET_IS_WINDOWS)
    foreach(_buildtype IN ITEMS "rel" "dbg")
        if(_buildtype STREQUAL "rel")
            set(_makefile "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Makefile")
        else()
            set(_makefile "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Makefile")
        endif()

        if(EXISTS "${_makefile}")
            file(READ "${_makefile}" _mk_content)

            # 1. Compile coders/emf.c as C++ (needs <gdiplus.h> with namespaces)
            string(APPEND _mk_content
                "\n# Per-file C++ mode for emf.c (needs <gdiplus.h>)\n"
                "coders/MagickCore_libMagickCore_7_${_im_qsuffix}_la-emf.lo: CFLAGS += -TP\n"
                "coders/emf_la-emf.lo: CFLAGS += -TP\n"
            )

            # 2. Inject _DLL/_LIB, _MT, and ssize_t defines
            # Note: _DLL is intentionally NOT defined here — it conflicts with
            # static CRT (-MT). ImageMagick uses _MAGICKLIB_ for dllexport
            # (already set by configure). _DLL would make CRT headers expect
            # the dynamic CRT import library.
            set(_extra_cppflags "-D_MT -Dssize_t=ptrdiff_t")
            if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
                string(APPEND _extra_cppflags " -D_LIB")
            endif()
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
                string(APPEND _extra_cppflags " -DWIN64")
            endif()
            string(REPLACE "\nCPPFLAGS = " "\nCPPFLAGS = ${_extra_cppflags} " _mk_content "${_mk_content}")

            file(WRITE "${_makefile}" "${_mk_content}")
        endif()
    endforeach()
endif()

vcpkg_build_make()
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

# The *-config shell scripts contain absolute build paths (harmless, they are
# developer helper tools for autotools consumers, not used by vcpkg consumers)
set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Remove .la files
file(GLOB _la_files "${CURRENT_PACKAGES_DIR}/lib/*.la" "${CURRENT_PACKAGES_DIR}/debug/lib/*.la")
if(_la_files)
    file(REMOVE ${_la_files})
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# ── Install CMake config (imagemagick) ────────────────────────────────────────
configure_file("${CMAKE_CURRENT_LIST_DIR}/imagemagickConfig.cmake"
               "${CURRENT_PACKAGES_DIR}/share/imagemagick/imagemagickConfig.cmake"
               @ONLY)

# ── Install config files (policy.xml, delegates.xml, etc.) ────────────────────
if("zero-configuration" IN_LIST FEATURES)
    # Zero-configuration mode: config is embedded in the binary, remove external files
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/etc")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/etc")
    file(GLOB _im_lib_dirs "${CURRENT_PACKAGES_DIR}/lib/ImageMagick-*")
    if(_im_lib_dirs)
        file(REMOVE_RECURSE ${_im_lib_dirs})
    endif()
    file(GLOB _im_lib_dirs_dbg "${CURRENT_PACKAGES_DIR}/debug/lib/ImageMagick-*")
    if(_im_lib_dirs_dbg)
        file(REMOVE_RECURSE ${_im_lib_dirs_dbg})
    endif()

    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "
imagemagick provides CMake targets:

    find_package(imagemagick CONFIG REQUIRED)
    target_link_libraries(main PRIVATE ImageMagick::Magick++)
    # Also available: ImageMagick::MagickCore, ImageMagick::MagickWand

Alternatively, via pkg-config:

    find_package(PkgConfig REQUIRED)
    pkg_check_modules(MagickCore REQUIRED IMPORTED_TARGET MagickCore-7.${_im_qsuffix})

This port was built with zero-configuration: all settings are embedded in the
binary. No external XML config files are needed at runtime.
")
else()
    # Standard mode: XML config files needed at runtime for initialization.
    # Collect from etc/ and lib/ImageMagick-*/config-* into share/imagemagick/config
    set(_config_dest "${CURRENT_PACKAGES_DIR}/share/${PORT}/config")
    file(MAKE_DIRECTORY "${_config_dest}")

    # Autotools installs policy, type maps, etc. to etc/ImageMagick-7/
    file(GLOB _etc_configs "${CURRENT_PACKAGES_DIR}/etc/ImageMagick-7/*.xml")
    if(_etc_configs)
        file(COPY ${_etc_configs} DESTINATION "${_config_dest}")
    endif()

    # Built-in config (configure.xml with compile-time paths) is in lib/ImageMagick-<ver>/config-Q16[HDRI]/
    file(GLOB_RECURSE _lib_configs "${CURRENT_PACKAGES_DIR}/lib/ImageMagick-*/config*/*.xml")
    if(_lib_configs)
        file(COPY ${_lib_configs} DESTINATION "${_config_dest}")
    endif()

    # Clean up original locations (consumers should use share/imagemagick/config)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/etc")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/etc")
    file(GLOB _im_lib_dirs "${CURRENT_PACKAGES_DIR}/lib/ImageMagick-*")
    if(_im_lib_dirs)
        file(REMOVE_RECURSE ${_im_lib_dirs})
    endif()
    file(GLOB _im_lib_dirs_dbg "${CURRENT_PACKAGES_DIR}/debug/lib/ImageMagick-*")
    if(_im_lib_dirs_dbg)
        file(REMOVE_RECURSE ${_im_lib_dirs_dbg})
    endif()

    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "
imagemagick provides CMake targets:

    find_package(imagemagick CONFIG REQUIRED)
    target_link_libraries(main PRIVATE ImageMagick::Magick++)
    # Also available: ImageMagick::MagickCore, ImageMagick::MagickWand

Alternatively, via pkg-config:

    find_package(PkgConfig REQUIRED)
    pkg_check_modules(MagickCore REQUIRED IMPORTED_TARGET MagickCore-7.${_im_qsuffix})

ImageMagick requires XML configuration files at runtime (policy.xml, delegates.xml, etc.).
They are installed to:

    ${CURRENT_INSTALLED_DIR}/share/imagemagick/config

Set the MAGICK_CONFIGURE_PATH environment variable to this directory, or copy its
contents next to your executable. Without these files, MagickCoreGenesis() will fail.
")
endif()
