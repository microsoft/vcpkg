# vcpkg_list(SET <list> <elements>...)
unit_test_check_variable_equal(
    [[vcpkg_list(SET lst)]]
    lst ""
)
unit_test_check_variable_equal(
    [[vcpkg_list(SET lst "")]]
    lst ""
)
unit_test_check_variable_equal(
    [[vcpkg_list(SET lst "" "")]]
    lst ";"
)
unit_test_check_variable_equal(
    [[vcpkg_list(SET lst a)]]
    lst "a"
)
unit_test_check_variable_equal(
    [[vcpkg_list(SET lst a b)]]
    lst "a;b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(SET lst "a;b")]]
    lst [[a\;b]]
)
unit_test_check_variable_equal(
    [=[vcpkg_list(SET lst "a;b" "c" [[d\;e]])]=]
    lst [[a\;b;c;d\\;e]]
)

# vcpkg_list(LENGTH <list> <out-var>)
set(lst [[]])
unit_test_check_variable_equal(
    [[vcpkg_list(LENGTH lst out)]]
    out 0
)
set(lst [[;]])
unit_test_check_variable_equal(
    [[vcpkg_list(LENGTH lst out)]]
    out 2
)
set(lst [[a]])
unit_test_check_variable_equal(
    [[vcpkg_list(LENGTH lst out)]]
    out 1
)
set(lst [[a;b]])
unit_test_check_variable_equal(
    [[vcpkg_list(LENGTH lst out)]]
    out 2
)
set(lst [[a\\;b]])
unit_test_check_variable_equal(
    [[vcpkg_list(LENGTH lst out)]]
    out 1
)
set(lst [[a\;b;c\\;d]])
unit_test_check_variable_equal(
    [[vcpkg_list(LENGTH lst out)]]
    out 2
)

# vcpkg_list(GET <list> <element-index> <out-var>)
set(lst "")
unit_test_ensure_fatal_error([[vcpkg_list(GET lst 0 out)]])

set(lst "a")
unit_test_check_variable_equal(
    [[vcpkg_list(GET lst 0 out)]]
    out "a"
)
unit_test_check_variable_equal(
    [[vcpkg_list(GET lst -1 out)]]
    out "a"
)
unit_test_ensure_fatal_error([[vcpkg_list(GET lst 2 out)]])
unit_test_ensure_fatal_error([[vcpkg_list(GET lst -2 out)]])

set(lst ";b")
unit_test_check_variable_equal(
    [[vcpkg_list(GET lst 0 out)]]
    out ""
)
unit_test_check_variable_equal(
    [[vcpkg_list(GET lst -1 out)]]
    out "b"
)

set(lst "a;b")
unit_test_check_variable_equal(
    [[vcpkg_list(GET lst 0 out)]]
    out "a"
)
unit_test_check_variable_equal(
    [[vcpkg_list(GET lst -1 out)]]
    out "b"
)

set(lst [[a\;b;c]])
unit_test_check_variable_equal(
    [[vcpkg_list(GET lst 0 out)]]
    out "a;b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(GET lst -1 out)]]
    out "c"
)

set(lst [[a;b\;c;d\\;e]])
unit_test_check_variable_equal(
    [[vcpkg_list(GET lst 1 out)]]
    out "b;c"
)
unit_test_check_variable_equal(
    [[vcpkg_list(GET lst -1 out)]]
    out [[d\;e]]
)

# vcpkg_list(JOIN <list> <glue> <out-var>)
set(lst "")
unit_test_check_variable_equal(
    [[vcpkg_list(JOIN lst "-" out)]]
    out ""
)

set(lst "a")
unit_test_check_variable_equal(
    [[vcpkg_list(JOIN lst "-" out)]]
    out "a"
)

set(lst ";")
unit_test_check_variable_equal(
    [[vcpkg_list(JOIN lst "-" out)]]
    out "-"
)

set(lst [[a;b]])
unit_test_check_variable_equal(
    [[vcpkg_list(JOIN lst "-" out)]]
    out [[a-b]]
)
unit_test_check_variable_equal(
    [[vcpkg_list(JOIN lst "+" out)]]
    out [[a+b]]
)

set(lst [[a;b\;c\\;d]])
unit_test_check_variable_equal(
    [[vcpkg_list(JOIN lst "-" out)]]
    out [[a-b;c\;d]]
)

