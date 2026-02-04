vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO steinbergmedia/vst3sdk
    REF ${VERSION}
    SHA512 7dd3483420abd79ee6dcb9db16663fb4e4d448e4243f8b905600ca871593701e66da97badaf3d723aafa1321cf72cbc013066ea8177a9497ab740fd98171efa3
    HEAD_REF master
)

#Submodules
vcpkg_from_github(
    OUT_SOURCE_PATH BASE_SOURCE_PATH
    REPO steinbergmedia/vst3_base
    REF ${VERSION}
    SHA512 be67019cd63f9f37fd541806f29e5e95899fba29153515048080e7d08aa397061d253d9f3de54d49303c99a36d197fd53fe9b54074e54092332020e4d4c845c8
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/base")
file(RENAME "${BASE_SOURCE_PATH}" "${SOURCE_PATH}/base")

vcpkg_from_github(
    OUT_SOURCE_PATH CMAKE_SOURCE_PATH
    REPO steinbergmedia/vst3_cmake
    REF ${VERSION}
    SHA512 b138ac696eb8f4f4ac2b28708972fabec576b7958c5ce74a94068c3a4ec3b2648ca992b4646529eff076efbc7c66bb335d9d883ce245df0e949bad76eafac7ac
    HEAD_REF master
    PATCHES
        fix-x86-architecture.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake")
file(RENAME "${CMAKE_SOURCE_PATH}" "${SOURCE_PATH}/cmake")

vcpkg_from_github(
    OUT_SOURCE_PATH DOC_SOURCE_PATH
    REPO steinbergmedia/vst3_doc
    REF ${VERSION}
    SHA512 d211bd475fa6f3fd1e0b12bfc592ceff6867d1e62bc7e7e816b88f12fa7c3eb7357b08d753eadd53c409135518e944a836b628e2af78ca6271322636e967f21f
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/doc")
file(RENAME "${DOC_SOURCE_PATH}" "${SOURCE_PATH}/doc")

vcpkg_from_github(
    OUT_SOURCE_PATH PLUGININTERFACES_SOURCE_PATH
    REPO steinbergmedia/vst3_pluginterfaces
    REF ${VERSION}
    SHA512 199a928e834f9ec50247305bd759a14135c7e4c88767867feae402f37edc38cc148b06e3f5b4d7d18812a1fb885eb09c6619ffc80bb2b5d951b77951b660d476
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/pluginterfaces")
file(RENAME "${PLUGININTERFACES_SOURCE_PATH}" "${SOURCE_PATH}/pluginterfaces")

vcpkg_from_github(
    OUT_SOURCE_PATH PUBLIC_SDK_SOURCE_PATH
    REPO steinbergmedia/vst3_public_sdk
    REF ${VERSION}
    SHA512 248b62ab7fa26e81aa306c38aed657c1ca738caac53d3aa9d1c2076997bad2ccb21abce1f77d6adb4fe7f53c6e51e2757ef2ce4a72db1f68d9c286947efd20c0
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
