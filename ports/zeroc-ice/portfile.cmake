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
    foreach(RELATIVE_PATH ${RELATIVE_PATHS})
        file(GLOB HEADER_FILES ${ORIGINAL_PATH}/${RELATIVE_PATH}/*.ice)
        if(EXISTS ${ORIGINAL_PATH}/${RELATIVE_PATH})
            file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/share/ice/slice/${RELATIVE_PATH}")
        endif()
    endforeach()
endfunction()

vcpkg_list(SET ICE_INCLUDE_SUB_DIRECTORIES
  "Glacier2"
  "Ice"
  "IceUtil"
  "IceBT"
  "IceBox"
  "IceBT"
  "IceDiscovery"
  "IceGrid"
  "IceIAP"
  "IceLocatorDiscovery"
  "IcePatch2"
  "IceSSL"
  "IceStorm"
)

set(ICE_COMPONENTS_MSBUILD "")
set(ICE_COMPONENTS_MAKE "Ice")
set(pkgconfig_packages "")

# IceSSL
if("icessl" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\icessl++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "IceSSL")
endif()

# Glacier2
if("glacier2lib" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\glacier2++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "Glacier2")
endif()

# Glacier2Router
if("glacier2router" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\glacier2router")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\glacier2cryptpermissionsverifier")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "glacier2router")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "Glacier2CryptPermissionsVerifier")
endif()

# IceBox
if("iceboxlib" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\iceboxlib++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "IceBox")
endif()

# IceBox
if("iceboxtools" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\icebox++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\iceboxadmin")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "icebox")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "iceboxadmin")
endif()

# IceGrid
if("icegridlib" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\icegrid++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "IceGrid")
endif()

# IceGrid tools
if("icegridtools" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icegridadmin")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icegridregistry")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icegridnode")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "icegridadmin")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "icegridregistry")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "icegridnode")
    list(APPEND pkgconfig_packages expat)
endif()

# IceStorm
if("icestormlib" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\icestorm++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "IceStorm")
endif()

# IceStormAdmin
if("icestormtools" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icestormadmin")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icestormservice")
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icestormdb")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "icestormadmin")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "IceStormService")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "icestormdb")
endif()

# IceBridge executable
if("icebridge" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++98\\icebridge")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "icebridge")
endif()

# IceDiscovery
if("icediscovery" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_COMPONENTS_MSBUILD "/t:C++11\\icediscovery++11")
    vcpkg_list(APPEND ICE_COMPONENTS_MAKE "IceDiscovery")
endif()

# IceLocatorDiscovery
if("icelocatordiscovery" IN_LIST FEATURES)
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
        ADDITIONAL_LIBS lmdb.lib
        ADDITIONAL_LIBS_RELEASE mcpp.lib ${libs_rel}
        ADDITIONAL_LIBS_DEBUG mcppd.lib ${libs_dbg}
    )

    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/zeroc.icebuilder.msbuild.dll")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/zeroc.icebuilder.msbuild.dll")
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/zeroc.icebuilder.msbuild.dll")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/zeroc.icebuilder.msbuild.dll")
    endif()

    install_includes("${WIN_RELEASE_BUILD_DIR}/cpp/include" "${ICE_INCLUDE_SUB_DIRECTORIES}")
    install_includes("${WIN_RELEASE_BUILD_DIR}/cpp/include/generated/cpp11/${TRIPLET_SYSTEM_ARCH}/Release" "${ICE_INCLUDE_SUB_DIRECTORIES}")

    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/ice/slice")
    install_slices("${SOURCE_PATH}/slice" "${ICE_INCLUDE_SUB_DIRECTORIES}")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()

    vcpkg_clean_msbuild()

else()

    file(COPY "${CMAKE_CURRENT_LIST_DIR}/configure" DESTINATION "${SOURCE_PATH}")

    vcpkg_list(SET options)
    if(VCPKG_CROSSCOMPILING)
        vcpkg_list(APPEND options
            "slice2cpp_path=${CURRENT_HOST_INSTALLED_DIR}/tools/zeroc-ice/slice2cpp${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        )
    endif()

    list(JOIN ICE_COMPONENTS_MAKE " " components)
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        COPY_SOURCE
        OPTIONS
            "COMPONENTS=${components}"
            ${options}
        OPTIONS_RELEASE
            OPTIMIZE=yes
        OPTIONS_DEBUG
            OPTIMIZE=no
    )
    vcpkg_install_make(
        MAKEFILE "Makefile.vcpkg"
    )

    string(REPLACE ";icebox;" ";icebox;icebox++11;" tools ";${ICE_COMPONENTS_MAKE};")
    list(FILTER tools INCLUDE REGEX "^ice|^glacier")
    if(tools)
        vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
