<?xml version="1.0" encoding="UTF-8"?>
<!--
     
     qti2xTo30.xsl - Transforms QTI 2.x content to QTI 3.0.
     
     Created By:     Wyatt VanderStucken
     Educational Testing Service
     wvanderstucken@ets.org
     
     Created Date:   2020-08-17-04:00
     
     NOTES:
     This XSL transformation requires a XSL 3.0 capable processor and has been developed/tested using the Saxon-HE
     Java implementation version 9.9.1.7.
     
     This XSL transformation is incomplete.  It only supports assessmentItem documents at this point, and does
     not purport to support these completely.  It is intended as a starting point for those who are venturing
     down this path.  The following features are implemented and simple items work reasonably well...
     
     * Namespace transformation.
     * schema-location reference updates.
     * Optional adds Schematron reference.  See param "addSchematronPi".
     * responseProcessing/@template updates.
     * element and attribute name "kabobization".
     * QTI 2.2's MathML 3 namespace-uri is transformed appropriately.
     * QTI 2.2's SSML 1.1 namespace-uri is transformed appropriately.
     * Content of feedbackBlock, modalFeedback, rubricBlock and templateBlock is reordered and encapsulated
     in qti-content-body.
     
-->
<xsl:stylesheet xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:apip="http://www.imsglobal.org/xsd/apip/apipv1p0/imsapip_qtiv1p0"
                xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:mml3="http://www.w3.org/2010/Math/MathML" xmlns:imx="http://ets.org/imex"
                xmlns:ssml="http://www.w3.org/2001/10/synthesis" xmlns:ssml11="http://www.w3.org/2010/10/synthesis"
                exclude-result-prefixes="apip imx math mml mml3 ssml ssml11 xi xs" version="3.0">
    
    <xsl:param name="addSchematronPi" as="xs:boolean" select="true()"/>
    
    <xsl:variable name="qti3NamespaceUri" select="'http://www.imsglobal.org/xsd/imsqtiasi_v3p0'"/>
    <xsl:variable name="qti3RptemplatesUri" select="'https://purl.imsglobal.org/spec/qti/v3p0/rptemplates/'"/>
    <xsl:variable name="mmlNamespaceUri" select="'http://www.w3.org/1998/Math/MathML'"/>
    <xsl:variable name="ssmlNamespaceUri" select="'http://www.w3.org/2001/10/synthesis'"/>
    
    <xsl:template match="/">
        <xsl:if test="$addSchematronPi">
            <!-- Associate Schematron... -->
            <xsl:text>&#10;</xsl:text>
            <xsl:processing-instruction name="xml-model">href="https://purl.imsglobal.org/spec/qti/v3p0/schema/xsd/imsqti_asiv3p0_v1p0.xsd" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        </xsl:if>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Copy comments and processing-instructions... -->
    <xsl:template match="comment() | processing-instruction()[not(name() = 'xml-model' and matches(., 'schematypens=&quot;http://purl.oclc.org/dsdl/schematron&quot;'))]">
        <xsl:copy/>
    </xsl:template>
    
    <!-- Unidentified elements just get the namespace switched... -->
    <xsl:template match="*">
        <xsl:element name="{local-name()}" namespace="{$qti3NamespaceUri}">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Attribute names (except @aria-* and @data-*) get kabobized... -->
    <xsl:template match="@*">
        <xsl:attribute name="{if (matches(name(), '^(aria|data)-')) then name() else imx:kabobize(name(), '')}" namespace="{namespace-uri()}"
            select="string()"/>
    </xsl:template>
    
    <!-- QTI specific element names get qti-kabobified... -->
    <xsl:template
        match="*:and | *:anyN | *:areaMapEntry | *:areaMapping | *:assessmentStimulusRef | *:associableHotspot | *:associateInteraction | *:baseValue | *:calculator | *:calculatorInfo | *:calculatorType | *:card | *:cardEntry | *:catalog | *:catalogInfo | *:choiceInteraction | *:companionMaterialsInfo | *:containerSize | *:contains | *:contentBody | *:contextDeclaration | *:contextVariable | *:correct | *:correctResponse | *:customInteraction | *:customOperator | *:default | *:defaultValue | *:delete | *:description | *:digitalMaterial | *:divide | *:drawingInteraction | *:durationGte | *:durationLt | *:endAttemptInteraction | *:equal | *:equalRounded | *:exitResponse | *:exitTemplate | *:extendedTextInteraction | *:feedbackInline | *:fieldValue | *:fileHref | *:gap | *:gapImg | *:gapMatchInteraction | *:gapText | *:gcd | *:graphicAssociateInteraction | *:graphicGapMatchInteraction | *:graphicOrderInteraction | *:gt | *:gte | *:hotspotChoice | *:hotspotInteraction | *:hottext | *:hottextInteraction | *:htmlContent | *:incrementSi | *:incrementUs | *:index | *:inlineChoice | *:inlineChoiceInteraction | *:inside | *:integerDivide | *:integerModulus | *:integerToFloat | *:interactionMarkup | *:interactionModule | *:interactionModules | *:interpolationTable | *:interpolationTableEntry | *:isNull | *:itemBody | *:label | *:lcm | *:lookupOutcomeValue | *:lt | *:lte | *:majorIncrement | *:mapEntry | *:mapResponse | *:mapResponsePoint | *:mapping | *:match | *:matchInteraction | *:matchTable | *:matchTableEntry | *:mathConstant | *:mathOperator | *:max | *:mediaInteraction | *:member | *:min | *:minimumLength | *:minorIncrement | *:multiple | *:not | *:null | *:numberCorrect | *:numberIncorrect | *:numberPresented | *:numberResponded | *:numberSelected | *:or | *:orderInteraction | *:ordered | *:outcomeDeclaration | *:outcomeMaximum | *:outcomeMinimum | *:patternMatch | *:physicalMaterial | *:portableCustomInteraction | *:positionObjectInteraction | *:positionObjectStage | *:power | *:printedVariable | *:product | *:prompt | *:protractor | *:random | *:randomFloat | *:randomInteger | *:repeat | *:resourceIcon | *:responseCondition | *:responseDeclaration | *:responseElse | *:responseElseIf | *:responseIf | *:responseProcessing | *:responseProcessingFragment | *:round | *:roundTo | *:rule | *:ruleSystemSi | *:ruleSystemUs | *:selectPointInteraction | *:setCorrectResponse | *:setDefaultValue | *:setOutcomeValue | *:setTemplateValue | *:simpleAssociableChoice | *:simpleChoice | *:simpleMatchSet | *:sliderInteraction | *:statsOperator | stimulusBody | *:stringMatch | *:stylesheet | *:substring | *:subtract | *:sum | *:templateBlock | *:templateCondition | *:templateConstraint | *:templateDeclaration | *:templateElse | *:templateElseIf | *:templateIf | *:templateInline | *:templateProcessing | *:templateVariable | *:textEntryInteraction | *:truncate | *:uploadInteraction | *:value | *:variable">
        <xsl:element name="{imx:qti-kabobify(name())}" namespace="{$qti3NamespaceUri}">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Stripping out APIP... -->
    <xsl:template match="apip:apipAccessibility"/>
    
    <!-- Inject Schematron association PI and schemaLocation... -->
    <xsl:template match="*:assessmentItem | *:assessmentStimulus">
        <xsl:element name="{imx:qti-kabobify(name())}" namespace="{$qti3NamespaceUri}">
            <xsl:attribute name="xsi:schemaLocation"
                select="'http://www.imsglobal.org/xsd/imsqtiasi_v3p0 https://purl.imsglobal.org/spec/qti/v3p0/schema/xsd/imsqti_asiv3p0_v1p0.xsd'"/>
            <xsl:apply-templates select="@* except @xsi:schemaLocation | node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*:feedbackBlock | *:modalFeedback | *:rubricBlock | *:templateBlock">
        <xsl:element name="{imx:qti-kabobify(name())}" namespace="{$qti3NamespaceUri}">
            <xsl:apply-templates select="@* | *:stylesheet"/>
            <!-- Adding qti-content-body ... -->
            <xsl:element name="qti-content-body" namespace="{$qti3NamespaceUri}">
                <xsl:apply-templates select="node() except *:stylesheet"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="mml:* | mml3:*">
        <xsl:element name="{local-name()}" namespace="{$mmlNamespaceUri}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="ssml:* | ssml11:*">
        <xsl:element name="{local-name()}" namespace="{$ssmlNamespaceUri}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*:responseProcessing/@template">
        <xsl:attribute name="{name()}" select="concat(replace(., '^.*/', $qti3RptemplatesUri), '.xml')"/>
    </xsl:template>
    
    <xsl:function name="imx:qti-kabobify" as="xs:string">
        <xsl:param name="s" as="xs:string"/>
        <xsl:value-of select="concat('qti-', imx:kabobize($s, ''))"/>
    </xsl:function>
    
    <xsl:function name="imx:kabobize" as="xs:string">
        <xsl:param name="s" as="xs:string"/>
        <xsl:param name="a" as="xs:string"/>
        <xsl:if test="substring($s, 1, 1)">
            <xsl:if test="matches($s, '^[A-Z]')">
                <xsl:value-of select="imx:kabobize(substring($s, 2), concat($a, '-', lower-case(substring($s, 1, 1))))"/>
            </xsl:if>
            <xsl:if test="not(matches($s, '^[A-Z]'))">
                <xsl:value-of select="imx:kabobize(substring($s, 2), concat($a, substring($s, 1, 1)))"/>
            </xsl:if>
        </xsl:if>
        <xsl:if test="not(substring($s, 1, 1))">
            <xsl:value-of select="$a"/>
        </xsl:if>
    </xsl:function>
    
    <!-- @citolab: Convert object elements with type image to images... -->
    <xsl:template match="*:object[starts-with(@type, 'image')]">
        <xsl:element name="img" namespace="{$qti3NamespaceUri}">
            <xsl:attribute name="src" select="@data" />
            <xsl:attribute name="alt" select="string(.)" />
            <xsl:copy-of select="@*[name() != 'data' and name() != 'type']"/>
        </xsl:element>
    </xsl:template>
    
    <!-- @citolab: Object elements with type video to video element... -->
    <xsl:template match="*:object[starts-with(@type, 'video')]">
        <xsl:element name="video" namespace="{$qti3NamespaceUri}">
            <xsl:attribute name="src" select="@data" />
            <xsl:copy-of select="@*[name(.)!='data' and name(.)!='type']|node()" />
            <xsl:apply-templates select="node( )" />
            <xsl:element name="source" namespace="{$qti3NamespaceUri}">
                <xsl:attribute name="type" select="@type" />
                <xsl:attribute name="src" select="@data" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
