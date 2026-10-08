# Set Up DiAna Environment

This function sets up the DiAna environment by creating necessary
folders and downloading the DiAna data up to the specified quarter and
DiAna dictionary together with the csv to link drugs with the ATC.

## Usage

``` r
setup_DiAna(quarter = "23Q1", timeout = 1e+05)
```

## Arguments

- quarter:

  The quarter for which to set up the DiAna environment (default is
  "23Q1"). The ones available: 23Q1, 23Q3, 23Q4, 24Q1, 24Q2, 24Q3, 24Q4,
  25Q1, 25Q2, 25Q3, 25Q4.

- timeout:

  The amount of time, in seconds, after which R stops a download if it
  is still unfinished. Default 100000. It may be necessary to increase
  it in the case of a slow connection. The previous value of the
  `timeout` option is restored when the function ends.

## Value

None. The function sets up the environment and downloads data.

## Examples

``` r
if (FALSE) { # \dontrun{
# Set up DiAna environment for the default quarter
# Run only when needed to download the FAERS datasets for the first time
# and at new quarter updates.
setup_DiAna()
} # }
```
