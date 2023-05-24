vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libigl/libigl
    REF  66b3ef2253e765d0ce0db74cec91bd706e5ba176 #2.4.0
    SHA512 7014ffdaa160bfa2509fc283cb7176d7994a37f51509c7374659292efad076c8fb594f9f6990bab1aa5562d1f66e93403ea35a5bf2a924436560a2d4669ffcfd
    HEAD_REF master
    PATCHES
        dependencies.patch
        upstream_fixes.patch
        install-extra-targets.patch
)
file(REMOVE
    "${SOURCE_PATH}/cmake/find/FindGMP.cmake"
    "${SOURCE_PATH}/cmake/find/FindMPFR.cmake"
    "${SOURCE_PATH}/cmake/recipes/external/boost.cmake"
    "${SOURCE_PATH}/cmake/recipes/external/catch2.cmake"
    "${SOURCE_PATH}/cmake/recipes/external/cgal.cmake"
    "${SOURCE_PATH}/cmake/recipes/external/eigen.cmake"
    "${SOURCE_PATH}/cmake/recipes/external/embree.cmake"
    "${SOURCE_PATH}/cmake/recipes/external/glad.cmake"
    "${SOURCE_PATH}/cmake/recipes/external/glfw.cmake"
    "${SOURCE_PATH}/cmake/recipes/external/gmp.cmake"
    "${SOURCE_PATH}/cmake/recipes/external/gmp_mpfr.cmake"
    "${SOURCE_PATH}/cmake/recipes/external/imgui.cmake"
    "${SOURCE_PATH}/cmake/recipes/external/imguizmo.cmake"
    "${SOURCE_PATH}/cmake/recipes/external/libigl_imgui_fonts.cmake"
    "${SOURCE_PATH}/cmake/recipes/external/mpfr.cmake"
    "${SOURCE_PATH}/cmake/recipes/external/stb.cmake"
    "${SOURCE_PATH}/cmake/recipes/external/tinyxml2.cmake"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cgal            LIBIGL_COPYLEFT_CGAL
        embree          LIBIGL_EMBREE
        glfw            LIBIGL_GLFW
        imgui           LIBIGL_IMGUI
        opengl          LIBIGL_OPENGL
        png             LIBIGL_PNG
        xml             LIBIGL_XML
        # Features removed: missing binary libs / separate ports
        comiso          LIBIGL_COPYLEFT_COMISO
        predicates      LIBIGL_PREDICATES
        tetgen          LIBIGL_COPYLEFT_TETGEN
        triangle        LIBIGL_RESTRICTED_TRIANGLE
)

set(VCPKG_BUILD_TYPE release) # header-only
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBIGL_BUILD_TESTS=OFF
        -DLIBIGL_BUILD_TUTORIALS=OFF
        -DLIBIGL_INSTALL=ON
        -DLIBIGL_RESTRICTED_MATLAB=OFF
        -DLIBIGL_RESTRICTED_MOSEK=OFF
        -DLIBIGL_USE_STATIC_LIBRARY=OFF
        -DHUNTER_ENABLED=OFF
        ${ADDITIONAL_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/igl)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

if(NOT LIBIGL_COPYLEFT_CGAL)
    vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.MPL2")
else()
    vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.MPL2" "${SOURCE_PATH}/LICENSE.GPL" COMMENT "GPL for targets in \"igl_copyleft::\" namespace.")
endif()
