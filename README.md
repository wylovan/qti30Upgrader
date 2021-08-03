# QTI 3.0 Upgrader

## Introduction
The QTI 3.0 Upgrader project features Extensible Stylesheet Language Transformations (XSLT) designed to
transform various flavors of QTI into the latest/greatest version QTI 3.0.  So far it has been tested with a
variety of QTI versions (QTI 2.1, QTI 2.2 and APIP 1.0) using several different XSL processing techniques.

The QTI 3.0 Upgrader project XSL ([qti2xTo30.xsl](qti2xTo30.xsl)) is intended to be a starting point for
organizations looking to transform older content into QTI 3.0.  There are notable gaps that are in the roadmap
such as apipAccessibility being dropped in the transformed XML, no support for assessmentSection,
assessmentTest or imsmanifest.xml files.

### The JavaScript Application
Currently the QTI 3.0 Upgrader project provides a fully "in browser" Javascript application - meaning
all processing is done on the client machine without any data being sent to a server.

### Demo
[http://wylovan.com/qti30Upgrader/](http://wylovan.com/qti30Upgrader/)

### Usage

1. Use the "Browse" button to select one or more assessmentItem or assessmentStimulus XML files.
1. The "Show results in page" checkbox causes the transformed XML to be displayed in the webpage when checked.
1. The "Create zip package" checkbox causes the transformed XML to be included in a .zip file that can be saved locally.
1. The "Submit" button starts the transformation process.

