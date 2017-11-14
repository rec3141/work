library(stringr)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)

#file.in <- "assembly_graph.gfa"

for (file.in in args) {

    no_col <- max(count.fields(file.in, sep = "\t"))
    gfa.in <- read.table("assembly_graph.gfa",sep="\t",stringsAsFactors=F,fill=T,strip.white=TRUE,col.names=1:no_col)

    gfa.s <- which(gfa.in[,1]=='S')
    gfa.ns <- which(gfa.in[,1]!='S')

    all.seq <- paste(gfa.in[gfa.s,3],collapse="")

    #GC skew
    #g.all <- unlist(lapply(gfa.in[,3],function(x) str_count(x,"[Gg]")))
    #c.all <- unlist(lapply(gfa.in[,3],function(x) str_count(x,"[Cg]")))
    #gfa.gc <- (g.all - c.all)/(g.all + c.all)

    #GC fraction
    #gc.avg <- str_count(all.seq,"[GCgc]")/str_count(all.seq,"[ATGCatgc]")
    gfa.gc <- unlist(lapply(gfa.in[,3],function(x) str_count(x,"[GCgc]"))) / unlist(lapply(gfa.in[,3],function(x) str_count(x,"[ATGCatgc]")))

    range01 <- function(x){(x-min(x))/(max(x)-min(x))}
    gfa.01 <- range01(gfa.gc[gfa.s])

    #colors <- brewer.pal(9, "Oranges")
    #pal <- colorRampPalette(colors)
    #all.colors <- pal(1000)

    all.colors <- topo.colors(1000)

    #CL:z:#bc5a83    C2:z:#bc5a83

    gfa.cl <- substr(unlist(lapply(gfa.01[gfa.s],function(x) paste("CL:z:",all.colors[round(x*1000)],sep=""))),1,12)
    gfa.c2 <- substr(unlist(lapply(gfa.01[gfa.s],function(x) paste("C2:z:",all.colors[round(x*1000)],sep=""))),1,12)

    gfa.in["CL"] <- c(gfa.cl,rep('',length(gfa.ns)))
    gfa.in["C2"] <- c(gfa.c2,rep('',length(gfa.ns)))

    write.table(gfa.in,file=paste("color_",file.in,sep=""),sep="\t",quote=F,row.names=F,col.names=F)
    write.table(cbind(gfa.in[gfa.s,2],round(gfa.gc[gfa.s],3)),file=paste("color_",file.in,".csv",sep=""),quote=F,row.names=F,col.names=c("id","GC"),sep=",")

}
