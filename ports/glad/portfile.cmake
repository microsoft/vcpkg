include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dav1dde/glad
    REF v0.1.28
    SHA512 5895e25bffab4ead346f65011cbb52a434779fed1dad619ffde27f68b52994cd0b048a45b4533b22b54971dfdba935d93fcf6bee5789061d0057af869b95998c
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
vcpkg_add_to_path("${PYTHON2_DIR}")

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
