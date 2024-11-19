# ## Network analysis:
#   
# This section perform the analysis of the banana and plantain planting material and stakeholder movement network.
# 
# ### Preparing the data set for the network analysis
# 
# #### Network of planting material


# Upload the network of panting material from github
net_plant_mat<- read.csv("https://raw.githubusercontent.com/jrobledob/2024_TR4_Project/refs/heads/main/Data_from_surveys_and_direct_sources/DATA_MAP_Network_of_Planting_Material_2023_12_08.csv", header = TRUE, row.names = 1)
head(net_plant_mat)

# 
# The data set has more than one category by cell. First we will check what are all the categories that are in the data set. They should be: BC, BN, PC, PN for banana registerd and non-registered and plantain registered and non-registered, respectively.


# Unlist the data to get all entries in a single vector
all_values <- unlist(net_plant_mat)
# Filter out the zeroes if they are not needed
all_values <- all_values[all_values != "0"]
# Split the comma-separated values and unlist again
all_values_split <- unlist(strsplit(all_values, ","))
# Get unique values
unique_values <- unique(all_values_split)
# Display the unique values
print(unique_values)

# 
# The data set is correctly formatted. Now we will need to create a binary matrix for each category (four in total --\> "BC" "BN" "PN" "PC"). We will create a matrix of the same size as the original data set, but with 1s and 0s. 1s will indicate that the category is present in the cell, and 0s will indicate that it is not.


# Get the dimensions of the original data
n_rows <- nrow(net_plant_mat)
n_cols <- ncol(net_plant_mat)
# Initialize a list to store the binary matrices for each category
binary_matrices <- list()
# Define the four categories
categories <- c("BC", "BN", "PN", "PC")
# Loop through each category
for (category in categories) {
  # Initialize an empty matrix of the same size as net_plant_mat with 0s
  binary_matrix <- matrix(0, nrow = n_rows, ncol = n_cols)
  # Loop through each cell in the data frame
  for (i in 1:n_rows) {
    for (j in 1:n_cols) {
      # Check if the category is present in the current cell
      if (grepl(category, net_plant_mat[i, j])) {
        binary_matrix[i, j] <- 1
      }
      
    }
  }
  # Store the binary matrix in the list with the category name as the key
  binary_matrices[[category]] <- binary_matrix
  # Convert the matrix to a data frame and assign row and column names
  binary_df <- as.data.frame(binary_matrix)
  rownames(binary_df) <- rownames(net_plant_mat)
  colnames(binary_df) <- colnames(net_plant_mat)
  binary_matrices[[category]] <- binary_df
}
# 
# 
# Check that the unique categories between the binary data sets and the original data set is the same.


# Unlist the data to get all entries in a single vector
all_values <- unlist(net_plant_mat)
# Filter out the zeroes if they are not needed
all_values <- all_values[all_values != "0"]
# Split the comma-separated values and unlist again
all_values_split <- unlist(strsplit(all_values, ","))
# Get unique values
unique_original_categories <- unique(all_values_split)
# Loop through each category and check if the binary matrix is correct
for (category in categories) {
  # Get the corresponding binary matrix
  binary_matrix <- binary_matrices[[category]]
  # Extract the positions where there is a 1 in the binary matrix
  positions <- which(binary_matrix == 1, arr.ind = TRUE)
  # Check if all positions in the original matrix contain the correct category
  for (pos in 1:nrow(positions)) {
    row <- positions[pos, 1]
    col <- positions[pos, 2]
    # Verify the category is in the original matrix at these positions
    if (!grepl(category, net_plant_mat[row, col])) {
      stop(paste("Mismatch found for category", category, "at position (", row, ",", col, ")"))
    }
  }
}
# If the script completes without stopping, it means all checks passed
cat("All binary matrices correctly reflect the categories in the original data set.\n")

# 
# The four data sets will be used later for the network analysis

##### Loading the relative exchenge proportions between departments of planting material
# 
# The data set contains the proportion of the movement of planting material between departments. The data set is divided in two categories: banana and plantain. These two data sets are called:
#   
#            
# -   DATA_MAP_Rel_Prop_banana_Network_of_Planting_Material.csv
# -   DATA_MAP_Rel_Prop_plantain_Network_of_Planting_Material.csv
# 
# 
# With these two data set two scenarios will be created:
#   
#   -   One without rare events, this is just based on the relative exchange proportions of the planting material.
# -   One with rare events, this is based on the relative exchange proportions of the planting material and the events reported in the qualitative exchange of planting material (discussion with experts). For the events where no relative exchange proportions were reported (in the individual surveys), the proportions were set as 0.005 and the proportions were normalized to sum up 1.
# 
# #### Without the rare events
# 
# This will be equal to the demand of each department multiplied by the relative exchange proportions of the planting material.
# 

