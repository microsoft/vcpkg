# Download source packages
# (bimg requires bx source for building)

vcpkg_from_github(OUT_SOURCE_PATH BX_SOURCE_DIR
    REPO "bkaradzic/bx"
    HEAD_REF master
    REF 2e4bc10d6c63b811f4aa2f9c8678339221bc73ca
    SHA512 053dbf356c46258d6cf32783f90e90025534c049c4f63c1d33348986a5f71303bbd34a6acc7e51b771f29b6565ee273bf487a77f4dd67bc6de1e614ec20e39ab
)

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_DIR
    REPO "bkaradzic/bimg"
    HEAD_REF master
    REF b34b29fa694d5bd328bd374c1728b4d0426b1788
    SHA512 067ca2d7f3b0e937b092691584bac0759777e7b956ff10433e37c16d94ad16c014f9fd25cccad9fdf661e558ba87b0a5934f9b23130a9d7664d3594fb60badaf
)

# Copy bx source inside bimg source tree
file(GLOB BX_FILES LIST_DIRECTORIES true "${BX_SOURCE_DIR}/*")
file(COPY ${BX_FILES} DESTINATION "${SOURCE_DIR}/.bx")
set(BX_DIR ${SOURCE_DIR}/.bx)
set(ENV{BX_DIR} ${BX_DIR})

# Set up GENie (custom project generator)
vcpkg_configure_genie("${BX_SOURCE_DIR}/tools")

if(GENIE_ACTION STREQUAL cmake)
    # Run CMake
    vcpkg_configure_cmake(
        SOURCE_PATH "${SOURCE_DIR}/.build/projects/${PROJ_FOLDER}"
        PREFER_NINJA
        OPTIONS_RELEASE -DCMAKE_BUILD_TYPE=Release
        OPTIONS_DEBUG -DCMAKE_BUILD_TYPE=Debug
    )
    vcpkg_install_cmake(TARGET bimg/all)
    vcpkg_install_cmake(TARGET bimg_encode/all)
    vcpkg_install_cmake(TARGET bimg_decode/all)
    # GENie does not generate an install target, so we install explicitly
    file(INSTALL "${SOURCE_DIR}/include/bimg" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    file(GLOB instfiles
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bimg/*.a"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bimg/*.so"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bimg_encode/*.a"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bimg_encode/*.so"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bimg_decode/*.a"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bimg_decode/*.so"
    )
    file(INSTALL ${instfiles} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(GLOB instfiles
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bimg/*.a"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bimg/*.so"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bimg_encode/*.a"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bimg_encode/*.so"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bimg_decode/*.a"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bimg_decode/*.so"
    )
    file(INSTALL ${instfiles} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(INSTALL "${SOURCE_DIR}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
else()
    # Run MSBuild for all 3 targets
    foreach(PROJ bimg bimg_decode bimg_encode)
        vcpkg_install_msbuild(
            SOURCE_PATH "${SOURCE_DIR}"
            PROJECT_SUBPATH ".build/projects/${PROJ_FOLDER}/${PROJ}.vcxproj"
            LICENSE_SUBPATH "LICENSE"
            INCLUDES_SUBPATH "include"
        )
    endforeach()
endif()

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
