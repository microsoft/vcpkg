vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO artem-ogre/CDT
    REF "${VERSION}"
    SHA512 15cf7f12aaddbf89eba48a8884ca9f57ccc4f44a8e94f5719df22141beea2a8f19de9d36fa9e573c790bfc8520db56e972ea5774cc23942cce02387ee027e8fe
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "64-bit-index-type"     CDT_USE_64_BIT_INDEX_TYPE
        "as-compiled-library"   CDT_USE_AS_COMPILED_LIBRARY
)

if (NOT CDT_USE_AS_COMPILED_LIBRARY)
    set(VCPKG_BUILD_TYPE "release") # header-only
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/CDT"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

if (CDT_USE_AS_COMPILED_LIBRARY)
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/include"
        "${CURRENT_PACKAGES_DIR}/debug/share"
	)
endif()

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/CDT/include/portable_nth_element.hpp"
    "${SOURCE_PATH}/CDT/include/predicates.h"
)
