set(LIBPNG_VER 1.6.37)

# Download the apng patch
set(LIBPNG_APNG_OPTION )
if ("apng" IN_LIST FEATURES)
    # Get (g)awk installed
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES gawk)
    set(AWK_EXE_PATH "${MSYS_ROOT}/usr/bin")
    vcpkg_add_to_path("${AWK_EXE_PATH}")
    
    set(LIBPNG_APG_PATCH_NAME libpng-${LIBPNG_VER}-apng.patch)
    set(LIBPNG_APG_PATCH_PATH ${CURRENT_BUILDTREES_DIR}/src/${LIBPNG_APG_PATCH_NAME})
    if (NOT EXISTS ${LIBPNG_APG_PATCH_PATH})
        if (NOT EXISTS ${CURRENT_BUILDTREES_DIR}/src)
            file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src)
        endif()
        vcpkg_download_distfile(LIBPNG_APNG_PATCH_ARCHIVE
            URLS "https://downloads.sourceforge.net/project/libpng-apng/libpng16/${LIBPNG_VER}/${LIBPNG_APG_PATCH_NAME}.gz"
            FILENAME "${LIBPNG_APG_PATCH_NAME}.gz"
            SHA512 226adcb3a8c60f2267fe2976ab531329ae43c2603dab4d0cf8f16217d64069936b879f3d6516b75d259c47d6f5c5b1f24f887602206c8e46abde0fb7f5c7946b
        )
        vcpkg_find_acquire_program(7Z)
        vcpkg_execute_required_process(
            COMMAND ${7Z} x ${LIBPNG_APNG_PATCH_ARCHIVE} -aoa
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src
            LOGNAME extract-patch.log
        )
    endif()
    set(APNG_EXTRA_PATCH ${LIBPNG_APG_PATCH_PATH})
    set(LIBPNG_APNG_OPTION "-DPNG_PREFIX=a")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO glennrp/libpng
    REF v${LIBPNG_VER}
    SHA512 ccb3705c23b2724e86d072e2ac8cfc380f41fadfd6977a248d588a8ad57b6abe0e4155e525243011f245e98d9b7afbe2e8cc7fd4ff7d82fcefb40c0f48f88918
    HEAD_REF master
    PATCHES
        use_abort.patch
        cmake.patch
        pkgconfig.patch
        pkgconfig.2.patch
        ${APNG_EXTRA_PATCH}
        fix-export-targets.patch
        macos-arch-fix.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(PNG_STATIC_LIBS OFF)
    set(PNG_SHARED_LIBS ON)
else()
    set(PNG_STATIC_LIBS ON)
    set(PNG_SHARED_LIBS OFF)
endif()

set(LIBPNG_HARDWARE_OPTIMIZATIONS_OPTION )
if(VCPKG_TARGET_IS_IOS)
    list(APPEND LIBPNG_HARDWARE_OPTIMIZATIONS_OPTION "-DPNG_HARDWARE_OPTIMIZATIONS=OFF")
endif()

set(LD_VERSION_SCRIPT_OPTION )
if(VCPKG_TARGET_IS_ANDROID)
    set(LD_VERSION_SCRIPT_OPTION "-Dld-version-script=OFF")
    # for armeabi-v7a, check whether NEON is available
    list(APPEND LIBPNG_HARDWARE_OPTIMIZATIONS_OPTION "-DPNG_ARM_NEON=check")
else()
    list(APPEND LIBPNG_HARDWARE_OPTIMIZATIONS_OPTION "-DPNG_ARM_NEON=on")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DPNG_MAN_DIR=share/${PORT}/man
        ${LIBPNG_APNG_OPTION}
        ${LIBPNG_HARDWARE_OPTIMIZATIONS_OPTION}
        ${LD_VERSION_SCRIPT_OPTION}
        -DPNG_STATIC=${PNG_STATIC_LIBS}
        -DPNG_SHARED=${PNG_SHARED_LIBS}
        -DPNG_TESTS=OFF
        -DSKIP_INSTALL_PROGRAMS=ON
        -DSKIP_INSTALL_EXECUTABLES=ON
        -DSKIP_INSTALL_FILES=OFF
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/libpng)
set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpng16.pc")
if(EXISTS ${_file})
    file(READ "${_file}" _contents)
    if(VCPKG_TARGET_IS_WINDOWS)
        string(REGEX REPLACE "-lpng16(d)?" "-llibpng16d" _contents "${_contents}")
    else()
        string(REGEX REPLACE "-lpng16(d)?" "-lpng16d" _contents "${_contents}")
    endif()
    if(VCPKG_TARGET_IS_MINGW)
        string(REPLACE "-lz" "-lzlibd" _contents "${_contents}")
    else()
        string(REPLACE "-lzlib" "-lzlibd" _contents "${_contents}")
    endif()
    file(WRITE "${_file}" "${_contents}")
endif()
set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpng.pc")
if(EXISTS ${_file})
    file(READ "${_file}" _contents)
    if(VCPKG_TARGET_IS_WINDOWS)
        string(REGEX REPLACE "-lpng16(d)?" "-llibpng16d" _contents "${_contents}")
    else()
        string(REGEX REPLACE "-lpng16(d)?" "-lpng16d" _contents "${_contents}")
    endif()
    if(VCPKG_TARGET_IS_MINGW)
        string(REPLACE "-lz" "-lzlibd" _contents "${_contents}")
    else()
        string(REPLACE "-lzlib" "-lzlibd" _contents "${_contents}")
    endif()
    file(WRITE "${_file}" "${_contents}")
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libpng16.pc")
    if(EXISTS ${_file})
        file(READ "${_file}" _contents)
        string(REPLACE "-lpng16" "-llibpng16" _contents "${_contents}")
        if(VCPKG_TARGET_IS_MINGW)
            string(REPLACE "-lz" "-lzlib" _contents "${_contents}")
        endif()
        file(WRITE "${_file}" "${_contents}")
    endif()
    set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libpng.pc")
    if(EXISTS ${_file})
        file(READ "${_file}" _contents)
        string(REPLACE "-lpng16" "-llibpng16" _contents "${_contents}")
        if(VCPKG_TARGET_IS_MINGW)
            string(REPLACE "-lz" "-lzlib" _contents "${_contents}")
        endif()
        file(WRITE "${_file}" "${_contents}")
    endif()
endif()
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES m)

vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools" "${CURRENT_PACKAGES_DIR}/debug/tools")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
