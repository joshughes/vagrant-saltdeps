## 1.0.5 (2015-04-13)

BugFixes:

  - change merge order so local pillars and grains overwrite dependent pillars and grains

## 1.0.4 (2015-04-03)

ErrorHandling:

  - exit on error if the branch defined in saltdeps.yml does not exist in the repository.

## 1.0.3 (2015-04-03)

Bugfixes:

  - when a branch is defined for a repository in saltdeps.yml, do a checkout of the remote branch.

## 1.0.2 (2015-03-31)

Bugfixes:

  - update README.md
  - introduce name to saltdeps.yml to automatically create folder in /srv/salt of current formula

## 1.0.1 (2015-03-31)

Bugfixes:

  - update README.md
  - cleanup on vagrant destroy
  - create CHANGLOG.md

## 1.0.0 (2015-03-30)

Initial Release
