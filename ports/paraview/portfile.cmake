# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   CURRENT_INSTALLED_DIR     = ${VCPKG_ROOT_DIR}\installed\${TRIPLET}
#   DOWNLOADS                 = ${VCPKG_ROOT_DIR}\downloads
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#   VCPKG_TOOLCHAIN           = ON OFF
#   TRIPLET_SYSTEM_ARCH       = arm x86 x64
#   BUILD_ARCH                = "Win32" "x64" "ARM"
#   MSBUILD_PLATFORM          = "Win32"/"x64"/${TRIPLET_SYSTEM_ARCH}
#   DEBUG_CONFIG              = "Debug Static" "Debug Dll"
#   RELEASE_CONFIG            = "Release Static"" "Release DLL"
#   VCPKG_TARGET_IS_WINDOWS
#   VCPKG_TARGET_IS_UWP
#   VCPKG_TARGET_IS_LINUX
#   VCPKG_TARGET_IS_OSX
#   VCPKG_TARGET_IS_FREEBSD
#   VCPKG_TARGET_IS_ANDROID
#   VCPKG_TARGET_EXECUTABLE_SUFFIX
#   VCPKG_TARGET_STATIC_LIBRARY_SUFFIX
#   VCPKG_TARGET_SHARED_LIBRARY_SUFFIX
#
# 	See additional helpful variables in /docs/maintainers/vcpkg_common_definitions.md 

# # Specifies if the port install should fail immediately given a condition
# vcpkg_fail_port_install(MESSAGE "paraview currently only supports Linux and Mac platforms" ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kitware/ParaView
    REF 0d5c94ac254a1eb1e55b3a0db291d97acd25790d # v5.7.0
    SHA512 df3490c463c96e2b7445e416067f0be469eca86ee655690fd8acdbcda8189c192909981dbb36b043d0e7ccd06f9eb6cf0a2c25a48d23d92c47b061a6ee39b2db
    HEAD_REF master
    PATCHES
        paraview.patch
        second.patch
        protobuf.patch
        #qt_plugin.patch
        qt_static_plugins.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND VisItPatches removedoublesymbols.patch)
endif()
#Get VisItBridge Plugin
vcpkg_from_gitlab(
    OUT_SOURCE_PATH VISITIT_SOURCE_PATH
    GITLAB_URL https://gitlab.kitware.com/
    REPO paraview/visitbridge
    REF 4e5fd802e83fcc8601b7a75d318ac277514cb736
    SHA512 49ab6e32051a9cb328f5694bca7445610d80bdedddc7ac3d48970f57be1c5969578a0501b12f48a2fb332f109f79f8df189e78530bb4af75e73b0d48d7124884
    PATCHES 
        VisIt.patch
        removeunusedsymbols.patch # These also get remove in master of ParaView
        ${VisItPatches}
)
#Get QtTesting Plugin
vcpkg_from_gitlab(
    OUT_SOURCE_PATH QTTESTING_SOURCE_PATH
    GITLAB_URL https://gitlab.kitware.com/
    REPO paraview/qttesting
    REF a17c15627db0852242d83460e032a021571669df
    SHA512  34ad7c97720366dd66c011aecbaf7103ebcc128223673140d42db32c6eb419c805da204ac9afe73dae4c9b2ef9acfc4ec1b927271351fde51c9df7c44d09bf6e
)

