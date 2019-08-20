cmake_minimum_required (VERSION 2.8.12)

# nsync provides portable synchronization primitives, such as mutexes and
# condition variables.

if ("${CMAKE_MAJOR_VERSION}X" STREQUAL "2X")
	project (nsync)
else ()
	# fetch from VERSION file in root
	file (STRINGS VERSION VERSION_STRING)

	cmake_policy(SET CMP0048 NEW) # remove when min ver >=3

	project (nsync
		VERSION "${VERSION_STRING}")
endif ()

# Some builds need position-independent code.
set (CMAKE_POSITION_INDEPENDENT_CODE ON)

# Allow nsync users to turn the tests on or off.
option (NSYNC_ENABLE_TESTS "Enable for building tests" ON)

# -----------------------------------------------------------------
# Functions to set common options on targets and files.
# Should be called on all targets.
function (set_c_target tgtname files)
	if ("${CMAKE_SYSTEM_NAME}X" STREQUAL "LinuxX")
		target_include_directories ("${tgtname}" BEFORE PRIVATE
			"${PROJECT_SOURCE_DIR}/platform/linux"
		)
	endif ()
endfunction (set_c_target)

function (set_cpp_target tgtname files)
	target_include_directories ("${tgtname}" BEFORE PRIVATE
		"${PROJECT_SOURCE_DIR}/platform/c++11"
	)

	if ("${CMAKE_SYSTEM_NAME}X" STREQUAL "LinuxX")
		target_include_directories ("${tgtname}" BEFORE PRIVATE
			"${PROJECT_SOURCE_DIR}/platform/c++11.futex"
		)
	endif ()

	target_compile_definitions ("${tgtname}" PRIVATE "${NSYNC_CPP_DEFINITIONS}")

	foreach (s IN ITEMS ${files})
		set_source_files_properties ("${s}"
			PROPERTIES LANGUAGE CXX
			COMPILE_FLAGS "${NSYNC_CPP_FLAGS}")
	endforeach (s)
endfunction (set_cpp_target)

# -----------------------------------------------------------------
# Platform dependencies

# Many platforms use these posix related sources; even Win32.
set (NSYNC_POSIX_SRC
	"platform/posix/src/nsync_panic.c"
	"platform/posix/src/per_thread_waiter.c"
	"platform/posix/src/time_rep.c"
	"platform/posix/src/yield.c"
)

set (NSYNC_CPP_DEFINITIONS NSYNC_USE_CPP11_TIMEPOINT NSYNC_ATOMIC_CPP11)
set (NSYNC_OS_CPP_SRC
	# Avoid use of the C++11 version of per_thread_waiter.  It behaves
	# badly if multiple copies of nsync are linked into an address space.
	"platform/posix/src/per_thread_waiter.c"
	"platform/c++11/src/yield.cc"
	"platform/c++11/src/time_rep_timespec.cc"
	"platform/c++11/src/nsync_panic.cc"
)

# Many of the string matches below use a literal "X" suffix on both sides.
# This is because some versions of cmake treat (for example) "MSVC" (in quotes)
# as a reference to the variable MSVC, thus the expression
#      "${CMAKE_C_COMPILER_ID}" STREQUAL "MSVC"
# is false when ${CMAKE_C_COMPILER_ID} has the value "MSVC"!  See
#    https://cmake.org/cmake/help/v3.1/policy/CMP0054.html

