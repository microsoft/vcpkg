set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
)
vcpkg_cmake_build()

if(NOT VCPKG_CROSSCOMPILING)
    foreach(config IN ITEMS rel dbg)
        foreach(exe IN ITEMS cmake_cxx cmake_capi cmake_c)
            set(exe_path "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${config}/${exe}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
            if(EXISTS "${exe_path}")
                vcpkg_execute_required_process(
                    COMMAND "${exe_path}"
                    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${config}"
                    LOGNAME "run-${exe}-${config}"
                )
            endif()
        endforeach()
    endforeach()
endif()
