# plotting SBS and ID counts from Gene as bar charts 
# v1, written for unclean files from WGS 30x batch1 only

# loading libraries
library(reshape2)
library(ggplot2)
library(paletteer)
library(tidyverse)
library(data.table)

# loading mutation data
subs <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch1_30x/caveman.txt", sep = "\t", header = T)
ids <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch1_30x/unfiltered_indel_classified_89.txt", sep = "\t", header = T)
head(subs)
head(ids)

# simplify the sample names
subs$Sample <- lapply(subs$Sample, function(x) {sub("_vs_HCEC-MC", "", x)})
print(subs$Sample)
# remove unsuccessful CRISPR2 KOs from the subs table 
subs <- subs[!(subs$Sample %in% c("A6-1", "A6-2", "A5A", "A5B", "A6A", "A6B", "B7A", "B7B", "B8A", "B8B", "C7A", "C7B", "C8A", "C8B")), ]
print(unique(subs$Sample)) # check if it worked

# extract sample names from the subs file
sample_id_subs <- unlist(unique(subs$Sample))
# count the number of subs per sample (number of rows)
sub_counts <- sapply(sample_id_subs, function(sample) {
  sum(subs$Sample==sample)
})

# add genotype information to subs
KO_subs <- c("MLH1-/-", "MLH1-/-", "MSH6-/-", "MSH6-/-", "MSH6-/-", "MSH3-/-", "MLH1-/- MSH6-/- (sim)", "MSH3-/-", "MSH3-/-", "MSH6-/-", "MSH3-/-", "MBD4-/-", "MBD4-/-", "WT", "WT", "MLH1-/- (PC)")
sub_counts_df <- data.frame(sample=sample_id_subs, KO=KO_subs, sub_count=sub_counts) # assembling the read count data frame
print(sub_counts_df)
sub_counts_df <- sub_counts_df[c(14:16, 1:3, 10, 4:6, 11, 8:9, 12:13, 7), ] # reorder samples
rownames(sub_counts_df) <- NULL # converting row names into numbers
print(sub_counts_df)

# filtering the unsuccessful CRISPR2 from the ids table
ids <- ids[!(ids$Sample %in% c("A6-1","A6-2", "A5A", "A5B", "A6A", "A6B", "B7A", "B7B", "B8A", "B8B", "C7A", "C7B", "C8A", "C8B")), ]
ids <- ids[ ,1:11] # filtering out the classification info
head(ids)

# extract sample names from the ids file
sample_id_ids <- unlist(unique(ids$Sample))
# count the number of subs per sample (number of rows)
id_counts <- sapply(sample_id_ids, function(sample) {
  sum(ids$Sample==sample)
})
print(id_counts)

# add genotype information to indels
KO_ids <- c("MLH1-/-", "MLH1-/-", "MSH6-/-", "MSH3-/-", "MSH6-/-", "MBD4-/-", "MBD4-/-", "MLH1-/- (PC)", "MSH6-/-", "MSH6-/-", "MSH3-/-", "MLH1-/- MSH6-/- (sim)", "MSH3-/-", "MSH3-/-", "WT", "WT")
id_counts_df <- data.frame(sample=sample_id_ids, KO=KO_ids, id_count=id_counts) # assembling the read count data frame
rownames(id_counts_df) <- NULL # converting row names into numbers
print(id_counts_df)

# ordering ids to match subs
id_counts_ordered <- id_counts_df[match(sub_counts_df$sample, id_counts_df$sample), ]
rownames(id_counts_ordered) <- NULL
print(id_counts_ordered)
# joining both mutation types
df_joint <- data.frame(sample=sub_counts_df$sample, KO=sub_counts_df$KO, sub_count=sub_counts_df$sub_count, id_count=id_counts_ordered$id_count)
print(df_joint)

# melting the df to plot a bar chart
final_df <- melt(df_joint, c("sample", "KO"))
print(final_df)
# generating summary statistics
all_good_summary <- ddply(final_df, c("KO","variable"), summarise, NChild=length(value),mean=mean(value),sd=sd(value)) # counts the number of sbs and id for each ko, calculates summary statistics
all_good_summary[is.na(all_good_summary)] <- 0 # replace NAs with zeroes
print(all_good_summary)

summary_ordered <- all_good_summary[c(13:14, 5:6, 3:4, 11:12, 9:10, 1:2, 7:8), ] # reorder
rownames(summary_ordered) <- NULL
print(summary_ordered)

# download the colours
my_colours <- paletteer::paletteer_d("tvthemes::Bismuth")
my_colours2 <- paletteer::paletteer_d("PrettyCols::Neon")
my_colours3 <- paletteer::paletteer_d("MetBrewer::Hokusai3")
my_colours4 <- paletteer::paletteer_d("LaCroixColoR::PassionFruit")
my_colours5 <- paletteer::paletteer_d("rcartocolor::Prism")

# plot the bar chart
p <- ggplot(summary_ordered, aes(x=KO, y=mean, fill=variable)) +
  geom_bar(position=position_dodge(), stat="identity",width=0.8) + # position_dodge - bars for different mutation type appear side by side; # stat=identity - no statistical transformation applied to the data (have already calculated the mean)
  geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd),
                width=.2,                    # Width of the error bars
                position=position_dodge(.8))+ geom_point(data=final_df,aes(x=KO, y=value),position=position_jitterdodge(0.1),show.legend = FALSE)
p <- p+scale_x_discrete(limits = c("WT","MLH1-/- (PC)","MLH1-/-","MSH6-/-","MSH3-/-","MBD4-/-","MLH1-/- MSH6-/- (sim)"))+scale_fill_manual(values=c("#CB64C0FF", "#3294DDFF"), labels = c("Substitutions", "Indels")) # sets order to the categorical variables on the x-axis
p <- p+theme(axis.text.x=element_text(angle=45,size=12,colour = "black",hjust=0.9,vjust=1), # horizontal and vertical justification
             axis.text.y=element_text(size=12,colour = "black"),
             axis.title.x = element_text(size=17, vjust=+10),
             axis.title.y = element_text(size=17, vjust=+2.3),
             plot.title = element_text(size=10),
             panel.grid.minor.x=element_blank(), # hides grid lines
             panel.grid.major.x=element_blank(),
             panel.grid.major.y = element_blank(),
             panel.grid.minor.y = element_blank(),
             panel.background = element_rect(fill = "white"),
             panel.border = element_rect(colour = "black", fill=NA),
             legend.position = c(0.85, 0.85),
             legend.title = element_blank(),
             legend.text = element_text(size=12),
             legend.key.size = unit(8, "mm")
             )
p <- p+labs(
  x = "Genotype",
  y = "Mean mutation count"
)

print(p)

