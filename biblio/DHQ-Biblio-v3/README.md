# DHQ Biblio


## Installing Biblio

Biblio is intended to be used as a webapp housed in the XML database BaseX. On the DHQ server, BaseX is installed as a servlet within Apache Tomcat. This README won't cover installing BaseX as a standalone server, but you can absolutely do that for local development work. After setting up BaseX, skip the "Installation into Tomcat" section below.


### Installation into Tomcat

Download the most recent BaseX WAR file from <http://basex.org/download/> and place it in Tomcat's `webapp` directory. Change the filename to "basex.war".

Either: unzip the WAR file (change WAR to ZIP, then `unzip basex.zip -d basex`), _or_ restart Tomcat, which will unpack the WAR file to a new "basex" directory.

In BaseX's configuration (`basex/WEB-INF/web.xml`):

* Disable WebSockets, since they aren't in use.
* Possibly: disable WebDAV.
* If using Tomcat 6, disable the "default", or "static", servlet. Tomcat 6 will not load BaseX as a web application because it claims that the servlet name "default" is not unique.

Create "basex/servlet.xml". (I use `<exists/>` as the only content.) The existence of this file will allow Biblio to create Tomcat-specific links.

Restart Tomcat to use the above settings.

When BaseX is used as a servlet, there doesn't seem to be a server-side client. To do any administrative tasks, you'll need to use the DBA web interface ("/basex/dba") or REST ("/basex/rest").


### Customizing BaseX

Change the admin password **immediately.** (Alternatively, copy a `users.xml` file from a test instance to "/basex/data".)

Make any changes to BaseX's configuration (`basex/WEB-INF/web.xml`). My preferences:

    <!-- By default, index attributes that look like IDs or keys. -->
    <context-param>
      <param-name>org.basex.attrinclude</param-name>
      <param-value>*:id,ID,key</param-value>
    </context-param>
    <!-- By default, keep leading and trailing whitespace. -->
    <context-param>
      <param-name>org.basex.chop</param-name>
      <param-value>false</param-value>
    </context-param>
    <!-- By default, index diacritics. -->
    <context-param>
      <param-name>org.basex.diacritics</param-name>
      <param-value>true</param-value>
    </context-param>
    <!-- By default, serialized documents aren't indented. -->
    <context-param>
      <param-name>org.basex.serializer</param-name>
      <param-value>indent=no</param-value>
    </context-param>
    <!-- By default, BaseX will skip over files that it can't parse, rather than 
      returning an error. -->
    <context-param>
      <param-name>org.basex.skipcorrupt</param-name>
      <param-value>true</param-value>
    </context-param>

Out-of-the-box, BaseX uses the XSLT 1.0 processor Xalan to transform stylesheets. Biblio requires XSLT v2.0 or higher. To enable XSLT v2.0+ in BaseX, download [the Saxon HE processor](https://sourceforge.net/projects/saxon/files/) and place it in `basex/lib/custom`.


### Preparing Biblio

Get a copy of the Biblio code into BaseX's "webapp" folder. Either `svn checkout` Biblio V3, or create a symbolic link to Biblio V3 as stored elsewhere. In either case, use the directory name "biblio". Then, (re)start Tomcat or BaseX-as-standalone-server, depending on your setup.

Run the Biblio database-maker XQuery and save the resulting command script locally. For example, when BaseX is running as a server at "http://localhost:8081":

    curl -u admin "http://localhost:8081/basex/rest?run=biblio/scripts/dbmaker_biblio-all.xq&dhq-svn-dir-path=../cocoon/dhq&biblio-dir-path=biblio/data" > ./biblio-setup.bxs ; echo ''

The result of the DB-maker script is a command script, which will set up the BaseX databases that Biblio will use. Tell BaseX to execute the new script, and then check if the Biblio databases were created. For example:

    curl -X POST -u admin --data @biblio-setup.bxs "http://localhost:8081/basex/rest" ; echo '' ; curl -u admin http://localhost:8081/basex/rest ; echo ''