# vcpkg_list(SUBLIST <list> <begin> <length> <out-var>)
set(lst "")
unit_test_check_variable_equal(
    [[vcpkg_list(SUBLIST lst 0 0 out)]]
    out ""
)
unit_test_check_variable_equal(
    [[vcpkg_list(SUBLIST lst 0 1 out)]]
    out ""
)
unit_test_ensure_fatal_error([[vcpkg_list(SUBLIST lst 1 0 out)]])

set(lst "a")
unit_test_check_variable_equal(
    [[vcpkg_list(SUBLIST lst 0 0 out)]]
    out ""
)
unit_test_check_variable_equal(
    [[vcpkg_list(SUBLIST lst 0 1 out)]]
    out "a"
)
unit_test_ensure_fatal_error([[vcpkg_list(SUBLIST lst 2 0 out)]])
unit_test_ensure_fatal_error([[vcpkg_list(SUBLIST lst 2 1 out)]])

set(lst ";;")
unit_test_check_variable_equal(
    [[vcpkg_list(SUBLIST lst 0 0 out)]]
    out ""
)
unit_test_check_variable_equal(
    [[vcpkg_list(SUBLIST lst 0 1 out)]]
    out ""
)
unit_test_check_variable_equal(
    [[vcpkg_list(SUBLIST lst 0 2 out)]]
    out ";"
)
unit_test_check_variable_equal(
    [[vcpkg_list(SUBLIST lst 0 3 out)]]
    out ";;"
)

set(lst "a;b;c;d")
unit_test_check_variable_equal(
    [[vcpkg_list(SUBLIST lst 1 2 out)]]
    out "b;c"
)

set(lst [[a\;b;c\;d;e]])
unit_test_check_variable_equal(
    [[vcpkg_list(SUBLIST lst 1 2 out)]]
    out [[c\;d;e]]
)

set(lst [[a\;b;c\\;d;e;f;g;h]])
unit_test_check_variable_equal(
    [[vcpkg_list(SUBLIST lst 1 -1 out)]]
    out [[c\\;d;e;f;g;h]]
)

# vcpkg_list(FIND <list> <value> <out-var>)
set(lst "")
unit_test_check_variable_equal(
    [[vcpkg_list(FIND lst "a" out)]]
    out -1
)

set(lst "b")
unit_test_check_variable_equal(
    [[vcpkg_list(FIND lst "a" out)]]
    out -1
)

set(lst "a;b")
unit_test_check_variable_equal(
    [[vcpkg_list(FIND lst "a" out)]]
    out 0
)
unit_test_check_variable_equal(
    [[vcpkg_list(FIND lst b out)]]
    out 1
)

set(lst ";b")
unit_test_check_variable_equal(
    [[vcpkg_list(FIND lst "" out)]]
    out 0
)
unit_test_check_variable_equal(
    [[vcpkg_list(FIND lst b out)]]
    out 1
)

set(lst [[a\;b;c]])
unit_test_check_variable_equal(
    [[vcpkg_list(FIND lst "a;b" out)]]
    out 0
)
unit_test_check_variable_equal(
    [[vcpkg_list(FIND lst c out)]]
    out 1
)
unit_test_check_variable_equal(
    [[vcpkg_list(FIND lst a out)]]
    out -1
)

set(lst [[a\\;b;c]])
unit_test_check_variable_equal(
    [=[vcpkg_list(FIND lst [[a\;b]] out)]=]
    out 0
)

# vcpkg_list(APPEND <list> [<element>...])
set(lst "")
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst)]]
    lst [[]]
)
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst "")]]
    lst ""
)
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst "" "")]]
    lst ";"
)
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst a)]]
    lst "a"
)

set(lst ";")
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst)]]
    lst ";"
)
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst "")]]
    lst ";;"
)
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst b)]]
    lst ";;b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst "b;c" d)]]
    lst [[;;b\;c;d]]
)

set(lst "a")
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst)]]
    lst "a"
)
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst "")]]
    lst "a;"
)
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst b)]]
    lst "a;b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst "b;c" d)]]
    lst [[a;b\;c;d]]
)

set(lst "a;b")
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst)]]
    lst "a;b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst "")]]
    lst "a;b;"
)
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst c)]]
    lst "a;b;c"
)
unit_test_check_variable_equal(
    [[vcpkg_list(APPEND lst "c;d" e)]]
    lst [[a;b;c\;d;e]]
)
unit_test_check_variable_equal(
    [=[vcpkg_list(APPEND lst [[c\;d]])]=]
    lst [[a;b;c\\;d]]
)

