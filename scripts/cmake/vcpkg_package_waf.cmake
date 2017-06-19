#.rst:
# .. command:: vcpkg_package_waf
#
#  Build and install a waf-based project, previously configured using vcpkg_configure_waf.
#  Build arguments are passed in from the port-file and passed on from vcpkg_configure_waf.
#
#  ::
#  vcpkg_package_waf()


function(vcpkg_package_waf)
    cmake_parse_arguments(_csc "" "" "BUILD_CONFIGURATION;OPTIONS_BUILD;OPTIONS_BUILD_RELEASE;OPTIONS_BUILD_DEBUG;TARGETS" ${ARGN})

    # Make sure that the linker finds the libraries used. Backup old setting first:
    set(ENV_LIB_BACKUP ENV{LIB})

    # Then set LIB environment variable according to build configuration
    if(${_csc_BUILD_CONFIGURATION} MATCHES "debug")
      set(ENV{LIB} "${CURRENT_INSTALLED_DIR}/debug/lib;$ENV{LIB}")
      set(CONFIG_SUFIX "dbg")
      set(SECONDARY_OPTIONS ${_csc_OPTIONS_BUILD_DEBUG})
    elseif(${_csc_BUILD_CONFIGURATION} MATCHES "release")
      set(ENV{LIB} "${CURRENT_INSTALLED_DIR}/lib;$ENV{LIB}")
      set(CONFIG_SUFIX "rel")
      set(SECONDARY_OPTIONS ${_csc_OPTIONS_BUILD_RELEASE})
    endif()

    if(${_csc_TARGETS})
      set(TARGETS "--targets=${_csc_TARGETS}")
    endif()

    message(STATUS "Package ${TARGET_TRIPLET}-${CONFIG_SUFIX}...")
    vcpkg_execute_required_process(
        COMMAND ${WAF} build install
          ${_csc_OPTIONS_BUILD}
          ${SECONDARY_OPTIONS}
          ${TARGETS}
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME package-${TARGET_TRIPLET}-${CONFIG_SUFIX}
    )
    message(STATUS "Package ${TARGET_TRIPLET}-${CONFIG_SUFIX}... Done!")

    # Restore the original value of ENV{LIB}
    set(ENV{LIB} ENV_LIB_BACKUP)
endfunction()