# Pick the include directory for the operating system.
if ("${CMAKE_SYSTEM_NAME}X" STREQUAL "WindowsX")
	include_directories ("${PROJECT_SOURCE_DIR}/platform/win32")
	set (NSYNC_CPP_FLAGS "/TP")

	set (NSYNC_OS_SRC
		${NSYNC_POSIX_SRC}
		"platform/win32/src/clock_gettime.c"
		"platform/win32/src/init_callback_win32.c"
		"platform/win32/src/nanosleep.c"
		"platform/win32/src/nsync_semaphore_win32.c"
		"platform/win32/src/pthread_cond_timedwait_win32.c"
		"platform/win32/src/pthread_key_win32.cc"
	)
	set (NSYNC_OS_CPP_SRC
		${NSYNC_OS_CPP_SRC}
		"platform/c++11/src/nsync_semaphore_mutex.cc"
		"platform/win32/src/clock_gettime.c"
		"platform/win32/src/pthread_key_win32.cc"
	)
	set (NSYNC_TEST_OS_SRC
		"platform/win32/src/start_thread.c"
	)

	# Suppress warnings to reduce build log size.
	add_definitions (/wd4057 /wd4100 /wd4152 /wd4242 /wd4244 /wd4255 /wd4267)
	add_definitions (/wd4365 /wd4389 /wd4458 /wd4571 /wd4625 /wd4626 /wd4668)
	add_definitions (/wd4702 /wd4710 /wd4774 /wd4820 /wd5026 /wd5027 /wd5039)
	add_definitions (/wd5045)
elseif ("${CMAKE_SYSTEM_NAME}X" STREQUAL "DarwinX")
	include_directories ("${PROJECT_SOURCE_DIR}/platform/macos")
	# Some versions of MacOS, such as Sierra, require _DARWIN_C_SOURCE
	# when including certin C++ standard header files, such as <mutex>.
	set (NSYNC_CPP_DEFINITIONS ${NSYNC_CPP_DEFINITIONS} _DARWIN_C_SOURCE)
	set (NSYNC_POSIX ON)

	set (NSYNC_OS_EXTRA_SRC
		"platform/posix/src/clock_gettime.c"
		"platform/posix/src/nsync_semaphore_mutex.c"
	)
	set (NSYNC_OS_CPP_SRC
		${NSYNC_OS_CPP_SRC}
		"platform/c++11/src/nsync_semaphore_mutex.cc"
		"platform/posix/src/clock_gettime.c"
		"platform/posix/src/nsync_semaphore_mutex.c"
	)
elseif ("${CMAKE_SYSTEM_NAME}X" STREQUAL "LinuxX")
	set (NSYNC_POSIX ON)

	set (NSYNC_OS_EXTRA_SRC
		"platform/linux/src/nsync_semaphore_futex.c"
	)
	set (NSYNC_OS_CPP_SRC
		"platform/linux/src/nsync_semaphore_futex.c"
		${NSYNC_OS_CPP_SRC}
	)
elseif ("${CMAKE_SYSTEM_NAME}X" STREQUAL "NetBSDX")
	include_directories ("${PROJECT_SOURCE_DIR}/platform/netbsd")
	set (NSYNC_POSIX ON)

	set (NSYNC_OS_EXTRA_SRC
		"platform/posix/src/nsync_semaphore_mutex.c"
	)
	set (NSYNC_OS_CPP_SRC
		"platform/c++11/src/nsync_semaphore_mutex.cc"
		${NSYNC_OS_CPP_SRC}
	)
elseif ("${CMAKE_SYSTEM_NAME}X" STREQUAL "FreeBSDX")
	include_directories ("${PROJECT_SOURCE_DIR}/platform/freebsd")
	set (NSYNC_POSIX ON)

	set (NSYNC_OS_EXTRA_SRC
		"platform/posix/src/nsync_semaphore_mutex.c"
	)
	set (NSYNC_OS_CPP_SRC
		"platform/c++11/src/nsync_semaphore_mutex.cc"
		${NSYNC_OS_CPP_SRC}
	)
elseif ("${CMAKE_SYSTEM_NAME}X" STREQUAL "OpenBSDX")
	include_directories ("${PROJECT_SOURCE_DIR}/platform/openbsd")
	set (NSYNC_POSIX ON)

	set (NSYNC_OS_EXTRA_SRC
		"platform/posix/src/nsync_semaphore_mutex.c"
	)
	set (NSYNC_OS_CPP_SRC
		"platform/c++11/src/nsync_semaphore_mutex.cc"
		${NSYNC_OS_CPP_SRC}
	)
