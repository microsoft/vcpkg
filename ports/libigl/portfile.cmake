vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libigl/libigl
    REF  f6b406427400ed7ddb56cfc2577b6af571827c8c #2.1.0
    SHA512 262f0b16e6c018d86d11a7cc90f8f4f8088fa7190634a7cd5cc392ebdefe47e2218b4f9276e411498ae0001d66d0207f4108c87c5090e3a39df4a2760930e945
    HEAD_REF master
    PATCHES fix-dependency.patch
)

set(LIBIGL_BUILD_STATIC OFF)
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(LIBIGL_BUILD_STATIC ON)
endif()

if ("python" IN_LIST FEATURES)
    vcpkg_check_linkage(ONLY_STATIC_CRT)
    
    vcpkg_find_acquire_program(PYTHON2)
    get_filename_component(PYTHON2_DIR ${PYTHON2} DIRECTORY)
    set(ENV{PATH} "$ENV{PATH};${PYTHON2_DIR}")
endif()

if ("test" IN_LIST FEATURES AND NOT EXISTS ${SOURCE_PATH}/tests/data)
    set(TEST_SOURCE_PATH ${SOURCE_PATH}/tests/data)
    file(MAKE_DIRECTORY ${TEST_SOURCE_PATH})
    vcpkg_from_github(
        OUT_SOURCE_PATH ${TEST_SOURCE_PATH}
        REPO libigl/libigl-tests-data
        REF  0689abc55bc12825e6c01ac77446f742839ff277
        SHA512 2b6aec21ed39a9fd534da86fff75eee0f94a3ea2db2fb9dd28974636cc34936341cc28dfcf3bb07cf79409124342717e001c529dc887da72c85fe314b0eb6ea6
        HEAD_REF master
    )
endif()

if ("imgui" IN_LIST FEATURES AND VCPKG_LIBRARY_LINKAGE STREQUAL static)
    # Remove this after add port libigl-imgui
    message(FATAL_ERROR "Feature imgui does not support static build currentlly")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    embree LIBIGL_WITH_EMBREE
    opengl LIBIGL_WITH_OPENGL
    glfw LIBIGL_WITH_OPENGL_GLFW
    imgui LIBIGL_WITH_OPENGL_GLFW_IMGUI
    #png LIBIGL_WITH_PNG# Disable this feature due to issue https://github.com/libigl/libigl/issues/1199
    xml LIBIGL_WITH_XML
    python LIBIGL_WITH_PYTHON
    test LIBIGL_BUILD_TESTS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DLIBIGL_BUILD_PYTHON=OFF
        -DLIBIGL_EXPORT_TARGETS=ON
        -DLIBIGL_USE_STATIC_LIBRARY=${LIBIGL_BUILD_STATIC}
        -DLIBIGL_WITH_COMISO=OFF
        -DLIBIGL_WITH_TETGEN=OFF
        -DLIBIGL_WITH_TRIANGLE=OFF
        -DLIBIGL_WITH_PREDICATES=OFF
        -DLIBIGL_WITH_PNG=OFF
        -DLIBIGL_BUILD_TUTORIALS=OFF
		-DPYTHON_EXECUTABLE=${PYTHON2}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/libigl/cmake)
vcpkg_copy_pdbs()

if (NOT LIBIGL_BUILD_STATIC)
    # For dynamic build, libigl is a header-only library.
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE.GPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