# read the two data set of the relative proportion of the movement of planting material between departments
rel_prop_banana<- read.csv("https://raw.githubusercontent.com/jrobledob/2024_TR4_Project/refs/heads/main/Data_from_surveys_and_direct_sources/DATA_MAP_Rel_Prop_banana_Network_of_Planting_Material.csv", header = TRUE, row.names = 1)
rel_prop_plantain<- read.csv("https://raw.githubusercontent.com/jrobledob/2024_TR4_Project/refs/heads/main/Data_from_surveys_and_direct_sources/DATA_MAP_Rel_Prop_plantain_Network_of_Planting_Material.csv", header = TRUE, row.names = 1)
#read the adjacency matrix of the EKE discussion of banana planting material formal and informal
con_formal_ban<- binary_matrices$BC
#informal
con_informal_ban<- binary_matrices$BN
# identify the cells that are only in con_formal_ban but not in con_informal_ban
cells_only_informal_ban<- con_informal_ban==1 & con_formal_ban==0
cells_only_formal_ban<- con_informal_ban==0 & con_formal_ban==1

# calculate the adjacency matrix for the common events 
adj_matri_ban_Formal<- rel_prop_banana*con_formal_ban
#Read the proportions of formality and informality per department
proportions_informatlity<- read.csv("https://raw.githubusercontent.com/jrobledob/2024_TR4_Project/refs/heads/main/Data_from_surveys_and_direct_sources/SUP_Percentage_of_informal_planting_material_by_department.csv", header = TRUE)
#Divide the column `percentage_informal` by 100
proportions_informatlity$percentage_informal<- proportions_informatlity$percentage_informal/100
#impute missing values inpercentage_informal with the median of the column
proportions_informatlity$percentage_informal[is.na(proportions_informatlity$percentage_informal)]<- median(proportions_informatlity$percentage_informal, na.rm = TRUE)
# organize the names in the column EKE.expert.in to match the colnames of adj_matri_ban_Formal
dput(unique(proportions_informatlity$EKE.expert.in))
# Create a named vector where the names correspond to the format in adj_matri_ban_Formal
name_mapping<- c("Antioquia"= "Antioquia", 
                 "Atlántico"= "Atlántico", 
                 "Bogotá, D. C."="Bogotá, D. C.", 
                 "Bolívar"= "Bolívar", 
                 "Boyacá"= "Boyacá", 
                 "Caldas"= "Caldas", 
                 "Caquetá"= "Caquetá", 
                 "Cauca"="Cauca", 
                 "Cesar"="Cesar", 
                 "Córdoba"="Córdoba", 
                 "Cundinamarca"= "Cundinamarca",
                 "Chocó"= "Chocó", 
                 "Huila"= "Huila", 
                 "La Guajira"="La.Guajira", 
                 "Magdalena"= "Magdalena", 
                 "Meta"="Meta", 
                 "Nariño"="Nariño", 
                 "Norte De Santander"= "Norte.de.Santander", 
                 "Quindío"= "Quindío", 
                 "Risaralda"= "Risaralda", 
                 "Santander"= "Santander", 
                 "Sucre"="Sucre", 
                 "Tolima"= "Tolima", 
                 "Valle Del Cauca"="Valle.del.Cauca", 
                 "Arauca"= "Arauca", 
                 "Casanare"= "Casanare", 
                 "Putumayo"= "Putumayo", 
                 "Archipiélago De San Andrés, Providencia Y Santa Catalina"= "San.Andrés.y.Providencia", 
                 "Amazonas"= "Amazonas", 
                 "Guainía"= "Guainía", 
                 "Guaviare"="Guaviare", 
                 "Vaupés"= "Vaupés", 
                 "Vichada"="Vichada")
