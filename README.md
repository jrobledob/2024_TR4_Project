# 2024_TR4_Project

#### Data_from_surveys_and_direct_sources:

has data that is coming direclty form summaries of the surveys and EKEs and direct sources like statistics from the ministry of agriculture. Files in this folder:



#### Data_processed

Has data that involves some steps in the functions and code of this repository. Files in this folder:


#### get_matrices_planting_material_trade

This script conducts a set the adjacency matrices of movement of banana and plantain planting materials between departments. The analysis considers both formal and informal networks, incorporates rare events, and adjusts for the informality proportions of each department.

###### Data Preparation

####### Network of Planting Material

- **Source**: The initial data is sourced from [`DATA_MAP_Network_of_Planting_Material_2023_12_08.csv`](https://github.com/jrobledob/2024_TR4_Project/blob/main/Data_from_surveys_and_direct_sources/DATA_MAP_Network_of_Planting_Material_2023_12_08.csv).
- **Categories**:
  - **BC**: Banana Certified
  - **BN**: Banana Non-certified
  - **PC**: Plantain Certified
  - **PN**: Plantain Non-certified
- **Process**:
  - Created binary adjacency matrices for each category to indicate the presence (1) or absence (0) of planting material movement between departments.
  - Verified that the binary matrices accurately represent the original data.

### Relative Exchange Proportions

- **Sources**:
  - Banana proportions: [`DATA_MAP_Rel_Prop_banana_Network_of_Planting_Material.csv`](https://github.com/jrobledob/2024_TR4_Project/blob/main/Data_from_surveys_and_direct_sources/DATA_MAP_Rel_Prop_banana_Network_of_Planting_Material.csv)
  - Plantain proportions: [`DATA_MAP_Rel_Prop_plantain_Network_of_Planting_Material.csv`](https://github.com/jrobledob/2024_TR4_Project/blob/main/Data_from_surveys_and_direct_sources/DATA_MAP_Rel_Prop_plantain_Network_of_Planting_Material.csv)
- **Informality Proportions**:
  - Obtained from [`SUP_Percentage_of_informal_planting_material_by_department.csv`](https://github.com/jrobledob/2024_TR4_Project/blob/main/Data_from_surveys_and_direct_sources/SUP_Percentage_of_informal_planting_material_by_department.csv).
  - Adjusted department names to ensure consistency across datasets.
  - Converted percentage values to proportions and imputed missing values with the median.

## Scenarios

Two scenarios were developed to model the network:

### Scenario 1: Without Rare Events

- **Approach**:
  - Calculated the demand of each department by multiplying the relative exchange proportions with the binary adjacency matrices.
  - Adjusted the matrices based on the informality proportions:
    - **Formal Networks**: Multiplied by `(1 - informality proportion)` for each department.
    - **Informal Networks**: Multiplied by the `informality proportion` for each department.
- **Outputs**:
  - Adjusted adjacency matrices representing the movement of planting materials without considering rare events:
    - `DATA_MAP_Seed_network_demand_Banana_Formal.csv`
    - `DATA_MAP_Seed_network_demand_Banana_INFormal.csv`
    - `DATA_MAP_Seed_network_demand_Plantain_Formal.csv`
    - `DATA_MAP_Seed_network_demand_Plantain_INFormal.csv`

### Scenario 2: Including Rare Events

- **Approach**:
  - Incorporated rare events by assigning a small proportion (`0.0005`) to events without reported exchange proportions.
  - Adjusted the adjacency matrices:
    - Assigned the small proportion to rare events.
    - Normalized each column so that the sum equals 1.
    - Multiplied by the informality proportions as in Scenario 1.
- **Outputs**:
  - Adjusted adjacency matrices including rare events:
    - `DATA_MAP_Rare_Seed_network_demand_Banana_Formal.csv`
    - `DATA_MAP_Rare_Seed_network_demand_Banana_INFormal.csv`
    - `DATA_MAP_Rare_Seed_network_demand_Plantain_Formal.csv`
    - `DATA_MAP_Rare_Seed_network_demand_Plantain_INFormal.csv`

