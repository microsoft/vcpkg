include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(WARNING "Dynamic not supported. Building static")
    set(VCPKG_LIBRARY_LINKAGE "static")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Tools
    REF 94af58a350b46f85422699e27ccbf22bf453149f
    SHA512 9edb65ec5d3fcaed9329d47dd2e3bcbd51e307308179f550a3d3b5c33fa7eadb2b36d50ad1a3c39044b9ea54c1dc5b62dc751a681cdd236030bd7985d5c8a337
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH SPIRV_HEADERS_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF 2bb92e6fe2c6aa410152fc6c63443f452acb1a65
    SHA512 cdd1437a67c7e31e2062e5d0f25c767b99a3fadd64b91d00c3b07404e535bb4bfd78a43878ebbcd45e013a7153f1a2c969da99d50a99cc39efab940d0aab7cfd
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON3_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DSPIRV-Headers_SOURCE_DIR=${SPIRV_HEADERS_PATH}
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
