package DwC;

use 5.14.0;
use strict;
use warnings;
use utf8;

use JSON;
use Module::Pluggable require => 1, sub_name => '_plugins';

require Exporter;

our @ISA = qw(Exporter);

our @PLUGINS = _plugins();
sub plugins { @PLUGINS };

our %EXPORT_TAGS = ( 'all' => [ qw(
	new Terms Auxiliary
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	new
);

our $VERSION = '0.01';

our %Cores = (
  occurrence => "occurrenceID",
  taxon => "taxonID",
  event => "eventID",
  measurement => "measurementID",
  multimedia => "id"
);

our @DCTerms = (
  "dcterms:type", "dcterms:modified", "dcterms:language",
  "dcterms:license", "dcterms:rightsHolder", "dcterms:accessRights",
  "type", "modified", "language", "license", "rightsHolder", "accessRights"
);

our @Terms = (
  "bibliographicCitation", "references",
  "institutionID", "collectionID", "datasetID",
  "institutionCode", "collectionCode", "datasetName", "ownerInstitutionCode",
  "basisOfRecord",
  "informationWithheld", "dataGeneralizations", "dynamicProperties",
  "occurrenceID", "catalogNumber", "recordNumber", "recordedBy",
  "individualCount", "organismQuantity", "organismQuantityType", "sex",
  "lifeStage", "reproductiveCondition", "behavior", "establishmentMeans",
  "occurrenceStatus", "preparations", "disposition", "associatedMedia",
  "associatedReferences", "associatedSequences", "associatedTaxa",
  "otherCatalogNumbers", "occurrenceRemarks", "organismID",
  "organismName", "organismScope", "associatedOccurrences",
  "associatedOrganisms", "previousIdentifications", "organismRemarks",
  "materialSampleID", "eventID", "parentEventID", "fieldNumber",
  "eventDate", "eventTime", "startDayOfYear", "endDayOfYear", "year",
  "month", "day", "verbatimEventDate", "habitat", "samplingProtocol",
  "sampleSizeValue", "sampleSizeUnit", "samplingEffort", "fieldNotes",
  "eventRemarks", "locationID", "higherGeographyID", "higherGeography",
  "continent", "waterBody", "islandGroup", "island", "country",
  "countryCode", "stateProvince", "county", "municipality", "locality",
  "verbatimLocality", "minimumElevationInMeters",
  "maximumElevationInMeters", "verbatimElevation",
  "minimumDepthInMeters", "maximumDepthInMeters", "verbatimDepth",
  "minimumDistanceAboveSurfaceInMeters",
  "maximumDistanceAboveSurfaceInMeters", "locationAccordingTo",
  "locationRemarks", "decimalLatitude", "decimalLongitude",
  "geodeticDatum", "coordinateUncertaintyInMeters",
  "coordinatePrecision", "pointRadiusSpatialFit", "verbatimCoordinates",
  "verbatimLatitude", "verbatimLongitude", "verbatimCoordinateSystem",
  "verbatimSRS", "footprintWKT", "footprintSRS", "footprintSpatialFit",
  "georeferencedBy", "georeferencedDate", "georeferenceProtocol",
  "georeferenceSources", "georeferenceVerificationStatus",
  "georeferenceRemarks", "geologicalContextID",
  "earliestEonOrLowestEonothem", "latestEonOrHighestEonothem",
  "earliestEraOrLowestErathem", "latestEraOrHighestErathem",
  "earliestPeriodOrLowestSystem", "latestPeriodOrHighestSystem",
  "earliestEpochOrLowestSeries", "latestEpochOrHighestSeries",
  "earliestAgeOrLowestStage", "latestAgeOrHighestStage",
  "lowestBiostratigraphicZone", "highestBiostratigraphicZone",
  "lithostratigraphicTerms", "group", "formation", "member", "bed",
  "identificationID", "identificationQualifier", "typeStatus",
  "identifiedBy", "dateIdentified", "identificationReferences",
  "identificationVerificationStatus", "identificationRemarks", "taxonID",
  "scientificNameID", "acceptedNameUsageID", "parentNameUsageID",
  "originalNameUsageID", "nameAccordingToID", "namePublishedInID",
  "taxonConceptID", "scientificName", "acceptedNameUsage",
  "parentNameUsage", "originalNameUsage", "nameAccordingTo",
  "namePublishedIn", "namePublishedInYear", "higherClassification",
  "kingdom", "phylum", "class", "order", "family", "genus", "subgenus",
  "specificEpithet", "infraspecificEpithet", "taxonRank",
  "verbatimTaxonRank", "scientificNameAuthorship", "vernacularName",
  "nomenclaturalCode", "taxonomicStatus", "nomenclaturalStatus",
  "taxonRemarks", "measurementID", "measurementType", "measurementValue",
  "measurementAccuracy", "measurementUnit", "measurementDeterminedBy",
  "measurementDeterminedDate", "measurementMethod", "measurementRemarks",
  "resourceRelationshipID", "resourceID", "relatedResourceID",
  "relationshipOfResource", "relationshipAccordingTo",
  "relationshipEstablishedDate", "relationshipRemarks"
);

our @Auxiliary = (
  "_completeness", "_incomplete", "_updated", "_id",
  "_info", "_warnings", "_errors"
);

my @basisofrecord = (
  "PreservedSpecimen", "FossilSpecimen", "LivingSpecimen",
  "HumanObservation", "MachineObservation"
);

sub disable_plugin {
  my ($package, $remove) = @_;
  @PLUGINS = grep { my $id = s/^DwC::Plugin:://r; $id ne $remove } @PLUGINS;
}

sub expand {
  my ($dwc, @terms) = @_;
  foreach my $term (@terms) {
    $$dwc{$term} = "" unless $$dwc{$term};
  }
}

sub new {
  my $me = shift;
  my $record = shift;

  $$record{_completeness} = "";
  $$record{_incomplete} = "";
  $$record{_updated} = "";
  $$record{_id} = "";

  $$record{info} = [];
  $$record{error} = [];
  $$record{warning} = [];

  $$record{"dcterms:modified"} = "";

  if($ENV{DWC_BASIS}) {
    $$record{basisOfRecord} = $ENV{DWC_BASIS};
  }

  return bless $record;
}

sub reset {
  my $me = shift;
  $$me{info} = [];
  $$me{error} = [];
  $$me{warning} = [];
}

sub triplet {
  my $me = shift;
  if(!$$me{institutionCode} || !$$me{collectionCode} || !$$me{catalogNumber}) {
    die "Missing triplet ingredients";
  }
  return "$$me{institutionCode}:$$me{collectionCode}:$$me{catalogNumber}";
}

sub log {
  my ($me, $level, $message, $type) = @_;
  $message =~ s/\n$//;
  push(@{$$me{$level}}, [ $message, $type ]);
}

sub validate {
  my ($me) = @_;
  if(!$$me{basisOfRecord} || !grep(/^$$me{basisOfRecord}$/, @basisofrecord)) {
    $me->log("error", "Invalid basisOfRecord", "core");
  }
  if(!$$me{occurrenceID}) {
    $me->log("error", "No occurrenceID", "core");
  }

  for my $plugin ($me->plugins) {
    $plugin->validate($me) if $plugin->can("validate");
  }
}

sub clean {
  my ($me) = @_;

  if(!$ENV{DWC_HANDSOFF}) {
    my $bor = $$me{basisOfRecord} || "Occurrence";
    $$me{basisOfRecord} = "PreservedSpecimen" if $bor eq "Preserved specimen";
    $$me{basisOfRecord} = "FossilSpecimen" if $bor eq "Fossil specimen";
    $$me{basisOfRecord} = "LivingSpecimen" if $bor eq "Living specimen";
    $$me{basisOfRecord} = "HumanObservation" if $bor eq "Human observation";
    $$me{basisOfRecord} = "MachineObservation" if $bor eq "Machine observation";
  }

  for my $plugin ($me->plugins) {
    $plugin->clean($me) if $plugin->can("clean");
  }
}

sub judge {
  my ($me) = @_;
  for my $plugin ($me->plugins) {
    $plugin->judge($me) if $plugin->can("judge");
  }
}

sub augment {
  my ($me) = @_;
  for my $plugin ($me->plugins) {
    $plugin->augment($me) if $plugin->can("augment");
  }
}

sub unknown {
  my ($me) = @_;
  my @terms = (@Terms, @Auxiliary, @DCTerms);
  foreach my $key (keys %$me) {
    if($key =~ /^warning|error|info$/) { next };

    if(!grep(/^$key$/, @terms)) {
      $me->log("error", "Unknown term: $key", "core");
    }
  }
}

sub printcsv {
  my ($me, $fh, $fields) = @_;

  $$me{_info} = encode_json($$me{info});
  $$me{_warnings} = encode_json($$me{warning});
  $$me{_errors} = encode_json($$me{error});
  $$me{"dcterms:modified"} = "";
  $$me{"dcterms:license"} = "";

  use warnings FATAL => 'all';
  my $row = join("\t", @{$me}{@$fields});
  $row =~ s/\"/'/g;
  say $fh $row;
}

1;

__END__

=head1 NAME

DwC - Darwin Core

=head1 SYNOPSIS

  use DwC;

  my $record = DwC->new({
    occurrenceID => "ff542953-3d5c-4edf-9411-50473a6da98e",
    basisOfRecord => "HumanObservation", 
    scientificName => "Lupus lupus"
  });

  $record->printcsv(\*STDERR, @DwC::Terms);

  $record->validate();

  $record->clean();

  $record->augment();

=head1 DESCRIPTION

The base DwC package is purposefully extremely minimal, and instead relies on
plugins to perform cleaning, validation and transformation.

=head1 AUTHOR

umeldt, E<lt>chris@svindseth.jptE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by umeldt

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.24.3 or,
at your option, any later version of Perl 5 you may have available.

=cut
