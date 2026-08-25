set(VERSION_MAJOR_MINOR 5.12)

# ParaView bundles its own VTK (PARAVIEW_USE_EXTERNAL_VTK=OFF) from a
# specific git submodule commit. Bundled VTK installs headers/libs with
# paraview prefixes and suffixes to coexist with standalone vtk port.
# Third-party dependencies come from vcpkg (VTK_USE_EXTERNAL=ON).

# paraview[python] and vtk[python] conflict: both install vtkmodules to the
# same site-packages path. Fail fast with actionable guidance.
if("python" IN_LIST FEATURES AND
   EXISTS "${CURRENT_INSTALLED_DIR}/${PYTHON3_SITE}/vtkmodules/__init__.py")
    message(FATAL_ERROR
        "paraview[python] cannot be installed: vtk's Python bindings are already "
        "installed in this triplet (${CURRENT_INSTALLED_DIR}), and paraview[python] "
        "would install the same 'vtkmodules' Python package (from its own bundled "
        "VTK) to the same tools/python3 site-packages path, which is not something "
        "Python supports two different builds sharing.\n"
        "Pick one of the following:\n"
        "  * `vcpkg remove vtk` (or reinstall it without the \"python\" feature), "
        "then install paraview[python], or\n"
        "  * drop \"python\" from this paraview install if you don't need "
        "pvpython/pvbatch/paraview.simple, or\n"
        "  * install into a separate triplet if you genuinely need both "
        "vtk[python] and paraview[python] installed at once.")
endif()

set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)

set(plat_feat "")
if(VCPKG_TARGET_IS_LINUX)
    set(plat_feat "tools" VTK_USE_X) # required to build the client
endif()
if(VCPKG_TARGET_IS_LINUX)
    set(plat_feat "tools" VTK_USE_COCOA) # required to build the client
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES
    "cuda"         PARAVIEW_USE_CUDA
    "all_modules"  PARAVIEW_BUILD_ALL_MODULES
    "vtkm"         PARAVIEW_USE_VTKM
    "python"       PARAVIEW_USE_PYTHON
    "tools"        PARAVIEW_BUILD_TOOLS
    ${plat_feat}
)

# Mirrors ports/vtk/portfile.cmake: an MPI-aware HDF5 requires VTK (and thus
# ParaView's bundled VTK) to also be built with MPI support, regardless of
# whether the "mpi" feature was requested.
set(use_mpi OFF)
if("mpi" IN_LIST FEATURES)
    set(use_mpi ON)
elseif(HDF5_WITH_PARALLEL)
    message(WARNING "${HDF5_WITH_PARALLEL} Enabling ParaView MPI.")
    set(use_mpi ON)
endif()
list(APPEND ADDITIONAL_OPTIONS -DPARAVIEW_USE_MPI=${use_mpi})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kitware/ParaView
    REF 8751c670e2aac949f17dd701a5a2f13849afafb2 # v5.12.1
    SHA512 ed7b7e183c9d1350d8d2feadf7b76bef939bc657f49e5160e2e96e2329642d8ba1c0a8ab7cb58ff068ba21b7adc3f52676b38779e1ecec31b4714184c2364072
    HEAD_REF master
    PATCHES
        add-tools-option.patch
        fix-build.patch
        protobuf-version.patch
        plugin.patch
        explicit_int_cast_2.patch
        fix-fmt-header.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND VisItPatches removedoublesymbols.patch)
endif()