# Replace the names in plantain$Departamento using the mapping
proportions_informatlity$EKE.expert.in <- name_mapping[proportions_informatlity$EKE.expert.in]
#multiply each column of adj_matri_ban_Formal by 1 - the column `percentage_informal` of proportions_informatlity matching the name of the column of adj_matri_ban_Formal with the column `EKE.expert.in` of proportions_informatlity
adj_matri_ban_Formal_2<- adj_matri_ban_Formal

adj_matri_ban_Formal_3<- adj_matri_ban_Formal_2
adj_matri_ban_Formal_3[adj_matri_ban_Formal_3==1]<- 10
adj_matri_ban_Formal_3[is.na(adj_matri_ban_Formal_3)]<- 0
adj_matri_ban_Formal_3<- adj_matri_ban_Formal_3 + con_formal_ban



for (i in colnames(adj_matri_ban_Formal)){
  adj_matri_ban_Formal_2[,i]<- adj_matri_ban_Formal_2[,i]*(1-proportions_informatlity$percentage_informal[proportions_informatlity$EKE.expert.in==i])
}
adj_matri_ban_Formal_2[cells_only_formal_ban]<- adj_matri_ban_Formal[cells_only_formal_ban]



# for the informal network the same process is done
adj_matri_ban_INFormal<- rel_prop_banana*con_informal_ban
adj_matri_ban_INFormal_2<- adj_matri_ban_INFormal
adj_matri_ban_INFormal_3<- adj_matri_ban_INFormal_2
adj_matri_ban_INFormal_3[adj_matri_ban_INFormal_3==1]<- 10
adj_matri_ban_INFormal_3[is.na(adj_matri_ban_INFormal_3)]<- 0
adj_matri_ban_INFormal_3<- adj_matri_ban_INFormal_3 + con_informal_ban

for (i in colnames(adj_matri_ban_INFormal)){
  adj_matri_ban_INFormal_2[,i]<- adj_matri_ban_INFormal_2[,i]*(proportions_informatlity$percentage_informal[proportions_informatlity$EKE.expert.in==i])
}
adj_matri_ban_INFormal_2[cells_only_informal_ban]<- adj_matri_ban_INFormal[cells_only_informal_ban]
# the data sets are adj_matri_ban_INFormal_2 and adj_matri_ban_Formal_2

# the same is done for plantain 
#read the adjacency matrix of the EKE discussion of plantain planting material formal and informal
con_formal_plan<- binary_matrices$PC
#informal
con_informal_plan<- binary_matrices$PN
# identify the cells that are only in con_formal_plan but not in con_informal_plan
cells_only_informal_plan<- con_informal_plan==1 & con_formal_plan==0
cells_only_formal_plan<- con_informal_plan==0 & con_formal_plan==1

# calculate the adjacency matrix for the common events 
adj_matri_plan_Formal<- rel_prop_plantain*con_formal_plan
adj_matri_plan_Formal_2<- adj_matri_plan_Formal

adj_matri_plan_Formal_3<- adj_matri_plan_Formal_2
adj_matri_plan_Formal_3[adj_matri_plan_Formal_3==1]<- 10
adj_matri_plan_Formal_3[is.na(adj_matri_plan_Formal_3)]<- 0
adj_matri_plan_Formal_3<- adj_matri_plan_Formal_3 + con_formal_plan

for (i in colnames(adj_matri_plan_Formal)){
  adj_matri_plan_Formal_2[,i]<- adj_matri_plan_Formal_2[,i]*(1-proportions_informatlity$percentage_informal[proportions_informatlity$EKE.expert.in==i])
}
adj_matri_plan_Formal_2[cells_only_formal_plan]<- adj_matri_plan_Formal[cells_only_formal_plan]

# for the informal network the same process is done
adj_matri_plan_INFormal<- rel_prop_plantain*con_informal_plan
adj_matri_plan_INFormal_2<- adj_matri_plan_INFormal
adj_matri_plan_INFormal_3<- adj_matri_plan_INFormal_2
adj_matri_plan_INFormal_3[adj_matri_plan_INFormal_3==1]<- 10
adj_matri_plan_INFormal_3[is.na(adj_matri_plan_INFormal_3)]<- 0
adj_matri_plan_INFormal_3<- adj_matri_plan_INFormal_3 + con_informal_plan

