library(openxlsx)

# Define the folder containing .txt files
folder_path <- "/Users/zofiapiszka/Desktop/cut&tag/batch2/kmetstat/output"

# Get a list of all .txt files in the folder
file_list <- list.files(path = folder_path, pattern = "\\.txt$", full.names = TRUE)

# Read all .txt files into a list using lapply
txt_data <- lapply(file_list, read.table, header = TRUE, sep = "\t", stringsAsFactors = FALSE)

# adding read counts by column
indices <- seq(2, length(txt_data), by = 2)

txt_data_merged1 <- lapply(indices, function(i) {
  txt_data[[i]] + txt_data[[i-1]]
})

# adding every two rows
txt_data_merged2 <- lapply(txt_data_merged1, function(df) {
  # Convert data frame to a matrix
  mat <- as.matrix(df)
  # Sum every two successive rows
  summed_mat <- rowSums(matrix(mat, nrow = nrow(mat) / 2, byrow = TRUE))
  # Convert back to a data frame
  return(as.data.frame(summed_mat))
})

# generating sample names
names <- strsplit(sapply(txt_data_merged1, colnames), "_")
names <- lapply(names, function(i) {paste(i[1:5], collapse = "_")})
names(txt_data_merged2) <- names

# generating PTM names
PTMs <- list("IgG", "H3k4me1",	"H3k4me2",	"H3k4me3",	"H3k9me1", 	"H3k9me2",	"H3k9me3", 	"H3k27me1",	"H3k27me2",	"H3k27me3",	"H3k36me1",	"H3k36me2",	"H3k36me3",	"H4k20me1",	"H4k20me2",	"H4k20me3")

# transposing the data frames
txt_data_t <- lapply(txt_data_merged2, t)
# joining into a single data frame
txt_data_stacked <- do.call(rbind, txt_data_t)

# naming the rows and columns in the data frame
txt_data_df <- as.data.frame(txt_data_stacked, row.names = names)
colnames(txt_data_df) <- PTMs

# write to Excel file
write.xlsx(txt_data_df, "/Users/zofiapiszka/Desktop/cut&tag/batch2/kmetstat/kmetstat.xlsx", sheetName = "Sheet1", rowNames = TRUE)
