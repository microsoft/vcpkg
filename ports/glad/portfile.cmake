include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dav1dde/glad
    REF de6c39e3040c987323b8ed078c36442f4fb681b3
    SHA512 a24523186d59de5c0895791c639c62573eaacf1d3843d3bf81eba848b4a33a9a8d17f9b6f791202dac77692bf147e25b3650989731d5ddb7a22e7d023b66885e
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

file(COPY
    ${CURRENT_INSTALLED_DIR}/include/KHR/khrplatform.h
    ${CURRENT_INSTALLED_DIR}/share/egl-registry/egl.xml
    ${CURRENT_INSTALLED_DIR}/share/opengl-registry/gl.xml
    ${CURRENT_INSTALLED_DIR}/share/opengl-registry/glx.xml
    ${CURRENT_INSTALLED_DIR}/share/opengl-registry/wgl.xml
    DESTINATION ${SOURCE_PATH}/glad/files
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGLAD_NO_LOADER=OFF
        -DGLAD_EXPORT=OFF
        -DGLAD_INSTALL=ON
        -DGLAD_REPRODUCIBLE=ON
        -DGLAD_SPEC="gl" # {gl,egl,glx,wgl}
        -DGLAD_PROFILE="compatibility" # {core,compatibility}
    OPTIONS_DEBUG
        -DGLAD_GENERATOR="c-debug"
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/glad)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/include/KHR)
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/glad/copyright COPYONLY)
