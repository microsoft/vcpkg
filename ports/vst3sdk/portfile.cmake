vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO steinbergmedia/vst3sdk
    REF ${VERSION}
    SHA512 0a0dc8d84a943ef06353cea748c8dd09e012f70f28ce56912c3e0038718dd2f353e142d4f39ea52979f3c08446a4ee0e8f0038c6d602207da8b0a22877e0c9f2
    HEAD_REF master
)

#Submodules
vcpkg_from_github(
    OUT_SOURCE_PATH BASE_SOURCE_PATH
    REPO steinbergmedia/vst3_base
    REF ${VERSION}
    SHA512 84f7ce79674756bde0829ea12220d15b1f82bd68dea8214ae0430324ab55cfa224550b7afc7962686359bb267b971860977d1993f4de76789d79d41b397ece9d
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/base")
file(RENAME "${BASE_SOURCE_PATH}" "${SOURCE_PATH}/base")

vcpkg_from_github(
    OUT_SOURCE_PATH CMAKE_SOURCE_PATH
    REPO steinbergmedia/vst3_cmake
    REF ${VERSION}
    SHA512 4beac9436786f2d6fc73f67a0eac5f96fdfb515f79c4ce1ef6fe7f39cdfdd6d026d903d177bd58438dc5576f0d3124843c7eabb97737f91425105e28efa6e636
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake")
file(RENAME "${CMAKE_SOURCE_PATH}" "${SOURCE_PATH}/cmake")

vcpkg_from_github(
    OUT_SOURCE_PATH DOC_SOURCE_PATH
    REPO steinbergmedia/vst3_doc
    REF ${VERSION}
    SHA512 b6a99ddfa749abd547ac0a1ff37e00985b7df537b32534d6e9255733257b104bbd0643d69675bc1d9c69d248aba45694e559996cc7eac97f977faef0daf84352
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/doc")
file(RENAME "${DOC_SOURCE_PATH}" "${SOURCE_PATH}/doc")

vcpkg_from_github(
    OUT_SOURCE_PATH PLUGININTERFACES_SOURCE_PATH
    REPO steinbergmedia/vst3_pluginterfaces
    REF ${VERSION}
    SHA512 f0007b3b5c917c0bc1f0fa4320d1800ee99a0cc445654e5d12b0e094f2ec20cffc9c9051d89fca917d59ac48313524f65fb7647ffe32eae95e50c3adc811a63f
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/pluginterfaces")
file(RENAME "${PLUGININTERFACES_SOURCE_PATH}" "${SOURCE_PATH}/pluginterfaces")

vcpkg_from_github(
    OUT_SOURCE_PATH PUBLIC_SDK_SOURCE_PATH
    REPO steinbergmedia/vst3_public_sdk
    REF ${VERSION}
    SHA512 695f2cf55bbabd57f466d0c6181c2b90314745f91f90c5b27db8617b3fe98c7a5f8675909bf5294371e3e90d10b9145ed8432e5ed16e09faa5b123740f73ba3f
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/public.sdk")
file(RENAME "${PUBLIC_SDK_SOURCE_PATH}" "${SOURCE_PATH}/public.sdk")

# Note that the submodules "vst3_tutorials" and "vstgui4" are standalone repos, which have own release cycles.
# Therefore these are not part of this port

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "plugin-examples"            SMTG_ENABLE_VST3_PLUGIN_EXAMPLES
        "hosting-examples"           SMTG_ENABLE_VST3_HOSTING_EXAMPLES
        "audiounit-wrapper"          SMTG_ENABLE_AUV2_BUILDS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DSMTG_ENABLE_VSTGUI_SUPPORT=OFF
        -DSMTG_CREATE_PLUGIN_LINK=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_build()

if (NOT VCPKG_BUILD_TYPE STREQUAL "release")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/vst3sdk")
endif()
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/vst3sdk")

file(INSTALL "${SOURCE_PATH}/base/source/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vst3sdk/base/source/" FILES_MATCHING PATTERN "*.h")
file(INSTALL "${SOURCE_PATH}/pluginterfaces/base/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vst3sdk/pluginterfaces/base/" FILES_MATCHING PATTERN "*.h")
file(INSTALL "${SOURCE_PATH}/pluginterfaces/gui/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vst3sdk/pluginterfaces/gui/" FILES_MATCHING PATTERN "*.h")
file(INSTALL "${SOURCE_PATH}/pluginterfaces/vst/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vst3sdk/pluginterfaces/vst/" FILES_MATCHING PATTERN "*.h")
file(INSTALL "${SOURCE_PATH}/public.sdk/source/vst/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vst3sdk/public.sdk//source/vst/" FILES_MATCHING PATTERN "*.h")

if (NOT VCPKG_TARGET_IS_WINDOWS)
   file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/Release/moduleinfotool" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
   file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/Release/validator" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
else()
   file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/moduleinfotool${VCPKG_TARGET_EXECUTABLE_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
   file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/validator${VCPKG_TARGET_EXECUTABLE_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

if ("plugin-examples" IN_LIST FEATURES)
   file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/VST3" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()

if ("hosting-examples" IN_LIST FEATURES)
   if (VCPKG_TARGET_IS_OSX)
       file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/Release/editorhost.app" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
   elseif(VCPKG_TARGET_IS_LINUX)
       file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/Release/editorhost" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    else()
       file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/editorhost${VCPKG_TARGET_EXECUTABLE_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
   endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")


if (VCPKG_TARGET_IS_OSX AND NOT "audiounit-wrapper" IN_LIST FEATURES)
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/include/vst3sdk/public.sdk/source/vst/aaxwrapper/resource"
        "${CURRENT_PACKAGES_DIR}/include/vst3sdk/public.sdk/source/vst/auv3wrapper/AUv3WrappermacOS"
        "${CURRENT_PACKAGES_DIR}/include/vst3sdk/public.sdk/source/vst/auwrapper/config"
    )
else()
    file(REMOVE_RECURSE
         # Remove macOS AudioUnit wrapper
        "${CURRENT_PACKAGES_DIR}/include/vst3sdk/public.sdk/source/vst/aaxwrapper/"
        "${CURRENT_PACKAGES_DIR}/include/vst3sdk/public.sdk/source/vst/auv3wrapper/"
        "${CURRENT_PACKAGES_DIR}/include/vst3sdk/public.sdk/source/vst/auwrapper/"
    )
endif()

# Remove other empty directories
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/vst3sdk/public.sdk/source/vst/hosting/test"
    "${CURRENT_PACKAGES_DIR}/include/vst3sdk/public.sdk/source/vst/utility/test"
)
