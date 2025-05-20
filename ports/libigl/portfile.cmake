vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libigl/libigl
    REF  "v${VERSION}"
    SHA512 7c6ae5b94020a01df5d6d0a358592293595d8d8bf04bf42e6acc09bcd6ed012071069373a71ed6f24ce878aa79447dd189b42bc8a3a70819ef05dccc60a2cf68
    HEAD_REF master
    PATCHES
        dependencies.patch
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
    "${SOURCE_PATH}/cmake/recipes/external/spectra.cmake"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cgal            LIBIGL_COPYLEFT_CGAL
        embree          LIBIGL_EMBREE
        glfw            LIBIGL_GLFW
        imgui           LIBIGL_IMGUI
        opengl          LIBIGL_OPENGL
        xml             LIBIGL_XML
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
        -DLIBIGL_SPECTRA=OFF
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
