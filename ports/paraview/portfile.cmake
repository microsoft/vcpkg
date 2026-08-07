set(VERSION_MAJOR_MINOR 6.1)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kitware/ParaView
    REF v${VERSION}
    SHA512 97132881dbaf3cf2589cd87c1aff9bb924aa2a2488a8df9256438e90abcb9a07bdf71bd68565f61b9498c9aa0fe6743db5ee1e24c852c460244da2b5698f7ead
    HEAD_REF master
    PATCHES
        add-tools-option.patch
        protobuf-version.patch
        fix-fmt-header.patch
        static-plugins.diff
        exe-debug-postfix.diff
)

#The following two dependencies should probably be their own port
#but require additional patching in paraview to make it work.

#Get VisItBridge Plugin
if("visitbridge" IN_LIST FEATURES)
    if(VCPKG_USE_KITWARE_GITLAB_ARCHIVES)
        vcpkg_from_gitlab(
            OUT_SOURCE_PATH VISITIT_SOURCE_PATH
            GITLAB_URL https://gitlab.kitware.com/
            REPO paraview/visitbridge
            REF be2a4143fdb979d19e6c74a7618c42d86249e809
            SHA512 c2c21d5df5ec09f7cce9d506be42b989aeffecd49240d927fecd549a652ed3b18a4ef04d6f2cd3605065ead680f594f22831ee05a62315e02a434f11051c6817
        )
    else()
        vcpkg_from_git(
            OUT_SOURCE_PATH VISITIT_SOURCE_PATH
            URL "https://gitlab.kitware.com/paraview/visitbridge"
            REF be2a4143fdb979d19e6c74a7618c42d86249e809
            HEAD_REF master
        )
    endif()
    file(COPY "${VISITIT_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/Utilities/VisItBridge")
endif()
#VTK_MODULE_USE_EXTERNAL_ParaView_protobuf
#NVPipe?
#Get QtTesting Plugin
if(VCPKG_USE_KITWARE_GITLAB_ARCHIVES)
    vcpkg_from_gitlab(
        OUT_SOURCE_PATH QTTESTING_SOURCE_PATH
        GITLAB_URL https://gitlab.kitware.com/
        REPO paraview/qttesting
        REF c11a762df71d9f44698b93a0aab5dceb59c90e63
        SHA512 8140035d59cb72bac0ce70589ba04d6ebbd631c536297887c0030f49c0375e24c7e0439c1dfc039d1b464ed3c7032e0ce5d22a0315c49fde94485ef3cb3f9c9c
    )
else()
    vcpkg_from_git(
        OUT_SOURCE_PATH QTTESTING_SOURCE_PATH
        URL "https://gitlab.kitware.com/paraview/qttesting"
        REF c11a762df71d9f44698b93a0aab5dceb59c90e63
        HEAD_REF master
    )
endif()
file(COPY "${QTTESTING_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/ThirdParty/QtTesting/vtkqttesting")

if("icet" IN_LIST FEATURES)
    if(VCPKG_USE_KITWARE_GITLAB_ARCHIVES)
        vcpkg_from_gitlab(
            OUT_SOURCE_PATH ICET_SOURCE_PATH
            GITLAB_URL https://gitlab.kitware.com/
            REPO paraview/IceT
            REF a79570acf121231aea53be23fe200b740a85c23c
            SHA512 66f2607e759a88a892f3f91a28fd1046dc168a7a4d6ed3b42aafbfa60f83c4805ea6097e10c303e30dd03c40db7a9819d8fabe725b1de89e357e2dfeb4449072
        )
    else()
        vcpkg_from_git(
            OUT_SOURCE_PATH ICET_SOURCE_PATH
            URL "https://gitlab.kitware.com/paraview/IceT"
            REF a79570acf121231aea53be23fe200b740a85c23c
            HEAD_REF master
        )
    endif()
    file(COPY "${ICET_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/ThirdParty/IceT/vtkicet")
endif()

set(plat_feat "")
if(VCPKG_TARGET_IS_LINUX)
    set(plat_feat "tools" VTK_USE_X) # required to build the client
