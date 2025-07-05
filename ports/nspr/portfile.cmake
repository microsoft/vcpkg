if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://releases.mozilla.org/pub/nspr/releases/v${VERSION}/src/nspr-${VERSION}.tar.gz"
    FILENAME "nspr-${VERSION}.tar.gz"
    SHA512 55d21e196508ad29a179639fc8006f44b04dc2c0b5a85895e727f0a4f0ea37aeeceb936e37ac6b271b882a18e9f06d96133a60f19cee6345f8424c1c66e270ee
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "${VERSION}"
    PATCHES
        android.diff
        library-linkage.diff
        nsinstall-windows.diff
        parallel.diff
)

set(OPTIONS "")
if(VCPKG_TARGET_IS_WINDOWS)
    # https://firefox-source-docs.mozilla.org/nspr/nspr_build_instructions.html#enable-win32-target-win95
    list(APPEND OPTIONS "--enable-win32-target=WIN95")
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        list(APPEND OPTIONS "--enable-static-rtl")
    else()
        list(APPEND OPTIONS "--disable-static-rtl")
    endif()
endif()

if(VCPKG_TARGET_ARCHITECTURE MATCHES "64")
    list(APPEND OPTIONS "--enable-64bit")
else()
    list(APPEND OPTIONS "--disable-64bit")
endif()

set(MAKE_OPTIONS "")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND MAKE_OPTIONS BUILD_SHARED_LIBS=1)
endif()

if(VCPKG_CROSSCOMPILING)
    list(APPEND MAKE_OPTIONS "NOW=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/now${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    if(NOT CMAKE_HOST_WIN32)
        list(APPEND MAKE_OPTIONS "NSINSTALL=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/nsinstall${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
endif()
if(CMAKE_HOST_WIN32)
    vcpkg_acquire_msys(MSYS_NSINSTALL
        NO_DEFAULT_PACKAGES
        DIRECT_PACKAGES
            "https://mirror.msys2.org/msys/x86_64/nsinstall-4.36-1-x86_64.pkg.tar.zst"
            36ceaf44db4368ef6319397cef1d82a752c68f3f7a16ca00e753ee7ae825058f22c38ccd750b53ea773212dffae838700be0d09288353db33d2f5197df9091df
    )
    list(APPEND MAKE_OPTIONS "NSINSTALL=${MSYS_NSINSTALL}/usr/bin/nsinstall${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}/nspr"
    AUTORECONF
    OPTIONS
        ${OPTIONS}
    OPTIONS_DEBUG
        --enable-debug-rtl
    OPTIONS_RELEASE
        --disable-debug-rtl
)
vcpkg_make_install(OPTIONS ${MAKE_OPTIONS})
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

set(install_dir_pattern "${CURRENT_INSTALLED_DIR}")
if(CMAKE_HOST_WIN32)
    string(REGEX REPLACE [[^([a-zA-Z]):/]] [[/\1/]] install_dir_pattern "${install_dir_pattern}")
endif()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/nspr-config" "${install_dir_pattern}" "`dirname $0`/../../..")
file(GLOB BIN_RELEASE "${CURRENT_PACKAGES_DIR}/lib/*.dll" "${CURRENT_PACKAGES_DIR}/lib/*.pdb")
if(NOT BIN_RELEASE STREQUAL "")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    foreach(path ${BIN_RELEASE})
        get_filename_component(name "${path}" NAME)
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/${name}" "${CURRENT_PACKAGES_DIR}/bin/${name}")
    endforeach()
endif()
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/nspr-config" "${install_dir_pattern}/debug" "`dirname $0`/../../../..")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
    file(GLOB BIN_DEBUG "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll" "${CURRENT_PACKAGES_DIR}/debug/lib/*.pdb")
    if(NOT BIN_DEBUG STREQUAL "")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
        foreach(path IN LISTS BIN_DEBUG)
            get_filename_component(name "${path}" NAME)
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/${name}" "${CURRENT_PACKAGES_DIR}/debug/bin/${name}")
        endforeach()
    endif()
endif()

if(NOT VCPKG_CROSSCOMPILING)
    set(tool_names now nsinstall)
    if(CMAKE_HOST_WIN32)
        list(REMOVE_ITEM tool_names nsinstall)
    endif()
    vcpkg_copy_tools(
        TOOL_NAMES ${tool_names}
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/config"
        DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}"
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/nspr/LICENSE")
