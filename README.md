## FinWhaleMovs_Med2Atlantic

This repository hosts the code used to perform the correlated random walk state-space model and Hidden-Markov Model described in subsection 2.3.2, as reported in:
> Panigada, V., Feliu-Tena, B., Belda, E. J., Degollada, E., Gallego, V., Nowacek, D. P., Santonja, P., Tort, B, and Panigada, S. (2026).
> Fin Whale Departures from the North-West Mediterranean Sea Reveal Summer Habitat Use in the North Atlantic and Potential Feeding Opportunities. *Under Review.*

## Correspondence with the manuscript
| Script | Manuscript section |
| --- | --- |
| `scripts/aniMotum_momentuHMM.R` | CRW and HMM models — Methods, 2.3.2 |

## Repository Structure
```text
FinWhaleMovs_Med2Atlantic/
├── README.md
├── LICENSE
├── CITATION.cff
├── .gitignore
├── data/
│   └── README.md
└── scripts/
    └── aniMotum_momentuHMM.R
```

## Requirements
The analysis was performed in R 4.5.2. \
Required R libraries:
- `aniMotum` (v1.2-15)
- `momentuHMM` (v2.0.0)
- `dplyr` (v1.2.0)
- `ggplot2` (v4.0.2)

## Input data format
- Format: .csv
- Required columns: `id`, `date` (YYYY-MM-DD HH:MM:SS), `lc`, `lon`, `lat`, `smaj`, `smin`, `eor`. \
> Note: Raw satellite telemetry data are not included in this repository. See the Data Availability section below and data/README.md for additional information.

## How to cite
If you use this code, please cite both the associated article and this repository:
> Panigada, V., Feliu-Tena, B., Belda, E. J., Degollada, E., Gallego, V., Nowacek, D. P., Santonja, P., Tort, B, and Panigada, S. (2026).
> Fin Whale Departures from the North-West Mediterranean Sea Reveal Summer Habitat Use in the North Atlantic and Potential Feeding Opportunities *Submitted.*

> Panigada, V. (2026). *FinWhaleMovs_Med2Atlantic* (Version v1.0.0). Zenodo. [ZENODO DOI]

## Contact
**Viola Panigada**  
Duke University Marine Lab, Beaufort, NC, USA  
Tethys Research Institute, Milano, Italy  
[ORCID: 0009-0003-0719-7790](https://orcid.org/0009-0003-0719-7790)


## License
© 2026 Duke University and collaborators.
Distributed for academic and non-commercial use under a MIT License. See [`LICENSE`](LICENSE) for details. 

------------------------------------------------------------------------
