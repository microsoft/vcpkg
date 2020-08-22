if(VCPKG_TARGET_IS_WINDOWS)
    if("icu" IN_LIST FEATURES)
        set(BOOST_LOCALE_ICU on)
    else()
        set(BOOST_LOCALE_ICU off)
    endif()

    list(APPEND B2_OPTIONS
        boost.locale.iconv=off
        boost.locale.posix=off
        /boost/locale//boost_locale
        boost.locale.icu=${BOOST_LOCALE_ICU}
    )
else()
    find_library(LIBICONV_LIBRARY iconv)
    get_filename_component(LIBICONV_DIR "${LIBICONV_LIBRARY}" DIRECTORY)

    list(APPEND B2_OPTIONS
        boost.locale.iconv=on
        boost.locale.posix=on
        /boost/locale//boost_locale
        boost.locale.icu=off
        -sICONV_PATH=${LIBICONV_DIR}
    )
endif()