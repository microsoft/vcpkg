# Clone
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commontk/CTK
    REF ec816cbb77986f6ee28c41a495e82238dee0e2d3 # 2022.05.17
    SHA512 fc5044a6110304e47a24542cd34545bbe58e1e4c695c3cec7e3bed2230e3317a0823d25ab01216a884c0efa1146c5817782e20154d16999fc63fcb6192912ccd
    HEAD_REF master
)

# Configure and build
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCTK_QT_VERSION=5
        -DCTK_ENABLE_DICOM=ON
        -DCTK_ENABLE_Widgets=ON
        -DCTK_SUPERBUILD=ON
)
vcpkg_cmake_build()

# Custom install
set(arg_LOGFILE_BASE "install")
vcpkg_list(SET build_param)
vcpkg_list(SET parallel_param)
vcpkg_list(SET no_parallel_param)

if("${Z_VCPKG_CMAKE_GENERATOR}" STREQUAL "Ninja")
    vcpkg_list(SET build_param "-v") # verbose output
    vcpkg_list(SET parallel_param "-j${VCPKG_CONCURRENCY}")
    vcpkg_list(SET no_parallel_param "-j1")
elseif("${Z_VCPKG_CMAKE_GENERATOR}" MATCHES "^Visual Studio")
    vcpkg_list(SET build_param
        "/p:VCPkgLocalAppDataDisabled=true"
        "/p:UseIntelMKL=No"
    )
    vcpkg_list(SET parallel_param "/m")
elseif("${Z_VCPKG_CMAKE_GENERATOR}" STREQUAL "NMake Makefiles")
    # No options are currently added for nmake builds
elseif(Z_VCPKG_CMAKE_GENERATOR STREQUAL "Unix Makefiles")
    vcpkg_list(SET build_args "VERBOSE=1")
    vcpkg_list(SET parallel_args "-j${VCPKG_CONCURRENCY}")
    vcpkg_list(SET no_parallel_args "")
elseif(Z_VCPKG_CMAKE_GENERATOR STREQUAL "Xcode")
    vcpkg_list(SET parallel_args -jobs "${VCPKG_CONCURRENCY}")
    vcpkg_list(SET no_parallel_args -jobs 1)
else()
    message(WARNING "Unrecognized GENERATOR setting from vcpkg_cmake_configure().")
endif()

vcpkg_list(SET target_param "--target" "install")

foreach(build_type IN ITEMS debug release)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR "${VCPKG_BUILD_TYPE}" STREQUAL "${build_type}")
        if("${build_type}" STREQUAL "debug")
            set(short_build_type "dbg")
            set(config "Debug")
        else()
            set(short_build_type "rel")
            set(config "Release")
        endif()

        message(STATUS "Building ${TARGET_TRIPLET}-${short_build_type}")

        vcpkg_execute_build_process(
            COMMAND
                "${CMAKE_COMMAND}" --build ./CTK-build --config "${config}" ${target_param}
                -- ${build_param} ${parallel_param}
            NO_PARALLEL_COMMAND
                "${CMAKE_COMMAND}" --build ./CTK-build --config "${config}" ${target_param}
                -- ${build_param} ${no_parallel_param}
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_build_type}"
            LOGNAME "${arg_LOGFILE_BASE}-${TARGET_TRIPLET}-${short_build_type}"
        )

    endif()
endforeach()
# End Custom Install

# VCPKG Fixup
#vcpkg_cmake_config_fixup(CONFIG_PATH "lib/ctk-0.1/CMake")
vcpkg_copy_pdbs()

# Remove debug built files
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Move library dlls to bin
set (CTK_DLLS "CTKCore.dll;CTKDICOMCore.dll;CTKDICOMWidgets.dll;CTKDummyPlugin.dll;CTKWidgets.dll;designer/CTKDICOMWidgetsPlugins.dll;designer/CTKWidgetsPlugins.dll")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin/designer")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin/designer")

foreach (DLL_FILE ${CTK_DLLS})
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/ctk-0.1/${DLL_FILE}")
        file(COPY "${CURRENT_PACKAGES_DIR}/lib/ctk-0.1/${DLL_FILE}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin/${DLL_FILE}")
    endif()
endforeach()

foreach (DLL_FILE ${CTK_DLLS})
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/ctk-0.1/${DLL_FILE}")
        file(COPY "${CURRENT_PACKAGES_DIR}/debug/lib/ctk-0.1/${DLL_FILE}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin/${DLL_FILE}")
    endif()
endforeach()

#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/ctk-0.1/designer" "${CURRENT_PACKAGES_DIR}/lib/ctk-0.1/designer")

# Copy usage and license
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
