# Sample Data on Therapy Details

A dataset containing details on therapeutic interventions, including
drug therapy start and end dates, duration in days, time to onset of
events related to therapy, and event dates.

## Usage

``` r
sample_Ther
```

## Format

A data.table with 7 variables:

- primaryid:

  Unique identifier for each individual (`numeric`).

- drug_seq:

  Sequence number identifying the specific drug within the report
  (`integer`).

- start_dt:

  Date of first administration of the therapy (`numeric`), in YYYYMMDD
  format.

- dur_in_days:

  Duration of therapy in days (`numeric`).

- end_dt:

  Date of last administration of the therapy (`numeric`), in YYYYMMDD
  format.

- time_to_onset:

  Time to onset of related events in days (`numeric`). We only have a
  TTO per drug, independently of the event, since we only have an event
  date for each report. The TTO is calculated as the difference between
  the event date and the start date.

- event_dt:

  Date of occurrence of the events (one per report even if there are
  multiple events) (`integer`), in YYYYMMDD format.

## Source

https://github.com/fusarolimichele/DiAna

## Details

This subset dataset provides detailed information on therapeutic
interventions, It facilitates analysis of therapy durations, and onset
times.
