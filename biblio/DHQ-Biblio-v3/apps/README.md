# DHQ Biblio web applications

The DHQ Biblio data has two applications: the public web application and the "workbench" application, intended for use by DHQ editors and other staff.

The code to run these applications is contained in `biblio-public.xq` and `biblio-workbench.xq` in this directory. These files contain XQuery functions, each of which defines a response to a given HTTP request. The functions make use of annotations defined by the [RESTXQ](http://exquery.github.io/exquery/exquery-restxq-specification/restxq-1.0-specification.html) community standard.

## File organization

Besides the XQueries, this directory contains other files to help construct webpages for the two applications. The files are currently divided into four subdirectories:

* **assets**, for CSS and Javascript, both custom and copies of external libraries;
* **lib**, for XQuery libraries which support interactions with the Biblio data;
* **templates**, for XHTML snippets and skeleton files which are used to reduce repetition of common HTML structures; and
* **transforms**, for XSL stylesheets which transform input XML into other forms.

## Installation

The web applications are built to be run by [BaseX](http://basex.org/), an XML database and XQuery processor. In addition, the applications require an XSLT processor which can handle XSLT version 2.0. Also, because identifiers are likely to have characters with diacritics in them, the server must be able to handle requests using the UTF-8 character set.

### BaseX Servlet installation

On the DHQ/ADHO server, BaseX is run as a “servlet” inside an instance of the HTTP web server [Apache Tomcat](https://tomcat.apache.org/). Tomcat routes web requests to BaseX and provides a [Java](https://en.wikipedia.org/wiki/Java_(programming_language)) environment in which BaseX runs.

This means that whenever Tomcat is running, BaseX is running. Unfortunately, it also means that all administration and maintenance must occur through HTTP requests of some kind, whether in the browser or from the command line.

1. Make sure you have a local Java environment by running `java --version` on the command line. You'll need Java at release version 8 or higher.
  1. If you don't have Java, download and install the Java runtime environment: <http://www.oracle.com/technetwork/java/javase/downloads/index.html>.
2. Get the most recent Tomcat Core: <https://tomcat.apache.org/download-90.cgi>.
  1. Unpack the archive.
  2. In the Tomcat directory, follow the instructions to set up Tomcat in `RUNNING.txt`.
3. Get the most recent BaseX WAR file: <http://basex.org/download/>.
  1. Download the WAR to the "webapp" directory within Tomcat.
  2. Change the filename to "basex.war".
4. (Re)start Tomcat, which will unpack the WAR file to a new "basex" directory.
