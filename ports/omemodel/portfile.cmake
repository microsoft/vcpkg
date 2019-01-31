include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ome/ome-model
    REF v5.6.0
    SHA512 e01a1c2323cfa614e36627de38ad44c77b3431b2148d8c2f5b3c63af6efe7f2214ae7ea8697da8df6baf73963d6875ccffdf70e1a87bf628491ae48b75aa626d
    HEAD_REF master
    PATCHES
        checks.patch
        cmakelists.patch
)

vcpkg_download_distfile(
    GENSHI_ZIP 
    URLS https://github.com/edgewall/genshi/archive/0.7.1.zip
    FILENAME genshi.zip
    SHA512 f74c407c97840e9808945c7bf7434daa6b6a790c8e5f29e96df086be5a2a46afd787c3302d2f0b9a2e76b3f12ee21daef9faf67b2fa99c3458fb1c2fdf62af25
)

vcpkg_find_acquire_program(7Z)
vcpkg_execute_required_process(
    COMMAND ${7Z} x -aoa ${GENSHI_ZIP}
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME unpack-genshi
)

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_EXE_PATH ${PYTHON2} DIRECTORY)
set(ENV{PATH} "${PYTHON2_EXE_PATH};$ENV{PATH}")
vcpkg_execute_required_process(
    COMMAND ${PYTHON2} setup.py install --user
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/genshi-0.7.1/
    LOGNAME install-genshi
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
       -Dtest:BOOL=OFF
       -Dextended-tests:BOOL=OFF
       -Drelocatable-install:BOOL=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/OMEXML TARGET_PATH share/OMEXML)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(COPY ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/omemodel)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/omemodel/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/omemodel/copyright)