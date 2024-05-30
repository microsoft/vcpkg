# Overwrite builtin scripts
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_configure_meson.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_install_meson.cmake")

set(meson_short_hash @MESON_SHORT_HASH@)

# Setup meson:
set(program MESON)
set(program_version @VERSION@)
set(program_name meson)
set(search_names meson meson.py)
set(ref 614d436232d3a86518164cbe2b8af12db3bde009)
set(path_to_search "${DOWNLOADS}/tools/meson-${program_version}-${meson_short_hash}")
set(download_urls "https://github.com/mesonbuild/meson/archive/${ref}.tar.gz")
set(download_filename "meson-${ref}.tar.gz")
set(download_sha512 c087da0113e76501fff66e68ac9ef7aede5e6672f1dc7201608cce9e5e1d202d3f4bf92beec1a5e4e8169f6ed1cedbb44b57ede2753437a61a13578de8d22040)

find_program(SCRIPT_MESON NAMES ${search_names} PATHS "${path_to_search}" NO_DEFAULT_PATH) # NO_DEFAULT_PATH due top patching

if(NOT SCRIPT_MESON)
    vcpkg_download_distfile(archive_path
        URLS ${download_urls}
        SHA512 "${download_sha512}"
        FILENAME "${download_filename}"
    )
    file(REMOVE_RECURSE "${path_to_search}")
    file(REMOVE_RECURSE "${path_to_search}-tmp")
    file(MAKE_DIRECTORY "${path_to_search}-tmp")
    file(ARCHIVE_EXTRACT INPUT "${archive_path}"
        DESTINATION "${path_to_search}-tmp"
        #PATTERNS "**/mesonbuild/*" "**/*.py"
        )
    z_vcpkg_apply_patches(
        SOURCE_PATH "${path_to_search}-tmp/meson-${ref}"
        PATCHES
            @PATCHES@
    )
    file(MAKE_DIRECTORY "${path_to_search}")
    file(RENAME "${path_to_search}-tmp/meson-${ref}/meson.py" "${path_to_search}/meson.py")
    file(RENAME "${path_to_search}-tmp/meson-${ref}/mesonbuild" "${path_to_search}/mesonbuild")
    file(REMOVE_RECURSE "${path_to_search}-tmp")
    set(SCRIPT_MESON "${path_to_search}/meson.py")
endif()

# Check required python version
vcpkg_find_acquire_program(PYTHON3)
vcpkg_execute_required_process(COMMAND "${PYTHON3}" --version
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
            LOGNAME "python3-version-${TARGET_TRIPLET}")

file(READ "${CURRENT_BUILDTREES_DIR}/python3-version-${TARGET_TRIPLET}-out.log" version_contents)
string(REGEX MATCH [[[0-9]+\.[0-9]+\.[0-9]+]] python_ver "${version_contents}")

set(min_required 3.7)
if(python_ver VERSION_LESS "${min_required}")
    message(FATAL_ERROR "Found Python version '${python_ver} at ${PYTHON3}' is insufficient for meson. meson requires at least version '${min_required}'")
else()
    message(STATUS "Found Python version '${python_ver} at ${PYTHON3}'")
endif()

message(STATUS "Using meson: ${SCRIPT_MESON}")
