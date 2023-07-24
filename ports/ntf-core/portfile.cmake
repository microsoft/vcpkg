vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bloomberg/ntf-core
    REF "${VERSION}"
    SHA512 57662d2dd105b2781e580623c26cd7bde84fce8374bbd70c18595a5f6934869b7a570f0d3c2e17e115f6c7eb1067541f8d19523639815b285324061f807d3179
    HEAD_REF main
)

function (ntf_configure var val)
    set(ENV{NTF_CONFIGURE_${var}} ${val})
endfunction()

ntf_configure(WITH_MOCKS 0)
ntf_configure(WITH_APPLICATIONS 0)
ntf_configure(WITH_TESTS 0)
ntf_configure(WITH_USAGE_EXAMPLES 0)
ntf_configure(FROM_PACKAGING 1)
ntf_configure(WITH_BSL 1)
ntf_configure(WITH_BAL 1)
ntf_configure(WITH_BDL 1)
ntf_configure(WITH_NTS 1)
ntf_configure(WITH_NTC 1)
ntf_configure(WITH_ADDRESS_FAMILY_IPV4 1)
ntf_configure(WITH_ADDRESS_FAMILY_IPV6 1)
ntf_configure(WITH_ADDRESS_FAMILY_LOCAL 1)
ntf_configure(WITH_TRANSPORT_PROTOCOL_TCP 1)
ntf_configure(WITH_TRANSPORT_PROTOCOL_UDP 1)
ntf_configure(WITH_TRANSPORT_PROTOCOL_LOCAL 1)
ntf_configure(WITH_SELECT 1)
ntf_configure(WITH_POLL 1)
ntf_configure(WITH_DYNAMIC_LOAD_BALANCING 1)
ntf_configure(WITH_THREAD_SCALING 1)
ntf_configure(WITH_BRANCH_PREDICTION 1)
ntf_configure(WITH_WITH_METRICS 1)

if(${VCPKG_TARGET_IS_LINUX})
    ntf_configure(WITH_EPOLL 1)
elseif(${VCPKG_TARGET_IS_OSX})
    ntf_configure(WITH_KQUEUE 1)
elseif(${VCPKG_TARGET_IS_WINDOWS})
    ntf_configure(WITH_IOCP 1)
endif()


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_build()

vcpkg_cmake_install()

function(replace_in_file file_path to_match to_replace)
    file(READ  "${file_path}" file_contents)
    string(REPLACE "${to_match}" "${to_replace}" file_contents "${file_contents}")
    file(WRITE "${file_path}" "${file_contents}")
endfunction()

function(fix_pkgconfig_ufid lib_dir ufid pc_name)
    replace_in_file("${CURRENT_PACKAGES_DIR}/${lib_dir}/pkgconfig/${pc_name}.pc" "/${ufid}" "")
    if ("${ufid}" MATCHES opt)
        set(build_mode "release")
    else()
        set(build_mode "debug")
    endif()

    replace_in_file("${CURRENT_PACKAGES_DIR}/${lib_dir}/cmake/${pc_name}Targets-${build_mode}.cmake" "/${ufid}" "")
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
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_fixup_pkgconfig()

# Usage
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

