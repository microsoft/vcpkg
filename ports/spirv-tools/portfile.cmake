include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Tools
    REF v2018.1
    SHA512 0637c413dafd931e8222f9bf70a024f8b64116f0300c7732b86bcaff321188a0e746f79c1385ae23a7692e83194586b57692960d5be607fb2d7960731b6cd63f
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH SPIRV_HEADERS_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF bd4c092be34081d88ec8342b1a4d9f77bcce4cac
    SHA512 e0bc7b8ea73bef762eff60d83104ca93c70e06c7b6e66f73c931eb9ec51227e0b64c3169fcccbffa311acf714138300104dd5e51cdfc846ed7961debc1f9cceb
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPIRV-Headers_SOURCE_DIR=${SPIRV_HEADERS_PATH}
        -DSPIRV_WERROR=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE ${EXES})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spirv-tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/spirv-tools/LICENSE ${CURRENT_PACKAGES_DIR}/share/spirv-tools/copyright)
