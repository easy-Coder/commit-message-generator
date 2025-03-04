A simple cli tools to generate a git commit message from changes made on projects.

## How to run?
1. You must have dart installed on your system.

You can get it from: [dart.dev](https://dart.dev)

``` shell
$ dart compile exe bin/git_commit_message_generator.dart -o build/commitgen
```

2. Make sure you set gemini api key in your environment variable

```shell
$ export GEMINI_API_KEY='...api_key...'
```

3. Then you can run the app like this:
```shell
$ ./build/commitgen
```
4. (Optional) You can add executable to path.
