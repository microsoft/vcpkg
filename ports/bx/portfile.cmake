# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Download source

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_DIR
    REPO "bkaradzic/bx"
    HEAD_REF master
    REF 2e4bc10d6c63b811f4aa2f9c8678339221bc73ca
    SHA512 053dbf356c46258d6cf32783f90e90025534c049c4f63c1d33348986a5f71303bbd34a6acc7e51b771f29b6565ee273bf487a77f4dd67bc6de1e614ec20e39ab
)

# Set up GENie (custom project generator)
vcpkg_configure_genie("${SOURCE_DIR}/tools")

if(GENIE_ACTION STREQUAL cmake)
    # Run CMake
    vcpkg_configure_cmake(
        SOURCE_PATH "${SOURCE_DIR}/.build/projects/${PROJ_FOLDER}"
        PREFER_NINJA
        OPTIONS_RELEASE -DCMAKE_BUILD_TYPE=Release
        OPTIONS_DEBUG -DCMAKE_BUILD_TYPE=Debug
    )
    vcpkg_install_cmake(TARGET bx/all)
    # GENie does not generate an install target, so we install explicitly
    file(INSTALL 
        "${SOURCE_DIR}/include/bx"
        "${SOURCE_DIR}/include/compat"
        "${SOURCE_DIR}/include/tinystl"
        DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    file(GLOB instfiles
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bx/*.a"
    )
    file(INSTALL ${instfiles} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(GLOB instfiles
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bx/*.a"
    )
    file(INSTALL ${instfiles} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(INSTALL "${SOURCE_DIR}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
else()
    # Run MSBuild
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_DIR}"
        PROJECT_SUBPATH ".build/projects/${PROJ_FOLDER}/bx.vcxproj"
        LICENSE_SUBPATH "LICENSE"
        INCLUDES_SUBPATH "include"
    )
endif()

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
