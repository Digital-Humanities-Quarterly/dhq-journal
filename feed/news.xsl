<?xml version="1.0" encoding="UTF-8"?>
<!-- Different namespaces for DHQ content and Atom entries -->
<!-- Old Version of news xslt that displays complete abstract --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dhq="http://digitalhumanities.org/DHQ/namespace" version="1.0"
    xmlns="http://www.w3.org/2005/Atom" exclude-result-prefixes="dhq">
    <!--  Final Atom feed is in xml format -->
    <xsl:output method="xml"/>

    <!-- Static publishing path contains the cocoon  path for volume -->
    <xsl:param name="staticPublishingPathPrefix">
        <xsl:value-of select="'../vol/'"/>
    </xsl:param>

    <!-- Generate path of xml files of article for the current volume and issue from table of contents (toc.xml) file -->
    <xsl:param name="vol">
        <xsl:value-of select="/toc/@vol"/>
    </xsl:param>
    <xsl:param name="issue">
        <xsl:value-of select="/toc/@issue"/>
    </xsl:param>
    <xsl:param name="staticPublishingPath">
        <xsl:value-of select="concat($staticPublishingPathPrefix,$vol,'/',$issue,'/xml/')"/>
        <xsl:message>
            <xsl:value-of select="concat($staticPublishingPathPrefix,$vol,'/',$issue,'/xml/')"/>
        </xsl:message>
    </xsl:param>

    <!-- Parameters to store actual weblinks of various elements of the atom feed -->
    <xsl:param name="pathfull">
        <xsl:value-of select="'http://brain.lis.uiuc.edu:2323/opencms/opencms/dhq/vol/'"/>
    </xsl:param>
    <xsl:param name="pathfulllink">
        <xsl:value-of select="concat($pathfull,$vol,'/',$issue,'/')"/>
    </xsl:param>
    <xsl:param name="channellink">
        <xsl:value-of select="concat($pathfulllink, 'index.html')"/>
    </xsl:param>


    <xsl:template match="/">
        <!--metadata aboout the feed-->
        <feed xmlns="http://www.w3.org/2005/Atom">
            <title>digital humanities quarterly</title>
            <id>
                <xsl:value-of select="($channellink)"/>
            </id>
            <!--manipulate the feed level timestamp  from toc.xml  and use it further for entry of new issue and author biography-->
            <xsl:variable name="tocdate">
                <xsl:value-of select="/toc/title/@value"> </xsl:value-of>
            </xsl:variable>
            <xsl:variable name="toctimestamp">
                <xsl:value-of select="concat($tocdate,'T00:00:00Z')"/>
            </xsl:variable>
            <updated>
                <!-- Use the timestamp created from table of contents-->
                <xsl:value-of select="$toctimestamp"/>
            </updated>

            <!-- actual link of the feed  - self link-->
            <link rel="self" href="http://atomnews.xml" type="application/atom+xml"/>
            <category term=" Digital Humanities"/>
            <rights type="xhtml" xml:lang="en">
                <div xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US">
                    <b>&amp; copy; The Alliance of Digital Humanities Organizations </b>
                </div>
            </rights>
            
            <!-- the name of the pic file that you want to upload to represent the feed on the page-->
            <icon>rsspic.gif</icon>
            <!-- Default the author name to digital humanities quarterly at feed level to avoid the validation error that comes if no author is found at the article level -->
            <author>
                <name>Digital Humanities Quarterly</name>
            </author>
            <subtitle>Digital Humanities Quarterly</subtitle>


            <!-- item to describe new issue -->
            <entry>
                <title>
                    <xsl:value-of select="toc/title"/>
                </title>
                <id>
                    <xsl:value-of select="($channellink)"/>
                </id>

                <updated>
                    <!-- Reuse the timestamp created from table of contents-->
                    <xsl:value-of select="$toctimestamp"/>
                </updated>
                <summary>Digital Humanities Quarterly - New Issue</summary>
