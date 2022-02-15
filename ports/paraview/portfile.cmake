file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" _vcpkg_json)
string(JSON _ver_string GET "${_vcpkg_json}" "version-semver")
string(REGEX MATCH "^[0-9]+\.[0-9]+" VERSION "${_ver_string}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    "cuda"         PARAVIEW_USE_CUDA            #untested; probably only affects internal VTK build so it does nothing here 
    "all_modules"  PARAVIEW_BUILD_ALL_MODULES   #untested
    "mpi"          PARAVIEW_USE_MPI             #untested
    "vtkm"         PARAVIEW_USE_VTKM
    "python"       PARAVIEW_USE_PYTHON
    "tools"        PARAVIEW_BUILD_TOOLS
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kitware/ParaView
    REF aad4b6f1e92154879209102edfab8367f1e7d191 # v5.9.1
    SHA512  330fcb8525bdee9b02e06f05d4e91cc4d631d03df99c30f82bb97da5e06b5a2a6ff4ecee807b6f6c7110d2f53db1c17e4670d6078ae1cc89cfd7089b67d05bdb
    HEAD_REF master
    PATCHES
        external_vtk.patch
        cgns.patch
        python_include.patch
        python_wrapper.patch
        add-tools-option.patch
        catalyst_install.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND VisItPatches removedoublesymbols.patch)
endif()

#The following two dependencies should probably be their own port 
#but require additional patching in paraview to make it work. 

#Get VisItBridge Plugin
vcpkg_from_gitlab(
    OUT_SOURCE_PATH VISITIT_SOURCE_PATH
    GITLAB_URL https://gitlab.kitware.com/
    REPO paraview/visitbridge
    REF 42fce8ad6863ca2c1308741955cca1d0cf570d22
    SHA512 03a6254989d3e286a462683af92caba1e90decbdcfb2e729f2d7e1116b04d63a05c28d02c4615d780fdd0d33e2719f96617233d6e0602410cc6d894f92fe6ee3
    PATCHES 
        ${VisItPatches}
)
#Get QtTesting Plugin
vcpkg_from_gitlab(
    OUT_SOURCE_PATH QTTESTING_SOURCE_PATH
    GITLAB_URL https://gitlab.kitware.com/
    REPO paraview/qttesting
    REF 72290689c7c55622d729bf95c97e7627026a234e
    SHA512  fb18c6745b784b294f01d5391ba4cdcaa109443a193eb35fbf1553fdb3a4f7217f784fd4893fab72784cec5bd3fc821bf1e766e943d0f562c5917788800599b0
)

#Get Catalyst
vcpkg_from_gitlab(
    OUT_SOURCE_PATH CATALYST_SOURCE_PATH
    GITLAB_URL https://gitlab.kitware.com/
    REPO paraview/catalyst
    REF e36e4a5f3c67011c97c335cce23d2bc3abc0d086
    SHA512  9926c272ab8785997f9c98cfaf696943081b0ddb0e9e343602722671b6f3eaef5b8de5dd049ca783b6844c7e328a96e1b09c8b24c16f001eeeed2d154d290480
)


