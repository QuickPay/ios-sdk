# Release instructions

This guide shows how to build the SDK and release it through CocoaPods.

## Prerequisit

The following needs to be available on your machine in order to release

 - XCode command line tools
 - Fastlane
 - Git
 - Ruby


## Fastlane

Most of the heavy lifting is done by Fastlane. First step is to make sure that Fastlane is installet and ready to use on your machine.

Run the `release` lane to build the SDK including architectures for both simulators and physical devices. This will also bundle everything we need to make a new release to CocoaPods.


## CocoaPods

When Fastlane is done with the release lane, copy the content of the release folder into the folder where you have checked out the `ios-sdk-pod` repo. Commit and push the code to origin.

Now we need add a new tag to the code which descripes the version of the SDK.

```bash
git tag -a v<VERSION_NUMBER EX. 2.0> -m "<DESCRIPTION OF THE TAG>"
Git push origin —tags
```

The last step is to update the CocoaPods podspec file so it point to the newest tag on git. When that is done, push the new podspec file to CocoaPods.

```bash
pod trunk push QuickPaySDK.podspec
```


# Nice to know commands

This is just a collection of command line commands that are nice to know about if stuff happens


## Git tags

If you tag the wrong code or just needs to remove a tag from git, use these commands.

```bash
git tag --delete <TAG NAME>
git push origin --delete <TAG NAME>
```


## CocoaPods Podspec

If you want to test a .podspec file you can reference it manually with a full path in the Podfile. This way you don't need to release it to CocoaPods for testing it out.

```ruby
pod 'QuickPaySDK', :podspec => "<FULL_PATH_TO_PODSPEC_FILE>"
```
