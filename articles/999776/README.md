This set of XML files is a test suite for the constraints on the
change entry for the git history, particularly the
"require_proper_git_history" constraint.

Every file in this directory should be invalid (due to a problem with
the `<change>` for the git history) against our TEI Schematron schema
(common/schema/DHQauthor-TEI.isosch) except those that have “_valid”
in their name (and article ID). Currently there is only one valid file
called 999776_one_valid.xml.

note-to-self
------------
One way to run tests would be:
$ cd dhq-journal/
$ time ( cd common/schema/ && saxon.bash /home/syd/Documents/schxslt/core/src/main/resources/xslt/2.0/pipeline-for-svrl.xsl DHQauthor-TEI.isosch > DHQauthor-TEI.xslt )
$ time for f in articles/999776/*.xml ; do echo "---------$f:" ; saxon.bash common/schema/DHQauthor-TEI.xslt $f | xsel -t -m "//v:text" -v "normalize-space(.)" -n ; done 2>&1 | egrep -v '^(saxon|java)' | perl -pe 's,&lt;,<,g; s,&gt;,>,g; s,&amp;,&,g;'
