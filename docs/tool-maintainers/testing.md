Testing
=======

Testing vcpkg is important whenever one makes changes to the tool itself, and
writing new tests and keeping them up to date is also very important. If one's
code is subtly broken, we'd rather find it out right away than a few weeks down
the line when someone complains!

Running Tests
-------------

Before anything else, we should know whether you can actually run the tests!
All you should need is a way to build vcpkg -- anything will do! All you have to
do is follow the guide 😄

With `$VCPKG_DIRECTORY` being the directory where you have cloned vcpkg:

```sh
cd $VCPKG_DIRECTORY/toolsrc
mkdir -p out # mkdir -f out if in powershell
cd out
rm -r -f ./* # rm -r -fo ./* if in powershell
cmake .. -DCMAKE_BUILD_TYPE=Debug -G Ninja
cmake --build .
./vcpkg-test # ./vcpkg-test [$SPECIFIC_TEST] for a specific set of tests
# i.e., ./vcpkg-test [arguments]
```

If you make any modifications to `vcpkg`, you'll have to do the
`cmake --build .` step again.

Writing Tests
-------------

In your journey to write new tests, and to modify existing tests, reading the
[Catch2 documentation] will be very helpful! Come back after reading those 😀

You'll want to place your tests in one of the existing files, or, if it doesn't
belong in any of those, in a [new file](#adding-new-test-files).

Adding New Test Files
---------------------

[Catch2 documentation]: https://github.com/catchorg/Catch2/blob/master/docs/tutorial.md#top
