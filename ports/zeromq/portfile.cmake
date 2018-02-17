include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/libzmq
    REF 18498f620f0f6d4076981ea16eb5760fe4d28dc2
    SHA512 0c4a5c72455411f47283da3cad381600101be19a62437ad8e2c38e5f18fb6d621a3136e402c6eb9ba153f3d6333da9902335c2dacd8405094d4d1269df28d4af
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} \"-I${SOURCE_PATH}/builds/msvc\"")
set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} \"-I${SOURCE_PATH}/builds/msvc\"")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DZMQ_BUILD_TESTS=OFF
        -DPOLLER=select
        -DBUILD_STATIC=${BUILD_STATIC}
        -DBUILD_SHARED=${BUILD_SHARED}
        -DWITH_PERF_TOOL=OFF
    OPTIONS_DEBUG
        "-DCMAKE_PDB_OUTPUT_DIRECTORY=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/ZeroMQ)

file(READ ${CURRENT_PACKAGES_DIR}/share/zeromq/ZeroMQConfig.cmake _contents)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(REPLACE "get_target_property(ZeroMQ_STATIC_LIBRARY libzmq-static LOCATION)" "add_library(libzmq-static INTERFACE IMPORTED)\nset_target_properties(libzmq-static PROPERTIES INTERFACE_LINK_LIBRARIES libzmq)" _contents "${_contents}")
    set(_contents "${_contents}\nset(ZeroMQ_STATIC_LIBRARY \${ZeroMQ_LIBRARY})\n")
else()
    string(REPLACE "get_target_property(ZeroMQ_LIBRARY libzmq LOCATION)" "add_library(libzmq INTERFACE IMPORTED)\nset_target_properties(libzmq PROPERTIES INTERFACE_LINK_LIBRARIES libzmq-static)" _contents "${_contents}")
    set(_contents "${_contents}\nset(ZeroMQ_LIBRARY \${ZeroMQ_STATIC_LIBRARY})\n")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/share/zeromq/ZeroMQConfig.cmake "${_contents}")

# Handle copyright
file(RENAME ${CURRENT_PACKAGES_DIR}/share/zmq/COPYING.LESSER.txt ${CURRENT_PACKAGES_DIR}/share/zeromq/copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/share/zmq)