for (i in colnames(adj_matri_plan_INFormal)){
  adj_matri_plan_INFormal_2[,i]<- adj_matri_plan_INFormal_2[,i]*(proportions_informatlity$percentage_informal[proportions_informatlity$EKE.expert.in==i])
}
adj_matri_plan_INFormal_2[cells_only_informal_ban]<- adj_matri_plan_INFormal[cells_only_informal_ban]
# the data sets are adj_matri_plan_Formal_2 and adj_matri_plan_INFormal_2


#write the data sets
write.csv(adj_matri_plan_Formal_2, "C:/Users/jrobl/OneDrive - University of Florida/Documents/Ph_D_Thesis/2024_TR4_Project/Data_processed/DATA_MAP_Seed_network_demand_Plantain_Formal.csv", row.names = TRUE)
write.csv(adj_matri_plan_INFormal_2, "C:/Users/jrobl/OneDrive - University of Florida/Documents/Ph_D_Thesis/2024_TR4_Project/Data_processed/DATA_MAP_Seed_network_demand_Plantain_INFormal.csv", row.names = TRUE)
write.csv(adj_matri_ban_Formal_2, "C:/Users/jrobl/OneDrive - University of Florida/Documents/Ph_D_Thesis/2024_TR4_Project/Data_processed/DATA_MAP_Seed_network_demand_Banana_Formal.csv", row.names = TRUE)
write.csv(adj_matri_ban_INFormal_2, "C:/Users/jrobl/OneDrive - University of Florida/Documents/Ph_D_Thesis/2024_TR4_Project/Data_processed/DATA_MAP_Seed_network_demand_Banana_INFormal.csv", row.names = TRUE)





#### Including the rare events (adjusting the ad matirx three):

# rare events will have a small proportion
# 
# proportion= 0.0005
# 

proportion = 0.0005
adj_matri_ban_INFormal_3[adj_matri_ban_INFormal_3==1]<- proportion
adj_matri_ban_INFormal_3[adj_matri_ban_INFormal_3>1 & adj_matri_ban_INFormal_3<10]<- (adj_matri_ban_INFormal_3[adj_matri_ban_INFormal_3>1 & adj_matri_ban_INFormal_3<10]) -1
adj_matri_ban_INFormal_3[adj_matri_ban_INFormal_3>=10]<- 1
# normalize (min-max) the columns of adj_matri_ban_INFormal_3 so that the sum of each column is 1
# Step 2: Normalize each column so the sum of each column is 1
normalize_column <- function(x) {
  return (x / sum(x))
}
adj_matri_ban_INFormal_3 <- apply(adj_matri_ban_INFormal_3, 2, normalize_column)

#Make all NaN values equal to 0
adj_matri_ban_INFormal_3[is.na(adj_matri_ban_INFormal_3)]<- 0
### Multiply the adj_matri_ban_INFormal_3 by the demand
adj_matri_ban_INFormal_4<- as.data.frame(adj_matri_ban_INFormal_3)
for (i in colnames(adj_matri_ban_INFormal_4)){
  adj_matri_ban_INFormal_4[,i]<- adj_matri_ban_INFormal_4[,i]*(proportions_informatlity$percentage_informal[proportions_informatlity$EKE.expert.in==i])
}
adj_matri_ban_INFormal_4[cells_only_formal_ban]<- adj_matri_ban_INFormal_3[cells_only_formal_ban]




#adj_matri_plan_INFormal_3
adj_matri_plan_INFormal_3[adj_matri_plan_INFormal_3==1]<- proportion
adj_matri_plan_INFormal_3[adj_matri_plan_INFormal_3>1 & adj_matri_plan_INFormal_3<10]<- (adj_matri_plan_INFormal_3[adj_matri_plan_INFormal_3>1 & adj_matri_plan_INFormal_3<10]) -1
adj_matri_plan_INFormal_3[adj_matri_plan_INFormal_3>=10]<- 1
# normalize (min-max) the columns of adj_matri_plan_INFormal_3 so that the sum of each column is 1
adj_matri_plan_INFormal_3 <- apply(adj_matri_plan_INFormal_3, 2, normalize_column)
#Make all NaN values equal to 0
adj_matri_plan_INFormal_3[is.na(adj_matri_plan_INFormal_3)]<- 0
### Multiply the adj_matri_plan_INFormal_3 by the demand
adj_matri_plan_INFormal_4<- as.data.frame(adj_matri_plan_INFormal_3)
for (i in colnames(adj_matri_plan_INFormal_4)){
  adj_matri_plan_INFormal_4[,i]<- adj_matri_plan_INFormal_4[,i]*(proportions_informatlity$percentage_informal[proportions_informatlity$EKE.expert.in==i])
}
adj_matri_plan_INFormal_4[cells_only_formal_ban]<- adj_matri_plan_INFormal_3[cells_only_formal_ban]





