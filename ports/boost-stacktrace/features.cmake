    # BOOST_STACKTRACE_ENABLE_NOOP

    # When ON, builds the boost_stacktrace_noop library variant. Defaults to ON.

    # BOOST_STACKTRACE_ENABLE_BACKTRACE

    # When ON, builds the boost_stacktrace_backtrace library variant. Defaults to ON when libbacktrace is found, OFF otherwise.

    # BOOST_STACKTRACE_ENABLE_ADDR2LINE

    # When ON, builds the boost_stacktrace_addr2line library variant. Defaults to ON, except on Windows.

    # BOOST_STACKTRACE_ENABLE_BASIC

    # When ON, builds the boost_stacktrace_basic library variant. Defaults to ON.

    # BOOST_STACKTRACE_ENABLE_WINDBG

    # When ON, builds the boost_stacktrace_windbg library variant. Defaults to ON under Windows when WinDbg support is autodetected, otherwise OFF.

    # BOOST_STACKTRACE_ENABLE_WINDBG_CACHED

    # When ON, builds the boost_stacktrace_windbg_cached library variant. Defaults to ON under Windows when WinDbg support is autodetected and when thread_local is supported, otherwise OFF.

vcpkg_check_features(
  OUT_FEATURE_OPTIONS
    FEATURE_OPTIONS
  FEATURES
    "backtrace" BOOST_STACKTRACE_ENABLE_BACKTRACE
    "windbg"    BOOST_STACKTRACE_ENABLE_WINDBG
)
