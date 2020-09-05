set(VERSION 5.8)

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
    REF 56631fdd9a31f4acdfe5fce2c3be3c4fb6e6800f # v5.8.0
    SHA512  1cdf4065428debc301c98422233524cdafc843495c54569b0854bf53f6ffeba1e83acf60497450779d493e56051557cd377902325d6ece89ad1b98ae6ba831be
    HEAD_REF master
    PATCHES
        paraview_build.patch
        remove_duplicates.patch # Missed something in the above patch
        cgns.patch
        python_include.patch
        python_wrapper.patch
        add-tools-option.patch
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
    REF c2605b5c3115bc4869c76a0d8bfdd8939b59f283
    SHA512 6d2c1d6e1cd345547926938451755e7a8be5dabd89e18a2ceb419db16c5b29f354554a5130eb365b7e522d655370fd4766953813ff530c06e4851fe26104ce58
    PATCHES 
        VisIt_Build.patch        
        #removeunusedsymbols.patch # These also get remove in master of ParaView
        ${VisItPatches}
)
#Get QtTesting Plugin
vcpkg_from_gitlab(
    OUT_SOURCE_PATH QTTESTING_SOURCE_PATH
    GITLAB_URL https://gitlab.kitware.com/
    REPO paraview/qttesting
    REF f2429588feb839e0d8f9f3ee73bfa8a032a3f178
    SHA512  752b13ff79095a14faa2edc134a64497ff0426da3aa6b1a5951624816fb4f113a26fbe559cedf495ebb775d782c9a1851421a88dd299a79f27cbebb730ea227e
)

file(COPY ${VISITIT_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/Utilities/VisItBridge)
file(COPY ${QTTESTING_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/ThirdParty/QtTesting/vtkqttesting)

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