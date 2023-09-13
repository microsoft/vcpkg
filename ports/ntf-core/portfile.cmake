vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bloomberg/ntf-core
    REF "${VERSION}"
    SHA512 57662d2dd105b2781e580623c26cd7bde84fce8374bbd70c18595a5f6934869b7a570f0d3c2e17e115f6c7eb1067541f8d19523639815b285324061f807d3179
    HEAD_REF main
    PATCHES dont-use-lib64.patch
)

# ntf-core requires debugger information to for dev tooling purposes, so we just fake it
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "-DNTF_BUILD_WITH_USAGE_EXAMPLES=0"
            "-DNTF_TOOLCHAIN_DEBUGGER_PATH=NOT-FOUND"
)

vcpkg_cmake_build()

vcpkg_cmake_install()

function(fix_pkgconfig_ufid lib_dir ufid pc_name)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/${lib_dir}/pkgconfig/${pc_name}.pc" "/${ufid}" "")
    if ("${ufid}" MATCHES opt)
        set(build_mode "release")
    else()
        set(build_mode "debug")
    endif()

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/${lib_dir}/cmake/${pc_name}Targets-${build_mode}.cmake" "/${ufid}" "")
endfunction()

function(fix_install_dir lib_dir ufid)
    message(STATUS "Fixing ufid layout for ${CURRENT_PACKAGES_DIR}/${lib_dir}/${ufid}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/${lib_dir}/${ufid}" "${CURRENT_PACKAGES_DIR}/tmp")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/${lib_dir}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tmp" "${CURRENT_PACKAGES_DIR}/${lib_dir}")

    fix_pkgconfig_ufid("${lib_dir}" "${ufid}" "nts")
    fix_pkgconfig_ufid("${lib_dir}" "${ufid}" "ntc")
endfunction()

fix_install_dir("lib" "opt_exc_mt")
fix_install_dir("debug/lib" "dbg_exc_mt")

# The ntf-core build installs CMake configs for both targets into share/ntf-core, which
# find_package will not be able to find on its own. We use vcpkg_cmake_config_fixup to install
# CMake configs into share/nts, and then move the ntc CMake configs into share/ntc with this
# function.
function(ntf_core_fixup_ntc_config)
    set(nts_share "${CURRENT_PACKAGES_DIR}/share/nts")
    set(ntc_share "${CURRENT_PACKAGES_DIR}/share/ntc")
    file(GLOB ntc_configs "${nts_share}/ntc*.cmake")
    file(MAKE_DIRECTORY "${ntc_share}")
    foreach(ntc_config IN LISTS ntc_configs)
        file(RELATIVE_PATH ntc_config_rel "${nts_share}" "${ntc_config}")
        file(RENAME "${ntc_config}" "${ntc_share}/${ntc_config_rel}")
    endforeach()
endfunction()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake" PACKAGE_NAME nts)
ntf_core_fixup_ntc_config()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_fixup_pkgconfig()

# Usage
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

