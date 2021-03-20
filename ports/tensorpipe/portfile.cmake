vcpkg_fail_port_install(ON_TARGET "windows" "uwp")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("test" IN_LIST FEATURES)
    list(APPEND FEATURE_PATCHES support-test.patch)
endif()
if(NOT VCPKG_TARGET_IS_LINUX)
    if("cma" IN_LIST FEATURES)
        message(FATAL_ERROR "'cma' feature is for Linux")
    elseif("ibv" IN_LIST FEATURES)
        message(FATAL_ERROR "'ibv' feature is for Linux")
    elseif("shm" IN_LIST FEATURES)
        message(FATAL_ERROR "'shm' feature is for Linux")
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/tensorpipe
    REF ee18d15dd098fe74b51f3d554fca7fa8ec6b3ce6
    SHA512 7ec69cf6291b7d8ec85008f76c98a1a20e268f6e2c1fa2792cc60e1c21babb9ac56b44fbc8b59e0fb1b396fa1127a15ad73a4f865a537eb3ae94ef371d36f25d
    PATCHES
        fix-cmakelists.patch
        ${FEATURE_PATCHES}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cuda        TP_USE_CUDA
        cuda        TP_ENABLE_CUDA_IPC
        shm         TP_ENABLE_SHM
        ibv         TP_ENABLE_IBV
        cma         TP_ENABLE_CMA
        pybind11    TP_BUILD_PYTHON
        test        TP_BUILD_TESTING
        benchmark   TP_BUILD_BENCHMARK
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTP_BUILD_LIBUV=OFF
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