# ParaView's bundled VTK from git submodule commit.
vcpkg_from_github(
    OUT_SOURCE_PATH VTK_SOURCE_PATH
    REPO Kitware/VTK
    REF 09a76bc55b37caad94d0d8ebe865caaed1b438af
    SHA512 396ee901fafacae8aef860b9c9c17cb92ae8b4969527fd271ad8dd9f6a9e0dc8e3dc807c8d43cc585608ad101a64edcd7aff49e1580c7a61a817c2ea8e2655f5
    HEAD_REF master
    PATCHES
        vtk/ffmpeg.diff
        vtk/ffmpeg-8.diff # c2bd786 + b8da15a + 492a5cd
        vtk/FindLZMA.patch
        vtk/FindLZ4.patch
        vtk/libproj.patch
        vtk/mysql.diff
        vtk/pegtl.patch
        vtk/pythonwrapper.patch # Required by ParaView to Wrap required classes
        vtk/NoUndefDebug.patch # Required to link against correct Python library depending on build type.
        vtk/fix-using-hdf5.patch
        vtk/FindExpat.patch # The find_library calls are taken care of by vcpkg-cmake-wrapper.cmake of expat
        vtk/cgns.patch
        vtk/vtkm.patch
        vtk/afxdll.patch
        vtk/vtkioss.patch
        vtk/jsoncpp.patch
        vtk/iotr.patch
        vtk/fast-float.patch
        vtk/fix-exprtk.patch # just for dbow2 and theia
        vtk/devendor_exodusII.patch
        vtk/remove-prefix-changes.patch
        vtk/hdf5helper.patch
        vtk/opencascade-7.8.0.patch
        vtk/no-libharu-for-ioexport.patch
        vtk/no-libproj-for-netcdf.patch
        vtk/octree.patch
        vtk/fix-tbbsmptool.patch  # https://gitlab.kitware.com/vtk/vtk/-/merge_requests/11530
        vtk/backport-bda8324.diff # https://gitlab.kitware.com/vtk/vtk/-/merge_requests/12418
        vtk/use-compile-tools.diff
        vtk/zspace.diff # https://gitlab.kitware.com/vtk/vtk/-/commit/01a8bd7a917d33892f67a8d76ce7fc4b524d56b4
        vtk/mpi-language.diff
        vtk/fix-eigen3.patch
        vtk/avoid-stdext.diff
        vtk/fix-fmt-header.patch
)

# Overwrite outdated modules if they have not been patched (mirrors the vtk port):
file(COPY "${CURRENT_PORT_DIR}/vtk/FindHDF5.cmake" DESTINATION "${VTK_SOURCE_PATH}/CMake/patches/99") # due to usage of targets in netcdf-c

file(REMOVE "${VTK_SOURCE_PATH}/CMake/FindOGG.cmake")
vcpkg_replace_string("${VTK_SOURCE_PATH}/ThirdParty/ogg/CMakeLists.txt" "OGG::OGG" "Ogg::ogg")
vcpkg_replace_string("${VTK_SOURCE_PATH}/ThirdParty/ogg/CMakeLists.txt" "OGG" "Ogg")
vcpkg_replace_string("${VTK_SOURCE_PATH}/CMake/vtkInstallCMakePackage.cmake" "FindOGG.cmake\n" "")
vcpkg_replace_string("${VTK_SOURCE_PATH}/CMake/FindTHEORA.cmake" "find_dependency(OGG)" "find_dependency(Ogg CONFIG)")
vcpkg_replace_string("${VTK_SOURCE_PATH}/CMake/FindTHEORA.cmake" "OGG::OGG" "Ogg::ogg")

# Populate ParaView's "VTK" submodule directory with the patched VTK source.
file(COPY "${VTK_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/VTK")

