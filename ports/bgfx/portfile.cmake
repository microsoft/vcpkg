# Download source packages
# (bgfx requires bx and bimg source for building)

vcpkg_from_github(OUT_SOURCE_PATH BX_SOURCE_DIR
    REPO "bkaradzic/bx"
    HEAD_REF master
    REF d175bde9d0059b126fd2a3084167623077586fe9
    SHA512 5166933a117f6f18edc6f4a44c36ab353836419d7749d5b2c0b67802f6a29aa08bf13520be70cd5236bf0bae8cd779d793db173f8c9e95987a0bc5b5568c8f7a
)

vcpkg_from_github(OUT_SOURCE_PATH BIMG_SOURCE_DIR
    REPO "bkaradzic/bimg"
    HEAD_REF master
    REF ed5fec9e82f975b2b37641e238f6f78d51c5b82c
    SHA512 1e1be1ffe5bf9d651eb57e72443e6b07bdd53c60cce494d397a29781c9d3b9461d88a95fea8bc064c767a1983b8ba09919ea6f151765a4b10568bba5655623d5
)

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_DIR
    REPO "bkaradzic/bgfx"
    HEAD_REF master
    REF 3f1c51203bea6443b029eaebb5d8132725180490
    SHA512 3c73f767f7906bcfbb84b225f5cbe26a897cf3e2cb0cccb5d7fdafb52f16bdc860e1151336ed21a96f3e11aba6db1d6de0dd90171b3e327b0157e319a2607f22
)

# Copy bx source inside bgfx source tree
file(GLOB BX_FILES LIST_DIRECTORIES true "${BX_SOURCE_DIR}/*")
file(COPY ${BX_FILES} DESTINATION "${SOURCE_DIR}/.bx")
set(BX_DIR ${SOURCE_DIR}/.bx)
set(ENV{BX_DIR} ${BX_DIR})

# Copy bimg source inside bgfx source tree
file(GLOB BIMG_FILES LIST_DIRECTORIES true "${BIMG_SOURCE_DIR}/*")
file(COPY ${BIMG_FILES} DESTINATION "${SOURCE_DIR}/.bimg")
set(BIMG_DIR ${SOURCE_DIR}/.bimg)
set(ENV{BIMG_DIR} ${BIMG_DIR})

# Set up GENie (custom project generator)
vcpkg_configure_genie("${BX_SOURCE_DIR}/tools" "--with-tools")

if(GENIE_ACTION STREQUAL cmake)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(PROJ bgfx-shared-lib)
    else()
        set(PROJ bgfx)
    endif()
    vcpkg_configure_cmake(
        SOURCE_PATH "${SOURCE_DIR}/.build/projects/${PROJ_FOLDER}"
        PREFER_NINJA
        OPTIONS_RELEASE -DCMAKE_BUILD_TYPE=Release
        OPTIONS_DEBUG -DCMAKE_BUILD_TYPE=Debug
    )
    vcpkg_build_cmake(TARGET shaderc/all)
    vcpkg_install_cmake(TARGET ${PROJ}/all)
    file(INSTALL "${SOURCE_DIR}/include/bgfx" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    file(GLOB instfiles
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${PROJ}/*.a"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${PROJ}/*.so"
    )
    file(INSTALL ${instfiles} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(GLOB instfiles
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${PROJ}/*.a"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${PROJ}/*.so"
    )
    file(INSTALL ${instfiles} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/shaderc/shadercRelease" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")
    file(INSTALL "${SOURCE_DIR}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
else()
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_DIR}"
        PROJECT_SUBPATH ".build/projects/${PROJ_FOLDER}/bgfx.sln"
        LICENSE_SUBPATH "LICENSE"
        INCLUDES_SUBPATH "include"
    )
    # Remove redundant files
    foreach(a bx bimg bimg_decode bimg_encode)
        foreach(b Debug Release)
            foreach(c lib pdb)
                if(b STREQUAL Debug)
                    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/${a}${b}.${c}")
                else()
                    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/${a}${b}.${c}")
                endif()
            endforeach()
        endforeach()
    endforeach()
endif()

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
