---
title: Steps to take for creating raw data
---


In order to reproduce this paper, you need to use the snapshot. Follow the steps bellow:

1. Visit [https://docs.openalex.org/download-all-data/openalex-snapshot](https://docs.openalex.org/download-all-data/openalex-snapshot) and follow their instructions to download the data

2. Go to the downloaded folder and locate folder *works* within *data* folder.

3. When we downloaded the data this folder included 236 subfolders starting from "updated_date=2023-05-17" to "updated_date=2024-09-27". Last folder had 40 gz files inside named as "part_000.gz" to "part_039.gz".

4. Move these 236 subfolders to your directory, navigate to data folder, and paste them within the works folder in this location (the downloaded version has an empty works file).

5. Now you can use *01_retrieve_data_from_snapshot.R* in the r_script folder to create the raw data used for this study.