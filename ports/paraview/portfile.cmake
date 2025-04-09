set(VERSION_MAJOR_MINOR 5.12)

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

vcpkg_download_distfile(
    external_vtk_patch
    URLS https://gitlab.kitware.com/paraview/paraview/-/merge_requests/6375.diff?full_index=1
    FILENAME paraview_external_vtk_pr.diff
    SHA512 c7760599239334817e9cad33ab7019c2dd0ce6740891e10ec15e1d63605ad73095fd7d48aed5ca8d002d25db356a7a5cf2a37188f0b43a7a9fa4c339e8f42adb
)

set(ext_vtk_patch_copy "${CURRENT_BUILDTREES_DIR}/paraview_external_vtk_pr.diff")
file(COPY "${external_vtk_patch}" DESTINATION "${CURRENT_BUILDTREES_DIR}" )

# Remove stuff which cannot be patched since it does not exist
vcpkg_replace_string("${ext_vtk_patch_copy}"
[[
diff --git a/.gitlab/ci/sccache.sh b/.gitlab/ci/sccache.sh
index f1897d6f719c3b61b6d4fa317966c007dab2fc23..e88d7c89198696832e5645bfb0e758fd5d92e6af 100755
--- a/.gitlab/ci/sccache.sh
+++ b/.gitlab/ci/sccache.sh
@@ -37,6 +37,6 @@ $shatool --check sccache.sha256sum
 mv "$filename" sccache
 chmod +x sccache
 
-mkdir shortcuts
+mkdir -p shortcuts
 cp ./sccache shortcuts/gcc
 cp ./sccache shortcuts/g++
]]
""
IGNORE_UNCHANGED
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kitware/ParaView
    REF 8751c670e2aac949f17dd701a5a2f13849afafb2 # v5.12.1
    SHA512  ed7b7e183c9d1350d8d2feadf7b76bef939bc657f49e5160e2e96e2329642d8ba1c0a8ab7cb58ff068ba21b7adc3f52676b38779e1ecec31b4714184c2364072
    HEAD_REF master
    PATCHES
        ${ext_vtk_patch_copy}
        add-tools-option.patch
        fix-build.patch
        fix-configure.patch
        protobuf-version.patch
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
    REF 093ea1dfddbb3266554ece823ae8d7dedc66eb3f
    SHA512 0fd5dd3fbc8e61123dedb8e30b3150109ef855bc398d01ed0defe0c560692c91231ff72568ee6a1840edc21d6ea3c9c164dbeb29b8590315ee5c153a3d77d568
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
    REF 375c33053704e2d99dda4d2e1dfc9f6f85b3e73f
    SHA512  4d42352394017f4a07ed96dea6b5c0caf3bc6b22bbe0c8f5df6d2740cb7b2946e0b04ac7b79b88bc7c4281bb8d48071878f42c41c042de8ef6979818d26490e5
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
    # This sections relies on target package python3.
    set(python_ver "")
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        set(python_ver "3")
    endif()
    list(APPEND ADDITIONAL_OPTIONS
        -DPython3_FIND_REGISTRY=NEVER
        "-DPython3_EXECUTABLE:PATH=${CURRENT_INSTALLED_DIR}/tools/python3/python${python_ver}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
        "-DPARAVIEW_PYTHON_SITE_PACKAGES_SUFFIX=${PYTHON3_SITE}" # from vcpkg-port-config.cmake
        -DVTK_MODULE_ENABLE_ParaView_PythonCatalyst:STRING=YES
        )
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PARAVIEW_BUILD_SHARED_LIBS)

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  # Hitting pdb size limits when building debug paraview so increase it
  string(APPEND VCPKG_LINKER_FLAGS_DEBUG " /PDBPAGESIZE:8192")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
     OPTIONS
        ${FEATURE_OPTIONS}
        -DPARAVIEW_USE_FORTRAN=OFF
        -DPARAVIEW_BUILD_SHARED_LIBS=${PARAVIEW_BUILD_SHARED_LIBS}
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

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Copyright.txt")

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

file(GLOB cmake_files "${CURRENT_PACKAGES_DIR}/share/${PORT}/*.cmake")
foreach(file IN LISTS cmake_files)
    vcpkg_replace_string("${file}" "pv${VERSION_MAJOR_MINOR}d.exe" "pv${VERSION_MAJOR_MINOR}.exe" IGNORE_UNCHANGED)
endforeach() 
 
# The plugins also work without these files
file(REMOVE "${CURRENT_PACKAGES_DIR}/Applications/paraview.app/Contents/Resources/paraview.conf")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/Applications/paraview.app/Contents/Resources/paraview.conf")
