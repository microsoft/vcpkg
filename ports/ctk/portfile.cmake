vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commontk/CTK
    REF 60a0740f228633f118698b4526256a4c2110ce81 # committed on 2023.07.18
    SHA512 ca04912ed516020c998865e877cb7df2e7f7758cb21346997ca4fcd76ebbbf6c4670ac4d51c03b5a7f6a7ed4ccc0d90096ae0ab566ee96c2b073826af0cc9ad8
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DCTK_APP_ctkDICOM=ON
        -DCTK_APP_ctkDICOM2=ON
        -DCTK_APP_ctkDICOMDemoSCU=ON
        -DCTK_APP_ctkDICOMHost=ON
        -DCTK_APP_ctkDICOMIndexer=ON
        -DCTK_APP_ctkDICOMObjectViewer=ON
        -DCTK_APP_ctkDICOMQuery=ON
        -DCTK_APP_ctkDICOMQueryRetrieve=ON
        -DCTK_APP_ctkDICOMRetrieve=ON
        -DCTK_APP_ctkExampleHost=ON
        -DCTK_APP_ctkExampleHostedApp=ON
        -DCTK_APP_ctkPluginBrowser=ON
        -DCTK_APP_ctkPluginGenerator=ON
        -DCTK_APP_ctkXnatTreeBrowser=ON
        -DCTK_SUPERBUILD=ON
        -DCTK_USE_QTTESTING=OFF
        -DCTK_USE_SYSTEM_VTK=OFF
        -DCTK_USE_SYSTEM_DCMTK=ON
        -DCTK_USE_SYSTEM_ITK=OFF
        -DCTK_BUILD_QTDESIGNER_PLUGINS=OFF
        -DCTK_BUILD_SHARED_LIBS=ON
        -DCTK_ENABLE_DICOM=ON
        -DCTK_ENABLE_DICOMApplicationHosting=ON
        -DCTK_ENABLE_PluginFramework=ON
        -DCTK_ENABLE_Widgets=ON
        -DCTK_LIB_CommandLineModules/Backend/FunctionPointer=ON
        -DCTK_LIB_CommandLineModules/Backend/LocalProcess=ON
        -DCTK_LIB_CommandLineModules/Backend/XMLChecker=ON
        -DCTK_LIB_CommandLineModules/Core=ON
        -DCTK_LIB_CommandLineModules/Frontend/QtGui=OFF
        -DCTK_LIB_CommandLineModules/Frontend/QtWebkit=OFF
        -DCTK_LIB_Widgets=ON
        -DCTK_LIB_Core=ON
        -DCTK_LIB_DICOM/Core=ON
        -DCTK_LIB_DICOM/Widgets=ON
        -DCTK_LIB_ImageProcessing/ITK/Core=OFF
        -DCTK_LIB_PluginFramework=ON
        -DCTK_LIB_Visualization/VTK/Core=OFF
        -DCTK_LIB_Visualization/VTK/Widgets=OFF
        -DCTK_LIB_XNAT/Core=ON
        -DCTK_LIB_XNAT/Widgets=ON
        -DCTK_PLUGIN_org.commontk.configadmin=ON
        -DCTK_PLUGIN_org.commontk.dah.cmdlinemoduleapp=ON
        -DCTK_PLUGIN_org.commontk.dah.core=ON
        -DCTK_PLUGIN_org.commontk.dah.exampleapp=ON
        -DCTK_PLUGIN_org.commontk.dah.examplehost=ON
        -DCTK_PLUGIN_org.commontk.dah.host=ON
        -DCTK_PLUGIN_org.commontk.dah.hostedapp=ON
        -DCTK_PLUGIN_org.commontk.eventadmin=ON
        -DCTK_PLUGIN_org.commontk.log=ON
        -DCTK_PLUGIN_org.commontk.metatype=ON
        -DCTK_PLUGIN_org.commontk.plugingenerator.core=ON
        -DCTK_PLUGIN_org.commontk.plugingenerator.ui=ON
)
elseif(VCPKG_TARGET_IS_LINUX)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DCTK_APP_ctkDICOM=ON
        -DCTK_APP_ctkDICOM2=ON
        -DCTK_APP_ctkDICOMDemoSCU=ON
        -DCTK_APP_ctkDICOMHost=ON
        -DCTK_APP_ctkDICOMIndexer=ON
        -DCTK_APP_ctkDICOMObjectViewer=ON
        -DCTK_APP_ctkDICOMQuery=ON
        -DCTK_APP_ctkDICOMQueryRetrieve=ON
        -DCTK_APP_ctkDICOMRetrieve=ON
        -DCTK_APP_ctkExampleHost=ON
        -DCTK_APP_ctkExampleHostedApp=ON
        -DCTK_APP_ctkPluginBrowser=ON
        -DCTK_APP_ctkPluginGenerator=ON
        -DCTK_APP_ctkQtTesting=OFF
        -DCTK_APP_ctkXnatTreeBrowser=ON
        -DCTK_SUPERBUILD=ON
        -DCTK_USE_SYSTEM_VTK=OFF
        -DCTK_USE_SYSTEM_DCMTK=ON
        -DCTK_USE_SYSTEM_ITK=OFF
        -DCTK_BUILD_QTDESIGNER_PLUGINS=OFF
        -DCTK_BUILD_SHARED_LIBS=ON
        -DCTK_ENABLE_DICOM=ON
        -DCTK_ENABLE_DICOMApplicationHosting=ON
        -DCTK_ENABLE_PluginFramework=ON
        -DCTK_ENABLE_Widgets=ON
        -DCTK_LIB_CommandLineModules/Backend/FunctionPointer=ON
        -DCTK_LIB_CommandLineModules/Backend/LocalProcess=ON
        -DCTK_LIB_CommandLineModules/Backend/XMLChecker=ON
        -DCTK_LIB_CommandLineModules/Core=ON
        -DCTK_LIB_CommandLineModules/Frontend/QtGui=OFF
        -DCTK_LIB_CommandLineModules/Frontend/QtWebkit=OFF
        -DCTK_LIB_Widgets=ON
        -DCTK_LIB_Core=ON
        -DCTK_LIB_Core_WITH_BFD_SHARED=OFF # Linux Only
        -DCTK_LIB_DICOM/Core=ON
        -DCTK_LIB_DICOM/Widgets=ON
        -DCTK_LIB_ImageProcessing/ITK/Core=OFF
        -DCTK_LIB_PluginFramework=ON
        -DCTK_LIB_Visualization/VTK/Core=OFF
        -DCTK_LIB_Visualization/VTK/Widgets=OFF
        -DCTK_LIB_XNAT/Core=ON
        -DCTK_LIB_XNAT/Widgets=ON
        -DCTK_PLUGIN_org.commontk.configadmin=ON
        -DCTK_PLUGIN_org.commontk.dah.cmdlinemoduleapp=ON
        -DCTK_PLUGIN_org.commontk.dah.core=ON
        -DCTK_PLUGIN_org.commontk.dah.exampleapp=ON
        -DCTK_PLUGIN_org.commontk.dah.examplehost=ON
        -DCTK_PLUGIN_org.commontk.dah.host=ON
        -DCTK_PLUGIN_org.commontk.dah.hostedapp=ON
        -DCTK_PLUGIN_org.commontk.eventadmin=ON
        -DCTK_PLUGIN_org.commontk.log=ON
        -DCTK_PLUGIN_org.commontk.metatype=ON
        -DCTK_PLUGIN_org.commontk.plugingenerator.core=ON
        -DCTK_PLUGIN_org.commontk.plugingenerator.ui=ON
)
endif()

