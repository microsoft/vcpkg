cmake_minimum_required(VERSION 3.5)

project(gperftools LANGUAGES C CXX)

include(GNUInstallDirs)

option(GPERFTOOLS_BUILD_TOOLS "Build tools" ON)

if(WIN32) # TODO: MINGW, MSYS
    option(GPERFTOOLS_WIN32_OVERRIDE "Override allocators" OFF)
endif()

set(deprecated_public_headers
    src/google/heap-checker.h
    src/google/heap-profiler.h
    src/google/malloc_extension.h
    src/google/malloc_extension_c.h
    src/google/malloc_hook.h
    src/google/malloc_hook_c.h
    src/google/profiler.h
    src/google/stacktrace.h
)

set(gperftools_public_headers
    src/gperftools/heap-checker.h
    src/gperftools/heap-profiler.h
    src/gperftools/malloc_extension.h
    src/gperftools/malloc_extension_c.h
    src/gperftools/malloc_hook.h
    src/gperftools/malloc_hook_c.h
    src/gperftools/nallocx.h
    src/gperftools/profiler.h
    src/gperftools/stacktrace.h
)

if(WIN32) # TODO: MINGW, MSYS
    list(APPEND deprecated_public_headers
        src/windows/google/tcmalloc.h
    )

    list(APPEND gperftools_public_headers
        src/windows/gperftools/tcmalloc.h
    )

    set(libtcmalloc_minimal_headers
        src/addressmap-inl.h
        src/base/arm_instruction_set_select.h
        src/base/atomicops-internals-arm-generic.h
        src/base/atomicops-internals-arm-v6plus.h
        src/base/atomicops-internals-gcc.h
        src/base/atomicops-internals-linuxppc.h
        src/base/atomicops-internals-macosx.h
        src/base/atomicops-internals-mips.h
        src/base/atomicops-internals-windows.h
        src/base/atomicops-internals-x86.h
        src/base/atomicops.h
        src/base/basictypes.h
        src/base/commandlineflags.h
        src/base/googleinit.h
        src/base/logging.h
        src/base/low_level_alloc.h
        src/base/spinlock.h
        src/base/spinlock_internal.h
        src/base/spinlock_linux-inl.h
        src/base/spinlock_posix-inl.h
        src/base/spinlock_win32-inl.h
        src/base/stl_allocator.h
        src/base/sysinfo.h
        src/base/thread_annotations.h
        src/central_freelist.h
        src/common.h
        src/gperftools/heap-checker.h
        src/gperftools/heap-profiler.h
        src/gperftools/malloc_extension.h
        src/gperftools/malloc_hook.h
        src/gperftools/profiler.h
        src/gperftools/stacktrace.h
        src/heap-profile-table.h
        src/internal_logging.h
        src/malloc_hook-inl.h
        src/memory_region_map.h
        src/packed-cache-inl.h
        src/pagemap.h
        src/page_heap.h
        src/page_heap_allocator.h
        src/raw_printer.h
        src/sampler.h
        src/span.h
        src/stacktrace_win32-inl.h
        src/stack_trace_table.h
        src/static_vars.h
        src/symbolize.h
        src/system-alloc.h
        src/tcmalloc.h
        src/thread_cache.h
        src/windows/config.h
        src/windows/mini_disassembler.h
        src/windows/mini_disassembler_types.h
        src/windows/port.h
        src/windows/preamble_patcher.h
    )

    set(libtcmalloc_minimal_sources
        src/base/dynamic_annotations.c
        src/base/logging.cc
        src/base/low_level_alloc.cc
        src/base/spinlock.cc
        src/base/spinlock_internal.cc
        src/base/sysinfo.cc
        src/central_freelist.cc
        src/common.cc
        src/fake_stacktrace_scope.cc
        src/heap-profile-table.cc
        src/internal_logging.cc
        src/malloc_extension.cc
        src/malloc_hook.cc
        src/memory_region_map.cc
        src/page_heap.cc
        src/raw_printer.cc
        src/sampler.cc
        src/span.cc
        src/stacktrace.cc
        src/stack_trace_table.cc
        src/static_vars.cc
        src/symbolize.cc
        src/thread_cache.cc
        src/windows/ia32_modrm_map.cc
        src/windows/ia32_opcode_map.cc
        src/windows/mini_disassembler.cc
        src/windows/port.cc
        src/windows/preamble_patcher.cc
        src/windows/preamble_patcher_with_stub.cc
        src/windows/system-alloc.cc
    )

    if(GPERFTOOLS_WIN32_OVERRIDE)
        list(APPEND libtcmalloc_minimal_sources src/windows/override_functions.cc)
    else()
        list(APPEND libtcmalloc_minimal_sources src/windows/patch_functions.cc)
    endif()

    set_property(GLOBAL PROPERTY USE_FOLDERS ON)
    source_group("Header Files" FILES ${libtcmalloc_minimal_headers})
    source_group("Source Files" FILES ${libtcmalloc_minimal_sources})

    if(GPERFTOOLS_WIN32_OVERRIDE)
        add_library(libtcmalloc_minimal
            STATIC
            ${libtcmalloc_minimal_headers}
            ${libtcmalloc_minimal_sources}
        )
    else()
        add_library(libtcmalloc_minimal
            ${libtcmalloc_minimal_headers}
            ${libtcmalloc_minimal_sources}
        )
    endif()

    target_compile_definitions(
        libtcmalloc_minimal
        PRIVATE
            $<$<BOOL:${GPERFTOOLS_WIN32_OVERRIDE}>:
                WIN32_OVERRIDE_ALLOCATORS
                PERFTOOLS_DLL_DECL=
            >
    )

    target_compile_options(
        libtcmalloc_minimal
        PRIVATE
            $<$<CXX_COMPILER_ID:MSVC>:
                /wd4141
                /wd4251
            >
    )

    target_include_directories(
        libtcmalloc_minimal
        PUBLIC
            $<BUILD_INTERFACE:
                ${CMAKE_CURRENT_LIST_DIR}/src
                ${CMAKE_CURRENT_LIST_DIR}/src/windows
            >
    )

    install(FILES ${deprecated_public_headers}
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/google
    )

    install(FILES ${gperftools_public_headers}
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/gperftools
    )

    install(TARGETS libtcmalloc_minimal
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

    if(GPERFTOOLS_BUILD_TOOLS)
        add_executable(addr2line-pdb src/windows/addr2line-pdb.c)
        target_link_libraries(addr2line-pdb PRIVATE DbgHelp)

        add_executable(nm-pdb src/windows/nm-pdb.c)
        target_link_libraries(nm-pdb PRIVATE DbgHelp)

        install(TARGETS addr2line-pdb nm-pdb DESTINATION ${CMAKE_INSTALL_BINDIR})
    endif()
else()
endif()
