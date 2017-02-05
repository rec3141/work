# this script uses BLASTN results to roughly calculate and plot the lengths of
# break points in bacterial genomes between long nucleotide repeats

# first run self_blast.sh in a directory of FASTA files

library(ggplot2)
library(plyr)

data.df <- read.table("longest_repeat_99pct.csv",sep="\t")

wholeg <- data.df[which(data.df[,2]==data.df[,4] & data.df[,2]==data.df[,6]),]
rownames(wholeg) <- wholeg[,1]
wholeg <- wholeg[,-1]

#this method ignores repeats that cross the origin of replication... there are a few
data.df <- data.df[which(data.df[,2]!=data.df[,4] | data.df[,2]!=data.df[,6]),]

# problem child/submission has ambiguous bases in nucleotide record
# may need to clean up
#                    V2 V3     V4 V5     V6
#GCA_000569015.1 504587  1 504587  1 504587

#wholeg <- wholeg[-c(which(rownames(wholeg)=="GCA_000569015.1")),]
#data.df <- data.df[-c(which(data.df[,1]=="GCA_000569015.1")),]

seqlengths <- c(seq(51,10001,25),seq(11001,50001,1000),seq(60001,100000001,10000))

unlink("longest_repeat_99pct_stats.csv")

for (genome in rownames(wholeg)) {
    print(genome)
    these.data <- data.df[which(data.df[,1]==genome),]
    
    these.seqlengths <- seqlengths[1:(sum(seqlengths <= max(these.data[,2]))+1)]
    data.save <- data.frame()

	# for each read length shorter than the longest repeat in the genome,
	# sort the locations of the breaks
	# calculate the length of each break
	# calculate the N50 based on those breaks
    for (len in these.seqlengths) {
        data.gen <- sort(unique(as.numeric(unlist(these.data[these.data[,2] > len,3:6]))))
        data.gen <- c(1,data.gen,wholeg[genome,1])

        data.diff <- sort(abs(diff(data.gen)))
        data.diff <- data.diff[data.diff>len]
    
        data.cumsum <- cumsum(data.diff)
        data.N50 <- data.diff[data.cumsum > max(data.cumsum)/2][1]
        data.longest <- max(data.diff)
        data.contigs <- nrow(data.diff)
        data.save <- rbind(data.save,cbind(genome,len,data.longest,data.longest/max(data.gen),data.N50,data.N50/max(data.gen),data.contigs))
    }
    write.table(data.save,file="longest_repeat_99pct_stats.csv",append=T,row.name=F,sep="\t",quote=F)    
}

#read back in results
stats.in <- read.table("longest_repeat_99pct_stats.csv",sep="\t",header=T)
stats.in <- stats.in[-c(which(stats.in[,1]=="genome")),]
colnames(stats.in) <- c("genome","len","longest","longest.pct","N50","N50.pct","contigs")

stats.work <- stats.in
stats.work[,c(2,3,4,5,6,7)] <- as.numeric( as.matrix(stats.in[,c(2,3,4,5,6,7)]) )

lrk = data.frame()
for (i in unique(stats.work$len)) {
    lrk <- rbind(lrk,cbind(i,length(which(stats.work$len==i))))
    }  

qplot(lrk[,1],lrk[,2]/lrk[1,2], xlim=c(0,10001),xlab="length of repeated sequence (99% identity)",ylab="fraction of genomes with repeat") + theme(axis.text=element_text(size=16), axis.title=element_text(size=20))
qplot(len,N50.pct,data=stats.work, xlim=c(0,10001), geom="boxplot", xlab="sequence length", ylab="maximum theoretical N50\n(as fraction of genome size)", group=len, outlier.size=0) + theme(axis.text=element_text(size=16), axis.title=element_text(size=20))
qplot(lrk[,1],(lrk[1,2]-lrk[,2])/lrk[1,2], xlim=c(0,10001), geom="point", xlab="read length", ylab="fraction of closable genomes") + theme(axis.text=element_text(size=16), axis.title=element_text(size=20))
