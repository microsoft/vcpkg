vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO steinbergmedia/vst3sdk
    REF ${VERSION}
    SHA512 f55c03aca2fb994e48e6e8ff0de5d58e512a0a67556cf6bd86c0f9ae429732fca3408e41692b9302a88f7db5be11d3864558762868d47e2def0175b87b9e0937
    HEAD_REF master
)

#Submodules
vcpkg_from_github(
    OUT_SOURCE_PATH BASE_SOURCE_PATH
    REPO steinbergmedia/vst3_base
    REF ${VERSION}
    SHA512 12de902576171233e382e0544cdfc8a651d6f640038569eb760ae1d3fe0fd43360952d1dcac209dd4224a9d6a669ce2ff41f9ba5279c35b8cf9622acd74d0857
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/base")
file(RENAME "${BASE_SOURCE_PATH}" "${SOURCE_PATH}/base")

vcpkg_from_github(
    OUT_SOURCE_PATH CMAKE_SOURCE_PATH
    REPO steinbergmedia/vst3_cmake
    REF ${VERSION}
    SHA512 1e81e4a191220bd2750148338cdeedc119e8c20a221b56613ffa4d2491a1a27bd400fb6d0bb2a265ce3d280a1bf85dd18c56a5abacfebc7c268db70112edf8a3
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake")
file(RENAME "${CMAKE_SOURCE_PATH}" "${SOURCE_PATH}/cmake")

vcpkg_from_github(
    OUT_SOURCE_PATH DOC_SOURCE_PATH
    REPO steinbergmedia/vst3_doc
    REF ${VERSION}
    SHA512 7afdc9827bbe5a3f7c7d9ae4eb8663aa39aba2de2b60db076a78b977864f63858c6d3e8f5b66a1d90e8162509f7218cdac175778d3866e6b1102d5d85f1c7d54
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/doc")
file(RENAME "${DOC_SOURCE_PATH}" "${SOURCE_PATH}/doc")

vcpkg_from_github(
    OUT_SOURCE_PATH PLUGININTERFACES_SOURCE_PATH
    REPO steinbergmedia/vst3_pluginterfaces
    REF ${VERSION}
    SHA512 fd2218c3e949133dd51b4834c6680131a520587c4449fa50f9b86cb3de3c3091e34ff15e21ba0e995f078b43890e7aa239a1beeb753eba1ce6822f9b44875b3c
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/pluginterfaces")
file(RENAME "${PLUGININTERFACES_SOURCE_PATH}" "${SOURCE_PATH}/pluginterfaces")

vcpkg_from_github(
    OUT_SOURCE_PATH PUBLIC_SDK_SOURCE_PATH
    REPO steinbergmedia/vst3_public_sdk
    REF ${VERSION}
    SHA512 d902a7b3f0d925e95d343df2378f4b701309d6460c970dfa064f0c2f24b0b4ca700ea15b3a4b63b3fc5f38cc5d6b2d55e5a3946fd10dd45960a86f948c868552
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
