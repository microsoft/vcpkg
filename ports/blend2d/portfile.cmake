vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO blend2d/blend2d
  REF 8d05b27f4445d9d53335f85fb97f53fa5fa77fce
  SHA512 d335b9203b790cab6997b35d65fb1332ae5c7039d07b4b1ff1072e24f30ebb3f53446003d4afc1ece0f34e433af1699181b254188a7392fa0d7f7e9057014dc8
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
    REF d241dfb364ba8984f621331e889014507ecb5bfc
    SHA512 345d9645f204b23e1fbedc4ab6a73790e07f8f91a953f8a89e053c3431a80c0a7430c7e2b2130d11d0029ee851f3bf1b046d7e1c9ba12396ffb9c9ee05403fc7
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
