vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BehaviorTree/BehaviorTree.CPP
    REF "${VERSION}"
    SHA512 1c76440baa562ddae8d63e2c2ea0d2ebdd7863771486c6729e6c646928659feeb551a7d0cd6483d93e96f5d8f2a3f29e59a102e9dbb97406b4e90317dd804c2b
    HEAD_REF master
    PATCHES
        remove-source-charset.diff # because vcpkg's default toolchain uses /utf-8 which is incompatible with /source-charset
        fix-dependencies.patch
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
