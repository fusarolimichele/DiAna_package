# Install RStudio Snippets from GitHub Repository

This function installs RStudio code snippets from a specified GitHub
repository.

## Usage

``` r
snippets_install_github(repo = "fusarolimichele/DiAna_snippets")
```

## Arguments

- repo:

  Character. The GitHub repository containing the snippets. Default is
  "fusarolimichele/DiAna_snippets".

## Value

None. This function is called for its side effects, which include
installing RStudio snippets.

## Examples

``` r
if (FALSE) { # \dontrun{
# This example is using internet connection to download snippets to initialize scripts.
# It automatically includes snippets among the ones available to the user.
# It should not be run at the check.
snippets_install_github()
} # }
```
