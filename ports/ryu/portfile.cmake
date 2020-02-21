vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO ulfjack/ryu
        REF v2.0
        SHA512 88a0cca74a4889e8e579987abdc75a6ac87c1cdae557e5a15c29dbfd65733f9e591d6569e97a9374444918475099087f8056e696a97c9be24e38eb737e2304c2
        HEAD_REF master
)

vcpkg_find_acquire_program(BAZEL)
vcpkg_execute_build_process(
        COMMAND bazel build //ryu
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME build-${TARGET_TRIPLET}-rel
)

file(INSTALL ${SOURCE_PATH}/LICENSE-Boost DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/ryu/ryu.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/ryuConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/bazel-bin/ryu/libryu.a DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
file(INSTALL ${SOURCE_PATH}/bazel-bin/ryu/libryu.a DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