endif()
if(VCPKG_TARGET_IS_OSX)
    set(plat_feat "tools" VTK_USE_COCOA) # required to build the client
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES
    "all-modules"  PARAVIEW_BUILD_ALL_MODULES   #untested
    "cuda"         PARAVIEW_USE_CUDA            #untested; probably only affects internal VTK build so it does nothing here
    "mpi"          PARAVIEW_USE_MPI             #untested
    "python"       PARAVIEW_USE_PYTHON
    "tools"        PARAVIEW_BUILD_TOOLS
    "visitbridge"  PARAVIEW_ENABLE_VISITBRIDGE
    "vtkm"         PARAVIEW_USE_VISKORES
    ${plat_feat}
)
#string(REGEX REPLACE "(-DVTK_MODULE_ENABLE[^=]*)=ON" "\\1=YES" FEATURE_OPTIONS "${FEATURE_OPTIONS}")
#string(REGEX REPLACE "(-DVTK_MODULE_ENABLE[^=]*)=OFF" "\\1=NO" FEATURE_OPTIONS "${FEATURE_OPTIONS}")

if("python" IN_LIST FEATURES)
    vcpkg_get_vcpkg_installed_python(PYTHON3)
    list(APPEND FEATURE_OPTIONS
        -DPython3_FIND_REGISTRY=NEVER
        "-DPython3_EXECUTABLE:PATH=${PYTHON3}"
        "-DPARAVIEW_PYTHON_SITE_PACKAGES_SUFFIX=${PYTHON3_SITE}" # from vcpkg-port-config.cmake
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
        -DCMAKE_POLICY_DEFAULT_CMP0076=NEW
        -DCMAKE_POLICY_DEFAULT_CMP0079=NEW
        -DCMAKE_POLICY_DEFAULT_CMP0167=OLD  # FindBoost.cmake
        -DPARAVIEW_BUILD_SHARED_LIBS=${PARAVIEW_BUILD_SHARED_LIBS}
        -DPARAVIEW_BUILD_WITH_EXTERNAL=ON
        -DPARAVIEW_ENABLE_EMBEDDED_DOCUMENTATION=OFF
        -DPARAVIEW_PLUGIN_DISABLE_XML_DOCUMENTATION=ON
        -DPARAVIEW_USE_EXTERNAL_VTK=ON
        -DPARAVIEW_USE_FORTRAN=OFF
        -DPARAVIEW_USE_QTHELP=OFF
        -DVCPKG_TRACE_FIND_PACKAGE=ON
    OPTIONS_DEBUG
        -DPARAVIEW_BUILD_TOOLS=OFF
    MAYBE_UNUSED_VARIABLES
        PARAVIEW_ENABLE_EMBEDDED_DOCUMENTATION
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/paraview-${VERSION_MAJOR_MINOR})

set(TOOLS
    smTestDriver-pv${VERSION_MAJOR_MINOR}
    vtkProcessXML-pv${VERSION_MAJOR_MINOR}
    vtkWrapClientServer-pv${VERSION_MAJOR_MINOR}
)
if("tools" IN_LIST FEATURES)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/paraview-config" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/paraview-config")
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/paraview-config")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/paraview-config" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/paraview-config")
    endif()
    list(APPEND TOOLS
        paraview
        pvdataserver
        pvrenderserver
        pvserver
    )
    if("python" IN_LIST FEATURES)
        list(APPEND TOOLS
            pvbatch
            pvpython
        )
    endif()
endif()
vcpkg_copy_tools(TOOL_NAMES ${TOOLS} AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
# The plugins also work without these files
file(REMOVE "${CURRENT_PACKAGES_DIR}/Applications/paraview.app/Contents/Resources/paraview.conf")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/Applications/paraview.app/Contents/Resources/paraview.conf")
# https://gitlab.kitware.com/paraview/paraview/-/issues/21328
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/paraview-${VERSION_MAJOR_MINOR}/vtkCPConfig.h")

file(RENAME "${CURRENT_PACKAGES_DIR}/share/licenses" "${CURRENT_PACKAGES_DIR}/share/${PORT}/licenses")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Copyright.txt")
