include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO blend2d/blend2d
  REF 60bb0a03199b406dac92cfaa07d026cd8be2df34
  SHA512 eb214f39be5285e2fcea494ecb461723420763fea14e0ffd3ee96618f0256b5da25e4c74e2914d0722d44cc75ccaa5fd91a1731b427b884dd829107a5e8d5c55
  HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BLEND2D_STATIC)

if(NOT ("jit" IN_LIST FEATURES))
  set(BLEND2D_BUILD_NO_JIT TRUE)
endif()
if(NOT ("logging" IN_LIST FEATURES))
  set(BLEND2D_BUILD_NO_LOGGING TRUE)
endif()

if(NOT BLEND2D_BUILD_NO_JIT)
  vcpkg_from_github(
    OUT_SOURCE_PATH ASMJIT_SOURCE_PATH
    REPO asmjit/asmjit
    REF 238243530a35f5ad6205695ff0267b8bd639543a
    SHA512 fd7936d3de5eabba35f4eb2d91f1833ab29c2ca34d9a89de674373f8101888ca9594bae34eb9eb02a9552fbf1785cdbf913a34db1865f9f56d39ce32aa951df7
    HEAD_REF master
  )

  file(REMOVE_RECURSE ${SOURCE_PATH}/3rdparty/asmjit)

  get_filename_component(ASMJIT_SOURCE_DIR_NAME ${ASMJIT_SOURCE_PATH} NAME)
  file(COPY ${ASMJIT_SOURCE_PATH} DESTINATION ${SOURCE_PATH}/3rdparty)
  file(RENAME ${SOURCE_PATH}/3rdparty/${ASMJIT_SOURCE_DIR_NAME} ${SOURCE_PATH}/3rdparty/asmjit)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBLEND2D_STATIC=${BLEND2D_STATIC}
        -DBLEND2D_BUILD_NO_JIT=${BLEND2D_BUILD_NO_JIT}
        -DBLEND2D_BUILD_NO_LOGGING=${BLEND2D_BUILD_NO_LOGGING}
)


vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)


if(BLEND2D_STATIC)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()



# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

if(BLEND2D_STATIC)
  # Install usage
  configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)
endif()
