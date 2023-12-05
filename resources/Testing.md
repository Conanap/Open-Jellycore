Testing

In order to test if your implementation is correct, build using `resources/build.sh`,
and you should compile a test case by modifying `resources/Hello.jelly`, and then
`./jelly resources/Hello.jelly --export --out test.shortcut`.

Get the shortcut file to a Mac, and sign with the following command in CLI:
`shortcuts sign --mode people-who-know-me --input ./test.shortcut --output "signed.shortcut"`

You will now be able to import the above shortcut to any shortcut app on iOS or MacOS to test.