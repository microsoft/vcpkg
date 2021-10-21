cmake_minimum_required(VERSION 3.20)
project(boinc)

find_package(OpenSSL REQUIRED)

set(LIBBOINC_HEADERS_WIN
    lib/boinc_win.h
    lib/diagnostics_win.h
    lib/idlemon.h
    lib/stackwalker_imports.h
    lib/stackwalker_win.h
)

set(LIBBOINC_HEADERS_UNIX
    lib/synch.h
    lib/unix_util.h
)

set(LIBBOINC_HEADERS_APPLE
    lib/mac/dyld_gdb.h
    lib/mac/mac_backtrace.h
    lib/mac/mac_spawn.h
    lib/mac/QBacktrace.h
    lib/mac/QCrashReport.h
    lib/mac/QMachOImage.h
    lib/mac/QMachOImageList.h
    lib/mac/QSymbols.h
    lib/mac/QTaskMemory.h
    lib/mac/mac_branding.h
)

set(LIBBOINC_HEADERS_GENERIC
    lib/app_ipc.h
    lib/base64.h
    lib/cal_boinc.h
    lib/cc_config.h
    lib/cert_sig.h
    lib/common_defs.h
    lib/coproc.h
    lib/crypt.h
    lib/diagnostics.h
    lib/error_numbers.h
    lib/filesys.h
    lib/hostinfo.h
    lib/keyword.h
    lib/md5.h
    lib/md5_file.h
    lib/mem_usage.h
    lib/mfile.h
    lib/miofile.h
    lib/network.h
    lib/notice.h
    lib/opencl_boinc.h
    lib/parse.h
    lib/prefs.h
    lib/proc_control.h
    lib/procinfo.h
    lib/project_init.h
    lib/proxy_info.h
    lib/std_fixes.h
    lib/str_replace.h
    lib/str_util.h
    lib/url.h
    lib/util.h
    lib/win_util.h
    lib/wslinfo.h
)

set(LIBBOINC_SOURCES_WIN
    lib/boinc_win.cpp
    lib/diagnostics_win.cpp
    lib/idlemon_win.cpp
    lib/procinfo_win.cpp
    lib/stackwalker_win.cpp
    lib/win_util.cpp
)

set(LIBBOINC_SOURCES_UNIX
    lib/procinfo_unix.cpp
    lib/synch.cpp
    lib/unix_util.cpp
)

set(LIBBOINC_SOURCES_APPLE
    lib/procinfo_mac.cpp
    lib/mac/mac_backtrace.cpp
    lib/mac/mac_spawn.cpp
    lib/mac/QBacktrace.c
    lib/mac/QCrashReport.c
    lib/mac/QMachOImage.c
    lib/mac/QMachOImageList.c
    lib/mac/QSymbols.c
    lib/mac/QTaskMemory.c
    lib/mac/mac_branding.cpp
)

set(LIBBOINC_SOURCES_GENERIC
    lib/app_ipc.cpp
    lib/base64.cpp
    lib/cc_config.cpp
    lib/cert_sig.cpp
    lib/coproc.cpp
    lib/crypt.cpp
    lib/diagnostics.cpp
    lib/filesys.cpp
    lib/hostinfo.cpp
    lib/keyword.cpp
    lib/md5.cpp
    lib/md5_file.cpp
    lib/mem_usage.cpp
    lib/mfile.cpp
    lib/miofile.cpp
    lib/network.cpp
    lib/notice.cpp
    lib/opencl_boinc.cpp
    lib/parse.cpp
    lib/prefs.cpp
    lib/proc_control.cpp
    lib/procinfo.cpp
    lib/project_init.cpp
    lib/proxy_info.cpp
    lib/shmem.cpp
    lib/str_util.cpp
    lib/url.cpp
    lib/util.cpp
    lib/wslinfo.cpp
)

set(LIBBOINCAPI_HEADERS
    api/boinc_api.h
)

