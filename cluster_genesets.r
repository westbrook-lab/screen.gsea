## to cluster genesets given a correlation matrix

cluster_genesets = function(input,merge.threshold = .10,output='') {
	new.matrix = read.table(input,header=T,sep='\t')
	new.matrix = new.matrix[order(rownames(new.matrix)),]
	lengths = rowSums(new.matrix)
	diss.matrix = as.matrix(daisy(new.matrix,'manhattan'))
	diss.matrix = diss.matrix[order(rownames(diss.matrix)),order(colnames(diss.matrix))]
	sum.length.matrix = diss.matrix
	for(i in 1:nrow(sum.length.matrix)) {
		for(j in 1:ncol(sum.length.matrix)) {
			sum.length.matrix[i,j] = sum(lengths[i],lengths[j])
		}
	}
	max.length.matrix = diss.matrix
	for(i in 1:nrow(max.length.matrix)) {
		for(j in 1:ncol(max.length.matrix)) {
			max.length.matrix[i,j] = max(lengths[i],lengths[j])
		}
	}
	core.matrix = (sum.length.matrix-diss.matrix)/2
	max.diss.matrix = max.length.matrix-core.matrix
	merge.matrix = max.diss.matrix/max.length.matrix
	for(i in 1:nrow(merge.matrix)) {
		merge.matrix[i,i] = NA
	}
	count = 0
	report = list()
	while(min(merge.matrix,na.rm = T) <= merge.threshold) {
		count = count+1
		min.ind = arrayInd(which.min(merge.matrix),dim(merge.matrix))
		min.row = min.ind[1,1]
		min.col = min.ind[1,2]
		new.row = new.matrix[min.row,] + new.matrix[min.col,]
		core.genes = colnames(new.row[which(new.row == 2)])
		core.genes = paste(core.genes,sep='',collapse=';')
		new.row[new.row == 2] = 1
		new.rowname = paste(rownames(new.matrix)[min.row],rownames(new.matrix)[min.col],sep='; ')
		report[count] = list(c(
				new.rowname,rownames(new.matrix)[min.col],rownames(new.matrix)[min.row], ## names of genesets involved in merge
				lengths[min.col],lengths[min.row], ## lengths of genesets A and B
				core.matrix[min.row,min.col],core.genes, ## number of genes shared by genesets A and B and their names
				diss.matrix[min.row,min.col],lengths[min.col]-core.matrix[min.row,min.col],lengths[min.row]-core.matrix[min.row,min.col],max.diss.matrix[min.row,min.col], ## combined, individual, and maximum dissimilarities of genesets A and B
				merge.matrix[min.row,min.col],sum(new.row) ## merge coefficient and length of merged geneset
				))
		trimmed.matrix = new.matrix[c(-min.row,-min.col),] ## remove merged rows from correlation matrix
		new.matrix = rbind(trimmed.matrix,new.row) ## add new row to correlation matrix
		rownames(new.matrix) = c(rownames(trimmed.matrix),new.rowname)
		new.matrix = new.matrix[order(rownames(new.matrix)),]
		lengths = rowSums(new.matrix)
		diss.matrix = as.matrix(daisy(new.matrix,'manhattan'))
		diss.matrix = diss.matrix[order(rownames(diss.matrix)),order(colnames(diss.matrix))]
		sum.length.matrix = diss.matrix
		for(i in 1:nrow(sum.length.matrix)) {
			for(j in 1:ncol(sum.length.matrix)) {
				sum.length.matrix[i,j] = sum(lengths[i],lengths[j])
			}
		}
		max.length.matrix = diss.matrix
		for(i in 1:nrow(max.length.matrix)) {
			for(j in 1:ncol(max.length.matrix)) {
				max.length.matrix[i,j] = max(lengths[i],lengths[j])
			}
		}
		core.matrix = (sum.length.matrix-diss.matrix)/2
		max.diss.matrix = max.length.matrix-core.matrix
		merge.matrix = max.diss.matrix/max.length.matrix
		for(i in 1:nrow(merge.matrix)) {
			merge.matrix[i,i] = NA
		}
		print(paste('Rows ',min.col,' and ',min.row,' merged.'))
	}
	print(paste(count,' merges performed.',sep=''))
	names(report) = c(1:count)
	write.table(new.matrix,output,sep='\t')
	write.table(t(data.frame(report,row.names = c('New Geneset','Geneset A','Geneset B','Length A','Length B','Core Length','Core Genes','Total Diss','Diss A','Diss B','Max Diss','Merge Coefficient','Merged Length'))),paste(output,'report','txt',sep='.'),row.names=F,sep='\t')
}