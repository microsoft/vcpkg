# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libigl/libigl
    REF  66b3ef2253e765d0ce0db74cec91bd706e5ba176 #2.4.0
    SHA512 7014ffdaa160bfa2509fc283cb7176d7994a37f51509c7374659292efad076c8fb594f9f6990bab1aa5562d1f66e93403ea35a5bf2a924436560a2d4669ffcfd
    HEAD_REF master
    PATCHES
        dependencies.patch
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
)

# remove custom FindGMP and FildMPFR
file(REMOVE "${SOURCE_PATH}/cmake/find/FindGMP.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/find/FindMPFR.cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
        # Build options
        -DLIBIGL_BUILD_TESTS=OFF
        -DLIBIGL_BUILD_TUTORIALS=OFF
        -DLIBIGL_INSTALL=ON
        -DLIBIGL_USE_STATIC_LIBRARY=OFF
        -DHUNTER_ENABLED=OFF
        -DLIBIGL_COPYLEFT_COMISO=OFF #there is no comiso port available anywhere. solved internally via FetchContent in cmake\recipes\external\comiso.cmake. maybe replace in patch with vcpkg_from_github 
        -DLIBIGL_COPYLEFT_TETGEN=OFF #there is no tetgen port available anywhere. solved internally via FetchContent in cmake\recipes\external\tetgen.cmake
        -DLIBIGL_RESTRICTED_TRIANGLE=OFF #same
        )

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/igl PACKAGE_NAME libigl)
file(APPEND "${CURRENT_PACKAGES_DIR}/share/libigl/libigl-config.cmake" "\nfind_package(Eigen3 CONFIG REQUIRED)\n")
file(APPEND "${CURRENT_PACKAGES_DIR}/share/libigl/libigl-config.cmake" [[include("${CMAKE_CURRENT_LIST_DIR}/LibiglConfigTargets.cmake")]])



vcpkg_copy_pdbs()

# libigl is a header-only library.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${SOURCE_PATH}/LICENSE.GPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
