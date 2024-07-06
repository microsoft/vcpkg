if(NOT DEFINED GFLAGS_USE_TARGET_NAMESPACE)
    # vcpkg legacy
    set(GFLAGS_USE_TARGET_NAMESPACE ON)
    vcpkg_underlying_find_package(${ARGS})
    unset(GFLAGS_USE_TARGET_NAMESPACE)
endif()
vcpkg_underlying_find_package(${ARGS})
