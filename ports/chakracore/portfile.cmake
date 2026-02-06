if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/ChakraCore
    REF 792ee7660cbb14f1b3f9f77a6f919aeed4ec1fc2
    SHA512 6845a8d3aae758ab7115b01cd14a607c56662dc0361076724697ee847412ac3291fc2148f4610ac55d58d09d832620029fcfb21bdb73f17f143e6647612e48c7
    HEAD_REF master
)

set(BUILDTREE_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(additional_options NO_TOOLCHAIN_PROPS) # don't know how to fix the linker error about __guard_check_icall_thunk 
    endif()
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
        set(PLATFORM_ARG PLATFORM x86) # it's x86, not Win32 in sln file
    endif()

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH Build/Chakra.Core.sln
        OPTIONS
            "/p:CustomBeforeMicrosoftCommonTargets=${CMAKE_CURRENT_LIST_DIR}/no-warning-as-error.props"
        ${PLATFORM_ARG}
        ${additional_options}
    )
    file(GLOB_RECURSE LIB_FILES "${CURRENT_PACKAGES_DIR}/lib/*.lib")
    file(GLOB_RECURSE DEBUG_LIB_FILES "${CURRENT_PACKAGES_DIR}/debug/lib/*.lib")
    foreach(file ${LIB_FILES} ${DEBUG_LIB_FILES})
        if(NOT file MATCHES "ChakraCore.lib")
            file(REMOVE ${file})
        endif()
    endforeach()
else()
    if(VCPKG_TARGET_IS_OSX)
        list(APPEND FEATURE_OPTIONS -DDISABLE_JIT=ON)
        message(WARNING "${PORT} requires Clang from the system package manager")
    endif()
    
    if (VCPKG_TARGET_IS_LINUX)
        message(WARNING "${PORT} requires Clang from the system package manager, this can be installed on Ubuntu systems via sudo apt install clang")
        list(APPEND FEATURE_OPTIONS -DICU_INCLUDE_PATH=${CURRENT_INSTALLED_DIR}/include)
    endif()
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND FEATURE_OPTIONS -DSTATIC_LIBRARY=ON)
    else()
        list(APPEND FEATURE_OPTIONS -DSTATIC_LIBRARY=OFF)
    endif()
    
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS ${FEATURE_OPTIONS}
    )
    
    vcpkg_cmake_build()
    
    # Manual installation since ChakraCore doesn't have install target
    file(GLOB_RECURSE RELEASE_LIBS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/libChakraCore*")
    foreach(lib ${RELEASE_LIBS})
        get_filename_component(lib_name ${lib} NAME)
        if(lib_name MATCHES "\\.(dylib|so)$")
            file(INSTALL ${lib} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        elseif(lib_name MATCHES "\\.a$")
            file(INSTALL ${lib} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        endif()
    endforeach()
    
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(GLOB_RECURSE DEBUG_LIBS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/libChakraCore*")
        foreach(lib ${DEBUG_LIBS})
            get_filename_component(lib_name ${lib} NAME)
            if(lib_name MATCHES "\\.(dylib|so)$")
                file(INSTALL ${lib} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
            elseif(lib_name MATCHES "\\.a$")
                file(INSTALL ${lib} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
            endif()
        endforeach()
    endif()
    
    # Copy ch binary if it exists
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(CH_BINARY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/ch/ch")
        if(EXISTS "${CH_BINARY}")
            file(INSTALL "${CH_BINARY}"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
                 FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
        endif()
    endif()
endif()

file(INSTALL
    "${SOURCE_PATH}/lib/Jsrt/ChakraCore.h"
    "${SOURCE_PATH}/lib/Jsrt/ChakraCommon.h"
    "${SOURCE_PATH}/lib/Jsrt/ChakraDebug.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(INSTALL
        "${BUILDTREE_PATH}-rel/lib/Jsrt/ChakraCommonWindows.h"
        "${BUILDTREE_PATH}-rel/lib/Jsrt/ChakraCoreWindows.h"
        DESTINATION "${CURRENT_PACKAGES_DIR}/include"
    )
else()
    # vcpkg_cmake handles file fixup automatically
endif()

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-chakracore-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}"
)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE.txt"
)
