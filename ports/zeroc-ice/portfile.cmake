vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeroc-ice/ice
    REF "v${VERSION}"
    SHA512 8cf76e8971a2fbe60d1d6a6255d11ac0f7302de0c8e764c5630e12be397094684a4a535eeac8b6a09cd4723060401f61d81152db4711f19ba3124f924afb4d27
    PATCHES
        no-werror.patch # Will be deprecated by https://github.com/zeroc-ice/ice/commit/b144681625a32d3878a6c478dac8c52d5f4c665c
        readline.patch
        rpath-link.patch
)

set(RELEASE_TRIPLET ${TARGET_TRIPLET}-rel)
set(DEBUG_TRIPLET ${TARGET_TRIPLET}-dbg)

set(WIN_DEBUG_BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET}")
set(WIN_RELEASE_BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}")

# install_includes
function(install_includes ORIGINAL_PATH RELATIVE_PATHS)
    foreach(RELATIVE_PATH ${RELATIVE_PATHS})
        file(GLOB HEADER_FILES ${ORIGINAL_PATH}/${RELATIVE_PATH}/*.h)
        if(EXISTS "${ORIGINAL_PATH}/${RELATIVE_PATH}")
            file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${RELATIVE_PATH}")
        endif()
    endforeach()
endfunction()

# install_slices
function(install_slices ORIGINAL_PATH RELATIVE_PATHS)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/ice/slice")
    foreach(RELATIVE_PATH ${RELATIVE_PATHS})
        file(GLOB HEADER_FILES ${ORIGINAL_PATH}/${RELATIVE_PATH}/*.ice)
        if(EXISTS ${ORIGINAL_PATH}/${RELATIVE_PATH})
            file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/share/ice/slice/${RELATIVE_PATH}")
        endif()
    endforeach()
endfunction()

set(components
    IceUtil
    Ice
    Glacier2
    IceBox
    IceGrid
    IceStorm
    IceStormService
    IceDiscovery
    IceLocatorDiscovery
)

set(tools
    icepatch2calc
    icepatch2client
    icepatch2server
    glacier2router
    icebox
    iceboxadmin
    icegridadmin
    icegriddb
    icegridnode
    icegridregistry
    icestormadmin
    icestormdb
    icebridge
)

set(ICE_COMPONENTS_MAKE "${components}")
set(ICE_INCLUDE_SUB_DIRECTORIES "${components}")
set(ICE_PROGRAMS_MAKE "")
set(pkgconfig_packages "expat")
set(msbuild_additional_libs "lmdb.lib")

string(TOLOWER "${components}" ICE_COMPONENTS_MSBUILD)
if("tools" IN_LIST FEATURES)
    list(APPEND ICE_COMPONENTS_MSBUILD ${tools})
    list(APPEND ICE_PROGRAMS_MAKE ${tools})
endif()
list(TRANSFORM ICE_COMPONENTS_MSBUILD PREPEND "/t:C++98\\")

if("cxx11" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\glacier2++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\icessl++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\icebox++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\icegrid++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\icediscovery++11")
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)

    # Fix project files to prevent nuget restore of dependencies and
    # remove hard coded runtime linkage
    include("${CURRENT_PORT_DIR}/prepare_for_build.cmake")
    prepare_for_build("${SOURCE_PATH}")

    vcpkg_list(SET MSBUILD_OPTIONS
        "/p:UseVcpkg=yes"
        "/p:IceBuildingSrc=yes"
        ${ICE_COMPONENTS_MSBUILD}
    )

    # Build Ice
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "cpp/msbuild/ice.${VCPKG_PLATFORM_TOOLSET}.sln"
        TARGET "C++11\\ice++11"
        OPTIONS
            ${MSBUILD_OPTIONS}
        DEPENDENT_PKGCONFIG bzip2 ${pkgconfig_packages}
        ADDITIONAL_LIBS ${msbuild_additional_libs}
        ADDITIONAL_LIBS_RELEASE mcpp.lib
        ADDITIONAL_LIBS_DEBUG mcppd.lib
    )

    install_includes("${WIN_RELEASE_BUILD_DIR}/cpp/include" "${ICE_INCLUDE_SUB_DIRECTORIES}")
    install_includes("${WIN_RELEASE_BUILD_DIR}/cpp/include/generated/cpp11/${TRIPLET_SYSTEM_ARCH}/Release" "${ICE_INCLUDE_SUB_DIRECTORIES}")

    install_slices("${SOURCE_PATH}/slice" "${ICE_INCLUDE_SUB_DIRECTORIES}")

    file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/zeroc.icebuilder.msbuild.dll")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/zeroc.icebuilder.msbuild.dll")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
        # To be removed with 3.7.10, cf. https://github.com/microsoft/vcpkg/issues/33589#issuecomment-1722174600
        # icebox naming is too broken to be fixed here.
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/IceUtil/Config.h" [[ NAME ICE_SO_VERSION ]] [[ NAME ]])
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/IceUtil/Config.h" [[++11D.lib]] [[++11.lib]])
    endif()

    # Don't leave C++98 libs side-by-side with C++11 libs
    file(GLOB libs_cxx11 "${CURRENT_PACKAGES_DIR}/lib/*++11.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/*++11d.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/*++11.lib")
    file(GLOB libs_release "${CURRENT_PACKAGES_DIR}/lib/*.lib")
    list(REMOVE_ITEM libs_release ${libs_cxx11})
    if(libs_release)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/manual-link")
        file(COPY ${libs_release} DESTINATION "${CURRENT_PACKAGES_DIR}/lib/manual-link")
        file(REMOVE ${libs_release})
    endif()
    file(GLOB libs_debug "${CURRENT_PACKAGES_DIR}/debug/lib/*.lib")
    list(REMOVE_ITEM libs_debug ${libs_cxx11})
    if(libs_debug)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")
        file(COPY ${libs_debug} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")
        file(REMOVE ${libs_debug})
    endif()

    vcpkg_clean_msbuild()

else()

    file(COPY "${CMAKE_CURRENT_LIST_DIR}/configure" DESTINATION "${SOURCE_PATH}")

    vcpkg_list(SET options)
    if(VCPKG_TARGET_IS_OSX)
        vcpkg_list(APPEND options build-platform=macosx)
    elseif(VCPKG_TARGET_IS_IOS AND CMAKE_OSX_SYSROOT MATCHES "iphonesimulator")
        vcpkg_list(APPEND options build-platform=iphonesimulator)
    elseif(VCPKG_TARGET_IS_IOS)
        vcpkg_list(APPEND options build-platform=iphoneos)
    else()
        vcpkg_list(APPEND options build-platform=linux)
    endif()
    if(VCPKG_CROSSCOMPILING)
        vcpkg_list(APPEND options
            "slice2cpp_path=${CURRENT_HOST_INSTALLED_DIR}/tools/zeroc-ice/slice2cpp${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        )
    endif()

    list(JOIN ICE_COMPONENTS_MAKE " " components)
    list(JOIN ICE_PROGRAMS_MAKE " " programs)
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        COPY_SOURCE
        OPTIONS
            ${options}
        OPTIONS_RELEASE
            "COMPONENTS=${components} ${programs}"
            OPTIMIZE=yes
        OPTIONS_DEBUG
            "COMPONENTS=${components}"
            OPTIMIZE=no
    )
    vcpkg_install_make(
        MAKEFILE "Makefile.vcpkg"
    )

    if(icebox IN_LIST ICE_PROGRAMS_MAKE)
        list(APPEND ICE_PROGRAMS_MAKE icebox++11)
    endif()
    if(ICE_PROGRAMS_MAKE)
        vcpkg_copy_tools(TOOL_NAMES ${ICE_PROGRAMS_MAKE} AUTO_CLEAN)
    endif()
    if(NOT VCPKG_CROSSCOMPILING)
        vcpkg_copy_tools(TOOL_NAMES slice2cpp SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/cpp/bin")
    endif()

    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/include"
        "${CURRENT_PACKAGES_DIR}/debug/share"
    )
endif()

# Remove unnecessary static libraries.
file(GLOB PDLIBS "${CURRENT_PACKAGES_DIR}/debug/lib/*")
file(GLOB PRLIBS "${CURRENT_PACKAGES_DIR}/lib/*")
list(FILTER PDLIBS INCLUDE REGEX ".*(([Ii]ce[Uu]til|[Ss]lice)d?\.([a-z]+))$")
list(FILTER PRLIBS INCLUDE REGEX ".*(([Ii]ce[Uu]til|[Ss]lice)d?\.([a-z]+))$")
if(NOT "${PDLIBS}${PRLIBS}" STREQUAL "")
    file(REMOVE ${PDLIBS} ${PRLIBS})
endif()

file(INSTALL "${CURRENT_PORT_DIR}/vcpkg-ci-IceConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/vcpkg-ci/cmake-user")
file(INSTALL "${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/ice")

file(READ "${SOURCE_PATH}/README.md" readme)
string(REGEX REPLACE "^.*## Copyright and License(.*)##.*\$" "\\1" comment "${readme}")
vcpkg_install_copyright(
    COMMENT "${comment}"
    FILE_LIST "${SOURCE_PATH}/ICE_LICENSE" "${SOURCE_PATH}/LICENSE"
)
