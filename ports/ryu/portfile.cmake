vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO ulfjack/ryu
        REF v2.0
        SHA512 88a0cca74a4889e8e579987abdc75a6ac87c1cdae557e5a15c29dbfd65733f9e591d6569e97a9374444918475099087f8056e696a97c9be24e38eb737e2304c2
        HEAD_REF master
)

vcpkg_find_acquire_program(BAZEL)
get_filename_component(BAZEL_DIR "${BAZEL}" DIRECTORY)
vcpkg_add_to_path(PREPEND ${BAZEL_DIR})
set(ENV{BAZEL_BIN_PATH} "${BAZEL}")

if (CMAKE_HOST_WIN32)
    set(ENV{BAZEL_VS} $ENV{VSInstallDir})
    set(ENV{BAZEL_VC} $ENV{VCInstallDir})
endif ()

vcpkg_execute_build_process(
            COMMAND ${BAZEL} build --verbose_failures --strategy=CppCompile=standalone //ryu //ryu:ryu_printf
            WORKING_DIRECTORY ${SOURCE_PATH}
            LOGNAME build-${TARGET_TRIPLET}-rel
    )

if (CMAKE_HOST_WIN32)
    file(INSTALL ${SOURCE_PATH}/bazel-bin/ryu/ryu.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(INSTALL ${SOURCE_PATH}/bazel-bin/ryu/ryu.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
    file(INSTALL ${SOURCE_PATH}/bazel-bin/ryu/ryu_printf.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(INSTALL ${SOURCE_PATH}/bazel-bin/ryu/ryu_printf.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
else()
    file(INSTALL ${SOURCE_PATH}/bazel-bin/ryu/libryu.a DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(INSTALL ${SOURCE_PATH}/bazel-bin/ryu/libryu.a DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
    file(INSTALL ${SOURCE_PATH}/bazel-bin/ryu/libryu_printf.a DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(INSTALL ${SOURCE_PATH}/bazel-bin/ryu/libryu_printf.a DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE-Boost DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/ryu/ryu.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/ryu/)
file(INSTALL ${SOURCE_PATH}/ryu/ryu2.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/ryu/)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/ryuConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