# vcpkg_list(PREPEND <list> [<element>...])
set(lst "")
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst)]]
    lst ""
)
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst "")]]
    lst ""
)
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst "" "")]]
    lst ";"
)
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst a)]]
    lst "a"
)

set(lst ";")
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst)]]
    lst ";"
)
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst "")]]
    lst ";;"
)
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst b)]]
    lst "b;;"
)
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst "b;c" d)]]
    lst [[b\;c;d;;]]
)

set(lst "a")
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst)]]
    lst "a"
)
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst "")]]
    lst ";a"
)
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst b)]]
    lst "b;a"
)
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst "b;c" d)]]
    lst [[b\;c;d;a]]
)

set(lst "a;b")
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst)]]
    lst "a;b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst "")]]
    lst ";a;b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst c)]]
    lst "c;a;b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(PREPEND lst "c;d" e)]]
    lst [[c\;d;e;a;b]]
)
unit_test_check_variable_equal(
    [=[vcpkg_list(PREPEND lst [[c\;d]])]=]
    lst [[c\\;d;a;b]]
)

# list(INSERT <list> <index> [<element>...])
set(lst "")
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst 0)]]
    lst ""
)
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst 0 "")]]
    lst ""
)
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst 0 "" "")]]
    lst ";"
)
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst 0 "a")]]
    lst "a"
)
unit_test_ensure_fatal_error([[vcpkg_list(INSERT lst 1 "")]])
unit_test_ensure_fatal_error([[vcpkg_list(INSERT lst -1 "")]])

set(lst ";")
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst 0)]]
    lst ";"
)
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst 1)]]
    lst ";"
)
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst 1 "")]]
    lst ";;"
)
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst 0 b)]]
    lst "b;;"
)
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst 1 b)]]
    lst ";b;"
)
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst 2 b)]]
    lst ";;b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst -1 "b;c" d)]]
    lst [[;b\;c;d;]]
)
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst -2 "b;c" d)]]
    lst [[b\;c;d;;]]
)
unit_test_ensure_fatal_error([[vcpkg_list(INSERT lst 3 "")]])
unit_test_ensure_fatal_error([[vcpkg_list(INSERT lst -3 "")]])

set(lst "a;b")
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst -1 c)]]
    lst "a;c;b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst 1 c)]]
    lst "a;c;b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst 2 c)]]
    lst "a;b;c"
)
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst -2 c)]]
    lst "c;a;b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(INSERT lst 1 "c;d")]]
    lst [[a;c\;d;b]]
)
unit_test_check_variable_equal(
    [=[vcpkg_list(INSERT lst 1 [[c\;d]] e)]=]
    lst [[a;c\\;d;e;b]]
)

# vcpkg_list(POP_BACK <list>)
set(lst "")
unit_test_check_variable_equal(
    [[vcpkg_list(POP_BACK lst)]]
    lst ""
)

set(lst ";")
unit_test_check_variable_equal(
    [[vcpkg_list(POP_BACK lst)]]
    lst ""
)

set(lst "a;b")
unit_test_check_variable_equal(
    [[vcpkg_list(POP_BACK lst)]]
    lst "a"
)

set(lst "a;;b")
unit_test_check_variable_equal(
    [[vcpkg_list(POP_BACK lst)]]
    lst "a;"
)

set(lst [[a\;b]])
unit_test_check_variable_equal(
    [[vcpkg_list(POP_BACK lst)]]
    lst ""
)

set(lst [[c;a\;b;c]])
unit_test_check_variable_equal(
    [[vcpkg_list(POP_BACK lst)]]
    lst [[c;a\;b]]
)

# vcpkg_list(POP_FRONT <list>)
set(lst "")
unit_test_check_variable_equal(
    [[vcpkg_list(POP_BACK lst)]]
    lst ""
)

set(lst ";")
unit_test_check_variable_equal(
    [[vcpkg_list(POP_FRONT lst)]]
    lst ""
)

set(lst "a;b")
unit_test_check_variable_equal(
    [[vcpkg_list(POP_FRONT lst)]]
    lst "b"
)

set(lst "a;;b")
unit_test_check_variable_equal(
    [[vcpkg_list(POP_FRONT lst)]]
    lst ";b"
)

set(lst [[a\;b]])
unit_test_check_variable_equal(
    [[vcpkg_list(POP_FRONT lst)]]
    lst ""
)

set(lst [[c;a\;b;c]])
unit_test_check_variable_equal(
    [[vcpkg_list(POP_FRONT lst)]]
    lst [[a\;b;c]]
)