else ()
	set (NSYNC_POSIX ON)

	set (NSYNC_OS_EXTRA_SRC
		"platform/posix/src/nsync_semaphore_mutex.c"
	)
	set (NSYNC_OS_CPP_SRC
		"platform/c++11/src/nsync_semaphore_mutex.cc"
		${NSYNC_OS_CPP_SRC}
	)
endif ()

# Pick the include directory for the compiler.
if ("${CMAKE_C_COMPILER_ID}X" STREQUAL "GNUX")
	include_directories ("${PROJECT_SOURCE_DIR}/platform/gcc")
	set (THREADS_HAVE_PTHREAD_ARG ON)
elseif ("${CMAKE_C_COMPILER_ID}X" STREQUAL "ClangX")
	include_directories ("${PROJECT_SOURCE_DIR}/platform/clang")
	set (THREADS_HAVE_PTHREAD_ARG ON)
elseif ("${CMAKE_C_COMPILER_ID}X" STREQUAL "MSVCX")
	include_directories ("${PROJECT_SOURCE_DIR}/platform/msvc")
else ()
	message (WARNING "CMAKE_C_COMPILER_ID (${CMAKE_C_COMPILER_ID}) matched NOTHING")
endif ()

if (NSYNC_POSIX)
	include_directories ("${PROJECT_SOURCE_DIR}/platform/posix")
	set (NSYNC_CPP_FLAGS "-std=c++11")

	set (NSYNC_OS_SRC
		${NSYNC_POSIX_SRC}
		${NSYNC_OS_EXTRA_SRC}
	)
	set (NSYNC_TEST_OS_SRC
		"platform/posix/src/start_thread.c"
	)
endif ()

# Pick the include directory for the architecture.
if (("${CMAKE_SYSTEM_PROCESSOR}X" STREQUAL "x86_64X") OR
    ("${CMAKE_SYSTEM_PROCESSOR}X" STREQUAL "amd64X") OR
    ("${CMAKE_SYSTEM_PROCESSOR}X" STREQUAL "AMD64X"))
	include_directories ("${PROJECT_SOURCE_DIR}/platform/x86_64")
elseif (("${CMAKE_SYSTEM_PROCESSOR}X" STREQUAL "x86_32X") OR
	("${CMAKE_SYSTEM_PROCESSOR}X" STREQUAL "i386X") OR
        ("${CMAKE_SYSTEM_PROCESSOR}X" STREQUAL "i686X"))
	include_directories ("${PROJECT_SOURCE_DIR}/platform/x86_32")
elseif (("${CMAKE_SYSTEM_PROCESSOR}X" STREQUAL "armv6lX") OR
	("${CMAKE_SYSTEM_PROCESSOR}X" STREQUAL "armv7lX") OR
	("${CMAKE_SYSTEM_PROCESSOR}X" STREQUAL "armX"))
	include_directories ("${PROJECT_SOURCE_DIR}/platform/arm")
elseif (("${CMAKE_SYSTEM_PROCESSOR}X" STREQUAL "aarch64X") OR
	("${CMAKE_SYSTEM_PROCESSOR}X" STREQUAL "arm64X"))
	include_directories ("${PROJECT_SOURCE_DIR}/platform/aarch64")
elseif (("${CMAKE_SYSTEM_PROCESSOR}X" STREQUAL "ppcX") OR
	("${CMAKE_SYSTEM_PROCESSOR}X" STREQUAL "ppc32X"))
	include_directories ("${PROJECT_SOURCE_DIR}/platform/ppc32")
elseif (("${CMAKE_SYSTEM_PROCESSOR}X" STREQUAL "ppc64X"))
	include_directories ("${PROJECT_SOURCE_DIR}/platform/ppc64")
endif ()

# Windows uses some include files from the posix directory also.
if ("${CMAKE_SYSTEM_NAME}X" STREQUAL "WindowsX")
	include_directories ("${PROJECT_SOURCE_DIR}/platform/posix")
