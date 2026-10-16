# Changelog

## v0.3.0

This is a major Buildroot update with security and feature updates throughout.

It does not appear that custom systems require modification for this upgrade,
but your system might use something not tested by the officially supported ones.

* Package updates
  * [nerves_system_br 1.35.2](https://github.com/nerves-project/nerves_system_br/releases/tag/v1.35.2)
  * [Buildroot 2026.08](https://lore.kernel.org/buildroot/878q5hf0yd.fsf@dell.be.48ers.dk/T/)
  * [Erlang/OTP 29.1.2](https://erlang.org/download/OTP-29.1.2.README.md)

## v0.2.2

This is a security and bug fix release.

* Changes
  * Support rendering Cog directly to DRM for improved performance
  * Allow Nerves 2 prereleases to be used

* Package updates
  * [nerves_system_br 1.34.4](https://github.com/nerves-project/nerves_system_br/releases/tag/v1.34.4)

## v0.2.1

This is a security and bug fix release.

* Package updates
  * [nerves_system_br 1.34.1](https://github.com/nerves-project/nerves_system_br/releases/tag/v1.34.1)

## v0.2.0

This is a major update with security and feature updates throughout.

* Changes
  * Use Liberation fonts as defaults. This fixes many rendering issues.
  * Enable WOFF2 support. v2.0.5 was missing a needed option.

* Updated dependencies
  * [nerves_system_br v1.34.0 release notes](https://github.com/nerves-project/nerves_system_br/releases/tag/v1.34.0)
  * GCC 15.3.0
  * [Erlang/OTP 29.0.2](https://erlang.org/download/OTP-29.0.2.README.md)
  * linux 6.18.34
  * [Buildroot 2026.05](https://lore.kernel.org/buildroot/87fr2wpxhj.fsf@dell.be.48ers.dk/T/)

## v0.1.2

This is a security and bug fix release.

* Changes
  * Disable unused Weston shells
  * Enable mime_info to support web inspector
  * Enable brotli to support WOFF2 fonts

* Package updates
  * [nerves_system_br 1.33.9](https://github.com/nerves-project/nerves_system_br/releases/tag/v1.33.9)
    * [Erlang/OTP 28.5.0.1](https://erlang.org/download/OTP-28.5.0.1.README.md)

## v0.1.1

* Changes
  * Fix QEMU video resolution (still only works on Linux)

* Package updates
  * [nerves_system_br 1.33.8](https://github.com/nerves-project/nerves_system_br/releases/tag/v1.33.8)

## v0.1.0

Initial release
