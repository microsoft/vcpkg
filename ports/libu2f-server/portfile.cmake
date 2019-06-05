include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Yubico/libu2f-server
    REF libu2f-server-1.1.0
    SHA512 085f8e7d74c1efb347747b8930386f18ba870f668f82e9bd479c9f8431585c5dc7f95b2f6b82bdd3a6de0c06f8cb2fbf51c363ced54255a936ab96536158ee59
    HEAD_REF master
    PATCHES 
      "windows.patch"
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(PLATFORM Win32)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(PLATFORM x64)
endif()

if (WIN32)

    # Copy additional files to Buildtree
    file(COPY ${CURRENT_PORT_DIR}/libu2f-server.vcxproj DESTINATION ${SOURCE_PATH})
    file(COPY ${CURRENT_PORT_DIR}/u2f-server-version.h DESTINATION ${SOURCE_PATH}/u2f-server)

    # Built project
    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH libu2f-server.vcxproj
        USE_VCPKG_INTEGRATION
    )
else()
    message(FATAL_ERROR "Sorry but gsoap only can be build in Windows temporary")
endif()

#file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include/u2f-server)
file(COPY ${SOURCE_PATH}/u2f-server/u2f-server-version.h ${SOURCE_PATH}/u2f-server/u2f-server.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/u2f-server)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
