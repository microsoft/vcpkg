set(NSPR_VERSION "4.33")

vcpkg_download_distfile(ARCHIVE
    URLS "https://releases.mozilla.org/pub/nspr/releases/v${NSPR_VERSION}/src/nspr-${NSPR_VERSION}.tar.gz"
    FILENAME "nspr-${NSPR_VERSION}.tar.gz"
    SHA512 8064f826c977f1302a341ca7a7aaf7977b5d10102062c030b1d42b856638e3408ab262447e8c7cfd5a98879b9b1043d17ceae66fbb1e5ed86d6bc3531f26667e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF "${NSPR_VERSION}"
)

set(MOZBUILD_ROOT "${CURRENT_HOST_INSTALLED_DIR}/tools/mozbuild")

set(MOZBUILD_BINDIR "${MOZBUILD_ROOT}/bin")
vcpkg_add_to_path("${MOZBUILD_BINDIR}")

set(MOZBUILD_MSYS_ROOT "${MOZBUILD_ROOT}/msys")
vcpkg_add_to_path(PREPEND "${MOZBUILD_MSYS_ROOT}")

set(OPTIONS "")
if (VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS "--disable-static-rtl")
else()
    list(APPEND OPTIONS "--enable-static-rtl")
endif()

list(APPEND OPTIONS "--enable-win32-target=win95")

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    list(APPEND OPTIONS "--enable-64bit")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    list(APPEND OPTIONS "--disable-64bit")
else()
    message(FATAL_ERROR "Unsupported arch: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

set(OPTIONS_DEBUG
    "--enable-debug-rtl"
)

set(OPTIONS_RELEASE
    "--disable-debug-rtl"
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    CONFIGURE_ENVIRONMENT_VARIABLES CC CXX LD
    PROJECT_SUBPATH "nspr"
    OPTIONS ${OPTIONS}
    OPTIONS_DEBUG ${OPTIONS_DEBUG}
    OPTIONS_RELEASE ${OPTIONS_RELEASE}
    DISABLE_VERBOSE_FLAGS
)
vcpkg_install_make()
vcpkg_copy_pdbs()

#
# VCPKG FHS adjustments
#

# Release
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(GLOB BIN_RELEASE "${CURRENT_PACKAGES_DIR}/lib/*.dll" "${CURRENT_PACKAGES_DIR}/lib/*.pdb")
    list(LENGTH BIN_RELEASE BIN_RELEASE_SIZE)
    if (BIN_RELEASE_SIZE GREATER 0)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")

        foreach(path ${BIN_RELEASE})
            get_filename_component(name "${path}" NAME)
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/${name}" "${CURRENT_PACKAGES_DIR}/bin/${name}")
        endforeach()
    endif()
endif()

# Debug
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
    file(GLOB BIN_DEBUG "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll" "${CURRENT_PACKAGES_DIR}/debug/lib/*.pdb")
    list(LENGTH BIN_DEBUG BIN_DEBUG_SIZE)
    if (BIN_DEBUG_SIZE GREATER 0)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")

        foreach(path IN LISTS BIN_DEBUG)
            get_filename_component(name "${path}" NAME)
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/${name}" "${CURRENT_PACKAGES_DIR}/debug/bin/${name}")
        endforeach()
    endif()
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/nspr-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")

if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/nspr-config" "${CURRENT_INSTALLED_DIR}/debug" "`dirname $0`/../../../..")
endif()

# Copy license
file(INSTALL "${SOURCE_PATH}/nspr/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
