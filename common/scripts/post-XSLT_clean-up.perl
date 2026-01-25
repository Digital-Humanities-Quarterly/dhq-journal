#!/usr/bin/env perl
#
# Copyright 2025 Syd Bauman and Digital Humanities Quarterly.
# Some rights reserved. For complete copyleft notice, see
# block comment at the end of this file.
#
# post_XSLT_clean-up.perl
# 
# usage
# -----
# 	$PROGRAM_NAME < IN.xml > OUT.xml
#
# effect
# ------
# This routine reads in a file from STDIN (which *could* be anything,
# but *should* be well-formed XML) and writes out a version of the
# same file (to STDOUT) that has been altered:
# * Redundant CDATA marked sections (defined as those that have
#   neither ‘<’ nor ‘&’ in their content) changed to just simple
#   text nodes.
# * The prolog and 1st start-tag have been re-written to use three
#   particular xml-model PIs and a particular set of namespaces, out-
#   put with particularly nice whitespace to make it readable.
#
# Notes
# -----
# 1) No actual XML parsing takes place, so this routine will also
#    change things that look like CDATA marked sections that are
#    in comments or PIs. (While the same is technically true of the
#    prolog, since by definition it only occurs before the 1st start-
#    tag, it is not much of a problem.)
#
# 2) This routine reads in the entire input file (as a single line)
#    at one time. So if you have *very* large input files, you may
#    run out of memory. (The largest article file in DHQ is < ½ MiB,
#    so this should not be a problem at all on any modern computer.)
#
# 3) If speed is becoming a problem, you can make this program much
#    faster by removing the “Use English;” and its dependencies
#    (i.e., change “$INPUT_RECORD_SEPARATOR” to “$/” and “$ARG” to
#    “$_”). Reducing the entire program to just 6 lines:
#    | #!/usr/bin/env perl
#    | undef $/;
#    | $_=<>;
#    | s,<!\[CDATA\[([^<&]+?)\]\]>,$1,g;
#    | s,^(<\?xml[^-][^>]+\?>)\s*(<\?(xml-model|oxygen)[^>]+\?>)+\s*<TEI[^>]+>,$1\n<?xml-model href="../../common/schema/DHQauthor-TEI.rng"    type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0" ?>\n<?xml-model href="../../common/schema/DHQauthor-TEI.isosch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>\n<?xml-model href="../../common/schema/dhqTEI-ready.sch"     type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>\n<TEI xmlns=      "http://www.tei-c.org/ns/1.0"\n     xmlns:cc=   "http://web.resource.org/cc/"\n     xmlns:dhq=  "http://www.digitalhumanities.org/ns/dhq"\n     xmlns:html= "http://www.w3.org/1999/xhtml"\n     xmlns:mml=  "http://www.w3.org/1998/Math/MathML"\n     xmlns:rdf=  "http://www.w3.org/1999/02/22-rdf-syntax-ns#">,;
#    | print;
#    cuts execution time to ~59% what it is now. (Adding my usual
#    echo before each execution reduces that advantage to ~71% of
#    time it takes now.)
# 

use English;

# --------- start program itself --------- #

my $file;		                 # declare a variable in which to hold data
undef $INPUT_RECORD_SEPARATOR;	         # disable record separator so that we can …
$file=<STDIN>;			         # … read in entire file as one single line
$file=~s,<TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:cc="http://web.resource.org/cc/" xmlns:dhq="http://www.digitalhumanities.org/ns/dhq" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">,<TEI xmlns=      "http://www.tei-c.org/ns/1.0"\n     xmlns:cc=   "http://web.resource.org/cc/"\n     xmlns:dhq=  "http://www.digitalhumanities.org/ns/dhq"\n     xmlns:html= "http://www.w3.org/1999/xhtml"\n     xmlns:mml=  "http://www.w3.org/1998/Math/MathML"\n     xmlns:rdf=  "http://www.w3.org/1999/02/22-rdf-syntax-ns#">,;
$file=~s,<!\[CDATA\[([^<&]+?)\]\]>,$1,g; # change "<![CDATA[stuff]]>" to just "stuff" iff it does not contain '<' or '&'
print STDOUT "$file";		         # write changed “line” out as output file

# --------- end program itself --------- #

exit 0;

# previous versions of prolog repair:
# $file=~s,^(<\?xml[^-][^>]+\?>)\s*(<\?xml-model[^>]+\?>)(<\?xml-model[^>]+\?>)(<\?xml-model[^>]+\?>)<TEI[^>]+>,$1\n$2\n$3\n$4\n<TEI xmlns=      "http://www.tei-c.org/ns/1.0"\n     xmlns:cc=   "http://web.resource.org/cc/"\n     xmlns:dhq=  "http://www.digitalhumanities.org/ns/dhq"\n     xmlns:html= "http://www.w3.org/1999/xhtml"\n     xmlns:mml=  "http://www.w3.org/1998/Math/MathML"\n     xmlns:rdf=  "http://www.w3.org/1999/02/22-rdf-syntax-ns#">,; # change prolog and 1st start tag so it is readable (and consistent)
# $file=~s,^(<\?xml[^-][^>]+\?>)\s*(<\?(xml-model|oxygen)[^>]+\?>)+\s*<TEI[^>]+>,$1\n<?xml-model href="../../common/schema/DHQauthor-TEI.rng"    type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0" ?>\n<?xml-model href="../../common/schema/DHQauthor-TEI.isosch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>\n<?xml-model href="../../common/schema/dhqTEI-ready.sch"     type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>\n<TEI xmlns=      "http://www.tei-c.org/ns/1.0"\n     xmlns:cc=   "http://web.resource.org/cc/"\n     xmlns:dhq=  "http://www.digitalhumanities.org/ns/dhq"\n     xmlns:html= "http://www.w3.org/1999/xhtml"\n     xmlns:mml=  "http://www.w3.org/1998/Math/MathML"\n     xmlns:rdf=  "http://www.w3.org/1999/02/22-rdf-syntax-ns#">,; # change prolog and 1st start tag so it is readable (and consistent)


# -----------------------------------------------------
# Update Hx
# ------ --
# 2025-09-29 — Written, based on my work for the XML.com Slack conversation about
#    this topic 2025-09-08. See
#    https://xmlcom.slack.com/archives/C011NLXE4DU/p1757379700256949?thread_ts=1757280208.357709&cid=C011NLXE4DU.
#
# -----------------------------------------------------
# Copyright 2025 Syd Bauman and Digital Humanities Quarterly.
# This program is free software; you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#        Free Software Foundation, Inc.
#        675 Mass Ave
#        Cambridge, MA  02139
#        USA
#        gnu@prep.ai.mit.edu
#
# Syd Bauman, senior XML textbase programmer/analyst
# Northeastern University Library / Digital Scholarship Group / Women Writers Project
# SL 371
# Boston, MA  02115-5005
# s.bauman@northeastern.edu
#
