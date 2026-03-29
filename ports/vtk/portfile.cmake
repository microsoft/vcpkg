set(VTK_SHORT_VERSION 9.6)
if (NOT VCPKG_TARGET_IS_WINDOWS)
    message(WARNING "You will need to install Xorg dependencies to build vtk:\napt-get install libxt-dev\n")
endif ()

set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)

# =============================================================================
# Clone & patch
vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Kitware/VTK
        REF edd2a192de28f042a548ef8f8663c255aadd6b08 # v9.6.x used by ParaView 5.12.0
        SHA512 6f2fe9f316a228a32fed08deb845b88ed8c016a615f079673333efdef7b532ed656bba30f53d32c13738c04c2fad66515d0e29ee0cd991fdfd537e3e1f4d65b0
        HEAD_REF master
        PATCHES
        FindLZMA.patch
        FindLZ4.patch
        libproj.patch
        pegtl.patch
        pythonwrapper.patch # Required by ParaView to Wrap required classes
        NoUndefDebug.patch # Required to link against correct Python library depending on build type.
        FindExpat.patch
        cgns.patch
        afxdll.patch
        remove-prefix-changes.patch
        cell-attribute-fix.patch
        vtk-diy2-factory.patch
        h5t-io.patch
)

# Overwrite outdated modules if they have not been patched:
file(COPY "${CURRENT_PORT_DIR}/FindHDF5.cmake" DESTINATION "${SOURCE_PATH}/CMake/patches/99") # due to usage of targets in netcdf-c
if (HDF5_WITH_PARALLEL AND NOT "mpi" IN_LIST FEATURES)
    message(WARNING "${HDF5_WITH_PARALLEL} Enabling MPI in vtk.")
    list(APPEND FEATURES "mpi")
endif ()
# =============================================================================
# Options:
# Collect CMake options for optional components

if ("atlmfc" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
            -DVTK_MODULE_ENABLE_VTK_GUISupportMFC=YES
    )
endif ()
if ("vtkm" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
            -DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmCore=YES
            -DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmDataModel=YES
            -DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmFilters=YES
            -DVTK_MODULE_ENABLE_VTK_vtkm=YES
    )
endif ()

