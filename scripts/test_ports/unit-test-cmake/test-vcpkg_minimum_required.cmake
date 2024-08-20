# -- error cases --
# VCPKG_BASE_VERSION not set - vcpkg version is too old
set(VCPKG_BASE_VERSION_backup "${VCPKG_BASE_VERSION}")
unset(VCPKG_BASE_VERSION)
unset(VCPKG_BASE_VERSION CACHE)
unit_test_ensure_fatal_error([[vcpkg_minimum_required(VERSION 2021-01-01)]])
unit_test_ensure_fatal_error([[vcpkg_minimum_required()]])
unit_test_ensure_fatal_error([[vcpkg_minimum_required(VERSION "")]])
unit_test_ensure_fatal_error([[vcpkg_minimum_required(VERSION "2021.01.01")]])

set(VCPKG_BASE_VERSION 2021-02-02)

# VERSION not passed
unit_test_ensure_fatal_error([[vcpkg_minimum_required()]])
# VERSION weird - empty
unit_test_ensure_fatal_error([[vcpkg_minimum_required(VERSION "")]])
# VERSION weird - dotted
unit_test_ensure_fatal_error([[vcpkg_minimum_required(VERSION 2021.01.01)]])
# VERSION weird - not a valid year
unit_test_ensure_fatal_error([[vcpkg_minimum_required(VERSION 3000-01-01)]])
# VERSION weird  - list
unit_test_ensure_fatal_error([[vcpkg_minimum_required(VERSION "2021-01-01;2021-01-02")]])
# VERSION weird  - small year
unit_test_ensure_fatal_error([[vcpkg_minimum_required(VERSION 21-01-01)]])
# VERSION weird  - small month
unit_test_ensure_fatal_error([[vcpkg_minimum_required(VERSION 2021-1-01)]])
# VERSION weird  - small day
unit_test_ensure_fatal_error([[vcpkg_minimum_required(VERSION 2021-01-1)]])
# VERSION too-new - later year, earlier month, earlier day
unit_test_ensure_fatal_error([[vcpkg_minimum_required(VERSION 2022-01-01)]])
# VERSION too-new - same year, later month, earlier day
unit_test_ensure_fatal_error([[vcpkg_minimum_required(VERSION 2021-03-01)]])
# VERSION too-new - same year, same month, later day
unit_test_ensure_fatal_error([[vcpkg_minimum_required(VERSION 2021-02-03)]])

# -- successes --
# same date
unit_test_ensure_success([[vcpkg_minimum_required(VERSION 2021-02-02)]])

# VERSION old - earlier year, later month, later day
unit_test_ensure_success([[vcpkg_minimum_required(VERSION 2020-03-03)]])
# VERSION old - same year, earlier month, later day
unit_test_ensure_success([[vcpkg_minimum_required(VERSION 2021-01-03)]])
# VERSION old - same year, same month, earlier day
unit_test_ensure_success([[vcpkg_minimum_required(VERSION 2021-02-01)]])

# reset to backup
unset(VCPKG_BASE_VERSION)
set(VCPKG_BASE_VERSION "${VCPKG_BASE_VERSION_backup}" CACHE STRING "")
