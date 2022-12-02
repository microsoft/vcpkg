# This port represents a dependency on the Meson build system.
# In the future, it is expected that this port acquires and installs Meson.
# Currently is used in ports that call vcpkg_find_acquire_program(MESON) in order to force rebuilds.

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(program MESON)
set(program_version 0.64.1)
set(program_name meson)
set(search_names meson meson.py)
set(interpreter PYTHON3)
set(apt_package_name "meson")
set(brew_package_name "meson")
set(ref e000aa11373298c6c07e264d4436b5075210bd11)
set(paths_to_search "${CURRENT_PACKAGES_DIR}/tools/meson")
set(download_urls "https://github.com/mesonbuild/meson/archive/${ref}.tar.gz")
set(download_filename "meson-${ref}.tar.gz")
set(download_sha512 a51f799183bdcf309b52487e3b98b7b9a83379c411375369b24fdb1ebd3eedd550b922fe98117040c8033c8b476a12c9e730c67c403efa711802dfdca88c34c8)
set(supported_on_unix ON)
set(version_command --version)
set(extra_search_args EXACT_VERSION_MATCH)

vcpkg_find_acquire_program(PYTHON3)

# Reenable if no patching of meson is required within vcpkg
# z_vcpkg_find_acquire_program_find_external("${program}"
#    ${extra_search_args}
#    PROGRAM_NAME "${program_name}"
#    MIN_VERSION "${program_version}"
#    INTERPRETER "${interpreter}"
#    NAMES ${search_names}
#    VERSION_COMMAND ${version_command}
# )

if(NOT "${program}")
    vcpkg_download_distfile(
        python_module_path
        URLS https://raw.githubusercontent.com/mesonbuild/meson/9c6dab2cfd310ef2d840a2a7a479ce6b9e563b1d/mesonbuild/modules/python.py
        FILENAME python-meson-module-9c6dab.py
        SHA512 6e93dad2d12929757a37b97c44f697413504e7238ff7bb4e87925a3b5ba6d9eae7c25ae4d1a022ee836747fac760662a33d1ea88c7c74712673ce64e538eb691
    )
    vcpkg_download_distfile(archive_path
        URLS ${download_urls}
        SHA512 "${download_sha512}"
        FILENAME "${download_filename}"
    )
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
    vcpkg_execute_in_download_mode(
                        COMMAND "${CMAKE_COMMAND}" -E tar xzf "${archive_path}"
                        WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools"
                    )
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/meson-${ref}" "${CURRENT_PACKAGES_DIR}/tools/meson")
    z_vcpkg_apply_patches(
        SOURCE_PATH "${CURRENT_PACKAGES_DIR}"
        PATCHES
            meson-intl.patch
            remove-python-lib-dep.patch # to avoid auto linking the wrong python libs for python extensions
    )
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/meson/test cases")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)
    file(INSTALL "${python_module_path}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/meson/mesonbuild/modules" RENAME "python.py")
endif()

z_vcpkg_find_acquire_program_find_internal("${program}"
    INTERPRETER "${interpreter}"
    PATHS ${paths_to_search}
    NAMES ${search_names}
)

message(STATUS "Using meson: ${MESON}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/meson/version.txt" "${program_version}") # For vcpkg_find_acquire_program
