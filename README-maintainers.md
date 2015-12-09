# Maintainers Guide

Guidelines for the core maintainers of the cisco_os_shim project - above and beyond the [general developer guidelines](https://github.com/cisco/cisco-os-shim/blob/master/CONTRIBUTING.md).

## Accepting Pull Requests

* Is the pull request correctly submitted against `develop`?
* Does [Travis-CI](https://travis-ci.org/cisco/cisco-os-shim) report successful evaluation?
* Is `CHANGELOG.md` updated appropriately?
* Are new minitests added? Do they provide sufficient coverage and consistent results?
* Do minitests pass on both NX-OS and IOS XR?

## Setting up git-flow

If you don't already have [`git-flow`](https://github.com/petervanderdoes/gitflow/) installed, install it.

Either run `git flow init` from the repository root directory, or manually edit your `.git/config` file. Either way, when done, you should have the following in your config:

```ini
[gitflow "branch"]
        master = master
        develop = develop
[gitflow "prefix"]
        feature = feature/
        release = release/
        hotfix = hotfix/
        support = support/
        versiontag = v
```

Most of these are default for git-flow except for the `versiontag` setting.

## Release Process

When we agree as a team that a new release should be published, the process is as follows:

1. Create a release branch. Follow [semantic versioning](http://semver.org) - a bugfix release is a 0.0.x version bump, a new feature is a 0.x.0 bump, and a backward-incompatible change is a new x.0.0 version. 

    ```
    git flow release start 1.0.1
    ```

2. In the newly created release branch, update `CHANGELOG.md`:

    ```diff
     Changelog
     =========
 
    -(unreleased)
    -------------
    +1.0.1
    +-----
    ```
    
    and also update `version.rb`:
    
    ```diff
    -  VERSION = '1.0.0'
    +  VERSION = '1.0.1'
    ```

3. Finish the release and push it to GitHub:

    ```
    git flow release finish 1.0.1
    git push origin master
    git push origin develop
    git push --tags
    ```

4. Add release notes on GitHub, for example `https://github.com/cisco/cisco-os-shim/releases/new?tag=v1.0.1`. Usually this will just be a copy-and-paste of the relevant section of the `CHANGELOG.md`.

5. Publish the new gem version to rubygems.org:

    ```
    gem build cisco_os_shim.gemspec
    gem push cisco_os_shim-1.0.1.gem
    ```
