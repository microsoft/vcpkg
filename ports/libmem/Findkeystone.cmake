if (MSVC)
    set(INSTALLED_ROOT "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
    set(keystone_LIBRARY_DIRS "${INSTALLED_ROOT}/lib")
    set(keystone_INCLUDE_DIRS "${INSTALLED_ROOT}/include")
    set(KEYSTONE_LIBRARY_NAMES keystone libkeystone)

    find_library(KEYSTONE_LIBRARIES
    NAMES ${KEYSTONE_LIBRARY_NAMES}
    PATHS ${keystone_LIBRARY_DIRS}
    PATH_SUFFIXES lib
    REQUIRED)

    find_path(KEYSTONE_INCLUDE_DIR
        NAMES keystone.h
        PATHS ${keystone_INCLUDE_DIRS}
        PATH_SUFFIXES include keystone
        REQUIRED)

    include(FindPackageHandleStandardArgs)

    find_package_handle_standard_args(
        keystone DEFAULT_MSG
        KEYSTONE_LIBRARIES
        keystone_LIBRARY_DIRS
        keystone_INCLUDE_DIRS
    )
else()
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(keystone REQUIRED IMPORTED_TARGET keystone)
    add_library(keystone ALIAS PkgConfig::keystone)
endif()
