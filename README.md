# Data.gov.be DCAT files 

Metadata being used to update the Belgian data.gov.be portal, in [DCAT-AP 1.1](https://joinup.ec.europa.eu/asset/dcat_application_profile/description).

Available as N-Triples and RDF/XML file.

## DCAT XML export for European Data Portal

The [datagovbe_edp.xml](all/datagovbe_edp.xml) XML file contains a serialization that is similar in structure to the one used by the Spanish portal, but there are nevertheless differences:

### Language
ES: dc:language element with short language codes

BE: dcterms:language with URIs from the [EU Publication Office Language](http://publications.europa.eu/mdr/authority/language/index.html), as recommended by the DCAT-AP profile

### Themes
ES: dcat:theme with own thesauri / categories

BE: dcat:theme with URIs from the [EU Publication Office Data Theme](http://publications.europa.eu/mdr/authority/data-theme/index.html), as recommended by the DCAT-AP profile / EDP

## Frequency / AccrualPeriodicity
ES: dcterms:accrualPeriodicity with dcterms:frequency element

BE: dcterms:accrualPeriodicity with URIs from the [EU Publication Office Frequency](http://publications.europa.eu/mdr/authority/frequency/index.html), as recommended by the DCAT-AP profile

## Spatial / geographical coverage
ES: dcterms:spatial with own thesauri

BE: dcterms:spatial with GeoNames URIs, as recommended by the DCAT-AP profile

## Contact points of a dataset
ES: not present ?

BE: dcat:contactPoint with vcard:Organization

## List of publishers of a dataset
ES: external list ?

BE: foaf:Organization at the end of the file