file(COPY ${VISITIT_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/Utilities/VisItBridge)
file(COPY ${QTTESTING_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/ThirdParty/QtTesting/vtkqttesting)
file(COPY ${CATALYST_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/ThirdParty/catalyst/vtkcatalyst/catalyst)

if("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
        -DPython3_FIND_REGISTRY=NEVER
        "-DPython3_EXECUTABLE:PATH=${PYTHON3}" # Required by more than one feature
        )
    #VTK_PYTHON_SITE_PACKAGES_SUFFIX should be set to the install dir of the site-packages
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
     OPTIONS ${FEATURE_OPTIONS}
        -DPARAVIEW_BUILD_WITH_EXTERNAL:BOOL=ON
        -DPARAVIEW_USE_EXTERNAL_VTK:BOOL=ON
        -DPARAVIEW_ENABLE_VISITBRIDGE:BOOL=ON
        -DVTK_MODULE_ENABLE_ParaView_qttesting=YES
        -DPARAVIEW_ENABLE_EMBEDDED_DOCUMENTATION:BOOL=OFF
        -DPARAVIEW_USE_QTHELP:BOOL=OFF

        #A little bit of help in finding the boost headers
        "-DBoost_INCLUDE_DIR:PATH=${CURRENT_INSTALLED_DIR}/include"

        # Workarounds for CMake issues
        -DHAVE_SYS_TYPES_H=0    ## For some strange reason the test first succeeds and then fails the second time around
        -DWORDS_BIGENDIAN=0     ## Tests fails in VisItCommon.cmake for some unknown reason this is just a workaround since most systems are little endian. 
        ${ADDITIONAL_OPTIONS}

        #-DPARAVIEW_ENABLE_FFMPEG:BOOL=OFF
)
if(CMAKE_HOST_UNIX)
    # ParaView runs Qt tools so LD_LIBRARY_PATH must be set correctly for them to find *.so files
    set(BACKUP_LD_LIBRARY_PATH $ENV{LD_LIBRARY_PATH})
    set(ENV{LD_LIBRARY_PATH} "${BACKUP_LD_LIBRARY_PATH}:${CURRENT_INSTALLED_DIR}/lib")
endif()

vcpkg_install_cmake(ADD_BIN_TO_PATH) # Bin to path required since paraview will use some self build tools

if(CMAKE_HOST_UNIX)
    set(ENV{LD_LIBRARY_PATH} "${BACKUP_LD_LIBRARY_PATH}")
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/paraview-${VERSION})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

set(TOOLVER pv${VERSION})
set(TOOLS   paraview
            pvbatch
            pvdataserver
            pvpython
            pvrenderserver
            pvserver
            smTestDriver
            vtkProcessXML
            vtkWrapClientServer)

foreach(tool ${TOOLS})
    # Remove debug tools
    set(filename ${CURRENT_PACKAGES_DIR}/debug/bin/${tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    if(EXISTS ${filename})
        file(REMOVE ${filename})
    endif()
    set(filename ${CURRENT_PACKAGES_DIR}/debug/bin/${tool}-${TOOLVER}${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    if(EXISTS ${filename})
        file(REMOVE ${filename})
    endif()
    set(filename ${CURRENT_PACKAGES_DIR}/debug/bin/${tool}-${TOOLVER}d${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    if(EXISTS ${filename})
        file(REMOVE ${filename})
    endif()
    
    # Move release tools
    set(filename ${CURRENT_PACKAGES_DIR}/bin/${tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    if(EXISTS ${filename})
        file(INSTALL ${filename} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
        file(REMOVE ${filename})
    endif()
    set(filename ${CURRENT_PACKAGES_DIR}/bin/${tool}-${TOOLVER}${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    if(EXISTS ${filename})
        file(INSTALL ${filename} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
        file(REMOVE ${filename})
    endif()
endforeach()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/paraview RENAME Copyright.txt) # Which one is the correct one?
file(INSTALL ${SOURCE_PATH}/License_v1.2.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/paraview RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    macro(move_bin_to_lib name)
        if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/${name})
            file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${name}" "${CURRENT_PACKAGES_DIR}/lib/${name}")
        endif()
        if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/bin/${name})
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/${name}" "${CURRENT_PACKAGES_DIR}/debug/lib/${name}")
        endif()
    endmacro()
    
    set(to_move Lib paraview-${VERSION} paraview-config)
    foreach(name ${to_move})
        move_bin_to_lib(${name})
    endforeach()

    file(GLOB_RECURSE cmake_files ${CURRENT_PACKAGES_DIR}/share/${PORT}/*.cmake)
    foreach(cmake_file ${cmake_files})
        file(READ "${cmake_file}" _contents)
        STRING(REPLACE "bin/" "lib/" _contents "${_contents}")
        file(WRITE "${cmake_file}" "${_contents}")
    endforeach()

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()