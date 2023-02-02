
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeroc-ice/ice
    REF v3.7.7
    SHA512 73c3a2bb14c9e145383e4026206edd3e03b29c60a33af628611bfdab71d69a3aed108ce4e6cbfd67eb852560110e3495b4bd238c8cdf0de9d1f8e2f1088513ee
    PATCHES md5i_fix.patch slice2swift.patch mcppd_fix.patch
)

set(RELEASE_TRIPLET ${TARGET_TRIPLET}-rel)
set(DEBUG_TRIPLET ${TARGET_TRIPLET}-dbg)

get_filename_component(SOURCE_PATH_SUFFIX ${SOURCE_PATH} NAME)
set(UNIX_BUILD_DIR "${SOURCE_PATH}")
set(WIN_DEBUG_BUILD_DIR ${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET}/${SOURCE_PATH_SUFFIX})
set(WIN_RELEASE_BUILD_DIR ${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET}/${SOURCE_PATH_SUFFIX})

# install_includes
function(install_includes ORIGINAL_PATH RELATIVE_PATHS)
    foreach(RELATIVE_PATH ${RELATIVE_PATHS})
        file(GLOB HEADER_FILES ${ORIGINAL_PATH}/${RELATIVE_PATH}/*.h)
        if(EXISTS ${ORIGINAL_PATH}/${RELATIVE_PATH})
            file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${RELATIVE_PATH})
        endif()
    endforeach()
endfunction()

# install_slices
function(install_slices ORIGINAL_PATH RELATIVE_PATHS)
    foreach(RELATIVE_PATH ${RELATIVE_PATHS})
        file(GLOB HEADER_FILES ${ORIGINAL_PATH}/${RELATIVE_PATH}/*.ice)
        if(EXISTS ${ORIGINAL_PATH}/${RELATIVE_PATH})
            file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/ice/slice/${RELATIVE_PATH})
        endif()
    endforeach()
endfunction()

vcpkg_list(SET ICE_INCLUDE_SUB_DIRECTORIES
  "Glacier2"
  "Ice"
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

set(ICE_OPTIONAL_COMPONENTS_MSBUILD "")
set(ICE_OPTIONAL_COMPONENTS_MAKE "Ice") # Intentional!

# IceSSL
if("icessl" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++11\\icessl++11")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "IceSSL")
endif()

# Glacier2
if("glacier2lib" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++11\\glacier2++11")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "Glacier2")
endif()

# Glacier2Router
if("glacier2router" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++98\\glacier2router")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++98\\glacier2cryptpermissionsverifier")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "glacier2router")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "Glacier2CryptPermissionsVerifier")
endif()

# IceBox
if("iceboxlib" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++11\\iceboxlib++11")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "IceBox")
endif()

# IceBox
if("iceboxtools" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++11\\icebox++11")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++98\\iceboxadmin")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "icebox")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "iceboxadmin")
endif()

# IceGrid
if("icegridlib" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++11\\icegrid++11")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "IceGrid")
endif()

# IceGrid tools
if("icegridtools" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++98\\icegridadmin")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++98\\icegridregistry")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++98\\icegridnode")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "icegridnode")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "icegridregistry")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "icegridnode")
endif()

# IceStorm
if("icestormlib" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++11\\icestorm++11")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "IceStorm")
endif()

# IceStormAdmin
if("icestormtools" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++98\\icestormadmin")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++98\\icestormservice")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++98\\icestormdb")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "icestormadmin")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "IceStormService")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "icestormdb")
endif()

# IceBridge executable
if("icebridge" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++98\\icebridge")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "icebridge")
endif()

# IceDiscovery
if("icediscovery" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MSBUILD "/t:C++11\\icediscovery++11")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS_MAKE "IceDiscovery")
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    # Clean up for the first round (important for install --editable)
    vcpkg_execute_build_process(
        COMMAND make distclean
        WORKING_DIRECTORY ${SOURCE_PATH}/cpp
        LOGNAME make-clean-${TARGET_TRIPLET}
    )

    if(EXISTS "${UNIX_BUILD_DIR}/cpp/lib")
        file(REMOVE_RECURSE "${UNIX_BUILD_DIR}/cpp/lib")
    endif()
    if(EXISTS "${UNIX_BUILD_DIR}/cpp/lib64")
        file(REMOVE_RECURSE "${UNIX_BUILD_DIR}/cpp/lib64")
    endif()
    file(REMOVE_RECURSE "${UNIX_BUILD_DIR}/cpp/bin")

    # Setting these as environment variables, as .d files aren't generated
    # the first time passing them as arguments to make.
    set(ENV{MCPP_HOME} ${CURRENT_INSTALLED_DIR})
    set(ENV{EXPAT_HOME} ${CURRENT_INSTALLED_DIR})
    set(ENV{BZ2_HOME} ${CURRENT_INSTALLED_DIR})
    set(ENV{LMDB_HOME} ${CURRENT_INSTALLED_DIR})
    set(ENV{CPPFLAGS} "-I${CURRENT_INSTALLED_DIR}/include")
    set(ENV{LDFLAGS} "-L${CURRENT_INSTALLED_DIR}/debug/lib")

    set(ICE_BUILD_CONFIG "shared cpp11-shared")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(ICE_BUILD_CONFIG "static cpp11-static")
    endif()
    if(NOT VCPKG_BUILD_TYPE)
    message(STATUS "Building ${TARGET_TRIPLET}-dbg")
        vcpkg_execute_build_process(
            COMMAND make
                V=1
                "prefix=${CURRENT_PACKAGES_DIR}/debug"
                linux_id=vcpkg
                "CONFIGS=${ICE_BUILD_CONFIG}"
                USR_DIR_INSTALL=yes
                OPTIMIZE=no
                ${ICE_OPTIONAL_COMPONENTS_MAKE}
                "-j${VCPKG_CONCURRENCY}"
            WORKING_DIRECTORY ${SOURCE_PATH}/cpp
            LOGNAME make-${TARGET_TRIPLET}-dbg
        )

        # Install debug libraries to packages directory
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
        if(EXISTS "${UNIX_BUILD_DIR}/cpp/lib64")
            file(GLOB ICE_DEBUG_LIBRARIES "${UNIX_BUILD_DIR}/cpp/lib64/*")
        else()
            file(GLOB ICE_DEBUG_LIBRARIES "${UNIX_BUILD_DIR}/cpp/lib/*")
        endif()
        file(COPY ${ICE_DEBUG_LIBRARIES} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

        # Clean up for the next round
        vcpkg_execute_build_process(
            COMMAND make distclean
            WORKING_DIRECTORY ${SOURCE_PATH}/cpp
            LOGNAME make-clean-${TARGET_TRIPLET}
        )

        if(EXISTS "${UNIX_BUILD_DIR}/cpp/lib")
            file(REMOVE_RECURSE "${UNIX_BUILD_DIR}/cpp/lib")
        endif()
        if(EXISTS "${UNIX_BUILD_DIR}/cpp/lib64")
            file(REMOVE_RECURSE "${UNIX_BUILD_DIR}/cpp/lib64")
        endif()
        file(REMOVE_RECURSE "${UNIX_BUILD_DIR}/cpp/bin")
    endif() # TODO: get-cmake-vars!
    # Release build
    set(ENV{LDFLAGS} "-L${CURRENT_INSTALLED_DIR}/lib")
    message(STATUS "Building ${TARGET_TRIPLET}-rel")
    vcpkg_execute_build_process(
        COMMAND make
            V=1
            "prefix=${CURRENT_PACKAGES_DIR}"
            linux_id=vcpkg
            "CONFIGS=${ICE_BUILD_CONFIG}"
            USR_DIR_INSTALL=yes
            OPTIMIZE=yes
            ${ICE_OPTIONAL_COMPONENTS_MAKE}
            "-j${VCPKG_CONCURRENCY}"
        WORKING_DIRECTORY ${SOURCE_PATH}/cpp
        LOGNAME make-${TARGET_TRIPLET}-rel
    )

    # Install release libraries and other files to packages directory
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/ice/slice")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

    install_includes("${UNIX_BUILD_DIR}/cpp/include" "${ICE_INCLUDE_SUB_DIRECTORIES}")
    install_includes("${UNIX_BUILD_DIR}/cpp/include/generated" "${ICE_INCLUDE_SUB_DIRECTORIES}")
    install_slices("${SOURCE_PATH}/slice" "${ICE_INCLUDE_SUB_DIRECTORIES}")
    if(EXISTS "${UNIX_BUILD_DIR}/cpp/lib64")
        file(GLOB ICE_RELEASE_LIBRARIES "${UNIX_BUILD_DIR}/cpp/lib64/*")
    else()
        file(GLOB ICE_RELEASE_LIBRARIES "${UNIX_BUILD_DIR}/cpp/lib/*")
    endif()
    file(COPY ${ICE_RELEASE_LIBRARIES} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(GLOB ICE_RELEASE_EXECUTABLES "${UNIX_BUILD_DIR}/cpp/bin/*")
    file(COPY ${ICE_RELEASE_EXECUTABLES} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

    # Clean up
    vcpkg_execute_build_process(
        COMMAND make distclean
        WORKING_DIRECTORY ${SOURCE_PATH}/cpp
        LOGNAME make-clean-after-build-${TARGET_TRIPLET}
    )

    if(EXISTS "${UNIX_BUILD_DIR}/cpp/lib")
        file(REMOVE_RECURSE "${UNIX_BUILD_DIR}/cpp/lib")
    endif()
    if(EXISTS "${UNIX_BUILD_DIR}/cpp/lib64")
        file(REMOVE_RECURSE "${UNIX_BUILD_DIR}/cpp/lib64")
    endif()
    file(REMOVE_RECURSE "${UNIX_BUILD_DIR}/cpp/bin")

else() # VCPKG_TARGET_IS_WINDOWS

    # Fix project files to prevent nuget restore of dependencies and
    # remove hard coded runtime linkage
    include("${CURRENT_PORT_DIR}/prepare_for_build.cmake")
    prepare_for_build("${SOURCE_PATH}")

    vcpkg_list(SET MSBUILD_OPTIONS
        "/p:UseVcpkg=yes"
        "/p:IceBuildingSrc=yes"
        ${ICE_OPTIONAL_COMPONENTS_MSBUILD}
    )

    # Build Ice
    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH "cpp/msbuild/ice.${VCPKG_PLATFORM_TOOLSET}.sln"
        SKIP_CLEAN
        TARGET "C++11\\ice++11"
        USE_VCPKG_INTEGRATION
        OPTIONS
            ${MSBUILD_OPTIONS}
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

endif()

# Remove unnecessary static libraries.
file(GLOB PDLIBS "${CURRENT_PACKAGES_DIR}/debug/lib/*")
file(GLOB PRLIBS "${CURRENT_PACKAGES_DIR}/lib/*")
list(FILTER PDLIBS INCLUDE REGEX ".*(([Ii]ce[Uu]til|[Ss]lice)d?\.([a-z]+))$")
list(FILTER PRLIBS INCLUDE REGEX ".*(([Ii]ce[Uu]til|[Ss]lice)d?\.([a-z]+))$")
file(REMOVE ${PDLIBS} ${PRLIBS})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/zeroc-ice RENAME copyright)
