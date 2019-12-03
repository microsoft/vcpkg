# Download source packages
# (bimg requires bx source for building)

vcpkg_from_github(OUT_SOURCE_PATH BX_SOURCE_DIR
    REPO "bkaradzic/bx"
    HEAD_REF master
    REF d175bde9d0059b126fd2a3084167623077586fe9
    SHA512 5166933a117f6f18edc6f4a44c36ab353836419d7749d5b2c0b67802f6a29aa08bf13520be70cd5236bf0bae8cd779d793db173f8c9e95987a0bc5b5568c8f7a
)

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_DIR
    REPO "bkaradzic/bimg"
    HEAD_REF master
    REF ed5fec9e82f975b2b37641e238f6f78d51c5b82c
    SHA512 1e1be1ffe5bf9d651eb57e72443e6b07bdd53c60cce494d397a29781c9d3b9461d88a95fea8bc064c767a1983b8ba09919ea6f151765a4b10568bba5655623d5
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
