#' Performs exact test for mutual exclusive events.
#'
#' @description Performs statistical test between given set of genes for mutual excluisiveness.
#' @references Leiserson, Mark DM et al. CoMEt: A Statistical Approach to Identify Combinations of Mutually Exclusive Alterations in Cancer. Genome Biology 16.1 (2015): 160.
#'
#' @param maf an \code{\link{MAF}} object generated by \code{\link{read.maf}}
#' @param genes A pair of genes between which test should be performed. If its null, test will be performed between all combinations of top ten genes.
#' @param top  check for exclusiveness among top 'n' number of genes. Defaults to top 10. \code{genes}
#' @return table with number of events in all possible combinations and p-value. Column header describes mutation status of gene1 and gene2 respectively. n.00 number of samples where both gene1 and gene2 are not mutated c.01 number of samples where gene1 is not mutated but gene2 is mutated and so on.
#' @examples
#' laml.maf <- system.file("extdata", "tcga_laml.maf.gz", package = "maftools")
#' laml <- read.maf(maf = laml.maf, removeSilent = TRUE, useAll = FALSE)
#' mutExclusive(maf = laml, top = 5)
#'
#' @import cometExactTest
#' @export


mutExclusive = function(maf, genes = NULL, top = 10){

  mat = maf@numericMatrix
  ampdel = as.numeric(names(maf@classCode[maf@classCode %in% c('Amp', 'Del')]))

  if(length(ampdel) > 0){
    for(i in 1:length(ampdel)){
      mat[mat == ampdel[i]] = 0
    }
    mat = sortByMutation(numMat = mat, maf = maf)
  }

  k = 2 #for now do test for a pair of genes
  #create a grid of binary matrix for k genes
  grid.mat = t(expand.grid(rep(list(0:1), k)))

  #colllapse grid and get all the levels (all posiible combinations)
  lvls = names(table(apply(grid.mat, 2, paste, collapse = '')))

  #convert various Variant_Classification class codes to binary (1 = mutated; 0 = nonmutated)
  mat[mat>0] = 1

  #if gene list is not given, use top ten genes and do pairwise comparision
  if(is.null(genes)){

    #choose top genes
    if(nrow(mat) < top){
      mat = mat
    }else{
      mat = mat[1:top,]
    }
    genes = rownames(mat)
    genes.combn = combn(genes, 2) #generate all pairwise combinations of top n genes chosen.
  } else{

    if(length(genes) < 2){
      stop('provide atleast two genes between which exlclusiveness has to be estimated.')
    }
    genes.combn = combn(genes, 2) #generate all pairwise combinations of top n genes chosen.
  }

    ptbl.df = c() #table to store p-values and raw counts

    for(i in 1:ncol(genes.combn)){
      geneSet = genes.combn[,i]
      geneMat = mat[geneSet,]
      mat.collapse = data.frame(table(apply(geneMat, 2, paste, collapse = '')))
      #check if for any missing combinations
      lvls.missing = lvls[!lvls %in% mat.collapse[,1]]

      if(length(lvls.missing) > 0){
        mat.collapse = rbind(mat.collapse, data.frame(Var1 = lvls.missing, Freq = 0)) #add missing combinations with zero values
      }

      #reorder
      mat.collapse = mat.collapse[order(mat.collapse$Var1),]

      #run comet exact test for significance
      pval = cometExactTest::comet_exact_test(tbl = as.numeric(x = mat.collapse$Freq), mutmatplot = FALSE)
      #pval = format(x = pval, digits = 3) #three decimal points
      #make a table
      ptbl = rbind(mat.collapse, data.frame(Var1 = rep(paste('gene', 1:length(geneSet), sep='')), Freq = geneSet))
      ptbl = rbind(ptbl, data.frame(Var1 = 'pval', Freq = pval))
      ptbl.df = rbind(ptbl.df,t(data.frame(row.names = ptbl$Var1, N = ptbl$Freq)))
    }

  ptbl.df = data.frame('n.00' = ptbl.df[,1], 'n.01' = ptbl.df[,2], 'n.10' = ptbl.df[,3], 'n.11' = ptbl.df[,4], 'gene1' = ptbl.df[,5], 'gene2' = ptbl.df[,6], 'pval' = ptbl.df[,7], row.names = NULL)
  ptbl.df = ptbl.df[order(ptbl.df$pval, decreasing = FALSE),]
  rownames(ptbl.df) = 1:nrow(ptbl.df)
  return(ptbl.df)
}
