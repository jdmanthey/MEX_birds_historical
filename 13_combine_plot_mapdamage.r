options(scipen=999)


x_files <- list.files(pattern="^mapdamage")

# combine all 108 output files
all_damage <- list()
for(a in 1:length(x_files)) {
	all_damage[[a]] <- read.table(paste0(x_files[a],"/misincorporation.txt"), header=T)
}
all_damage <- do.call(rbind, all_damage)

write.table(all_damage, "_all_map_damage_output.txt", row.names=F, quote=F, sep="\t")





# read in popmap
popmap <- read.table("popmap_stats.txt", header=T)
species <- sapply(strsplit(popmap$Individual, "_"), "[[", 1)
time <- sapply(strsplit(popmap$PopName, "_"), "[[", 1)
popmap <- cbind(popmap, species, time)
unique_species <- unique(species)

# read in damage file
x <- read.table("_all_map_damage_output.txt", header=T)

# positions to include for plot
plot_positions <- seq(from=1, to=50, by=1)

# time periods to include
time_periods <- c("hist", "mod")

# get the mean, min, max values for modern and historical samples for each species
output_species <- c()
output_position <- c()
output_time <- c()
output_mean <- c()
output_min <- c()
output_max <- c()
output_type <- c()

for(a in 1:length(unique_species)) {
	a_rep <- x[x$Sample %in% popmap$Individual[popmap$species == unique_species[a]] & x$End == "5p" & x$Std == "+",]
	for(b in 1:length(time_periods)) {
		b_rep <- a_rep[a_rep$Sample %in% popmap$Individual[popmap$species == unique_species[a] & popmap$time == time_periods[b]], ]
		for(d in plot_positions) {
			d_rep <- b_rep[b_rep$Pos == d,]
			# get the frequency of C->T / total C positions for each individual
			d_rep <- d_rep$C.T / d_rep$C
		
			# output
			output_species <- c(output_species, unique_species[a])
			output_position <- c(output_position, d)
			output_time <- c(output_time, time_periods[b])
			output_mean <- c(output_mean, mean(d_rep))
			output_min <- c(output_min, min(d_rep))
			output_max <- c(output_max, max(d_rep))
			output_type <- c(output_type, "c_t")
		}
		# frequency of all transitions
		for(d in plot_positions) {
			d_rep <- b_rep[b_rep$Pos == d,]
			# get the frequency of C->T / total C positions for each individual
			d_rep <- (d_rep$G.A / d_rep$G + d_rep$A.G / d_rep$A + d_rep$T.C / d_rep$T) / 3
		
			# output
			output_species <- c(output_species, unique_species[a])
			output_position <- c(output_position, d)
			output_time <- c(output_time, time_periods[b])
			output_mean <- c(output_mean, mean(d_rep))
			output_min <- c(output_min, min(d_rep))
			output_max <- c(output_max, max(d_rep))
			output_type <- c(output_type, "transitions")
		}
	}
}

output <- data.frame(species=as.character(output_species), position=as.numeric(output_position), time=as.character(output_time), mean=as.numeric(output_mean), min=as.numeric(output_min), max=as.numeric(output_max), type=as.character(output_type))



library(RColorBrewer)
cols <- brewer.pal(12,"Paired")

# plotting
par(mar=c(5,5,1,1))
par(mfrow=c(1,4))
position_jitter <- 0.15
for(a in 1:length(unique_species)) {
	a_rep <- output[output$species == unique_species[a],]
	
	# plot C -> T frequency
	a_historical <- a_rep[a_rep$time == "hist" & a_rep$type == "c_t",]
	a_historical$position <- a_historical$position - position_jitter
	a_modern <- a_rep[a_rep$time == "mod" & a_rep$type == "c_t",]
	a_modern$position <- a_modern$position + position_jitter
	
	plot(c(-1,-1), pch=19, cex=0.1, col="white", xlim=c(1, max(plot_positions)), ylim=c(0, 0.035), xlab="Distance From Read End (bp)", ylab="Frequency")
	
	# add range bars
	for(b in 1:nrow(a_historical)) {
		lines(rbind(c(a_historical$position[b], a_historical$min[b]), c(a_historical$position[b], a_historical$max[b])), col=cols[3])
		lines(rbind(c(a_modern$position[b], a_modern$min[b]), c(a_modern$position[b], a_modern$max[b])), col=cols[1])
	}
	
	lines(a_historical$position, a_historical$mean, col=cols[3])

	lines(a_modern$position, a_modern$mean, col=cols[1])

	points(a_historical$position, a_historical$mean, cex=0.8, pch=19, col=cols[3])

	points(a_modern$position, a_modern$mean, cex=0.8, pch=19, col=cols[1])
	
	
	# plot all transitions frequency (except C -> T)
	a_historical <- a_rep[a_rep$time == "hist" & a_rep$type == "transitions",]
	a_historical$position <- a_historical$position - position_jitter
	a_modern <- a_rep[a_rep$time == "mod" & a_rep$type == "transitions",]
	a_modern$position <- a_modern$position + position_jitter
		
	# add range bars
	for(b in 1:nrow(a_historical)) {
		lines(rbind(c(a_historical$position[b], a_historical$min[b]), c(a_historical$position[b], a_historical$max[b])), col=cols[4])
		lines(rbind(c(a_modern$position[b], a_modern$min[b]), c(a_modern$position[b], a_modern$max[b])), col=cols[2])
	}
	
	lines(a_historical$position, a_historical$mean, col=cols[4])

	lines(a_modern$position, a_modern$mean, col=cols[2])

	points(a_historical$position, a_historical$mean, cex=0.8, pch=19, col=cols[4])

	points(a_modern$position, a_modern$mean, cex=0.8, pch=19, col=cols[2])
}


















