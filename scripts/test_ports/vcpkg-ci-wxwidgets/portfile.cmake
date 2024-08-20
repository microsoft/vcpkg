set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_check_features(OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        wxrc    USE_WXRC
)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_INSTALLED_DIR}/share/wxwidgets/example"
    DISABLE_PARALLEL_CONFIGURE # Need separate dbg log for following test
    OPTIONS
        ${OPTIONS}
        -DCMAKE_CONFIG_RUN=1
        "-DPRINT_VARS=CMAKE_CONFIG_RUN;wxWidgets_LIBRARIES"
)
vcpkg_cmake_build()

if(NOT VCPKG_BUILD_TYPE)
    # Check that debug libs are still used after re-configuration, #24489
    set(config_log "config-${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" -DCMAKE_CONFIG_RUN=2 .
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
        LOGNAME "${config_log}-2"
    )
    file(STRINGS "${CURRENT_BUILDTREES_DIR}/${config_log}-out.log" expected REGEX "wxWidgets_LIBRARIES:=")
    file(STRINGS "${CURRENT_BUILDTREES_DIR}/${config_log}-2-out.log" actual REGEX "wxWidgets_LIBRARIES:=")
    if(NOT actual STREQUAL expected)
        message(FATAL_ERROR "wxWidgets libraries changed after CMake re-run\n"
            "actual:\n${actual}\n"
            "expected:\n ${expected}\n"
        )
    endif()
endif()
