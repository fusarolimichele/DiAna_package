# Install RStudio Snippets from GitHub Repository

This function installs RStudio code snippets from a specified GitHub
repository. The downloaded snippets are merged into the user's existing
R snippets file: snippets with the same name are replaced, all the
others are kept.

## Usage

``` r
snippets_install_github(repo = "fusarolimichele/DiAna_snippets")
```

## Arguments

- repo:

  Character. The GitHub repository containing the snippets. Default is
  "fusarolimichele/DiAna_snippets".

## Value

Invisibly, the path of the updated snippets file. This function is
called for its side effects, which include installing RStudio snippets.

## Examples

``` r
if (FALSE) { # \dontrun{
# This example is using internet connection to download snippets to initialize scripts.
# It automatically includes snippets among the ones available to the user.
# It should not be run at the check.
snippets_install_github()
} # }
```
