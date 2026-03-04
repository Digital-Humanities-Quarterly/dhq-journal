# Schematron validator for DHQ
## written 2026-02-02 by Syd

We are currently using [SchXslt](https://codeberg.org/SchXslt/schxslt)
directly by calling the compiler code from `ant`’s XSLT task (and then
calling the output of that form `ant`’s XSLT task), rather than by
using the ant task that David set up as part of SchXslt. That is, we
use schxslt/core/src/main/resources/xslt/2.0/pipeline-for-svrl.xsl, not
schxslt/ant/src/main/java/name/dmaus/schxslt/ant (or anything else).

SchXslt was installed simply by downloading the tarball and expanding
it into this directory. No local mods whatsoever.

We should upgrade to [SchXslt2](https://codeberg.org/schxslt/schxslt2)
when there is time to do so.
