vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Download source

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_DIR
    REPO "bkaradzic/bx"
    HEAD_REF master
    REF d175bde9d0059b126fd2a3084167623077586fe9
    SHA512 5166933a117f6f18edc6f4a44c36ab353836419d7749d5b2c0b67802f6a29aa08bf13520be70cd5236bf0bae8cd779d793db173f8c9e95987a0bc5b5568c8f7a
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
