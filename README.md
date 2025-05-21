A simple cli tools to generate a git commit message from changes made on projects.

## How to run?
1. You must have dart installed on your system ([dart.dev](https://dart.dev)).

2. Clone the github repo
```shell
git clone https://github.com/easy-Coder/commit-message-generator
```

3. Compile program
``` shell
dart compile exe bin/git_commit_message_generator.dart -o build/commitgen
```

4. Make sure you set gemini api key in your environment variable

```shell
export GEMINI_API_KEY='...api_key...'
```

5. Then you can run the app like this:
```shell
./build/commitgen
```

6. (Optional) You can add executable to path.
