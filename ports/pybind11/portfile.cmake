vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF 8de7772cc72daca8e947b79b83fea46214931604 # v2.6.2
    SHA512 9bb688209791bd5f294fa316ab9a8007f559673a733b796e76e223fe8653d048d3f01eb045b78aa1843f7eacf97f6e2ee090ac68fed2b43856eb0c4813583204
    HEAD_REF master
    PATCHES add-feature-options.patch
)

set(EXTRA_OPTIONS )
if ("python2" IN_LIST FEATURES AND "python3" IN_LIST FEATURES)
    message(FATAL_ERROR "Only one function can be selected for ${PORT}.")
elseif ("python2" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON2)
    set(EXTRA_OPTIONS -DPython2_EXECUTABLE=${PYTHON2})
elseif ("python3" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    set(EXTRA_OPTIONS -DPython3_EXECUTABLE=${PYTHON3})
else()
    message(FATAL_ERROR "${PORT} must select a function.")
endif()


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    python2 WITH_PYTHON2
    python3 WITH_PYTHON3
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DPYBIND11_TEST=OFF
        -DPYBIND11_FINDPYTHON=ON
       ${EXTRA_OPTIONS}
    OPTIONS_RELEASE
        -DPYTHON_IS_DEBUG=OFF
    OPTIONS_DEBUG
        -DPYTHON_IS_DEBUG=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/pybind11)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/)

# copy license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
