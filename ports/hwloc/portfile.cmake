string(REGEX MATCH "^[0-9]+\\.[0-9]+" HWLOC_SHORT_VERSION "${VERSION}")
vcpkg_download_distfile(ARCHIVE
    URLS "https://download.open-mpi.org/release/hwloc/v${HWLOC_SHORT_VERSION}/hwloc-${VERSION}.tar.bz2"
    FILENAME "hwloc-${VERSION}.tar.bz2"
    SHA512 05b1df51d792c6136744cba24119fe7f403b25825c4f5d1882cebb26da29f6b323905d5ed350cb91bec372ebd4b9d04b8858867419f0955fdda530c1626a67ed
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix_shared_win_build.patch
        stdout_fileno.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(OPTIONS ac_cv_prog_cc_c99= # To avoid the compiler check for C99 which will fail for MSVC
                --disable-plugin-dlopen)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS "HWLOC_LDFLAGS=-no-undefined")
elseif(VCPKG_TARGET_IS_OSX)
    list(APPEND OPTIONS "HWLOC_LDFLAGS=-framework CoreFoundation")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${OPTIONS}
        --disable-libxml2
        --disable-opencl
        --disable-cairo
        --disable-gl
        --disable-cuda
        --disable-libudev
        --disable-levelzero
        --disable-nvml
        --disable-rsmi
        --disable-pci
        #--disable-cpuid
        #--disable-picky
)

vcpkg_install_make()
if(VCPKG_TARGET_IS_ANDROID)
    # Android provides pthread functions in libc, not a separate libpthread.
    foreach(config IN ITEMS "" "debug/")
        if(EXISTS "${CURRENT_PACKAGES_DIR}/${config}lib/pkgconfig/hwloc.pc")
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/${config}lib/pkgconfig/hwloc.pc" " -lpthread" "")
        endif()
    endforeach()
endif()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(EXISTS "${CURRENT_PACKAGES_DIR}/tools/hwloc/bin/hwloc-compress-dir")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/hwloc/bin/hwloc-compress-dir" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../.." IGNORE_UNCHANGED)
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/tools/hwloc/debug/bin/hwloc-compress-dir")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/hwloc/debug/bin/hwloc-compress-dir" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../.." IGNORE_UNCHANGED)
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/tools/hwloc/bin/hwloc-gather-topology")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/hwloc/bin/hwloc-gather-topology" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/tools/hwloc/debug/bin/hwloc-gather-topology")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/hwloc/debug/bin/hwloc-gather-topology" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
endif()

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/COPYING"
    "${SOURCE_PATH}/hwloc/base64.c"
)

file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/COPYING.txt"
            "${CURRENT_PACKAGES_DIR}/debug/README.txt"
            "${CURRENT_PACKAGES_DIR}/debug/NEWS.txt"
            "${CURRENT_PACKAGES_DIR}/COPYING.txt"
            "${CURRENT_PACKAGES_DIR}/README.txt"
            "${CURRENT_PACKAGES_DIR}/NEWS.txt"
    )
