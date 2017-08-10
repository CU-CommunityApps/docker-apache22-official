# Docker configuration for Apache 2.2-official image

This image is built using the same logic from [CU-CommunityApps/docker-apache24](https://github.com/CU-CommunityApps/docker-apache24), though it uses the [official httpd:2.2 image](https://hub.docker.com/_/httpd/) on Docker Hub as its base.


# Differences from previous versions

The original `cs/apache22` image was based upon Ubuntu 12.04.5 LTS, which transitioned to [end-of-life support status in April, 2017](https://wiki.ubuntu.com/Releases).  In order to provide continued support for Apache 2.2, as long as the Apache Software Foundation is commited to maintaining that release series, we have changed the base image to the official httpd:2.2 from Docker Hub.  This image is based upon Debian 8.9 (Jessie), the LTS release of which is scheduled to be supported through June, 2020.

The name of the running Apache binary has changed from `apache2` to `httpd`.  If you have scripting that interacts with the process directly instead of using `apache2ctl` (or `apachectl`), keep this in mind!

The default [MPM](https://httpd.apache.org/docs/2.2/mpm.html) is `prefork` instead of `worker`.

You can expect minor versions of supporting binaries to change as a result of this re-base.  Effort has been made to ensure similar functionality by incorporating many of the build steps from [cs/apache22](https://github.com/CU-CommunityApps/docker-apache22) and [cs/base12](https://github.com/CU-CommunityApps/docker-base12/) into this Dockerfile and the supporting scripting.

As part of the underlying base image change, Ruby has been updated from version 1.9.3 to 2.1.5.

The Apache configuration and management look-and-feel from Debian/Ubuntu has been brought into this image by way of the scripting and files under `ubuntu-compat/`.  While none of this is _required_ to launch the official Apache 2.2 build from `/usr/local/apache2`, it may assist users who have built their Dockerfiles and/or customizations with the expectation that the Debian/Ubuntu method for configuring Apache will remain in place.

The version of `mod_cuwebauth` has been been updated to **2.3.0.238** at minimum.  This version was the released by CIT Identity Management in September, 2016 and has the latest support for Two-Step Login.  As they release new versions, we may opt to update the module included in this image.

Components **missing from this image** include `mod_cgid`, `/usr/sbin/check_forensic` and `/usr/sbin/split-logfile` since the official httpd:2.2 image does not include these items.


# Building the image

The included `bin/go.sh` script will run through building mod_cuwebauth.so, creating the image and running a basic set of tests on the result.  Two environment variables are required to be set:

 - **CUWA_VERSION** -- The version of CUWebAuth being built (ie: 2.3.0.238)
 - **DOCKER_IMG** -- The label for the resulting Docker image (ie: dtr.cucloud.net/cs/apache22-official)

Prior to running `go.sh`, you need to obtain a copy of the CUWebAuth source code from Identity Management and place it in the `cuwal-src/` directory (ie: `cuwal-src/cuwal-${CUWA_VERSION}.tar.gz`).  


# Building mod_cuwebauth

When running `bin/go.sh`, we automatically attempt to build `lib/mod_cuwebauth.so` in the same environment used to run Apache.  Instead of baking a shared object file into this repository, we purposely take this step to ensure CUWebAuth is compiled natively in the environment as external dependencies change.  The `.gitignore` file is purposely ignoring everything unser `lib/`; we should **not** be distributing pre-compiled binaries or CUWebAuth sources with this repository!

The included `bin/build-mod_cuwebauth.sh` script can be used to compile mod_cuwebauth within a Docker container.  The script will build a temporary Docker image, copy the mod_cuwebauth.so artifact to `lib/` and clean up the temporary images/containers.

```
./bin/build-mod_cuwebauth.sh
```

The `build-mod_cuwebauth.sh` script requires environment variables **CUWA_VERSION** and **DOCKER_IMG** to be set.  The corresponding source tarball _must_ exist in the `cuwal-src/` directory.  We do not distribute the CUWebAuth sources with this repository; you will need to obtain them from Identity Management prior to launching a build.  Also consider where alterations to the compilation enviromnment or CUWA sources are required when updating versions.


# CUWA compiliation issues

In the `cuwal-src/` tree, there exists a patch for the bundled `configure` script for cuwal-2.3.0.238.  The stock `configure` script gets stuck trying to probe for `apr_psprintf()`; this patch simply bypasses that probe.

In time, we should circle back around with Identity Management to see if they are aware of this issue.