#adj_matri_plan_Formal_3
adj_matri_plan_Formal_3[adj_matri_plan_Formal_3==1]<- proportion
adj_matri_plan_Formal_3[adj_matri_plan_Formal_3>1 & adj_matri_plan_Formal_3<10]<- (adj_matri_plan_Formal_3[adj_matri_plan_Formal_3>1 & adj_matri_plan_Formal_3<10]) -1
adj_matri_plan_Formal_3[adj_matri_plan_Formal_3>=10]<- 1
# normalize (min-max) the columns of adj_matri_plan_Formal_3 so that the sum of each column is 1
adj_matri_plan_Formal_3 <- apply(adj_matri_plan_Formal_3, 2, normalize_column)
#Make all NaN values equal to 0
adj_matri_plan_Formal_3[is.na(adj_matri_plan_Formal_3)]<- 0
### Multiply the adj_matri_plan_Formal_3 by the demand
adj_matri_plan_Formal_4<- as.data.frame(adj_matri_plan_Formal_3)
for (i in colnames(adj_matri_plan_Formal_4)){
  adj_matri_plan_Formal_4[,i]<- adj_matri_plan_Formal_4[,i]*(1-proportions_informatlity$percentage_informal[proportions_informatlity$EKE.expert.in==i])
}
adj_matri_plan_Formal_4[cells_only_formal_ban]<- adj_matri_plan_Formal_3[cells_only_formal_ban]




#adj_matri_ban_Formal_3
adj_matri_ban_Formal_3[adj_matri_ban_Formal_3==1]<- proportion
adj_matri_ban_Formal_3[adj_matri_ban_Formal_3>1 & adj_matri_ban_Formal_3<10]<- (adj_matri_ban_Formal_3[adj_matri_ban_Formal_3>1 & adj_matri_ban_Formal_3<10]) -1
adj_matri_ban_Formal_3[adj_matri_ban_Formal_3>=10]<- 1
# normalize (min-max) the columns of adj_matri_ban_Formal_3 so that the sum of each column is 1
adj_matri_ban_Formal_3 <- apply(adj_matri_ban_Formal_3, 2, normalize_column)
#Make all NaN values equal to 0
adj_matri_ban_Formal_3[is.na(adj_matri_ban_Formal_3)]<- 0
### Multiply the adj_matri_ban_Formal_3 by the demand
adj_matri_ban_Formal_4<- as.data.frame(adj_matri_ban_Formal_3)
for (i in colnames(adj_matri_ban_Formal_4)){
  adj_matri_ban_Formal_4[,i]<- adj_matri_ban_Formal_4[,i]*(1-proportions_informatlity$percentage_informal[proportions_informatlity$EKE.expert.in==i])
}
adj_matri_ban_Formal_4[cells_only_formal_ban]<- adj_matri_ban_Formal_3[cells_only_formal_ban]












write.csv(adj_matri_ban_INFormal_4, "C:/Users/jrobl/OneDrive - University of Florida/Documents/Ph_D_Thesis/2024_TR4_Project/Data_processed/DATA_MAP_Rare_Seed_network_demand_Banana_INFormal.csv", row.names = TRUE)

write.csv(adj_matri_plan_INFormal_4, "C:/Users/jrobl/OneDrive - University of Florida/Documents/Ph_D_Thesis/2024_TR4_Project/Data_processed/DATA_MAP_Rare_Seed_network_demand_Plantain_INFormal.csv", row.names = TRUE)

write.csv(adj_matri_plan_Formal_4, "C:/Users/jrobl/OneDrive - University of Florida/Documents/Ph_D_Thesis/2024_TR4_Project/Data_processed/DATA_MAP_Rare_Seed_network_demand_Plantain_Formal.csv", row.names = TRUE)

write.csv(adj_matri_ban_Formal_4, "C:/Users/jrobl/OneDrive - University of Florida/Documents/Ph_D_Thesis/2024_TR4_Project/Data_processed/DATA_MAP_Rare_Seed_network_demand_Banana_Formal.csv", row.names = TRUE)