#Get VisItBridge Plugin
vcpkg_from_gitlab(
    OUT_SOURCE_PATH VISITIT_SOURCE_PATH
    GITLAB_URL https://gitlab.kitware.com/
    REPO paraview/visitbridge
    REF 92ad478e3d6b18b111ef45ab76d6dad5d3530381
    SHA512 c4893929b99419a365e90450f9c6d8a72f30f88aadbfe5c7d23ec4a46e9cf301e0b9c31cd602d1ab717ffb6744ae45abe41cb0e9c1f02b83e4468c702e8d023d
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
    REF 9d4346485cfce79ad448f7e5656b2525b255b2ca
    SHA512  7561cd66e1a12053b7a81ab7a80ad2163922995317a503761521151668a905602fb1bb23c963e18d2739d17aa4187ccf1b4bd1010b0494aab6d4fc004e0e9760
    PATCHES
      explicit_int_cast.patch
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

# =============================================================================
# Cross-compiling: Same rationale as ports/vtk/portfile.cmake. The bundled
# VTK's wrap tools must run on the build machine, so point at a host-triplet
# vtk install's tool binaries instead. Paraview does not declare a "host"
# dependency on vtk to force this; whoever cross-compiles paraview is
# expected to have vtk installed for their host triplet already.
set(VTK_CROSSCOMPILE_OPTIONS "")
if(VCPKG_CROSSCOMPILING)
    set(VTK_HOST_TOOLS_DIR "${CURRENT_HOST_INSTALLED_DIR}/tools/vtk")
    if(NOT EXISTS "${VTK_HOST_TOOLS_DIR}/vtkWrapHierarchy-9.3${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        message(FATAL_ERROR
            "paraview is cross-compiling (target triplet '${TARGET_TRIPLET}', "
            "host triplet '${HOST_TRIPLET}') and needs prebuilt wrap-tool "
            "binaries from a host-triplet vtk install for its bundled VTK to "
            "generate wrapper code, but none were found at "
            "'${VTK_HOST_TOOLS_DIR}'.\n"
            "Install vtk for your host triplet first, e.g.:\n"
            "  vcpkg install vtk:${HOST_TRIPLET}")
    endif()
    list(APPEND VTK_CROSSCOMPILE_OPTIONS
        -DVTK_USE_EXTERNAL_COMPILE_TOOLS=ON
        "-DVTK_HOST_TOOLS_DIR=${VTK_HOST_TOOLS_DIR}"
        "-DVTK_HOST_EXECUTABLE_SUFFIX=${VCPKG_HOST_EXECUTABLE_SUFFIX}"
    )
endif()

# =============================================================================
# VTK module options for the bundled VTK. Mirrors the options the `vtk`
# port sets for its "qt", "seacas", "netcdf", and "libtheora" features,
# since ParaView builds these VTK modules itself. See
# ports/vtk/portfile.cmake for the equivalent standalone-VTK logic.
# =============================================================================
list(APPEND ADDITIONAL_OPTIONS
    -DVTK_USE_EXTERNAL:BOOL=ON
    -DVTK_MODULE_USE_EXTERNAL_VTK_token:BOOL=OFF # Not yet in vcpkg
    -DVTK_MODULE_ENABLE_VTK_WrappingTools=YES
    -DVTK_GROUP_ENABLE_StandAlone=YES
    -DVTK_GROUP_ENABLE_Rendering=YES
    -DVTK_GROUP_ENABLE_Views=YES
    -DVTK_GROUP_ENABLE_Qt=YES
    -DVTK_MODULE_ENABLE_VTK_GUISupportQt=YES
    -DVTK_MODULE_ENABLE_VTK_GUISupportQtSQL=YES
    -DVTK_MODULE_ENABLE_VTK_RenderingQt=YES
    -DVTK_MODULE_ENABLE_VTK_ViewsQt=YES
    -DVTK_MODULE_ENABLE_VTK_sqlite=YES
    -DVTK_MODULE_ENABLE_VTK_IOSQL=YES
    -DVTK_MODULE_ENABLE_VTK_IOOggTheora=YES
    -DVCPKG_LOCK_FIND_PACKAGE_SQLite3=ON
    -DVCPKG_LOCK_FIND_PACKAGE_THEORA=ON
    # netcdf (required by the seacas/cgns readers below)
    -DVCPKG_LOCK_FIND_PACKAGE_NetCDF=ON
    -DVTK_MODULE_ENABLE_VTK_netcdf=YES
    -DVTK_MODULE_ENABLE_VTK_IOMINC=YES
    -DVTK_MODULE_ENABLE_VTK_IONetCDF=YES
    # cgns (pulled in by seacas in the vtk port; mirrored here directly)
    -DVCPKG_LOCK_FIND_PACKAGE_CGNS=ON
    -DVTK_MODULE_ENABLE_VTK_IOCGNSReader=YES
    # seacas / exodus / ioss
    -DVCPKG_LOCK_FIND_PACKAGE_SEACASExodus=ON
    -DVCPKG_LOCK_FIND_PACKAGE_SEACASIoss=ON
    -DVTK_MODULE_ENABLE_VTK_IOIOSS=YES
    -DVTK_MODULE_ENABLE_VTK_IOExodus=YES
    # ParaView-specific VTK modules
    -DVTK_MODULE_ENABLE_VTK_FiltersParallelStatistics=YES
    -DVTK_MODULE_ENABLE_VTK_IOParallelExodus=YES
    -DVTK_MODULE_ENABLE_VTK_RenderingParallel=YES
    -DVTK_MODULE_ENABLE_VTK_RenderingVolumeAMR=YES
    -DVTK_MODULE_ENABLE_VTK_IOXdmf2=YES
    -DVTK_MODULE_ENABLE_VTK_IOH5part=YES
    -DVTK_MODULE_ENABLE_VTK_IOH5Rage=YES
    -DVTK_MODULE_ENABLE_VTK_IOParallelLSDyna=YES
    -DVTK_MODULE_ENABLE_VTK_IOTRUCHAS=YES
    -DVTK_MODULE_ENABLE_VTK_IOVPIC=YES
    -DVTK_MODULE_ENABLE_VTK_RenderingAnnotation=YES
    -DVTK_MODULE_ENABLE_VTK_DomainsChemistry=YES
    -DVTK_MODULE_ENABLE_VTK_FiltersParallelDIY2=YES
    -DVTK_MODULE_ENABLE_VTK_cli11=YES
    -DVTK_MODULE_ENABLE_VTK_FiltersOpenTURNS=YES
    -DVTK_MODULE_ENABLE_VTK_FiltersParallelVerdict=YES
    -DVTK_MODULE_ENABLE_VTK_IOOMF=YES
    -DVTK_MODULE_ENABLE_VTK_IOPIO=YES
    # opengl (always required by paraview's rendering)
    -DVTK_MODULE_ENABLE_VTK_ImagingOpenGL2=YES
    -DVTK_MODULE_ENABLE_VTK_RenderingGL2PSOpenGL2=YES
    -DVTK_MODULE_ENABLE_VTK_RenderingOpenGL2=YES
    -DVTK_MODULE_ENABLE_VTK_RenderingVolumeOpenGL2=YES
    -DVTK_MODULE_ENABLE_VTK_opengl=YES
    -DVTK_MODULE_ENABLE_VTK_RenderingContextOpenGL2=YES
    -DVTK_MODULE_ENABLE_VTK_RenderingLICOpenGL2=YES
    -DVTK_MODULE_ENABLE_VTK_DomainsChemistryOpenGL2=YES
    # Excludes not present/wanted in vcpkg (mirrors the vtk port):
    -DVTK_MODULE_ENABLE_VTK_CommonArchive=NO
    -DVTK_MODULE_ENABLE_VTK_DomainsMicroscopy=NO
    -DVTK_MODULE_ENABLE_VTK_fides=NO
    -DVTK_MODULE_ENABLE_VTK_FiltersReebGraph=NO
    -DVTK_MODULE_ENABLE_VTK_InfovisBoost=NO
    -DVTK_MODULE_ENABLE_VTK_InfovisBoostGraphAlgorithms=NO
    -DVTK_MODULE_ENABLE_VTK_IOADIOS2=NO
    -DVTK_MODULE_ENABLE_VTK_IOAlembic=NO
    -DVTK_MODULE_ENABLE_VTK_IOLAS=NO
    -DVTK_MODULE_ENABLE_VTK_IOOpenVDB=NO
    -DVTK_MODULE_ENABLE_VTK_IOPDAL=NO
    -DVTK_MODULE_ENABLE_VTK_RenderingOpenXR=NO
    # The WebGPU module only has a render-window factory for X11 and
    # Emscripten, and hard-errors at configure time on Windows otherwise.
    -DVTK_MODULE_ENABLE_VTK_RenderingWebGPU=NO
    -DVTK_MODULE_ENABLE_VTK_xdmf3=NO
    # ParaView's GUI is widget-based, not QML-based, and does not need this.
    # Also avoids a real conflict: VTK's QML plugin directory name is fixed
    # to "VTK.<major>.<minor>" with no suffix mechanism, so it collides with
    # the standalone vtk port's install if both are built with "qt".
    -DVTK_MODULE_ENABLE_VTK_GUISupportQtQuick=NO
    -DVTK_QT_VERSION=6
    -DCMAKE_INSTALL_QMLDIR:PATH=qml
    ${VTK_CROSSCOMPILE_OPTIONS}
    -DVCPKG_HOST_TRIPLET=${_HOST_TRIPLET}
    -DCMAKE_POLICY_DEFAULT_CMP0174=NEW     # cmake_parse_arguments
    -DCMAKE_POLICY_DEFAULT_CMP0177=NEW     # install() DESTINATION paths are normalized
    -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON # Due to Qt6::Platform not being found on Linux platform
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_MODULE_ENABLE_VTK_IOODBC=NO
    )
endif()

file(READ "${CURRENT_INSTALLED_DIR}/share/qtbase/vcpkg_abi_info.txt" qtbase_abi_info)
if(qtbase_abi_info MATCHES "(^|;)gles2(;|$)")
    message(FATAL_ERROR "VTK/ParaView assumes qt to be built with desktop opengl. As such trying to build with qt using GLES will fail.")
endif()

if("atlmfc" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS -DVTK_MODULE_ENABLE_VTK_GUISupportMFC=YES)
else()
    list(APPEND ADDITIONAL_OPTIONS -DVTK_MODULE_ENABLE_VTK_GUISupportMFC=NO)
endif()

if("vtkm" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_MODULE_ENABLE_VTK_vtkm=YES
        -DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmCore=YES
        -DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmDataModel=YES
        -DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmFilters=YES
    )
endif()

if(use_mpi)
    list(APPEND ADDITIONAL_OPTIONS
        -DVTK_GROUP_ENABLE_MPI=YES
        -DVTK_MODULE_ENABLE_VTK_ParallelMPI=YES
        -DVTK_MODULE_ENABLE_VTK_FiltersParallelFlowPaths=YES
        -DVTK_MODULE_ENABLE_VTK_RenderingParallelLIC=YES
    )
endif()

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
        -DVTK_MODULE_ENABLE_VTK_Python=YES
        -DVTK_MODULE_ENABLE_VTK_PythonContext2D=YES
        -DVTK_MODULE_ENABLE_VTK_PythonInterpreter=YES
        -DVTK_MODULE_ENABLE_VTK_WebCore=YES
        -DVTK_MODULE_ENABLE_VTK_WebPython=YES
        -DVTK_MODULE_ENABLE_VTK_RenderingMatplotlib=YES
        )
    if(use_mpi)
        list(APPEND ADDITIONAL_OPTIONS -DVTK_MODULE_USE_EXTERNAL_VTK_mpi4py=OFF)
    endif()
