<?xml version="1.0" encoding="UTF-8"?>

<!-- Temporary stylesheet created by kw for Julia to add  <mods:identifier type="dhq"> to the DHQ biblio records -->
<!-- Empty <mods:identifier type="dhq"> element first added at desired location with simple GREP -->

<xsl:stylesheet version="2.0" 
	  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	  xmlns:mods="http://www.loc.gov/mods/v3">  
 
<xsl:preserve-space elements="*"/>
 
<xsl:template match="mods:identifier[@type='dhq']">
	
	<xsl:variable name="name">
		<xsl:choose>
			<xsl:when test="parent::*[self::mods:mods]/mods:name[position()=1]/mods:namePart[@type='family']">
				<xsl:choose>
					<!-- Suppressing any part of a name following a hyphen -->
					<xsl:when test="contains(parent::*[self::mods:mods]/mods:name[position()=1]/mods:namePart[@type='family'], '-')">
						<xsl:value-of select="substring-before(parent::*[self::mods:mods]/mods:name[position()=1]/mods:namePart[@type='family'], '-' )"/>
					</xsl:when>
					<!-- Suppressing "van ", "van der ", "van den " (case-insensitive) -->
					<xsl:when test="matches(parent::*[self::mods:mods]/mods:name[position()=1]/mods:namePart[@type='family'], 'van (de[rn]? )?.+', 'i')">
						<xsl:value-of select="replace(parent::*[self::mods:mods]/mods:name[position()=1]/mods:namePart[@type='family'], 'van (de[rn]? )?([^ ]+)( .+)?' , '$2' , 'i')"/>
					</xsl:when>
					<!-- Suppressing  "von " (case-insensitive)-->
					<xsl:when test="matches(parent::*[self::mods:mods]/mods:name[position()=1]/mods:namePart[@type='family'], 'von .+', 'i')">
						<xsl:value-of select="replace(parent::*[self::mods:mods]/mods:name[position()=1]/mods:namePart[@type='family'], 'von ([^ ]+)( .+)?' , '$1' , 'i')"/>
					</xsl:when>
					<!-- Suppressing  "St. " -->
					<xsl:when test="matches(parent::*[self::mods:mods]/mods:name[position()=1]/mods:namePart[@type='family'], 'St\. .+', 'i')">
						<xsl:value-of select="replace(parent::*[self::mods:mods]/mods:name[position()=1]/mods:namePart[@type='family'], 'St\. ([^ ]+)( .+)?' , '$1' , 'i')"/>
					</xsl:when>
					<!-- Suppressing  an initial 2-character part of the name (and the following space) -->
					<xsl:when test="matches(parent::*[self::mods:mods]/mods:name[position()=1]/mods:namePart[@type='family'], '^.{2} .+' )">
						<xsl:value-of select="replace(parent::*[self::mods:mods]/mods:name[position()=1]/mods:namePart[@type='family'], '^.{2} ([^ ]+)( .+)?' , '$1' )"/>
					</xsl:when>
					<!-- Suppressing  any part of a name follwing a space (this is after evaluating the previous conditions) -->
					<xsl:when test="contains(parent::*[self::mods:mods]/mods:name[position()=1]/mods:namePart[@type='family'], ' ')">
						<xsl:value-of select="replace(parent::*[self::mods:mods]/mods:name[position()=1]/mods:namePart[@type='family'], '^([^ ,]+),? .+', '$1' , 'ms')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="parent::*[self::mods:mods]/mods:name[position()=1]/mods:namePart[@type='family']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise><xsl:text>xxx</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="date">
		<xsl:choose>
			<xsl:when test="parent::*[self::mods:mods]//mods:date"><xsl:value-of select="parent::*[self::mods:mods]//mods:date"/></xsl:when>
			<xsl:when test="parent::*[self::mods:mods]//mods:dateIssued"><xsl:value-of select="parent::*[self::mods:mods]//mods:dateIssued"/></xsl:when>
			<xsl:otherwise><xsl:text>yyy</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="titleFrag">
		<xsl:choose>
			<xsl:when test="parent::*[self::mods:mods]/mods:titleInfo//mods:title">
				<xsl:value-of select="substring(replace(parent::*[self::mods:mods]/mods:titleInfo//mods:title, '(“|‘|&quot;|The |[A-Z] |[A-Z][a-z] )?(“|‘|&quot;)?([^ ]+)' , '$3' ),1,3)"/>
			</xsl:when>
			<xsl:otherwise><xsl:text>zzz</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>	
	
	<xsl:copy>
		<xsl:copy-of select="@*"/>
    	<xsl:value-of select="lower-case($name)"/>
		<xsl:text>_</xsl:text>
		<xsl:value-of select="replace($date, '.*(\d\d\d\d).*', '$1' )"/>
		<xsl:text>_</xsl:text>
		<xsl:value-of select="lower-case($titleFrag)"/>
   </xsl:copy>
	
</xsl:template>
 


<!-- The Identity Transformation --> 
<xsl:template match="node()|@*">
  <!-- Copy the current node -->
  <xsl:copy>
    <!-- Including any attributes it has and any child nodes -->
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>
  
</xsl:stylesheet>
      
