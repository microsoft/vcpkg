vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeroc-ice/ice
    REF "v${VERSION}"
    SHA512 07d7c439fbe1f69d808d05a11f32e09cdd8d4df2a93b6f253496304e0a521d417212ae688e316b4450dae406b59d1a460025b51ecd0614c69e48d86c0a6f81c5
    PATCHES
        no-werror.patch
        readline.patch
        rpath-link.patch
        fix-missing-functional.patch
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

set(ICE_INCLUDE_SUB_DIRECTORIES "Ice" "IceUtil")
set(ICE_COMPONENTS_MSBUILD "/t:C++98\\ice")
set(ICE_COMPONENTS_MAKE "IceUtil Ice")
set(ICE_PROGRAMS_MAKE "")
set(pkgconfig_packages "")
set(msbuild_additional_libs "")

if("icepatch2" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_INCLUDE_SUB_DIRECTORIES "IcePatch2")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icepatch2")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "IcePatch2")
endif()

if("icepatch2tools" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icepatch2server")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icepatch2client")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icepatch2calc")
    vcpkg_list(APPEND ICE_PROGRAMS_MAKE "icepatch2server")
    vcpkg_list(APPEND ICE_PROGRAMS_MAKE "icepatch2client")
    vcpkg_list(APPEND ICE_PROGRAMS_MAKE "icepatch2calc")
endif()

if("icessl" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_INCLUDE_SUB_DIRECTORIES "IceSSL")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icessl")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\icessl++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "IceSSL")
endif()

if("glacier2" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_INCLUDE_SUB_DIRECTORIES "Glacier2")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\glacier2")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\glacier2cryptpermissionsverifier")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\glacier2++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "Glacier2")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "Glacier2CryptPermissionsVerifier")
endif()

if("glacier2router" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\glacier2router")
    vcpkg_list(APPEND ICE_PROGRAMS_MAKE "glacier2router")
endif()

if("icebox" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_INCLUDE_SUB_DIRECTORIES "IceBox")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\iceboxlib")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\iceboxlib++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "IceBox")
endif()

if("iceboxtools" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icebox")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\iceboxadmin")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\icebox++11")
    vcpkg_list(APPEND ICE_PROGRAMS_MAKE "icebox")
    vcpkg_list(APPEND ICE_PROGRAMS_MAKE "iceboxadmin")
endif()

if("icegrid" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_INCLUDE_SUB_DIRECTORIES "IceGrid")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icegrid")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\icegrid++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "IceGrid")
    vcpkg_list(APPEND msbuild_additional_libs "lmdb.lib")

endif()

if("icegridtools" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icegridadmin")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icegriddb")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icegridnode")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icegridregistry")
    vcpkg_list(APPEND ICE_PROGRAMS_MAKE "icegridadmin")
    vcpkg_list(APPEND ICE_PROGRAMS_MAKE "icegriddb")
    vcpkg_list(APPEND ICE_PROGRAMS_MAKE "icegridnode")
    vcpkg_list(APPEND ICE_PROGRAMS_MAKE "icegridregistry")
    list(APPEND pkgconfig_packages expat)
endif()

if("icestorm" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_INCLUDE_SUB_DIRECTORIES "IceStorm")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icestorm")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icestormservice")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\icestorm++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "IceStorm")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "IceStormService")
endif()

if("icestormtools" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icestormadmin")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icestormdb")
    vcpkg_list(APPEND ICE_PROGRAMS_MAKE "icestormadmin")
    vcpkg_list(APPEND ICE_PROGRAMS_MAKE "icestormdb")
endif()

if("icebridge" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icebridge")
    vcpkg_list(APPEND ICE_PROGRAMS_MAKE "icebridge")
endif()

if("icediscovery" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_INCLUDE_SUB_DIRECTORIES "IceDiscovery")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icediscovery")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\icediscovery++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "IceDiscovery")
endif()

if("icelocatordiscovery" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_INCLUDE_SUB_DIRECTORIES "IceLocatorDiscovery")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\icelocatordiscovery++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "IceLocatorDiscovery")
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
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/IceUtil/Config.h" " NAME ICE_SO_VERSION " " NAME ")
    endif()

    # Don't leave C++98 libs side-by-side with C++11 libs
    file(GLOB libs_release "${CURRENT_PACKAGES_DIR}/lib/*37.lib")
    if(libs_release)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/manual-link")
        file(COPY ${libs_release} DESTINATION "${CURRENT_PACKAGES_DIR}/lib/manual-link")
        file(REMOVE ${libs_release})
    endif()
    file(GLOB libs_debug "${CURRENT_PACKAGES_DIR}/debug/lib/*37d.lib")
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
