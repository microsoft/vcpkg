vcpkg_check_features(
  OUT_FEATURE_OPTIONS
    FEATURE_OPTIONS
  FEATURES
    "icu"    BOOST_LOCALE_ENABLE_ICU
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(BOOST_LOCALE_ENABLE_ICONV off)
    set(BOOST_LOCALE_ENABLE_POSIX off)
else()
    set(BOOST_LOCALE_ENABLE_ICONV on)
    if(VCPKG_TARGET_IS_ANDROID)
        set(BOOST_LOCALE_ENABLE_POSIX off)
    else()
        set(BOOST_LOCALE_ENABLE_POSIX on)
    endif()
endif()

list(APPEND FEATURE_OPTIONS 
  -DBOOST_LOCALE_ENABLE_ICONV=${BOOST_LOCALE_ENABLE_ICONV}
  -DBOOST_LOCALE_ENABLE_POSIX=${BOOST_LOCALE_ENABLE_POSIX}
  )


    # BOOST_LOCALE_ENABLE_ICU

    # When ON, enables the ICU backend. Defaults to ON when ICU is found, OFF otherwise.

    # BOOST_LOCALE_ENABLE_ICONV

    # When ON, enables the Iconv backend. Defaults to ON when iconv is found, OFF otherwise.

    # BOOST_LOCALE_ENABLE_POSIX

    # When ON, enables the POSIX backend. Defaults to ON on POSIX systems, OFF otherwise.

    # BOOST_LOCALE_ENABLE_STD

    # When ON, enables the std::locale backend. Defaults to ON.

    # BOOST_LOCALE_ENABLE_WINAPI

    # When ON, enables the Windows API backend. Defaults to ON under Windows, OFF otherwise.
