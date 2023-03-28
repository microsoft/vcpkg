# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libigl/libigl
    REF  66b3ef2253e765d0ce0db74cec91bd706e5ba176 #2.4.0
    SHA512 7014ffdaa160bfa2509fc283cb7176d7994a37f51509c7374659292efad076c8fb594f9f6990bab1aa5562d1f66e93403ea35a5bf2a924436560a2d4669ffcfd
    HEAD_REF master
    PATCHES
        dependencies.patch
        upstream_fixes.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        embree          LIBIGL_EMBREE
        opengl          LIBIGL_OPENGL
        glfw            LIBIGL_GLFW
        imgui           LIBIGL_IMGUI
        png             LIBIGL_PNG
        xml             LIBIGL_XML
        cgal            LIBIGL_COPYLEFT_CGAL
        predicates      LIBIGL_PREDICATES
        comiso          LIBIGL_COMISO
        tetgen          LIBIGL_TETGEN
        triangle        LIBIGL_TRIANGLE
)

# External dependencies, which are not packaged by vcpkg
# COMISO
if(LIBIGL_COMISO)
    vcpkg_from_github(
        OUT_SOURCE_PATH COMISO_SOURCE_PATH
        REPO            libigl/CoMISo
        REF             536440e714f412e7ef6c0b96b90ba37b1531bb39
        SHA512          79824ea7f52dc6d59da491a9df763215285955ad2414c508368bcddd227adced72553476ede6d1ff95d4f0c3df8b4854d1d534dc7d2ab648b13c105f948ca2b3
        HEAD_REF        master
    )
    list(APPEND ADDITIONAL_OPTIONS "-DFETCHCONTENT_SOURCE_DIR_COMISO=${COMISO_SOURCE_PATH}")
endif()

# tetgen
if(LIBIGL_TETGEN)
    vcpkg_from_github(
        OUT_SOURCE_PATH TETGEN_SOURCE_PATH
        REPO            libigl/tetgen
        REF             4f3bfba3997f20aa1f96cfaff604313a8c2c85b6
        SHA512          d847cddd699df4ddca1743d328db8d9f193986f46df668683450b55331d701d6d1f4b9f8aa9d0097856892e3b21bdd5582a41d6ee37f2cf148eb31630e62258e
        HEAD_REF        master
    )
    list(APPEND ADDITIONAL_OPTIONS "-DFETCHCONTENT_SOURCE_DIR_TETGEN=${TETGEN_SOURCE_PATH}")
endif()


# triangle
if(LIBIGL_TRIANGLE)
    include(FetchContent)
    vcpkg_from_github(
        OUT_SOURCE_PATH TRIANGLE_SOURCE_PATH
        REPO            libigl/triangle
        REF             3ee6cac2230f0fe1413879574f741c7b6da11221
        SHA512          f668836277585068324a208e0cc445ddda569e048ea99e9a77df1e0027e5efa38882c6fcccee242213adf24127db24d018d3b2eea227762eaab9e1b60292a6fd
        HEAD_REF        master
    )
    list(APPEND ADDITIONAL_OPTIONS "-DFETCHCONTENT_SOURCE_DIR_TRIANGLE=${TRIANGLE_SOURCE_PATH}")
endif()

# remove custom FindGMP and FildMPFR
file(REMOVE "${SOURCE_PATH}/cmake/find/FindGMP.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/find/FindMPFR.cmake")

# static or dynamic build
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBIGL_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
        # Build options
        -DLIBIGL_BUILD_TESTS=OFF
        -DLIBIGL_BUILD_TUTORIALS=OFF
        -DLIBIGL_INSTALL=ON
        -DLIBIGL_USE_STATIC_LIBRARY=${LIBIGL_BUILD_STATIC}
        -DHUNTER_ENABLED=OFF
        -DLIBIGL_COPYLEFT_COMISO=${LIBIGL_COMISO}
        -DLIBIGL_COPYLEFT_TETGEN=${LIBIGL_TETGEN}
        -DLIBIGL_RESTRICTED_TRIANGLE=${LIBIGL_TRIANGLE}
        ${ADDITIONAL_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        LIBIGL_COMISO
        LIBIGL_TETGEN
        LIBIGL_TRIANGLE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/igl PACKAGE_NAME libigl)
vcpkg_copy_pdbs()

# libigl is a header-only library.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${SOURCE_PATH}/LICENSE.GPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
