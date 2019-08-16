include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO blend2d/blend2d
  REF 934d07161971aeef5c4ac3b15e69ff57929445ac
  SHA512 71b17611c20a8a7d27a37b0984918ce4ed608d8d2d053d116cd4c0ca9b7fcad742f39ef9939d9addf600113c2ad399d1dc4ee72b5f036ccda58b7d4237316928
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
    REF 5d40561d14f93dc45613bfa03155d1dfb4f5825a
    SHA512 88f16fc1ff8e9eb1b8d7441d7bd2e08d238a2104f3de94aaa16972faac704bf526996fa1556a3831701fb370f051df6839b4058690cf2f49ea5aeb1224c84fe0
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