vcpkg_cmake_install()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/CTK-build/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/" FILES_MATCHING PATTERN *.exe)
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/CTK-build/bin/" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/" FILES_MATCHING PATTERN *.lib)
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/CTK-build/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/" FILES_MATCHING PATTERN *.dll)
endif()

if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/CTK-build/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/" FILES_MATCHING PATTERN *.exe)
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/CTK-build/bin/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/" FILES_MATCHING PATTERN *.lib)
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/CTK-build/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/" FILES_MATCHING PATTERN *.dll)
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/CTK-build/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/" FILES_MATCHING PATTERN *.pdb)
endif()

# ctkCoreExport.h
file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/CTK-build/Libs/Core/ctkCoreExport.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/ctk/")
# ctkPluginFrameworkExport.h
file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/CTK-build/Libs/PluginFramework/ctkPluginFrameworkExport.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/ctk/")
# other
file(COPY "${SOURCE_PATH}/Libs/Core" DESTINATION "${CURRENT_PACKAGES_DIR}/include/ctk/Libs" FILES_MATCHING PATTERN *.h)
file(COPY "${SOURCE_PATH}/Libs/PluginFramework" DESTINATION "${CURRENT_PACKAGES_DIR}/include/ctk/Libs" FILES_MATCHING PATTERN *.h)
file(COPY "${SOURCE_PATH}/Libs/Widgets" DESTINATION "${CURRENT_PACKAGES_DIR}/include/ctk/Libs" FILES_MATCHING PATTERN *.h)

# Install the pkgconfig file
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
