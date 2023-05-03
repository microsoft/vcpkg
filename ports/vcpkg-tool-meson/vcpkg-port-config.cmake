# Overwrite builtin scripts
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_configure_meson.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_install_meson.cmake")

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

# Setup meson:
set(program MESON)
set(program_version 1.1.0)
set(program_name meson)
set(search_names meson meson.py)
set(ref ae163a3f3e0ccdcbea97c8ad0e78f087925646b9)
set(path_to_search "${DOWNLOADS}/tools/meson-${program_version}")
set(download_urls "https://github.com/mesonbuild/meson/archive/${ref}.tar.gz")
set(download_filename "meson-${ref}.tar.gz")
set(download_sha512 1bc5be2dc3a26b811bbeaf8f8b8d14900a00975a2e50f2f4b3da4da067114268fd5da76d9365a811d2dcdc8c63bae9adc08f743954ca4e8cf8c49bba36973490)

find_program(SCRIPT_MESON NAMES ${search_names} PATHS "${path_to_search}" NO_DEFAULT_PATH) # NO_DEFAULT_PATH due top patching

if(NOT SCRIPT_MESON)
    vcpkg_download_distfile(archive_path
        URLS ${download_urls}
        SHA512 "${download_sha512}"
        FILENAME "${download_filename}"

    )
    file(MAKE_DIRECTORY "${path_to_search}/../")
    file(ARCHIVE_EXTRACT INPUT "${archive_path}"
        DESTINATION "${path_to_search}/../"
        #PATTERNS "**/mesonbuild/*" "**/*.py"
        )
    file(REMOVE_RECURSE "${path_to_search}/../meson-${ref}/test cases/")
    file(RENAME "${path_to_search}/../meson-${ref}" "${path_to_search}")
    z_vcpkg_apply_patches(
        SOURCE_PATH "${path_to_search}"
        PATCHES
            "${CMAKE_CURRENT_LIST_DIR}/meson-intl.patch"
            "${CMAKE_CURRENT_LIST_DIR}/adjust-python-dep.patch"
    )
    vcpkg_replace_string("${DOWNLOADS}/tools/meson-${program_version}/mesonbuild/cmake/toolchain.py" "arg.startswith('/')" "arg.startswith(('/','-'))")
    set(SCRIPT_MESON "${DOWNLOADS}/tools/meson-${program_version}/meson.py")
endif()

message(STATUS "Using meson: ${SCRIPT_MESON}")
