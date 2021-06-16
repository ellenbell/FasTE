#RM_TRIPS
#Author = Chris Butler
#Email = c.butler@uea.ac.uk
#Date = 22/08/19


rm(list = ls())

### set up inputs
i <- '/Users/chrisbutler/Documents/technical_paper/RepeatMasker_Final/no_asterisk' #directory where .out file is located
j <- "noasteriskSample2.fasta.out" #set name of file
k <- '/Users/chrisbutler/Documents/technical_paper' #directory where the repeatmasker library is found (.lib/fasta file)
l <- 'RepeatMasker.lib' #set name of .lib file

#LOAD PACKAGES - ensure these are installed beforehand
library(dplyr)
library(ggplot2)
library(biomartr)
library(seqinr)


#SET UP FUNCTIONS
read_rm1 <- function(file) {
  rm_file <- readr::read_lines(file = file, skip = 2) ##### changed from skip = 3 as this removed the first entry
  rm_file <- lapply(rm_file, function(x) {
    str.res <- unlist(stringr::str_split(x, "\\s+"))[-1]
    str.res <- str.res[1:14]
    return(str.res)
  })
  rm_file <- tibble::as_tibble(do.call(rbind, rm_file))
  colnames(rm_file) <- c(
    "sw_score",
    "perc_div",
    "perc_del",
    "perc_insert",
    "qry_id",
    "qry_start",
    "qry_end",
    "qry_left",
    "matching_repeat",
    "repeat_id",
    "matching_class",
    "no_bp_in_complement",
    "in_repeat_start",
    "in_repeat_end"
  )
  qry_end <- qry_start <- NULL
  
  nrow_before_filtering <- nrow(rm_file)
  
  suppressWarnings(rm_file <- dplyr::mutate(rm_file,
                                            qry_start = as.integer(qry_start),
                                            qry_end = as.integer(qry_end)))
  
  
  rm_file <-
    dplyr::filter(
      rm_file,
      !is.na(qry_start),
      !is.na(qry_end)
    )
  
  rm_file <-
    dplyr::mutate(
      rm_file,
      qry_width = as.integer(qry_end - qry_start + 1L))
  
  nrow_after_filtering <- nrow(rm_file)
  
  
  if ((nrow_before_filtering - nrow_after_filtering) > 0)
    message((nrow_before_filtering - nrow_after_filtering) + 1 , " out of ",nrow_before_filtering," rows ~ ", round(((nrow_before_filtering - nrow_after_filtering) + 1) / nrow_before_filtering, 3) , "% were removed from the imported RepeatMasker file, ",
            "because they contained 'NA' values in either 'qry_start' or 'qry_end'.")
  
  return(rm_file)
}



###load input files
setwd(i)
RM <- read_rm1(j)

setwd(k)
TEsequence <- read.fasta(file = l, seqtype = c("DNA"))


##########
#FILTERING STEPS
##########

# 1) Remove simple repeats
noisonosim <- RM
noisonosim <- noisonosim %>% filter(matching_class != "Simple_repeat") #no simple repeats
noisonosim <- noisonosim %>% filter(matching_class != "Low_complexity") #no low complexity repeats
noisonosim <- noisonosim %>% filter(matching_class != "Satellite") #no satellites
noisonosim <- noisonosim %>% filter(matching_class != "rRNA") #no rRNA
noisonosim <- noisonosim %>% filter(matching_class != "snRNA") #no snRNA
noisonosim <- noisonosim %>% filter(matching_class != "tRNA") #no tRNA
noisonosim <- noisonosim %>% filter(matching_class != "ARTEFACT") #no artefacts





# 2) Merge fragments 
# Extract the length of every  reference sequence and store the results in a vector.
seq_length <- rep(NA,length(TEsequence))
for (f in 1:length(TEsequence)) {
  seq_length[[f]] <- summary(TEsequence[[f]])$length
}

seq_length <- as.data.frame(seq_length)
seq_length$repeat_id <- attr(TEsequence, "name")
seq_length$repeat_id <- gsub('\\#.*','', seq_length$repeat_id) #tidies up repbase naming conventions

#merge 
test <- merge(noisonosim, seq_length, by = "repeat_id") 
test <- dplyr::rename(test, reference_length = seq_length)
test <- test %>%  mutate(., Query_Length = ((qry_end - qry_start) + 1)) #overall length of fragment
test <- test %>% group_by(repeat_id, matching_repeat, qry_id) %>% mutate(., lowextremety = min(qry_start)) #the earliest the fragment appears in the scaffold
test <- test %>% group_by(repeat_id, qry_id, matching_repeat) %>% mutate(., highextremety = max(qry_end))  #the latest the fragment appears in the scaffold


test <- mutate(test, mergedfraglength = ((highextremety - lowextremety)+1)) #overall merged fragment length


test$length_check <- ifelse(test$mergedfraglength <= test$reference_length, "YES", "NO")

test1 <- filter(test, length_check == "YES") #put all cases where the merged fragment length is less than the refbase entry into one database
test2 <- filter(test, length_check == "NO") #put all cases where the merged fragment length is longer than the refbase entry into one database

#####test2#####
#next snippet of code keeps merged elements that should have been merged seperate