endif()

if("cuda" IN_LIST FEATURES)
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    list(APPEND ADDITIONAL_OPTIONS
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
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
        -DPARAVIEW_USE_EXTERNAL_VTK:BOOL=OFF # Bundle/vendor VTK, see note at top of file
        -DPARAVIEW_ENABLE_VISITBRIDGE:BOOL=ON
        -DVTK_MODULE_ENABLE_ParaView_qttesting=YES
        -DPARAVIEW_ENABLE_EMBEDDED_DOCUMENTATION:BOOL=OFF
        -DPARAVIEW_USE_QTHELP:BOOL=OFF
        -DPARAVIEW_BUILD_TESTING:BOOL=OFF
        # A little bit of help in finding the boost headers
        "-DBoost_INCLUDE_DIR:PATH=${CURRENT_INSTALLED_DIR}/include"

        # Workarounds for CMake issues
        -DHAVE_SYS_TYPES_H=0    ## For some strange reason the test first succeeds and then fails the second time around
        -DWORDS_BIGENDIAN=0     ## Tests fails in VisItCommon.cmake for some unknown reason this is just a workaround since most systems are little endian.
        ${ADDITIONAL_OPTIONS}

        #-DPARAVIEW_ENABLE_FFMPEG:BOOL=OFF
    MAYBE_UNUSED_VARIABLES
        VTK_MODULE_ENABLE_VTK_GUISupportMFC # only windows
        VTK_MODULE_ENABLE_VTK_vtkm
        VTK_MODULE_USE_EXTERNAL_VTK_mpi4py
        CMAKE_POLICY_DEFAULT_CMP0174
        CMAKE_POLICY_DEFAULT_CMP0177
        # When working properly these should be unused
        VCPKG_LOCK_FIND_PACKAGE_CGNS
        VCPKG_LOCK_FIND_PACKAGE_NetCDF
        VCPKG_LOCK_FIND_PACKAGE_SEACASExodus
        VCPKG_LOCK_FIND_PACKAGE_SEACASIoss
        VCPKG_LOCK_FIND_PACKAGE_SQLite3
        VCPKG_LOCK_FIND_PACKAGE_THEORA
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

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/vtktoken-pv${VERSION_MAJOR_MINOR}.dll" AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  # vendored "token" library can only be built as a shared library
  set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)
endif()

set(TOOLVER pv${VERSION_MAJOR_MINOR})
set(TOOLS   paraview
            pvbatch
            pvdataserver
            pvpython
            pvrenderserver
            pvserver
            smTestDriver
            vtkProcessXML
            vtkWrapClientServer
            # Build-time OpenGL-probing utilities from the bundled VTK; VTK's
            # own port moves these into tools/vtk, so mirror that here too.
            vtkProbeOpenGLVersion
            vtkTestOpenGLVersion)

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