# TODO:
# - add loguru as a dependency requires #8682
vcpkg_check_features(OUT_FEATURE_OPTIONS VTK_FEATURE_OPTIONS
        FEATURES
        "qt" VTK_GROUP_ENABLE_Qt
        "qt" VTK_MODULE_ENABLE_VTK_GUISupportQt
        "qt" VTK_MODULE_ENABLE_VTK_GUISupportQtSQL
        "qt" VTK_MODULE_ENABLE_VTK_RenderingQt
        "qt" VTK_MODULE_ENABLE_VTK_ViewsQt
        "atlmfc" VTK_MODULE_ENABLE_VTK_GUISupportMFC
        "vtkm" VTK_MODULE_ENABLE_VTK_AcceleratorsVTKmCore
        "vtkm" VTK_MODULE_ENABLE_VTK_AcceleratorsVTKmDataModel
        "vtkm" VTK_MODULE_ENABLE_VTK_AcceleratorsVTKmFilters
        "vtkm" VTK_MODULE_ENABLE_VTK_vtkm
        "python" VTK_MODULE_ENABLE_VTK_Python
        "python" VTK_MODULE_ENABLE_VTK_PythonContext2D
        "python" VTK_MODULE_ENABLE_VTK_PythonInterpreter
        "paraview" VTK_MODULE_ENABLE_VTK_FiltersParallelStatistics
        "paraview" VTK_MODULE_ENABLE_VTK_IOParallelExodus
        "paraview" VTK_MODULE_ENABLE_VTK_RenderingParallel
        "paraview" VTK_MODULE_ENABLE_VTK_RenderingVolumeAMR
        "paraview" VTK_MODULE_ENABLE_VTK_IOXdmf2
        "paraview" VTK_MODULE_ENABLE_VTK_IOH5part
        "paraview" VTK_MODULE_ENABLE_VTK_IOH5Rage
        "paraview" VTK_MODULE_ENABLE_VTK_IOParallelLSDyna
        "paraview" VTK_MODULE_ENABLE_VTK_IOTRUCHAS
        "paraview" VTK_MODULE_ENABLE_VTK_IOVPIC
        "paraview" VTK_MODULE_ENABLE_VTK_RenderingAnnotation
        "paraview" VTK_MODULE_ENABLE_VTK_DomainsChemistry
        "paraview" VTK_MODULE_ENABLE_VTK_FiltersParallelDIY2
        "paraview" VTK_MODULE_ENABLE_VTK_cli11
        "paraview" VTK_MODULE_ENABLE_VTK_FiltersOpenTURNS
        "paraview" VTK_MODULE_ENABLE_VTK_FiltersParallelVerdict
        "paraview" VTK_MODULE_ENABLE_VTK_IOOMF
        "paraview" VTK_MODULE_ENABLE_VTK_IOPIO
        "mpi" VTK_GROUP_ENABLE_MPI
        "opengl" VTK_MODULE_ENABLE_VTK_ImagingOpenGL2
        "opengl" VTK_MODULE_ENABLE_VTK_RenderingGL2PSOpenGL2
        "opengl" VTK_MODULE_ENABLE_VTK_RenderingOpenGL2
        "opengl" VTK_MODULE_ENABLE_VTK_RenderingVolumeOpenGL2
        "opengl" VTK_MODULE_ENABLE_VTK_opengl
        "openvr" VTK_MODULE_ENABLE_VTK_RenderingOpenVR
        "gdal" VTK_MODULE_ENABLE_VTK_IOGDAL
        "geojson" VTK_MODULE_ENABLE_VTK_IOGeoJSON
        "ioocct" VTK_MODULE_ENABLE_VTK_IOOCCT
        "libtheora" VTK_MODULE_ENABLE_VTK_IOOggTheora
        "libharu" VTK_MODULE_ENABLE_VTK_IOExportPDF
        "cgns" VTK_MODULE_ENABLE_VTK_IOCGNSReader
        "seacas" VTK_MODULE_ENABLE_VTK_IOIOSS
        "seacas" VTK_MODULE_ENABLE_VTK_IOExodus
        "sql" VTK_MODULE_ENABLE_VTK_IOSQL
        "proj" VTK_MODULE_ENABLE_VTK_IOCesium3DTiles
        "proj" VTK_MODULE_ENABLE_VTK_GeovisCore
        "netcdf" VTK_MODULE_ENABLE_VTK_IONetCDF
        "netcdf" VTK_MODULE_ENABLE_VTK_IOMINC
)

# Require port features to prevent accidental finding of transitive dependencies
vcpkg_check_features(OUT_FEATURE_OPTIONS PACKAGE_FEATURE_OPTIONS
        FEATURES
        "libtheora" CMAKE_REQUIRE_FIND_PACKAGE_THEORA
        "libharu" CMAKE_REQUIRE_FIND_PACKAGE_LibHaru
        "cgns" CMAKE_REQUIRE_FIND_PACKAGE_CGNS
        "seacas" CMAKE_REQUIRE_FIND_PACKAGE_SEACASIoss
        "seacas" CMAKE_REQUIRE_FIND_PACKAGE_SEACASExodus
        "sql" CMAKE_REQUIRE_FIND_PACKAGE_SQLite3
        "proj" CMAKE_REQUIRE_FIND_PACKAGE_PROJ
        "netcdf" CMAKE_REQUIRE_FIND_PACKAGE_NetCDF
        INVERTED_FEATURES
        "cgns" CMAKE_DISABLE_FIND_PACKAGE_CGNS
        "seacas" CMAKE_DISABLE_FIND_PACKAGE_SEACASIoss
        "seacas" CMAKE_DISABLE_FIND_PACKAGE_SEACASExodus
        "proj" CMAKE_DISABLE_FIND_PACKAGE_PROJ
        "netcdf" CMAKE_DISABLE_FIND_PACKAGE_NetCDF
)

# Replace common value to vtk value
list(TRANSFORM VTK_FEATURE_OPTIONS REPLACE "=ON" "=YES")
list(TRANSFORM VTK_FEATURE_OPTIONS REPLACE "=OFF" "=DONT_WANT")