file(COPY ${VISITIT_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/Utilities/VisItBridge)
file(COPY ${QTTESTING_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/ThirdParty/QtTesting/vtkqttesting)
#file(REMOVE_RECURSE ${SOURCE_PATH}/ThirdPary/protobuf/vtkprotobuf)
#file(REMOVE_RECURSE "${SOURCE_PATH}/ThirdParty/QtTesting")
# # Check if one or more features are a part of a package installation.
# # See /docs/maintainers/vcpkg_check_features.md for more details
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
#   FEATURES # <- Keyword FEATURES is required because INVERTED_FEATURES are being used
#     tbb   WITH_TBB
#   INVERTED_FEATURES
#     tbb   ROCKSDB_IGNORE_PACKAGE_TBB
# )

if("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
        -DPARAVIEW_ENABLE_PYTHON:BOOL=ON
        -DVTK_PYTHON_VERSION=3
        -DPython3_FIND_REGISTRY=NEVER
        "-DPython3_FOUND=YES"
        "-DPYTHON3_FOUND=YES"
        "-DPYTHON_FOUND=YES"
        "-DPython3_LIBRARY_RELEASE=${CURRENT_INSTALLED_DIR}/lib/python37.lib"
        "-DPython3_LIBRARY_DEBUG=${CURRENT_INSTALLED_DIR}/debug/lib/python37_d.lib"
        "-DPython3_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/python3.7"
        "-DPython3_EXECUTABLE=${PYTHON3}"
        "-DPYTHON3_EXECUTABLE=${PYTHON3}"
        "-DPython_EXECUTABLE=${PYTHON3}"
        "-DPYTHON_EXECUTABLE=${PYTHON3}"
    )
    #VTK_PYTHON_SITE_PACKAGES_SUFFIX should be set to the install dir of the site-packages
else()
    list(APPEND ADDITIONAL_OPTIONS
        -DPARAVIEW_ENABLE_PYTHON:BOOL=OFF
    )
endif()

if("vtkm" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DPARAVIEW_USE_VTKM:BOOL=ON # VTK-m port is missing but this is a requirement to build VisItLib
    )
else()
    list(APPEND ADDITIONAL_OPTIONS
        -DPARAVIEW_USE_VTKM:BOOL=OFF # VTK-m port is missing but this is a requirement to build VisItLib
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
     OPTIONS 
        -DPARAVIEW_USE_EXTERNAL:BOOL=ON
        -DPARAVIEW_USE_EXTERNAL_VTK:BOOL=ON
        -DPARAVIEW_ENABLE_VISITBRIDGE:BOOL=ON
        -DPARAVIEW_ENABLE_CATALYST:BOOL=ON
        -DVTK_MODULE_ENABLE_ParaView_qttesting=YES
        -DPARAVIEW_ENABLE_EMBEDDED_DOCUMENTATION=OFF
        -DPARAVIEW_USE_QTHELP=OFF
        
        #A little bit of help in finding the boost headers
        -DBoost_INCLUDE_DIR:PATH="${CURRENT_INSTALLED_DIR}/include"
        
        # Workarounds for CMake issues
        -DHAVE_SYS_TYPES_H=0    ## For some strange reason the test first succeeds and then fails the second time around
        -DWORDS_BIGENDIAN=0     ## Tests fails in VisItCommon.cmake for some unknown reason this is just a workaround since most systems are little endian. 
        ${ADDITIONAL_OPTIONS}

        
        #-DPARAVIEW_ENABLE_FFMPEG:BOOL=OFF
        ##VTK_MODULE_USE_EXTERNAL_<name>
)

vcpkg_install_cmake(ADD_BIN_TO_PATH) # Bin to path required since paraview will use some self build tools

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/paraview-5.7)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

set(TOOLVER pv5.7)
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
# # Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME paraview)


if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    macro(move_bin_to_lib name)
        if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/${name})
            file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${name}" "${CURRENT_PACKAGES_DIR}/lib/${name}")
        endif()
        if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/bin/${name})
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/${name}" "${CURRENT_PACKAGES_DIR}/debug/lib/${name}")
        endif()
    endmacro()
    
    set(to_move Lib paraview-5.7 paraview-config)
    foreach(name ${to_move})
        move_bin_to_lib(${name})
    endforeach()

    file(GLOB_RECURSE cmake_files ${CURRENT_PACKAGES_DIR}/share/${PORT}/*.cmake)
    foreach(cmake_file ${cmake_files})
        file(READ "${cmake_file}" _contents)
        STRING(REPLACE "/bin/" "/lib/" _contents "${_contents}")
        file(WRITE "${cmake_file}" "${_contents}")
    endforeach()

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()