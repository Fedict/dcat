# Data.gov.be DCAT files 

Metadata being used to update the Belgian data.gov.be portal, in [DCAT-AP](https://joinup.ec.europa.eu/asset/dcat_application_profile/description) + HVD.
Available as N-Triples and RDF/XML file.

## DCAT XML export for European Data Portal

The [datagovbe_edp.xml.gz](all/datagovbe_edp.xml.gz) contains a "pretty-print" RDF/XML serialization which is harvested by the [EDP](https://data.europa.eu/)

## Conversion tools

Source code of the harvesting and conversion tools being used to create these files can be found on https://github.com/fedict/dcattools

## DCAT-AP Feed for European Data Portal

The `docs/` folder contains the DCAT-AP feed for the European Data Portal, which is an LDES feed stored as a set of files.
On change of the [datagovbe_edp.xml.gz](all/datagovbe_edp.xml.gz) file, the LDES feed is updated using the [RDF-Connect](https://github.com/rdf-connect) [dumps-to-feed-pipeline.ttl](pipeline/dumps-to-feed-pipeline.ttl).
This pipeline is automatically run by the [create-feed.yml](.github/workflows/create-feed.yml) GitHub Action.
This resulting `docs/` folder is served by GitHub Pages with entrypoint index.trig.