set(LIBBOINCAPI_SOURCES_WIN
    lib/boinc_win.cpp
)

set(LIBBOINCAPI_SOURCES_GENERIC
    api/boinc_api.cpp
)

if(APPLE)
    set(LIBBOINC_HEADERS ${LIBBOINC_HEADERS_GENERIC} ${LIBBOINC_HEADERS_APPLE})
    set(LIBBOINC_SOURCES ${LIBBOINC_SOURCES_GENERIC} ${LIBBOINC_SOURCES_APPLE})

    set(LIBBOINCAPI_SOURCES ${LIBBOINCAPI_SOURCES_GENERIC})
elseif(WIN32)
    set(LIBBOINC_HEADERS ${LIBBOINC_HEADERS_GENERIC} ${LIBBOINC_HEADERS_WIN})
    set(LIBBOINC_SOURCES ${LIBBOINC_SOURCES_GENERIC} ${LIBBOINC_SOURCES_WIN})

    set(LIBBOINCAPI_SOURCES ${LIBBOINCAPI_SOURCES_GENERIC} ${LIBBOINCAPI_SOURCES_WIN})
elseif(UNIX)
    set(LIBBOINC_HEADERS ${LIBBOINC_HEADERS_GENERIC} ${LIBBOINC_HEADERS_UNIX})
    set(LIBBOINC_SOURCES ${LIBBOINC_SOURCES_GENERIC} ${LIBBOINC_SOURCES_UNIX})

    set(LIBBOINCAPI_SOURCES ${LIBBOINCAPI_SOURCES_GENERIC})
endif()

add_library(boinc ${LIBBOINC_SOURCES})
add_library(boincapi ${LIBBOINCAPI_SOURCES})

if(WIN32 OR APPLE)
    set_target_properties(boinc PROPERTIES PREFIX "lib")
    set_target_properties(boinc PROPERTIES IMPORT_PREFIX "lib")

    set_target_properties(boincapi PROPERTIES PREFIX "lib")
    set_target_properties(boincapi PROPERTIES IMPORT_PREFIX "lib")
endif()

if(APPLE)
    target_include_directories(boinc PUBLIC
                                $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/lib/mac>
                                $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/clientgui/mac>
    )

    target_include_directories(boincapi PUBLIC
                                $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/lib/mac>
                                $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/clientgui/mac>
    )
elseif(WIN32)
    target_compile_definitions(boinc PUBLIC
                                -D_CRT_SECURE_NO_WARNINGS
                                -DWIN32
                                -D_CONSOLE
    )

    target_compile_definitions(boincapi PUBLIC
                                -D_CRT_SECURE_NO_WARNINGS
                                -DWIN32
                                -D_CONSOLE
    )

    target_include_directories(boinc PUBLIC
                                $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/win_build>
    )

    target_include_directories(boincapi PUBLIC
                                $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/win_build>
    )
elseif(UNIX)
    target_include_directories(boinc PUBLIC
                                $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/config-h-${CMAKE_BUILD_TYPE}>
    )

    target_include_directories(boincapi PUBLIC
                                $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/config-h-${CMAKE_BUILD_TYPE}>
    )
endif()

target_include_directories(boinc PUBLIC
                            $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
                            $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/lib>
                            $<INSTALL_INTERFACE:include>
)

target_include_directories(boincapi PUBLIC
                            $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
                            $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/lib>
                            $<INSTALL_INTERFACE:include>
)

target_link_libraries(boinc PRIVATE
                        OpenSSL::SSL
                        OpenSSL::Crypto
)

install(TARGETS boinc boincapi EXPORT boinc-config
            RUNTIME DESTINATION bin
            ARCHIVE DESTINATION lib
            LIBRARY DESTINATION lib
        )

install(FILES ${LIBBOINC_HEADERS} ${LIBBOINCAPI_HEADERS} DESTINATION include/boinc)
install(EXPORT boinc-config NAMESPACE unofficial::boinc:: DESTINATION share/boinc)
