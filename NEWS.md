<!-- NEWS.md is maintained by https://fledge.cynkra.com, contributors should not edit this file -->

# jmbr 0.0.0.9132 (2025-01-07)

## Continuous integration

- Check if rjags can be loaded (#43).


# jmbr 0.0.0.9131 (2024-12-22)

- Updated to testthat3 (#40).


# jmbr 0.0.0.9130 (2024-12-14)

## Continuous integration

- Update macOS installation to avoid failures (#39).

- Update locking workflow to avoid failures (#38).


# jmbr 0.0.0.9129 (2024-12-09)

## Continuous integration

- Avoid failure in fledge workflow if no changes (#37).


# jmbr 0.0.0.9128 (2024-12-08)

## Continuous integration

- Fetch tags for fledge workflow to avoid unnecessary NEWS entries (#36).


# jmbr 0.0.0.9127 (2024-11-27)

## Continuous integration

- Explicit permissions (#35).

- Download JAGS on Windows follows HTTP redirects (#24, #30).


# jmbr 0.0.0.9126 (2024-11-26)

## Continuous integration

- Use styler from main branch (#34).


# jmbr 0.0.0.9125 (2024-11-25)

## Continuous integration

- Need to install R on Ubuntu 24.04 (#33).

- Use Ubuntu 24.04 and styler PR (#31).


# jmbr 0.0.0.9124 (2024-11-22)

## Continuous integration

  - Correctly detect branch protection (#29).


# jmbr 0.0.0.9123 (2024-11-18)

## Continuous integration

  - Use stable pak (#28).


# jmbr 0.0.0.9122 (2024-11-11)

## Continuous integration

  - Trigger run (#27).
    
      - ci: Trigger run
    
      - ci: Latest changes


# jmbr 0.0.0.9121 (2024-11-02)

  - Internal changes only.


# jmbr 0.0.0.9120 (2024-10-28)

## Continuous integration

  - Trigger run (#26).

  - Use pkgdown branch (#25).
    
      - ci: Use pkgdown branch
    
      - ci: Updates from duckdb


# jmbr 0.0.0.9119 (2024-09-15)

## Continuous integration

  - Install via R CMD INSTALL ., not pak (#23).
    
      - ci: Install via R CMD INSTALL ., not pak
    
      - ci: Bump version of upload-artifact action


# jmbr 0.0.0.9118 (2024-08-31)

## Continuous integration

  - Install local package for pkgdown builds.

  - Improve support for protected branches with fledge.

  - Improve support for protected branches, without fledge.


# jmbr 0.0.0.9117 (2024-08-17)

## Continuous integration

- Sync with latest developments.


# jmbr 0.0.0.9116 (2024-08-11)

## Continuous integration

- Fix edge case of no suggested packages.


# jmbr 0.0.0.9115 (2024-08-10)

## Chore

- Auto-update from GitHub Actions.

  Run: https://github.com/poissonconsulting/jmbr/actions/runs/10326788569

## Continuous integration

- Use workflows from actions-sync.

- Sync rcc workflows.

- Sync pkgdown workflows.

- Sync codecov workflows.

## Uncategorized

- Merge pull request #22 from poissonconsulting/f-style.


# jmbr 0.0.0.9114 (2023-10-02)

## Bug fixes

- Use `model(code = )` in tests, stabilize (#21).

## Uncategorized

- Merge pull request #20 from poissonconsulting/b-glance.


# jmbr 0.0.0.9113 (2023-07-17)

- Switched from mbr to embr.