if ("qt" IN_LIST FEATURES)
    list(APPEND VTK_FEATURE_OPTIONS -DVTK_MODULE_ENABLE_VTK_GUISupportQtQuick=YES)
    file(READ "${CURRENT_INSTALLED_DIR}/share/qtbase/vcpkg_abi_info.txt" qtbase_abi_info)
    if (qtbase_abi_info MATCHES "(^|;)gles2(;|$)")
        message(FATAL_ERROR "VTK assumes qt to be build with desktop opengl. As such trying to build vtk with qt using GLES will fail.")
        # This should really be a configure error but using this approach doesn't require patching. 
    endif ()
endif ()

if ("python" IN_LIST FEATURES)
    # This sections relies on target package python3.
    set(python_ver "")
    if (NOT VCPKG_TARGET_IS_WINDOWS)
        set(python_ver "3")
    endif ()
    list(APPEND ADDITIONAL_OPTIONS
            -DVTK_WRAP_PYTHON=ON
            -DPython3_FIND_REGISTRY=NEVER
            "-DPython3_EXECUTABLE:PATH=${CURRENT_INSTALLED_DIR}/tools/python3/python${python_ver}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
            -DVTK_MODULE_ENABLE_VTK_Python=YES
            -DVTK_MODULE_ENABLE_VTK_PythonContext2D=YES # TODO: recheck
            -DVTK_MODULE_ENABLE_VTK_PythonInterpreter=YES
            "-DVTK_PYTHON_SITE_PACKAGES_SUFFIX=${PYTHON3_SITE}" # from vcpkg-port-config.cmake
    )
    #VTK_PYTHON_SITE_PACKAGES_SUFFIX should be set to the install dir of the site-packages
endif ()

if ("paraview" IN_LIST FEATURES OR "opengl" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
            -DVTK_MODULE_ENABLE_VTK_RenderingContextOpenGL2=YES
            -DVTK_MODULE_ENABLE_VTK_RenderingLICOpenGL2=YES
            -DVTK_MODULE_ENABLE_VTK_RenderingAnnotation=YES
            -DVTK_MODULE_ENABLE_VTK_DomainsChemistryOpenGL2=YES
            -DVTK_MODULE_ENABLE_VTK_FiltersParallelDIY2=YES
    )
endif ()

if ("paraview" IN_LIST FEATURES AND "python" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
            -DVTK_MODULE_ENABLE_VTK_WebCore=YES
            -DVTK_MODULE_ENABLE_VTK_WebPython=YES
            -DVTK_MODULE_ENABLE_VTK_RenderingMatplotlib=YES
    )
endif ()

if ("paraview" IN_LIST FEATURES AND "mpi" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
            -DVTK_MODULE_ENABLE_VTK_FiltersParallelFlowPaths=YES
            -DVTK_MODULE_ENABLE_VTK_RenderingParallelLIC=YES
    )
endif ()

if ("mpi" IN_LIST FEATURES AND "python" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
            -DVTK_MODULE_USE_EXTERNAL_VTK_mpi4py=OFF
    )
endif ()

if ("cuda" IN_LIST FEATURES AND CMAKE_HOST_WIN32)
    vcpkg_add_to_path("$ENV{CUDA_PATH}/bin")
endif ()

if ("utf8" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
            -DKWSYS_ENCODING_DEFAULT_CODEPAGE=CP_UTF8
    )
endif ()

if ("all" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
            -DVTK_USE_TK=OFF # TCL/TK currently not included in vcpkg
            -DVTK_FORBID_DOWNLOADS=OFF
    )
else ()
    list(APPEND ADDITIONAL_OPTIONS
            -DVTK_FORBID_DOWNLOADS=ON
    )
endif ()

if ("tbb" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
            -DVTK_SMP_IMPLEMENTATION_TYPE=TBB
    )
endif ()

if ("openmp" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
            -DVTK_SMP_IMPLEMENTATION_TYPE=OpenMP
    )
endif ()

if (VCPKG_TARGET_IS_OSX)# VTK's OpenXR module is not supported on macOS, and it doesn't have a proper check for this in the CMakeLists, so we have to disable it manually.
    list(APPEND ADDITIONAL_OPTIONS
            -DVTK_MODULE_ENABLE_VTK_RenderingOpenXR=DONT_WANT
    )
endif ()

