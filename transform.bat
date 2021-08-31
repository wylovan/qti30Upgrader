@echo off
set d=%~dp0
echo %d%items

echo PROCS: %NUMBER_OF_PROCESSORS%

java -cp "C:\_apps\Saxon\SaxonHE10-5J\saxon-he-10.5.jar" net.sf.saxon.Transform -t -s:"%d%items\qti22" -xsl:"%d%qti2xTo30.xsl" -o:"%d%\output\qti22" -threads:%NUMBER_OF_PROCESSORS%
java -cp "C:\_apps\Saxon\SaxonHE10-5J\saxon-he-10.5.jar" net.sf.saxon.Transform -t -s:"%d%items\apip1" -xsl:"%d%qti2xTo30.xsl" -o:"%d%\output\apip1" -threads:%NUMBER_OF_PROCESSORS%
java -cp "C:\_apps\Saxon\SaxonHE10-5J\saxon-he-10.5.jar" net.sf.saxon.Transform -t -s:"%d%items\qti21" -xsl:"%d%qti2xTo30.xsl" -o:"%d%\output\qti21" -threads:%NUMBER_OF_PROCESSORS%