endif ()

# -----------------------------------------------------------------

include_directories ("${PROJECT_SOURCE_DIR}/public")
include_directories ("${PROJECT_SOURCE_DIR}/internal")

include (GNUInstallDirs)

set (NSYNC_COMMON_SRC
	"internal/common.c"
	"internal/counter.c"
	"internal/cv.c"
	"internal/debug.c"
	"internal/dll.c"
	"internal/mu.c"
	"internal/mu_wait.c"
	"internal/note.c"
	"internal/once.c"
	"internal/sem_wait.c"
	"internal/time_internal.c"
	"internal/wait.c"
)

add_library (nsync ${NSYNC_COMMON_SRC} ${NSYNC_OS_SRC})
set_target_properties (nsync PROPERTIES
	VERSION ${PROJECT_VERSION}
	SOVERSION ${PROJECT_VERSION_MAJOR})

set_c_target (nsync "${NSYNC_COMMON_SRC} ${NSYNC_OS_SRC}")

foreach (s IN ITEMS ${NSYNC_COMMON_SRC} ${NSYNC_OS_CPP_SRC})
	# The C and C++ libraries are built from the same source files but
	# compiled with either the C or C++ compiler. CMake normally detects
	# the filetype based on the extension so we need to override LANGUAGE
	# manually. A custom command first copies the source files (only if
	# changed) so the LANGUAGE property does not conflict.
	add_custom_command (
		OUTPUT cpp/${s}
		COMMAND ${CMAKE_COMMAND} -E copy_if_different ${PROJECT_SOURCE_DIR}/${s} cpp/${s}
		DEPENDS ${PROJECT_SOURCE_DIR}/${s}
	)

	set (NSYNC_CPP_SRC_COPY ${NSYNC_CPP_SRC_COPY}
		cpp/${s}
	)
endforeach (s)

add_library (nsync_cpp ${NSYNC_CPP_SRC_COPY})
set_target_properties (nsync_cpp PROPERTIES
	VERSION ${PROJECT_VERSION}
	SOVERSION ${PROJECT_VERSION_MAJOR})

set_cpp_target (nsync_cpp "${NSYNC_CPP_SRC_COPY}")