test2 <- test2 %>% dplyr::select(-c('lowextremety', 'highextremety', 'mergedfraglength'))

test2 <- rename(test2, lowextremety = qry_start)
test2 <- rename(test2, highextremety = qry_end)
test2 <- rename(test2, mergedfraglength = qry_width)

##########################


noisonosim <- rbind(test1, test2) #merge


noisonosim <- noisonosim %>% dplyr::select(-c(Query_Length, qry_width, in_repeat_start, in_repeat_end, no_bp_in_complement, qry_start, qry_end, qry_left, sw_score)) #remove all these columns
noisonosim$perc_del <- as.numeric(noisonosim$perc_del) #ensure these column are numeric
noisonosim$perc_div <- as.numeric(noisonosim$perc_div)
noisonosim$perc_insert <- as.numeric(noisonosim$perc_insert)

#calculate a new mean perc del across the novel merged fragments copy 
noisonosim <- noisonosim %>% group_by(qry_id, repeat_id, matching_repeat, mergedfraglength) %>% mutate(., Copy_perc_div = mean(perc_div)) 
noisonosim <- noisonosim %>% group_by(qry_id, repeat_id, matching_repeat, mergedfraglength) %>% mutate(., Copy_perc_del = mean(perc_del))
noisonosim <- noisonosim %>% group_by(qry_id, repeat_id, matching_repeat, mergedfraglength) %>% mutate(., Copy_perc_insert = mean(perc_insert))


#remove old 'perc del' values
noisonosim <- noisonosim %>% dplyr::select(-c(perc_div, perc_del, perc_insert))

noisonosim <- dplyr::rename(noisonosim, perc_div = Copy_perc_div) #rename
noisonosim <- dplyr::rename(noisonosim, perc_del = Copy_perc_del)
noisonosim <- dplyr::rename(noisonosim, perc_insert = Copy_perc_insert)


noisonosim <- unique(noisonosim) #this step ensures that what was two fragments now merged is only represented once



# 3)Remove TEs found in different isoforms of the same "gene" 
#########NOTE - this step is not needed when working with genome data##############


noisonosim$Gene <- noisonosim$qry_id #make duplicated transcript file

noisonosim$Gene <- sub("_[^_]+$","", noisonosim$Gene) #removes isoform identifier

noisonosim$isoform <- noisonosim$qry_id #make another duplicated transcript file

noisonosim$isoform <- gsub(".*i","", noisonosim$isoform) #removes isoform identifier


#for a given TE how many isoforms is it found on
noisonosim <- noisonosim %>% group_by(Gene, repeat_id, matching_repeat) %>% mutate(isoform_number = n_distinct(isoform)) 

check <- filter(noisonosim, isoform_number == 1) #if TE is only found in one isoform then no worry



#What about TEs found in multiple isoforms?
check2 <- filter(noisonosim, isoform_number > 1)
#only keep isoform which has the most TE content
check2 <- check2 %>% group_by(repeat_id, qry_id, matching_repeat) %>% mutate(totalTElength_pertranscript = sum(mergedfraglength)) #total TE content per element per transcript (ie if fragments were merged)
check2 <- check2 %>% ungroup() %>% group_by(repeat_id, Gene, matching_repeat) %>% filter(.,totalTElength_pertranscript ==max(totalTElength_pertranscript))

#however - this will correctly keep two TE fragments on the same isoform but incorrectly keep TEs on different isoforms if they have the same merged length (common)
check2 <- check2 %>% group_by(Gene, repeat_id, matching_repeat) %>% mutate(isoform_number_two = n_distinct(isoform)) #are TEs on same isoform or not?

check3 <- check2 %>% ungroup() %>% filter(isoform_number_two > 1) #check 3 contains those incorrect - found on two different isoforms
check2 <- check2 %>% filter(isoform_number_two == 1) #check 2 contains those correct - fragments found on same isoform
check2 <- check2 %>% dplyr::select(-c(isoform_number_two, totalTElength_pertranscript)) #tidy




check3 <- check3 %>% distinct(Gene, repeat_id, matching_repeat, .keep_all = TRUE) #only keep one instance (at random) if TEs on different isoforms have same merged frag length
#distinct (only keep one entry) if sample, gene, repeat and matching repeat all identical

check3 <- check3 %>% dplyr::select(-c(isoform_number_two, totalTElength_pertranscript)) #tidy


#time to merge those TEs found in only one isoform (check), largest TEs containing isoform if found in multiple isoforms  (keeping both fragments on same isoform if necessary)  (check2), or if no largest TE containing isoform one entry kept at random
check <-as.data.frame(check)
check2 <- as.data.frame(check2)
check3 <- as.data.frame(check3)
finalcheck <- rbind(check, check2, check3)

noisonosim <- as.data.frame(finalcheck)


# 4) remove fragments less than 80bp
noisonosim <- filter(noisonosim, mergedfraglength >= 80)

# 5) Write output file
#quick clean up
noisonosim <- noisonosim %>% dplyr::select(-c(length_check, isoform_number))
noisonosim <- rename(noisonosim, merged_qrystart = lowextremety)
noisonosim <- rename(noisonosim, merged_qryend = highextremety)


setwd(i)
write.csv(noisonosim, file = paste0(j, "_RM_TRIPS.csv"))






