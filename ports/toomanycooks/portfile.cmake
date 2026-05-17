set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tzcnt/TooManyCooks
    REF e3e1e5f399a9c02ad3665ad87b181e868ce8f8c0
    SHA512 17e0aff92c848009793f4712202764e3d0ec2ed388a8b807cc31e12977b1dc2bdf9f2ac67177c9dc1bfac2691c721eecbef8bfffeb79539d0d48464697da539d
    HEAD_REF main
)

if("standalone-asio" IN_LIST FEATURES AND "boost-asio" IN_LIST FEATURES)
    message(FATAL_ERROR "toomanycooks features 'standalone-asio' and 'boost-asio' are mutually exclusive")
endif()

if("windows-dll" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "toomanycooks feature 'windows-dll' is only supported for Windows targets")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hwloc                    TMC_USE_HWLOC
        boost-asio               TMC_USE_BOOST_ASIO
        trivial-task             TMC_TRIVIAL_TASK
        nodiscard-await          TMC_NODISCARD_AWAIT
        more-threads             TMC_MORE_THREADS
        debug-task-alloc-count   TMC_DEBUG_TASK_ALLOC_COUNT
        debug-thread-creation    TMC_DEBUG_THREAD_CREATION
        standalone-compilation   TMC_STANDALONE_COMPILATION
        windows-dll              TMC_WINDOWS_DLL
)

# TMC_PRIORITY_COUNT feature can't be exposed as a vcpkg feature, since vcpkg doesn't support integer configurations.
# Instead, users must specify it manually before find_package(TooManyCooks).

set(TMC_WORK_ITEM CORO)
if("funcoro" IN_LIST FEATURES)
    set(TMC_WORK_ITEM FUNCORO)
endif()

if("windows-dll" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -DTMC_STANDALONE_COMPILATION=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTMC_WORK_ITEM=${TMC_WORK_ITEM}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME TooManyCooks CONFIG_PATH lib/cmake/TooManyCooks)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/licenses"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