if (NSYNC_ENABLE_TESTS)
	set (NSYNC_TEST_SRC
		"testing/array.c"
		"testing/atm_log.c"
		"testing/closure.c"
		"testing/smprintf.c"
		"testing/testing.c"
		"testing/time_extra.c"
		${NSYNC_TEST_OS_SRC}
	)
	add_library (nsync_test ${NSYNC_TEST_SRC})
	set_target_properties (nsync_test PROPERTIES
		VERSION ${PROJECT_VERSION}
		SOVERSION ${PROJECT_VERSION_MAJOR})

	set_c_target (nsync_test "${NSYNC_TEST_SRC}")
	target_include_directories (nsync_test PUBLIC
		"${PROJECT_SOURCE_DIR}/testing"
	)

	foreach (t IN ITEMS ${NSYNC_TEST_SRC})
		add_custom_command (
			OUTPUT cpp/${t}
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${PROJECT_SOURCE_DIR}/${t} cpp/${t}
			DEPENDS ${PROJECT_SOURCE_DIR}/${t}
		)

		set (NSYNC_TEST_CPP_SRC "${NSYNC_TEST_CPP_SRC}"
			"cpp/${t}"
		)
	endforeach (t)

	add_library (nsync_test_cpp ${NSYNC_TEST_CPP_SRC})
	set_target_properties (nsync_test_cpp PROPERTIES
		VERSION ${PROJECT_VERSION}
		SOVERSION ${PROJECT_VERSION_MAJOR})

	set_cpp_target (nsync_test_cpp "${NSYNC_TEST_CPP_SRC}")
	target_include_directories (nsync_test_cpp PUBLIC
		"${PROJECT_SOURCE_DIR}/testing"
	)

	# Test names should not end with _cpp
	set (NSYNC_TESTS
		"counter_test"
		"cv_mu_timeout_stress_test"
		"cv_test"
		"cv_wait_example_test"
		"dll_test"
		"mu_starvation_test"
		"mu_test"
		"mu_wait_example_test"
		"mu_wait_test"
		"note_test"
		"once_test"
		"pingpong_test"
		"wait_test"
	)

	enable_testing ()

	# Test targets to only run C or C++ tests
	add_custom_target(test_c COMMAND ${CMAKE_CTEST_COMMAND} -E '_cpp$$')
	add_custom_target(test_cpp COMMAND ${CMAKE_CTEST_COMMAND} -R '_cpp$$')

	foreach (t IN ITEMS ${NSYNC_TESTS})
		add_executable (${t} "testing/${t}.c")
		set_c_target (${t} "testing/${t}.c")
		target_include_directories (${t} PUBLIC
			"${PROJECT_SOURCE_DIR}/testing"
		)
		target_link_libraries (${t} nsync_test nsync)
		add_test (NAME ${t} COMMAND ${t})
		add_dependencies (test_c ${t})

		add_custom_command (
			OUTPUT cpp/testing/${t}.c
			COMMAND ${CMAKE_COMMAND} -E copy_if_different ${PROJECT_SOURCE_DIR}/testing/${t}.c cpp/testing/${t}.c
			DEPENDS ${PROJECT_SOURCE_DIR}/testing/${t}.c
		)

		set (NSYNC_TEST_CPP_SRC ${NSYNC_TEST_CPP_SRC}
			cpp/testing/${t}.c
		)
		add_executable (${t}_cpp "cpp/testing/${t}.c")
		set_cpp_target (${t}_cpp "cpp/testing/${t}.c")
		target_include_directories (${t}_cpp PUBLIC
			"${PROJECT_SOURCE_DIR}/testing"
		)
		target_link_libraries (${t}_cpp nsync_test_cpp nsync_cpp)
		add_test (NAME ${t}_cpp COMMAND ${t}_cpp)
		add_dependencies (test_cpp ${t}_cpp)
	endforeach (t)

	find_package (Threads REQUIRED)
	set (THREADS_PREFER_PTHREAD_FLAG ON)
	foreach (t IN ITEMS "nsync" "nsync_test" ${NSYNC_TESTS})
		if (THREADS_HAVE_PTHREAD_ARG)
			target_compile_options (${t} PUBLIC "-pthread")
			target_compile_options (${t}_cpp PUBLIC "-pthread")
		endif ()
		if (CMAKE_THREAD_LIBS_INIT)
			target_link_libraries (${t} "${CMAKE_THREAD_LIBS_INIT}")
			target_link_libraries (${t}_cpp "${CMAKE_THREAD_LIBS_INIT}")
		endif ()
	endforeach (t)
endif ()

if(WIN32 AND NOT VCPKG_TARGET_TRIPLET STREQUAL "x64-windows-static")
    set (CMAKE_SKIP_INSTALL_ALL_DEPENDENCY ON)
endif()

install (TARGETS nsync
	LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT RuntimeLibraries
	ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Development)

install (TARGETS nsync_cpp OPTIONAL
	LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT RuntimeLibraries
	ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT Development)

set (NSYNC_INCLUDES
	"public/nsync.h"
	"public/nsync_atomic.h"
	"public/nsync_counter.h"
	"public/nsync_cpp.h"
	"public/nsync_cv.h"
	"public/nsync_debug.h"
	"public/nsync_mu.h"
	"public/nsync_mu_wait.h"
	"public/nsync_note.h"
	"public/nsync_once.h"
	"public/nsync_time.h"
	"public/nsync_time_internal.h"
	"public/nsync_waiter.h"
)

foreach (NSYNC_INCLUDE ${NSYNC_INCLUDES})
	install (FILES ${NSYNC_INCLUDE}
		DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
		COMPONENT Development)
endforeach ()