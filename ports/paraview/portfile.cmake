set(VERSION_MAJOR_MINOR 5.11)

set(plat_feat "")
if(VCPKG_TARGET_IS_LINUX)
    set(plat_feat "tools" VTK_USE_X) # required to build the client
endif()
if(VCPKG_TARGET_IS_LINUX)
    set(plat_feat "tools" VTK_USE_COCOA) # required to build the client
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES
    "cuda"         PARAVIEW_USE_CUDA            #untested; probably only affects internal VTK build so it does nothing here 
    "all_modules"  PARAVIEW_BUILD_ALL_MODULES   #untested
    "mpi"          PARAVIEW_USE_MPI             #untested
    "vtkm"         PARAVIEW_USE_VTKM
    "python"       PARAVIEW_USE_PYTHON
    "tools"        PARAVIEW_BUILD_TOOLS
    ${plat_feat}
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kitware/ParaView
    REF 91aaf338c62f77fccd7d197dea05e7a68035ab25 # v5.11.0
    SHA512  ddd72b127462a37dba220808925ab1991b3072ddd3f39ba7f26d260bd5abbaa6bd38a0c0181141f461df60dd718ec85df8c0faffff8e53a6cd1737b784565f4b
    HEAD_REF master
    PATCHES
        external_vtk.patch
        python_include.patch
        python_wrapper.patch
        add-tools-option.patch
        qt6-all.patch
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
    REF df098f4148a96d62c388861c1d476039e02224ae
    SHA512 002c2c934ef7e64c89b1567f406db1ebb90532817062e7016c248ba8ae85a88f1a35bc3963a9577ec08ba742a0e7fb91022c29aaaa0bddf0a1d585074341733e
    PATCHES 
        ${VisItPatches}
)
#VTK_MODULE_USE_EXTERNAL_ParaView_protobuf
#NVPipe?
#Get QtTesting Plugin
vcpkg_from_gitlab(
    OUT_SOURCE_PATH QTTESTING_SOURCE_PATH
    GITLAB_URL https://gitlab.kitware.com/
    REPO paraview/qttesting
    REF 08d96e9277bc4c26804fd77ce1b4fa5c791605ae # https://gitlab.kitware.com/paraview/qttesting/-/merge_requests/53 for Qt6
    SHA512  cb4acdfe1206bd8bae4f70185c8ca1ce555cf983a1d1e97293dac544ab13b039638bfe0d1e448f9589db92b6ed23b9b940157e72d9ec9e3994ea9858ab1722ec
    PATCHES 53.diff
)

vcpkg_from_gitlab(
    OUT_SOURCE_PATH ICET_SOURCE_PATH
    GITLAB_URL https://gitlab.kitware.com/
    REPO paraview/IceT
    REF 32816fe5592de3be664da6f8466a546f221d8532
    SHA512  33d5e8f2ecdc20d305d04c23fc3a3121d3c5305ddff7f5b71cee1a2c2183c4b36c9d0bd91e9dba5f2369e237782d7dbcf635d2e1814ccde88570647c890edc9d
)

file(COPY "${VISITIT_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/Utilities/VisItBridge")
file(COPY "${QTTESTING_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/ThirdParty/QtTesting/vtkqttesting")
file(COPY "${ICET_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/ThirdParty/IceT/vtkicet")

if("python" IN_LIST FEATURES)
    set(python_ver "")
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        set(python_ver 3.10)
    endif()
    list(APPEND ADDITIONAL_OPTIONS
        -DPython3_FIND_REGISTRY=NEVER
        "-DPython3_EXECUTABLE:PATH=${CURRENT_HOST_INSTALLED_DIR}/tools/python3/python${python_ver}${VCPKG_EXECUTABLE_SUFFIX}"
        )
    #VTK_PYTHON_SITE_PACKAGES_SUFFIX should be set to the install dir of the site-packages
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
     OPTIONS ${FEATURE_OPTIONS}
        -DPARAVIEW_PLUGIN_DISABLE_XML_DOCUMENTATION:BOOL=ON
        -DPARAVIEW_BUILD_WITH_EXTERNAL:BOOL=ON
        -DPARAVIEW_USE_EXTERNAL_VTK:BOOL=ON
        -DPARAVIEW_ENABLE_VISITBRIDGE:BOOL=ON
        -DVTK_MODULE_ENABLE_ParaView_qttesting=YES
        -DPARAVIEW_ENABLE_EMBEDDED_DOCUMENTATION:BOOL=OFF
        -DPARAVIEW_USE_QTHELP:BOOL=OFF
        # A little bit of help in finding the boost headers
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

vcpkg_cmake_install(ADD_BIN_TO_PATH) # Bin to path required since paraview will use some self build tools

if(CMAKE_HOST_UNIX)
    set(ENV{LD_LIBRARY_PATH} "${BACKUP_LD_LIBRARY_PATH}")
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/paraview-${VERSION_MAJOR_MINOR})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# see https://gitlab.kitware.com/paraview/paraview/-/issues/21328
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/paraview-${VERSION_MAJOR_MINOR}/vtkCPConfig.h")

set(TOOLVER pv${VERSION_MAJOR_MINOR})
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
        file(REMOVE "${filename}")
    endif()
    set(filename ${CURRENT_PACKAGES_DIR}/debug/bin/${tool}-${TOOLVER}${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    if(EXISTS ${filename})
        file(REMOVE "${filename}")
    endif()
    set(filename ${CURRENT_PACKAGES_DIR}/debug/bin/${tool}-${TOOLVER}d${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    if(EXISTS ${filename})
        file(REMOVE "${filename}")
    endif()
    
    # Move release tools
    set(filename ${CURRENT_PACKAGES_DIR}/bin/${tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    if(EXISTS ${filename})
        file(INSTALL "${filename}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        file(REMOVE "${filename}")
    endif()
    set(filename ${CURRENT_PACKAGES_DIR}/bin/${tool}-${TOOLVER}${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    if(EXISTS ${filename})
        file(INSTALL "${filename}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        file(REMOVE "${filename}")
    endif()
endforeach()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/Copyright.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME Copyright.txt) # Which one is the correct one?
file(INSTALL "${SOURCE_PATH}/License_v1.2.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    macro(move_bin_to_lib name)
        if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/${name})
            file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${name}" "${CURRENT_PACKAGES_DIR}/lib/${name}")
        endif()
        if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/bin/${name})
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/${name}" "${CURRENT_PACKAGES_DIR}/debug/lib/${name}")
        endif()
    endmacro()
    
    set(to_move Lib paraview-${VERSION_MAJOR_MINOR} paraview-config)
    foreach(name ${to_move})
        move_bin_to_lib(${name})
    endforeach()

    file(GLOB_RECURSE cmake_files ${CURRENT_PACKAGES_DIR}/share/${PORT}/*.cmake)
    foreach(cmake_file ${cmake_files})
        file(READ "${cmake_file}" _contents)
        STRING(REPLACE "bin/" "lib/" _contents "${_contents}")
        file(WRITE "${cmake_file}" "${_contents}")
    endforeach()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# The plugins also work without these files
file(REMOVE "${CURRENT_PACKAGES_DIR}/Applications/paraview.app/Contents/Resources/paraview.conf")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/Applications/paraview.app/Contents/Resources/paraview.conf")
