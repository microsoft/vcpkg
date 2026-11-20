vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BehaviorTree/BehaviorTree.CPP
    REF "${VERSION}"
    SHA512 3a3b32a1d2a6e1fb898a60612c54ddce8f877c0ac4288e7aa8e2c9827c87bffff69f68e36cb50f4db49bd47cca322306c99c841aefc3e453c2ef474455446d5c
    HEAD_REF master
    PATCHES
        remove-source-charset.diff # because vcpkg's default toolchain uses /utf-8 which is incompatible with /source-charset
        fix-dependencies.patch
        mtr_enabled.patch # https://github.com/BehaviorTree/BehaviorTree.CPP/pull/1291
		warning_as_error.patch # Maintainer rejected an option for this: https://github.com/BehaviorTree/BehaviorTree.CPP/pull/1293
)

# Set BTCPP_SHARED_LIBS based on VCPKG_LIBRARY_LINKAGE
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BTCPP_SHARED_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        groot BTCPP_GROOT_INTERFACE
        sqlite BTCPP_SQLITE_LOGGING
)

if("groot" IN_LIST FEATURES)
    # Avoid shadowing zeromq's vcpkg CMake wrapper during cppzmq's dependency lookup.
    file(REMOVE "${SOURCE_PATH}/cmake/FindZeroMQ.cmake")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_ament_cmake=1
        -DBTCPP_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DBTCPP_BUILD_TOOLS=OFF
        -DBTCPP_SHARED_LIBS=${BTCPP_SHARED_LIBS}
        -DUSE_VENDORED_CPPZMQ=OFF
        -DUSE_VENDORED_FLATBUFFERS=OFF
        -DUSE_VENDORED_MINITRACE=OFF
        -DUSE_VENDORED_TINYXML2=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/behaviortree_cpp PACKAGE_NAME behaviortree_cpp)
vcpkg_copy_pdbs()

vcpkg_install_copyright(
    COMMENT [[
The installed headers contain embedded copies of the following libraries:
- linb::any and expected-lite, licensed under BSL-1.0. Copyright notices are retained in the headers; see https://www.boost.org/LICENSE_1_0.txt.
- nlohmann/json and magic_enum, licensed under MIT. Copyright and SPDX notices are retained in the headers.
]]
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/3rdparty/minicoro/LICENSE"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