<!-- Provide link to the index of the current issue -->
                <link rel="alternate">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$channellink"/>
                    </xsl:attribute>
                </link>
            </entry>
            
            <!-- editorials items-->

            <xsl:for-each select="//list[@id='editorials']/item">
                <entry>
                    <xsl:apply-templates
                        select="document(concat($staticPublishingPath,@id,'/',@id,'.xml'))//dhq:DHQarticle"/>
                    <xsl:message>
                        <xsl:value-of
                            select="concat('file: ',$staticPublishingPath,@id,'/',@id,'.xml')"/>
                    </xsl:message>
                </entry>
            </xsl:for-each>

            <!--    article items      -->

            <xsl:for-each select="//list[@id='articles']/item">
                <entry>
                    <xsl:apply-templates
                        select="document(concat($staticPublishingPath,@id,'/',@id,'.xml'))//dhq:DHQarticle"/>
                    <xsl:message>
                        <xsl:value-of
                            select="concat('file: ',$staticPublishingPath,@id,'/',@id,'.xml')"/>
                    </xsl:message>
                </entry>
            </xsl:for-each>


            <!--     issues in digital humanities  items    -->

            <xsl:for-each select="//list[@id='issues']/item">
                <entry>

                    <xsl:apply-templates
                        select="document(concat($staticPublishingPath,@id,'/',@id,'.xml'))//dhq:DHQarticle"/>
                    <xsl:message>
                        <xsl:value-of
                            select="concat('file: ',$staticPublishingPath,@id,'/',@id,'.xml')"/>
                    </xsl:message>
                </entry>
            </xsl:for-each>


            <!--     reviews items   -->

            <xsl:for-each select="//list[@id='reviews']/item">
                <entry>

                    <xsl:apply-templates
                        select="document(concat($staticPublishingPath,@id,'/',@id,'.xml'))//dhq:DHQarticle"/>
                    <xsl:message>
                        <xsl:value-of
                            select="concat('file: ',$staticPublishingPath,@id,'/',@id,'.xml')"/>
                    </xsl:message>
                </entry>
            </xsl:for-each>

            <!--    author biography items -->

            <entry>
                <id>
                    <xsl:value-of select="concat($pathfulllink,'bios.html')"/>
                </id>
<!-- Link for author biography page -->
                <link rel="alternate">
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($pathfulllink,'bios.html')"/>
                    </xsl:attribute>
                </link>
                <title>
                    <xsl:value-of select="'Author Biographies'"/>
                </title>

                <updated>
                    <!-- Use the timestamp created from table of contents-->
                    <xsl:value-of select="$toctimestamp"/>
                </updated>

            </entry>
        </feed>
        
        
    </xsl:template>

    <xsl:template match="dhq:DHQarticle">

        <xsl:param name="id">
            <xsl:value-of select="@id"/>
        </xsl:param>
        <xsl:variable name="apos">'</xsl:variable>
        <id>
            <xsl:value-of select="concat($pathfulllink,$id,'.html')"/>
        </id>
        <link rel="alternate">
            <xsl:attribute name="href">
                <xsl:value-of select="concat($pathfulllink,$id,'.html')"/>
            </xsl:attribute>
        </link>
        <title>
            <xsl:apply-templates select="dhq:DHQheader/dhq:title"/>
        </title>

        <!--Author details-->
        <!--Select author name, affiliation and email from xml documents and put the content into appropriate feed entry tags -->
        <author>
            <name>
                <xsl:for-each select="dhq:DHQheader/dhq:author">
                    <xsl:value-of select="normalize-space(./dhq:name)"/>
                    <xsl:if test="dhq:affiliation">
                        <xsl:value-of select="', '"/>
                    </xsl:if>
                    <xsl:value-of select="normalize-space(./dhq:affiliation)"/>
                    <xsl:if test="not(position() = last())">
                        <xsl:value-of select="'; '"/>
                    </xsl:if>
                </xsl:for-each>
            </name>

            <xsl:for-each select="dhq:DHQheader/dhq:author">
                <xsl:if test="dhq:email">
                    <email>
                        <xsl:value-of select="normalize-space(./dhq:email)"/>
                    </email>
                </xsl:if>
            </xsl:for-each>

        </author>

        <!--  </description> -->
        <!-- If abstarct for the article exists - Put that in summary tag -->
        <xsl:if test="//dhq:abstract">
            <summary>
                <xsl:apply-templates select="//dhq:abstract"/>
            </summary>
        </xsl:if>

<!-- Manipulate timestamp for the entries -->
        <xsl:variable name="datestmp">
            <xsl:value-of select="dhq:DHQheader/dhq:date/@value"> </xsl:value-of>
        </xsl:variable>
        <updated>
            <!-- create a time stamp for entries appending date stamp in article and 00:00:00-->
            <xsl:value-of select="concat($datestmp,'T00:00:00Z')"/>
        </updated>
    </xsl:template>


    <xsl:template match="dhq:author/dhq:name">
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::dhq:affiliation">
            <xsl:value-of select="', '"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dhq:author/dhq:affiliation">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

    <xsl:template match="dhq:author/dhq:address|dhq:author/dhq:email"/>

</xsl:stylesheet>
