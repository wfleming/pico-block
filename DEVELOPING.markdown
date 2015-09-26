# Developing Locally

Setting up PBlock to hack on locally is fairly straightforward.
[Carthage][0] is used for dependency management, and the currently used versions of libraries are checked in, so while getting set up, no action should be required there.

[0]: https://github.com/Carthage/Carthage

What *is* required is setting up an App Group in the [Apple Developer Member Center][1]. PBlock uses app groups so that the extension & the user-facing app can look at the same rules file, which unfortunately means you need to have an active iOS Developer Program account and set up an app group for your main app & your extension.

[1]: https://developer.apple.com/membercenter/

## Setting up your app group

1. Log into the Member Center & navigate to "Certificates, Profiles, & Identifiers".
2. Under "Identifiers" -> "App Groups" create a new app group with whatever name you like. (e.g. "your.org.group.pblock")
3. Under "Identifiers" -> "App IDs", create two new IDs. One of them should be called something like "your.org.pblock", and the other should be something like "your.org.pblock-extension". For both of these IDs, enable "App Groups", and add the group ID you created in the previous step.
4. Locally, copy the following `.example` files to their non-example counterparts:
  * pblock/pblock.entitlements.example
  * pblock-extension/pblock-extension.entitlements.example
  * env/Debug.plist.example
  * env/Release.plist.example
5. In each of those files, replace `"your.group.here"` with the group name you created previously.

At this point, you should be able to build & run the project!
