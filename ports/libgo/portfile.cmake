vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yyzybb537/libgo
    REF 5d4f36508e8eb2d5aa17cf37cd951dc91da23096 #v3.1
    SHA512 0f281f58116148ba1dd3904febbc391d47190f8e148b70bed7c4b7e6cb3efa5e41e2b7be4832ceeb805996e085f4c2d89fd0cf3b0651e037b32758d6a441411b
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH XHOOK_SOURCE_PATH
    REPO XBased/xhook
    REF e18c450541892212ca4f11dc91fa269fabf9646f
    SHA512 1bcf320f50cff13d92013a9f0ab5c818c2b6b63e9c1ac18c5dd69189e448d7a848f1678389d8b2c08c65f907afb3909e743f6c593d9cfb21e2bb67d5c294a166
    HEAD_REF master
)

file(REMOVE_RECURSE ${SOURCE_PATH}/third_party)
file(MAKE_DIRECTORY ${SOURCE_PATH}/third_party)
file(RENAME ${XHOOK_SOURCE_PATH} ${SOURCE_PATH}/third_party/xhook)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_build_cmake()
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libgo.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libgo.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    # Install headers
    file(GLOB HEADERS ${SOURCE_PATH}/libgo/*.h)   
    file(INSTALL ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo)
    file(INSTALL ${SOURCE_PATH}/libgo/cls/co_local_storage.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo/cls)
    file(GLOB COMMOM_HEADERS ${SOURCE_PATH}/libgo/common/*.h)
    file(INSTALL ${COMMOM_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo/common)
    file(INSTALL ${SOURCE_PATH}/libgo/context/fiber/context.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo/context/fiber)
    file(GLOB CONTXET_HEADERS ${SOURCE_PATH}/libgo/context/*.h)
    file(INSTALL ${CONTXET_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo/context)
    file(GLOB DEBUG_HEADERS ${SOURCE_PATH}/libgo/debug/*.h)
    file(INSTALL ${DEBUG_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo/debug)
    file(INSTALL ${SOURCE_PATH}/libgo/defer/defer.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo/defer)
    file(GLOB WINDOWS_HEADERS ${SOURCE_PATH}/libgo/netio/windows/*.h)
    file(INSTALL ${WINDOWS_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo/netio/windows)
    file(INSTALL ${SOURCE_PATH}/libgo/netio/windows/arpa/inet.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo/netio/windows/arpa)
    file(GLOB WINDOWS_SYS ${SOURCE_PATH}/libgo/netio/windows/sys/*.h)
    file(INSTALL ${WINDOWS_SYS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo/netio/windows/sys)
    file(INSTALL ${SOURCE_PATH}/libgo/netio/windows/xhook/xhook.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo/netio/windows/xhook/)
    file(GLOB POOL_HEADERS ${SOURCE_PATH}/libgo/pool/*.h)
    file(INSTALL ${POOL_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo/pool)
    file(GLOB SCHEDULER_HEADERS ${SOURCE_PATH}/libgo/scheduler/*.h)
    file(INSTALL ${SCHEDULER_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo/scheduler) 
    file(GLOB SYNC_HEADERS ${SOURCE_PATH}/libgo/sync/*.h)
    file(INSTALL ${SYNC_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo/sync)
    file(INSTALL ${SOURCE_PATH}/libgo/task/task.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo/task)
    file(INSTALL ${SOURCE_PATH}/libgo/timer/timer.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/libgo/timer)
else()
    vcpkg_install_cmake()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/libgo/netio/disable_hook)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/libgo/netio/unix/static_hook)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CURRENT_PORT_DIR}/libgo-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})