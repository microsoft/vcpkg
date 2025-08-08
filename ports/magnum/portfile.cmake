vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mosra/magnum
    REF v2020.06
    SHA512 65b0c8a4520d1d282420c30ecd7c8525525d4dbb6e562e1e2e93d110f4eb686af43f098bf02460727fab1e1f9446dd00a99051e150c05ea40b1486a44fea1042
    HEAD_REF master
    PATCHES
        002-sdl-includes.patch
        003-fix-FindGLFW.patch
        004-fix-FindOpenAL.patch
        005-fix-find-sdl2.patch
        006-fix-build.patch # From https://github.com/mosra/magnum/issues/642#issuecomment-2217261862
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_PLUGINS_STATIC)

set(ALL_SUPPORTED_FEATURES ${ALL_FEATURES})

# Head only features
if(NOT VCPKG_USE_HEAD_VERSION)
    foreach(_feature anyshaderconverter shadertools shaderconverter vk-info)
        if("${_feature}" IN_LIST FEATURES)
            message(FATAL_ERROR "Features anyshaderconverter, shadertools, shaderconverter and vk-info are not avaliable when building non-head version.")
        endif()
    endforeach()
    list(REMOVE_ITEM ALL_SUPPORTED_FEATURES anyshaderconverter shadertools shaderconverter vk-info)
endif()

set(_COMPONENTS "")
# Generate cmake parameters from feature names
foreach(_feature IN LISTS ALL_SUPPORTED_FEATURES)
    # Uppercase the feature name and replace "-" with "_"
    string(TOUPPER "${_feature}" _FEATURE)
    string(REPLACE "-" "_" _FEATURE "${_FEATURE}")

    # Final feature is empty, ignore it
    if(_feature)
        list(APPEND _COMPONENTS ${_feature} WITH_${_FEATURE})
    endif()
endforeach()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES ${_COMPONENTS})

if(VCPKG_CROSSCOMPILING)
    set(CORRADE_RC_EXECUTABLE "-DCORRADE_RC_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/corrade/corrade-rc${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${CORRADE_RC_EXECUTABLE}
        -DBUILD_STATIC=${BUILD_STATIC}
        -DBUILD_PLUGINS_STATIC=${BUILD_PLUGINS_STATIC}
        -DMAGNUM_PLUGINS_DEBUG_DIR=${CURRENT_INSTALLED_DIR}/debug/bin/magnum-d
        -DMAGNUM_PLUGINS_RELEASE_DIR=${CURRENT_INSTALLED_DIR}/bin/magnum
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

# Copy tools into vcpkg's tools directory
set(_TOOL_EXEC_NAMES "")
set(_TOOLS
    al-info
    distancefieldconverter
    fontconverter
    gl-info
    imageconverter
    sceneconverter)
if(VCPKG_USE_HEAD_VERSION)
    list(APPEND _TOOLS shaderconverter vk-info)
endif()
foreach(_tool IN LISTS _TOOLS)
    if("${_tool}" IN_LIST FEATURES)
        list(APPEND _TOOL_EXEC_NAMES magnum-${_tool})
    endif()
endforeach()
message(STATUS ${_TOOL_EXEC_NAMES})
if(_TOOL_EXEC_NAMES)
    vcpkg_copy_tools(TOOL_NAMES ${_TOOL_EXEC_NAMES} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Special handling for plugins.
#
# For static plugins, in order to make MSBuild auto-linking magic work, where 
# the linker implicitly takes everything from the root lib/ folder, the 
# static libraries have to be moved out of lib/magnum/blah/ directly to lib/.
# Possibly would be enough to do this just for Windows, doing it also on other
# platforms for consistency.
#
# For dynamic plugins, auto-linking is not desirable as those are meant to be 
# loaded dynamically at runtime instead. In order to prevent that, on Windows 
# the *.lib files corresponding to the plugin *.dlls are removed. However, we 
# cannot remove the *.lib files entirely here, as plugins from magnum-plugins 
# are linked to them on Windows (e.g. AssimpImporter depends on 
# AnyImageImporter). Thus the Any* plugin lib files are kept, but also not 
# moved to the root lib/ folder, to prevent autolinking. A consequence of the 
# *.lib file removal is that downstream projects can't implement Magnum plugins
# that would depend on (and thus link to) these, but that's considered a very 
# rare use case and so it's fine.
#
# See https://github.com/microsoft/vcpkg/pull/1235#issuecomment-308805989 for 
# futher info.
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
    # move plugin libs to conventional place
    file(GLOB_RECURSE LIB_TO_MOVE "${CURRENT_PACKAGES_DIR}/lib/magnum/*")
    file(COPY ${LIB_TO_MOVE} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/magnum")

    file(GLOB_RECURSE LIB_TO_MOVE_DBG "${CURRENT_PACKAGES_DIR}/debug/lib/magnum/*")
    file(COPY ${LIB_TO_MOVE_DBG} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/magnum")
else()
    if(VCPKG_TARGET_IS_WINDOWS)
        file(GLOB_RECURSE LIB_TO_REMOVE "${CURRENT_PACKAGES_DIR}/lib/magnum/*")
        file(GLOB_RECURSE LIB_TO_KEEP "${CURRENT_PACKAGES_DIR}/lib/magnum/*Any*")
        if(LIB_TO_KEEP)
            list(REMOVE_ITEM LIB_TO_REMOVE ${LIB_TO_KEEP})
        endif()
        if(LIB_TO_REMOVE)
            file(REMOVE ${LIB_TO_REMOVE})
        endif()

        if (VCPKG_TARGET_IS_UWP)
            set(debug_dir "magnum")
        else()
            set(debug_dir "magnum-d")
        endif()

        file(GLOB_RECURSE LIB_TO_REMOVE_DBG "${CURRENT_PACKAGES_DIR}/debug/lib/${debug_dir}/*")
        file(GLOB_RECURSE LIB_TO_KEEP_DBG "${CURRENT_PACKAGES_DIR}/debug/lib/${debug_dir}/*Any*")
        if(LIB_TO_KEEP_DBG)
            list(REMOVE_ITEM LIB_TO_REMOVE_DBG ${LIB_TO_KEEP_DBG})
        endif()
        if(LIB_TO_REMOVE_DBG)
            file(REMOVE ${LIB_TO_REMOVE_DBG})
        endif()
        
        # remove maybe empty dirs
        foreach(subdir "fonts" "importers" "fontconverters" "imageconverters" "audioimporters")
            file(GLOB maybe_empty "${CURRENT_PACKAGES_DIR}/lib/magnum/${subdir}/*")
            if(maybe_empty STREQUAL "")
                file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/magnum/${subdir}")
                file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/${debug_dir}/${subdir}")
            endif()
        endforeach()

        file(GLOB maybe_empty "${CURRENT_PACKAGES_DIR}/lib/magnum/*")
        if(maybe_empty STREQUAL "")
            file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/magnum")
            file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/${debug_dir}")
        endif()
        
    endif()

    file(COPY "${CMAKE_CURRENT_LIST_DIR}/magnumdeploy.ps1" DESTINATION "${CURRENT_PACKAGES_DIR}/bin/magnum")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/magnumdeploy.ps1" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin/${debug_dir}")
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
