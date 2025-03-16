set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if(NOT VCPKG_CROSSCOMPILING)
    file(INSTALL "${CURRENT_PORT_DIR}/test-macros.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()

include("${CURRENT_PORT_DIR}/test-macros.cmake")

if("minimum-required" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-vcpkg_minimum_required.cmake")
endif()
if("list" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-vcpkg_list.cmake")
endif()
if("host-path-list" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-vcpkg_host_path_list.cmake")
endif()
if("function-arguments" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_function_arguments.cmake")
endif()
if("merge-libs" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_cmake_config_fixup_merge.cmake")
endif()
if("backup-restore-env-vars" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-vcpkg_backup_restore_env_vars.cmake")
endif()
if("setup-pkgconfig-path" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_setup_pkgconfig_path.cmake")
endif()
if("fixup-pkgconfig" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-vcpkg_fixup_pkgconfig.cmake")
endif()
if("fixup-rpath" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_calculate_corrected_rpath.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/test-z_vcpkg_calculate_corrected_rpath_macho.cmake")
endif()
if("execute-required-process" IN_LIST FEATURES)
    include("${CMAKE_CURRENT_LIST_DIR}/test-vcpkg_execute_required_process.cmake")
endif()

if(Z_VCPKG_UNIT_TEST_HAS_ERROR)
    _message(FATAL_ERROR "At least one test failed")
endif()
