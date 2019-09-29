
# boost-context removed all.hpp, which is used by FindBoost to determine that context is installed
if(NOT EXISTS ${CURRENT_PACKAGES_DIR}/include/boost/context/all.hpp)
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/boost/context/all.hpp
        "#error \"#include <boost/context/all.hpp> is no longer supported by boost_context.\"")
endif()