# vcpkg_list(REMOVE_DUPLICATES <list>)
set(lst ";")
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_DUPLICATES lst)]]
    lst ""
)

set(lst "a;b")
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_DUPLICATES lst)]]
    lst "a;b"
)

set(lst "a;a;b")
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_DUPLICATES lst)]]
    lst "a;b"
)

set(lst "a;b;a")
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_DUPLICATES lst)]]
    lst "a;b"
)

set(lst "c;a;b;a;c")
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_DUPLICATES lst)]]
    lst "c;a;b"
)

set(lst "a;;b")
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_DUPLICATES lst)]]
    lst "a;;b"
)

set(lst [[a\;b;a\;b]])
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_DUPLICATES lst)]]
    lst [[a\;b]] 
)

set(lst [[c;a\;b;c]])
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_DUPLICATES lst)]]
    lst [[c;a\;b]]
)

# vcpkg_list(REVERSE <list>)
set(lst "")
unit_test_check_variable_equal(
    [[vcpkg_list(REVERSE lst)]]
    lst ""
)
set(lst ";")
unit_test_check_variable_equal(
    [[vcpkg_list(REVERSE lst)]]
    lst ";"
)
set(lst "a;b")
unit_test_check_variable_equal(
    [[vcpkg_list(REVERSE lst)]]
    lst "b;a"
)
set(lst "a;b;c;d;e;f;g")
unit_test_check_variable_equal(
    [[vcpkg_list(REVERSE lst)]]
    lst "g;f;e;d;c;b;a"
)

set(lst [[a\;b;a\;b\\;c]])
unit_test_check_variable_equal(
    [[vcpkg_list(REVERSE lst)]]
    lst [[a\;b\\;c;a\;b]] 
)
set(lst [[c;a\;b]])
unit_test_check_variable_equal(
    [[vcpkg_list(REVERSE lst)]]
    lst [[a\;b;c]]
)

# vcpkg_list(REMOVE_ITEM <list> <value>)
set(lst "")
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_ITEM lst "a")]]
    lst ""
)

set(lst ";")
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_ITEM lst "")]]
    lst ""
)

set(lst "a;b")
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_ITEM lst a)]]
    lst "b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_ITEM lst b)]]
    lst "a"
)

set(lst "a;a;b")
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_ITEM lst a)]]
    lst "b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_ITEM lst b)]]
    lst "a;a"
)

set(lst "a;b;c;a;d")
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_ITEM lst b)]]
    lst "a;c;a;d"
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_ITEM lst a)]]
    lst "b;c;d"
)

set(lst "a;;b")
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_ITEM lst "")]]
    lst "a;b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_ITEM lst a)]]
    lst ";b"
)

set(lst [[e;a\;b;c\;d]])
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_ITEM lst "a;b")]]
    lst [[e;c\;d]] 
)

set(lst [[c;a\;b;c]])
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_ITEM lst "c")]]
    lst [[a\;b]]
)

set(lst [[c;a\\;b;c]])
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_ITEM lst "a\\;b")]]
    lst [[c;c]]
)

# vcpkg_list(REMOVE_AT <list> <index>)
set(lst "")
unit_test_ensure_fatal_error([[vcpkg_list(REMOVE_AT lst 0)]])

set(lst ";")
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst 0)]]
    lst ""
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst 1)]]
    lst ""
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst -1)]]
    lst ""
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst -2)]]
    lst ""
)
unit_test_ensure_fatal_error([[vcpkg_list(REMOVE_AT lst 2)]])
unit_test_ensure_fatal_error([[vcpkg_list(REMOVE_AT lst -3)]])

set(lst "a;b")
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst 0)]]
    lst "b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst 1)]]
    lst "a"
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst -1)]]
    lst "a"
)

set(lst "a;;b")
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst 0)]]
    lst ";b"
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst 1)]]
    lst "a;b"
)

set(lst [[e;a\;b;c\;d]])
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst 0)]]
    lst [[a\;b;c\;d]] 
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst 1)]]
    lst [[e;c\;d]] 
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst -1)]]
    lst [[e;a\;b]] 
)

set(lst [[c;a\\;b;c\;d;e]])
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst 0)]]
    lst [[a\\;b;c\;d;e]]
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst 1)]]
    lst [[c;c\;d;e]]
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst 2)]]
    lst [[c;a\\;b;e]]
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst 3)]]
    lst [[c;a\\;b;c\;d]]
)
unit_test_check_variable_equal(
    [[vcpkg_list(REMOVE_AT lst -1)]]
    lst [[c;a\\;b;c\;d]]
)
