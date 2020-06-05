vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "Linux" "OSX" "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevemk14ebr/PolyHook_2_0
    REF  1c8cea89adb563ef1337e711128c438d95937a5c
    SHA512 dfb7b9cd2060eadeca1f539b6c06eac6018c5eae9c093d043588853921de42a5c793ea71d800b2d6c7ee639fc54beda7e2b1ebec4dd84c443084badefbbfc45b
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    capstone  POLYHOOK_DISASM_CAPSTONE
    zydis     POLYHOOK_DISASM_ZYDIS
    exception POLYHOOK_FEATURE_EXCEPTION
    detours   POLYHOOK_FEATURE_DETOURS
    inlinentd POLYHOOK_FEATURE_INLINENTD
    pe        POLYHOOK_FEATURE_PE
    virtuals  POLYHOOK_FEATURE_VIRTUALS
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BUILD_SHARED_LIB OFF)
else()
    set(BUILD_SHARED_LIB ON)
endif()

if (VCPKG_CRT_LINKAGE STREQUAL "static")
    set(BUILD_STATIC_RUNTIME ON)
else()
    set(BUILD_STATIC_RUNTIME OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA  
    OPTIONS ${FEATURE_OPTIONS}
      -DPOLYHOOK_BUILD_SHARED_LIB=${BUILD_SHARED_LIB}
      -DPOLYHOOK_BUILD_STATIC_RUNTIME=${BUILD_STATIC_RUNTIME}
      -DPOLYHOOK_USE_EXTERNAL_ASMJIT=ON
      -DPOLYHOOK_USE_EXTERNAL_CAPSTONE=ON
      -DPOLYHOOK_USE_EXTERNAL_ZYDIS=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/PolyHook_2 TARGET_PATH share/PolyHook_2)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
