<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
                xmlns:adms="http://www.w3.org/ns/adms#"
                xmlns:schema="http://schema.org/"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:spdx="http://spdx.org/rdf/terms#"
                xmlns:locn="http://www.w3.org/ns/locn#"
                xmlns:time="http://www.w3.org/2006/time#"
                xmlns:functx="http://www.functx.com"
                xsi:noNamespaceSchemaLocation="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" />
    <xsl:strip-space elements="*" />

    <xsl:param name="repo_lang" select="'en'" />

    <xsl:function name="functx:trim" as="xs:string" xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?" />
        <xsl:sequence select=" replace(replace($arg,'\s+$',''),'^\s+','')" />
    </xsl:function>

    <xsl:variable name="fr" select="('\t', '\n', '\r', '\\', '&quot;')"/>
    <xsl:variable name="to" select="('\\t', '\\n', '\\r', '\\\\', '\\&quot;')"/>

    <xsl:function name="functx:replace-multi" as="xs:string?" xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="changeFrom" as="xs:string*"/>
        <xsl:param name="changeTo" as="xs:string*"/>

        <xsl:sequence select="if (count($changeFrom) > 0)
   		then functx:replace-multi(
   			replace($arg, $changeFrom[1], functx:if-absent($changeTo[1],'')),
          	$changeFrom[position() > 1],
          	$changeTo[position() > 1])
		else $arg"/>
    </xsl:function>

    <xsl:function name="functx:if-absent" as="item()*" xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="item()*"/>
        <xsl:param name="value" as="item()*"/>

        <xsl:sequence select="if (exists($arg))
	    then $arg
    	else $value"/>

    </xsl:function>

    <xsl:template match="dcat:Dataset">
        {
        "name": "<xsl:value-of select="@rdf:about" />",

        <!-- dct:description 1..n (multilingual) -->
        "notes": "<xsl:value-of select="functx:replace-multi(normalize-space((dct:description[not(xml:lang)]|dct:description[xml:lang = $repo_lang])[1]), $fr, $to)" />",

        <!-- dct:title 1..n (multilingual) -->
        "title": "<xsl:value-of select="functx:replace-multi(normalize-space((dct:title[not(xml:lang)]|dct:title[xml:lang = $repo_lang])[1]), $fr, $to)" />",

        <!-- dcat:contactPoint 0..n -->
        <xsl:if test="dcat:contactPoint">"contact_point": [ <xsl:for-each select="dcat:contactPoint"><xsl:apply-templates select="." /><xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each> ],</xsl:if>

        <!-- dcat:distribution 0..n -->
        <xsl:if test="dcat:distribution">"resources": [ <xsl:for-each select="dcat:distribution"><xsl:apply-templates select="." /><xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each> ],</xsl:if>

        <xsl:if test="dcat:keyword">"tags": [ <xsl:for-each select="dcat:keyword">{ "name": "<xsl:value-of select="functx:replace-multi(normalize-space(.), $fr, $to)" />" }<xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each> ],</xsl:if>

        <xsl:apply-templates select="dct:publisher" />

        <xsl:if test="dcat:theme[starts-with(@rdf:resource, 'http://publications.europa.eu/resource/authority/data-theme/')]">
            "groups": [<xsl:for-each select="dcat:theme[starts-with(@rdf:resource, 'http://publications.europa.eu/resource/authority/data-theme/')]"><xsl:call-template name="category" /></xsl:for-each> ],
        </xsl:if>

        <xsl:apply-templates select="dct:accessRights" />

        <xsl:if test="dct:conformsTo">
            "conforms_to": [<xsl:for-each select="dct:conformsTo"><xsl:apply-templates select="." /><xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],
        </xsl:if>

        <xsl:if test="foaf:page">
            "page": [<xsl:for-each select="foaf:page"><xsl:apply-templates select="." /><xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],
        </xsl:if>

        <xsl:apply-templates select="dct:accrualPeriodicity[starts-with(@rdf:resource, 'http://publications.europa.eu/resource/authority/frequency/')]" />

        <!-- dct:hasVersion 0..n -->
        <xsl:if test="dct:hasVersion">
            "has_version": [<xsl:for-each select="dct:hasVersion">"<xsl:value-of select="@rdf:resource" />"<xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],
        </xsl:if>

        <!-- dct:identifier 0..n -->
        <xsl:if test="dct:identifier">
            "identifier": [<xsl:for-each select="dct:identifier">"<xsl:value-of select="." />"<xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],
        </xsl:if>

        <!-- dct:isVersionOf 0..n -->
        <xsl:if test="dct:isVersionOf">
            "is_version_of": [<xsl:for-each select="dct:isVersionOf">"<xsl:value-of select="@rdf:resource" />"<xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],
        </xsl:if>

        <xsl:apply-templates select="dcat:landingPage[1]" />

        <!-- dct:language 0..n -->
        <xsl:if test="dct:language[starts-with(@rdf:resource, 'http://publications.europa.eu/resource/authority/language/')]">
            "language": [<xsl:for-each select="dct:language[starts-with(@rdf:resource, 'http://publications.europa.eu/resource/authority/language/')]">{ "resource": "<xsl:value-of select="@rdf:resource" />" }<xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],
        </xsl:if>
        <xsl:if test="dc:language">
            "language": [ { "label": "<xsl:value-of select="dc:language" />" } ],
        </xsl:if>

        <!-- adms:identifier 0..n -->
        <xsl:if test="adms:identifier">
            "other_identifier": [<xsl:for-each select="adms:identifier">"<xsl:value-of select="." />"<xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],
        </xsl:if>

        <!-- dct:provenance 0..n -->
        <xsl:if test="dct:provenance">
            "provenance": [<xsl:for-each select="dct:provenance"><xsl:apply-templates select="." /><xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],
        </xsl:if>

        <!-- dct:relation 0..n -->
        <xsl:if test="dct:relation">
            "relation": [<xsl:for-each select="dct:relation">"<xsl:value-of select="@rdf:resource" />"<xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],
        </xsl:if>

        <!-- dct:issued 0..1 -->
        <xsl:apply-templates select="dct:issued" />

        <!-- adms:sample 0..n -->
        <xsl:if test="adms:sample">
            "sample": [<xsl:for-each select="adms:sample">"<xsl:value-of select="@rdf:resource" />"<xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],
        </xsl:if>

        <!-- dct:source 0..n -->
        <xsl:if test="dct:source">
            "source": [<xsl:for-each select="dct:source">"<xsl:value-of select="@rdf:resource" />"<xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],
        </xsl:if>

        <!-- dct:spatial 0..n -->
        <xsl:if test="dct:spatial[@rdf:resource]">
            "dcat_spatial": [<xsl:for-each select="dct:spatial[@rdf:resource]">{ "resource": "<xsl:value-of select="@rdf:resource" />" }<xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],
        </xsl:if>

        <xsl:if test="dct:spatial[dct:Location[locn:geometry]]">
            "extras": [ { "key": "spatial", "value": "{\"type\": \"Polygon\", \"coordinates\": [ <xsl:for-each select="dct:spatial[dct:Location[locn:geometry]]"><xsl:apply-templates select="dct:Location" /><xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each> ]}" } ],
        </xsl:if>

        <!-- dct:temporal 0..n -->
        <xsl:if test="dct:temporal[@rdf:parseType='Resource']|dct:temporal/dct:PeriodOfTime|dct:temporal/time:Interval">
            "temporal": [ <xsl:for-each select="dct:temporal"><xsl:apply-templates select="." /><xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each> ],
        </xsl:if>

        <!-- dct:type 0..1 -->
        <xsl:if test="dct:type">
            "dct_type": "<xsl:value-of select="dct:type/@rdf:resource" />",
        </xsl:if>

        <!-- dct:modified 0..1 -->
        <xsl:apply-templates select="dct:modified" />

        <!-- owl:versionInfo 0..1 -->
        <xsl:if test="owl:versionInfo">
            "version_info": "<xsl:value-of select="normalize-space(owl:versionInfo)" />",
        </xsl:if>

        <!-- adms:versionNotes 0..n (multilingual) -->
        <xsl:if test="adms:versionNotes">
            "version_notes": "<xsl:value-of select="functx:replace-multi(adms:versionNotes[1], $fr, $to)" />",
        </xsl:if>

        <!-- default should be set per harvester depending of the source language -->
        "translation_meta": { "default": "<xsl:value-of select="$repo_lang" />" },

        "translation": {
        <xsl:for-each select="dct:title[@xml:lang != $repo_lang]">
            <xsl:variable name="lang" select="@xml:lang" />
            "<xsl:value-of select="$lang" />": {
            "title": "<xsl:value-of select="functx:replace-multi(normalize-space(.), $fr, $to)" />"<xsl:if test="../dct:description[@xml:lang = $lang]">,
            "notes": "<xsl:value-of select="functx:replace-multi(../dct:description[@xml:lang = $lang], $fr, $to)" />"</xsl:if>
            }<xsl:if test="not(position() = last())">,</xsl:if>
        </xsl:for-each>
        }
        }
    </xsl:template>

    <!-- Matches the dcat:contactPoint -->
    <xsl:template match="dcat:contactPoint[@rdf:resource]">{ "resource": "<xsl:value-of select="@rdf:resource" />" }</xsl:template>
    <xsl:template match="dcat:contactPoint[@rdf:parseType='Resource']|vcard:Kind|vcard:Individual|vcard:Organization">
        {
        <xsl:if test="@rdf:about">
            "resource": "<xsl:value-of select="@rdf:about" />",
        </xsl:if>
        <xsl:choose>
            <xsl:when test="not(@rdf:parseType)">
                "type": "<xsl:value-of select="concat(namespace-uri(), local-name())" />",
            </xsl:when>
            <xsl:otherwise>
                "type": "http://www.w3.org/2006/vcard/ns#Kind",
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="vcard:hasEmail">
            "email": "<xsl:value-of select="vcard:hasEmail/@rdf:resource" />",
        </xsl:if>
        <xsl:choose>
            <xsl:when test="vcard:organization-name">
                "name": "<xsl:value-of select="functx:replace-multi(normalize-space(vcard:organization-name[@xml:lang = $repo_lang]), $fr, $to)" />"
            </xsl:when>
            <xsl:otherwise>
                "name": "<xsl:value-of select="functx:replace-multi(normalize-space(vcard:fn[@xml:lang = $repo_lang]), $fr, $to)" />"
            </xsl:otherwise>
        </xsl:choose>
        }
    </xsl:template>

    <!-- Matches the dct:publisher -->
    <xsl:template match="dct:publisher[@rdf:resource]">"publisher": { "resource": "<xsl:value-of select="@rdf:resource" />" },</xsl:template>
    <xsl:template match="dct:publisher[@rdf:parseType='Resource']|foaf:Agent|foaf:Person|foaf:Organization">
        "publisher": {
        <xsl:if test="@rdf:about">
            "resource": "<xsl:value-of select="@rdf:about" />",
        </xsl:if>
        <xsl:choose>
            <xsl:when test="not(@rdf:parseType)">
                "type": "<xsl:value-of select="concat(namespace-uri(), local-name())" />",
            </xsl:when>
            <xsl:otherwise>
                "type": "http://xmlns.com/foaf/0.1/Agent",
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="foaf:mbox">
            "email": "<xsl:value-of select="foaf:mbox/@rdf:resource" />",
        </xsl:if>
        "name": "<xsl:value-of select="functx:replace-multi(normalize-space(foaf:name[@xml:lang = $repo_lang]), $fr, $to)" />"
        },
    </xsl:template>

    <xsl:template name="category">
        <xsl:variable name="category" select="substring-after(@rdf:resource, 'http://publications.europa.eu/resource/authority/data-theme/')" />
        {
        "name": "<xsl:choose>
        <xsl:when test="$category='AGRI'">agriculture-fisheries-forestry-and-food</xsl:when>
        <xsl:when test="$category='EDUC'">education-culture-and-sport</xsl:when>
        <xsl:when test="$category='ENVI'">environment</xsl:when>
        <xsl:when test="$category='ENER'">energy</xsl:when>
        <xsl:when test="$category='TRAN'">transport</xsl:when>
        <xsl:when test="$category='TECH'">science-and-technology</xsl:when>
        <xsl:when test="$category='ECON'">economy-and-finance</xsl:when>
        <xsl:when test="$category='SOCI'">population-and-society</xsl:when>
        <xsl:when test="$category='HEAL'">health</xsl:when>
        <xsl:when test="$category='GOVE'">government-and-public-sector</xsl:when>
        <xsl:when test="$category='REGI'">regions-and-cities</xsl:when>
        <xsl:when test="$category='JUST'">justice-legal-system-and-public-safety</xsl:when>
        <xsl:when test="$category='INTR'">international-issues</xsl:when>
    </xsl:choose>"
        }<xsl:if test="not(position() = last())">,</xsl:if>
    </xsl:template>

    <xsl:template match="dct:accessRights[@rdf:resource]">"access_rights": { "resource": "<xsl:value-of select="dct:accessRights/@rdf:resource" />" },</xsl:template>
    <xsl:template match="dct:accessRights[@rdf:parseType='Resource']|dct:accessRights/dct:RightsStatement">
        "access_rights": {
        <xsl:if test="dct:RightsStatement/@rdf:about">
            "resource": "<xsl:value-of select="dct:RightsStatement/@rdf:about" />",
        </xsl:if>
        <xsl:choose>
            <xsl:when test="rdfs:label">
                "label": "<xsl:value-of select="functx:replace-multi(normalize-space((rdfs:label[not(xml:lang)]|rdfs:label[xml:lang = $repo_lang])[1]), $fr, $to)" />"
            </xsl:when>
            <xsl:when test="dct:title">
                "label": "<xsl:value-of select="functx:replace-multi(normalize-space((dct:title[not(xml:lang)]|dct:title[xml:lang = $repo_lang])[1]), $fr, $to)" />"
            </xsl:when>
        </xsl:choose>
        }
    </xsl:template>

    <xsl:template match="dct:rights[@rdf:resource]">"rights": { "resource": "<xsl:value-of select="dct:rights/@rdf:resource" />" },</xsl:template>
    <xsl:template match="dct:rights[@rdf:parseType='Resource']|dct:rights/dct:RightsStatement">
        "rights": {
        <xsl:if test="dct:RightsStatement/@rdf:about">
            "resource": "<xsl:value-of select="dct:RightsStatement/@rdf:about" />",
        </xsl:if>
        <xsl:choose>
            <xsl:when test="rdfs:label">
                "label": "<xsl:value-of select="functx:replace-multi(normalize-space((rdfs:label[not(xml:lang)]|rdfs:label[xml:lang = $repo_lang])[1]), $fr, $to)" />"
            </xsl:when>
            <xsl:when test="dct:title">
                "label": "<xsl:value-of select="functx:replace-multi(normalize-space((dct:title[not(xml:lang)]|dct:title[xml:lang = $repo_lang])[1]), $fr, $to)" />"
            </xsl:when>
        </xsl:choose>
        },
    </xsl:template>

    <xsl:template match="dct:license[@rdf:resource]">
        "license": { "resource": "<xsl:value-of select="dct:license/@rdf:resource" />" },
    </xsl:template>

    <xsl:template match="dct:license[@rdf:parseType='Resource']|dct:LicenseDocument">
        "license": {
        <xsl:if test="@rdf:about">
            "resource": "<xsl:value-of select="@rdf:about" />",
        </xsl:if>
        <xsl:choose>
            <xsl:when test="rdfs:label">
                "label": "<xsl:value-of select="functx:replace-multi(normalize-space((rdfs:label[not(xml:lang)]|rdfs:label[xml:lang = $repo_lang])[1]), $fr, $to)" />"
            </xsl:when>
            <xsl:when test="dct:title">
                "label": "<xsl:value-of select="functx:replace-multi(normalize-space((dct:title[not(xml:lang)]|dct:title[xml:lang = $repo_lang])[1]), $fr, $to)" />"
            </xsl:when>
        </xsl:choose>
        },
    </xsl:template>

    <xsl:template match="dct:conformsTo">
        {
        <xsl:choose>
            <xsl:when test="@rdf:resource">
                "resource": "<xsl:value-of select="@rdf:resource" />"
            </xsl:when>
            <xsl:when test="@rdf:parseType='Resource'">
                "label": "<xsl:value-of select="functx:replace-multi(normalize-space((dct:title[not(xml:lang)]|dct:title[xml:lang = $repo_lang])[1]), $fr, $to)" />"
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="dct:Standard" />
            </xsl:otherwise>
        </xsl:choose>
        }
    </xsl:template>

    <xsl:template match="foaf:page">
        "<xsl:choose>
        <xsl:when test="@rdf:resource">
            <xsl:value-of select="@rdf:resource" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates select="foaf:Document" />
        </xsl:otherwise>
    </xsl:choose>"
    </xsl:template>

    <xsl:template match="dcat:landingPage">
        "url": "<xsl:choose>
        <xsl:when test="@rdf:resource">
            <xsl:value-of select="@rdf:resource" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates select="foaf:Document" />
        </xsl:otherwise>
    </xsl:choose>",
    </xsl:template>

    <xsl:template match="dct:language">
        {
        <xsl:choose>
            <xsl:when test="@rdf:resource">
                "resource": "<xsl:value-of select="@rdf:resource" />"
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="dct:LinguisticSystem" />
            </xsl:otherwise>
        </xsl:choose>
        }
    </xsl:template>

    <xsl:template match="dct:provenance">
        {
        <xsl:choose>
            <xsl:when test="@rdf:parseType='Resource'">
                "label": "<xsl:value-of select="functx:replace-multi(normalize-space((dct:title[not(xml:lang)]|dct:title[xml:lang = $repo_lang])[1]), $fr, $to)" />"
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="dct:ProvenanceStatement" />
            </xsl:otherwise>
        </xsl:choose>
        }
    </xsl:template>

    <xsl:template match="dct:ProvenanceStatement|dct:Standard">
        <xsl:if test="@rdf:about">
            "resource": "<xsl:value-of select="@rdf:about" />"
        </xsl:if>
        <xsl:choose>
            <xsl:when test="rdfs:label">
                <xsl:if test="@rdf:about">,</xsl:if>
                "label": "<xsl:value-of select="functx:replace-multi(normalize-space((rdfs:label[not(xml:lang)]|rdfs:label[xml:lang = $repo_lang])[1]), $fr, $to)" />"
            </xsl:when>
            <xsl:when test="dct:title">
                <xsl:if test="@rdf:about">,</xsl:if>
                "label": "<xsl:value-of select="functx:replace-multi(normalize-space((dct:title[not(xml:lang)]|dct:title[xml:lang = $repo_lang])[1]), $fr, $to)" />"
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="foaf:Document">
        <xsl:choose>
            <xsl:when test="@rdf:about">
                <xsl:value-of select="@rdf:about" />
            </xsl:when>
            <xsl:when test="foaf:page">
                <xsl:value-of select="foaf:page" />
            </xsl:when>
            <xsl:when test="foaf:homepage">
                <xsl:value-of select="foaf:homepage" />
            </xsl:when>
            <xsl:otherwise>http://acme.org</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dct:Location">[<xsl:choose><xsl:when test="locn:geometry[@rdf:datatype='http://www.opengis.net/ont/geosparql#wktLiteral']"><xsl:call-template name="wktLiteral" /></xsl:when><xsl:otherwise><xsl:call-template name="gmlLiteral" /></xsl:otherwise></xsl:choose>]</xsl:template>

    <!-- Matches wktLiterals -->
    <xsl:template name="wktLiteral">
        <xsl:variable name="literal" select="locn:geometry[@rdf:datatype='http://www.opengis.net/ont/geosparql#wktLiteral']" />
        <xsl:variable name="coordinateList" select="substring-before(substring-after($literal, 'POLYGON(('), '))')" />
        <xsl:call-template name="coordinateList"><xsl:with-param name="list" select="normalize-space($coordinateList)" /></xsl:call-template>
    </xsl:template>

    <!-- Processes the coordinateList -->
    <xsl:template name="coordinateList">
        <xsl:param name="list" />
        <xsl:for-each select="tokenize($list, ',')">
            <xsl:variable name="coord" select="tokenize(normalize-space(.), '\s')" />
            <xsl:call-template name="coordinate"><xsl:with-param name="left" select="normalize-space($coord[1])" /><xsl:with-param name="right" select="normalize-space($coord[2])" /></xsl:call-template><xsl:if test="not(position() = last())">,</xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- Produces one coordinate -->
    <xsl:template name="coordinate">
        <xsl:param name="left" />
        <xsl:param name="right" />[<xsl:value-of select="number($left)" />,<xsl:value-of select="number($right)" />]</xsl:template>

    <xsl:template name="gmlLiteral">
        <xsl:variable name="literal" select="locn:geometry[@rdf:datatype='http://www.opengis.net/ont/geosparql#gmlLiteral']" />
        <xsl:variable name="firstCoordinate" select="substring-before(substring-after($literal, '&lt;gml:lowerCorner&gt;'), ' ')" />
        <xsl:variable name="secondCoordinate" select="substring-after(substring-before(substring-after($literal, '&lt;gml:lowerCorner&gt;'), '&lt;/gml:lowerCorner&gt;'), ' ')" />
        <xsl:variable name="thirdCoordinate" select="substring-before(substring-after($literal, '&lt;gml:upperCorner&gt;'), ' ')" />
        <xsl:variable name="fourthCoordinate" select="substring-after(substring-before(substring-after($literal, '&lt;gml:upperCorner&gt;'), '&lt;/gml:upperCorner&gt;'), ' ')" />
        [<xsl:value-of select="number($secondCoordinate)" />,<xsl:value-of select="number($thirdCoordinate)" />],[<xsl:value-of select="number($fourthCoordinate)" />,<xsl:value-of select="number($thirdCoordinate)" />],[<xsl:value-of select="number($fourthCoordinate)" />,<xsl:value-of select="number($firstCoordinate)" />],[<xsl:value-of select="number($secondCoordinate)" />,<xsl:value-of select="number($firstCoordinate)" />],[<xsl:value-of select="number($secondCoordinate)" />,<xsl:value-of select="number($thirdCoordinate)" />]
    </xsl:template>

    <xsl:template match="dct:temporal[@rdf:parseType='Resource']|dct:PeriodOfTime">
        {
        "start_date": "<xsl:value-of select="schema:startDate" />",
        "end_date": "<xsl:value-of select="schema:endDate" />"
        }
    </xsl:template>
    <xsl:template match="dct:temporal/time:Interval">
        {
        <xsl:if test="time:hasBeginning">"start_date": "<xsl:value-of select="time:hasBeginning/time:Instant/time:inXSDDateTime" />"</xsl:if><xsl:if test="time:hasBeginning and time:hasEnd">,</xsl:if>
        <xsl:if test="time:hasEnd">"end_date": "<xsl:value-of select="time:hasEnd/time:Instant/time:inXSDDateTime" />"</xsl:if>
        }
    </xsl:template>

    <xsl:template match="dcat:distribution[rdf:parseType='Resource']|dcat:Distribution">
        {
        <!-- dcat:accessURL 1..n -->
        "access_url": [<xsl:for-each select="dcat:accessURL">"<xsl:value-of select="." />"<xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],

        <!-- dct:description 1..n (multilingual) -->
        <xsl:if test="dct:description[not(xml:lang)]|dct:description[xml:lang = $repo_lang]">
            "description": "<xsl:value-of select="functx:replace-multi(normalize-space((dct:description[not(xml:lang)]|dct:description[xml:lang = $repo_lang])[1]), $fr, $to)" />",
        </xsl:if>

        <!-- dct:format 0..1 -->
        <xsl:apply-templates select="dct:format" />

        <!-- dct:license 0..1 -->
        <xsl:apply-templates select="dct:license" />

        <!-- dcat:byteSize 0..1 -->
        <xsl:apply-templates select="dcat:byteSize" />

        <!-- spdx:checksum 0..1 -->
        <xsl:apply-templates select="spdx:checksum" />

        <!-- foaf:page 0..n -->
        <xsl:if test="foaf:page">
            "page": [<xsl:for-each select="foaf:page"><xsl:apply-templates select="." /><xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],
        </xsl:if>

        <!-- dcat:downloadURL 0..n -->
        <xsl:if test="dcat:downloadURL">
            "download_url": [<xsl:for-each select="dcat:downloadURL">"<xsl:value-of select="." />"<xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],
        </xsl:if>

        <!-- dct:language 0..n -->
        <xsl:if test="dct:language[starts-with(@rdf:resource, 'http://publications.europa.eu/resource/authority/language/')]">
            "language": [<xsl:for-each select="dct:language[starts-with(@rdf:resource, 'http://publications.europa.eu/resource/authority/language/')]">"<xsl:value-of select="@rdf:resource" />"<xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each>],
        </xsl:if>

        <!-- dct:conformsTo 0..n -->
        <xsl:if test="dct:conformsTo">
            "conforms_to": [ <xsl:for-each select="dct:conformsTo"><xsl:apply-templates select="." /><xsl:if test="not(position() = last())">,</xsl:if></xsl:for-each> ],
        </xsl:if>

        <!-- dcat:mediaType 0..1 -->
        <xsl:apply-templates select="dcat:mediaType" />

        <!-- dct:issued 0..1 -->
        <xsl:apply-templates select="dct:issued" />

        <!-- dct:rights 0..1 -->
        <xsl:apply-templates select="dct:rights" />

        <!-- adms:status 0..1 -->
        <xsl:apply-templates select="adms:status[starts-with(@rdf:resource, 'http://purl.org/adms/status')]" />

        <!-- dct:title 0..n (multilingual) -->
        <xsl:if test="dct:title[not(xml:lang)]|dct:title[xml:lang = $repo_lang]">
            "name": "<xsl:value-of select="functx:replace-multi(normalize-space((dct:title[not(xml:lang)]|dct:title[xml:lang = $repo_lang])[1]), $fr, $to)" />",
        </xsl:if>

        <!-- dct:modified 0..1 -->
        <xsl:apply-templates select="dct:modified" />

        "translation": {
        <xsl:for-each select="dct:description[@xml:lang != $repo_lang]">
            <xsl:variable name="lang" select="@xml:lang" />
            "<xsl:value-of select="$lang" />": {
            "description": "<xsl:value-of select="." />"<xsl:if test="functx:replace-multi(../dct:title[@xml:lang = $lang], $fr, $to)">,
            "name": "<xsl:value-of select="functx:replace-multi(normalize-space(../dct:title[@xml:lang = $lang]), $fr, $to)" />"</xsl:if>
            }<xsl:if test="not(position() = last())">,</xsl:if>
        </xsl:for-each>
        }

        }
    </xsl:template>

    <xsl:template match="dct:issued">"issued": "<xsl:value-of select="." />",</xsl:template>

    <xsl:template match="dct:modified">"modified": "<xsl:value-of select="." />",</xsl:template>

    <xsl:template match="dcat:byteSize">"size": "<xsl:value-of select="." />",</xsl:template>

    <xsl:template match="dct:accrualPeriodicity">"accrual_periodicity": { resource: "<xsl:value-of select="@rdf:resource" />" },</xsl:template>

    <xsl:template match="dcat:mediaType">"mimetype": "<xsl:value-of select="." />",</xsl:template>

    <xsl:template match="dct:format">"format": "<xsl:value-of select="dct:IMT/@rdfs:label" />",</xsl:template>

    <xsl:template match="adms:status">"status": { "resource": "<xsl:value-of select="@rdf:resource" />" },</xsl:template>

    <xsl:template match="spdx:checksum[@rdf:parseType='Resource']|spdx:Checksum">
        "checksum": {
        "algorithm": "<xsl:value-of select="spdx:algorithm" />",
        "checksum_value": "<xsl:value-of select="spdx:checksumValue" />"
        },
    </xsl:template>

</xsl:stylesheet>
