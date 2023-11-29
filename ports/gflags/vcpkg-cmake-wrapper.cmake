if(NOT DEFINED GFLAGS_USE_TARGET_NAMESPACE)
    # vcpkg legacy
    set(GFLAGS_USE_TARGET_NAMESPACE ON)
    _find_package(${ARGS})
    unset(GFLAGS_USE_TARGET_NAMESPACE)
endif()
_find_package(${ARGS})
