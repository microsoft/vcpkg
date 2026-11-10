set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
)
vcpkg_cmake_build()

if(NOT VCPKG_CROSSCOMPILING)
    foreach(config IN ITEMS rel dbg)
        set(build_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${config}")
        if(NOT EXISTS "${build_dir}")
            continue()
        endif()
        if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            # Next to the executables, not on PATH: System32 ships an older
            # onnxruntime.dll that the loader finds before anything on PATH.
            if(config STREQUAL "rel")
                file(GLOB dlls "${CURRENT_INSTALLED_DIR}/bin/*.dll")
            else()
                file(GLOB dlls "${CURRENT_INSTALLED_DIR}/debug/bin/*.dll")
            endif()
            file(COPY ${dlls} DESTINATION "${build_dir}")
        endif()
        foreach(exe IN ITEMS cmake_cxx cmake_capi cmake_c)
            vcpkg_execute_required_process(
                COMMAND "${build_dir}/${exe}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
                WORKING_DIRECTORY "${build_dir}"
                LOGNAME "run-${exe}-${config}"
            )
        endforeach()
    endforeach()
endif()