if ("all" IN_LIST FEATURES)
    #fix eigen dependency of onnxruntime, which is required by vtk's onnx module. This is required to avoid finding the system eigen instead of the one provided by vcpkg, which causes build errors.
    vcpkg_replace_string("${SOURCE_PATH}/Filters/ONNX/CMakeLists.txt"
            "vtk_module_find_package(PRIVATE_IF_SHARED\n  PACKAGE onnxruntime)"
            "find_package(Eigen3 CONFIG REQUIRED)\n\nvtk_module_find_package(PRIVATE_IF_SHARED\n  PACKAGE onnxruntime)"
    )
    #fix the same issue in the header file, which is required to avoid build errors when building with onnx module enabled.
    vcpkg_replace_string("${SOURCE_PATH}/Filters/ONNX/Private/vtkONNXInferenceInternals.h"
            "<onnxruntime_cxx_api.h>"
            "<onnxruntime/onnxruntime_cxx_api.h>"
    )
    vcpkg_replace_string("${SOURCE_PATH}/Filters/ONNX/vtkONNXInference.cxx"
            "<onnxruntime_cxx_api.h>"
            "<onnxruntime/onnxruntime_cxx_api.h>"
    )


endif ()
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        FEATURES
        "cuda" VTK_USE_CUDA
        "mpi" VTK_USE_MPI
        "all" VTK_BUILD_ALL_MODULES
        "tbb" VTK_SMP_ENABLE_TBB
        "openmp" VTK_SMP_ENABLE_OPENMP
)

# =============================================================================
# Configure & Install
file(COPY
        "${SOURCE_PATH}/ThirdParty/ioss/vtkioss/Ioss_TransformFactory.h"
        DESTINATION
        "${CURRENT_PACKAGES_DIR}/include/")
# We set all libraries to "system" and explicitly list the ones that should use embedded copies
vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
        ${FEATURE_OPTIONS}
        ${VTK_FEATURE_OPTIONS}
        ${PACKAGE_FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DVTK_BUILD_TESTING=OFF
        -DVTK_BUILD_EXAMPLES=OFF
        -DVTK_ENABLE_REMOTE_MODULES=OFF
        # VTK groups to enable
        -DVTK_GROUP_ENABLE_StandAlone=YES
        -DVTK_GROUP_ENABLE_Rendering=YES
        -DVTK_GROUP_ENABLE_Views=YES
        # Disable deps not in VCPKG
        -DVTK_USE_TK=OFF # TCL/TK currently not included in vcpkg
        # Select modules / groups to install
        -DVTK_USE_EXTERNAL:BOOL=ON
        -DVTK_MODULE_USE_EXTERNAL_VTK_gl2ps:BOOL=OFF # Not yet in VCPKG
        -DVTK_MODULE_USE_EXTERNAL_VTK_token:BOOL=OFF # Not yet in VCPKG
        -DVTK_MODULE_USE_EXTERNAL_VTK_vtkviskores=OFF
        -DVTK_ENABLE_OSPRAY=OFF # OSPRay is not yet in vcpkg
        -DVTK_ENABLE_VISRTX=OFF # VisRTX is not yet in vcpkg
        -DVTK_MODULE_USE_EXTERNAL_VTK_ioss:BOOL=OFF
        -DVTK_MODULE_ENABLE_VTK_IOUSD=NO # USD is not yet in vcpkg
        -DVTK_MODULE_ENABLE_VTK_IOODBC=NO
        -DVTK_MODULE_ENABLE_VTK_IOMySQL=NO
        -DVTK_MODULE_ENABLE_VTK_IOLAS=NO
        -DVTK_MODULE_ENABLE_VTK_IOADIOS2=NO
        -DVTK_MODULE_ENABLE_VTK_fides=NO
        -DTBB_VERSION_MAJOR=2022# VTK needs this to enable TBB support, but it doesn't actually use the version number for anything else.
        #-DVTK_MODULE_ENABLE_VTK_jsoncpp=YES
        ${ADDITIONAL_OPTIONS}
        -DVTK_DEBUG_MODULE_ALL=ON
        -DVTK_DEBUG_MODULE=ON
        -DVTK_QT_VERSION=6
        -DCMAKE_INSTALL_QMLDIR:PATH=qml
        -DVCPKG_HOST_TRIPLET=${_HOST_TRIPLET}
        -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON # Due to Qt6::Platform not being found on Linux platform
        MAYBE_UNUSED_VARIABLES
        VTK_MODULE_ENABLE_VTK_PythonContext2D # Guarded by a conditional
        VTK_MODULE_ENABLE_VTK_GUISupportMFC # only windows
        VTK_QT_VERSION # Only with Qt
        CMAKE_INSTALL_QMLDIR
        # When working properly these should be unused
        CMAKE_DISABLE_FIND_PACKAGE_CGNS
        CMAKE_DISABLE_FIND_PACKAGE_LibHaru
        CMAKE_DISABLE_FIND_PACKAGE_NetCDF
        CMAKE_DISABLE_FIND_PACKAGE_PROJ
        CMAKE_DISABLE_FIND_PACKAGE_SEACASExodus
        CMAKE_DISABLE_FIND_PACKAGE_SEACASIoss
        CMAKE_DISABLE_FIND_PACKAGE_SQLite3
        CMAKE_DISABLE_FIND_PACKAGE_THEORA
        CMAKE_REQUIRE_FIND_PACKAGE_CGNS
        CMAKE_REQUIRE_FIND_PACKAGE_LibHaru
        CMAKE_REQUIRE_FIND_PACKAGE_NetCDF
        CMAKE_REQUIRE_FIND_PACKAGE_PROJ
        CMAKE_REQUIRE_FIND_PACKAGE_SEACASExodus
        CMAKE_REQUIRE_FIND_PACKAGE_SEACASIoss
        CMAKE_REQUIRE_FIND_PACKAGE_SQLite3
        CMAKE_REQUIRE_FIND_PACKAGE_THEORA

)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# =============================================================================
# Fixup target files
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/vtk-${VTK_SHORT_VERSION})

