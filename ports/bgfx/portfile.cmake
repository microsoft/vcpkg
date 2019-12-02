# Download source packages
# (bgfx requires bx and bimg source for building)

vcpkg_from_github(OUT_SOURCE_PATH BX_SOURCE_DIR
    REPO "bkaradzic/bx"
    HEAD_REF master
    REF 2e4bc10d6c63b811f4aa2f9c8678339221bc73ca
    SHA512 053dbf356c46258d6cf32783f90e90025534c049c4f63c1d33348986a5f71303bbd34a6acc7e51b771f29b6565ee273bf487a77f4dd67bc6de1e614ec20e39ab
)

vcpkg_from_github(OUT_SOURCE_PATH BIMG_SOURCE_DIR
    REPO "bkaradzic/bimg"
    HEAD_REF master
    REF b34b29fa694d5bd328bd374c1728b4d0426b1788
    SHA512 067ca2d7f3b0e937b092691584bac0759777e7b956ff10433e37c16d94ad16c014f9fd25cccad9fdf661e558ba87b0a5934f9b23130a9d7664d3594fb60badaf
)

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_DIR
    REPO "bkaradzic/bgfx"
    HEAD_REF master
    REF f453c55e7cb0a132397abf6dc4b71c91327e71c8
    SHA512 9dc48572f4ac7866e0ce582d11ebb33e1b0b66d3f6dfa30b737bf208869878ab3ee447e24d4c3b1444d31e7ba8c709ebe42860a61b0b65b871c5e65f311c5877
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
vcpkg_configure_genie("${BX_SOURCE_DIR}/tools")

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