# =============================================================================
# Clean-up other directories

# Delete the debug binary TOOL_NAME that is not required
function(_vtk_remove_debug_tool TOOL_NAME)
    set(filename "${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL_NAME}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    if (EXISTS "${filename}")
        file(REMOVE "${filename}")
    endif ()
    set(filename "${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL_NAME}d${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    if (EXISTS "${filename}")
        file(REMOVE "${filename}")
    endif ()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
        # we also have to bend the lines referencing the tools in VTKTargets-debug.cmake
        # to make them point to the release version of the tools
        file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/VTK-targets-debug.cmake" VTK_TARGETS_CONTENT_DEBUG)
        string(REPLACE "debug/bin/${TOOL_NAME}" "tools/vtk/${TOOL_NAME}" VTK_TARGETS_CONTENT_DEBUG "${VTK_TARGETS_CONTENT_DEBUG}")
        string(REPLACE "tools/vtk/${TOOL_NAME}d" "tools/vtk/${TOOL_NAME}" VTK_TARGETS_CONTENT_DEBUG "${VTK_TARGETS_CONTENT_DEBUG}")
        file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/VTK-targets-debug.cmake" "${VTK_TARGETS_CONTENT_DEBUG}")
    endif ()
endfunction()

# Move the release binary TOOL_NAME from bin to tools
function(_vtk_move_release_tool TOOL_NAME)
    set(old_filename "${CURRENT_PACKAGES_DIR}/bin/${TOOL_NAME}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    if (EXISTS "${old_filename}")
        file(INSTALL "${old_filename}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/vtk" USE_SOURCE_PERMISSIONS)
        file(REMOVE "${old_filename}")
    endif ()

    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release)
        # we also have to bend the lines referencing the tools in VTKTargets-release.cmake
        # to make them point to the tool folder
        file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/VTK-targets-release.cmake" VTK_TARGETS_CONTENT_RELEASE)
        string(REPLACE "bin/${TOOL_NAME}" "tools/vtk/${TOOL_NAME}" VTK_TARGETS_CONTENT_RELEASE "${VTK_TARGETS_CONTENT_RELEASE}")
        file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/VTK-targets-release.cmake" "${VTK_TARGETS_CONTENT_RELEASE}")
    endif ()
endfunction()

set(VTK_TOOLS
        vtkEncodeString-${VTK_SHORT_VERSION}
        vtkHashSource-${VTK_SHORT_VERSION}
        vtkWrapTclInit-${VTK_SHORT_VERSION}
        vtkWrapTcl-${VTK_SHORT_VERSION}
        vtkWrapPythonInit-${VTK_SHORT_VERSION}
        vtkWrapPython-${VTK_SHORT_VERSION}
        vtkWrapSerDes-${VTK_SHORT_VERSION}
        vtkWrapJava-${VTK_SHORT_VERSION}
        vtkWrapHierarchy-${VTK_SHORT_VERSION}
        vtkParseJava-${VTK_SHORT_VERSION}
        vtkWrapJavaScript-${VTK_SHORT_VERSION}
        vtkParseOGLExt-${VTK_SHORT_VERSION}
        vtkProbeOpenGLVersion-${VTK_SHORT_VERSION}
        vtkTestOpenGLVersion-${VTK_SHORT_VERSION}
        vtkpython
        pvtkpython
)
# TODO: Replace with vcpkg_copy_tools if known which tools are built with which feature
# or add and option to vcpkg_copy_tools which does not require the tool to be present
foreach (TOOL_NAME IN LISTS VTK_TOOLS)
    _vtk_remove_debug_tool("${TOOL_NAME}")
    _vtk_move_release_tool("${TOOL_NAME}")
endforeach ()

if (EXISTS "${CURRENT_PACKAGES_DIR}/bin/vtktoken-9.3.dll" AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # vendored "token" library can be only build as a shared library
    set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE
            "${CURRENT_PACKAGES_DIR}/bin"
            "${CURRENT_PACKAGES_DIR}/debug/bin")
endif ()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/vtk")

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if (EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/CMakeFiles/vtkpythonmodules/static_python") #python headers
        file(GLOB_RECURSE STATIC_PYTHON_FILES "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/CMakeFiles/*/static_python/*.h")
        file(INSTALL ${STATIC_PYTHON_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/vtk-${VTK_SHORT_VERSION}")
    endif ()
endif ()

#remove one get_filename_component(_vtk_module_import_prefix "${_vtk_module_import_prefix}" DIRECTORY) from vtk-prefix.cmake and VTK-vtk-module-properties and vtk-python.cmake
set(filenames_fix_prefix vtk-prefix VTK-vtk-module-properties vtk-python)
foreach (name IN LISTS filenames_fix_prefix)
    if (EXISTS "${CURRENT_PACKAGES_DIR}/share/vtk/${name}.cmake")
        file(READ "${CURRENT_PACKAGES_DIR}/share/vtk/${name}.cmake" _contents)
        string(REPLACE
                [[set(_vtk_module_import_prefix "${CMAKE_CURRENT_LIST_DIR}")
get_filename_component(_vtk_module_import_prefix "${_vtk_module_import_prefix}" DIRECTORY)]]
                [[set(_vtk_module_import_prefix "${CMAKE_CURRENT_LIST_DIR}")]] _contents "${_contents}")
        file(WRITE "${CURRENT_PACKAGES_DIR}/share/vtk/${name}.cmake" "${_contents}")
    else ()
        debug_message("FILE:${CURRENT_PACKAGES_DIR}/share/vtk/${name}.cmake does not exist! No prefix correction!")
    endif ()
endforeach ()

# Use vcpkg provided find method
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/${PORT}/FindEXPAT.cmake")

if (EXISTS "${CURRENT_PACKAGES_DIR}/include/vtk-${VTK_SHORT_VERSION}/vtkChemistryConfigure.h")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/vtk-${VTK_SHORT_VERSION}/vtkChemistryConfigure.h" "${SOURCE_PATH}" "not/existing" IGNORE_UNCHANGED)
endif ()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/vtk/VTK-vtk-module-properties.cmake" "_vtk_module_import_prefix}/lib/vtk-9.3/hierarchy" "_vtk_module_import_prefix}$<$<CONFIG:Debug>:/debug>/lib/vtk-9.3/hierarchy")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(RENAME "${CURRENT_PACKAGES_DIR}/share/licenses" "${CURRENT_PACKAGES_DIR}/share/${PORT}/licenses")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Copyright.txt" COMMENT [[
This file presents the top-level Copyright.txt.
Additional licenses and notes are located in the licenses directory.
]])
